import QtQuick 2.7;
import QtQuick.Controls 2.1;
import QtQuick.Layouts 1.3;
import QtQuick.Window 2.1;
import QtLocation 5.6;
import QtPositioning 5.5;
import QtQuick.Dialogs 1.1;

Page {
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
        z: 1
        width: parent.width
        height: parent.height - header.height
        model: tweets
        // we have a container to hold all the parts of each tweet, including margins
        delegate: Rectangle {
            id: delegateContainer
            width: parent.width
            height: Screen.height / 5.5
            color: "transparent"
            Rectangle {
                id: delegate
                z: 1
                anchors.top: parent.top
                width: parent.width
                height: parent.height / 1.8
                radius: 10
                border.width: 2
                border.color: "#1dcaff"
                color: "white"
                Text{
                    id: messageText
                    anchors.fill: parent
                    text: message
                    color: "black"
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    Component.onCompleted: {
        getTweetsAndPost();
    }

    function getTweetsAndPost() {
        // http request for the website data
        // based on method from CabTracker.qml
        var xmlhttp = new XMLHttpRequest();
        var url = "http://MyUTD.tk/cometCabTwitter.json";

        xmlhttp.onreadystatechange=function() {
            if (xmlhttp.readyState === XMLHttpRequest.DONE && xmlhttp.status == 200) {
                parseTweets(xmlhttp.responseText);
            }
        }
        xmlhttp.open("GET", url, true);
        xmlhttp.send();
    }

    function parseTweets(tweetsJSON) {
        // JSON parsing
        var arr = JSON.parse(tweetsJSON);

        for(var i = 0; i < 10; i++)
        {
            tweets.get(i).date = arr[i].created_at;
            tweets.get(i).message = arr[i].text;
            makeDateBetter(i);
        }
    }

    function makeDateBetter(index){
        var date = tweets.get(index).date
        tweets.get(index).date = date.replace("+0000", "");
    }
}
