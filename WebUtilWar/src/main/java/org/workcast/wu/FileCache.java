package org.workcast.wu;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.Reader;
import java.io.StringReader;
import java.io.Writer;
import java.net.URL;
import java.net.URLConnection;
import java.util.Hashtable;
import java.util.List;

import com.purplehillsbooks.json.JSONObject;
import com.purplehillsbooks.json.JSONSchema;
import com.purplehillsbooks.json.JSONTokener;
import com.purplehillsbooks.streams.HTMLWriter;
import com.purplehillsbooks.streams.MemFile;

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

    private String       name;
    public  MemFile      contents;
    private JSONObject   parsedFile;
    private FileCache    schemaFile;
    private Exception    parseError;

    //for XMLSchema support, we need to remember what the namespace of the root
    //element was before stripping the XMLSchema attributes out
    public String    assignedNamespace;

    public boolean isSchema = false;

    //these are values of 'genType'
    public static int LOAD_WEB_RESOURCE = 1;
    public static int TRANSFORM = 2;


    public FileCache(String newName) throws Exception {
        name = newName;
        contents = new MemFile();
        parseError = null;
    }


    public FileCache(String newName, MemFile mf) throws Exception {
        this(newName);
        contents = mf;
        parseContents();
    }

    public FileCache(String newName, String newCont) throws Exception {
        this(newName);
        setContents(newCont);
    }

    public FileCache(String newName, JSONObject newTree) throws Exception {
        this(newName);
        parsedFile = newTree;
    }

    /**
    * First parameter is the name of the resulting file cache, and the
    * second parameter is an input stream to read from.  Read it,
    * return a FileCached in memory.
    */
    private static FileCache createFromInputStream(String name, InputStream is) throws Exception {
        MemFile mf = new MemFile();
        mf.fillWithInputStream(is);
        return new FileCache(name, mf);
    }


    /**
    * First parameter is the name of the resulting file cache, and the
    * second parameter is a file to read from.  Read it the file,
    * return a FileCached in memory.
    */
    public static FileCache createFromFile(String name, File file) throws Exception {
        return createFromInputStream(name, new FileInputStream(file));
    }


    /**
    * Returns a Reader which may be read from in order to
    * read the contents of the memory file, assuming that the
    * file is in UTF-8 encoding.
    */
    public Reader getReader() throws Exception {
        return contents.getReader();
    }



    public void setContents(String newCont) throws Exception {
        parsedFile = null;
        parseError = null;
        contents.clear();
        StringReader sr = new StringReader(newCont);
        contents.fillWithReader(sr);

        parseContents();
    }

    public void parseContents() {
        parsedFile = null;
        parseError = null;
        try {
            parsedFile = new JSONObject(new JSONTokener(contents.getInputStream()));
        }
        catch (Exception e) {
            parseError = e;
        }
    }


    public void loadContentsFromWeb(String urlPath) throws Exception {
        URL url = new URL(urlPath);
        URLConnection uc = url.openConnection();
        if (uc == null) {
            throw new Exception("Got a null URLConnection object!");
        }
        InputStream is = uc.getInputStream();
        contents.clear();
        contents.fillWithInputStream(is);
        parseContents();
    }

    public String getName() {
        return name;
    }

    public void setName(String newName) {
        name = newName;
    }

    public void writeContents(Writer w) throws Exception {
        if (parsedFile!=null) {
            parsedFile.write(w, 2, 0);
        }
        else if (contents!=null) {
            contents.outToWriter(w);
        }
    }

    /**
    * Writes the contents of this file cach to the ourput writer
    * whiel encoding for HTML at the same time.
    */
    public void writeContentsHtml(Writer wr) throws Exception {
        HTMLWriter hr = new HTMLWriter(wr);
        writeContents(hr);
        hr.flush();
    }


    public JSONObject getJSON() {
        return parsedFile;
    }

    public void setSchema(FileCache otherFile) throws Exception {
        schemaFile = otherFile;
    }

    public FileCache getSchema() {
        return schemaFile;
    }


    public boolean isValidJSON() {
        return (parsedFile!=null);
    }


    public boolean hasSchema() {
        return (schemaFile!=null);
    }

    public Exception getError() {
        return parseError;
    }

    public List<String> validateSchema() throws Exception {
        JSONSchema converter = new JSONSchema();
        boolean valid = converter.checkSchema(parsedFile, this.schemaFile.parsedFile);
        return converter.getErrorList();
    }



}
