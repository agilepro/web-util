package org.workcast.wu;

import java.util.Hashtable;
import java.util.Vector;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class XMLSchemaFile
{
    public  XMLSchemaPool pool;
    private Element       schemaRoot; // schema as a Document
    private String        shortName;

    /**
    * The schema tag has attribute 'elementFormDefault' which can either be
    *   'qualified'    which makes elementFormQualified true
    *   'unqualified'  which makes elementFormQualified false
    * This value applies to the entire schema.
    * If it is true, then every tag should get a prefix added to it.
    * If it is false, then the prefix should not appear in the tag.
    * The default value is 'true'.
    */
    public  boolean       elementFormQualified = false;
    public  boolean       attributeFormQualified = false;
    public  String        namespace;
    public  Hashtable<String,Element> globalElements = new Hashtable<String,Element>();
    public  Hashtable<String,Element> globalTypes    = new Hashtable<String,Element>();
    public  Hashtable<String,Element> globalAttr     = new Hashtable<String,Element>();

    /**
    * This file uses prefixes within it, and it might not use the same prefix that
    * are the global official prefixes.  This hashtable tracks the declarations in
    * this file.  Any prefix (short name) that appears in this file, should be mapped
    * to a namespace using this hashtable.
    */
    public  Hashtable<String,String>  prefixNamespace= new Hashtable<String,String>();

    public XMLSchemaFile(XMLSchemaPool npool, String newShortName, Element schemaroot)
        throws Exception
    {
        pool = npool;
        shortName = newShortName;
        schemaRoot = schemaroot;
        process();
    }

    public String getNamespace()
    {
        return namespace;
    }


    public String getOfficialPrefix()
    {
        return shortName;
    }

    public Element getRootElement()
    {
        return schemaRoot;
    }


    /**
    * Pass the name of a global element without any prefix
    * and get top level element definition returned.
    */
    public XMLSchemaDef getRootDef(String name)
        throws Exception
    {
        Element lookedUp = globalElements.get(name);
        if (lookedUp==null)
        {
            throw new Exception("Unable to find a definition for element '"+name+"' in schema '"+shortName+"'");
        }
        return new XMLSchemaDef(this, lookedUp);
    }

    /**
    * pass the name of a reference, with or without the
    * prefix qualifier, and the element definition returned
    */
    public XMLSchemaDef getDef(String name)
        throws Exception
    {
        int colonPos = name.indexOf(":");
        XMLSchemaFile source = this;
        if (colonPos>0)
        {
            String prefix = name.substring(0,colonPos);
            name = name.substring(colonPos+1);
            String namespace = lookupNamespace(prefix);
            source = pool.lookupByNamespaceOrFail(namespace);
        }
        return source.getRootDef(name);
    }


    public XMLSchemaType getRootType(String name)
        throws Exception
    {
        Element lookedUp = globalTypes.get(name);
        if (lookedUp==null)
        {
            throw new Exception("Unable to find a root type named '"+name+"' in schema '"+shortName+"'");
        }
        return new XMLSchemaType(this, lookedUp);
    }
    public XMLSchemaType getType(String name)
        throws Exception
    {
        int colonPos = name.indexOf(":");
        XMLSchemaFile source = this;
        if (colonPos>0)
        {
            String prefix = name.substring(0,colonPos);
            name = name.substring(colonPos+1);
            String namespace = lookupNamespace(prefix);

            if ("http://www.w3.org/2001/XMLSchema".equals(namespace))
            {
                //Here we handle all of the XMLSchema pre-defined types
                //since all predefined types are simple types, we simply
                //return an empty XMLSchemaType object that has no data
                //in it, and returns empty sets for everything
                return XMLSchemaType.simpleType();
            }
            source = pool.lookupByNamespaceOrFail(namespace);
        }
        return source.getRootType(name);
    }


    public XMLSchemaAttr getRootAttr(String name)
        throws Exception
    {
        Element lookedUp = globalAttr.get(name);
        if (lookedUp==null)
        {
            throw new Exception("Unable to find a attribute definition named '"+name+"' in schema '"+shortName+"'");
        }
        return new XMLSchemaAttr(this, lookedUp);
    }
    public XMLSchemaAttr getAttr(String name)
        throws Exception
    {
        int colonPos = name.indexOf(":");
        XMLSchemaFile source = this;
        if (colonPos>0)
        {
            String prefix = name.substring(0,colonPos);
            name = name.substring(colonPos+1);
            String namespace = lookupNamespace(prefix);
            source = pool.lookupByNamespaceOrFail(namespace);
        }
        return source.getRootAttr(name);
    }

    public String lookupNamespace(String prefix)
    {
        return prefixNamespace.get(prefix);
    }

    private void process()
        throws Exception
    {
        Element root = schemaRoot;
        String prefix = XMLSchemaPool.getPrefix(root);
        String postfix = XMLSchemaPool.getName(root);
        if (!"schema".equals(postfix))
        {
            throw new Exception("Sorry, can't process this as a schema since the root tag is a '"
                +postfix+"' instad of a 'schema'");
        }
        String schemaDeclaredNamespace = root.getAttribute("xmlns:"+prefix);
        if (!"http://www.w3.org/2001/XMLSchema".equals(schemaDeclaredNamespace))
        {
            throw new Exception("only know how to process schemas declared in the http://www.w3.org/2001/XMLSchema namespace");
        }
        namespace = root.getAttribute("targetNamespace");
        if (namespace==null)
        {
            throw new Exception("Can only handle XML Schema definitions with a specified targetNamespace attribute");
        }

        String qual = root.getAttribute("elementFormDefault");
        if (qual!=null && qual.length()>0)
        {
            //note, if it is anything other than qualified, it counts as unqualified
            elementFormQualified = "qualified".equals(qual);
        }
        qual = root.getAttribute("attributeFormDefault");
        if (qual!=null && qual.length()>0)
        {
            //note, if it is anything other than qualified, it counts as unqualified
            attributeFormQualified = "qualified".equals(qual);
        }

        //might want to automatically register this at this point

        //now, find all the top level chidren 'element' and 'complextType'
        NodeList childNdList = root.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++)
        {
            Node n = childNdList.item(i);
            if (n.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE)
            {
                Element child = (Element)n;
                String childName = XMLSchemaPool.getName(child);
                if ("element".equals(childName))
                {
                    String tagName = XMLSchemaPool.stripPrefix(child.getAttribute("name"));
                    globalElements.put(tagName, child);
                }
                if ("complexType".equals(childName))
                {
                    String tagName = XMLSchemaPool.stripPrefix(child.getAttribute("name"));
                    globalTypes.put(tagName, child);
                }
                if ("simpleType".equals(childName))
                {
                    String tagName = XMLSchemaPool.stripPrefix(child.getAttribute("name"));
                    globalTypes.put(tagName, child);
                }
                if ("attribute".equals(childName))
                {
                    String tagName = XMLSchemaPool.stripPrefix(child.getAttribute("name"));
                    globalAttr.put(tagName, child);
                }
            }
        }

        gatherNamespaceInfo(root);
    }

    //internal method to walk the tree
    private void gatherNamespaceInfo(Element e)
    {
        //first copy attributes that dont start with xmlns
        NamedNodeMap nnm = e.getAttributes();
        if (nnm!=null)
        {
            int last = nnm.getLength();
            for (int j=0; j<last; j++)
            {
                Node na = nnm.item(j);
                if (na.getNodeType() == org.w3c.dom.Node.ATTRIBUTE_NODE)
                {
                    String name = na.getNodeName();
                    if (name.startsWith("xmlns:"))
                    {
                        String prefix = name.substring(6);
                        String namespace = na.getNodeValue();
                        prefixNamespace.put(prefix, namespace);
                    }
                }
            }
        }

        //walk through child nodes, either elements or attributes
        NodeList childNdList = e.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++)
        {
            Node n = childNdList.item(i);
            if (n.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE)
            {
                gatherNamespaceInfo((Element)n);
            }
            else if (n.getNodeType() == org.w3c.dom.Node.ATTRIBUTE_NODE)
            {
                String name = n.getNodeName();
                if (name.startsWith("xmlns:"))
                {
                    String prefix = name.substring(5);
                    String namespace = n.getNodeValue();
                    prefixNamespace.put(prefix, namespace);
                }
            }
        }

    }

    public void findAllPaths(Vector<String> v, String startingWith)
        throws Exception
    {
        for (Element elem : globalElements.values())
        {
            XMLSchemaDef xst = new XMLSchemaDef(this, elem);
            xst.findAllPaths(v, "", startingWith);
        }
    }
}