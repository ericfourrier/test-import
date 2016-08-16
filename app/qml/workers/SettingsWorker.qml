/* Copyright (C) 2016 Dan Chapman <dpniel@ubuntu.com>

   This file is part of Dekko email client for Ubuntu devices

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License as
   published by the Free Software Foundation; either version 2 of
   the License or (at your option) version 3

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
import QtQuick 2.4
import QuickFlux 1.0
import Dekko.Accounts 1.0
import Dekko.Settings 1.0
import "../actions/logging"
import "../actions/views"
import "../actions/settings"
import "../stores/settings"

AppListener {

    waitFor: [SettingsStore.listenerId]

    Filter {
        type: SettingsKeys.updateMarkAsReadInterval
        onDispatched: {
            if (!PolicyManager.idValid(message.accountId)) {
                Log.logInfo("SettingsWorker::updateMarkAsReadInterval", "Invalid account id. doing nothing")
                return;
            }
            Log.logInfo("SettingsWorker::updateMarkAsReadInterval", "Updating interval to %1 for account: %2".arg(message.interval).arg(message.accountId))
            PolicyManager.mailPolicy(message.accountId).markAsReadInterval = message.interval
        }
    }

    Filter {
        type: SettingsKeys.updateMarkAsReadMode
        onDispatched: {
            if (!PolicyManager.idValid(message.accountId)) {
                Log.logInfo("SettingsWorker::updateMarkAsReadMode", "Invalid account id. doing nothing")
                return;
            }
            Log.logInfo("SettingsWorker::updateMarkAsReadMode", "Updating mode to %1 for account: %2".arg(message.mode).arg(message.accountId))
            PolicyManager.mailPolicy(message.accountId).markRead = message.mode
        }
    }

    Filter {
        type: SettingsKeys.openSettingsGroup
        onDispatched: {
            SettingsActions.saveCurrentGroup()
            SettingsStore.currentGroup = message.group
            if (dekko.viewState.isSmallFF) {
                ViewActions.pushToStageArea(ViewKeys.settingsStack1, SettingsStore.currentGroup, {})
            } else {
                ViewActions.replaceTopStageAreaItem(ViewKeys.settingsStack2, SettingsStore.currentGroup, {})
            }
        }
    }

    Filter {
        type: SettingsKeys.switchSettingsGroupLocation
        onDispatched: {
            SettingsActions.saveCurrentGroup()
            ViewActions.popStageArea(message.stackKey)
            delaySwitch.start()
        }
        property Timer delaySwitch: Timer {
            interval: 50
            repeat: false
            onTriggered: {
                SettingsActions.openSettingsGroup(SettingsStore.currentGroup)
            }
        }
    }

    Filter {
        type: SettingsKeys.setSelectedAccount
        onDispatched: {
            SettingsStore.selectedAccount = message.account
        }
    }

    Filter {
        type: SettingsKeys.saveSelectedAccount
        onDispatched: {
            SettingsStore.selectedAccount.save()
            ViewActions.orderSimpleToast(qsTr("Account saved"))
        }
    }
}
