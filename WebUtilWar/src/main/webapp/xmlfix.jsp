<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
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


    Exception error = mainDoc.getError();

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Edit File: <%wr.writeHtml(f);%></title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.srctext = "<% mainDoc.writeContents(out); %>";

    });
  </script>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">
<h1>Edit File: <%wr.writeHtml(f);%></h1>
<%
    if (error!=null)
    {
%>
<p>text below is not valid JSON.  You might be able to manually correct the problem for further work.</p>
<%
    }
%>
<hr>
<p><form action="xmlpasteAction.jsp" method="POST">
   <input type="submit" name="act" value="Save Contents"><br/>
   <textarea name="value" cols="80" rows="20"><% mainDoc.writeContents(out); %></textarea><br/>
   Name for this file: <input type="text" name="f" value="<% wr.writeHtml(f); %>"><br/>
   <input type="submit" name="act" value="Cancel">
   </form>
<hr>
<%
    if (error!=null)
    {
%>
<p>The parsing error was</p>
<pre><% wr.writeHtml(error.toString()); %></pre>
<hr>
<%
    }
%>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
