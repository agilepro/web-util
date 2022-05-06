<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%
    request.setCharacterEncoding("UTF-8");
    String path = request.getParameter("path");
    if (path==null) {
        path = "";
    }

    String pageSource = fetchDoc(session, request);

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Page Source Display</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Swenson Utilities - Page Source Display</h1>
<%

    //makeTabs(out, "Links");

%>
<hr>

<%

    if (pageSource != null) {
        out.write("<table><tr><td><tt>show links here</tt></td></tr></table>");
    }
    else {

    }

%>

<hr>

</body>
</html>

<%@ include file="functions.jsp"%>
