package com.purplehillsbooks.ohioscan;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import com.purplehillsbooks.json.JSONArray;
import com.purplehillsbooks.json.JSONObject;
import com.purplehillsbooks.streams.CSVHelper;

public class NameScanner {

    File dataFolder = new File("./data");
    File logFolder = new File("./log");
    JSONObject data;
    Random rand = new Random(System.currentTimeMillis());
    WebStuff webStuff;
    List<String> remainingQueries;
    List<String> remainingShortQueries;
    
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
        if (remainingShortQueries.size()==0) {
            findAllRemainingQueries();
        }
        int rval = rand.nextInt(remainingShortQueries.size());
        String newGuess = remainingShortQueries.get(rval);
        remainingShortQueries.remove(newGuess);
        return newGuess;
    }
    public String pickUntriedQueryOld() throws Exception {
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
    
    String alphabet = "aeioubcdfghjklmnpqrstvwxyz";
    public void findAllRemainingQueries() throws Exception {
        remainingQueries = new ArrayList<String>();
        recursiveFind0(remainingQueries, "");
        recursiveFind2(remainingQueries, "o'");
        JSONArray untried = new JSONArray();
        int shortest = 99;
        for (String val : remainingQueries) {
            if (val.length()<shortest) {
                shortest = val.length();
            }
            System.out.println("  -->"+val);
            untried.put(val);
        }
        remainingShortQueries = new ArrayList<String>();
        for (String val : remainingQueries) {
            if (val.length()==shortest) {
                remainingShortQueries.add(val);
            }
        }
        
        if (remainingShortQueries.size()>200) {
            ArrayList<String> evenShorter = new ArrayList<String>();
            for (String val : remainingShortQueries) {
                char ch = val.charAt(val.length()-1);
                if (ch=='a' || ch=='e' || ch=='i' || ch=='o' || ch=='u') {
                    evenShorter.add(val);
                }
            }
            if (evenShorter.size()==0) {
                for (String val : remainingShortQueries) {
                    char ch = val.charAt(val.length()-1);
                    if (ch=='t' || ch=='r' || ch=='h' || ch=='l' || ch=='n') {
                        evenShorter.add(val);
                    }
                }
            }
            if (evenShorter.size()>0) {
                remainingShortQueries = evenShorter;
            }
        }
        data.put("untried", untried);
        System.out.println("There are "+remainingQueries.size()+" untried queries remaining, and "+remainingShortQueries.size()+" short ones.");
    }
    
    private void recursiveFind0(List<String> results, String query) throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        for (int i=0; i<alphabet.length(); i++) {
            String newQuery = query + alphabet.charAt(i);
            if (!alreadyTried.has(newQuery)) {
                results.add(newQuery);
            }
            else {
                String val = alreadyTried.getString(newQuery);
                if ("toomany".equals(val)) {
                    recursiveFind1(results, newQuery);
                }
            }
        }
    }
    private void recursiveFind1(List<String> results, String query) throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        for (int i=0; i<alphabet.length(); i++) {
            String newQuery = query + alphabet.charAt(i);
            if (!alreadyTried.has(newQuery)) {
                results.add(newQuery);
            }
            else {
                String val = alreadyTried.getString(newQuery);
                if ("toomany".equals(val)) {
                    recursiveFind2(results, newQuery);
                }
            }
        }
    }
    private void recursiveFind2(List<String> results, String query) throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        for (int i=0; i<alphabet.length(); i++) {
            String newQuery = query + alphabet.charAt(i);
            if (!alreadyTried.has(newQuery)) {
                results.add(newQuery);
            }
            else {
                String val = alreadyTried.getString(newQuery);
                if ("toomany".equals(val)) {
                    recursiveFind3(results, newQuery);
                }
            }
        }
    }
    private void recursiveFind3(List<String> results, String query) throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        for (int i=0; i<alphabet.length(); i++) {
            String newQuery = query + "-" + alphabet.charAt(i);
            if (!alreadyTried.has(newQuery)) {
                results.add(newQuery);
            }
            else {
                String val = alreadyTried.getString(newQuery);
                if ("toomany".equals(val)) {
                    recursiveFind4(results, newQuery);
                }
            }
        }
    }
    private void recursiveFind4(List<String> results, String query) throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        for (int i=0; i<alphabet.length(); i++) {
            String newQuery = query + "-" + alphabet.charAt(i);
            if (!alreadyTried.has(newQuery)) {
                results.add(newQuery);
            }
            else {
                String val = alreadyTried.getString(newQuery);
                if ("toomany".equals(val)) {
                    recursiveFind5(results, newQuery);
                }
            }
        }
    }
    private void recursiveFind5(List<String> results, String query) throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        for (int i=0; i<alphabet.length(); i++) {
            String newQuery = query + alphabet.charAt(i);
            if (!alreadyTried.has(newQuery)) {
                results.add(newQuery);
            }
            else {
                String val = alreadyTried.getString(newQuery);
                if ("toomany".equals(val)) {
                    recursiveFind5(results, newQuery);
                }
            }
        }
    }
    
    public void markDone(String query) throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        alreadyTried.put(query, "done");
        System.out.println("Marked query ("+query+") as DONE, total query count = "+alreadyTried.length());
    }
    public void markTooMany(String query) throws Exception {
        JSONObject alreadyTried = data.getJSONObject("tried");
        alreadyTried.put(query, "toomany");
        System.out.println("Marked query ("+query+") as incomplete, total query count = "+alreadyTried.length());
    }
    
    
    public void getOnePage() throws Exception {
        String query = pickUntriedQuery();
        WebResult page = new WebResult(query);
        page.cacheIt(webStuff, logFolder);
        page.parseIt();
        
        
        JSONObject addresses = data.getJSONObject("addresses");
        for (String email : page.results.keySet()) {
            JSONObject record = page.results.get(email);
            if (!addresses.has(email)) {
                addresses.put(email, record);
            }
        }
        
        if (page.incompleteResults) {
            System.out.println("FOUND "+page.results.size()+" records for ("+query+") but INCOMPLETE");
            markTooMany(query);
        }
        else {
            System.out.println("FOUND "+page.results.size()+" records for ("+query+") - done");
            markDone(query);
        }
    }
    
    public void dumpCSV() throws Exception {
        JSONObject addresses = data.getJSONObject("addresses");
        
        File csvFile = new File(dataFolder, "addresses"+System.currentTimeMillis()+".csv");
        OutputStream os = new FileOutputStream(csvFile);
        Writer w = new OutputStreamWriter(os,"UTF-8");
        
        ArrayList<String> row = new ArrayList<String>();
        row.add("email");
        row.add("name");
        row.add("phone");
        row.add("major");
        row.add("org");
        CSVHelper.writeLine(w, row);
        
        ArrayList<String> sortedKeys = new ArrayList<String>();
        for (String key : addresses.keySet()) {
            sortedKeys.add(key);
        }
        
        Collections.sort(sortedKeys);
        for (String key : sortedKeys) {
            JSONObject val = addresses.getJSONObject(key);
            row = new ArrayList<String>();
            row.add(key);
            row.add(val.getString("name"));
            row.add(val.getString("phone"));
            row.add(val.getString("major"));
            row.add(val.getString("org"));
            CSVHelper.writeLine(w, row);
        }
        
        w.close();
        os.close();
    }
    
    public static void main(String args[]) {
        try {
            NameScanner ns = new NameScanner();
            int count = 1000;
            ns.loadData();
            ns.dumpCSV();
            ns.findAllRemainingQueries();
            ns.saveData();
            while (--count>0) {
                ns.loadData();
                ns.getOnePage();
                ns.saveData();
                //most of delay is in the web request
                //Thread.sleep(200);
            }
        }
        catch (Exception e) {
            System.out.println("############ EXCEPTION ##############");
            e.printStackTrace();
        }
    }
}
