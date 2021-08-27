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
    String enc  = wr.defParam("enc","UTF-8");

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>CSV Parser</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>CSV Parser</h1>
<p>Paste a CVS into the box (as text) and click convert to see it as a simple HTML table</p>
<form action="CSVParsedTable.jsp" method="post">
  <textarea name="csvSource" cols="100" rows="20"></textarea><br>
  <input type="submit" value="Parse CSV">
  character encoding: <input type="text" name="enc" value="<%= enc %>">
</form>

<hr>

<p><font size="-1">Cut and paste the CSV into the edit box above, then
press "Parse CSV" to have that CSV read, parsed, and a table generated.
This will only work on well formed XML.  If the XML is not well formed,
</p>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<%@ include file="functions.jsp"%>
