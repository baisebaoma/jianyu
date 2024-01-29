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

        // 以下是文本框
        TextField {
            id: word
            placeholderText: "Skillname"
            clip: true
            verticalAlignment: Qt.AlignVCenter
            background: Rectangle {
            implicitHeight: 16
            implicitWidth: 120
            color: "transparent"
            }
        }

        ToolButton {
            text: luatr("OK")
            enabled: word.text !== ""
            onClicked: {
            close();
            roomScene.state = "notactive";
            ClientInstance.replyToServer("", JSON.stringify("jy_bazhen"));  // 先这样
            }
        }
        // 以上是文本框

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
      MetroButton {
        Layout.alignment: Qt.AlignHCenter
        id:  answera
        text:"jy_kaiju"
        textFont.pixelSize: 12
        width: 400
        height:40

        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("", JSON.stringify("jy_kaiju"));
        }
      }

      MetroButton {
        Layout.alignment: Qt.AlignHCenter
        id: answerb
        text: "jy_bazhen"
        textFont.pixelSize: 12

        width: 400
        height: 40

        onClicked: {
          close();
           ClientInstance.replyToServer("", JSON.stringify("jy_bazhen"));
        }
      }
     }
     Row {
       Layout.alignment: Qt.AlignHCenter
        spacing: 20
      MetroButton {
        Layout.alignment: Qt.AlignHCenter
        id:  answerc
        text: "jy_yuyu"
        textFont.pixelSize: 12
        width: 400
        height: 40

        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("", JSON.stringify("jy_yuyu"));
        }
      }

      MetroButton {
        Layout.alignment: Qt.AlignHCenter
        id:  answerd
        text: "jy_huapen"
        textFont.pixelSize: 12
        width: 400
        height: 40

        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("", JSON.stringify("jy_huapen"));
        }
      }

    }


  }
}

