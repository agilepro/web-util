<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
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
    FileCache fcs = mainDoc.getSchema();
    String schemaName = "";
    if (fcs!=null)
    {
        schemaName = fcs.getName();
    }

    Exception error = mainDoc.getError();

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Fix XML: <%wr.writeHtml(f);%></title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Fix XML: <%wr.writeHtml(f);%></h1>
<%
    if (error!=null)
    {
%>
<p>text below is not valid XML.  You might be able to manually correct the problem for further work.</p>
<%
    }
%>
<hr>
<p><form action="xmlpasteAction.jsp" method="POST">
   <input type="submit" name="act" value="Parse Value"><br/>
   <textarea name="value" cols="80" rows="20"><% wr.writeHtml(mainDoc.getContents()); %></textarea><br/>
   Name for this file: <input type="text" name="f" value="<% wr.writeHtml(f); %>"><br/>
   MinSch: <input type="text" name="schema" value="<% wr.writeHtml(schemaName); %>"><br/>
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
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
