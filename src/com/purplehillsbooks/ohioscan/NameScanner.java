package com.purplehillsbooks.ohioscan;

import java.io.File;
import java.util.Random;

import com.purplehillsbooks.json.JSONObject;

public class NameScanner {

    File dataFolder = new File("./data");
    File logFolder = new File("./log");
    JSONObject data;
    Random rand = new Random(System.currentTimeMillis());
    WebStuff webStuff;
    
    public NameScanner() throws Exception {
        webStuff = new WebStuff();
    }
    
    public void loadData() throws Exception {
        File dataFile = new File(dataFolder, "ScanRecords.json");
        if (dataFile.exists()) {
            data = JSONObject.readFileIfExists(dataFile);
        }
        else {
            data = new JSONObject();
            data.put("tried", new JSONObject());
        }
        if (!data.has("addresses")) {
            data.put("addresses", new JSONObject());
        }
    }
    public void saveData() throws Exception {
        File dataFile = new File(dataFolder, "ScanRecords.json");
        data.writeToFile(dataFile);
    }
    
    //letters of names are a-z plus apostrophe
    public char pickRandomChar(String possibles) {
        int rval = rand.nextInt(possibles.length());
        return possibles.charAt(rval);
    }
    
    public String pickUntriedQuery() throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        
        int count = 1000;
        while (--count>0) {
            
            //LAST NAME LETTER 1
            String query = ""+pickRandomChar("abcdefghijklmnopqrstuvwxyz");
            
            if (!alreadyTried.has(query)) {
                //if we have never tried this before, return it
                return query;
            }
            
            String lastResult = alreadyTried.getString(query);
            if ("done".equals(lastResult)) {
                continue;
            }
            
            if (!"toomany".equals(lastResult)) {
                throw new Exception("data file should only have 'done' and 'toomany' as values");
            }
            
            //LAST NAME LETTER 2 -- NOTE: can be an apostrophe
            query = query+pickRandomChar("abcdefghijklmnopqrstuvwxyz'");
            if (!alreadyTried.has(query)) {
                //if we have never tried this before, return it
                return query;
            }
            
            lastResult = alreadyTried.getString(query);
            if ("done".equals(lastResult)) {
                continue;
            }
            
            if (!"toomany".equals(lastResult)) {
                throw new Exception("data file should only have 'done' and 'toomany' as values");
            }
            

            //LAST NAME LETTER 3
            query = query+pickRandomChar("abcdefghijklmnopqrstuvwxyz");
            if (!alreadyTried.has(query)) {
                //if we have never tried this before, return it
                return query;
            }
            
            lastResult = alreadyTried.getString(query);
            if ("done".equals(lastResult)) {
                continue;
            }
            
            if (!"toomany".equals(lastResult)) {
                throw new Exception("data file should only have 'done' and 'toomany' as values");
            }
            
            //FIRST NAME LETTER 1
            query = query+"-"+pickRandomChar("abcdefghijklmnopqrstuvwxyz");
            if (!alreadyTried.has(query)) {
                //if we have never tried this before, return it
                return query;
            }
            
            lastResult = alreadyTried.getString(query);
            if ("done".equals(lastResult)) {
                continue;
            }
            
            if (!"toomany".equals(lastResult)) {
                throw new Exception("data file should only have 'done' and 'toomany' as values");
            }
            
            //FIRST NAME LETTER 2
            query = query+pickRandomChar("abcdefghijklmnopqrstuvwxyz");
            if (!alreadyTried.has(query)) {
                //if we have never tried this before, return it
                return query;
            }
            //no matter what after 5 characters just try another
            
        }
        throw new Exception("Searched for 1000 queries and did not find one to search for");
    }
    
    public void markDone(String query) throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        alreadyTried.put(query, "done");
    }
    public void markTooMany(String query) throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        alreadyTried.put(query, "toomany");
    }
    
    
    public void getOnePage() throws Exception {
        String query = pickUntriedQuery();
        WebResult page = new WebResult(query);
        page.cacheIt(webStuff, logFolder);
        page.parseIt();
        
        if (page.exceeds150) {
            markTooMany(query);
            System.out.println("FOUND TOO MANY records for ("+query+")");
            return;
        }
        
        System.out.println("FOUND "+page.results.size()+" records for ("+query+")");
        JSONObject addresses = data.getJSONObject("addresses");
        for (String email : page.results.keySet()) {
            String name = page.results.get(email);
            addresses.put(email, name);
        }
        
        markDone(query);
    }
    
    public static void main(String args[]) {
        try {
            NameScanner ns = new NameScanner();
            int count = 1000;
            while (--count>0) {
                ns.loadData();
                ns.getOnePage();
                ns.saveData();
                //an odd number of seconds >1 minute
                Thread.sleep(99900);
            }
        }
        catch (Exception e) {
            System.out.println("############ EXCEPTION ##############");
            e.printStackTrace();
        }
    }
}
