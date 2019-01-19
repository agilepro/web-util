<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.io.File"
%><%@page import="java.util.List"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.WebRequest"
%><%@page import="com.purplehillsbooks.unbuilder.FileInfo"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String enc  = request.getParameter("enc");
    if (enc==null) {
        enc = "UTF-8";
    }
    
    File sourceFolder = new File("c:/beanstalk/bpm/artifacts");
    File objectFolder = new File("c:/CD-IMG/11.4.1/");
    

%>
<html>
<head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" 
      integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
</head>
<body>

<h1>UN-Builder</h1>

<p>Utility to examine a source system, and a final output, and figure out what came from where.  
Will be reading files from 
<%= sourceFolder %>.
</p>


<table class="table">
<tr><td>Path</td><td>Name</td><td>Size</td><td>Checksum</td></tr>
<%

    List<FileInfo> allSource = FileInfo.findAllFiles(sourceFolder);
    
    FileInfo.sortByName(allSource);
    
    for (FileInfo fi : allSource) {
        out.flush();
        %><tr><td><%= fi.path %></td><td><%= fi.getName() %></td><td><%= fi.getSize() %></td><td><%= fi.getChecksum() %></td></tr><%
    }

%>

</body>
</html>
