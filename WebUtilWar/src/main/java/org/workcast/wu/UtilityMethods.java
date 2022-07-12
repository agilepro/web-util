package org.workcast.wu;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class UtilityMethods
{

    public static String subString(String s, int pos, int len)
        throws Exception
    {
        try {
            return s.substring(pos, len);
        }
        catch (Exception e) {
            throw new Exception("Substring exception: ["
                  +s+"] (len "+s.length()+") at "
                  +pos+" for len "+len+"; "+e.getMessage());
        }
    }


    static public List<String> splitOnDelimiter (String str, char delim)
    {
        ArrayList<String> vec = new ArrayList<String>();
        int pos = 0;
        int last = str.length();
        while (pos<last) {
            int nextpos = str.indexOf(delim, pos);
            if (nextpos >= pos) {
                vec.add(str.substring(pos, nextpos));
            }
            else {
                vec.add(str.substring(pos));
                break;
            }
            pos = nextpos + 1;
        }
        return vec;
    }


    public static String getXMLDateFormat(long ms)
    {
        if (ms <= 0)
            return "";
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ss'Z'");
        Date dt = new Date(ms);
        return sdf.format(dt);
    }

    public static long getDateTimeFromXML(String date)
        throws Exception
    {
        if(date == null)
            return 0;
        if(date.trim().equals(""))
            return 0;
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'hh:mm:ss'Z'");
        return sdf.parse(date).getTime();
    }

}