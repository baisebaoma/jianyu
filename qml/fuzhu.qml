// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import Fk.Pages
import Fk.RoomElement

GraphicsBox {
    id: root
    property var cancelsign: []

    title.text: "你好"
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
        }
    }
}
