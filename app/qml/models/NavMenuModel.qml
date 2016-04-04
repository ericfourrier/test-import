import QtQuick 2.4
import Ubuntu.Components 1.3
import Dekko.Settings 1.0
import "../delegates"
import "../components"

VisualItemModel {

    id: navModel

    property bool panelIsParent: true
    signal openFolder(string accountName, var accountId)


    Item {
        width: navDrawer.width
        height: panelIsParent ? navDrawer.topListViewHandle.height : navDrawer.height

        ScrollView {
            anchors.fill: parent
            Flickable {
                id: flicker
                anchors.fill: parent
                clip: true
                contentHeight: col.height + units.gu(5)
                interactive: col.height > parent.height
                Column {
                    id: col
                    anchors {left: parent.left; right: parent.right; top: parent.top}
                    Column {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        Repeater {
                            id: inboxList
                            model: standardFolders.children
                            delegate: NavMenuStandardFolderDelegate {
                                id: folderDelegate
                                folder: qtObject
                                supportsDescendents: true
                                onClicked: {
                                    if (model.index === 0) {
                                        navDrawer.msgKeySelected(folder.displayName, folder.descendentsKey)
                                    } else {
                                        navDrawer.msgKeySelected(folder.displayName, folder.messageKey)
                                    }
                                }
                                onSubFolderClicked: navDrawer.msgKeySelected(name, key)
                                Component.onCompleted: {
                                    if (model.index === 0) {
                                        navDrawer.msgKeySelected(folder.displayName, folder.descendentsKey)
                                    }
                                }
                            }
                        }
                    }
                    Item {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        height: smf.height
                        NavigationGroup {
                            id: smf
                            title: qsTr("Smart folders")
                            visible: navSettings.data.smartfolders.show
                            model: smartFolders.children
                            expansion.expanded: navSettings.data.smartfolders.expanded
                            onExpandClicked: navSettings.set(NavigationSettings.SmartFoldersExpanded, !navSettings.data.smartfolders.expanded)
                            delegate: NavMenuStandardFolderDelegate {
                                id: smartFolderDelegate
                                folder: qtObject
                                smartFolder: true
                                onClicked: navDrawer.msgKeySelected(folder.displayName, folder.messageKey)
                            }
                        }
                    }

                    Item {
                        anchors {
                            left: parent.left
                            right: parent.right
                        }
                        height: acg.height
                        NavigationGroup {
                            id: acg
                            title: qsTr("Accounts")
                            visible: navSettings.data.accounts.show
                            model: accounts.model
                            expansion.expanded: navSettings.data.accounts.expanded
                            onExpandClicked: navSettings.set(NavigationSettings.AccountsExpanded, !navSettings.data.accounts.expanded)
                            delegate: ListItem {
                                height: dLayout.height
                                divider.visible: false
                                onClicked: openFolder(qtObject.name, qtObject.id)
                                ListItemLayout {
                                    id: dLayout
                                    height: units.gu(6)
                                    title.text: qtObject.name
                                    Icon {
                                        height: units.gu(2.5)
                                        width: height
                                        name: "contact"
                                        SlotsLayout.position: SlotsLayout.Leading
                                    }
                                    ProgressionSlot{}
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        width: navDrawer.width
        height: panelIsParent ? navDrawer.topListViewHandle.height : navDrawer.height

        ScrollView {
            anchors.fill: parent
            ListView {
                anchors.fill: parent
                model: NavMenuContactsModel{}
            }
        }
    }
    Item {
        width: navDrawer.width
        height: panelIsParent ? navDrawer.topListViewHandle.height : navDrawer.height

        ScrollView {
            anchors.fill: parent
            ListView {
                anchors.fill: parent
                model: NavMenuAccountSettingsModel{}
            }
        }
    }
    Item {
        width: navDrawer.width
        height: panelIsParent ? navDrawer.topListViewHandle.height : navDrawer.height

        ScrollView {
            anchors.fill: parent
            ListView {
                anchors.fill: parent
                model: NavMenuDekkoVisualModel{}
            }
        }
    }
}
