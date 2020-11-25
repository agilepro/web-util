<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.File"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.util.List"
%><%@page import="java.util.ArrayList"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    File dataFolder = new File("d:/cogData/discus/");
    if (!dataFolder.exists()) {
        throw new Exception("Can't find the folder: "+dataFolder.getAbsolutePath());
    }
    
    JSONObject discussionList = new JSONObject();
    
    for( File child : dataFolder.listFiles()) {
        String childName = child.getName();
        if (childName.endsWith(".disc")) {
            String topic = childName.substring(0, childName.length()-5);
            JSONObject discussion = discussionList.requireJSONObject(topic);
            JSONArray comments = discussion.requireJSONArray("comments");
        }
        else if (childName.endsWith(".comm")) {
            String combo = childName.substring(0, childName.length()-5);
            int dotPos = combo.lastIndexOf(".");
            String topic = combo.substring(0, dotPos);
            String user = combo.substring(dotPos+1);
            JSONObject discussion = discussionList.requireJSONObject(topic);
            JSONArray comments = discussion.requireJSONArray("comments");
            comments.put(user);
        }
    }
    
    
    
%>
<head>
  <title>Discusser</title>
  <script src="js/angular.min.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.discList = <%discussionList.write(out, 2, 2);%>;
        
        $scope.viewDiscus = function(art) {
            var url = "discusart.jsp?art="+art;
            window.location.assign(url);
        }
        $scope.editDiscus = function(art) {
            var url = "discusedit.jsp?art="+art;
            window.location.assign(url);
        }
    });
  </script>
  <style>
  button {
      font-size:60%;
  }
  </style>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">

<h1>Discussions</h1>

<ol>
  <li ng-repeat="(key, obj) in discList">
    <a href="discusart.jsp?art={{key}}">{{key}}</a>
    <button ng-click="viewDiscus(key)">View</button>
    <button ng-click="editDiscus(key)">Edit</button>
    <ol>
      <li ng-repeat="user in obj.comments">
        {{user}}
      </li>
    </ol>
  </li>
</ol>

<div>
<button ng-click="showCreatePanel=!showCreatePanel">Create New</button>
</div>

<div ng-show="showCreatePanel" class="well">
New Name: <input type="text" ng-model="newName" class="form-element"/>
<button ng-click="createNew()">Create It</button>
</div>
    
<div style="height:400px"></div>
<% wr.invokeJSP("tileBottom.jsp"); %>

</div>
</body>
</html>


