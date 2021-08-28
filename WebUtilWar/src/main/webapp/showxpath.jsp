<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.net.URLConnection"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Vector"
%><%@page import="java.util.TreeSet"
%><%@page import="org.w3c.dom.NamedNodeMap"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");

    Hashtable<String,FileCache> ht = (Hashtable<String,FileCache>) session.getAttribute("fileCache");
    if (ht == null)
    {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    FileCache mainDoc = (FileCache) ht.get(f);
    if (mainDoc==null)
    {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    if (!mainDoc.isValidJSON())
    {
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }

    String s = wr.reqParam("s");
    boolean useSchema = (s.equals("true"));

    TreeSet<String> allPaths = new TreeSet<String>();
    generateXPaths(allPaths, "", mainDoc.getJSON());


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>All Paths: <%wr.writeHtml(f);%></title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>All Paths: <%wr.writeHtml(f);%></h1>
<p><form action="xmleditAction.jsp" method="GET">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Change File">
   <input type="submit" name="act" value="JSON View">
   <input type="submit" name="act" value="Field Edit">
   <input type="submit" name="act" value="Operation">
   </form></p>
<p>Schema is
<%
    FileCache fcs = mainDoc.getSchema();
    if (fcs==null)
    {
        out.write("<i>not set</i>");
    }
    else
    {
        out.write(": ");
        wr.writeHtml(fcs.getName());
    }
%>
</p>
<hr>

<table width="800">
<%

    for (String line : allPaths) {
        %><tr><td><%
        wr.writeHtml(line);
        %></td></tr><%
    }

%>
</table>

<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
<%!

    public void generateXPaths(TreeSet<String> v, String pre, JSONObject jo)
        throws Exception
    {
        for (String key : jo.keySet()) {
            String newPre = pre + "." + key;
            Object o = jo.get(key);
            if (o instanceof JSONObject) {
                generateXPaths(v, newPre, (JSONObject)o);
            }
            else if (o instanceof JSONArray) {
                generateXPaths(v, newPre, (JSONArray)o);
            }
            else {
                v.add(newPre);
            }
        }

    }
    public void generateXPaths(TreeSet<String> v, String pre, JSONArray ja) 
        throws Exception {
        for (int i=0; i<ja.length(); i++) {
            String newPre = pre + "[#]";
            Object o = ja.get(i);
            if (o instanceof JSONObject) {
                generateXPaths(v, newPre, (JSONObject)o);
            }
            else if (o instanceof JSONArray) {
                generateXPaths(v, newPre, (JSONArray)o);
            }
            else {
                v.add(newPre);
            }
        }
    }

%>
