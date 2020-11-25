<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
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
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="org.workcast.wu.XMLSchemaDef"
%><%@page import="org.workcast.wu.XMLSchemaFile"
%><%@page import="org.workcast.wu.XMLSchemaPool"
%><%@page import="org.workcast.wu.XMLSchemaType"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");
    String destFile = wr.defParam("destFile", null);

    Hashtable ht = (Hashtable) session.getAttribute("fileCache");
    if (ht == null)
    {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    XMLSchemaPool pool = (XMLSchemaPool) session.getAttribute("XMLSchemaPool");
    if (pool == null)
    {
        pool = new XMLSchemaPool();
        session.setAttribute("XMLSchemaPool", pool);
    }
    FileCache mainDoc = (FileCache) ht.get(f);

    if (mainDoc==null)
    {
        response.sendRedirect("selectfile.jsp");
        return;
    }
    String go = "xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8");

    String act = wr.reqParam("act");

    if ("Change File".equals(act))
    {
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else if ("XML View".equals(act))
    {
        response.sendRedirect(go);
        return;
    }
    else if ("Field Edit".equals(act))
    {
        response.sendRedirect("fieldview.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else if ("Data View".equals(act))
    {
        response.sendRedirect("dataview.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else if ("Java View".equals(act))
    {
        response.sendRedirect("javaview.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }
    else if ("Set MinSch".equals(act))
    {
        String otherFile=wr.reqParam("otherFile");
        FileCache schemaFile = (FileCache) ht.get(otherFile);
        if (schemaFile==null)
        {
            throw new Exception("sorry, can't find a schema file named '"+otherFile+"'");
        }
        mainDoc.setSchema(schemaFile);
        response.sendRedirect(go);
        return;
    }
    else if ("Rename".equals(act))
    {
        if (destFile!=null)
        {
            mainDoc.setName(destFile);
            ht.remove(f);
            ht.put(destFile, mainDoc);
        }
        response.sendRedirect(go);
        return;
    }
    else if ("Reformat".equals(act))
    {
        mainDoc.getMel().reformatXML();
        response.sendRedirect(go);
        return;
    }
    else if ("Eliminate CData".equals(act))
    {
        mainDoc.getMel().eliminateCData();
        response.sendRedirect(go);
        return;
    }
    else if ("Edit".equals(act))
    {
        response.sendRedirect("xmlfix.jsp?f="+URLEncoder.encode(f));
        return;
    }
    else if ("Operation".equals(act))
    {
        response.sendRedirect("xmlop.jsp?f="+URLEncoder.encode(f));
        return;
    }
    else if ("Gen MinSch".equals(act))
    {
        Schema schema = SchemaGen.generateFor(mainDoc.getMel());
        schema.reformatXML();
        if (destFile==null)
        {
            destFile = "MinSch for "+f;
        }
        FileCache schemaFile = new FileCache(destFile, schema);
        FileCache schemaSchemaFile = (FileCache) ht.get("MinSch MinSch");
        schemaFile.isSchema = true;
        schemaFile.setSchema(schemaSchemaFile);
        mainDoc.setSchema(schemaFile);
        ht.put(destFile, schemaFile);
        response.sendRedirect(go);
    }
    else if ("Validate".equals(act))
    {
        String otherFile=wr.reqParam("otherFile");
        FileCache schemaFile = (FileCache) ht.get(otherFile);
        if (schemaFile==null)
        {
            throw new Exception("sorry, can't find a schema file named '"+otherFile+"'");
        }
        mainDoc.setSchema(schemaFile);
        ValidationResults vr = (ValidationResults) Mel.createEmpty("validationResults", ValidationResults.class);
        mainDoc.validateSchema(vr);
        if (destFile==null)
        {
            destFile = "Validation Results for "+f;
        }
        FileCache valFile = new FileCache(destFile, vr);
        FileCache valSchema = (FileCache) ht.get("Validation Results MinSch");
        if (valSchema!=null)
        {
            valFile.setSchema(valSchema);
        }
        ht.put(destFile, valFile);
        response.sendRedirect(go);
    }
    else if ("Transform".equals(act))
    {
        String otherFile=wr.reqParam("otherFile");
        if (destFile==null)
        {
            destFile = "Transform of "+f;
        }
        FileCache outputFile = new FileCache(destFile, FileCache.TRANSFORM, f, otherFile, ht);
        ht.put(destFile, outputFile);
        response.sendRedirect(go);
    }
    else if ("Refresh".equals(act))
    {
        mainDoc.refresh();
        response.sendRedirect(go);
    }
    else if ("Register XMLSchema".equals(act))
    {
        Mel me = mainDoc.getMel();
        String ns = mainDoc.findNamespace();
        String target = me.getAttribute("targetNamespace");
        String prefix = findAssociatedPrefix(me, target);
        pool.registerXMLSchema(prefix,me.getElement());
        response.sendRedirect(go);
    }
    else if ("Internalize".equals(act))
    {
        Mel me = mainDoc.getMel();
        String newName = mainDoc.getName() + "(I)";
        String nameSpace = mainDoc.findNamespace();

        Element rootElement = me.getElement();
        String newRootName = pool.getName(rootElement);

        Mel newTree = Mel.createEmpty(newRootName, DOMFace.class);

        pool.cloneInternalized(me.getElement(), newTree.getElement(), newTree.getDocument());
        FileCache newFileCache = new FileCache(newName, newTree);
        ht.put(newName, newFileCache);
        newFileCache.assignedNamespace = nameSpace;
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(newName, "UTF-8"));
    }
    else if ("Externalize".equals(act))
    {
        String namespace = mainDoc.assignedNamespace;
        if (namespace==null)
        {
            throw new Exception("Can not externalize a cached file that does not have an assigned namespace");
        }
        XMLSchemaFile item = pool.lookup(namespace);
        Mel me = mainDoc.getMel();
        String newName = mainDoc.getName() + "(E)";

        Element rootElement = me.getElement();
        String rootName = pool.getName(rootElement);
        String newRootName = pool.getPrefixFromNamespace(namespace) + ":" + rootName;
        Mel newTree = Mel.createEmpty(newRootName, DOMFace.class);


        pool.cloneExternalized(me.getElement(), newTree.getElement(), newTree.getDocument(), namespace);
        FileCache newFileCache = new FileCache(newName, newTree);
        ht.put(newName, newFileCache);
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(newName, "UTF-8"));
    }
    else if ("Save to Path".equals(act))
    {
        String fullpath = wr.reqParam("path");
        File path = new File(fullpath);
        if (path.exists()) {
            //set the old file aside
            File newFile = new File(fullpath+"."+System.currentTimeMillis()+".old");
            path.renameTo(newFile);
        }
        InputStream is = mainDoc.getInputStreamForContents();
        OutputStream os = new FileOutputStream(path);
        byte[] buf = new byte[2000];
        int amt = is.read(buf);
        while (amt>0) {
            os.write(buf, 0, amt);
            amt = is.read(buf);
        }
        os.close();
        is.close();
        response.sendRedirect(go);
    }
    else
    {
        throw new Exception("Action not implemented: "+act);
    }
%>
<%!


    public String findAssociatedPrefix(Mel me, String desiredNamespace)
    {
        Vector allAttrNames = me.getAllAttributeNames();
        for (String aName : (Vector<String>)allAttrNames)
        {
            int colonPos = aName.indexOf(":");
            if (colonPos>0)
            {
                String prePart = aName.substring(0,colonPos);
                if ("xmlns".equals(prePart))
                {
                    String ns = me.getAttribute(aName);
                    if (desiredNamespace.equals(ns))
                    {
                        return aName.substring(colonPos+1);
                    }
                }
            }
        }
        return null;
    }


%>
