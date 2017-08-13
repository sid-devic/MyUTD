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
        // 5 cabs, the sixth element is position of the user (so we don't need another QML object)
        id: cabDataList
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "black"
            lastLatitude: 0
            lastLongitude: 0
        }
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "red"
            lastLatitude: 0
            lastLongitude: 0
        }
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "blue"
            lastLatitude: 0
            lastLongitude: 0
        }
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "green"
            lastLatitude: 0
            lastLongitude: 0
        }
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "darkred"
            lastLatitude: 0
            lastLongitude: 0
        }
        ListElement{
            name: "s"
            latitude: 0
            longitude: 0
            color: "fuchsia"
            lastLatitude: 0
            lastLongitude: 0
        }
        ListElement{
            name: "User Position"
            latitude: -2.5
            longitude: -2.5
            color: "slategray"
        }
    }

    Plugin {
        id: esriPlugin
        name: "esri"
        // set min/max zoom levels, this is why we're using esri and not osm
        PluginParameter{
            name: "esri.mapping.minimumZoomLevel"
            value: 15
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
            latitude: 32.986148492300856;
            longitude: -96.75047601796122;
        }
        copyrightsVisible: false
        zoomLevel: 15
        activeMapType: supportedMapTypes[0]
        z: 0
        Component.onCompleted: {
            // start out main timer, draws all cabs and updates cabDataList
            updateAllDataTimer.running = true;

            // display message to user that location not working
            checkUserPosition();

            // start our timer that handles map repositioning if the user leaves the
            // displayed UTD map
            stayOnCabMap.running = true;
        }

        // these two coordinates are what we constantly track to keep the user within the bounds of
        // the displayed UTD map. We need to wait until the Flickable animatino stops before changing
        // the map.center, and the only way to know if the animation has stopped (because it is included
        // natively in the Map QML type), is to keep track of the current map.center and see if it matches
        // the last one. If both are equal, the animation has ended and we can reposition the map.
        Location{
            id: lastMapCenter
            coordinate: {
                latitude: 0
                longitude: 0
            }
        }

        Location{
            id: currentMapCenter
            coordinate:{
                latitude: 0
                longitude: 0
            }
        }
        // <--------------------------------Dialogs for various events-------------------------------->
        MessageDialog {
            id: aboutDialog
            visible: false
            title: "About"
            text: "Version: 1.1"
            informativeText: "Please report any bugs on the appstore!"
            standardButtons: StandardButton.Ok
            onAccepted: {
                aboutDialog.visible = false;
            }
        }
        MessageDialog {
            id: positionMissing
            visible: false
            title: "Location Services Disabled"
            text: "You will not be able to see your position on the map."
            informativeText: "You can enable location services in your device settings."
            onAccepted: {
                positionMissing.visible = false;
            }
        }
        MessageDialog {
            id: offCampus
            visible: false
            title: "Where are you?"
            text: "You're not on campus!"
            onAccepted: {
                offCampus.visible = false;
            }
        }
        // <!-----------------------------------------------------------------------------------------!>

        ColumnLayout{
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 4
            z:20

            // recenter map on user. If they're off campus, recenter on comet cab. If GPS not enabled, nothing happens,
            // as the user has been notified at the start of the application that they're position cannot
            // be displayed
            Button {
                id: findMe;
                highlighted: true
                anchors.right: parent.right
                text: "Find Me"
                onPressed: {
                    recenterMapOnUser();
                }
            }
            // recenter map on cab
            Button {
                highlighted: true
                anchors.right: parent.right
                text: "Find Cab"
                onPressed: {
                    centerMapOnCab();
                }
            }
        }

        // Button for displaying dialog containing information on the current build
        Button {
            id: about;
            highlighted: true
            anchors.right: parent.right
            anchors.bottom: map.bottom
            text: "About"
            z: 20
            onPressed: {
                aboutDialog.visible = true;
            }
        }

        // grab position of user and put to cabDataList[6]
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
    // refreshes our list of cab data (cabDataList) and draws new markers for the new data
    Timer{
        id: updateAllDataTimer
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered:
        {
            updateCabData();
            createMarkers();
        }
    }

    // make sure the user can't leave the UTD area on the map
    Timer{
        id: stayOnCabMap
        interval: 100
        running: false
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            // debugging for map repositioning
            /*
            console.log("current: " + lastMapCenter.coordinate.latitude + " " + lastMapCenter.coordinate.longitude)
            console.log("last: " + currentMapCenter.coordinate.latitude + " " + currentMapCenter.coordinate.longitude)
            */
            keepUserWithinBounds();
        }
    }

    function updateCabData() {
        // http request for the website data
        // based on method from CabTracker.qml
        var xmlhttp = new XMLHttpRequest();
        var url = "http://MyUTD.tk/location.json";

        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState === XMLHttpRequest.DONE && xmlhttp.status == 200) {
                returnCoords(xmlhttp.responseText);
            }
        }
        xmlhttp.open("GET", url, true);
        xmlhttp.send();
    }

    function returnCoords(cabData) {
        // JSON parsing
        var arr = JSON.parse(cabData);
        var devicesList = arr.devices;

        for(var i = 0; i < 6; i++)
        {
            if(cabDataList.get(i).name == "s"){
                cabDataList.get(i).name = devicesList[i].device.toString();
            }
            cabDataList.get(i).lastLatitude = cabDataList.get(i).latitude;
            cabDataList.get(i).lastLongitude = cabDataList.get(i).longitude;
            cabDataList.get(i).latitude = parseFloat(devicesList[i].lat);
            cabDataList.get(i).longitude = parseFloat(devicesList[i].lng);
        }
    }

    function createMarkers()
    {
        // actual drawing of items on the map. We have to redraw anytime position is changed
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
            // testing for directional marker
            /*
            if(i != 6)
            {
                var lastMarker = Qt.createQmlObject('import QtQuick 2.7;
                                                     import QtQuick.Controls 2.0;
                                                     import QtQuick.Layouts 1.3;
                                                     import QtQuick.Window 2.1;
                                                     import QtLocation 5.6;
                                                     import QtPositioning 5.5;
                                                     MapQuickItem {
                                                     id: zeroLastPosition;
                                                     sourceItem: Rectangle { width: parent.width<parent.height?parent.width:parent.height height: width color: "red" border.color: "black" border.width: 1 radius: width*0.5 }
                                                     coordinate {latitude: cabDataList.get(' + i + ').lastLatitude; longitude: cabDataList.get(' + i + ').lastLongitude } opacity:1.0; anchorPoint: Qt.point(sourceItem.width/2, sourceItem.height/2)}
                                                     ', map)
            }
            map.addMapItem(lastMarker);
            */
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
        // IMPROVE LATER
        // check if the cabDataList(6), which is the user position, is still default value.
        // if it is, we say we don't have location services. Only triggered on start
        if(user.sourceError != 3)
        {
            positionMissing.visible = true;
        }
    }

    function keepUserWithinBounds(){
        // function to keep the map within the bounds of UTD

        // sets last coordinate and current coordinate. We check if the flickable animation of the map
        // has ended, otherwise we don't run our map.center change to bound the user within the map of UTD
        lastMapCenter.coordinate.latitude = currentMapCenter.coordinate.latitude;
        lastMapCenter.coordinate.longitude = currentMapCenter.coordinate.longitude;
        currentMapCenter.coordinate.longitude = map.center.longitude;
        currentMapCenter.coordinate.latitude = map.center.latitude;

        if(map.center.latitude > 32.993859 && lastMapCenter.coordinate == currentMapCenter.coordinate)
            map.center.latitude = 32.993859;
        if(map.center.longitude < -96.757075 && lastMapCenter.coordinate == currentMapCenter.coordinate)
            map.center.longitude = -96.757075;
        if(map.center.latitude < 32.980338 && lastMapCenter.coordinate == currentMapCenter.coordinate)
            map.center.latitude = 32.980338
        if(map.center.longitude > -96.742024 && lastMapCenter.coordinate == currentMapCenter.coordinate)
            map.center.longitude = -96.742024
    }

    function centerMapOnCab(){
        //center map on cab, default is cab 5 (commons)
        map.center.latitude = cabDataList.get(5).latitude;
        map.center.longitude = cabDataList.get(5).longitude;
        map.zoomLevel = 16;
    }

    function centerMapOnUser(){
        //center map on user
        map.center.latitude = cabDataList.get(6).latitude;
        map.center.longitude = cabDataList.get(6).longitude;
        map.zoomLevel = 16;
    }

    function recenterMapOnUser(){
        // checks if user is outside our bounded UTD map
        if(user.valid == true){
            if(cabDataList.get(6).latitude > 32.993859 || cabDataList.get(6).longitude < -96.757075
                    || cabDataList.get(6).latitude < 32.980338 || map.center.longitude > -96.742024){
                offCampus.visible = true;
                centerMapOnCab();
            }
            else{
                centerMapOnUser();
            }
        }
        else{
            console.log("Positioning services unavailible");
            positionMissing.visible = true;
        }
    }
}
