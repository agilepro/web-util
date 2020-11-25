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
  <title>Batch Process Starter</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Batch Process Starter</h1>
<form action="BatchProcessStarterAction.jsp" method="post">
  Process Definition ID:  <input type="text" name="pdid" value="" size="10"><br/>
  <textarea name="csvSource" cols="100" rows="20"></textarea><br>
  <input type="submit" value="Start Processes">
  Ignore columns that do not match a UDA name: <input type="checkbox" name="ignoreColumns" value="yes">
</form>

<hr>

<p><font size="-1">Copy and paste the CSV into the edit box above.
The first row of the CSV should be the column names.
Each column should match by name a UDA to put the value into.
Press "Start Processes" to have that CSV read, parsed, and a process created for each
row in the CVS.
The ignore non-matching UDA names will suppress the
</p>
<hr/>
<div style="font-size:small;text-align:center">© 2019, Keith D Swenson</div>
</body>
</html>

<%@ include file="functions.jsp"%>
