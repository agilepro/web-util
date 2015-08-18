<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.security.KeyStore"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.List"
%><%@page import="java.util.Properties"
%><%@page import="org.workcast.wu.WebRequest"
%><%

    WebRequest wr = WebRequest.getOrCreate(request, response, out);
%>

<html>
<head>
</head>
<body>
<h3>Installed Keys</h3>
<p>Here are list of the keys stored in the keystore on the JVM this page is running on.</p>

<ul>
<%


    KeyStore keyStore = KeyStore.getInstance(KeyStore.getDefaultType());
    int numKeys = keyStore.size();

    %><li>Has <%=numKeys%> keys. </li><%


    if (numKeys>0) {
        Enumeration<String> aliasEnum = keyStore.aliases();
        while (aliasEnum.hasMoreElements()) {
            String alias = aliasEnum.nextElement();

            %><li><%
            wr.writeHtml(alias);
            %></li><%

        }
    }

%>
</ul>

</body>
</html>
