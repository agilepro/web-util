<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Map"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Document"
%><%@page import="org.w3c.dom.Element"
%><%@page import="org.w3c.dom.Node"
%><%@page import="org.w3c.dom.NodeList"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");

    FileCache mainDoc = FileCache.findFile(session, f);

    if (mainDoc==null) {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>File View: <%wr.writeHtml(f);%></title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope, $http) {
        $scope.fileName = "<% wr.writeJS(f); %>";
        $scope.fileType = "<% wr.writeJS(mainDoc.getType()); %>";
        
        $scope.content = "<% mainDoc.writeContentsJS(out); %>";
        $scope.goof = function() {
            window.open("dmn-test.jsp?f="+$scope.fileName);
        }
        $scope.goMode = function(page) {
            window.location.assign(page+"?f="+encodeURIComponent($scope.fileName));
        }
        $scope.update = function() {
            var postURL = "FileReceive.jsp?f="+encodeURIComponent($scope.fileName);
            var oneProgress = {};
            var payload = {
                fileName: $scope.fileName,
                content: $scope.content.trim()
            }
            sendPost(payload);
        }
        function sendPost(value) {
            var postURL = "FileReceive.jsp?f="+encodeURIComponent($scope.fileName);
            $scope.showError=false;
            console.log("POSTING", value);
            $http.post(postURL, JSON.stringify(value))
            .success( function(data) {
                $scope.goMode("selectfile.jsp");
            })
            .error( function(data, status, headers, config) {
                $scope.reportError(data);
            });
        }

    });
  </script>
  <style>
  .datacell {
      padding:5px;
  }
  tr td {
      padding:5px;
  }
  </style>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">
<h1>{{fileType}} View: {{fileName}}</h1>

<table>
<tr><td>
   <button ng-click="goMode('selectfile.jsp')" class="btn btn-primary">Change File</button>
</td><td>
   <button ng-click="goMode('xmledit.jsp')" class="btn btn-warning">Text View</button>
<% if (mainDoc.isValidJSON() || mainDoc.isValidXML()) { %>
</td><td>
   <button ng-click="goMode('xmlop.jsp')" class="btn btn-primary">Operation</button>
</td><td>
   <button ng-click="goMode('dataview.jsp')" class="btn btn-primary">Data View</button>
<% } %>
<% if (mainDoc.isValidJSON()) { %>
</td><td>
   <button ng-click="goMode('fieldview.jsp')" class="btn btn-primary">Field Edit</button>
<% } %>
</td></tr>
<tr><td>
</table>

   
   
   </p>
<p>
<%
    if (!mainDoc.isValidJSON()) {
        wr.write(" <font color=\"red\">NOT JSON</font> ");
    }
    else {
        out.write("Valid JSON,   Schema is");
        FileCache fcs = mainDoc.getSchema();
        if (fcs==null) {
            wr.write(" <i>not set</i> ");
        }
        else {
            wr.write(": ");
            wr.writeHtml(fcs.getName());
        }
    }
    if (!mainDoc.isValidXML()) {
        wr.write(" <font color=\"red\">NOT XML</font> ");
    }
    else {
        out.write(" Valid XML ");
    }
%>

</p>
<textarea ng-model="content" style="width:800px;height:400px"></textarea>

<table><tr><td>
<button ng-click="update()" class="btn btn-primary">Update {{fileName}}</button>
</td></tr></table>

<hr/>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>

</body>
</html>


