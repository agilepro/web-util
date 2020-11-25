<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

%>
<head>
  <title>Discusser</title>
  <script src="js/angular.min.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>

  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.srctext = "";
        
        $scope.restext = {};
        
        $scope.userComment = {};
        $scope.userComment2 = {};
        $scope.userComment3 = {};

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
                    var dotPos = findBreak(item);
                    while(dotPos>0) {
                        thirdList.push(item.substring(0,dotPos+1).trim());
                        item = item.substring(dotPos+1).trim();
                        dotPos = findBreak(item);
                    }
                    if (item.length>0) {
                        thirdList.push(item.trim());
                    }
                }
            });
            var count = 0;
            var finalObj = "";
            thirdList.forEach( function(item) {
                finalObj += item.trim() + "\n\n";
            });
            $scope.restext = finalObj;
            console.log("conversion complete");
        }
        
        
        $scope.convert();
    });
    
    function findBreak(str) {
        if (str.length<80) {
            return -1;
        }
        var dotPos = str.indexOf(".", 10);
        var semiPos = str.indexOf(";", 10);
        var quesPos = str.indexOf("?", 10);
        var res = 99999;
        if (dotPos>0 && dotPos<res) {
            res = dotPos;
        }
        if (semiPos>0 && semiPos<res) {
            res = semiPos;
        }
        if (quesPos>0 && quesPos<res) {
            res = quesPos;
        }
        return res;
    }
  </script>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">

<h1>Sentence Parser</h1>

<p>Attempts to break a block of text up into individual sentences</p>

<div>
<textarea ng-model="srctext" class="form-control" style="width:1200px;height:600px"></textarea>
</div>

<div>
<button ng-click="convert()" class="btn btn-primary">Break into sentences</button>
</div>

<h1>Output</h1>

<div>
<textarea ng-model="restext" class="form-control" style="width:1200px;height:600px"></textarea>
</div>


<div style="height:400px"></div>
<% wr.invokeJSP("tileBottom.jsp"); %>

</div>
</body>
</html>


