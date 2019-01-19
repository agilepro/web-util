<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.io.File"
%><%@page import="java.util.ArrayList"
%><%@page import="java.util.List"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.WebRequest"
%><%@page import="com.purplehillsbooks.unbuilder.FileInfo"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String fname  = request.getParameter("fname");
    
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

<h1>UN-Builder: <%wr.writeHtml(fname);%></h1>


<p>Displays all the results for the file <%=fname%>.</p>

<div style="padding:20px">
<a href="unbuilder.jsp"><button class="btn btn-primary">Return</button></a>
</div>

<table class="table">
<tr><td></td><td>Path</td><td>File Name</td><td>Size</td><td>Checksum</td></tr>
<%
    int sourceCount = 0;
    for (FileInfo fi : allSource) {
        if (fname.equalsIgnoreCase(fi.getName())) {
            sourceCount++;
            File parent = fi.path.getParentFile();
            out.flush();
            %><tr><td>S</td><td><a href="unb_src_path.jsp?path=<%wr.writeURLData(parent.toString());%>"><%wr.writeHtml(parent.toString());%></a></td><td><%wr.writeHtml(fi.getName());%></td><td><%= fi.getSize() %></td><td><%= fi.getChecksum() %></td></tr><%
        }
    }
    int objectCount = 0;
    for (FileInfo fi : allObjects) {
        if (fname.equalsIgnoreCase(fi.getName())) {
            objectCount++;
            File parent = fi.path.getParentFile();
            out.flush();
            %><tr><td>O</td><td><a href="unb_obj_path.jsp?path=<%wr.writeURLData(parent.toString());%>"><%wr.writeHtml(parent.toString());%></a></td><td><%wr.writeHtml(fi.getName());%></td><td><%= fi.getSize() %></td><td><%= fi.getChecksum() %></td></tr><%
        }
    }

%>
</table>

<ul>
<li><%wr.writeHtml(fname);%> appears <%=objectCount%> in the CD image</li>
<li>It appears <%=sourceCount%> in the source repository</li>
</ul>

</body>
</html>
