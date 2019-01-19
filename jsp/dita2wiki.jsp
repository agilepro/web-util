<%@pagecontentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
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

    String wikiVersion = "";
    if (pageSource.length()>5)
    {
        pageSource = stripIndent(pageSource);
        DOMFace d = null;
        try {
            d = DOMFace.parseString(pageSource);
        }
        catch (Exception e) {
            throw new Exception("The XML supplied could not be parsed.  Possibly it is not well formed XML.  "+e.toString(), e);
        }
        wikiVersion = dita2Wiki(d.getDocumentElement());
        pageSource = d.convertToString();
    }

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>DITA to Wiki Converter</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>DITA to Wiki Converter</h1>
<form action="dita2wiki.jsp" method="post">
  <textarea name="pageSource" cols="100" rows="20"><% wr.writeHtml(pageSource); %></textarea><br>
  <input type="submit" value="Convert to Wiki Format">
  character encoding: <input type="text" name="enc" value="<%= enc %>">
</form>
<form>
  <textarea name="wikiout" cols="100" rows="20"><% wr.writeHtml(wikiVersion); %></textarea><br>
</form>
<hr>

<p><font size="-1">Cut and paste the XHTML into the edit box above (html
the follows the strict rules of XML).
Enter the name of the tag that you want removed. Press "Convert to Wiki Format"
and the content in the html will be converted to a simple text format suitable
for use in a wiki</p>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<%@ include file="functions.jsp"%>
