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

    int amtTotal = 0;
    String pageSource = fetchDoc(session, request);
    String pageURL = (String) session.getAttribute("url");

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

    //makeTabs(out, "Source");

%>
<hr>
<pre>
<%
    if (pageSource != null) {
        out.write("\n<table><tr><td><tt>");
        out.flush();
        //wr.writeHtmlWithLines(pageSource);
        out.write("</tt></td></tr></table>");
    }
    else {
        %>No page is loaded, go to 'Set up' and configure one.<%
    }

%>
</pre>
<hr>
<p><font size="-1">This shows the source of the designated page.
Go to the setup to specify a different page.</p>
</body>
</html>

<%@ include file="functions.jsp"%>
