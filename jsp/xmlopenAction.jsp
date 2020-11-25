<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.File"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.defParam("f", "");

    String act = wr.reqParam("act");
    String username = wr.defParam("username", "");
    String password = wr.defParam("password", "");

    System.out.println("Starting to read XML file -- "+System.currentTimeMillis());
    Hashtable ht = (Hashtable) session.getAttribute("fileCache");
    if (ht == null)
    {
        ht = FileCache.getPreloadedHashtable();
        session.setAttribute("fileCache", ht);
    }

    if ("Load From URL".equals(act))
    {
        String urlPath = wr.reqParam("url");
        String charset = wr.reqParam("charset");
        if (f==null || f.length()==0)
        {
            int slashpos = urlPath.lastIndexOf("/");
            if (slashpos>=0)
            {
                f = urlPath.substring(slashpos+1);
            }
            else
            {
                f = urlPath;
            }
        }
        if (f==null || f.length()==0)
        {
            throw new Exception("Some sort of strange problem here, should not happen: "+urlPath+" & "+urlPath.lastIndexOf("/"));
        }
        System.out.println("Reading file: "+urlPath+" -- "+System.currentTimeMillis());
        FileCache fc = new FileCache(f, FileCache.LOAD_WEB_RESOURCE, urlPath, charset, ht);
        System.out.println("Cached, now parsing: "+urlPath+" -- "+System.currentTimeMillis());
        ht.put(f, fc);
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        System.out.println("all done: -- "+System.currentTimeMillis());
    }
    else if ("Load From Local File".equals(act))
    {
        String fullpath = wr.reqParam("path");
        File path = new File(fullpath);
        if (!path.exists()) {
            throw new Exception("the path does not exist: "+fullpath);
        }
        String name = path.getName();
        System.out.println("Reading file: "+path+" -- "+System.currentTimeMillis());
        FileCache fc = FileCache.createFromFile(name, path);
        System.out.println("Cached, now parsing: "+path+" -- "+System.currentTimeMillis());
        ht.put(name, fc);
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(name, "UTF-8"));
        System.out.println("all done: -- "+System.currentTimeMillis());
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
