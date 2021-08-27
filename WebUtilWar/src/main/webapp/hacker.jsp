<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.net.URLDecoder"
%><%@page import="java.util.Vector"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String enc  = request.getParameter("enc");
    if (enc==null) {
        enc = "UTF-8";
    }
    String url = request.getParameter("url");
    if (url==null)
    {
        url = "";
    }
%>
<html>
<head>
  <title>URL Hacker</title>
  <script src="js/angular.js"></script>
  <link href='https://fonts.googleapis.com/css?family=Montserrat:200,400,700' rel='stylesheet' type='text/css'>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.srctext = "";

    });
</script>
</head>
<body ng-app="genieApp" ng-controller="genieCtrl">
<div class="mainFrame">

<h1>URL Hacker</h1>

<form action="hacker.jsp" method="get">
  <input type="text" name="url" value="<%wr.writeHtml(url);%>" size=80>
  <input type="submit" value="Create Form">
</form>
<hr/>
<%
    if (url.length()<4) {
%>
        <p>Enter the URL of a page on the web.
           This this break the URL in to a form that makes it easy to
           subsatitute other values in.</p>
           </p>

<% wr.invokeJSP("tileBottom.jsp"); %>
           
        </body>
        </html>
<%
        return;
    }


    Vector params = new Vector();
    Vector values = new Vector();
    int questionPos = url.indexOf("?");
    String partBeforeQuestion = url;
    if (questionPos>0)
    {
        partBeforeQuestion = url.substring(0,questionPos);

        String rest = url.substring(questionPos+1)+"&";
        int amppos = rest.indexOf('&');
        int start = 0;
        while (amppos>0)
        {
            String qpart = rest.substring(start, amppos);
            int equalsPos = qpart.indexOf('=');
            String qparam = qpart;
            String qval = "";
            if (equalsPos>0)
            {
                qparam = qpart.substring(0,equalsPos);
                qval = qpart.substring(equalsPos+1);
            }
            params.add(URLDecoder.decode(qparam, "UTF-8"));
            values.add(URLDecoder.decode(qval, "UTF-8"));
            start = amppos+1;
            amppos = rest.indexOf('&', start);
        }
    }

%>

<h3>Form for GET requests</h3>
<form action="<%wr.writeHtml(partBeforeQuestion);%>">
<%

    for (int i=0; i<params.size(); i++)
    {
        String qparam = (String) params.elementAt(i);
        String qval = (String) values.elementAt(i);
%>
    <%wr.writeHtml(qparam);%>:  <input type="text" name="<%wr.writeHtml(qparam);%>"
            value="<%wr.writeHtml(qval);%>" size="80"><br/>
<%
    }

%>
<input type="submit" value="GET">
</form>
<hr/>
<h3>Form for POST requests</h3>
<form action="<%wr.writeHtml(partBeforeQuestion);%>" method="post">
<%

    for (int i=0; i<params.size(); i++)
    {
        String qparam = (String) params.elementAt(i);
        String qval = (String) values.elementAt(i);
%>
    <%wr.writeHtml(qparam);%>:  <input type="text" name="<%wr.writeHtml(qparam);%>"
            value="<%wr.writeHtml(qval);%>" size="80"><br/>
<%
    }

%>
<input type="submit" value="POST"/>
</form>

<% wr.invokeJSP("tileBottom.jsp"); %>

</div>
</body>
</html>
