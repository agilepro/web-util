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
%><%@page import="org.w3c.dom.NamedNodeMap"
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

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>JSON Grinder: <%wr.writeHtml(f);%></title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>JSON Grinder: <%wr.writeHtml(f);%></h1>
<p><form action="xmleditAction.jsp" method="GET">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Data View">
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

<form action="fieldviewAction.jsp">
<input type="submit" name="act" value="Save Changes">
<input type="hidden" name="f" value="<%wr.writeHtml(f);%>">

<table><tr><td bgcolor="skyblue">
<% generateTables(wr, 800, "MAIN", mainDoc.getJSON()); %>
</td></tr></table>
</form>

<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
<%!




    public void generateTables(OldWebRequest wr, int width, String name, Object me)
        throws Exception
    {
        String color = "LightCyan";
        if (width%50==0)
        {
            color = "lightyellow";
        }
        int cellwidth = width-25;
        if (me instanceof JSONObject) {
            JSONObject jo = ((JSONObject)me);
            wr.write("\n<table width=\""+(width-4)+"\">");
            wr.write("\n<col width=\"16\">");
            wr.write("\n<col width=\""+(cellwidth-4)+"\">");
            wr.write("\n  <tr><td colspan=\"2\"><b>");
            wr.writeHtml(name);
            wr.write("</b>");
            if (true) {
                wr.write("\n  </td></tr><tr><td>");
                wr.write("\n  </td><td bgcolor=\""+color+"\">");
                for (String key : jo.keySet()) {
                    Object o = jo.get(key);
                    if (o instanceof JSONObject) {
                        generateTables(wr, cellwidth, key, ((JSONObject)o));
                    }
                    else if (o instanceof JSONArray) {
                        generateTables(wr, cellwidth, key, ((JSONArray)o));
                    }
                    else if (o instanceof String) {
                        wr.writeHtml(key);
                        wr.write(" = <input type=\"text\" name=\"xxx\" value=\"");
                        wr.writeHtml((String)o);
                        wr.write("\"><br/>");
                    }
                    else  {
                        wr.writeHtml(key);
                        wr.write(" = ");
                        wr.writeHtml("no impplemented yet");
                        wr.write("<br/>");
                    }
                }
            }
            wr.write("\n  </td></tr>");
            wr.write("\n</table>");
        }
        else if (me instanceof JSONArray) {
            JSONArray ja = ((JSONArray)me);
            //wr.write("\n<table width=\""+(width-4)+"\">");
            //wr.write("\n<col width=\"16\">");
            //wr.write("\n<col width=\""+(cellwidth-4)+"\">");
            //wr.write("\n  <tr><td colspan=\"2\">");
            for (int i=0; i<ja.length(); i++) {
                Object o = ja.get(i);
                if (o instanceof JSONObject) {
                    generateTables(wr, width, name+"["+i+"]", ((JSONObject)o));
                }
                else if (o instanceof JSONArray) {
                    generateTables(wr, width, name+"["+i+"]", ((JSONArray)o));
                }
                else if (o instanceof String) {
                    wr.writeHtml(name+"["+i+"]");
                    wr.write(" = <input type=\"text\" name=\"xxx\" value=\"");
                    wr.writeHtml((String)o);
                    wr.write("\"><br/>");
                }
                else  {
                    wr.writeHtml(name+"["+i+"]");
                    wr.write(" = ");
                    wr.writeHtml("no impplemented yet");
                    wr.write("<br/>");
                }
            }
            //wr.write("\n  </td></tr>");
            //wr.write("\n  </table>");
        }
        else if (me instanceof String) {
            wr.writeHtml(name);
            wr.write(" = <input type=\"text\" name=\"xxx\" value=\"");
            wr.writeHtml((String)me);
            wr.write("\"><br/>");
        }
        else {
            wr.writeHtml(name);
            wr.write(" = ");
            wr.writeHtml("No implemento");
            wr.write("<br/>");
        }
    }

%>
