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
    String path = wr.defParam("path", "");

    String pageSource = fetchDoc(session, request);
    String pageURL = (String) session.getAttribute("url");
    int amtTotal = 0;
    if (pageSource != null) {
        amtTotal = pageSource.length();
    }


%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Page Source Display</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Swenson Utilities - Set Up & Load Page</h1>
<%

    makeTabs(out, "Set Up");

%>
<hr>
<form action="setup.jsp" method="get">
  <input type="text" name="path" value="<%wr.writeHtml(pageURL); %>" size=80>
  <input type="submit" value="Get">
  <input type="text" name="enc" value="<%= enc %>">
</form>

<%

    if (pageSource != null)
    {
        wr.write("<p>Characters: ");
        wr.write(Integer.toString(amtTotal));
        wr.write("</p>\n<p>URL: <a target=\"other\" href=\"");
        wr.writeHtml(pageURL);
        wr.write("\">");
        wr.writeHtml(pageURL);
        wr.write("</a></p>");
    }

%>

<hr>
<p><font size="-1">This page can be help in debugging web applications.
Enter the URL into the box.  The page will be retrieved and then displayed
in the browser.  This conversion to displayable form is done <i>before</i>
the browser attempts to act on the data, which in some cases alters it.
For example, if XML is malformed, Internet Explorer will refuse to show you
the malformed XML source.  This page will retrieve the XML, and then display
it so that the browser is not involved in trying to interpret the XML.</p>

<p>Enter the desired page encoding for conversion from bytes to characters into
the second box if you know the page to be encoded in something other than UTF-8.</p>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<%@ include file="functions.jsp"%>
