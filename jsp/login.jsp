<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    String go = wr.reqParam("go");
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Log In</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Log In</h1>
<hr>

<table>
<form action="loginAction.jsp" method="post">
<col width="50">
<col width="150" align="right">
<col width="450">
<tr>
<td></td>
<td>Open Id:</td>
<td><input type="text" name="openid" size="50"></td>
</tr>
<tr>
<td></td>
<td></td>
<td><input type="submit" value="Log In"></td>
</tr>
</form>
</table>

</body>
</html>

<%@include file="functions.jsp"%>
