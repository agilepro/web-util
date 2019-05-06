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
%><%@page import="com.purplehillsbooks.xml.Mel"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");

    Hashtable ht = (Hashtable) session.getAttribute("fileCache");
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
    if (!mainDoc.isValidXML())
    {
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>XML Grinder: <%wr.writeHtml(f);%></title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>XML Grinder: <%wr.writeHtml(f);%></h1>
<p><form action="xmleditAction.jsp" method="GET">
   <input type="hidden" name="f" value="<% wr.writeHtml(f); %>">
   <input type="submit" name="act" value="Data View">
   </form></p>
<p>MinSch is
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
<% generateTables(wr, 800, mainDoc.getMel()); %>
</td></tr></table>
</form>

<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
<%!

    public void generateTables(WebRequest wr, int width, Mel me)
        throws Exception
    {
        String color = "skyblue";
        if (width%50==0)
        {
            color = "lightyellow";
        }
        int cellwidth = width-25;
        if (me.isContainer())
        {
            wr.write("\n<table width=\""+(width-4)+"\">");
            wr.write("\n<col width=\"16\">");
            wr.write("\n<col width=\""+(cellwidth-4)+"\">");
            wr.write("\n  <tr><td colspan=\"2\"><b>");
            wr.writeHtml(me.getName());
            wr.write("</b>");
            Vector attrs = me.getAllAttributeNames();
            Vector cs = me.getAllChildren();
            if (attrs.size()==0 && cs.size()==0)
            {
                wr.write(" = <i>empty</i>");
            }
            else
            {
                wr.write("\n  </td></tr><tr><td>");
                wr.write("\n  </td><td bgcolor=\""+color+"\">");
                if (attrs.size()>0)
                {
                    Enumeration e = attrs.elements();
                    while (e.hasMoreElements())
                    {
                        String aName = (String) e.nextElement();
                        wr.write("@");
                        wr.writeHtml(aName);
                        wr.write(" = <input type=\"text\" name=\"xxx\" value=\"");
                        wr.writeHtml(me.getAttribute(aName));
                        wr.write("\"><br/>");
                    }
                }
                if (cs.size()>0)
                {
                    Enumeration e = cs.elements();
                    while (e.hasMoreElements())
                    {
                        Mel child = (Mel) e.nextElement();
                        if (!child.isContainer())
                        {
                            wr.writeHtml(child.getName());
                            wr.write(" = <input type=\"text\" name=\"xxx\" value=\"");
                            wr.writeHtml(child.getDataValue());
                            wr.write("\"><br/>");
                        }
                        else
                        {
                            generateTables(wr, cellwidth, child);
                        }
                    }
                }
            }
            wr.write("\n  </td></tr>");
            wr.write("\n</table>");
        }
        else
        {
            wr.writeHtml(me.getName());
            wr.write(" = ");
            wr.writeHtml(me.getDataValue());
        }
    }

%>
