<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    request.setCharacterEncoding("UTF-8");
    String path = request.getParameter("path");

    int amtTotal = 0;
    String pageSource = fetchDoc(session, request);
    String pageURL = (String) session.getAttribute("url");

    String fileListUrl = "GET https://www.googleapis.com/drive/v2/files?key={YOUR_API_KEY}";

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Google Doc Access</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Swenson Utilities - Google Doc Access</h1>










<hr>

</body>
</html>

<%@ include file="functions.jsp"%>
