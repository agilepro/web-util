<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
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

    String act = wr.reqParam("act");

    if ("Cancel".equals(act))
    {
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8"));
    }
    else if ("Set".equals(act))
    {
        String s = wr.reqParam("s");
        FileCache schemaFile = (FileCache) ht.get(s);
        if (schemaFile==null)
        {
            throw new Exception("sorry, can't find a file named '"+s+"' for use as the schema.");
        }
        mainDoc.setSchema(schemaFile);
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else
    {
        throw new Exception("Action not implemented: "+act);
    }
%>
