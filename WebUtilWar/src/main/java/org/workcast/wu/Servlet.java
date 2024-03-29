/*
 * NGLeafServlet.java
 */
package org.workcast.wu;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
* This servlet serves up pages using the following URL format:
*
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
@SuppressWarnings("serial")
public class Servlet extends jakarta.servlet.http.HttpServlet
{

    protected void service(HttpServletRequest request, HttpServletResponse response)
                throws ServletException, java.io.IOException
    {
        try {
            OldWebRequest wr = OldWebRequest.getOrCreate(request, response, null);
            try {
                doWebService(wr);
            }
            catch (Exception e)
            {
                handleException(e, wr);
            }
        }
        catch (Exception e) {
            throw new IOException("Wrapped exception to conform to signature", e);
        }
        //wr.logCompletedRequest();
    }


    /**
    * This is the method that subclasses should implement
    */
    private void doWebService(OldWebRequest wr) throws Exception
    {

        try {

            List<String> parsedPath = wr.getParsedPath();

            if (parsedPath.size()<=1)
            {
                //this the case of an empty string after servlet mount point
                wr.invokeJSP("index.jsp");
                wr.flush();
                return;
            }

            //note: element 0 is always a zero length string

            String firstPart = parsedPath.get(1);
            wr.request.setAttribute("p", firstPart);

            //resource is anything after the book id, could a complex path
            //itself, if it involves attachments or subaddressing
            String resource = "index.htm";
            if (parsedPath.size()>2)
            {
                resource = parsedPath.get(2);
            }
            if (resource.endsWith(".htm"))
            {
                String jspName = resource.substring(0, resource.length()-4)+".jsp";
                wr.invokeJSP(jspName);
            }
            else
            {
                throw new Exception("No idea what resource '"+resource+"' is.");
            }


        } catch (Exception e) {
            handleException(e, wr);
        }
    }

    public void init(ServletConfig config)
          throws ServletException
    {
        try
        {
            /*ServletContext sc = */  config.getServletContext();
        }
        catch (Exception e)
        {
            throw new ServletException("Unable to initialize the servlet.", e);
        }
    }

    private void handleException(Exception e, OldWebRequest wr)
    {
        try
        {
            //wr.logException("NG Leaf Servlet", e);

            wr.response.setContentType("text/html;charset=UTF-8");
            wr.write("<html><body><ul><li>Exception: ");
            wr.writeHtml(e.toString());
            wr.write("</li></ul>\n");
            wr.write("<hr/>\n");
            wr.write("<a href=\"main.jsp\" title=\"Access the main page\">Main</a>\n");
            wr.write("<hr/>\n<pre>");
            e.printStackTrace(new PrintWriter(wr.w));
            wr.write("</pre></body></html>\n");
            wr.flush();
        } catch (Exception eeeee) {
            // nothing we can do here...
        }
    }

}
