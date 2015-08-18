<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.File"
%><%@page import="java.io.FileInputStream"
%><%@page import="java.io.FileOutputStream"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.OutputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.mendocino.Mel"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.MemFile"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    String act = wr.reqParam("act");

    //hard-coded for now
    String projFolderLocation = "c:\\projects\\";

    if ("Link Another Project".equals(act))
    {
        String url = wr.reqParam("url");
        String pname = wr.reqParam("pname");
        Mel conFile = Mel.createEmpty("synchstatus", Mel.class);
        conFile.setAttribute("id", url);
        File projFolder = new File(projFolderLocation);
        File newChild = new File(projFolder,pname);
        if (newChild.exists())
        {
            throw new Exception("Project with the name '"+pname+"' already exists!");
        }
        newChild.mkdirs();
        File newConfig = new File(newChild, "synch_status.xml");
        OutputStream os = new FileOutputStream(newConfig);
        conFile.writeToOutputStream(os);
        os.flush();
        os.close();
    }
    else
    {
        throw new Exception("Action not implemented: "+act);
    }

    response.sendRedirect("projectFolder.jsp");

%>
