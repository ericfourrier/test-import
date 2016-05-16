#include "SenderIdentities.h"
#include <qmailaccount.h>

SenderIdentities::SenderIdentities(QObject *parent) : QObject(parent), m_selectedIndex(-1),
    m_accountsModel(0)
{
}

int SenderIdentities::selectedIndex() const
{
    return m_selectedIndex;
}

QObject *SenderIdentities::selectedAccount() const
{
    if (m_selectedIndex < 0 || m_selectedIndex > m_accountsModel->count()) {
        return new QObject();
    }
    return m_accountsModel->at(m_selectedIndex);
}

QObject *SenderIdentities::accountsModel() const
{
    return m_accountsModel;
}

void SenderIdentities::setSelectedIndex(int selectedIndex)
{
    if (m_selectedIndex == selectedIndex)
        return;

    m_selectedIndex = selectedIndex;
    emit selectedIndexChanged();
}

void SenderIdentities::setAccountsModel(QObject *accountsModel)
{
    if (accountsModel == Q_NULLPTR) {
        return;
    }
    if (m_accountsModel) {
        disconnect(m_accountsModel, 0, this, 0);
    }
    QQmlObjectListModel<Account> *model = static_cast<QQmlObjectListModel<Account> *>(accountsModel);
    if (m_accountsModel == model)
        return;

    m_accountsModel = model;
    connect(m_accountsModel, &QQmlObjectListModel<Account>::countChanged, this, &SenderIdentities::accountsChanged);
    emit modelsChanged();
    accountsChanged();
}

void SenderIdentities::setSelectedIndexFromAccountId(quint64 accountId)
{
    if (m_accountsModel->isEmpty()) {
        setSelectedIndex(-1);
        return;
    }
    foreach(Account *account, m_accountsModel->toList()) {
        if (account->accountId() == QMailAccountId(accountId)) {
            setSelectedIndex(m_accountsModel->indexOf(account));
            return;
        }
    }
}

void SenderIdentities::reset()
{
    setSelectedIndex(-1);
    accountsChanged();
}

void SenderIdentities::accountsChanged()
{
    foreach(Account *account, m_accountsModel->toList()) {
        if (account->isPreferredSender()) {
            setSelectedIndex(m_accountsModel->indexOf(account));
            return;
        }
    }
    if (!m_accountsModel->isEmpty()) {
        setSelectedIndex(m_accountsModel->indexOf(m_accountsModel->first()));
    }
}

