<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.File"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.List"
%><%@page import="java.util.ArrayList"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");
    String art = wr.reqParam("art");
    
    File dataFolder = new File("d:/cogData/discus/");
    if (!dataFolder.exists()) {
        throw new Exception("Can't find the folder: "+dataFolder.getAbsolutePath());
    }
    
    File discussionFile = new File(dataFolder, art+".disc");
    if (!discussionFile.exists()) {
        throw new Exception("Can't find the file: "+discussionFile.getAbsolutePath());
    }
    
    JSONObject discussion = JSONObject.readFromFile(discussionFile);
    List<String> commenters = new ArrayList<String>();
    for( File child : dataFolder.listFiles()) {
        String childName = child.getName();
        if (!childName.startsWith(art)) {
            continue;
        }
        if (childName.endsWith(".comm")) {
            String combo = childName.substring(0, childName.length()-5);
            int dotPos = combo.lastIndexOf(".");
            String topic = combo.substring(0, dotPos);
            String user = combo.substring(dotPos+1);
            commenters.add(user);
        }
    }
    
    JSONObject allComments = new JSONObject();
    for (String user : commenters) {
        File commentFile = new File(dataFolder, art + "." + user + ".comm");
        if (commentFile.exists()) {
            JSONObject ucomm = JSONObject.readFromFile(commentFile);
            allComments.put(user, ucomm);
        }
    }
    

%>
<head>
  <title>Discusser</title>
  <script src="js/angular.min.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <style>
  .fixColumn {
      width:350px;
      border: 1px solid #AA00FF;
  }
  .fixColumnUser {
      width:350px;
      background-color: white;
      border: 1px solid #AA00FF;
  }
  </style>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {

        
        $scope.discussion = <%discussion.write(out, 2, 2);%>;
        $scope.allComments = <%allComments.write(out, 2, 2);%>;
        
        $scope.commenters = Object.keys($scope.allComments);

        $scope.convert = function() {
            console.log("conversion started");
            $scope.restext = [];
            var firstList = $scope.srctext.split("\n");
            var runner = "";
            var secondList = [];
            firstList.forEach( function(item) {
                item = item.trim();
                if (item.length==0) {
                    runner = runner.trim();
                    if (runner.length>0) {
                        secondList.push(runner);
                    }
                    runner = "";
                }
                else {
                    runner += item + " ";
                }
            });
            if (runner.length>0) {
                secondList.push(runner);
            }
            var thirdList = [];
            secondList.forEach( function(item) {
                item = item.trim();
                if (item.length==0) {
                    //do nothing
                }
                else if (item.length<80) {
                    thirdList.push(item);
                }
                else {
                    var dotPos = item.indexOf(".");
                    while(dotPos>0) {
                        thirdList.push(item.substring(0,dotPos+1).trim());
                        item = item.substring(dotPos+1).trim();
                        dotPos = item.indexOf(".");
                    }
                    if (item.length>0) {
                        thirdList.push(item.trim());
                    }
                }
            });
            var count = 0;
            var finalObj = {};
            thirdList.forEach( function(item) {
                finalObj[count++] = {txt: item};
            });
            $scope.restext = finalObj;
            console.log("conversion complete");
        }
        
        $scope.convertBack = function() {
            var res = "";
            Object.keys($scope.restext).forEach( function(item) {
                res += $scope.restext[item].txt + "\n\n";
            });
            $scope.srctext = res;
        }
    });
  </script>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">

<h1>Discussion</h1>

<div>
<button ng-click="convert()" class="btn btn-primary">Convert</button>
<button ng-click="convertBack()" class="btn btn-primary">Convert Back</button>
</div>


<table class="table" style="width:1600px">
<tr>
  <th>#</th>
  <th class="fixColumn">Original</th>
  <th class="fixColumn">Comment</th>
  <th class="fixColumn" ng-repeat="user in commenters">{{user}}</th>
</tr>
<tr ng-repeat="(row,obj) in discussion.content track by row">
  <td style="width:30px">{{row}}</td>
  <td class="fixColumn">{{obj.txt}}</td>
  <td class="fixColumnUser" 
      ng-dblclick="userComment[row] = obj">
      {{userComment[row].txt}}</td>
  <td class="fixColumn"  ng-repeat="user in commenters"
      ng-dblclick="allComments[user][row] = obj">
      {{allComments[user][row].txt}}</td>
</tr>
</table>

<hr/>

<pre>{{restext|json}}</pre>

<div style="height:400px"></div>
<% wr.invokeJSP("tileBottom.jsp"); %>

</div>
</body>
</html>


