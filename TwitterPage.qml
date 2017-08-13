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
        id: header
        padding: 10
        fill: true
        text: qsTr("@UTDCometCab Twitter")
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHLeft
        verticalAlignment: Text.AlignVCenter
        z: 2
        visible: false
    }
    Rectangle{
        anchors.top: parent.top
        height: Screen.height / 13
        width: Screen.width
        color: Material.Dark
        z:1
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
        width: parent.width
        height: parent.height - header.height
        model: tweets
        z: 0
        delegate: Rectangle{
            height: Screen.height / 6.5
            Text{
                id: above
                height: parent.height / 2
                anchors.top: parent.top
                text: date;
                color: "white"
                wrapMode: Text.Wrap
                z: 0
            }
            Text{
                height: parent.height / 2
                anchors.top: above.bottom
                text: message;
                color: "white"
                wrapMode: Text.Wrap
                z: 0
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
        }
    }
}
