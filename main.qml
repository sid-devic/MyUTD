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

    // useless here...
    /*
    Drawer{
        width: window.width * .45
        height: window.height - header.height
    }
    */

    StackLayout{
        width: parent.width
        height: parent.height
        //currentIndex: tabBar.currentIndex

        CometCabContainer {
        }

    }

    // TODO:
    // 1. Check if bug was with UBS port
    // 2. Change about button to link to play store
    // 3. Setting to display "Not In Service" Cabs
    // 4. Finish up twitter display

}
