<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%>
<html>
<head>
  <title>SUDOKU Solver</title>
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

<h1>SUDOKU Solver</h1>

<form action="sudoku3.jsp" method="get">
<table>
<%
for (int i=0; i<9; i++) {
    if ((i%3)==0) {
        %><tr align="center"><td> + </td><td>----</td><td>----</td><td>----</td>
              <td> + </td><td>----</td><td>----</td><td>----</td>
              <td> + </td><td>----</td><td>----</td><td>----</td></tr><%
    }
%>
<tr align="center">
<%
    for (int j=0; j<9; j++) {
        if ((j%3)==0) {
            %><td> | </td><%
        }
%>
<td><input type="text" name="a<%=(i+1)%><%=(j+1)%>" size="1"></td>
<%
    }
%>
</tr>
<%
}
%>
        <tr align="center"><td> + </td><td>----</td><td>----</td><td>----</td>
              <td> + </td><td>----</td><td>----</td><td>----</td>
              <td> + </td><td>----</td><td>----</td><td>----</td></tr>
</table>
<input type="submit" value="GO">
</form>
<hr>


<div class="footLine">
    <a href="index.htm">Purple Hills Tools</a></div>
</div>

</div>
</body>
</html>