<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.security.cert.X509Certificate"
%><%@page import="javax.net.ssl.HostnameVerifier"
%><%@page import="javax.net.ssl.HttpsURLConnection"
%><%@page import="javax.net.ssl.SSLContext"
%><%@page import="javax.net.ssl.SSLSession"
%><%@page import="javax.net.ssl.TrustManager"
%><%@page import="javax.net.ssl.X509TrustManager"
%><%@page import="org.workcast.wu.WebRequest"
%><%@page import="com.purplehillsbooks.streams.SSLPatch"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    String enc  = wr.defParam("enc","UTF-8");
    String path = wr.defParam("path","");
    String pageSource = null;
    long startTime = System.currentTimeMillis();
    int amtTotal = 0;
    if (path!=null && path.length()>=5)
    {
        SSLPatch.disableSSLCertValidation();

        pageSource = fetchDoc(path, enc);
        amtTotal = pageSource.length();
    }
    long fetchDuration = System.currentTimeMillis() - startTime;

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Page Source Display</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Page Source Display</h1>
<hr>
<form action="pagesource.jsp" method="get">
  <input type="text" name="path" value="<%= path %>" size=80>
  <input type="submit" value="Get">
  <input type="text" name="enc" value="<%= enc %>">
</form>

<%

    if (pageSource != null) {
        out.write("<textarea cols=\"120\" rows=\"40\">");
        wr.writeHtml(pageSource);
        wr.write("</textarea><p>Characters: ");
        wr.write(Integer.toString(amtTotal));
        long rate = 0;
        if (fetchDuration>0) {
            rate = ((long)amtTotal)*1000 / fetchDuration;
        }
        wr.write(", Time: "+fetchDuration+" ms, rate = "+rate+" bytes/sec");
        wr.write("</p>\n<p>URL: <a target=\"other\" href=\"");
        wr.writeHtml(path);
        wr.write("\">");
        wr.writeHtml(path);
        wr.write("</a>  &nbsp; <a href=\"pagelinear.jsp?path=");
        wr.write(URLEncoder.encode(path, "UTF-8"));
        wr.write("\">Linearized Source</a></p>");
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
