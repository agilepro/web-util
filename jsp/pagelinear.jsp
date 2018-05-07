<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.util.List"
%><%@page import="java.util.ArrayList"
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
    long startTime = System.currentTimeMillis();
    List<String> pageSource =  new ArrayList<String>();
    if (path!=null && path.length()>=5) {
        pageSource = parseFile(path);
    }
    long fetchDuration = System.currentTimeMillis() - startTime;

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Page Linear Display</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Page Linear Display</h1>
<hr>
<form action="pagesource.jsp" method="get">
  <input type="text" name="path" value="<%= path %>" size=80>
  <input type="submit" value="Get">
  <input type="text" name="enc" value="<%= enc %>">
</form>

<%

    if (pageSource.size()>0) {
        out.write("<textarea cols=\"120\" rows=\"40\">");
        int amtTotal = 0;
        for (String line : pageSource) {
            wr.writeHtml(line);
            wr.writeHtml("\n");
            amtTotal += line.length();
        }
        
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
        wr.write("</a>  &nbsp; <a href=\"pagesource.jsp?path=");
        wr.write(URLEncoder.encode(path, "UTF-8"));
        wr.write("\">Regular Source</a></p>");
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

<%!

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
%>
