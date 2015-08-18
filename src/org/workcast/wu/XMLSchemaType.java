package org.workcast.wu;

import java.util.Vector;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
* An XMLSchemaType class represents an xsd:complexType tag and its information.
* There are a couple different cases
*
* 1. a complexType may appear at the root level of a schema with a name.
*    The "type" attribute points to the proper type def in the proper namespace.
*
* 2. a complexType may appear as a child of an element definition
*
* The XMLSchemaType tells you the composition of the children of the element.
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class XMLSchemaType
{
    XMLSchemaFile container;
    private Vector<XMLSchemaDef>  subelements = new Vector<XMLSchemaDef>();
    private Vector<XMLSchemaAttr> attribDefs  = new Vector<XMLSchemaAttr>();

    public XMLSchemaType(XMLSchemaFile newContainer, Element thisDef)
        throws Exception
    {
        container = newContainer;
        gatherElements(thisDef);
    }


    /**
    * This constructor is used for simple types which have no attributes a
    * and no children elements.
    */
    public XMLSchemaType()
        throws Exception
    {
        container = null;
    }




    // fill the vector of elements so we don't have to search everytime
    // recursive search through all of the various container elements.
    // All we care about is the existence of the element definition, and
    // we don't really care how it is related to other elements.
    private void gatherElements(Element thisDef)
        throws Exception
    {
        NodeList childNdList = thisDef.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++) {
            org.w3c.dom.Node n = childNdList.item(i) ;
            if (n.getNodeType() != org.w3c.dom.Node.ELEMENT_NODE) {
                continue ;
            }
            Element ne = (Element)n;
            String elementName = XMLSchemaPool.getName(ne);
            if ("element".equals(elementName))
            {
                String refName = ne.getAttribute("ref");
                if (refName!=null && refName.length()>0)
                {
                    subelements.add(container.getDef(refName));
                }
                else
                {
                    subelements.add(new XMLSchemaDef(container, ne));
                }
            }
            else if ("sequence".equals(elementName))
            {
                gatherElements(ne);
            }
            else if ("all".equals(elementName))
            {
                gatherElements(ne);
            }
            else if ("choice".equals(elementName))
            {
                gatherElements(ne);
            }
            else if ("group".equals(elementName))
            {
                gatherElements(ne);
            }
            else if ("complexContent".equals(elementName))
            {
                gatherElements(ne);
            }
            else if ("attribute".equals(elementName))
            {
                String refName = ne.getAttribute("ref");
                if (refName!=null && refName.length()>0)
                {
                    attribDefs.add(container.getAttr(refName));
                }
                else
                {
                    attribDefs.add(new XMLSchemaAttr(container, ne));
                }
            }
            else if ("extension".equals(elementName))
            {
                //copy all the element and attribute definitions from that type, into this type
                String refName = ne.getAttribute("base");
                XMLSchemaType copySource = container.getType(refName);
                subelements.addAll(copySource.subelements);
                attribDefs.addAll(copySource.attribDefs);
                gatherElements(ne);
            }
        }
    }

    public XMLSchemaDef findChildDef(String name)
        throws Exception
    {
        if (name.indexOf(":")>=0)
        {
            throw new Exception("findChildDef works on the name of the child without any prefix");
        }
        for (XMLSchemaDef xsd : subelements)
        {
            String tagName = xsd.getName();
            if (name.equals(tagName))
            {
                return xsd;
            }
        }
        throw new Exception("Unable to find a definition for a tag '"+name+"',  Allowed tags are: "+allowedTagList());
    }


    /**
    * debugging infomation, returns a comma separated list of the child tags
    * that are legal and allowable for this type of element.
    */
    private String allowedTagList()
    {
        StringBuffer sb = new StringBuffer();
        boolean needComma = false;
        for (XMLSchemaDef xsd : subelements)
        {
            String tagName = xsd.getName();
            if (needComma)
            {
                sb.append(", ");
            }
            sb.append(tagName);
            needComma = true;
        }
        return sb.toString();
    }

    public String getExternalAttributeName(String internalName)
    {
        for (XMLSchemaAttr xsa : attribDefs)
        {
            String aName = xsa.getName();
            if (internalName.equals(aName))
            {
                return xsa.getExternalName();
            }
        }

        //perhaps this should be an error since we have an undeclared attribute
        //but do we really need to complain about that.  We only need the
        //declaration when it is in a different namespace.
        return internalName;
    }

    //Predefined xml schema types are simple types with no attributes and
    //no children. This method returns a XMLSchemaType object that acts
    //appropriately so that it returns empty sets or whatever is needed to
    //handling the processing of standard types.
    public static XMLSchemaType simpleType()
        throws Exception
    {
        return new XMLSchemaType();
    }


    public void findAllPaths(Vector<String> v, String base, String startingWith)
        throws Exception
    {
        for (XMLSchemaDef child : subelements)
        {
            child.findAllPaths(v, base, startingWith);
        }
    }


}