<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    String enc  = wr.defParam("enc","UTF-8");
    String tag  = wr.defParam("tag","ExtendedAttributes");
    String pageSource = wr.defParam("pageSource","");
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
        seekAndDestroy(d.getDocumentElement(), tag);
        pageSource = d.convertToString();
    }

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>XML Tag Stripper</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>XML Tag Stripper</h1>
<form action="xmlstrip.jsp" method="post">
  <textarea name="pageSource" cols="100" rows="30"><% wr.writeHtml(pageSource); %></textarea><br>
  <input type="submit" value="Remove Tags Named:">
  <input type="text" name="tag" value="<% wr.writeHtml(tag); %>">
  character encoding: <input type="text" name="enc" value="<%= enc %>">
</form>

<hr>

<p><font size="-1">Cut and paste the XML into the edit box above.
Enter the name of the tag that you want removed. Press "Remove Tags Named"
button.  It will search for all tags with that name, and remove them
as well as all tags that are children of that tag.</p>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<%@ include file="functions.jsp"%>
