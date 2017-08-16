import QtQuick 2.7;
import QtQuick.Controls 2.1;
import QtQuick.Layouts 1.3;
import QtQuick.Window 2.1;
import QtLocation 5.6;
import QtPositioning 5.5;
import QtQuick.Dialogs 1.1;

// we have to have this container for the CabTracker and TwitterPage
// pages so that we can have a tab view inside the same tab of the planned drawer.

Page {
    StackLayout{
        width: parent.width
        height: parent.height
        currentIndex: tabBar.currentIndex

        CabTracker {
        }

        TwitterPage {
        }

        Component.onCompleted: {
            tabBar.visible = true;
        }
  }

    footer: TabBar {
        id: tabBar
        visible: false
        TabButton {
            text: qsTr("Location")
        }
        TabButton {
            text: qsTr("Updates")
        }
    }
}
