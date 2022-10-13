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
  <title>XML Editor - Upload File</title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.srctext = "dddd";

    });
  </script>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">
<h1>XML Editor - Open Web Resource</h1>
<form action="xmlopenAction.jsp" method="POST">
    <table class="table">
    <tr><td></td><td>
       <input type="submit" name="act" value="Load From Local File">
    </td></tr>
    <tr><td>
        Path to file:
    </td><td>
        <input type="text" name="path" value="">
    </td></tr>
    <tr><td></td><td>
       <input type="submit" name="act" value="Cancel">
    </td></tr>
    </table>
</form>

   <p>You have to find the file path on your system to the file that you want
   to upload, and paste that into the field.   Sorry, no drag/drop or browse, 
   maybe in the future.</p>
<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
