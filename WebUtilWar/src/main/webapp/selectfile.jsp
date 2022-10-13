<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="com.purplehillsbooks.web.WebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    //determine a good name for a new file if they want to create one
    int i=1;
    String newFileName = "File "+i;
    FileCache checker = FileCache.findFile(session, newFileName);
    while (checker!=null) {
        i++;
        newFileName = "File "+i;
        checker = FileCache.findFile(session, newFileName);
    }


%>



<html>
<head>
  <title>File List</title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.srctext = "dddd";

        
        $scope.goMode = function(page) {
            window.location.assign(page+"?f="+encodeURIComponent($scope.fileName));
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
<h1>File List</h1>

<table class="table">
<%

    int count = 0;
    for (FileCache fc : FileCache.listFiles(session)) {
        if (fc.isSchema) {
            continue;
        }
        String name = fc.getName();
        FileCache fcSchema = fc.getSchema();
        String schemaName = "";
        if (fcSchema!=null) {
            schemaName = fcSchema.getName();
        }
        count++;
        if (fc.isValidJSON())
        {
%>
<tr><td><a href="<%=wr.retPath%>xmledit.jsp?f=<%= URLEncoder.encode(name, "UTF-8") %>">
    <% wr.writeHtml(name); %></a></td><td>(JSON)  <% wr.writeHtml(schemaName); %> </td></tr>
<%
        }
        else
        {
%>
<tr><td><a href="<%=wr.retPath%>xmledit.jsp?f=<%= URLEncoder.encode(name, "UTF-8") %>">
    <% wr.writeHtml(name); %></a></td><td>(<% wr.writeHtml(fc.getType()); %>)</td></tr>
<%
        }
    }
%>
</table>


<table><tr><td>
   <button ng-click="goMode('xmlpaste.jsp')" class="btn btn-primary">Load Pasted Text</button>
</td><td>
   <button ng-click="goMode('xmlopen.jsp')" class="btn btn-primary">Load Web Resource</button>
</td><td>
   <button ng-click="goMode('xmlupload.jsp')" class="btn btn-primary">Upload File</button>
</td></tr></table>


<p>Please note, files are retained only for the duration of your session, 
usually until about 30 minutes after your last access.</p>

<div style="height:50px"></div>

<% wr.invokeJSP("tileBottom.jsp"); %>
</div>

</body>
</html>

<%@include file="functions.jsp"%>
