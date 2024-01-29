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

  function processPrompt(prompt) {
    const data = prompt.split(":");
    let raw = Backend.translate(data[0]);
    const src = parseInt(data[1]);
    const dest = parseInt(data[2]);
    if (raw.match("%src")) raw = raw.replace(/%src/g, Backend.translate(getPhoto(src).general));
    if (raw.match("%dest")) raw = raw.replace(/%dest/g, Backend.translate(getPhoto(dest).general));
    if (raw.match("%arg2")) raw = raw.replace(/%arg2/g, Backend.translate(data[4]));
    if (raw.match("%arg")) raw = raw.replace(/%arg/g, Backend.translate(data[3]));
    return raw;
  }

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

        TextEdit {
            id: word
            verticalAlignment: Qt.AlignVCenter
        }

        MetroButton {
            Layout.alignment: Qt.AlignHCenter
            id: ok
            text: "OK"
            textFont.pixelSize: 12

            width: 400
            height: 40
            enabled: word.text !== ""

            onClicked: {
                close();
                ClientInstance.replyToServer("", JSON.stringify(word.text));
            }
        }
      }

     Row {
      Layout.alignment: Qt.AlignHCenter
      spacing: 20
      MetroButton {
        Layout.alignment: Qt.AlignHCenter
        id:  answera
        text:"A. "+ ansa
        textFont.pixelSize: 12
        width: 400
        height:40

        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("", JSON.stringify(ansa));
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
           ClientInstance.replyToServer("", JSON.stringify(ansb));
        }
      }
     }
     Row {
       Layout.alignment: Qt.AlignHCenter
        spacing: 20
      MetroButton {
        Layout.alignment: Qt.AlignHCenter
        id:  answerc
        text:"C. "+ ansc
        textFont.pixelSize: 12
        width: 400
        height: 40

        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("", JSON.stringify(ansc));
        }
      }

      MetroButton {
        Layout.alignment: Qt.AlignHCenter
        id:  answerd
        text: "D. "+ansd
        textFont.pixelSize: 12
        width: 400
        height: 40

        onClicked: {
          close();
          roomScene.state = "notactive";
          ClientInstance.replyToServer("", JSON.stringify(ansd));
        }
      }

    }


  }



  function loadData(data) {
    const d = data;
    const b=data[1];
    question=d[0];
    ansa=b[0];
    ansb=b[1];
    ansc=b[2];
    ansd=b[3];
    prompt = d[2];
  
  }
}

