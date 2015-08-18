<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%>
<html>
<head>
  <title>SUDOKU Solver</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h3>SUDOKU Solver</h3>
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
<table>
<tr>
<td><a href="index.htm"><img border="0" src="SwensonWebUtilities.gif"></a></td>
</tr>
</table>
</body></html>