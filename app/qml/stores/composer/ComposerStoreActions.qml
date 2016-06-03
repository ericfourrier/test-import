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
import Dekko.Components 1.0
import "../../actions/composer"
import "../../actions/content"

QtObject {

    property Action sendAction: Action {
        text: qsTr("Send")
        iconName: Icons.SendIcon
        iconSource: Paths.actionIconUrl(Icons.SendIcon)
        onTriggered: ComposerActions.sendMessage()
    }

    property Action saveDraftAction: Action {
        text: qsTr("Save draft")
        iconName: Icons.DraftIcon
        iconSource: Paths.actionIconUrl(Icons.DraftIcon)
        onTriggered: ComposerActions.saveDraft()
    }

    property Action discardMessageAction: Action {
        text: qsTr("Discard")
        iconName: Icons.DeleteIcon
        iconSource: Paths.actionIconUrl(Icons.DeleteIcon)
        onTriggered: ComposerActions.discardMessage()
    }

    property Action attachmentsAction: Action {
        text: ""
        iconName: Icons.AttachmentIcon
        iconSource: Paths.actionIconUrl(Icons.AttachmentIcon)
        onTriggered: ContentActions.pickFile()
    }
}

