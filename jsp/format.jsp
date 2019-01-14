<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
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
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String enc  = request.getParameter("enc");
    if (enc==null) {
        enc = "UTF-8";
    }
    String value = request.getParameter("value");
    if (value==null) {
        value = "12345678";
    }
    String format = request.getParameter("format");
    if (format==null) {
        format = "%f";
    }

    Vector<String> flist = (Vector<String>) session.getAttribute("string_format_list");
    if (flist==null) {
        flist = new  Vector<String>();
        session.setAttribute("string_format_list", flist);
    }
%>
<html>
<head>
  <title>Decimal Formatter</title>
  <script src="http://cdnjs.cloudflare.com/ajax/libs/angular.js/1.2.1/angular.min.js"></script>
  <link href='http://fonts.googleapis.com/css?family=Montserrat:200,400,700' rel='stylesheet' type='text/css'>
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

<h1>Decimal Formatter</h1>

<form action="format.jsp" method="get">
<table class="table">
<tr>
<td>value:</td><td><input type="text" name="value" value="<%wr.writeHtml(value);%>" size=30>
</td><td><input type="submit" value="Recalc" class="btn btn-primary"></td>
</tr>
<tr>
<td>format:</td><td><input type="text" name="format" value="<%wr.writeHtml(format);%>" size=30>
</td><td><input type="submit" value="Add Format" class="btn btn-primary"></td>
</tr>
</table>
</form>
<hr/>
<%

    Double d = Double.parseDouble(value);
    String formatted = String.format(format, d);
    if (!flist.contains(format)) {
        flist.add(format);
    }

%>



<table class="table">
<col width="50">
<col width="150">
<col width="150">
<%
int count = 0;
for (String olff : flist) {
    String res = null;
    try {
        res = String.format(olff, Double.parseDouble(value));
    }
    catch (Exception e) {
        res = e.toString();
    }
%>
<tr>
<td><pre><%= count++ %></pre></td>
<td><pre><%wr.writeHtml(olff); %></pre></td>
<td><pre><%wr.writeHtml(res); %></pre></td>
</tr>
<%
}
%>
</table>
<div class="footLine">
    <a href="index.htm">Purple Hills Tools</a></div>
</div>

</div>
</body>
</html>

