<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
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

<h1>UN-Builder - LOADING</h1>

<p>Utility to examine a source system, and a final output, and figure out what came from where.  
Will be reading files from 
<%= sourceFolder %>.
</p>


<h2>Generating...</h2>
<%

    File dest = new File("c:/temp/sourceFileUsage.txt");
    
    FileOutputStream fos = new FileOutputStream(dest);
    Writer fw = new OutputStreamWriter(fos, "utf-8");
    
    fw.write("Source File Usage Report");
    fw.write("\n------------------------");
    fw.write("\nThis is the result of reading the entire collection of source files");
    fw.write("\nfrom : "+sourceFolder);
    fw.write("\nAnd then reading all the file in the cd image");
    fw.write("\nfrom : "+objectFolder);
    fw.write("\nThen each folder in the source tree is visited, and each file is checked");
    fw.write("\nfor the same named file in the cd image.  The files are compred using a");
    fw.write("\nchecksum that ignores whitespace/line feed differences.");
    fw.write("\nAn '=' symbol indicates that the checksum matches, '!' symbol means they differ.");
    fw.write("\n");
    fw.write("\nSource files might not be in the build for several reasons:");
    fw.write("\n1. they could be build files themselves like ant scripts,");
    fw.write("\n2. they might be files that are converted to another form, like java-->class,");
    fw.write("\n3. they might be source documentation not needed for run time,");
    fw.write("\n4. some are test files used in testing but not included in the build,");
    fw.write("\n5. MOST of the files are simply left over from previous versions no longer needed, or");
    fw.write("\n6. Checked in versions of build results which are now outdated and don't match");
    fw.write("\n");
    fw.write("\nRemember that the source folders often have duplicates of files with a given name");
    fw.write("\nand so some copies of that will never be used.  Also, there are files with common");
    fw.write("\nnames like 'index.html' which are naturally used in many places, both in the source");
    fw.write("\nand in the CD image.");
    fw.write("\n");
    fw.write("\nThe output is arranged by folder because this might help in identifying entire folders");
    fw.write("\nthat were and should be copied, or entire folders of duplicates.");
    fw.write("\n--------------------------------");
    fw.write("\n");

    int totalUnusedFiles = 0;
    
    List<String> allParents = findAllParents(allSource);
    
    for (String parent: allParents) {
        
        fw.write("\n\n");
        fw.write(parent);
        List<FileInfo> notUsed = new ArrayList<FileInfo>();
        List<FileInfo> used = new ArrayList<FileInfo>();
        List<FileInfo> matching = new ArrayList<FileInfo>();
        List<FileInfo> notMatching = new ArrayList<FileInfo>();
        Set<String> pathSet = new HashSet<String>();
        
        for (FileInfo fi : allSource) {
            
            if (parent.equals(fi.folder)) {

                long checksum = fi.getChecksum();
                String sourceName = fi.getName();
                boolean ignoreChecksum = false;
                if (sourceName.endsWith(".java")) {
                    int tailPos = sourceName.length()-4;
                    sourceName = sourceName.substring(0,tailPos) + "class";
                    ignoreChecksum = true;
                }
                int count = 0;
                for (FileInfo fi2: allObjects) {
                    
                    if (sourceName.equalsIgnoreCase(fi2.getName())) {
                        pathSet.add(fi2.folder);
                        if (ignoreChecksum || checksum == fi2.getChecksum()) {
                            matching.add(fi2);
                            count++;
                        }
                        else {
                            notMatching.add(fi2);
                        }
                    }
                }
                if (count==0) {
                    notUsed.add(fi);
                }
                else {
                    used.add(fi);
                }
            }
        }
        
        totalUnusedFiles += notUsed.size();
        fw.write("\n\n    NOT USED: "+notUsed.size()+", USED: "+used.size());
        for (FileInfo fi6: notUsed) {
            fw.write("\n        "+fi6.getName());
        }
        for (String path : pathSet) {
            fw.write("\n\n    "+path);
            for (FileInfo fi3: matching) {
                if (path.equals(fi3.folder)) {
                    String modName = fi3.getName();
                    if (modName.endsWith(".class")) {
                        fw.write("\n        x "+modName);
                    }
                    else {
                        fw.write("\n        = "+modName);
                    }
                }
            }
            //for (FileInfo fi4: notMatching) {
            //    if (path.equals(fi4.folder)) {
            //        fw.write("\n        ! "+fi4.getName());
            //    }
            //}
        }
        
        

        
        
    }
    fw.write("\n\n----------------------------------");
    fw.write("\nSource file scanned: "+ allSource.size());
    fw.write("\nNot used in the CD image in exact same form: "+totalUnusedFiles);
    fw.write("\n");
    fw.flush();
    fw.close();
    fos.close();
    
%>
<h2><%= allSource.size() %> source file scanned, <%= totalUnusedFiles %> are not used in the CD image in exact same form.</h2>

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
