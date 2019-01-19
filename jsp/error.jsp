<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page isErrorPage="true"
%><%@page import="org.workcast.wu.WebRequest"
%><%@page import="java.io.PrintWriter"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);

    if (exception == null)
    {
        exception = new Exception("<<Unknown exception arrived at the error page ... this should never happen. The exception variable was null.>>");
    }
    String msg = exception.toString();
%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD><TITLE>JSP Test</TITLE></HEAD>
<BODY BGCOLOR="#FDF5E6">
<H1>Error</H1>
<ul>
<%
        Throwable t = exception;
        while (t!=null) {
            wr.write("\n<li>");
            wr.writeHtmlWithLines(t.toString());
            wr.write("</li>");
            t = t.getCause();
        }
%>
</ul>
<hr>
<a href="index.htm">Main</a>
<pre>
<% out.flush(); %>
<% exception.printStackTrace(new PrintWriter(out)); %>
</pre>
</BODY>
</HTML>