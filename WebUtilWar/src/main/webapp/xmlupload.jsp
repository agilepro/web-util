<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%

    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    String f = wr.defParam("f", "");

%>
<html>
<head>
  <title>File Upload</title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope, $http) {
        window.MY_SCOPE = $scope;
        $scope.fileProgress = [];
        $scope.reportError = function(serverErr) {
            console.log("ERROR", serverErr);
        };
        $scope.goMode = function(page, fileName) {
            window.location.assign(page+"?f="+encodeURIComponent(fileName));
        }
        $scope.cancelUpload = function(oneProgress) {
            oneProgress.done = true;
            oneProgress.status = "Cancelled";
        }
        $scope.startUpload = function(oneProgress) {
            let reader = new FileReader();
            let fileContent = "";
            reader.onload = function(e) {
                var contents = e.target.result;
                $scope.saveContents(oneProgress, contents);
            };
            reader.readAsText(oneProgress.file);
        }
        $scope.saveContents = function(oneProgress, content) {
            var payload = {
                fileName: oneProgress.file.name,
                content: content.trim()
            }
            var postURL = "FileReceive.jsp?f="+encodeURIComponent(payload.fileName);
            $scope.showError=false;
            $http.post(postURL, JSON.stringify(payload))
            .success( function(data) {
                $scope.fileName = payload.fileName;
                oneProgress.status = "DONE";
                oneProgress.done = true;
            })
            .error( function(data, status, headers, config) {
                $scope.reportError(data);
            });
        }

    });
  </script>
  <style>
    .lvl-over {
        background-color: yellow;
    }
    .nicenice {
        border: 2px dashed #bbb;
        border-radius: 5px;
        padding: 25px;
        text-align: center;
        font: 20pt bold Georgia,Tahoma,sans-serif;
        color: #bbb;
        margin-bottom: 20px;
        width:500px;
    }
  </style>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">
<h1>File Upload</h1>

<table>
<tr><td>
   <button ng-click="goMode('selectfile.jsp')" class="btn btn-primary">Change File</button>
</td></tr>
<tr><td>
</table>

    <table class="table">
        <tr>
            <td class="firstColumn"></td>
            <td>
                <div id="holder" class="nicenice">Drop Files Here</div>
            </td>
        </tr>
        <tr>
            <td class="gridTableColummHeader"></td>
            <td>
                <div ng-repeat="fp in fileProgress" class="well">
                  <div style="margin-bottom:15px">
                      <div style="float:left;"><b>{{fp.file.name}}</b> - {{fp.file.size|number}} bytes</div>

                      <div style="float:right;">{{fp.status}}</div>
                      <div style="clear:both;"></div>
                  </div>
                  <div ng-hide="fp.done">
                      <button ng-click="startUpload(fp)" class="btn btn-primary">Upload</button>
                      <button ng-click="cancelUpload(fp)" class="btn btn-warning">Cancel</button>
                  </div>
                  <div ng-show="fp.done">
                      <button ng-click="goMode('xmledit.jsp', fp.file.name)" class="btn btn-primary">Text View</button>
                  </div>
                </div>
            </td>
        </tr>
    </table>



<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>

<script>
var holder = document.getElementById('holder');
holder.ondragenter = function (e) {
    e.preventDefault();
    this.className = 'nicenice lvl-over';
    return false;
};
holder.ondragleave = function () {
    this.className = 'nicenice';
    return false;
};
holder.ondragover = function (e) {
    e.preventDefault()
}
holder.ondrop = function (e) {
    e.preventDefault();

    var newFiles = e.dataTransfer.files;
    if (!newFiles) {
        alert("Oh.  It looks like you are using a browser that does not support the dropping of files.  Currently we have no other solution than using Mozilla or Chrome or the latest IE for uploading files.");
        return;
    }
    if (newFiles.length==0) {
        console.log("Strange, got a drop, but no files included");
    }

    this.className = 'nicenice';
    var scope = window.MY_SCOPE;

    for (var i=0; i<newFiles.length; i++) {
        var newProgress = {};
        newProgress.file = newFiles[i];
        newProgress.status = "Preparing";
        newProgress.done = false;
        scope.fileProgress.push(newProgress);
    }
    scope.$apply();
};
</script>
</body>
</html>
