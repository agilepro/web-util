<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Map"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Document"
%><%@page import="org.w3c.dom.Element"
%><%@page import="org.w3c.dom.Node"
%><%@page import="org.w3c.dom.NodeList"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");

    Hashtable<String,FileCache> ht = (Hashtable<String,FileCache>) session.getAttribute("fileCache");
    if (ht == null) {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    FileCache mainDoc = (FileCache) ht.get(f);

    if (mainDoc==null) {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>JSON Grinder: <%wr.writeHtml(f);%></title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>JSON Grinder: <%wr.writeHtml(f);%></h1>
<p><form action="xmleditAction.jsp" method="POST">
    <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
    <input type="submit" name="act" value="Change File">
    <% if (mainDoc.isValidJSON()) { %>
    <input type="submit" name="act" value="Data View">
    <input type="submit" name="act" value="Edit">
    <input type="submit" name="act" value="Operation">
    <% } else { %>
    <input type="submit" name="act" value="Edit">
    <% } %>

   </form></p>
<p>
<%
    if (!mainDoc.isValidJSON()) {
        wr.write("<font color=\"red\">NOT JSON</font>");
    }
    else {
        out.write("Valid JSON,   Schema is");
        FileCache fcs = mainDoc.getSchema();
        if (fcs==null) {
            wr.write(" <i>not set</i>");
        }
        else {
            wr.write(": ");
            wr.writeHtml(fcs.getName());
        }
    }
%>
<a href="findallpaths.jsp">Find All Paths</a>
</p>
<hr/>
<% if (mainDoc != null) { %>
<pre><% mainDoc.writeContentsHtml(out); %></pre>
<% } else { %>
<p>No XML document is loaded into the editor.  Use the load option to bring in a document.</p>
<% } %>
<hr/>

<hr/>
<% wr.invokeJSP("tileBottom.jsp"); %>


</body>
</html>


