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
%><%@page import="java.util.Hashtable"
%><%@page import="com.purplehillsbooks.xml.Schema"
%><%@page import="com.purplehillsbooks.xml.SchemaGen"
%><%@page import="com.purplehillsbooks.xml.ValidationResults"
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
        response.sendRedirect("selectfile.jsp");
        return;
    }


    String act = wr.reqParam("act");

    if ("Save Changes".equals(act))
    {
        response.sendRedirect("dataview.jsp?f="+URLEncoder.encode(f));
        return;
    }
    else if (true)
    {
        throw new Exception("Action not implemented: "+act);
    }
%>
