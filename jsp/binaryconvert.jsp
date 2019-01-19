<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    String enc  = wr.defParam("enc","UTF-8");
    String pageSource = wr.defParam("pageSource","");
    StringBuffer result = new StringBuffer();
    int pageLen = pageSource.length();
    int i=0;
    while (i<pageLen-1) {
        char ch1 = pageSource.charAt(i);
        i++;
        char ch2 = pageSource.charAt(i);
        i++;
        int val=0;
        if (ch1>='0' && ch1<='9') {
            val = 16* (int) (ch1-'0');
        } else if (ch1>='A' && ch1<='F') {
            val = 10 + 16* (int) (ch1-'A');
        }
        if (ch2>='0' && ch2<='9') {
            val = val + (int) (ch2-'0');
        } else if (ch2>='A' && ch2<='F') {
            val = val + 10 + (int) (ch2-'A');
        }
        result.append((char) val);
    }


%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>XML Formatter</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Binary Converter</h1>
<form action="binaryconvert.jsp" method="post">
  <textarea name="pageSource" cols="100" rows="30"><% wr.writeHtml(pageSource); %></textarea><br>
  <input type="submit" value="Reformat XML">
  character encoding: <input type="text" name="enc" value="<%= enc %>">
</form>

<hr>

<p><font size="-1">Cut and paste the XML into the edit box above, then
press "Format XML" to have that XML read, parsed, and regenerated.
This will only work on well formed XML.  If the XML is not well formed,
you will get a parsing error, so this is also a way to check if the
XML is well formed.</p>
<pre>
<% wr.writeHtml(result.toString()); %>
</pre>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<%@ include file="functions.jsp"%>
