{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections     #-}
{-# LANGUAGE TypeApplications  #-}

module Main where

import Data.Bifunctor (bimap)
import Data.Functor ((<&>))
import GHC.IO.Encoding (setLocaleEncoding, utf8)
import System.Environment (getArgs)
import System.IO (hSetBuffering, stdout, BufferMode(LineBuffering))

import Data.Map.Strict (keys)
import qualified Graphics.UI.Threepenny as UI
import Graphics.UI.Threepenny.Core
import Foreign.JavaScript (IsHandler, JSObject)

import SoundChange.Apply (applyStr)
import SoundChange.Category (values)
import SoundChange.Parse
import SoundChange.Types (getGrapheme, Grapheme, WordPart, Rule(..), Flags(..))
import Data.List (intercalate)
import Data.Maybe (mapMaybe)
import Data.Either (fromRight)

main :: IO ()
main = do
    setLocaleEncoding utf8
    hSetBuffering stdout LineBuffering
    [port] <- getArgs
    startGUI defaultConfig {
          jsCustomHTML = Just "gui.html"
        , jsStatic = Just "static"
        , jsPort = Just (read port)
        } setup

setup :: Window -> UI ()
setup window = do
    cats     <- getElementById' "categories"
    rules    <- getElementById' "rules"
    words    <- getElementById' "words"
    applyBtn <- getElementById' "applyBtn"
    reportBtn <- getElementById' "reportBtn"
    out      <- getElementById' "out"

    -- A 'Behaviour' to keep track of the previous output.
    (prevOutE, setPrevOut) <- liftIO $ newEvent @[Component [WordPart]]
    prevOut <- stepper [] prevOutE

    on UI.keydown cats $ const $ do
        catsText  <- lines <$> get value cats
        rehighlight catsText

    on UI.click applyBtn $ const $ do
        catsText  <- lines <$> get value cats
        rulesText <- fmap lines $ callFunction $ ffi "rulesCodeMirror.getValue()"
        wordsText <- get value words

        let cats = parseCategoriesSpec catsText
            rules = parseRules cats rulesText

            results = fmap (fmap $ applyRulesWithChanges rules . fmap Right) . tokeniseWords (values cats) $ wordsText

        prevResults <- liftIO $ currentValue prevOut
        liftIO $ setPrevOut $ (fmap.fmap) fst results

        results' <- getHlMode <&> \mode -> detokeniseWords' id $
            zipWithComponents results prevResults [] $ \(word, hasBeenAltered) prevWord ->
                case mode of
                    HlNone -> concat $ mapMaybe getGrapheme word
                    HlRun -> surroundBold (word /= prevWord) $ concat $ mapMaybe getGrapheme word
                    HlInput -> surroundBold hasBeenAltered $ concat $ mapMaybe getGrapheme word

        element out # set html results'

    on UI.click reportBtn $ const $ do
        catsText  <- lines <$> get value cats
        rulesText <- fmap lines $ callFunction $ ffi "rulesCodeMirror.getValue()"
        wordsText <- lines <$> get value words

        let cats = parseCategoriesSpec catsText
            rules = mapMaybe (\ruleText -> (ruleText,) <$> parseRule cats ruleText) rulesText

            results = fmap (fmap $ applyRulesWithLog rules . fmap Right) . tokeniseWords (values cats) <$> wordsText

        element out # set html (unlines $ fmap formatLog $ concat $ concat $ getWords <$> results)

    _ <- exportAs "openRules" $ runUI window . openRules cats rules
    _ <- exportAs "saveRules" $ runUI window . saveRules cats rules
    _ <- exportAs "openLexicon" $ runUI window . openLexicon words
    _ <- exportAs "saveLexicon" $ runUI window . saveLexicon words

    return ()
  where
    getElementById' i = getElementById window i >>= \case
        Nothing -> error "Tried to get nonexistent ID"
        Just el -> return el

    surroundBold False w = w
    surroundBold True  w = "<b>" ++ w ++ "</b>"

    formatLog RuleApplied{..} =
        let input'  = intercalate "·" $ fromRight "%" <$> input
            output' = intercalate "·" $ fromRight "%" <$> output
        in "<b>" ++ rule ++ "</b> changed <b>" ++ input' ++ "</b> to <b>" ++ output' ++ "</b>"

    zipWith2' :: [[Component a]] -> [[Component b]] -> b -> (a -> b -> c) -> [[Component c]]
    zipWith2' ass bss bd f = zipWith' ass bss [] $ \as bs -> zipWithComponents as bs bd f

    zipWith' :: [a] -> [b] -> b -> (a -> b -> c) -> [c]
    zipWith' []      _     _ _ = []
    zipWith' as     []     bd f = fmap (`f` bd) as
    zipWith' (a:as) (b:bs) bd f = f a b : zipWith' as bs bd f

    zipWithComponents :: [Component a] -> [Component b] -> b -> (a -> b -> c) -> [Component c]
    zipWithComponents []             _            _  _ = []
    zipWithComponents as            []            bd f = (fmap.fmap) (`f` bd) as
    zipWithComponents (Word a:as)   (Word b:bs)   bd f = Word (f a b) : zipWithComponents as bs bd f
    zipWithComponents as@(Word _:_) (_:bs)        bd f = zipWithComponents as bs bd f
    zipWithComponents (a:as)        bs@(Word _:_) bd f = unsafeCastComponent a : zipWithComponents as bs bd f
    zipWithComponents (a:as)        (_:bs)        bd f = unsafeCastComponent a : zipWithComponents as bs bd f

applyRulesWithChanges :: [Rule] -> [WordPart] -> ([WordPart], Bool)
applyRulesWithChanges = flip (go . (,False))
  where
    go gs [] = gs
    go (gs,w) (r:rs) =
        let gs' = applyStr r gs
        in go (gs', w || (not (highlightChanges $ flags r) && (gs/=gs'))) rs

