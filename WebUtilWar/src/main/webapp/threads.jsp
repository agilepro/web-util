<%@ page language="java" import="java.util.*,java.lang.Thread.State" contentType="text/html;charset=UTF-8"
    pageEncoding="ISO-8859-1"%>
<%@page import="org.workcast.wu.SimpleWebRequest"%>
<html>
<head>
  <title>Thread Dump</title>
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

<h1>Thread Dump</h1>

<%
    SimpleWebRequest wr = new SimpleWebRequest(request, response, out);
    out.print("Generating Thread-dump at:" + (new java.util.Date()).toString() + "<BR>");
    out.println("----------------------------<br>");
    Map<Thread, StackTraceElement[]> map = Thread.getAllStackTraces();
    Iterator<Thread> itr = map.keySet().iterator();
    while (itr.hasNext()) {
            Thread t = itr.next();
            StackTraceElement[] elem = map.get(t);
            out.print("\"" + t.getName() + "\"");
            out.print(" prio=" + t.getPriority());
            out.print(" tid=" + t.getId());
            State s = t.getState();
            String state = null;
            String color = "000000";
            String GREEN = "00FF00";
            String RED = "FF0000";
            String ORANGE = "FCA742";
            switch(s) {
                case NEW: state ="NEW"; color = GREEN; break;
                case BLOCKED: state = "BLOCKED"; color = RED; break;
                case RUNNABLE: state = "RUNNABLE"; color = GREEN; break;
                case TERMINATED: state = "TERMINATED"; break;
                case TIMED_WAITING: state = "TIME WAITING"; color = ORANGE; break;
                case WAITING: state = "WAITING"; color = RED; break;
            }
            out.print("<font color=\"" + color + "\"> @@@@</font>");
            out.println(" " + state + "<BR>");
            for (int i=0; i < elem.length; i++) {
                    out.println("  at ");
                    out.print(elem[i].toString());
                    out.println("<BR>");
            }
            out.println("----------------------------<br>");
    }

%>

<% wr.invokeJSP("tileBottom.jsp"); %>

</div>
</body>
</html>