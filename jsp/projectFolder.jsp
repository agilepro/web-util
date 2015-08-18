<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.File"
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
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Project Folder Maintenance</title>
  <link href="<%=wr.retPath%>mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Project Folders</h1>
<hr>

<table>
<%

int folderCount = 0;

//hard-coded for now
String projFolderLocation = "c:\\projects\\";

File projFolder = new File(projFolderLocation);
if (!projFolder.exists())
{
    throw new Exception("The c:\\projects\\ folder must exist on your machine in order to use this page.");
}
if (!projFolder.isDirectory())
{
    throw new Exception("The c:\\projects\\ file exists, but it must be a folder on your machine in order to use this page.");
}
File[] children = projFolder.listFiles();
for (File child : children)
{
    if (!child.isDirectory())
    {
        continue;
    }
    %><tr><td><%
    wr.writeHtml(child.getName());
    %></td></tr><%
    folderCount++;
}

%>
</table>

Found <%=folderCount%> project folders
<br/>
<form action="projectFolderAction.jsp" method="post">
  <input type="submit" value="Link Another Project" name="act">
  Link: <input type="text" value="" name="url">(paste link URL in here)
  Local Name: <input type="text" value="Proj<%=folderCount+1%>" name="pname">
</form>


<hr>

<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<%@include file="functions.jsp"%>
