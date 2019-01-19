<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    Hashtable ht = (Hashtable) session.getAttribute("fileCache");
    if (ht == null)
    {
        ht = FileCache.getPreloadedHashtable();
        session.setAttribute("fileCache", ht);
    }

    String act = wr.reqParam("act");
    String f = wr.reqParam("f");

    if ("Parse Value".equals(act))
    {
        String value = wr.reqParam("value");
        FileCache fc = new FileCache(f, value);
        ht.put(f, fc);
        String schema = wr.defParam("schema", null);
        if (schema!=null)
        {
            FileCache schemaFile = (FileCache) ht.get(schema);
            if (schemaFile!=null)
            {
                fc.setSchema(schemaFile);
            }
        }
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8"));
    }
    else if ("Cancel".equals(act))
    {
        //ignore this
        response.sendRedirect("selectfile.jsp");
    }
    else
    {
        throw new Exception("Don't understand the action: "+act);
    }
%>
