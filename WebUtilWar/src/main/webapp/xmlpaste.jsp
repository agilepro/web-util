<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="org.workcast.wu.DOMFace"
%><%

    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.defParam("f", "");


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>XML Editor - Paste Value</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>XML Editor - Paste Value</h1>
<hr>
<p><form action="xmlpasteAction.jsp" method="POST">
   <input type="submit" name="act" value="Parse Value"><br/>
   <textarea name="value" cols="80" rows="20"></textarea><br/>
   Name for this file: <input type="text" name="f" value="<% wr.writeHtml(f); %>"><br/>
   <input type="submit" name="act" value="Cancel">
   </form>

   <p>Paste XML into the edit box.  The application
   parse it as long as it is well formed XML.</p>
<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
