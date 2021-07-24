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

        %>
        <html>
        <head>
            <title>Web Page Cleaner</title>
            <link href="mystyle.css" rel="stylesheet" type="text/css"/>
        </head>
        <body BGCOLOR="#E6FDF5">
        <h1>Random ID</h1>
        
        <%! static long lastTime = 0; %>
        <%
            
            long time = System.currentTimeMillis()/1000;
            if (time<=lastTime) {
                time = lastTime+1;
            }
            lastTime = time;
            char[] zcode = new char[] { '0','1','2','3','4','5','6','7','8','9','a',
                             'b','c','d','e','f','g','h','i','j','k','l','m','n','o',
                             'p','q','r','s','t','u','v','w','x','y','z'};
            StringBuffer newId = new StringBuffer();
            while (time>0) {
                long offset = time%36;
            	newId.append(zcode[(int)offset]);
            	time = time / 36L;
            }
            
        %>
        <p>here is it: <%=newId.toString()%></p>
        <hr/>
        <% wr.invokeJSP("tileBottom.jsp"); %>
        </body>
        </html>

