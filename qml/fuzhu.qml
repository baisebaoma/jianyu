// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import Fk.Pages
import Fk.RoomElement

GraphicsBox {
  id: root

  property int min
  property int max
  property string prompt
  property string question
  property string ansa
  property string ansb
  property string ansc
  property string ansd
  property var cancelsign: []

  title.text: Backend.translate(prompt !== "" ? processPrompt(prompt) : "$Choice")
  width: 200 + 8 * 88
  height: 300

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
          text: "你好"
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
        placeholderText: "技能名，如：paoxiao"
        clip: true
        verticalAlignment: Qt.AlignVCenter
        background: Rectangle {
          implicitHeight: 16
          implicitWidth: 120
          color: "transparent"
        }
      }

      MetroButton {
        Layout.alignment: Qt.AlignHCenter
        id: answerb
        text: "B. "+ansb
        textFont.pixelSize: 12

        width: 400
        height: 40

        onClicked: {
          close();
           ClientInstance.replyToServer("", JSON.stringify(word.text));
        }
      }
     }
  }
}

