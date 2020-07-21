package com.purplehillsbooks.ohioscan;

import java.io.File;
import java.net.URL;
import java.net.URLEncoder;
import java.util.Hashtable;

import com.purplehillsbooks.json.JSONObject;
import com.purplehillsbooks.streams.MemFile;
import com.purplehillsbooks.streams.StreamHelper;

public class WebResult {
    private String key;
    private String lastNameQuery;
    private String firstNameQuery;
    public MemFile rawResult = new MemFile();
    public boolean incompleteResults = false;
    public String anticipatedNum = "";
    Hashtable<String, JSONObject> results = new Hashtable<String, JSONObject>();
    
    private URL serverBaseUrl = new URL("https://www.osu.edu/findpeople/");
    /**
     * Constructor that sets credential info
     * @param _credentials
     */
    public WebResult(String combined) throws Exception  {
        key = combined;
        int pos = combined.indexOf("-");
        if (pos>0) {
            lastNameQuery = combined.substring(0,pos)+"*";
            firstNameQuery = combined.substring(pos+1)+"*";
        }
        else {
            lastNameQuery = combined+"*";
            firstNameQuery = "";
        }
    }


    public void postIt(WebStuff web) throws Exception {
        String postBody = "lastname="+URLEncoder.encode(lastNameQuery, "UTF-8")
                +"&firstname="+URLEncoder.encode(firstNameQuery, "UTF-8")+"&name_n=&filter=All"; 
        System.out.println("READING: "+postBody);
        web.postHttpRequestRaw(serverBaseUrl, postBody, rawResult);
    }
    
    public void debugDump(File logFolder) throws Exception {
        File debugFile = new File(logFolder, "page-"+key+".html");
        StreamHelper.copyReaderToFile(rawResult.getReader(), debugFile, "UTF-8");
    }

    public void cacheIt(WebStuff web, File logFolder) throws Exception {

        File debugFile = new File(logFolder, "page-"+key+".html");
        if (debugFile.exists()) {
            System.out.println("LOADING from cache: "+debugFile);
            StreamHelper.copyFileToWriter(debugFile, rawResult.getWriter(), "UTF-8");
        }
        else {
            String postBody = "lastname="+URLEncoder.encode(lastNameQuery, "UTF-8")
                    +"&firstname="+URLEncoder.encode(firstNameQuery, "UTF-8")+"&name_n=&filter=All"; 
            System.out.println("READING: "+postBody);
            web.postHttpRequestRaw(serverBaseUrl, postBody, rawResult);
            System.out.println("WRITING to cache: "+debugFile);
            StreamHelper.copyReaderToFile(rawResult.getReader(), debugFile, "UTF-8");
            Thread.sleep(9999);
        }
    }
    
    
    public void parseIt() throws Exception {
        
        LineReader lineReader = new LineReader(rawResult.getReader());
        
        //read and find the detail of there there were too many records or not
        lineReader.advanceUntil("#results-table", "id=\"results-table");
        
        //we have the results line
        if (lineReader.lineContains("exceed 150 matches")) {
            System.out.println("   TOO MANY");
            incompleteResults = true;
        }
        else if (lineReader.lineContains("Results Found")) {
            anticipatedNum = lineReader.getBetween("<strong>", "</strong>");
            System.out.println("   EXPECTING: "+anticipatedNum);
        }
        
        lineReader.advanceUntil("id=\"results-table");
        
        while (lineReader.advanceUntil("record-collapsed")) {

            String personName = "";
            String email = "";
            String phone = "";
            String major = "";
            String org = "";
            
            if (lineReader.advanceUntil("record-data-name", "record-data-phone")) {
                lineReader.nextLine();
                lineReader.nextLine();
                personName = lineReader.getBefore("<span class=\"off-left\">").trim();
                //System.out.println("    --+   "+personName);
            }
            if (lineReader.advanceUntil("record-data-phone", "record-data-email")) {
                phone = lineReader.getBetween("<a href=\"tel:", "\">");
                
            }
            if (lineReader.advanceUntil("record-data-email", "record-data-major")) {
                email = lineReader.getBetween("<a href=\"mailto:", "\">");
            }
            if (lineReader.advanceUntil("record-data-major", "record-data-org")) {
                major = lineReader.getBetween("data-major\">", "</td>");
            }
            if (lineReader.advanceUntil("record-data-org", "record-details")) {
                org = lineReader.getBetween("data-org\">", "</td>");
            }
            
            if (email.length()>0 && !email.startsWith("★")) {
                JSONObject record = new JSONObject();
                record.put("name", personName );
                record.put("phone", phone );
                record.put("major", major );
                record.put("org", org );
                results.put(email, record);
                System.out.println("    --+   "+email+" - "+personName);
            }
        
        }
        
        //it seems that valid sets extend to 300 records (or 301)
        //so assume that this is valid to 299 and more than that is 
        incompleteResults = results.size()>299;
    }
    
    private boolean findBeginningOfRecord(LineReader lineReader) throws Exception {
        while (true) {
            lineReader.advanceUntil("record-details");
            if (lineReader.line==null) {
                return false;
            }
            if (lineReader.lineContains("record-person")) {
                return true;
            }
        }
    }
    
}
