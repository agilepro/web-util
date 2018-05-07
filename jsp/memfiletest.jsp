<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.ByteArrayOutputStream"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.OutputStream"
%><%@page import="java.io.OutputStreamWriter"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="com.purplehillsbooks.streams.MemFile"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    String testCase = "This is sample text.";

    MemFile mf = new MemFile();
    OutputStream os = mf.getOutputStream();
    OutputStreamWriter osw = new OutputStreamWriter(os, "UTF-8");
    osw.write(testCase);
    osw.flush();
    osw.close();

    InputStream is = mf.getInputStream();
    byte[] buf = new byte[300];
    int len = is.read(buf);

    String res2 = "not set";

    if (len>0)
    {
        res2 = new String(buf, 0, len);
    }

    ByteArrayOutputStream baos = new ByteArrayOutputStream();
    mf.outToOutputStream(baos);

    String res3 = new String(baos.toByteArray(), "UTF-8");


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>XML Grinder</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>MemFile Test</h1>

<ul>
<li/><%= len %>
<li/><% wr.writeHtml(res2); %> - <% if (testCase.equals(res2)) { %>OK<% } %>
<li/><% wr.writeHtml(res3); %> - <% if (testCase.equals(res3)) { %>OK<% } %>
</ul>

</body>
</html>

