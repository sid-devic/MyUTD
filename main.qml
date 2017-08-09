import QtQuick 2.7;
import QtQuick.Controls 2.1;
import QtQuick.Layouts 1.3;
import QtQuick.Window 2.1;
import QtLocation 5.6;
import QtPositioning 5.5;

ApplicationWindow {
    visible: true
    width: Screen.width
    height: Screen.height
    title: qsTr("MyUTD")

    StackLayout{
        width: parent.width
        height: parent.height
        currentIndex: tabBar.currentIndex

        Page1 {
        }

        Page {
            Label {
                text: qsTr("Second page")
                anchors.centerIn: parent
            }
        }
    }

    footer: TabBar {
        id: tabBar
        TabButton {
            text: qsTr("Current Location")
        }
        TabButton {
            text: qsTr("Updates")
        }
    }
}
