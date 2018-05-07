<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.FileOutputStream"
%><%@page import="java.io.OutputStream"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.File"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Map"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Document"
%><%@page import="org.w3c.dom.Element"
%><%@page import="org.w3c.dom.NamedNodeMap"
%><%@page import="org.w3c.dom.Node"
%><%@page import="org.w3c.dom.NodeList"
%><%@page import="com.purplehillsbooks.xml.Mel"
%><%@page import="com.purplehillsbooks.xml.Schema"
%><%@page import="com.purplehillsbooks.xml.SchemaGen"
%><%@page import="com.purplehillsbooks.xml.ValidationResults"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.WebRequest"
%><%@page import="org.workcast.wu.XMLSchemaDef"
%><%@page import="org.workcast.wu.XMLSchemaFile"
%><%@page import="org.workcast.wu.XMLSchemaPool"
%><%@page import="org.workcast.wu.XMLSchemaType"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");
    String destFile = wr.defParam("destFile", null);

    Hashtable ht = (Hashtable) session.getAttribute("fileCache");
    if (ht == null) {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    XMLSchemaPool pool = (XMLSchemaPool) session.getAttribute("XMLSchemaPool");
    if (pool == null) {
        pool = new XMLSchemaPool();
        session.setAttribute("XMLSchemaPool", pool);
    }
    FileCache mainDoc = (FileCache) ht.get(f);

    if (mainDoc==null) {
        response.sendRedirect("selectfile.jsp");
        return;
    }
    String go = "xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8");

    String act = wr.reqParam("act");

    if ("Smooth KML File".equals(act)) {
        Mel root = mainDoc.getMel();
        if (root==null) {
            throw new Exception("Unable to get the root.");
        }
        Mel document = root.getChild("Document",0);
        if (document==null) {
            throw new Exception("Unable to get the Document element.");
        }
        Mel placemark = document.getChild("Placemark",0);
        if (placemark==null) {
            throw new Exception("Unable to get the Placemark element.");
        }
        Mel track = placemark.getChild("Track",0);
        if (track==null) {
            throw new Exception("Unable to get the Track element.");
        }
        Vector<Mel> smurphy = track.getAllChildren();
        Vector<Float> xlist = new Vector<Float>();
        Vector<Float> ylist = new Vector<Float>();
        Vector<Float> zlist = new Vector<Float>();
        for (Mel item : smurphy) {
            String elname = item.getName();
            if ("when".equals(elname)) {
                //ignore it
            }
            else if ("coord".equals(elname)) {
                String coordContents = item.getDataValue();
                String[] splits = coordContents.split(" ");
                if (splits==null) {
                    throw new Exception("Unable to get split the data: "+coordContents);
                }
                if (splits.length!=3) {
                    throw new Exception("Split the data and did not get three pieces: "+coordContents);
                }
                Float xVal = Float.parseFloat(splits[0]);
                xlist.add(xVal);
                Float yVal = Float.parseFloat(splits[1]);
                ylist.add(xVal);
                Float zVal = Float.parseFloat(splits[2]);
                zlist.add(xVal);
            }
        }

        Vector<Float> newxlist = new Vector<Float>();
        Vector<Float> newylist = new Vector<Float>();
        Vector<Float> newzlist = new Vector<Float>();
        int last = xlist.size()-3;

        newxlist.add(xlist.get(0));
        newxlist.add((xlist.get(0)+xlist.get(1)+xlist.get(2))/3);
        newylist.add(ylist.get(0));
        newylist.add((ylist.get(0)+ylist.get(1)+ylist.get(2))/3);
        newzlist.add(zlist.get(0));
        newzlist.add((zlist.get(0)+zlist.get(1)+zlist.get(2))/3);

        //now do the smoothing
        for (int x = 2; x<last; x++) {
            newxlist.add((xlist.get(x-2) + xlist.get(x-1) + xlist.get(x) + xlist.get(x+1) + xlist.get(x+2))/5);
            newylist.add((ylist.get(x-2) + ylist.get(x-1) + ylist.get(x) + ylist.get(x+1) + ylist.get(x+2))/5);
            newzlist.add((zlist.get(x-2) + zlist.get(x-1) + zlist.get(x) + zlist.get(x+1) + zlist.get(x+2))/5);
        }

        newxlist.add((xlist.get(last)+xlist.get(last+1)+xlist.get(last+2))/3);
        newxlist.add(xlist.get(last+2));
        newylist.add((ylist.get(last)+ylist.get(last+1)+ylist.get(last+2))/3);
        newylist.add(ylist.get(last+2));
        newzlist.add((zlist.get(last)+zlist.get(last+1)+zlist.get(last+2))/3);
        newzlist.add(zlist.get(last+2));

        int xpos = 0;
        for (Mel item : smurphy) {
            String elname = item.getName();
            if ("when".equals(elname)) {
                //ignore it
            }
            else if ("coord".equals(elname)) {
                String val = xlist.get(xpos) + " " + ylist.get(xpos) + " " + zlist.get(xpos);
                xpos++;
                item.//set the content here
            }
        }

        if (true) {
            throw new Exception("Yup everything OK");
        }
    }
    else {
        throw new Exception("Action not implemented: "+act);
    }
    response.sendRedirect(go);
%>
<%!



%>
