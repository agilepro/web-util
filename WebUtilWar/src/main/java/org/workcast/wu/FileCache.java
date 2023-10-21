package org.workcast.wu;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.io.Reader;
import java.io.StringReader;
import java.io.Writer;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpSession;

import com.purplehillsbooks.json.JSONArray;
import com.purplehillsbooks.json.JSONObject;
import com.purplehillsbooks.json.JSONSchema;
import com.purplehillsbooks.json.JSONTokener;
import com.purplehillsbooks.streams.HTMLWriter;
import com.purplehillsbooks.streams.JavaScriptWriter;
import com.purplehillsbooks.streams.MemFile;
import com.purplehillsbooks.xml.Mel;

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
    private String       fileType;
    public  MemFile      contents;
    private JSONObject   parsedJSON;
    private Mel          parsedXML;
    private FileCache    schemaFile;
    public  Exception    parseError;
    public  Exception    parseErrorXML;

    //for XMLSchema support, we need to remember what the namespace of the root
    //element was before stripping the XMLSchema attributes out
    public String    assignedNamespace;

    public boolean isSchema = false;

    //these are values of 'genType'
    public static int LOAD_WEB_RESOURCE = 1;
    public static int TRANSFORM = 2;

    
    public static List<FileCache> listFiles(HttpSession session) {
        @SuppressWarnings("unchecked")
        List<FileCache> fileList = (List<FileCache>) session.getAttribute("fileCache");
        if (fileList == null) {
            fileList = new ArrayList<FileCache>();
            session.setAttribute("fileCache", fileList);
        }
        return fileList;
    }

    public static FileCache findFile(HttpSession session, String name) {
        List<FileCache> fileList = listFiles(session);
        for (FileCache fc : fileList) {
            if (name.equalsIgnoreCase(fc.name)) {
                return fc;
            }
        }
        return null;
    }
    public static void storeFile(HttpSession session, FileCache fc) {
        List<FileCache> fileList = listFiles(session);
        List<FileCache> newFileList = new ArrayList<FileCache>();
        newFileList.add(fc);
        for (FileCache ofc : fileList) {
            if (!fc.name.equalsIgnoreCase(ofc.name)) {
                newFileList.add(ofc);
            }
        }
        session.setAttribute("fileCache", newFileList);
    }
    
    
    
    
    
    public FileCache(String newName) throws Exception {
        name = newName;
        contents = new MemFile();
        parseError = null;
        String lcName = newName.toLowerCase();
        if (lcName.endsWith(".dmn")) {
            fileType = "DMN";
        }
        else if (lcName.endsWith(".xml")) {
            fileType = "XML";
        }
        else if (lcName.endsWith(".json")) {
            fileType = "JSON";
        }
        else {
            fileType = "TXT";
        }
        normalizeFileName();
    }

    public void normalizeFileName() {
        String newName = name;
        int dotPos = newName.lastIndexOf(".");
        if (dotPos>0) {
            newName = newName.substring(0,dotPos);
        }
        if ("DMN".equals(fileType)) {
            newName = newName + ".dmn";
        }
        else if ("XML".equals(fileType)) {
            newName = newName + ".xml";
        }
        else if ("JSON".equals(fileType)) {
            newName = newName + ".json";
        }
        else {
            newName = newName + ".txt";
        }
        name = newName;
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
        parsedJSON = newTree;
    }

    /**
    * First parameter is the name of the resulting file cache, and the
    * second parameter is an input stream to read from.  Read it,
    * return a FileCached in memory.
    */
    public static FileCache createFromInputStream(String name, InputStream is) throws Exception {
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
    public InputStream getInputStream() throws Exception {
        return contents.getInputStream();
    }


    private void clearContents() {
        parsedJSON = null;
        parsedXML = null;
        parseError = null;
        parseErrorXML = null;
        fileType = "TXT";
        contents.clear();
    }

    public String getContents() throws Exception {
        return contents.toString();
    }
    public void setContents(String newCont) throws Exception {
        clearContents();
        StringReader sr = new StringReader(newCont);
        contents.fillWithReader(sr);

        parseContents();
    }
    public void fillWithInputStream(InputStream input) throws Exception {
        clearContents();
        contents.fillWithInputStream(input);
        parseContents();
    }
    public void setContentsJSON(JSONObject newCont) throws Exception {
        clearContents();
        newCont.write(contents.getWriter(), 2, 0);
        parseContents();
    }
    public void setContentsXML(Mel newCont) throws Exception {
        clearContents();
        newCont.writeToOutputStream(contents.getOutputStream());
        parseContents();
    }

    public void parseContents() {
        parsedJSON = null;
        parsedXML = null;
        parseError = null;
        fileType = "TXT";
        try {
            parsedJSON = new JSONObject(new JSONTokener(contents.getInputStream()));
            fileType = "JSON";
            normalizeFileName();
        }
        catch (Exception e) {
            parseError = e;
        }
        if (parsedJSON==null) {
            try {
                parsedXML = Mel.readInputStream(contents.getInputStream(), Mel.class);
                fileType = "XML";
                String rootNode = parsedXML.getName();
                if ("definitions".equals(rootNode)) {
                    fileType = "DMN";
                }
            }
            catch (Exception e) {
                parseErrorXML = e;
            }
        }
        normalizeFileName();
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
    public void setName(HttpSession session, String newName) {
        name = newName;
    }
    
    public String getType() {
        return fileType;
    }
    public void setType(HttpSession session, String newName) {
        fileType = newName;
    }
    
    public int getSize() {
        return contents.totalBytes();
    }

    public void writeContents(Writer w) throws Exception {
        if (parsedJSON!=null) {
            parsedJSON.write(w, 2, 0);
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
    public void writeContentsJS(Writer wr) throws Exception {
        JavaScriptWriter hr = new JavaScriptWriter(wr);
        writeContents(hr);
        hr.flush();
    }


    public JSONObject getJSON() {
        if (parsedJSON == null) {
            parseContents();
        }
        return parsedJSON;
    }
    public Mel getXML() {
        return parsedXML;
    }

    public void setSchema(FileCache otherFile) throws Exception {
        schemaFile = otherFile;
    }

    public FileCache getSchema() {
        return schemaFile;
    }


    public boolean isValidJSON() {
        return (parsedJSON!=null);
    }
    public boolean isValidXML() {
        return (parsedXML!=null);
    }


    public boolean hasSchema() {
        return (schemaFile!=null);
    }

    public Exception getError() {
        return parseError;
    }

    public List<String> validateSchema() throws Exception {
        JSONSchema converter = new JSONSchema();
        converter.checkSchema(parsedJSON, this.schemaFile.parsedJSON);
        return converter.getErrorList();
    }

    public static void recusiveStripNameSpace(JSONObject jo) throws Exception {
        ArrayList<String> keys = new ArrayList<String>();
        for (String key : jo.keySet()) {
            keys.add(key);
        }
        for (String key : keys) {
            int colonPos = key.indexOf(":");
            if (colonPos>0) {
                Object value = jo.get(key);
                jo.remove(key);
                String bareKey = key.substring(colonPos+1);
                jo.put(bareKey, value);
            }
        }
        for (String key : jo.keySet()) {
            Object value = jo.get(key);
            if (value instanceof JSONObject) {
                recusiveStripNameSpace((JSONObject)value);
            }
            else if (value instanceof JSONArray) {
                listStripNameSpace((JSONArray)value);
            }
        }
    }
    public static void listStripNameSpace(JSONArray ja) throws Exception {
        for (int i=0; i<ja.length(); i++) {
            Object value = ja.get(i);
            if (value instanceof JSONObject) {
                recusiveStripNameSpace((JSONObject)value);
            }
            else if (value instanceof JSONArray) {
                listStripNameSpace((JSONArray)value);
            }
        }
    }
    public static void recursiveStripTag(JSONObject jo, String tagName) throws Exception {
        if (jo.has(tagName)) {
            jo.remove(tagName);
        }
        ArrayList<String> keys = new ArrayList<String>();
        for (String key : jo.keySet()) {
            keys.add(key);
        }
        for (String key : jo.keySet()) {
            Object value = jo.get(key);
            if (value instanceof JSONObject) {
                recursiveStripTag((JSONObject)value, tagName);
            }
            else if (value instanceof JSONArray) {
                listStripNameSpace((JSONArray)value);
            }
        }
    }
    public static void listStripTag(JSONArray ja, String tagName) throws Exception {
        for (int i=0; i<ja.length(); i++) {
            Object value = ja.get(i);
            if (value instanceof JSONObject) {
                recursiveStripTag((JSONObject)value, tagName);
            }
            else if (value instanceof JSONArray) {
                listStripTag((JSONArray)value, tagName);
            }
        }
    }

}