data LogItem = RuleApplied
    { rule :: String
    , input :: [WordPart]
    , output :: [WordPart]
    } deriving (Show)

applyRulesWithLog :: [(String, Rule)] -> [WordPart] -> [LogItem]
applyRulesWithLog = go []
  where
    go log []     _ = log
    go log ((rstr,r):rs) gs =
        let gs'  = applyStr r gs
            log' = if gs == gs' then log else RuleApplied rstr gs gs' : log
        in go log' rs gs

data HlMode = HlNone | HlRun | HlInput deriving (Show)

getHlMode :: UI HlMode
getHlMode = callFunction (ffi @(JSFunction String) "$('input[name=hl-options]:checked').val()") >>= \case
    "hl-none"  -> return HlNone
    "hl-run"   -> return HlRun
    "hl-input" -> return HlInput
    _ -> error "unexpected highlighting mode"

rehighlight :: [String] -> UI ()
rehighlight catsText =
    let catNames = keys $ parseCategoriesSpec catsText
    in runFunction $ ffi "setupMode(%1)" catNames

exportAs :: IsHandler a => String -> a -> UI JSObject
exportAs name h = do
    ref <- ffiExport h
    runFunction $ ffi ("window.hs." ++ name ++ " = %1") ref
    return ref

openRules :: Element -> Element -> FilePath -> UI ()
openRules cats rules path = do
    (catsText, rulesText) <- liftIO $ decodeRules <$> readFile path
    runFunction $ ffi "rulesCodeMirror.setValue(%1)" rulesText
    _ <- element cats # set value catsText
    rehighlight $ lines catsText

    return ()

decodeRules :: String -> (String, String)
decodeRules = bimap unlines (unlines.tail) . span (/="[rules]") . lines

saveRules :: Element -> Element -> FilePath -> UI ()
saveRules cats rules path = do
    catsText <- get value cats
    rulesText <- callFunction $ ffi "rulesCodeMirror.getValue()"

    liftIO $ writeFile path $ encodeRules catsText rulesText

encodeRules
    :: String  -- ^ Categories
    -> String  -- ^ Rules
    -> String
encodeRules cats rules = cats ++ "\n[rules]\n" ++ rules

openLexicon :: Element -> FilePath -> UI ()
openLexicon words path = liftIO (readFile path) >>= ($ element words) . set value >> pure ()

saveLexicon :: Element -> FilePath -> UI ()
saveLexicon words path = get value words >>= liftIO . writeFile path
