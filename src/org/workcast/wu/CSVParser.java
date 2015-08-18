/*
 * WebRequest.java
 */
package org.workcast.wu;

import java.io.Reader;
import java.util.Vector;

/**
* Parses a CVS file, and returns a vector of vectors
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
@SuppressWarnings("serial")
public class CSVParser extends javax.servlet.http.HttpServlet
{
    //since we read line by line, but a quote can contain return
    //characters, so for each line we have to remember whether we
    //are in a quote or not.

    boolean inQuote = false;
    Vector<Vector<String>>  results = new Vector<Vector<String>>();
    Vector<String>  currentRow = new Vector<String>();
    StringBuffer currentValue;  //used when value extends beyond line

    public CSVParser()  {}

    public Vector<Vector<String>> parseStream(Reader input)
        throws Exception
    {
        currentValue = new StringBuffer();

        int ch = input.read();
        while (ch != -1)
        {
            if (inQuote)
            {
                if (ch == '"')
                {
                    inQuote=false;
                }
                else
                {
                    currentValue.append((char)ch);
                }
            }
            else
            {
                if (ch == '"')
                {
                    inQuote=true;
                }
                else if (ch == ',')
                {
                    //terminate the current value, start another
                    currentRow.add(currentValue.toString());
                    currentValue = new StringBuffer();
                }
                else if (ch == '\n')
                {
                    //terminate the current value, start another
                    //also terminate the current row, start another
                    currentRow.add(currentValue.toString());
                    currentValue = new StringBuffer();
                    results.add(currentRow);
                    currentRow = new Vector<String>();
                }
                else
                {
                    currentValue.append((char)ch);
                }
            }
        }

        currentRow.add(currentValue.toString());
        results.add(currentRow);
        return results;
    }

}
