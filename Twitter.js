WorkerScript.onMessage = function (message) {
    // http request for the website data
    // based on method from CabTracker.qml
    var xmlhttp = new XMLHttpRequest();
    var url = "http://MyUTD.tk/cometCabTwitter.json";
    var jsonRaw;
    xmlhttp.onreadystatechange=function() {
        if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
            jsonRaw = xmlhttp.responseText;
        }
    }
    xmlhttp.open("GET", url, true);
    xmlhttp.send();
    console.log(jsonRaw);
    var tweet = parseTweets(json, 0)
    WorkerScript.sendMessage(tweet.toString());
}

function parseTweets(tweetsJSON, index) {
    // JSON parsing
    var arr = JSON.parse(tweetsJSON);

    //tweets.get(i).date = arr[i].created_at.toString();
    //console.log(arr[i].created_at.toString());

    // remove anything after http://, links useless on mobile (can't set reference to website without text object)
    // might change later
    console.log(arr[index].text);
    return arr[index].text.toString().replace(/(?:https?|ftp):\/\/[\n\S]+/g, '');

    //console.log(messageStrings[i]);
    //makeDateBetter(i);

}

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
