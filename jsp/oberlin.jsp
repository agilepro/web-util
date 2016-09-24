<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.util.List"
%><%@page import="java.util.ArrayList"
%><%@page import="java.io.Writer"
%><%@page import="org.workcast.streams.HTMLWriter"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String enc  = request.getParameter("enc");
    if (enc==null) {
        enc = "UTF-8";
    }
    String path = "http://new.oberlin.edu/home/directory.dot?type=Student";
    int lastSlash = path.lastIndexOf("/");
    if (lastSlash<0) {
        throw new Exception("Hey, you have to have at least one slash in that URL!");
    }
    String basePath = path.substring(0, lastSlash+1);
%>
<html>
<head>
<style>
body
{
    font-family:"Helvetica";
    font-size:12px;
    background-color:#eeeeee;
    width:600px;
    margin-right:50px;
    margin-left:50px;
}
h1
{
    font-family:"Helvetica";
    color:darkblue;
}
h2
{
    font-family:"Helvetica";
    color:blue;
}
h3
{
    font-family:"Helvetica";
    color:green;
}
p
{
    font-family:"Helvetica";
    font-size:16px;
}
</style>
</head>

<body>
<h1>Listing of Oberlin Students</h1>

<pre>
<%
    for (int i=1; i<124; i++) {
        //out.write("\nPage "+i+"\n\n");
        dumpStudents("http://new.oberlin.edu/home/directory.dot?type=Student&pageNumber="+i, out);
    }
%>
</pre>
<hr>
<a href="<%=path%>">Go There</a>
<% wr.invokeJSP("tileBottom.jsp"); %>
<%!
    boolean outputMode = true;
    boolean showDebug = false;

    
    public List<String> parseFile(String path) throws Exception {
        List<String> output = new ArrayList<String>();
        URL testUrl = new URL(path);
        URLConnection uc = testUrl.openConnection();
        if (uc == null) {
            throw new Exception("Got a null URLConnection object!");
        }
        InputStream is = uc.getInputStream();
        if (is == null) {
            throw new Exception("Got a null content object!");
        }
        Reader r = new InputStreamReader(is, "UTF-8");
        boolean skipBefore = true;
        boolean skipAfter = true;
        
        StringBuffer currentTag = new StringBuffer();
        int ch = 0;
        boolean inTag = false;
        
        while ((ch = r.read()) >= 0) {
           
            if (ch != '<' && ch != '>') {
                currentTag.append((char)ch);
                continue;
            }
            if (inTag) {
                if (ch=='>') {
                    //found the end of a tag
                    currentTag.append((char)ch);
                    output.add(currentTag.toString());
                    currentTag.setLength(0);
                    inTag = false;
                }
            }
            else if (ch == '<') {
                String aLine = currentTag.toString().trim();
                if (aLine.length()>0) {
                    output.add(aLine);
                }
                currentTag.setLength(0);
                currentTag.append((char)ch);
                inTag = true;
            }
        }
        return output;
    }
    
    public void dumpStudents(String path, Writer out) throws Exception {
        List<String> res = parseFile(path);
        boolean isAName = false;
        for (String line : res) {
            if (isAName) {
                HTMLWriter.writeHtml(out, line);
                isAName = false;
                out.write("\n");
            }
            else if (line.indexOf("class=\"geor\"")>0) {
                isAName = true;
            }        
        }
    }
    
%>
