#include "ClientServiceAction.h"
#include <qmaildisconnected.h>
#include <qmailmessage.h>
#include <qmailaccount.h>
#include <QDebug>

DeleteMessagesAction::DeleteMessagesAction(QObject *parent, const QMailMessageIdList &msgIds):
    UndoableAction(parent), m_ids(msgIds)
{
    m_itemType = ItemType::Message;
    m_serviceActionType = ServiceAction::DeleteAction;
    m_description = QStringLiteral("Deleting %1 messages.").arg(m_ids.count());
}

void DeleteMessagesAction::process()
{
    qDebug() << "Moving to trash" << m_ids.at(0).toULongLong();
    QMailDisconnected::moveToStandardFolder(m_ids,QMailFolder::TrashFolder);
    qDebug() << "Mark message deleted";
    QMailDisconnected::flagMessages(m_ids,QMailMessage::Trash,0,"Marking messages as deleted");
}

int DeleteMessagesAction::itemCount()
{
    return m_ids.count();
}

QMailAccountIdList DeleteMessagesAction::accountIds()
{
    QMailAccountIdList accounts;
    Q_FOREACH(auto &id, m_ids) {
        QMailAccountId accountId = QMailMessageMetaData(id).parentAccountId();
        if (!accounts.contains(accountId)) {
            accounts.append(accountId);
        }
    }
    return accounts;
}

ExportUpdatesAction::ExportUpdatesAction(QObject *parent, const QMailAccountId &id) :
    ClientServiceAction(parent), m_accountId(id)
{
    m_actionType = ActionType::Silent;
    m_serviceActionType = ServiceAction::ExportAction;
    m_description = tr("Syncing changes for %1 account").arg(QMailAccount(m_accountId).name());
}

void ExportUpdatesAction::process()
{
    qDebug() << "Exporting updates for account: " << QMailAccount(m_accountId).name();
    createRetrievalAction()->exportUpdates(m_accountId);
}

FlagsAction::FlagsAction(QObject *parent, const QMailMessageIdList &msgs,
                         const FlagsAction::FlagType &flag, const FlagsAction::State &state) :
    ClientServiceAction(parent), m_idList(msgs), m_flag(flag), m_state(state) {

    m_actionType = ActionType::Immediate;
    m_serviceActionType = ServiceAction::FlagAction;
    QString count = QString::number(m_idList.count());
    QString flagAction;
    switch (m_flag) {
    case FlagStarred:
    {
        switch (m_state) {
        case State::Apply:
            flagAction = tr("important");
            break;
        case State::Remove:
            flagAction = tr("not important");
            break;
        }
        break;
    }
    case FlagRead:
    {
        switch (m_state) {
        case State::Apply:
            flagAction = tr("read");
            break;
        case State::Remove:
            flagAction = tr("unread");
            break;
        }
        break;
    }
    case FlagTodo:
    {
        switch (m_state) {
        case State::Apply:
            flagAction = tr("as todo");
            break;
        case State::Remove:
            flagAction = tr("no loger todo");
            break;
        }
    }
    }
    m_description = tr("Marking %1 messages %2").arg(count, flagAction);
}

void FlagsAction::process()
{
    if (m_idList.isEmpty()) {
        return;
    }
    quint64 applyMask = 0;
    quint64 removeMask = 0;

    switch (m_flag) {
    case FlagStarred:
    {
        switch (m_state) {
        case State::Apply:
            applyMask = QMailMessage::Important;
            break;
        case State::Remove:
            removeMask = QMailMessage::Important;
            break;
        }
        break;
    }
    case FlagRead:
    {
        switch (m_state) {
        case State::Apply:
            applyMask = QMailMessage::Read;
            break;
        case State::Remove:
            removeMask = QMailMessage::Read;
            break;
        }
        break;
    }
    case FlagTodo:
    {
        switch (m_state) {
        case State::Apply:
            applyMask = QMailMessage::Todo;
            break;
        case State::Remove:
            removeMask = QMailMessage::Todo;
            break;
        }
        break;
    }
    }
    QMailDisconnected::flagMessages(m_idList, applyMask, removeMask, m_description);
}

QMailAccountIdList FlagsAction::accountIds()
{
    QMailAccountIdList accounts;
    Q_FOREACH(auto &id, m_idList) {
        QMailAccountId accountId = QMailMessageMetaData(id).parentAccountId();
        if (!accounts.contains(accountId)) {
            accounts.append(accountId);
        }
    }
    return accounts;
}




