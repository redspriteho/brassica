#include "ruleshighlighter.h"

RulesHighlighter::RulesHighlighter(QTextDocument *parent)
    : QSyntaxHighlighter(parent)
{
    QTextCharFormat specialCharsFormat;
    specialCharsFormat.setForeground(QColor(0, 0, 255));
    formats.append(specialCharsFormat);
    patterns.append(QRegularExpression(R"(>|#|\(|\)|{|}|\\|^|%|~|\*|categories|end|new)"));

    QTextCharFormat separatorFormat;
    separatorFormat.setFontWeight(QFont::Bold);
    formats.append(separatorFormat);
    patterns.append(QRegularExpression("/|_"));

    QTextCharFormat commentFormat;
    commentFormat.setForeground(QColor(0, 128, 0));
    commentFormat.setFontItalic(true);
    formats.append(commentFormat);
    patterns.append(QRegularExpression(R"(;.*)"));

    categoryFormat = QTextCharFormat();
    categoryFormat.setBackground(QColor(245, 245, 220));
    setCategories(QStringList());
}

void RulesHighlighter::setCategories(QStringList categories)
{
    if (m_categories != categories)
    {
        m_categories = categories;

        QString regexpText(R"(\[.*?\])");  // start with regexp for ad-hoc category
        for (int i = 0; i < categories.length(); ++i)
        {
            regexpText += '|' + QRegularExpression::escape(categories[i]);
        }
        categoriesPattern = QRegularExpression(regexpText);

        rehighlight();
    }
}

void RulesHighlighter::highlightBlock(const QString &text)
{
    for (int i = 0; i < patterns.length(); i++)
    {
        QRegularExpressionMatchIterator itr = patterns[i].globalMatch(text);
        while (itr.hasNext())
        {
            QRegularExpressionMatch m = itr.next();
            setFormat(m.capturedStart(), m.capturedLength(), formats[i]);
        }
    }

    {
        QRegularExpressionMatchIterator itr = categoriesPattern.globalMatch(text);
        while (itr.hasNext())
        {
            QRegularExpressionMatch m = itr.next();
            setFormat(m.capturedStart(), m.capturedLength(), categoryFormat);
        }
    }
}