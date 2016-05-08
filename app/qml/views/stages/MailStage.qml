import QtQuick 2.4
import Ubuntu.Components 1.3
import Dekko.Components 1.0
import Dekko.Settings 1.0
import QuickFlux 1.0
import "../../actions"
import "../../actions/logging"
import "../../actions/messaging"
import "../../actions/views"
import "../../stores"
import "../components"

BaseStage {
    id: ms

    panelContent: Label {
        anchors.centerIn: parent
        text: "Dev widgets will go in this panel"
    }
    panelEnabled: false
    
    // We use a stretch row here rather than RowLayout
    // Just because we can use the implicit size hints to stretch the correct
    // panel. Yes we could use Layout.fillWidth but in the future there maybe
    // more columns added to this (through plugins) and we may want to share remaining width evenly between two
    // or more colums. Which StretchRow handles
    StretchRow {
        spacing: 0
        anchors.fill: parent
        // Should only be visible on large FF
        // Access is done via the navigation drawer
        // for smaller FF's
        PanelContainer {
            visible: dekko.viewState.isLargeFF
            resizable: !dekko.viewState.isSmallFF
            minSize: units.gu(30)
            maxSize: units.gu(50)
            height: parent.height
            activeEdge: Item.Right
            StageArea {
                id: navMenuStage
                stageID: ViewKeys.navigationStack
                anchors.fill: parent
                baseUrl: "qrc:/qml/views/NavMenuPage.qml"
            }
        }

        PanelContainer {
            // This is where we could no longer
            // work with AdaptivePageLayout
            // Our center column is actually our main page
            // when on small form factor devices, and having to
            // pop/push and rejig evenrything was just awful
            // Plus i prefer our api.
            // So we set this main page to fill screen width when
            // on small FF. This sets the implicit width to -1
            // and restores it on going back to larger FF's
            stretchOnSmallFF: true
            resizable: !dekko.viewState.isSmallFF
            minSize: units.gu(40)
            maxSize: units.gu(60)
            size: units.gu(40)
            height: parent.height
            activeEdge: Item.Right
            StageArea {
                id: msgListStage
                stageID: ViewKeys.messageListStack
                anchors.fill: parent
                baseUrl: "qrc:/qml/views/MessageListView.qml"
                function rewind() {
//                    while (stackCount !== 1) {
//                        Log.logInfo("MailStage::openFolder", "Popping page")
//                        ViewActions.popStageArea(ViewKeys.messageListStack)
//                    }
                    if (stackCount > 1) {
                        while (stackCount !== 1) {
                            pop()
                        }
                    }
                }
            }
        }
        // Take rest of space when visible
        Stretcher {
            visible: !dekko.viewState.isSmallFF
            anchors {
                top: parent.top
                bottom: parent.bottom
            }
            StageArea {
                id: msgViewStage
                stageID: ViewKeys.messageViewStack
                anchors.fill: parent
                immediatePush: true
                baseUrl: "qrc:/qml/views/NothingSelectedPage.qml"
            }
        }
    }

    GlobalSettings {
        id: globalSettings

        function messageViewStyle() {
            if (data.messageview.style === "default") {
                return "qrc:/qml/views/messageview/DefaultMessagePage.qml"
            } else if (data.messageview.style === "clean") {
                return "qrc:/qml/views/messageview/CleanMessagePage.qml"
            }
        }
    }

    AppListener {
        Filter {
            type: MessageKeys.openMessage
            onDispatched: {
                var style = globalSettings.messageViewStyle()
                if (dekko.viewState.isSmallFF) {
                    // leftStage push msgview
                    ViewActions.pushToStageArea(ViewKeys.messageListStack, style, {msgId: message.msgId})
                } else {
                    if (msgViewStage.stackCount > 1) {
                        ViewActions.replaceTopStageAreaItem(ViewKeys.messageViewStack, style, {msgId: message.msgId})
                    } else {
                        ViewActions.pushToStageArea(ViewKeys.messageViewStack, style, {msgId: message.msgId})
                    }
                }
            }
        }

        Filter {
            type: MessageKeys.rewindMessageListStack
            onDispatched: {
                // Listen for a new folder opening and pop the stack
                // until wee get to the msglist. MailStore is also listening on this and will take
                // care of actually opening the folder.
                Log.logInfo("MailStage::openFolder", "Checking stack count")
                msgListStage.rewind()
//                if (msgListStage.stackCount > 1) {
//                    Log.logInfo("MailStage::openFolder", "Popping the stack to show msg list")
//                    msgListStage.rewind()
//                }
            }
        }

        Filter {
            type: MessageKeys.openAccountFolder
            onDispatched: {
                if (dekko.viewState.isLargeFF) {
                    ViewActions.pushToStageArea(ViewKeys.navigationStack,
                                                "qrc:/qml/views/FolderListView.qml",
                                                {
                                                    pageTitle: message.accountName,
                                                    accountId: message.accountId
                                                })
                } else {
                    ViewActions.pushToStageArea(ViewKeys.messageListStack,
                                                "qrc:/qml/views/FolderListView.qml",
                                                {
                                                    pageTitle: message.accountName,
                                                    accountId: message.accountId
                                                })
                }
            }
        }
    }
}
