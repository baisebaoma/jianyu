import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fk.RoomElement

Item {
  id: root
  anchors.fill: parent
  property var userInput: ""

  // 新增一个信号，用于在按下按钮时返回文本框内的信息
  // signal submitUserInput(string userInput)

  // 在按钮按下时发出信号，将文本框内的信息传递给槽函数
  // submitUserInput(word.text);

  ToolBar {
    id: bar
    width: parent.width
    RowLayout {
      anchors.fill: parent

      // 只包含一个文本框和一个按钮
      TextField {
        id: word
        placeholderText: "paoxiao"
        clip: true
        verticalAlignment: Qt.AlignVCenter
        background: Rectangle {
          implicitHeight: 16
          implicitWidth: 120
          color: "transparent"
        }
      }

      ToolButton {
        text: luatr("确定")
        enabled: word.text !== ""
        onClicked: {
          close();
          ClientInstance.replyToServer("", word.text);
        }
      }
    }
  }

  // 不再需要 StackView、ListModel、和其他视图相关的代码

  Component.onCompleted: {
    // 移除原先的加载函数
  }
}
