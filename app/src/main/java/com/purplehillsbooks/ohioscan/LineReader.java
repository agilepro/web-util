package com.purplehillsbooks.ohioscan;

import java.io.BufferedReader;
import java.io.Reader;

public class LineReader {

    public BufferedReader lineReader;
    public String line;
    int lineNo = 0;
    
    public LineReader(Reader r) throws Exception  {
        lineReader = new BufferedReader(r);
        //go ahead and read the first line so there is something in the buffer
        nextLine();
    }
    
    public String nextLine() throws Exception {
        line = lineReader.readLine();
        lineNo++;
        return line;
    }

    public boolean advanceUntil(String token) throws Exception {
        if (line==null) {
            return false;
        }
        while (true) {
            if (line.indexOf(token)>0) {
                //System.out.println("            line "+lineNo+" has "+token);
                return true;
            }
            nextLine();
            if (line==null) {
                return false;
            }
        }
    }
    
    public boolean advanceUntil(String token, String stopper) throws Exception {
        if (line==null) {
            return false;
        }
        while (true) {
            if (line.indexOf(token)>0) {
                //System.out.println("            line "+lineNo+" has "+token);
                return true;
            }
            if (line.indexOf(stopper)>0) {
                return false;
            }
            nextLine();
            if (line==null) {
                return false;
            }
        }
    }
    
    public boolean lineContains(String token) throws Exception {
        if (line==null) {
            return false;
        }
        if (line.indexOf(token)>0) {
            //System.out.println("            line "+lineNo+" has "+token);
            return true;
        }
        return false;
    }
    
    public String getBetween(String pre, String post) {
        int pos1 = line.indexOf(pre);
        if (pos1<0) {
            System.out.println("            line "+lineNo+" MISSING "+pre);
            return "★1-"+pre;
        }
        pos1 = pos1 + pre.length();
        int pos2 = line.indexOf(post, pos1);
        if (pos2<pos1) {
            System.out.println("            line "+lineNo+" MISSING "+post);
            return "★2-"+post;
        }
        return line.substring(pos1, pos2);
    }
    public String getBefore(String post) {
        int pos2 = line.indexOf(post);
        if (pos2<0) {
            System.out.println("            line "+lineNo+" MISSING "+post);
            return "★3-"+post;
        }
        return line.substring(0, pos2);
    }

}
