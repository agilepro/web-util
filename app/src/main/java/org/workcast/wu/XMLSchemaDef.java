package org.workcast.wu;

import java.util.Vector;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

/**
* An XMLSchemaDef class represents an xsd:element tag and its information.
* There are a couple different cases
*
* 1. simple type
* <xsd:element name="foo" type="xsd:String"/>
*
* In this case the element holds a simply scalar value.  isComplex() == false
* There are no expected children of this (and if any chidlren are found there is
* nothing we could do with them anyway.
* A call to getType() will return a null.
*
* 2. inline complex type
* <xsd:element name="foo">
*   <xsd:complexType>
*     <xsd:sequence>
*       <xsd:element name="bar1">
*       <xsd:element name="bar1">
*       <xsd:element name="bar1">
*     </xsd:sequence>
*   </xsd:complexType>
* <xsd:element name="foo">
*
* In this case the type is declared inline, isComplex()==true
* The method getType() will return an object that wraps the
* complexType tag that is a child of this element tag.
*
* 3. type related by name
* <xsd:element name="foo" type="ddd:bar">
*
* In this case the referred type is assumed to be complex.  isComplex()==true
* The method getType() will find the linked type in the appropriate namespace
* and will return a wrapper of that.
*
* 4. element def is reference
* <xsd:element ref="ddd:foo2">
* <xsd:element name="foo2" type="...">
*
* In this case the actual defition of the element is in the referred element
* so there will never be a XMLSchemaDef wrapping the first element tag.
* Instead, it will always wrap the referred element tag which actually
* provides the definition.  That referred element might be one of types 1 thru 3
* and will be handled according to those guidelines.
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class XMLSchemaDef
{
    XMLSchemaFile container;
    private Element definition;
    boolean complex = false;
    String  internalName;

    /**
    * The element definition may have a 'form' attribute which can be:
    * 'qualified' which sets formQualified to true;
    * 'anything else' which sets formQualified to false;
    * If there is no 'form' attribute at all, this inherits the value from container.
    */
    boolean formQualified = true;

    public XMLSchemaDef(XMLSchemaFile newContainer, Element thisDef)
        throws Exception
    {
        container = newContainer;
        definition = thisDef;
        formQualified = container.elementFormQualified;

        internalName = definition.getAttribute("name");
        if (internalName==null || internalName.length()==0)
        {
            throw new Exception("Unable to understand this schema element definition that does not have a name attribute!");
        }
        String isRef = definition.getAttribute("ref");
        if (isRef!=null && isRef.length()>0)
        {
            throw new Exception("the XMLSchemaDef class should never be instantiated on a ref item, but only on the destination of that ref (schema='"
                +container.getOfficialPrefix()+"', element='"+internalName+"')");
        }
        String formValue = definition.getAttribute("form");
        if (formValue!=null && formValue.length()>0)
        {
            formQualified = "qualified".equals(formValue);
        }
    }

    /**
    * return the official prefix for the namespace that this element is in
    */
    public String getPrefix()
    {
        return container.getOfficialPrefix();
    }


    public String getExternalName()
    {
        if (formQualified)
        {
            return container.getOfficialPrefix() + ":" + internalName;
        }
        else
        {
            return internalName;
        }
    }

    public String getName()
    {
        return internalName;
    }


    public XMLSchemaType getType()
        throws Exception
    {
        String type = definition.getAttribute("type");
        if (type!=null && type.length()>0)
        {
            return container.getType(type);
        }

        //there was no type attribute, so it must be defined inline
        Element child = getChildElement(definition, "complexType");
        if (child!=null)
        {
            return new XMLSchemaType(container, child);
        }

        //assume it is a simple type at this point
        return XMLSchemaType.simpleType();
        //throw new Exception("Unable to find a type definition: no type attribute and no child complexType element named "+definition.getAttribute("name"));
    }

    public Element getChildElement(Element parent, String elementName)
    {
        NodeList childNdList = parent.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++) {
            org.w3c.dom.Node n = childNdList.item(i) ;
            if (n.getNodeType() != org.w3c.dom.Node.ELEMENT_NODE) {
                continue ;
            }
            Element ne = (Element)n;
            if (elementName.equals(XMLSchemaPool.getName(ne)))
            {
                return ne;
            }
        }
        return null;
    }

    public void findAllPaths(Vector<String> v, String base, String startingWith)
        throws Exception
    {
        if (v.size()>1000)
        {
            //terminate when there are too many paths
            return;
        }
        base = base + internalName + "/";
        if (base.length()>startingWith.length())
        {
            if (!base.startsWith(startingWith))
            {
                return;  //don't search this path any further
            }
        }
        else
        {
            if (!startingWith.startsWith(base))
            {
                return;  //don't search this path any further
            }
        }

        v.add(base);
        XMLSchemaType myType = getType();
        if (myType!=null)
        {
            myType.findAllPaths(v, base, startingWith);
        }
    }

}