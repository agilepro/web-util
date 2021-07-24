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
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="com.purplehillsbooks.unbuilder.FileInfo"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String enc  = request.getParameter("enc");
    if (enc==null) {
        enc = "UTF-8";
    }
    
    File sourceFolder = new File("c:/beanstalk/bpm");
    File objectFolder = new File("c:/CD-IMG/11.4.1-exploded/");
    //HttpSession session = request.getSession();
    
    Object loadedFiles = session.getAttribute("loadedFiles");
    Object objectFiles = session.getAttribute("objectFiles");

%>
<html>
<head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" 
      integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
</head>
<body>

<h1>UN-Builder - LOADING</h1>

<p>Utility to examine a source system, and a final output, and figure out what came from where.  
Will be reading files from 
<%= sourceFolder %>.
</p>


<h2>Reading...</h2>
<%
    out.flush();

    List<FileInfo> allSource = FileInfo.findAllFiles(sourceFolder);    
    FileInfo.sortByName(allSource);   
    session.setAttribute("loadedFiles", allSource);
%>
<h2><%= allSource.size() %> source files found</h2>
<%
    out.flush();
    List<FileInfo> allObjects = FileInfo.findAllFiles(objectFolder);    
    FileInfo.sortByName(allObjects);   
    session.setAttribute("objectFiles", allObjects);
    
%>
<h2><%= allObjects.size() %> object files found</h2>

<div style="padding:20px">
<a href="unbuilder.jsp"><button class="btn btn-primary">Return</button></a>
</div>

</body>
</html>
