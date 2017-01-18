#ifndef MARKDOWNDOCUMENT_H
#define MARKDOWNDOCUMENT_H

#include <QChar>
#include <QHash>
#include <QObject>
#include <QRegExp>
#include <QTextCursor>
#include <QQuickItem>
#include <QQuickTextDocument>
#include <QQmlAutoPropertyHelpers.h>

class MarkdownDocument : public QQuickItem
{
    Q_OBJECT
    QML_WRITABLE_AUTO_PROPERTY(QQuickTextDocument*, textDocument)
    QML_WRITABLE_AUTO_PROPERTY(bool, enabled)
    QML_WRITABLE_AUTO_PROPERTY(bool, autoMatchEnabled)
    QML_WRITABLE_AUTO_PROPERTY(bool, cycleBulletMarker)
    QML_WRITABLE_AUTO_PROPERTY(bool, enableLargeHeadingSizes)
    QML_WRITABLE_AUTO_PROPERTY(bool, useUnderlineForEmp)
    QML_WRITABLE_AUTO_PROPERTY(bool, spacesForTabs)
    QML_WRITABLE_AUTO_PROPERTY(int, tabWidth)
    QML_WRITABLE_AUTO_PROPERTY(int, paperMargins)
    QML_WRITABLE_AUTO_PROPERTY(bool, hasSelection)
    QML_WRITABLE_AUTO_PROPERTY(int, selectionStart)
    QML_WRITABLE_AUTO_PROPERTY(int, selectionEnd)
    Q_PROPERTY(int cursorPosition READ cursorPosition WRITE setCursorPosition NOTIFY cursorPositionChanged)
    Q_ENUMS(BulletListMarkerType)
    Q_ENUMS(NumberedListMarkerType)
public:
    explicit MarkdownDocument(QQuickItem *parent = 0);

    enum BulletListMarkerType {
        Asterisk,
        Minus,
        Plus
    };

    enum NumberedListMarkerType {
        Period,
        Parenthesis
    };

    int cursorPosition() const;

signals:

    void cursorPositionChanged(int cursorPosition);

public slots:
//    void bold();
//    void italic();
//    void strikeThrough();
//    void insertComment();
//    void createBulletList(BulletListMarkerType markerType);
//    void createNumberedList(NumberedListMarkerType markerType);
//    void createTaskList();
//    void createBlockQuote();
//    void removeBlockQuote();
    void indentText();
    void unindentText();
    void setCursorPosition(int cursorPosition);

protected:
    QTextDocument *document() const;
    void keyPressEvent(QKeyEvent *event);
    void handleCLRF();

private slots:
    void onDocumentChanged();
    void onContentsChange(const int &pos, const int &rm, const int &add);
private:
    QTextCursor textCursor();
    bool insertPair(const QChar &c);
    bool endPairHandled(const QChar &c);
    QHash<QChar, QChar> m_pairs;
    QHash<QChar, bool> m_matches;
    QRegExp m_blockQuote;
    QRegExp m_numList;
    QRegExp m_bulletList;
    QRegExp m_taskList;
    QTextCursor m_cursor;
    int m_cursorPosition;
};

#endif // MARKDOWNDOCUMENT_H
