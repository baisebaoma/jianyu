// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk.Pages
import Fk.RoomElement

GraphicsBox {
  id: root

  title.text: Backend.translate("输入技能名")
  width: 300
  height: 100

  ColumnLayout {
    anchors.fill: parent
    anchors.topMargin: 40
    anchors.leftMargin: 20
    anchors.rightMargin: 20
    anchors.bottomMargin: 40

    RowLayout {
      anchors.rightMargin: 8
      spacing: 16

      TextField {
        id: word
        maximumLength: 12
        placeholderText: "技能名"
        clip: true
        verticalAlignment: Qt.AlignVCenter
        background: Rectangle {
          implicitHeight: 16
          implicitWidth: 120
          color: "white"
        }
      }

      ToolButton {
        text: "确定"
        enabled: word.text !== ""
        background: Rectangle {
          implicitHeight: 16
          implicitWidth: 120
          color: "grey"
        }
        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("", word.text);
        }
      }
    }
  }
}