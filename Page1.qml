import QtQuick 2.7;
import QtQuick.Controls 2.1;
import QtQuick.Layouts 1.3;
import QtQuick.Window 2.1;
import QtLocation 5.6;
import QtPositioning 5.5;
Page {
    anchors.fill: parent
    header: Label {
        padding: 10
        text: qsTr("Find a cab")
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    ListModel{
        id: cabDataList
        // default name "s" for debug
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
    }

    Plugin {
        id: esriPlugin
        name: "esri"
        // set min/max zoom levels
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
            latitude: 32.988889
            longitude: -96.748801
        }
        copyrightsVisible: false
        zoomLevel: 17
        activeMapType: supportedMapTypes[0]
        z: 0
    }

    Timer{
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered:
        {
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

            for(var i = 0; i < 6; i++)
            {
                //can't do case insensitive string comparison inline (...easily)
                if(cabDataList.get(i).name != "Not in Service"){
                    if(cabDataList.get(i).name != "Not In Service"){
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
            }
        }
}
