<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
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
%><%@page import="java.util.Collections"
%><%@page import="org.w3c.dom.NamedNodeMap"
%><%@page import="com.purplehillsbooks.xml.Mel"
%><%@page import="com.purplehillsbooks.xml.Schema"
%><%@page import="com.purplehillsbooks.xml.SchemaDef"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.WebRequest"
%><%@page import="org.workcast.wu.XMLSchemaDef"
%><%@page import="org.workcast.wu.XMLSchemaFile"
%><%@page import="org.workcast.wu.XMLSchemaPool"
%><%@page import="org.workcast.wu.XMLSchemaType"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);

    XMLSchemaPool pool = (XMLSchemaPool) session.getAttribute("XMLSchemaPool");
    if (pool == null)
    {
        pool = new XMLSchemaPool();
        session.setAttribute("XMLSchemaPool", pool);
    }

    String start = wr.defParam("start", "");


    Vector<String> v = new Vector<String>();
    pool.findAllPaths(v, start);
    Collections.sort(v);


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>XML Grinder Paths</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>XML Grinder Paths</h1>
<p><form action="xmleditAction.jsp" method="GET">
   <input type="hidden" name="f" value="File 1">
   <input type="submit" name="act" value="Change File">
   <input type="submit" name="act" value="XML View">
   <input type="submit" name="act" value="Field Edit">
   <input type="submit" name="act" value="Operation">
   </form></p>
<hr>

<table><tr><td>Starting with: </td><form method="get" action="findallpaths.jsp">
<td><input type="text" name="start" value="<% wr.writeHtml(start); %>" size="50">
<input type="submit" value="Search"></td>
</form></tr></table>

<% if (v.size()>=1000) { %>
<p><i>Note: too many paths, results limited to 1000 paths, some paths may be missing.  Specify a starting filter to restrict results</i></p>
<% } %>

<table width="800">
<%
    for (String path : v)
    {
        %><tr><td><%
        wr.writeHtml(path);
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

    public void generateXPaths(Vector v, String pre, Mel me,
            int index, boolean isPlural, Schema schema)
        throws Exception
    {
        String thisTag = me.getName();
        boolean isMultiple = false;
        SchemaDef sd = schema.lookUpDefinition(thisTag);
        if (sd!=null)
        {

        }
        String newPre = null;
        if (isPlural)
        {
            newPre = pre + me.getName() +"[" + Integer.toString(index) + "]/";
        }
        else
        {
            newPre = pre + me.getName() +"/";
        }
        v.add(newPre);
        if (!me.isContainer())
        {
            return;
        }
        Vector attrs = me.getAllAttributeNames();
        Vector cs = me.getAllChildren();
        if (attrs.size()==0 && cs.size()==0)
        {
        }
        else
        {
            if (attrs.size()>0)
            {
                Enumeration e = attrs.elements();
                while (e.hasMoreElements())
                {
                    String aName = (String) e.nextElement();
                    v.add(newPre + "@" + aName);
                }
            }
            if (cs.size()>0)
            {
                int childIndex = 1;
                String lastTag = "";
                Enumeration e = cs.elements();
                while (e.hasMoreElements())
                {
                    Mel child = (Mel) e.nextElement();
                    String childName = child.getName();
                    boolean childIsPlural = false;
                    if(sd!=null)
                    {
                        childIsPlural = sd.childIsPlural(childName);
                    }
                    if (lastTag.equals(childName))
                    {
                        childIndex++;
                    }
                    else
                    {
                        childIndex = 1;
                        lastTag = childName;
                    }
                    generateXPaths(v, newPre, child, childIndex, childIsPlural, schema);
                }
            }
        }
    }



    public void potentialXPaths(Vector v, String pre, String tagName,
            boolean isPlural, Schema schema, int depthLimit)
        throws Exception
    {
        if (depthLimit<=0)
        {
            return;
        }
        int newDepthLimit = depthLimit - 1;
        SchemaDef sd = schema.lookUpDefinition(tagName);
        String newPre = null;
        if (isPlural)
        {
            newPre = pre + tagName +"[*]/";
        }
        else
        {
            newPre = pre + tagName +"/";
        }
        v.add(newPre);
        if (sd.isContainer())
        {
            Vector attrs = sd.getChildren("attr");
            Vector children = sd.getChildren("contains");
            if (attrs.size()==0 && children.size()==0)
            {
                return;
            }
            if (attrs.size()>0)
            {
                Enumeration e = attrs.elements();
                while (e.hasMoreElements())
                {
                    Mel ae = (Mel) e.nextElement();
                    v.add(newPre + "@" + ae.getAttribute("name"));
                }
            }
            if (children.size()>0)
            {
                Enumeration e = children.elements();
                while (e.hasMoreElements())
                {
                    Mel child = (Mel) e.nextElement();
                    String childName = child.getAttribute("name");
                    String pluralAttr = child.getAttribute("plural");
                    boolean childIsPlural = (pluralAttr!=null && pluralAttr.equals("true"));
                    if(sd!=null)
                    {
                        childIsPlural = sd.childIsPlural(childName);
                    }
                    potentialXPaths(v, newPre, childName, childIsPlural, schema, newDepthLimit);
                }
            }
        }
    }

%>
