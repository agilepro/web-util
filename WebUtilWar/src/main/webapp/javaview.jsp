<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Writer"
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
%><%@page import="com.purplehillsbooks.xml.Mel"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="org.workcast.wu.XMLSchemaDef"
%><%@page import="org.workcast.wu.XMLSchemaFile"
%><%@page import="org.workcast.wu.XMLSchemaPool"
%><%@page import="org.workcast.wu.XMLSchemaType"
%><%@page import="com.purplehillsbooks.streams.HTMLWriter"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");

    Hashtable<String,FileCache> ht = (Hashtable<String,FileCache>) session.getAttribute("fileCache");
    if (ht == null)
    {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    XMLSchemaPool pool = (XMLSchemaPool) session.getAttribute("XMLSchemaPool");
    if (pool == null)
    {
        pool = new XMLSchemaPool();
        session.setAttribute("XMLSchemaPool", pool);
    }
    FileCache mainDoc = (FileCache) ht.get(f);

    if (mainDoc==null)
    {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    String validMarker = "NOT XML";

    String nameSpace = "unknown";

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
    <% if (mainDoc.isValidJSON()) { %>
    <input type="submit" name="act" value="Data View">
    <input type="submit" name="act" value="Edit">
    <input type="submit" name="act" value="Operation">
    <input type="submit" name="act" value="Internalize">
    <input type="submit" name="act" value="Externalize">
    <% } else { %>
    <input type="submit" name="act" value="Edit">
    <% } %>
    <% if (mainDoc.isRefreshable()) { %>
    <input type="submit" name="act" value="Refresh">
    <% } %>
    <% if (mainDoc.isXMLSchema()) { %>
    <input type="submit" name="act" value="Register XMLSchema">
    <% } %>

   </form></p>
<p>
<%
    if (!mainDoc.isValidJSON()) {
        wr.write("<font color=\"red\">NOT JSON</font>");
    }
    else {
        out.write("Valid XML,   Schema is");
        FileCache fcs = mainDoc.getSchema();
        if (fcs==null)
        {
            wr.write(" <i>not set</i>");
        }
        else
        {
            wr.write(": ");
            wr.writeHtml(fcs.getName());
        }
    }
    if (mainDoc.isRefreshable())
    {
        wr.write(" - - ");
        wr.writeHtml(mainDoc.refreshDesc());
    }
%>
<a href="findallpaths.jsp">Find All Paths</a>
</p>
<hr/>
<% if (mainDoc != null) { %>
<pre>w.write("<% writeContentsJava(out, mainDoc); %>");</pre>
<% } else { %>
<p>No XML document is loaded into the editor.  Use the load option to bring in a document.</p>
<% } %>
<hr/>
<%
    if (mainDoc!=null && mainDoc.isValidXML())
    {
        Mel root = mainDoc.getMel();
        %>Defspace '<%
        wr.writeHtml(root.getPrefix());
        %>': <%
        wr.writeHtml(nameSpace);


        %><br/>Assigned: <%
        wr.writeHtml(mainDoc.assignedNamespace);
        %><br/><%

        Vector allAttrNames = root.getAllAttributeNames();
        for (String aName : (Vector<String>)allAttrNames)
        {
            int colonPos = aName.indexOf(":");
            if (colonPos>0)
            {
                String prePart = aName.substring(0,colonPos);
                if ("xmlns".equals(prePart))
                {
                    String postPart = aName.substring(colonPos+1);
                    String ns = root.getAttribute(aName);
                    wr.write("<br/>Namespace '");
                    wr.writeHtml(postPart);
                    wr.write("': ");
                    wr.writeHtml(ns);
                }
            }
        }
    }

    Map<String,XMLSchemaFile> schemaTable = pool.getMap();
    int i=0;
    for (String mapping : schemaTable.keySet())
    {
        XMLSchemaFile ace = schemaTable.get(mapping);
        wr.write("<br/>Registered: ");
        wr.writeHtml(mapping);
        wr.write("  -  -  ");
        wr.writeHtml(ace.getOfficialPrefix());
        for (String key : ace.globalElements.keySet())
        {
            wr.write("   (");
            wr.writeHtml(key);
            wr.write(")");
        }
        if (ace.elementFormQualified)
        {
            wr.write(" *qualified* ");
        }
        else
        {
            wr.write(" *unqualified* ");
        }
        for (String key : ace.prefixNamespace.keySet())
        {
            wr.write("   (");
            wr.writeHtml(key);
            wr.write("=");
            wr.write(ace.prefixNamespace.get(key));
            wr.write(")");
        }
        i++;
    }


%>
<br/><%=i%> registered keys found

<hr/>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->

<%!

    public void writeContentsJava(Writer wr, FileCache mainDoc)
        throws Exception
    {
        HTMLWriter hr = new HTMLWriter(wr);
        Reader r = mainDoc.getReader();
        int ch = r.read();
        while (ch>=0)
        {
            switch (ch) {
            case '\n':
                wr.write("\\n\");\nw.write(\"");
            case '\f':
            case '\r':
                break;
            case '\"':
                wr.write("\\&quot;");
                break;
            case '\\':
                wr.write("\\\\");
                break;
            default:
                hr.write((char)ch);
            }
            ch = r.read();
        }
    }


%>