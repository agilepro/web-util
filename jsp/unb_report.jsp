<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.io.File"
%><%@page import="java.io.FileOutputStream"
%><%@page import="java.io.OutputStreamWriter"
%><%@page import="java.util.List"
%><%@page import="java.util.ArrayList"
%><%@page import="java.util.Set"
%><%@page import="java.util.HashSet"
%><%@page import="java.util.Collections"
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
    
    File sourceFolder = new File("c:/beanstalk/bpm");
    File objectFolder = new File("c:/CD-IMG/11.4.1/");
    //HttpSession session = request.getSession();
    
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
<body>

<h1>UN-Builder - CD Image Report</h1>

<p>Utility to examine a source system, and a final output, and figure out what came from where.  
Will be reading files from 
<%= sourceFolder %>.
</p>


<h2>Generating...</h2>
<ul>
<%
    out.flush();
    File dest = new File("c:/temp/analysis.txt");
    
    FileOutputStream fos = new FileOutputStream(dest);
    Writer fw = new OutputStreamWriter(fos, "utf-8");
    int totalNotFound = 0;
    
    List<String> allParents = findAllParents(allObjects);
    
    for (String parent: allParents) {
        
        out.write("\n<li>"+parent+"</li>");
        out.flush();
        
        fw.write("\n\n");
        fw.write(parent);
        
        for (FileInfo fi : allObjects) {
            
            if (parent.equals(fi.folder)) {
                String sourceName = fi.getName();
                String name = fi.getName();
                boolean ignoreChecksum = false;
                if (name.endsWith(".class")) {
                    int tailPos = name.length()-5;
                    name = name.substring(0,tailPos) + "java";
                    ignoreChecksum = true;
                }
                
                long checksum = fi.getChecksum();
                fw.write("\n\n    "+sourceName);
                boolean found = false;
                
                for (FileInfo fi2: allSource) {
                    if (name.equalsIgnoreCase(fi2.getName())) {
                        fw.write("\n       ");
                        if (ignoreChecksum) {
                            fw.write("x ");
                        }
                        else if (checksum == fi2.getChecksum()) {
                            fw.write("= ");
                            found = true;
                        }
                        else {
                            fw.write("! ");
                        }
                        fw.write(fi2.path.toString());
                    }
                }
                if (!found && !ignoreChecksum) {
                    totalNotFound++;
                    fw.write("\n       ** no matching file in source **");
                }
            }
        }
    }
    fw.write("\n\n--------------------------------------");
    fw.write("\nTotal number of files: "+allObjects.size());
    fw.write("\nTotal number of unfound files: "+totalNotFound);
    fw.flush();
    fw.close();
    fos.close();
    
%>
</ul>
<h2><%= allObjects.size() %> object files found</h2>

<div style="padding:20px">
<a href="unbuilder.jsp"><button class="btn btn-primary">Return</button></a>
</div>

</body>
</html>

<%!

public List<String> findAllParents(List<FileInfo> list) {
    Set<String> roo = new HashSet<String>();
    for (FileInfo fi : list) {
        String parent = fi.path.getParentFile().toString();
        roo.add(parent);
    }
    List<String> res = new ArrayList<String>();
    for (String val : roo) {
        res.add(val);
    }
    Collections.sort(res);
    return res;
}


%>
