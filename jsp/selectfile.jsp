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

    Hashtable ht = (Hashtable) session.getAttribute("fileCache");
    if (ht == null)
    {
        //this will be the start page for many people, so very important
        //to create this object at this time.
        ht = FileCache.getPreloadedHashtable();
        session.setAttribute("fileCache", ht);
    }

    //determine a good name for a new file if they want to create one
    int i=1;
    String newFileName = "File "+i;
    Object checker = ht.get(newFileName);
    while (checker!=null)
    {
        i++;
        newFileName = "File "+i;
        checker = ht.get(newFileName);
    }


%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Select File</title>
  <link href="<%=wr.retPath%>mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Select or Load XML</h1>
<hr>
<ul>
<%
    Enumeration e = ht.elements();
    int count = 0;
    while (e.hasMoreElements())
    {
        FileCache fc = (FileCache) e.nextElement();
        if (fc.isSchema)
        {
            continue;
        }
        String name = fc.getName();
        FileCache fcSchema = fc.getSchema();
        String schemaName = "";
        if (fcSchema!=null)
        {
            schemaName = fcSchema.getName();
        }
        count++;
        if (fc.isValidXML())
        {
%>
<li><a href="<%=wr.retPath%>xmledit.jsp?f=<%= URLEncoder.encode(name, "UTF-8") %>">
    <% wr.writeHtml(name); %></a> (xml)  <% wr.writeHtml(schemaName); %> </li>
<%
        }
        else
        {
%>
<li><a href="<%=wr.retPath%>xmledit.jsp?f=<%= URLEncoder.encode(name, "UTF-8") %>">
    <% wr.writeHtml(name); %></a> (txt)</li>
<%
        }
    }
%>
</ul>
<h1>Select or Load MinSch</h1>
<ul><%
    e = ht.elements();
    while (e.hasMoreElements())
    {
        FileCache fc = (FileCache) e.nextElement();
        if (!fc.isSchema)
        {
            continue;
        }
        String name = fc.getName();
        FileCache fcSchema = fc.getSchema();
        String schemaName = "";
        if (fcSchema!=null)
        {
            schemaName = fcSchema.getName();
        }
        count++;
        if (fc.isValidXML())
        {
%>
<li><a href="<%=wr.retPath%>xmledit.jsp?f=<%= URLEncoder.encode(name, "UTF-8") %>">
    <% wr.writeHtml(name); %></a> (xml)  <% wr.writeHtml(schemaName); %> </li>
<%
        }
        else
        {
%>
<li><a href="<%=wr.retPath%>xmledit.jsp?f=<%= URLEncoder.encode(name, "UTF-8") %>">
    <% wr.writeHtml(name); %></a> (txt)</li>
<%
        }
    }

    if (count==0)
    {
        %>
        <p>There are no files loaded at this time.   Use the 'Add' buttons below to import a file for working with.</p>
        <p>Please note that if you do load files into the server, they will remain only as long as your session
           remains active.  <br/>After you are idle for a while (30 minutes), they will be cleared out of memory.<%
    }

%>

</ul>
<hr>
<p><form action="<%=wr.retPath%>selectfileAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(newFileName); %>">
   <input type="submit" name="act" value="Load Web Resource">
   <input type="submit" name="act" value="Load Pasted Text">
   <input type="submit" name="act" value="Load Standard Files">
   </form></p>

<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<%@include file="functions.jsp"%>
