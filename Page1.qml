import QtQuick 2.7;
import QtQuick.Controls 2.1;
import QtQuick.Layouts 1.3;
import QtQuick.Window 2.1;
import QtLocation 5.6;
import QtPositioning 5.5;
import QtQuick.Dialogs 1.1;

Page {
    anchors.fill: parent
    header: Label {
        padding: 10
        text: qsTr("Comet Cab")
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter
    }
    property variant errorHasBeenDisplayed: false


    ListModel{
        // 5 cabs, the sixth index is actually position of the user
        id: cabDataList
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "black"
        }
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "red"
        }
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "blue"
        }
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "green"
        }
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "darkred"
        }
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "fuchsia"
        }
        ListElement{
            name: "User Position"
            latitude: 0
            longitude: 0
            color: "slategray"
        }
    }

    Plugin {
        id: esriPlugin
        name: "esri"
        // set min/max zoom levels, this is why we're using esri and not osm
        PluginParameter{
            name: "esri.mapping.minimumZoomLevel"
            value: 16
        }
        PluginParameter{
            name: "esri.mapping.maximumZoomLevel"
            value: 18
        }
    }

    Map {
        id: map
        plugin: esriPlugin
        anchors.fill: parent
        center {
            // utd center
            latitude: 32.988889
            longitude: -96.748801
        }
        copyrightsVisible: false
        zoomLevel: 17
        activeMapType: supportedMapTypes[0]
        z: 0
        Component.onCompleted: {
            updateAllDataTimer.start;
            map.center.latitude = cabDataList.get(6).latitude;
            map.center.longitude = cabDataList.get(6).longitude;
        }
        MessageDialog {
            id: messageDialog
            visible: false
            title: "Cache Map Data?"
            text: "Caching uses a more data than usual, if you wish to preserve data switch to WiFi."
            informativeText: "Continue with caching?"
            standardButtons: StandardButton.Yes | StandardButton.No
            onYes: {
                console.log("And of course you could only agree.")
                Qt.quit()
            }
            onNo:{
                messageDialog.visible = false;
            }
        }
        ColumnLayout{
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 4
            z:20

            Button {
                highlighted: true
                anchors.right: parent.right
                text: "Find Me"
                onPressed: {
                    map.center.latitude = cabDataList.get(6).latitude;
                    map.center.longitude = cabDataList.get(6).longitude;
                }
            }
            Button {
                highlighted: true
                anchors.right: parent.right
                text: "Find Cab"
                onPressed: {
                    map.center.latitude = cabDataList.get(5).latitude;
                    map.center.longitude = cabDataList.get(5).longitude;
                }
            }
        }

        Button {
            highlighted: true
            anchors.right: parent.right
            anchors.bottom: map.bottom
            text: "Cache Map Data"
            onPressed: {
                messageDialog.visible = true;
            }
        }

        PositionSource {
            id: user
            updateInterval: 2000
            active: true
            onPositionChanged: {
                cabDataList.get(6).latitude = user.position.coordinate.latitude;
                cabDataList.get(6).longitude = user.position.coordinate.longitude;
            }
        }
    }

// new embedPlot.aspx delivered every ~5-6 sec

    Timer{
        id: updateAllDataTimer
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered:
        {
            console.log("triggered");
            updateCabData();
            createMarkers();            
        }
    }
    function updateCabData() {

        var xmlhttp = new XMLHttpRequest();
        var url = "http://159.203.183.245/index.html";

        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status == 200) {
                returnCoords(xmlhttp.responseText);
            }
        }

        xmlhttp.open("GET", url, true);
        xmlhttp.send();
    }

    function returnCoords(cabData) {
        var arr = JSON.parse(cabData);
        var devicesList = arr.devices;

        for(var i = 0; i < 6; i++)
        {
            cabDataList.get(i).name = devicesList[i].device.toString();
            cabDataList.get(i).latitude = parseFloat(devicesList[i].lat);
            cabDataList.get(i).longitude = parseFloat(devicesList[i].lng);
        }
    }

    function createMarkers()
    {
        map.clearMapItems();

        for(var i = 0; i < 7; i++)
        {
            var color = cabDataList.get(i).color;
            var marker = Qt.createQmlObject('import QtQuick 2.7;
                                                 import QtQuick.Controls 2.0;
                                                 import QtQuick.Layouts 1.3;
                                                 import QtQuick.Window 2.1;
                                                 import QtLocation 5.6;
                                                 import QtPositioning 5.5;
                                                 MapQuickItem {
                                                 id: zeroMarker;
                                                 sourceItem: Rectangle { width: 10; height: 10; color: ' + "\"" + color + "\"" + '; smooth: true; radius: 5 }
                                                 coordinate {latitude: cabDataList.get(' + i + ').latitude; longitude: cabDataList.get(' + i + ').longitude } opacity:1.0; anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)}
                                                 ', map, "dynamicSnippet" + i)
            var text = Qt.createQmlObject('import QtQuick 2.7;
                                                  import QtQuick.Controls 2.0;
                                                  import QtQuick.Layouts 1.3;
                                                  import QtQuick.Window 2.1;
                                                  import QtLocation 5.6;
                                                  import QtPositioning 5.5;
                                                  MapQuickItem {
                                                  id: zeroText;
                                                  sourceItem: Text { text: cabDataList.get(' + i + ').name; font.family: "Helvetica"; font.pointSize: 10; color: ' + "\"" + color + "\"" + '}
                                                  coordinate {latitude: cabDataList.get(' + i + ').latitude; longitude: cabDataList.get(' + i + ').longitude } opacity:1.0; anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height + 4)}
                                                  ', map, "dynamicSnippet1")
            map.addMapItem(marker);
            map.addMapItem(text);
        }
    }

    function delay(duration) { // In milliseconds
        var timeStart = new Date().getTime();

        while (new Date().getTime() - timeStart < duration) {
            // Do nothing
        }
        // Duration has passed
    }

    function checkUserPosition(){
        if(user.sourceError == 2 && !errorHasBeenDisplayed)
        {

        }
    }
}
