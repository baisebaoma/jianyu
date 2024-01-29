// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk.Pages
import Fk.RoomElement

GraphicsBox {
  id: root

  property int min
  property int max
  property string prompt
  property string question
  property var cancelsign: []

  title.text: Backend.translate("输入你想要的技能的名字（如：paoxiao、jy_lingfu）")
  width: 200
  height: 100

  ColumnLayout {
    anchors.fill: parent
    anchors.topMargin: 40
    anchors.leftMargin: 20
    anchors.rightMargin: 20
    anchors.bottomMargin: 40

    Row  {
      Layout.alignment: Qt.AlignHCenter
      spacing: 40
      Text {
        color: "#E4D5A0"
        text:question
        anchors.fill: parent
        wrapMode: Text.WrapAnywhere
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 20
      }
    }

    Row {
      Layout.alignment: Qt.AlignHCenter
      spacing: 20

      TextField {
        id: word
        placeholderText: "Search..."
        clip: true
        verticalAlignment: Qt.AlignVCenter
        background: Rectangle {
          implicitHeight: 16
          implicitWidth: 120
          color: "transparent"
        }
      }

      ToolButton {
        text: luatr("Search")
        enabled: word.text !== ""
        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("", word.text);
        }
      }
    }
  }
}
