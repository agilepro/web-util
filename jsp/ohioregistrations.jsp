<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.util.List"
%><%@page import="java.util.ArrayList"
%><%@page import="java.io.Writer"
%><%@page import="com.purplehillsbooks.streams.HTMLWriter"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="com.purplehillsbooks.xml.Mel"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String enc  = request.getParameter("enc");
    if (enc==null) {
        enc = "UTF-8";
    }
    String path = "http://www.voterfind.com/lorainoh/vtrpolldetails.aspx?idnum=";

    String valStart  = request.getParameter("s");
    String valEnd  = request.getParameter("e");
    
    int numStart = (int) Mel.safeConvertLong(valStart);
    int numEnd = (int) Mel.safeConvertLong(valEnd);
    
    if (numEnd > numStart+100) {
        numEnd = numStart+100;
    }
    
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
<h1>Listing of Ohio Registrations</h1>

<form ohioregistrations.jsp>
Start Registration Num: <input type="text" name="s" value="<%=numStart%>"> to 
   <input type="text" name="e" value="<%=numEnd%>"> 
   <input type="submit" value="Fetch List">
</form>
<pre>
<%
    if (numStart>0) {
        for (int i=numStart; i<numEnd+1; i++) {
            //out.write("\nPage "+i+"\n\n");
            dumpReg(path, i, out);
        }
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

    public void dumpAll(String path, Writer out) throws Exception {
        List<String> res = parseFile(path);
        for (String line : res) {
            HTMLWriter.writeHtml(out, line);
            out.write("\n");
        }
    }
     
    public void dumpReg(String path, int num, Writer out) throws Exception {
        List<String> res = parseFile(path+num);
        boolean isAName = false;
        boolean isFirstLine = false;
        boolean readySecondLine = false;
        boolean isSecondLine = false;
        boolean isBirthYear = false;
        String name = "";
        String firstLine = "";
        String secondLine = "";
        String birthYear = "";
        for (String line : res) {
            if (isAName) {
                name = line;
                isAName = false;
            }
            else if (isFirstLine) {
                firstLine = line;
                isFirstLine = false;
                readySecondLine = true;
            }
            else if (readySecondLine) {
                isSecondLine = true;
                readySecondLine = false;
            }
            else if (isSecondLine) {
                secondLine = line;
                isSecondLine = false;
            }
            else if (isBirthYear) {
                birthYear = line;
                isBirthYear = false;
            }
            else if (line.indexOf("span id=\"lblname\"")>0) {
                isAName = true;
            }        
            else if (line.indexOf("span id=\"lblres\"")>0) {
                isFirstLine = true;
            }        
            else if (line.indexOf("span id=\"lblbirthyear\"")>0) {
                isBirthYear = true;
            }        
            else if (line.indexOf("span id=\"lblfullvot\"")>0) {
                HTMLWriter.writeHtml(out, Integer.toString(num));
                out.write(",");
                writeClean(out, name);
                out.write(",");
                writeClean(out, firstLine);
                out.write(",");
                writeClean(out, secondLine);
                out.write(",");
                writeClean(out, birthYear);
                out.write("\n");
                name = "";
                firstLine = "";
                secondLine = "";                
                birthYear = "";   
                out.flush();                
            }
        }
    }
    
    
    public void writeClean(Writer out, String val) throws Exception {
        if (val.startsWith("<")) {
            return;
        }
        while(val.indexOf("  ")>0) {
            val = val.replace("  "," ");
        }
        while(val.indexOf(",")>0) {
            val = val.replace(",","");
        }
        HTMLWriter.writeHtml(out, val);
    }
%>
