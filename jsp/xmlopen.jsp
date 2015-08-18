<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="org.workcast.wu.WebRequest"
%><%

    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    String f = wr.defParam("f", "");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>XML Editor - Open Web Resource</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>XML Editor - Open Web Resource</h1>
<hr>
<p><form action="xmlopenAction.jsp" method="POST">
   <input type="submit" name="act" value="Load From URL">
   <input type="text" name="url" value="" size="50"><br/>
   Username: <input type="text" name="user" value=""> Password: <input type="text" name="user" value=""><br/>
   Name for this file: <input type="text" name="f" value="<% wr.writeHtml(f); %>">
   Character Set: <input type="text" name="charset" value="UTF-8"><br/>
   <br/>
   <input type="submit" name="act" value="Load From Local File">
   Path to file: <input type="text" name="path" value="">

   <input type="submit" name="act" value="Cancel">
   </form>

   <p>Enter the URL to an XML resource available on the web.  The application
   will fetch the XML and parse it as long as the resource being fetched is
   well formed XML.</p>
<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
