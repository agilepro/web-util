<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");

    Hashtable ht = (Hashtable) session.getAttribute("fileCache");
    if (ht == null)
    {
        ht = FileCache.getPreloadedHashtable();
        session.setAttribute("fileCache", ht);
    }
    FileCache mainDoc = (FileCache) ht.get(f);

    if (mainDoc==null)
    {
        throw new Exception("Can't file a loaded file named '"+f
            +"'.  Have you loaded a file with this anme, or has your session timed out?");
    }


    Enumeration e = ht.elements();

    int count = 0;

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Select MinSch for <% wr.writeHtml(f); %></title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Select MinSch for <% wr.writeHtml(f); %></h1>
<hr>
<ul>
<%
    while (e.hasMoreElements())
    {
        FileCache fc = (FileCache) e.nextElement();
        String name = fc.getName();
        if (name.equals(f))
        {
            //skip the file itself
            continue;
        }
        count++;
%>
<li><a href="selectschemaAction.jsp?act=Set&f=<%= URLEncoder.encode(f, "UTF-8") %>&s=<%= URLEncoder.encode(name, "UTF-8") %>"><% wr.writeHtml(name); %></a> (set schema)</li>
<%
    }

%>

</ul>
<hr>
<p><form action="selectfileAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Cancel">
   </form></p>

<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
