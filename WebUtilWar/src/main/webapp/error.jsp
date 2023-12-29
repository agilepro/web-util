<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page isErrorPage="true"
%><%@page import="org.workcast.wu.SimpleWebRequest"
%><%@page import="java.io.PrintWriter"
%><%
    SimpleWebRequest wr = new SimpleWebRequest(request, response, out);

    if (exception == null)
    {
        exception = new Exception("<<Unknown exception arrived at the error page ... this should never happen. The exception variable was null.>>");
    }
    String msg = exception.toString();
%>


<!DOCTYPE HTML>
<html>

<head>
  <title>Error Page</title>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">
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

<div style="height:400px"></div>
<% wr.invokeJSP("tileBottom.jsp"); %>

</div>
</body>
</html>
