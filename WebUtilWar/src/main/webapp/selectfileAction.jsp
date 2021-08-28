<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.File"
%><%@page import="java.io.FileInputStream"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="com.purplehillsbooks.streams.MemFile"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    String f = wr.defParam("f", "");
    Hashtable<String,FileCache> ht = (Hashtable<String,FileCache>) session.getAttribute("fileCache");
    if (ht == null) {
        ht = new Hashtable<String,FileCache>();
        session.setAttribute("fileCache", ht);
    }

    String act = wr.reqParam("act");

    if ("Load Web Resource".equals(act))
    {
        response.sendRedirect("xmlopen.jsp");
    }
    else if ("Load Pasted Text".equals(act))
    {
        response.sendRedirect("xmlpaste.jsp?f="+URLEncoder.encode(f, "UTF-8"));
    }
    else if ("Load Standard Files".equals(act))
    {
        String path = request.getSession().getServletContext().getRealPath("/samples");
        File sampleDir = new File(path);
        if (!sampleDir.exists())
        {
            throw new Exception("The sample directory does not exist.  Looking for it at: "+path);
        }
        if (!sampleDir.isDirectory())
        {
            throw new Exception("The sample directory is not a directory.  Looking for it at: "+path);
        }
        File[] children = sampleDir.listFiles();
        for (File child : children)
        {
            String childName = child.getName();
            if (childName.endsWith(".xml") || childName.endsWith(".xsd"))
            {
                FileCache fc = FileCache.createFromFile(childName, child);
                ht.put(childName, fc);
            }
        }
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
    }
    else
    {
        throw new Exception("Action not implemented: "+act);
    }
%>
