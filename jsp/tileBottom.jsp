<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
%>

<table><form action="<%=wr.retPath%>loginAction.jsp?go=<%wr.writeURLData(wr.getRequestURL());%>" method="post">
  <tr>
    <td><a href="<%=wr.retPath%>index.htm">
      <img border="0" src="<%=wr.retPath%>SwensonWebUtilities.gif"></a>
    </td>

<% if (wr.isLoggedIn()) { %>

    <td>
      <input type="submit" name="act" value="Log Out"><font size="-3">
      ( <% wr.writeHtml((String)session.getAttribute("openid")); %> )</font>
    </td>

<% } else { %>

    <td>
      <input type="submit" name="act" value="Log In">
      <input type="text" name="openid" size="50" value="<% wr.writeHtml(wr.getFormerId()); %>">
    </td>

<% } %>

  </tr>
</form>
</table>

