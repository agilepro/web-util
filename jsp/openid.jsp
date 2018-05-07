<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.PrintWriter"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Properties"
%><%@page import="com.purplehillsbooks.streams.HTMLWriter"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
%>

<p>This is the OpenId test page.
   Enter an OpenID in order to test the ability to log in to a particular OpenID provider.
   </p>

<table>
<col width="100">
<col width="500">
<form action="<%=wr.retPath%>openidAction.jsp?go=<%wr.writeURLData(wr.getRequestURL());%>" method="post">
  <tr>
<% if (wr.isLoggedIn()) {%>

    <td>Login Status</td>
    <td>
        You are currently logged in to id:
        ( <% wr.writeHtml((String)session.getAttribute("openid")); %> )
    </td>
    </tr>
    <tr>
    <td>Action:</td>
    <td>
        <input type="submit" name="act" value="Log Out">
    </td>
    </tr>

<% } else {%>

    <td>Login Status</td>
    <td>
        You are not logged in.
    </td>
    </tr>
    <tr>
    <td>Action:</td>
    <td>
      <input type="submit" name="act" value="Log In">
      <input type="text" name="openid" size="50" value="<% wr.writeHtml(wr.getFormerId()); %>">
    </td>
<% } %>

  </tr>
    <tr>
    <td colspan="2"><br/>Properties from last login attempt:</td>
    </tr>

<%
    Properties traceProps = (Properties) session.getAttribute("login_trace");
    if (traceProps == null) {
        traceProps = new Properties();
    }
    Enumeration trenum = traceProps.propertyNames();
    while (trenum.hasMoreElements()) {
        String key = (String) trenum.nextElement();
        String val = traceProps.getProperty(key);
        %><tr><td valign="top"><%
        wr.writeHtml(key);
        %>:</td><td valign="top"><%
        wr.writeHtmlWithLines(val);
        %></td></tr><%
    }
%>

</form>
</table>

<%
    Exception fatalError = (Exception) session.getAttribute("error-msg");
    if (fatalError!=null) {

        %><h3>Fatal Exception</h3><ul><%
        Throwable t = fatalError;
        while (t!=null) {
            wr.write("\n<li>");
            wr.writeHtmlWithLines(t.toString());
            wr.write("</li>");
            t = t.getCause();
        }
        %></ul><pre><font size="-4"><%
        fatalError.printStackTrace(new PrintWriter(new HTMLWriter(out)));
        %></font></pre><%

    }
%>

<hr/>
<table>
  <tr>
    <td><a href="<%=wr.retPath%>index.htm">
      <img border="0" src="<%=wr.retPath%>SwensonWebUtilities.gif"></a>
    </td>
  </tr>
</table>