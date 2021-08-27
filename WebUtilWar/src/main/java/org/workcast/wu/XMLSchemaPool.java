package org.workcast.wu;

import java.util.HashMap;
import java.util.Map;
import java.util.Vector;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

/**
* XMLSchemaPool holds a collection of schema files that are each associated
* with a specific prefix (short name).  The schema pool can be loaded with a
* number of schema files, one at a time, each time given a prefix value and
* the root DOM element of the schema tree.
* The namespace of the schema is retrieved from the root element.
*
* The schema is held in a XMLSchemaFile object, which can be retrieved
* by namespace or by prefix value.
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class XMLSchemaPool
{
    private Map<String,XMLSchemaFile> schemaTable = new HashMap<String,XMLSchemaFile>();

    public XMLSchemaPool() {}


    public void registerXMLSchema(String shortName, Element schemaBaseElement)
        throws Exception
    {
        XMLSchemaFile si = new XMLSchemaFile(this, shortName, schemaBaseElement);
        schemaTable.put(si.getNamespace(), si);
    }

    public Map<String,XMLSchemaFile> getMap()
    {
        return schemaTable;
    }

    public XMLSchemaFile lookup(String namespace)
    {
        return schemaTable.get(namespace);
    }

    /**
    * Given a standard prefix, this method will look for the associated schema object.
    * The schema pool is expected to be loaded with all the necessary schema files
    * before calling this method.  If the prefix value is not found in the table,
    * a warning exception is thrown to inform the user that not all the schema files
    * are available for the processing being requested.
    */
    public XMLSchemaFile lookupByPrefixOrFail(String prefix)
        throws Exception
    {
        for (String mapping : schemaTable.keySet())
        {
            XMLSchemaFile ace = schemaTable.get(mapping);
            if (prefix.equals(ace.getOfficialPrefix()))
            {
                return ace;
            }
        }
        throw new Exception("Unable to find a registered schema for the prefix '"+prefix+"'");
    }

    /**
    * Given a standard prefix, this method will look for the associated schema object.
    * The schema pool is expected to be loaded with all the necessary schema files
    * before calling this method.  If the namespace value is not found in the table,
    * a warning exception is thrown to inform the user that not all the schema files
    * are available for the processing being requested.
    */
    public XMLSchemaFile lookupByNamespaceOrFail(String namespace)
        throws Exception
    {
        XMLSchemaFile xsf = schemaTable.get(namespace);
        if (xsf != null)
        {
            return xsf;
        }
        throw new Exception("Unable to find a registered schema for the namespace '"+namespace+"'");
    }

    /**
    * Given a namespace URI, this will return the associated prefix value.
    */
    public String getPrefixFromNamespace(String namespace)
    {
        XMLSchemaFile ace = schemaTable.get(namespace);
        if (ace!=null)
        {
            return ace.getOfficialPrefix();
        }
        return null;
    }

    /**
    * Given a prefix value, this will return the associated namespace URI.
    */
    public String getNamespaceFromPrefix(String prefix)
    {
        for (String mapping : schemaTable.keySet())
        {
            XMLSchemaFile ace = schemaTable.get(mapping);
            if (prefix.equals(ace.getOfficialPrefix()))
            {
                return ace.getNamespace();
            }
        }
        return null;
    }


    /**
    * This returns the name without the prefix.
    */
    public static String getName(Element e)
    {
        String name = e.getNodeName();
        if (name==null || name.length()==0)
        {
            name = e.getLocalName();
        }
        return stripPrefix(name);
    }
    /**
    * This returns the namespace prefix, if there is one.
    * Returns an empty string if not.
    */
    public static String getPrefix(Element e)
    {
        String name = e.getNodeName();
        if (name==null || name.length()==0)
        {
            name = e.getLocalName();
        }
        int colonPos = name.lastIndexOf(":");
        if (colonPos>=0)
        {
            return name.substring(0,colonPos);
        }
        return "";
    }

    /**
    * general purpose routine to look for a colon, and return what is after it if found
    * otherwise return the entire string
    */
    public static String stripPrefix(String name)
    {
        int colonPos = name.lastIndexOf(":");
        if (colonPos>=0)
        {
            return name.substring(colonPos+1);
        }
        return name;
    }


    /**
    * general purpose routine to look for a colon, and return what is before it if found
    * otherwise return a null stirng.
    */
    public static String extractPrefix(String name)
    {
        int colonPos = name.lastIndexOf(":");
        if (colonPos>=0)
        {
            return name.substring(0,colonPos);
        }
        return "";
    }


    public void addNamespaceMappings(Element ele)
    {
        for (String mapping : schemaTable.keySet())
        {
            XMLSchemaFile ace = schemaTable.get(mapping);
            ele.setAttribute("xmlns:"+ace.getOfficialPrefix(), ace.getNamespace());
        }
    }


    public void cloneInternalized(Element parent, Element destEle, Document destDoc)
        throws Exception
    {
        //first copy attributes that dont start with xmlns
        NamedNodeMap nnm = parent.getAttributes();
        if (nnm!=null)
        {
            int last = nnm.getLength();
            for (int j=0; j<last; j++)
            {
                Node na = nnm.item(j);
                String oldName = na.getNodeName();
                if (oldName.startsWith("xmlns"))
                {
                    continue;
                }
                String newName = oldName;
                int colonPos = oldName.lastIndexOf(":");
                if (colonPos>=0)
                {
                    newName = oldName.substring(colonPos+1);
                }
                destEle.setAttribute(newName, parent.getAttribute(oldName));
            }
        }

        //now walk through any children
        NodeList childNdList = parent.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++)
        {
            Node n = childNdList.item(i);
            if (n.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE)
            {
                Element child = (Element)n;
                String childName = getName(child);

                Element newElem = destDoc.createElement(childName);
                destEle.appendChild(newElem);

                //do the same for the children
                cloneInternalized(child, newElem, destDoc);
            }
            else if (n.getNodeType() == org.w3c.dom.Node.TEXT_NODE)
            {
                destEle.appendChild(destDoc.createTextNode(n.getNodeValue()));
            }
        }
    }


    public void cloneExternalized(Element parent, Element destEle, Document destDoc, String namespace)
        throws Exception
    {
        addNamespaceMappings(destEle);
        XMLSchemaFile container = lookupByNamespaceOrFail(namespace);
        XMLSchemaDef rootDef = container.getRootDef(getName(parent));
        cloneExternalizedR(parent, destEle, destDoc, rootDef);
    }

    private void cloneExternalizedR(Element parent, Element destEle, Document destDoc,
            XMLSchemaDef def)  throws Exception
    {
        try
        {
            XMLSchemaType type = def.getType();

            //first copy attributes
            NamedNodeMap nnm = parent.getAttributes();
            if (nnm!=null)
            {
                int last = nnm.getLength();
                for (int j=0; j<last; j++)
                {
                    Node na = nnm.item(j);
                    String oldName = na.getNodeName();
                    String newName = type.getExternalAttributeName(oldName);
                    destEle.setAttribute(newName, parent.getAttribute(oldName));
                }
            }

            //then walk through the children
            NodeList childNdList = parent.getChildNodes();
            for (int i = 0 ; i < childNdList.getLength(); i++)
            {
                Node n = childNdList.item(i);
                if (n.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE)
                {

                    Element child = (Element)n;
                    String childName = getName(child);

                    XMLSchemaDef childDef = type.findChildDef(childName);

                    Element newElem = destDoc.createElement(childDef.getExternalName());
                    destEle.appendChild(newElem);

                    //do the same for the children
                    cloneExternalizedR(child, newElem, destDoc, childDef);
                }
                else if (n.getNodeType() == org.w3c.dom.Node.TEXT_NODE)
                {
                    destEle.appendChild(destDoc.createTextNode(n.getNodeValue()));
                }
            }
        }
        catch (Exception e)
        {
            throw new Exception("error while trying to externalize "+parent.getNodeName() + " into " + destEle.getNodeName(), e);
        }
    }


    /*
    * Finds all paths in the schema pool starting with the specified path part
    */
    public void findAllPaths(Vector<String> v, String startingWith)
        throws Exception
    {
        for (String key : schemaTable.keySet())
        {
            XMLSchemaFile file = schemaTable.get(key);
            file.findAllPaths(v, startingWith);
        }
    }

}
