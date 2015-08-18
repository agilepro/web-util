package org.workcast.wu;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Writer;
import java.net.URL;
import java.net.URLConnection;
import java.util.Hashtable;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.workcast.mendocino.Mel;
import org.workcast.mendocino.Schema;
import org.workcast.mendocino.ValidationResults;
import org.workcast.streams.MemFile;
import org.workcast.streams.HTMLWriter;

/**
* Manages a collection of "files" for session.  Each
* user can have a number of files loaded in at once.
* The file can be text, or it might be parsed XML.
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class FileCache
{

    String           name;
    public MemFile   contents;
    String           charset;
    Mel parsedFile;
    FileCache        assignedMinSch;
    Exception        parseError;
    Hashtable<String, FileCache>        lookup;

    //for XMLSchema support, we need to remember what the namespace of the root
    //element was before stripping the XMLSchema attributes out
    public String    assignedNamespace;

    public boolean isSchema = false;

    // Generation: how this file was generated.
    // By specifying the means that was used to generate a file,
    // it is possible to "refresh" the file.
    int    genType;
    String genData1;
    String genData2;

    //these are values of 'genType'
    public static int LOAD_WEB_RESOURCE = 1;
    public static int TRANSFORM = 2;


    public FileCache(String newName, MemFile mf)
        throws Exception
    {
        name = newName;
        contents = mf;
        charset  = "UTF-8";
        parseError = null;
        genType  = 0;
        genData1 = null;
        genData2 = null;
        lookup   = null;
        parseContents();
    }

    public FileCache(String newName)
        throws Exception
    {
        this(newName, new MemFile());
    }


    public FileCache(String newName, String newCont)
        throws Exception
    {
        this(newName, new MemFile());
        setContents(newCont);
    }

    /**
    * Use this constructor is the file is regeneratable.
    * Construct with a generation command, and then later
    * the file can be regenerated on demand.
    *
    * if type is the following, then data1, data2 is:
    *  LOAD_WEB_RESOURCE,  URL to the web resource, character encoding
    *  TRANSFORM,          Name of the source, name of transform
    */
    public FileCache(String newName, int type, String data1, String data2,
            Hashtable<String, FileCache> newLookup)
        throws Exception
    {
        name = newName;
        contents = new MemFile();
        charset  = "UTF-8";
        parseError = null;
        parsedFile = null;
        genType = type;
        genData1 = data1;
        genData2 = data2;
        lookup = newLookup;
        refresh();
    }


    public FileCache(String newName, Mel newTree)
        throws Exception
    {
        name = newName;
        contents = new MemFile();
        charset  = "UTF-8";
        parsedFile = newTree;
        parseError = null;
        genType = 0;
        genData1 = null;
        genData2 = null;
        lookup   = null;
    }

    /**
    * First parameter is the name of the resulting file cache, and the
    * second parameter is an input stream to read from.  Read it,
    * return a FileCached in memory.
    */
    public static FileCache createFromInputStream(String name, InputStream is)
        throws Exception
    {
        MemFile mf = new MemFile();
        mf.fillWithInputStream(is);
        return new FileCache(name, mf);
    }


    /**
    * First parameter is the name of the resulting file cache, and the
    * second parameter is a file to read from.  Read it the file,
    * return a FileCached in memory.
    */
    public static FileCache createFromFile(String name, File file)
        throws Exception
    {
        return createFromInputStream(name, new FileInputStream(file));
    }


    /**
    * Returns a Reader which may be read from in order to
    * read the contents of the memory file, assuming that the
    * file is in UTF-8 encoding.
    */
    public Reader getReader()
        throws Exception
    {
        return contents.getReader();
    }





    public boolean isRefreshable()
    {
        return (genType>0);
    }

    public String refreshDesc()
    {
        if (genType == LOAD_WEB_RESOURCE)
        {
            return "Web resource load from "+genData1;
        }
        if (genType == TRANSFORM)
        {
            return "Transform of file '"+genData1+"' using file "+genData2;
        }
        return "No refresh information available";
    }

    /**
    * IF the file is created by some generation operations
    * designed to be done again, then refresh will regenerate
    * the file from that operation.
    */
    public void refresh()
        throws Exception
    {
        if (genType == LOAD_WEB_RESOURCE)
        {
            loadContentsFromWeb(genData1, genData2);
        }
        else if (genType == TRANSFORM)
        {
            loadContentsFromTransform(genData1, genData2);
        }
        else
        {
            throw new Exception("The refresh operation for FileCache does not understand the 'type' of "+genType);
        }
    }

    private void setContents(String newCont)
        throws Exception
    {
        parsedFile = null;
        parseError = null;
        contents.clear();
        charset  = "UTF-8";
        OutputStream os = contents.getOutputStream();
        Writer w = new OutputStreamWriter(os, charset);
        w.write(newCont);
        w.close();

        parseContents();
    }

    public void parseContents()
    {
        parsedFile = null;
        parseError = null;
        try
        {
            parsedFile = DOMFace.parseInputStream(contents.getInputStream());
        }
        catch (Exception e)
        {
            parseError = e;
        }
    }


    public void loadContentsFromWeb(String urlPath, String newCharset)
        throws Exception
    {
        URL url = new URL(urlPath);
        URLConnection uc = url.openConnection();
        if (uc == null)
        {
            throw new Exception("Got a null URLConnection object!");
        }
        InputStream is = uc.getInputStream();
        charset = newCharset;
        contents.clear();
        contents.fillWithInputStream(is);
        parseContents();
    }

    public void loadContentsFromTransform(String source, String xform)
        throws Exception
    {
        FileCache srcFile = lookup.get(source);
        if (srcFile==null)
        {
            throw new Exception("sorry, can't find a source file named '"+source+"'");
        }
        FileCache xsltFile = lookup.get(xform);
        if (xsltFile==null)
        {
            throw new Exception("sorry, can't find a XSLT file named '"+xform+"'");
        }
        transformFrom(srcFile, xsltFile);
    }


    public String getName()
    {
        return name;
    }

    public void setName(String newName)
    {
        name = newName;
    }

    public String getContents()
        throws Exception
    {
        if (parsedFile!=null)
        {
            return DOMFace.convertToString(parsedFile);
        }
        if (contents!=null)
        {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            contents.outToOutputStream(baos);
            byte[] buf = baos.toByteArray();
            return new String(buf, charset);
        }
        return null;
    }

    /**
    * Writes the contents of this file cach to the ourput writer
    * whiel encoding for HTML at the same time.
    */
    public void writeContentsHtml(Writer wr)
        throws Exception
    {
        HTMLWriter hr = new HTMLWriter(wr);
        if (parsedFile!=null)
        {
            //Instead of creating a memfile here, we could instead keep contents current...
            //depends on whether we believe contents needs to be maintained unchanged.
            MemFile mf = new MemFile();
            parsedFile.writeToOutputStream(mf.getOutputStream());
            mf.outToWriter(hr);
        }
        else if (contents!=null)
        {
            contents.outToWriter(hr);
        }
    }


    public Mel getMel()
    {
        return parsedFile;
    }


    public Schema getAsSchema()
        throws Exception
    {
        if (parsedFile!=null)
        {
            return parsedFile.convertClass(Schema.class);
        }
        return null;
    }

    public void setSchema(FileCache otherFile)
        throws Exception
    {
        assignedMinSch = otherFile;
        if (parsedFile!=null)
        {
            parsedFile.setSchema(otherFile.getAsSchema());
        }
    }

    public FileCache getSchema()
    {
        return assignedMinSch;
    }


    public boolean isValidXML()
    {
        return (parsedFile!=null);
    }


    public boolean isSchema()
    {
        //not sure if this is complete enough
        return (parsedFile instanceof Schema);
    }

    public boolean hasSchema()
    {
        return (assignedMinSch!=null);
    }

    public Exception getError()
    {
        return parseError;
    }

    public void validateSchema(ValidationResults results)
        throws Exception
    {
        parsedFile.validate(results);
    }

    public InputStream getInputStreamForContents()
        throws Exception
    {
        return DOMFace.getInputStreamForContents(parsedFile);
    }


    public void transformFrom(FileCache source, FileCache xslt)
        throws Exception
    {
        // Source XML from 'this' object
        StreamSource xmlFile = new StreamSource(source.getInputStreamForContents());

        // Source XSLT Stylesheet from passed file
        StreamSource xsltFile = new StreamSource(xslt.getInputStreamForContents());
        TransformerFactory xsltFactory = TransformerFactory.newInstance();
        Transformer transformer = xsltFactory.newTransformer(xsltFile);

        // Send transformed output to memory file
        contents.clear();
        StreamResult resultStream = new StreamResult(contents.getOutputStream());

        // Apply the transformation
        transformer.transform(xmlFile, resultStream);

        parseContents();
    }

    public String findNamespace() throws Exception
    {
        if (parsedFile==null)
        {
            throw new Exception("This file is not parsed, so we can not determine the namespace");
        }

        String shortName = parsedFile.getPrefix();
        if (shortName !=null && shortName.length()>=0)
        {
            String attvalns = parsedFile.getAttribute("xmlns:"+shortName);
            if (attvalns!=null && attvalns.length()>0)
            {
                return attvalns;
            }
        }

        //first look for xmlns attribute
        String attval = parsedFile.getAttribute("xmlns");
        if (attval!=null && attval.length()>0)
        {
            return attval;
        }

        if (shortName!=null && shortName.length()>0)
        {
            return "No namespace for '"+shortName+"' on element: "+parsedFile.getName();
        }
        return "No prefix and no xmlns on element: "+parsedFile.getName();
    }

    public boolean isXMLSchema() throws Exception
    {
		String nameSpace = "unknown";
		if (isValidXML())
		{
			nameSpace = findNamespace();
		}
        return "http://www.w3.org/2001/XMLSchema".equals(nameSpace);
    }



    public static Hashtable<String, FileCache> getPreloadedHashtable()
        throws Exception
    {
        Hashtable<String, FileCache> ht = new Hashtable<String, FileCache>();
        FileCache schemaSchema = getSchemaSchemaMemFile();
        ht.put(schemaSchema.getName(), schemaSchema);
        FileCache validationResults = getValRes();
        validationResults.setSchema(schemaSchema);
        ht.put(validationResults.getName(), validationResults);
        return ht;
    }

    private static FileCache getSchemaSchemaMemFile()
        throws Exception
    {
        MemFile schemaSchema = new MemFile();
        Writer w = schemaSchema.getWriter();
        w.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?><schema>");
        w.write("\n  <container name=\"schema\">");
        w.write("\n    <contains name=\"container\" plural=\"true\"/>");
        w.write("\n    <contains name=\"data\" plural=\"true\"/>");
        w.write("\n    <contains name=\"root\"/>");
        w.write("\n  </container>");
        w.write("\n  <container name=\"attr\">");
        w.write("\n    <attr name=\"name\"/>");
        w.write("\n  </container>");
        w.write("\n  <container name=\"contains\">");
        w.write("\n    <attr name=\"name\"/>");
        w.write("\n    <attr name=\"plural\"/>");
        w.write("\n  </container>");
        w.write("\n  <container name=\"container\">");
        w.write("\n    <attr name=\"name\"/>");
        w.write("\n    <contains name=\"attr\" plural=\"true\"/>");
        w.write("\n    <contains name=\"contains\" plural=\"true\"/>");
        w.write("\n  </container>");
        w.write("\n  <container name=\"data\">");
        w.write("\n    <attr name=\"name\"/>");
        w.write("\n    <attr name=\"ambiguous\"/>");
        w.write("\n  </container>");
        w.write("\n  <data name=\"root\"/>");
        w.write("\n  <root>schema</root>");
        w.write("\n</schema>");
        w.flush();
        FileCache fc = new FileCache("MinSch MinSch", schemaSchema);
        fc.isSchema = true;
        fc.setSchema(fc);
        return fc;
    }

    private static FileCache getValRes()
        throws Exception
    {
        MemFile schemaSchema = new MemFile();
        Writer w = schemaSchema.getWriter();
        w.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?><schema>");
        w.write("\n  <container name=\"validationResults\">");
        w.write("\n    <contains name=\"result\" plural=\"true\"/>");
        w.write("\n  </container>");
        w.write("\n  <data name=\"result\"/>");
        w.write("\n  <root>validationResults</root>");
        w.write("\n</schema>");
        w.flush();
        FileCache fc = new FileCache("Validation Results MinSch", schemaSchema);
        fc.isSchema = true;
        return fc;
    }


}
