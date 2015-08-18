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
%><%@page import="org.w3c.dom.NamedNodeMap"
%><%@page import="org.workcast.mendocino.Mel"
%><%@page import="org.workcast.mendocino.Schema"
%><%@page import="org.workcast.mendocino.SchemaDef"
%><%@page import="org.workcast.wu.DOMFace"
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

    String s = wr.reqParam("s");
    boolean useSchema = (s.equals("true"));
    FileCache schemaFile = mainDoc.getSchema();

    if (schemaFile==null) {
        throw new Exception("Unable to find a schema file for the current XML file.  You might need to generate one before getting the XPath expressions.");
    }

    Schema schema = schemaFile.getAsSchema();
    String rootName = schema.getScalar("root");

    if (schema==null)
    {
        throw new Exception("XML file ('"+f+"') must have an associated schema for this function");
    }

    Vector allPaths = new Vector();
    potentialXPaths(allPaths, "/", rootName, false, schema, 10);


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
   <input type="submit" name="act" value="Change File">
   <input type="submit" name="act" value="XML View">
   <input type="submit" name="act" value="Field Edit">
   <input type="submit" name="act" value="Operation">
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

<table width="800">
<%
    Enumeration e = allPaths.elements();
    while (e.hasMoreElements())
    {
        String path = (String) e.nextElement();
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
