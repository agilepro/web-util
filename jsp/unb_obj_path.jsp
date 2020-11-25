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
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="com.purplehillsbooks.unbuilder.FileInfo"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String path  = request.getParameter("path");
    File pathFile = new File(path);
    String parentPath = pathFile.getParentFile().toString();
    
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

<h1>UN-Builder: <%wr.writeHtml(path);%></h1>


<p>Displays all the results for the path <%=path%>.</p>

<div style="padding:20px">
<a href="unbuilder.jsp"><button class="btn btn-primary">Return</button></a>
<a href="unb_obj_path.jsp?path=<%wr.writeURLData(parentPath);%>"><%wr.writeHtml(parentPath);%></a>
</div>

<table class="table">
<tr><td></td><td>Path</td><td>Size</td><td>Checksum</td></tr>
<%
    int sourceCount = 0;
    for (FileInfo fi : allObjects) {
        String p1 = fi.path.getParentFile().toString();
        if (path.equalsIgnoreCase(p1)) {
            sourceCount++;
            out.flush();
            %><tr><td>O</td><td><a href="unb_file.jsp?fname=<%wr.writeURLData(fi.getName());%>"><%wr.writeHtml(fi.getName());%></td><td><%= fi.getSize() %></td><td><%= fi.getChecksum() %></td></tr><%
        }
    }


%>
</table>

<ul>
<li><%wr.writeHtml(path);%> contains <%=sourceCount%> files</li>
</ul>

</body>
</html>
