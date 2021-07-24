/*
 * ConnectionTest.java
 */
package org.workcast.wu;

import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
* This cass fetches a specified web resource every ten seconds and it reports whether it
* is able to fetch it or not.  This is for testing whether your internet connection
* is functioning over a long period of time.  Writes a simple log file recording
* time and success or failure.
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class ConnectionTest
{

    public ConnectionTest()
        throws Exception
        {
        }


    public static String formatDateTime(long ms)
    {
        if (ms <= 0) {
            return "";
        }
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd hh-mm-ss");
        Date dt = new Date(ms);
        return sdf.format(dt);
    }



    static public void main(String[] args)
    {
        OutputStreamWriter osw = null;
        try
        {
            if (args.length!=1)
            {
                throw new Exception("ConnectionTest requires one parameter:\n 1. the web address to request to\n");
            }
            String address = args[0];
            if (!address.startsWith("http"))
            {
                throw new Exception("got web address: "+address+"\nplease include the entire web address including 'http://'");
            }
            long targetTime = System.currentTimeMillis();
            String formattedStartTime = formatDateTime(targetTime);

            String logFile = "ConnectionTest_"+formattedStartTime+".txt";
            FileOutputStream fos = new FileOutputStream(logFile);
            osw = new OutputStreamWriter(fos, "UTF-8");

            osw.write("ConnectionTest Log\n");
            osw.write("Starting at ");
            osw.write(formattedStartTime);
            osw.write("\nFetching address: ");
            osw.write(address);
            osw.write("\n-------------------------------------\n");
            osw.write("Count,Time,Result,BytesRead,Duration\n");
            osw.flush();

            URL destAddress = new URL(address);
            int count = 0;
            targetTime = targetTime + 100;

            while (true)
            {
                count++;
                long requestTime = System.currentTimeMillis();
                String formattedTargetTime = formatDateTime(targetTime);

                //if a request takes a long time, far greater than 10 seconds,
                //this will print all the entries for the time slots that were
                //missed.  This will yeild a more accurate measure of uptime.
                if (requestTime > targetTime+150)
                {
                    osw.write(Long.toString(count));
                    osw.write(",\"");
                    osw.write(formattedTargetTime);
                    osw.write("\",\"Missed\",0,0\n");
                    osw.flush();
                    System.out.print("\n"+formattedTargetTime+" Missed");
                    targetTime = targetTime + 10000;
                    continue;
                }
                if (requestTime<targetTime)
                {
                    Thread.sleep(targetTime-requestTime);
                }
                requestTime = System.currentTimeMillis();
                String result = "Nothing Read";

                int size = 0;
                try
                {
                    //open a connection
                    InputStream aStream = destAddress.openStream();

                    //read to the end of the file
                    int ch = aStream.read();
                    while (ch >= 0)
                    {
                        size++;
                        ch = aStream.read();
                    }

                    if (size>0)
                    {
                        result = "Success";
                    }
                }
                catch (Exception e)
                {
                    result = "Exception: "+e.toString();
                }
                //calculate time
                long finalTime = System.currentTimeMillis();
                long duration = finalTime - requestTime;
                osw.write(Long.toString(count));
                osw.write(",\"");
                osw.write(formattedTargetTime);
                osw.write("\",\"");
                osw.write(result);
                osw.write("\",");
                osw.write(Integer.toString(size));
                osw.write(",");
                osw.write(Long.toString(duration));
                osw.write("\n");
                osw.flush();

                System.out.print("\n"+formattedTargetTime+" "+result);

                targetTime = targetTime + 10000;
            }

        }
        catch(Exception e)
        {
            System.out.print("ConnectionTest has ended because of a problem:\n");
            System.out.print(e.toString());
        }
        finally {
            if (osw!=null) {
                try {
                    osw.close();
                }
                catch(Exception e) {
                    //nothing we can do here as we exit...
                }
            }
        }
    }
}