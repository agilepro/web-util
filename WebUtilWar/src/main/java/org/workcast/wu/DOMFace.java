package org.workcast.wu;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import com.purplehillsbooks.xml.Mel;
import com.purplehillsbooks.streams.MemFile;

/**
* now just a wrapper for Mendocino element
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class DOMFace extends Mel
{

    public DOMFace(Document doc, Element ele)
    {
        super(doc,ele);
    }


    public static DOMFace parseInputStream(InputStream xmlIn)
        throws Exception
    {
        return Mel.readInputStream(xmlIn, DOMFace.class);
    }

    public static String convertToString(Mel me)
        throws Exception
    {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        me.writeToOutputStream(baos);
        byte[] buf = baos.toByteArray();
        return new String(buf, "UTF-8");
    }

    public String convertToString()
        throws Exception
    {
        return convertToString(this);
    }

    public Document getDocumentElement()
    {
        return getDocument();
    }

    public static InputStream getInputStreamForString(String data)
        throws Exception
    {
        MemFile mf = new MemFile();
        OutputStreamWriter osw = new OutputStreamWriter(mf.getOutputStream(), "UTF-8");
        osw.write(data);
        osw.flush();
        osw.close();
        return mf.getInputStream();
    }

    public static InputStream getInputStreamForContents(Mel me)
        throws Exception
    {
        MemFile mf = new MemFile();
        me.writeToOutputStream(mf.getOutputStream());
        return mf.getInputStream();
    }


}
