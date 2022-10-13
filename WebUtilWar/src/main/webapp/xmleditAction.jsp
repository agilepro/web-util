<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="com.purplehillsbooks.json.Dom2JSON"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONSchema"
%><%@page import="com.purplehillsbooks.streams.MemFile"
%><%@page import="com.purplehillsbooks.xml.Mel"
%><%@page import="java.io.File"
%><%@page import="java.io.FileOutputStream"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.OutputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Map"
%><%@page import="java.util.List"
%><%@page import="java.util.ArrayList"
%><%@page import="org.w3c.dom.Document"
%><%@page import="org.w3c.dom.Element"
%><%@page import="org.w3c.dom.NamedNodeMap"
%><%@page import="org.w3c.dom.Node"
%><%@page import="org.w3c.dom.NodeList"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");
    String destFile = wr.defParam("destFile", null);

    FileCache mainDoc = FileCache.findFile(session, f);

    if (mainDoc==null) {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }

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
        FileCache schemaFile = FileCache.findFile(session, otherFile);
        if (schemaFile==null) {
            throw new Exception("sorry, can't find a schema file named '"+otherFile+"'");
        }
        mainDoc.setSchema(schemaFile);
        response.sendRedirect(go);
        return;
    }
    else if ("Rename".equals(act)) {
        mainDoc.setName(session, destFile);
        response.sendRedirect(go);
        return;
    }
    else if ("Save As".equals(act)) {
        MemFile mf = new MemFile();
        mf.fillWithInputStream(mainDoc.getInputStream());
        FileCache newCopy = new FileCache(destFile, mf);
        FileCache.storeFile(session, newCopy);
        response.sendRedirect(go);
        return;
    }
    else if ("Edit".equals(act)){
        response.sendRedirect("xmlfix.jsp?f="+URLEncoder.encode(f));
        return;
    }
    else if ("Operation".equals(act)) {
        response.sendRedirect("xmlop.jsp?f="+URLEncoder.encode(f));
        return;
    }
    else if ("Gen Schema".equals(act))
    {
        String otherFile=wr.reqParam("destFile");
        FileCache schemaFile = FileCache.findFile(session, otherFile);
        if (schemaFile==null) {
            schemaFile = new FileCache(otherFile);
            FileCache.storeFile(session, schemaFile);
        }
        JSONSchema generator = new JSONSchema();
        JSONObject schema = generator.generateSchema(mainDoc.getJSON());
        schemaFile.setContents(schema.toString());
        response.sendRedirect(go);
        return;
    }
    else if ("Generate JSON".equals(act)) {
        if (!mainDoc.isValidXML()) {
            throw new Exception("must be XML");
        }
        Hashtable<String,Integer> hints = new Hashtable<String,Integer>();
        hints.put("input", 3);
        hints.put("output", 3);
        hints.put("rule", 3);
        hints.put("decision", 3);
        hints.put("contextEntry", 3);
        hints.put("decisionService", 3);
        hints.put("semantic:input", 3);
        
        Mel xmlFile = mainDoc.getXML();
        JSONObject jo = Dom2JSON.convertDomToJSON(xmlFile.getDocument(), hints);
        //FileCache.recusiveStripNameSpace(jo);
        String xmlFileName = mainDoc.getName();
        int xpos = xmlFileName.indexOf(".");
        if (xpos>0) {
            xmlFileName = xmlFileName.substring(0, xpos);
        }
        xmlFileName = xmlFileName + ".json";
        FileCache fc = new FileCache(xmlFileName);
        fc.setContents(jo.toString());
        FileCache.storeFile(session, fc);
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else if ("Reformat".equals(act)) {
        if (!mainDoc.isValidXML()) {
            throw new Exception("must be XML");
        }
        Mel xmlFile = mainDoc.getXML();
        response.sendRedirect(go);
        return;
    }
    else if ("Validate".equals(act)){
        String otherFile = wr.reqParam("otherFile");
        FileCache schemaDoc = FileCache.findFile(session, otherFile);
        JSONSchema jSchema = new JSONSchema();
        jSchema.checkSchema(mainDoc.getJSON(), schemaDoc.getJSON());
        MemFile mf = new MemFile();
        Writer w = mf.getWriter();
        w.write("=== Schema validation of "+mainDoc.getName()+" with "+schemaDoc.getName()+" ===\n");
        for (String error : jSchema.getErrorList()) {
            w.write(error);
            w.write("\n");
        }
        w.flush();
        FileCache dest = new FileCache(destFile, mf);
        FileCache.storeFile(session, dest);
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else if ("Register XMLSchema".equals(act)) {
        throw new Exception("Register XMLSchema not implemented: "+act);
    }
    else if ("Save to Path".equals(act)) {
        throw new Exception("Save to Path not implemented: "+act);
    }
    else if (act.length()>0) {
        //need a nonsense if statement so that compiler won't complain about below
        throw new Exception("Action not implemented: "+act);
    }
%><%!
%>