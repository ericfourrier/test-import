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
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Dekko.Mail 1.0
import "../components"
import "../../actions/popups"
import "../../actions/composer"

Popover {
    id: info
    property var address

    property bool composeMode: false
    property int type: -1
    property int index: -1

    Column {
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }

        ListItem {
            height: layout.height
            color: UbuntuColors.porcelain
            ListItemLayout {
                id: layout
                title.text: address ? address.name : model.email
                title.elide: Text.ElideRight
                title.wrapMode: Text.NoWrap
                subtitle.text: {
                    if (address.name) {
                        if (address.name !== address.address)
                            return address.address
                        else
                            return ""
                    }/* else if (model.isInContacts) {
                        return model.contactInfo.organization
                    } else {
                        return ""
                    }*/
                }
//                summary.text: address.name && model.isInContacts ? model.contactInfo.organization : ""
                subtitle.elide: Text.ElideRight
                subtitle.wrapMode: Text.NoWrap

                Avatar {
                    id: avatar
                    name: address.name
                    initials: address.initials
                    email: address.address
                    validContact: true
                    fontSize: "large"
                    SlotsLayout.position: SlotsLayout.Leading
                }
            }
        }

//        ListItem {
//            height: deleteLayout.implicitHeight
//            ListItemLayout {
//                id: deleteLayout
//                title.text: qsTr("Remove")
//                title.font.weight: Style.common.fontWeight
//                title.elide: Text.ElideRight
//                title.wrapMode: Text.NoWrap
//            }
//            onClicked: info.remove()
//        }
        ListItem {
            height: clipboard.implicitHeight
            color: UbuntuColors.porcelain
            ListItemLayout {
                id: clipboard
                title.text: qsTr("Copy to clipboard")
                title.elide: Text.ElideRight
                title.wrapMode: Text.NoWrap
            }
            onClicked: {
                PopupActions.showNotice("Not implemented yet. Fix it before release!!!!")
                PopupUtils.close(info)
            }
        }
        ListItem {
            height: addContactLayout.implicitHeight
            ListItemLayout {
                id: addContactLayout
                title.text: qsTr("Add to addressbook")
                title.elide: Text.ElideRight
                title.wrapMode: Text.NoWrap
            }
            color: UbuntuColors.porcelain
            onClicked: {
                PopupActions.showNotice("Not implemented yet. Fix it before release!!!!")
                PopupUtils.close(info)
            }
        }
        ListItem {
            visible: !composeMode
            height: send.implicitHeight
            color: UbuntuColors.porcelain
            ListItemLayout {
                id: send
                title.text: qsTr("Send message")
                title.elide: Text.ElideRight
                title.wrapMode: Text.NoWrap
            }
            onClicked: {
                PopupActions.showNotice("Not implemented yet. Fix it before release!!!!")
                PopupUtils.close(info)
            }
        }
        ListItem {
            visible: composeMode
            height: remove.implicitHeight
            color: UbuntuColors.porcelain
            ListItemLayout {
                id: remove
                title.text: qsTr("Remove")
                title.elide: Text.ElideRight
                title.wrapMode: Text.NoWrap
            }
            onClicked: {
                ComposerActions.removeRecipient(type, index)
                PopupUtils.close(info)
            }
        }
    }
}

