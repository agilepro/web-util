<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Vector"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");

    Hashtable ht = (Hashtable) session.getAttribute("fileCache");
    if (ht == null)
    {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    FileCache mainDoc = (FileCache) ht.get(f);

    if (mainDoc==null)
    {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    if (!mainDoc.isValidXML())
    {
        throw new Exception("How did you get here?  File '"+f+"' is not valid XML, and this page works only with valid XML.");
    }


    Enumeration e = ht.elements();
    Vector otherFiles = new Vector();
    while (e.hasMoreElements())
    {
        FileCache fc = (FileCache) e.nextElement();
        String name = fc.getName();
        if (name.equals(f))
        {
            continue;
        }
        otherFiles.add(name);
    }


%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>XML Grinder: <%wr.writeHtml(f);%></title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>XML Grinder: <%wr.writeHtml(f);%></h1>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Change File">
   <input type="submit" name="act" value="XML View">
   <input type="submit" name="act" value="Data View">
   <input type="submit" name="act" value="Java View">
   </form></p>


<h2>Operations</h2>
<p>File: <b><%wr.writeHtml(f);%></b>
  &nbsp; &nbsp; &nbsp; MinSch is
<%
    FileCache fcs = mainDoc.getSchema();
    if (fcs==null)
    {
        out.write("<i>not set</i>");
    }
    else
    {
        wr.write(" <b>");
        wr.writeHtml(fcs.getName());
        wr.write("</b>");
    }
%>
</p>


<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Gen MinSch">
   to file name: <input type="text" name="destFile" value="MinSch for <%wr.writeHtml(f);%>">
   </form></p>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Reformat">
   to put the file in canonical form
   </form></p>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Transform">
   using XSLT: <select type="text" name="otherFile">
<%
    e = otherFiles.elements();
    while (e.hasMoreElements())
    {
        wr.write("<option>");
        wr.writeHtml((String)e.nextElement());
        wr.write("</option>");
    }
%>
   </select>
   output to: <input type="text" name="destFile" value="Transform of <%wr.writeHtml(f);%>">
   </form></p>


<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Validate">
   using schema: <select type="text" name="otherFile">
<%
    e = otherFiles.elements();
    while (e.hasMoreElements())
    {
        wr.write("<option>");
        wr.writeHtml((String)e.nextElement());
        wr.write("</option>");
    }
%>
   </select>
   output to: <input type="text" name="destFile" value="Validation of <%wr.writeHtml(f);%>">
   </form></p>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Set MinSch">
   to the file:  <select type="text" name="otherFile">
<%
    e = otherFiles.elements();
    while (e.hasMoreElements())
    {
        wr.write("<option>");
        wr.writeHtml((String)e.nextElement());
        wr.write("</option>");
    }
%>
   </select>
   </form></p>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Rename">
   file to new name: <input type="text" name="destFile" value="<%wr.writeHtml(f);%>">
   </form></p>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Save to Path">
   file to new name: <input type="text" name="path" value="">
   </form></p>



<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Eliminate CData">
   to convert CData into normal data
   </form></p>

<p><form action="showxpath.jsp" method="GET">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="hidden" name="s" value="false">
   <input type="submit" name="act" value="Show XPaths">
   </form></p>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="text" name="sn" value="">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Register XMLSchema">
   </form></p>

<p><form action="kmlSmoothing.jsp" method="POST">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Smooth KML File">
   </form></p>

<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
