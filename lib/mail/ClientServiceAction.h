#ifndef CLIENTSERVICEACTION_H
#define CLIENTSERVICEACTION_H

#include <QObject>
#include <QPointer>
#include <qmailserviceaction.h>
#include <QUuid>

class ClientServiceAction : public QObject
{
    Q_OBJECT
public:
    explicit ClientServiceAction(QObject *parent = 0) : QObject(parent)
    {
        m_uid = QUuid::createUuid().toByteArray();
    }

    enum ActionType {
        // Highest priority
        Immediate = 1, /** @short Triggered immediately cannot be undone */
        Undoable, /** @short Triggered immediately but can be undone within 5 seconds */
        Silent /** @short Queued and be processed in the near future; */
    };

    enum ServiceAction {
        CopyAction,
        MoveAction,
        DeleteAction,
        FlagAction,
        RetrieveAction,
        SearchAction,
        SendAction,
        StandardFoldersAction,
        StorageAction,
        TransmitAction,
        ExportAction
    };

    virtual void process() = 0;
    QMailServiceAction *action() const { return m_serviceAction; }
    ActionType actionType() const { return m_actionType; }
    ServiceAction serviceActionType() const { return m_serviceActionType; }
    QString description() const { return m_description; }
    bool isRunning() const { return m_serviceAction ? m_serviceAction->isRunning() : false; }
    QByteArray uid() const { return m_uid; }

    // Used by PriorityQueue
    const bool operator < (const ClientServiceAction *r) const {
        return m_actionType < r->actionType();
    }

    const bool operator == (const ClientServiceAction *r) const {
        return m_uid == r->uid();
    }

signals:
    void activityChanged(QMailServiceAction::Activity activity);

protected:
    ActionType m_actionType;
    ServiceAction m_serviceActionType;
    QString m_description;
    QPointer<QMailServiceAction> m_serviceAction;
    QByteArray m_uid;

    QMailRetrievalAction *createRetrievalAction() {
        m_serviceAction = new QMailRetrievalAction(this);
        connect(m_serviceAction, &QMailServiceAction::activityChanged, this, &ClientServiceAction::activityChanged);
        qDebug() << "Retrieval action created";
        return static_cast<QMailRetrievalAction *>(m_serviceAction.data());
    }

    QMailStorageAction *createStorageAction(){
        m_serviceAction = new QMailStorageAction(this);
        connect(m_serviceAction, &QMailServiceAction::activityChanged, this, &ClientServiceAction::activityChanged);
        return static_cast<QMailStorageAction *>(m_serviceAction.data());
    }

    QMailTransmitAction *createTransmitAction(){
        m_serviceAction = new QMailTransmitAction(this);
        connect(m_serviceAction, &QMailServiceAction::activityChanged, this, &ClientServiceAction::activityChanged);
        return static_cast<QMailTransmitAction *>(m_serviceAction.data());
    }
};

class UndoableAction : public ClientServiceAction
{
    Q_OBJECT
public:
    explicit UndoableAction(QObject *parent = 0) : ClientServiceAction(parent)
    {
        m_actionType = ActionType::Undoable;
    }

    enum ItemType { Folder, Message };
    // Number of QMail* items this action is being applied on
    virtual int itemCount() = 0;
    virtual QMailAccountIdList accountIds() = 0;
    ItemType itemType() const { return m_itemType; }

protected:
    ItemType m_itemType;
};

class DeleteMessagesAction : public UndoableAction
{
    Q_OBJECT
    QMailMessageIdList m_ids;
public:
    DeleteMessagesAction(QObject *parent, const QMailMessageIdList &msgIds);

    void process();
    int itemCount();
    QMailAccountIdList accountIds();
};

class ExportUpdatesAction : public ClientServiceAction
{
    Q_OBJECT
    QMailAccountId m_accountId;
public:
    ExportUpdatesAction(QObject *parent, const QMailAccountId &id);
    void process();
    QMailAccountId accountId() { return m_accountId; }
};

class FlagsAction : public ClientServiceAction
{
    Q_OBJECT

public:

    enum FlagType {
        FlagStarred,
        FlagRead
    };
    enum State {
        Apply,
        Remove
    };

    FlagsAction(QObject *parent, const QMailMessageIdList &msgs,
                const FlagsAction::FlagType &flag, const FlagsAction::State &state);

    void process();
    QMailAccountIdList accountIds();

private:
    QMailMessageIdList m_idList;
    FlagType m_flag;
    State m_state;
};

//class MoveMessagesAction : public UndoableAction
//{
//    Q_OBJECT
//    QMailMessageIdList m_ids;
//    QMailFolderId m_destination;
//public:
//    MoveMessagesAction(QObject *parent, const QMailMessageIdList &msgIds, const QMailFolderId &destination);
//    void process();
//    int itemCount();
//    QMailAccountIdList accountIds();
//};

#endif // CLIENTSERVICEACTION_H