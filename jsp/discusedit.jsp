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


%>
<head>
  <title>Discusser</title>
  <script src="js/angular.min.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <style>
  td {
      padding: 5px;
  }
  </style>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope, $http) {

        $scope.discussion = <%discussion.write(out, 2, 2);%>;
        $scope.art = "<%=art%>";
        
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
            $scope.discussion.content = finalObj;
            console.log("conversion complete");
            $scope.convertBack();
        }
        $scope.convertBack = function() {
            var res = "";
            Object.keys($scope.discussion.content).forEach( function(item) {
                res += $scope.discussion.content[item].txt + "\n\n";
            });
            $scope.srctext = res;
        }
        $scope.convertBack();
        
        function saveDocument() {
            var postURL = "discussave.jsp?art="+$scope.art;
            var updateRec = {time:$scope.cmtId, responses:[]};
            var postdata = angular.toJson($scope.discussion);
            console.log("saving new document: ",updateRec);
            $http.post(postURL ,postdata)
            .success( function(data) {
                setComment(data);
                if ("Y"==close) {
                    $modalInstance.close();
                }
            })
            .error( function(data, status, headers, config) {
                reportError(data);
            });
        }
        
    });
  </script>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">

<h1>Edit Discussion Document</h1>

<table>
  <tr>
    <td>Key</td>
    <td><input ng-model="art" class="form-control" disabled="disabled"/></td>
  </tr>
  <tr>
    <td>Full Name</td>
    <td><input ng-model="discussion.fullName" class="form-control"/></td>
  </tr>
  <tr>
    <td>Description</td>
    <td><input ng-model="discussion.description" class="form-control"/></td>
  </tr>
</table>


<div>
<textarea ng-model="srctext" class="form-control" style="width:1200px;height:600px"></textarea>
</div>

<div>
<button ng-click="convert()" class="btn btn-primary">Save</button>
</div>


<hr/>

<pre>{{discussion|json}}</pre>

<div style="height:400px"></div>
<% wr.invokeJSP("tileBottom.jsp"); %>

</div>
</body>
</html>


