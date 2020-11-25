<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    
    String getContextPathStr = request.getContextPath();
    String getPathInfoStr = request.getPathInfo();
    String getPathTranslatedStr = request.getPathTranslated();
    String getQueryStringStr = request.getQueryString();
    String getRequestURIStr = request.getRequestURI();
    String getRequestURLStr = request.getRequestURL().toString();
    String getServletPathStr = request.getServletPath();

    
%>
<html>
<head>

</head>

<body>

<hr>
<table>
<tr><td> request.getContextPath();  </td><td> <%wr.writeHtml(getContextPathStr);%> </td></tr>
<tr><td> request.getPathInfo();  </td><td> <%wr.writeHtml(getPathInfoStr);%> </td></tr>
<tr><td> request.getPathTranslated();  </td><td> <%wr.writeHtml(getPathTranslatedStr);%> </td></tr>
<tr><td> request.getQueryString();  </td><td> <%wr.writeHtml(getQueryStringStr);%> </td></tr>
<tr><td> request.getRequestURI();  </td><td> <%wr.writeHtml(getRequestURIStr);%> </td></tr>
<tr><td> request.getRequestURL();  </td><td> <%wr.writeHtml(getRequestURLStr);%> </td></tr>
<tr><td> request.getServletPath();  </td><td> <%wr.writeHtml(getServletPathStr);%> </td></tr>
</table>

</body>
</html>
