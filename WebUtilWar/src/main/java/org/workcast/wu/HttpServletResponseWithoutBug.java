/*
 * HttpServletResponseWithoutBug.java
 */
package org.workcast.wu;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.OutputStreamWriter;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

/**
* HttpServletResponse has this *strange* limitation that you can
* call getOutputStream() once, or getWriter() once, but not both.
* If any of the code, calls
* it a second time, it throws an exception telling you that it
* has already been called.  Here is the problem, it is impossible
* to know if a piece of code is the first time calling the method
* or not.  There are a lot of public libraries that help to handle
* responses, specifically the JSP page handlers, that assume they
* are the only thing needing access to the output stream.
* We end up writing elaborate code to attempt to track which bit of
* code needs the output handler, and avoiding getting it, and when
* getting it, putting it in a temporary variables, and forcing
* other code which is after that point to go to the variable, etc.
* It is all a lot of coding complication and involves setting in
* place patterns which the public libraries are not designed to handle.
*
* This class caches a copy of the output stream, and makes sure
* that getOutputStream on the super class is called only once
* and lets the method on this version be called more that once
* without throwing an exception.  This gives flexibility for a
* method that uses output stream for just a few moments to get it
* straint from the response class, and not worry whether it is
* the first routine making that request or not.
*
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class HttpServletResponseWithoutBug extends javax.servlet.http.HttpServletResponseWrapper
{
    public ServletOutputStream out;
    public PrintWriter writer;


    public HttpServletResponseWithoutBug(HttpServletResponse nresp)
    {
        super(nresp);

        //There is some small chance that this may help solve another bug
        //which is that even though a form is specified with UTF-8 encoding
        //the browser does not always send the character set.
        //if the "writer" is fetched before you are able to set the encoding
        //then you are stuck with ISO-8859-1 even if the data is UTF-8 encoded.
        //This will assure that JSP servlet gets the right encoding.
        //I know it is a big heavy handed, but all of our code ALWAYS uses UTF-8
        //and ALWAYS received UTF-8.  There is no reason to support any other
        //character set, because UTF-8 is supported by all browsers, and it
        //holds all of the characters that can be expressed in Java.
        nresp.setCharacterEncoding("UTF-8");
    }

    /**
    * the only point of this method is to make sure that the method
    * getOutputStream is called only once.
    */
    public ServletOutputStream getOutputStream()
        throws IOException
    {
        if (out!=null)
        {
            return out;
        }
        out = super.getOutputStream();
        return out;
    }

    /**
    * the only point of this method is to make sure that the method
    * getWriter or getOutputStream is called only once.
    */
    public PrintWriter getWriter()
        throws IOException
    {
        if (writer!=null)
        {
            return writer;
        }
        if (out==null)
        {
            out = super.getOutputStream();
        }
        if (out!=null)
        {
            //note we REQUIRE UTF-8 at this point as well
            writer = new PrintWriter(new OutputStreamWriter(out, "UTF-8"));
        }
        return writer;
    }

}