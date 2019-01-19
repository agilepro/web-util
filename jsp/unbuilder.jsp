<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.io.File"
%><%@page import="java.util.ArrayList"
%><%@page import="java.util.List"
%><%@page import="java.util.HashSet"
%><%@page import="java.util.Set"
%><%@page import="java.util.Collections"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.WebRequest"
%><%@page import="com.purplehillsbooks.unbuilder.FileInfo"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String filter  = request.getParameter("filter");
    if (filter==null) {
        filter="";
    }
    
    File sourceFolder = new File("c:/beanstalk/bpm/artifacts");
    File objectFolder = new File("c:/CD-IMG/11.4.1/");
    
    List<FileInfo> allSource = null;
    Object loadedFiles = session.getAttribute("loadedFiles");
    if (loadedFiles==null) {
        allSource = new ArrayList<FileInfo>();
        session.setAttribute("loadedFiles", allSource);
    }
    else {
        allSource = (List<FileInfo>)loadedFiles;
    }
    List<FileInfo> allObjects = null;
    Object objectFiles = session.getAttribute("objectFiles");
    if (loadedFiles==null) {
        allObjects = new ArrayList<FileInfo>();
        session.setAttribute("objectFiles", allObjects);
    }
    else {
        allObjects = (List<FileInfo>)objectFiles;
    }

%>
<html>
<head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" 
      integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
</head>
<body style="padding:10px">

<h1>UN-Builder</h1>


<p>Utility to examine a source system, and a final output, and figure out what came from where.  
Will be reading files from 
<%wr.writeHtml(sourceFolder.toString()); %>.
</p>

<div style="padding:20px">
<a href="unb_load.jsp"><button class="btn btn-primary">Load</button></a>
<form method="get" src="unbuild.jsp">
<input type="text" name="filter" value="<%wr.writeHtml(filter);%>">
<input type="submit" class="btn btn-primary" value="Filter More">
</form>
<a href="unb_report.jsp"><button class="btn btn-primary">Output Files Source</button></a>
<a href="unb_report2.jsp"><button class="btn btn-primary">Source File Usage</button></a>
</div>

<table class="table">
<tr><td>Path</td><td>Name</td><td>Size</td><td>Checksum</td></tr>
<%

    FileInfo.sortByName(allObjects);
    Set<String> listVals = new HashSet<String>();
    for (FileInfo fi : allObjects) {
        if (!listVals.contains(fi.getName())) {
            listVals.add(fi.getName());
        }
    }
    
    //Collections.sort(listVals);
    int count=100;
    for (String name: listVals) {
        if (name.indexOf(filter)>=0) {
            if (count-- >0) {
                out.flush();
                %><tr><td>
                    <a href="unb_file.jsp?fname=<%wr.writeURLData(name);%>"><%wr.writeHtml(name);%></td></tr><%
            }
        }
    }

%>

</body>
</html>
