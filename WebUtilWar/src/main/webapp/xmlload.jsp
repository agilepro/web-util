<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="com.purplehillsbooks.xml.Mel"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    Mel mainDoc = (Mel) session.getAttribute("mainDoc");

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>XML Editor</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>XML Editor</h1>
<p><form action="xmleditAction.jsp" method="POST">
   <input type="submit" name="act" value="Load">
   <input type="submit" name="act" value="Paste">
   <input type="submit" name="act" value="Clear">
   <input type="submit" name="act" value="Reformat">
   <input type="submit" name="act" value="Generate Schema">
   </form>
<hr>
<% if (mainDoc != null) { %>
<pre><% mainDoc.writeToOutputStream(wr.getBufferedOutputStream()); wr.flush(); %></pre>
<% } else { %>
<p>No XML document is loaded into the editor.  Use the load option to bring in a document.</p>
<% } %>
<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
