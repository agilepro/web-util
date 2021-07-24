package org.workcast.wu;

import org.w3c.dom.Element;

/**
* An XMLSchemaAttr class represents an xsd:attribute tag and its information.
* The only thing we are interested in is the target namespace, so that
* the prefix can be placed on it if needed.
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class XMLSchemaAttr
{
    XMLSchemaFile container;
    private Element definition;

    public XMLSchemaAttr(XMLSchemaFile newContainer, Element thisDef)
        throws Exception
    {
        container = newContainer;
        definition = thisDef;
    }

    public String getName()
    {
        return definition.getAttribute("name");
    }

    public String getExternalName()
    {
        String name = getName();
        String target = definition.getAttribute("target");
        if (target==null || target.length()==0)
        {
            return name;
        }
        if (target.equals(container.getNamespace()))
        {
            return name;
        }
        String prefix = container.pool.getPrefixFromNamespace(target);
        return prefix + ":" + name;
    }
}