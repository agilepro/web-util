<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.FileOutputStream"
%><%@page import="java.io.OutputStream"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.File"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Map"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Document"
%><%@page import="org.w3c.dom.Element"
%><%@page import="org.w3c.dom.NamedNodeMap"
%><%@page import="org.w3c.dom.Node"
%><%@page import="org.w3c.dom.NodeList"
%><%@page import="com.purplehillsbooks.xml.Mel"
%><%@page import="com.purplehillsbooks.xml.Schema"
%><%@page import="com.purplehillsbooks.xml.SchemaGen"
%><%@page import="com.purplehillsbooks.xml.ValidationResults"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%@page import="com.purplehillsbooks.json.JSONSchema"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");
    String destFile = wr.defParam("destFile", null);

    Hashtable<String,FileCache> ht = (Hashtable<String,FileCache>) session.getAttribute("fileCache");
    if (ht == null) {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    FileCache mainDoc = (FileCache) ht.get(f);

    if (mainDoc==null) {
        response.sendRedirect("selectfile.jsp");
        return;
    }
    String go = "xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8");

    String act = wr.reqParam("act");

    if ("Change File".equals(act))
    {
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else if ("JSON View".equals(act))
    {
        response.sendRedirect(go);
        return;
    }
    else if ("Field Edit".equals(act))
    {
        response.sendRedirect("fieldview.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else if ("Data View".equals(act))
    {
        response.sendRedirect("dataview.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else if ("Java View".equals(act))
    {
        response.sendRedirect("javaview.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else if ("Set Schema".equals(act))
    {
        String otherFile=wr.reqParam("otherFile");
        FileCache schemaFile = (FileCache) ht.get(otherFile);
        if (schemaFile==null) {
            throw new Exception("sorry, can't find a schema file named '"+otherFile+"'");
        }
        mainDoc.setSchema(schemaFile);
        response.sendRedirect(go);
        return;
    }
    else if ("Rename".equals(act))
    {
        if (destFile!=null) {
            mainDoc.setName(destFile);
            ht.remove(f);
            ht.put(destFile, mainDoc);
        }
        response.sendRedirect(go);
        return;
    }
    else if ("Reformat".equals(act))
    {
        //mainDoc.getMel().reformatXML();
        response.sendRedirect(go);
        return;
    }
    else if ("Edit".equals(act))
    {
        response.sendRedirect("xmlfix.jsp?f="+URLEncoder.encode(f));
        return;
    }
    else if ("Operation".equals(act))
    {
        response.sendRedirect("xmlop.jsp?f="+URLEncoder.encode(f));
        return;
    }
    else if ("Gen Schema".equals(act))
    {
        String otherFile=wr.reqParam("destFile");
        FileCache schemaFile = (FileCache) ht.get(otherFile);
        if (schemaFile==null) {
            schemaFile = new FileCache(otherFile);
            ht.put(otherFile, schemaFile);
        }
        JSONSchema generator = new JSONSchema();
        JSONObject schema = generator.generateSchema(mainDoc.getJSON());
        schemaFile.setContents(schema.toString());
        response.sendRedirect(go);
    }
    else if ("Validate".equals(act))
    {
        //validate JSON here according to schema
    }
    else if ("Register XMLSchema".equals(act))
    {
        //register thsi as a schema
    }
    else if ("Save to Path".equals(act))
    {
        //should have a save to option on the FileCache
    }
    else
    {
        throw new Exception("Action not implemented: "+act);
    }
%>

