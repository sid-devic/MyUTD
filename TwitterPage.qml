import QtQuick 2.7;
import QtQuick.Controls 2.1;
import QtQuick.Layouts 1.3;
import QtQuick.Window 2.1;
import QtQuick.Dialogs 1.1;

Page {
    property string rawJSON: "";
    property variant messageStrings: ["", "", "", "","","", "", "", "",""]

    anchors.fill: parent
    header: Rectangle {
        id: header
        height: 40
        color: "#303030"
        Text{
            text: qsTr("@UTDCometCab Twitter")
            topPadding: 10
            bottomPadding: 10
            leftPadding: 5
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: 20
            visible: true
            color: "white"
            horizontalAlignment: Text.AlignHLeft
        }

        // so header is always on top
        z: 2
    }

    ListModel{
        id: tweets
        ListElement{
            date: "";
            message: "";
        }
        ListElement{
            date: "";
            message: "";
        }
        ListElement{
            date: "";
            message: "";
        }
        ListElement{
            date: "";
            message: "";
        }
        ListElement{
            date: "";
            message: "";
        }
        ListElement{
            date: "";
            message: "";
        }
        ListElement{
            date: "";
            message: "";
        }
        ListElement{
            date: "";
            message: "";
        }
        ListElement{
            date: "";
            message: "";
        }
        ListElement{
            date: "";
            message: "";
        }
    }

    ListView{
        id: tweetListView
        z: 1
        width: parent.width
        height: parent.height - header.height
        model: tweets
        visible: false;
        // we have a container to hold all the parts of each tweet, including margins
        delegate: Rectangle {
            id: delegateContainer
            width: parent.width
            height: Screen.height / 4.5
            color: "transparent"
            Rectangle {
                id: delegate
                anchors.top: parent.top
                width: parent.width
                height: parent.height * .75
                radius: 10
                border.width: 2
                border.color: "#1dcaff"
                color: "white"
                Text{
                    id: dateTextObject
                    anchors.top: parent.top
                    topPadding: 5
                    rightPadding: 5
                    anchors.right: parent.right
                    text: date
                    color: "#c0deed"
                    wrapMode: Text.Wrap
                }
                Text{
                    id: messageTextObject
                    anchors.top: dateTextObject.bottom
                    text: message
                    color: "black"
                    wrapMode: Text.Wrap
                    width: parent.width
                    height: parent.height - dateTextObject.height
                }
            }
        }
    }

    Component.onCompleted: {
        getTweetJSON();
        //myWorker.sendMessage();
        tweets.get(0).message = rawJSON;
        tweetListView.visible = true;
    }

    WorkerScript {
        id: myWorker
        source: "Twitter.js"
        onMessage: rawJSON = messageObject.reply;
    }

    function getTweetJSON() {
        // http request for the website data
        // based on method from CabTracker.qml
        var xmlhttp = new XMLHttpRequest();
        var url = "http://MyUTD.tk/cometCabTwitter.json";

        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                rawJSON = xmlhttp.responseText;
            }
        }
        xmlhttp.open("GET", url, true);
        xmlhttp.send();
    }
}
