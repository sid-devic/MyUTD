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
            height: Screen.height / 4.5
            color: "transparent"
            Rectangle {
                id: delegate
                z: 1
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

    // dStr.replace("+0000 ", "") + " GMT"
    function makeDateBetter(index){
        var tdate = tweets.get(index).date
        // have to change some stuff to make acceptable JS Date object
        var better_date = new Date(Date.parse(tdate.replace("+0000 ", "") + " GMT"));

        // user date
        var user_date = new Date();

        // difference between tweet date and current time
        var diff = Math.floor((user_date - better_date) / 1000);

        // all the cases for different times
        if (diff <= 1) {tweets.get(index).date = "just now";}
        if (diff < 20) {tweets.get(index).date = diff + " seconds ago";}
        if (diff < 40) {tweets.get(index).date = "half a minute ago";}
        if (diff < 60) {tweets.get(index).date = "less than a minute ago";}
        if (diff <= 90) {tweets.get(index).date = "one minute ago";}
        if (diff <= 3540) {tweets.get(index).date = Math.round(diff / 60) + " minutes ago";}
        if (diff <= 5400) {tweets.get(index).date = "1 hour ago";}
        if (diff <= 86400) {tweets.get(index).date = Math.round(diff / 3600) + " hours ago";}
        if (diff <= 129600) {tweets.get(index).date = "1 day ago";}
        if (diff < 604800) {tweets.get(index).date = Math.round(diff / 86400) + " days ago";}
        if (diff <= 777600) {tweets.get(index).date = "1 week ago";}

        // more than a week old, we display the day and month number form
        // E.G. 6/25
        else{tweets.get(index).date = better_date.getMonth() + "/" + better_date.getDate()}

    }
}
