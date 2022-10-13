<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.StringReader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String act = wr.reqParam("act");
    String f = wr.reqParam("f");
    FileCache mainDoc = FileCache.findFile(session, f);
    if (mainDoc==null) {
        mainDoc = new FileCache(f);
        FileCache.storeFile(session, mainDoc);
    }

    if ("Save Contents".equals(act)) {
        String value = wr.reqParam("value");
        if (value==null) {
            throw new Exception("value is null");
        }
        mainDoc.setContents(value);

        String schema = wr.defParam("schema", null);
        if (schema!=null) {
            FileCache schemaFile = FileCache.findFile(session, schema);
            if (schemaFile!=null) {
                mainDoc.setSchema(schemaFile);
            }
        }
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8"));
    }
    else if ("Cancel".equals(act)) {
        //ignore this
        response.sendRedirect("selectfile.jsp");
    }
    else {
        throw new Exception("Don't understand the action: "+act);
    }
%>
