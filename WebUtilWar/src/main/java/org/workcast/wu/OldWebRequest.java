package org.workcast.wu;

import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.io.Writer;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.purplehillsbooks.json.SimpleException;
import com.purplehillsbooks.streams.HTMLWriter;
import com.purplehillsbooks.streams.JavaScriptWriter;
import com.purplehillsbooks.streams.MemFile;
import com.purplehillsbooks.web.WebRequest;

/**
* WebRequest is the "Authorized Web Request and Response" class for the
* consolidated way of responding to HTTP requests.  This class wraps both the
* HTTPRequest and the HTTPResponse objects, and carries them around to
* whatever handler.  It also provides some uniform services around such a
* request.  For example:
*
* Identifying the user: this class will automatically detect in the headers
*     or in the session who the user is (by openid) and it will maintain
*     cookies that the user or session might use in the future
*
* Parsing the path: provide consistent mechanism for parsing and decoding
*     the request path.  You get an array of decoded strings.
*
* Output Stream and Writer: handles this approrpiately, including a
*     copy constructor that allows you to substitute a different writer.
*
* HTTPRequest & HTTPResponse: still lets you have access to these when needed.
*
* The standard patterns for all servlets should be:
*
* public void doGet(HttpServletRequest request, HttpServletResponse response)
* {
*      WebRequest wr = WebRequest.getOrCreate(request, response, null);
*      ....
*      ar.flush();
* }
*
* All subsequent code should use the "wr" object, you can get the request
* or response objects from that if necessary, but more important the userid,
* path parsing, and access control will all be handled through that consistently.
* If a handler is a subroutine, pass the "ar" object for convenience.
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/

public class OldWebRequest extends com.purplehillsbooks.web.WebRequest {

    //openid is the user name
    public String   openid;
    public String   licenseid;


    //address of this page that this servlet was mapped to, will be
    //something like "/p" or "/b".   Same as "request.getServletPath()"
    public String servletPath = "";

    //the relative path parsed and properly URLDecoded into an
    //array of string.
    private List<String> parsedPath = null;

    //The relative return path back to the base of the application
    public String retPath = "";

    public MemFile      memBuffer;

    //this request may take a few millisecond.  We record the time that
    //the request STARTED, and use that for all timestamps.  Within the
    //execution of this request, and updating of pages, you should NEVER
    //use currentTimeMillis, but use this nowTime instead for all current
    //time uses.  This way the markings will always be consistent regardless
    //of how slow the server is.
    public long nowTime;


    /**
    * First look to see if this request already has constructed a WebRequest object
    * and if so, use that.  If not, construct one.  This prevents many copies of the
    * object (with different settings) from being created along the way.
    *
    * From a JSP you have to pass in the writer, because the JSP framework plays
    * with the writer.  From other places you can pass null.
    */
    public static OldWebRequest getOrCreate(HttpServletRequest  areq, HttpServletResponse aresp, Writer aw)
            throws Exception {
        WebRequest wr = WebRequest.findOrCreate(areq, aresp, aw);
        if (wr == null || !(wr instanceof OldWebRequest)) {
            OldWebRequest owr = new OldWebRequest(areq,aresp,aw);
            areq.setAttribute("AuthRequest", owr);
            return owr;
        }
        else  {
            OldWebRequest owr = (OldWebRequest) wr;
            owr.setWriter(aw);
            return owr;
        }
        //can't get here
    }


    /**
    * constructor: if this object is constructed in a servlet, then pass
    * a NULL to the newWriter paramter, and the output stream will be
    * retrieved from the response object in a safe way.
    * If object is constructed in a JSP page, then getWriter has already
    * been called on the request, and you must pass the writer in here
    * so that we can avoid calling this method twice
    */
    private OldWebRequest(HttpServletRequest  areq, HttpServletResponse aresp, Writer aw) throws Exception {
        super(areq,aresp,aw);
        try
        {
            request.setCharacterEncoding("UTF-8");

            response.setContentType("text/html;charset=UTF-8");

            nowTime = System.currentTimeMillis();

            resolveUser();

            servletPath = request.getServletPath();
            if (servletPath==null)
            {
                throw new Exception("Hmmmmmmm, no servlet path???");
            }

            retPath = getRelPathFromCtx();

        }
        catch (Exception e)
        {
            // This should happen only if the server is very confused about itself.
            throw new RuntimeException("Unable to create a web request object.  ", e);
        }
    }

    /**
    * this copy constructor allows you to access according to the access
    * rights of the original request, but substitute a different writer
    * so that you can, for example, create a file, or generate test output.
    */
    private OldWebRequest(OldWebRequest oldAr, Writer newWriter) throws Exception {
        this(oldAr.request, oldAr.response, newWriter);
    }



    public void setWriter(Writer aw) {
          w = aw;
    }


    /**
    * This is a rather goofy routine to get around the limitations of the
    * HTTP servlet classes.  It seems that somebody thought that if you ask
    * for both the output stream and the write at the same time, you might
    * try to abuse this, by using them at the same time.  Actually this is
    * a problem only if you create a BufferedWriter, write to that writer,
    * and then write to the output stream BEFORE flushing what you have in
    * the writer.  So there is this code that allows you to get the OutputStream
    * and then throws an exception if you try to get the Writer, and vice versa
    * so that you can only get one per request.
    *
    * The problem is that you sometimes need an OutputStream and a Writer
    * will simply not do.   This creates a buffered output stream, that
    * then writes to the Writer (which in turn writes to an output stream
    * which you are not allowed access to).  It is very gross.
    *
    * If you write to this stream, BE SURE to call flush before you write
    * anything else to the writer!   Whatever is written to this stream
    * is being buffered up in a byte array, and flush will cause it to
    * be actually written out to the web page.
    */
    public OutputStream getBufferedOutputStream()
        throws Exception
    {
        if (memBuffer!=null)
        {
            throw new Exception("current implementation you have to get the output stream once, and then flush it before getting it again.");
        }
        memBuffer = new MemFile();
        return memBuffer.getOutputStream();
    }

    public void flush()
        throws Exception
    {
        if (memBuffer!=null)
        {
            memBuffer.outToWriter(w);
            memBuffer = null;
        }
        w.flush();
    }


    /**
    * take the relative path, split it on slash characters, and
    * and parse it into an array os string values, properly converting
    * each element of the array for URL encoding.
    */
    public List<String> getParsedPath()
    {
        if (parsedPath!=null)
        {
            return parsedPath;
        }
        String ctxtroot = request.getContextPath();
        String requrl = request.getRequestURL().toString();
        int indx = requrl.indexOf(ctxtroot);
        int bindx = indx + ctxtroot.length() + 1;

        List<String> pieces = UtilityMethods.splitOnDelimiter(requrl.substring(bindx), '/');
        List<String> decoded = new ArrayList<String>();

        //must do the URLDecoding AFTER parsing the slashes out
        for (String piece : pieces)
        {
            try
            {
                decoded.add(URLDecoder.decode(piece, "UTF-8"));
            }
            catch (java.io.UnsupportedEncodingException e)
            {
                //it is really not possible that UTF-8 is not supported
                //but in that case, leave it encoded.
                decoded.add(piece);
            }
        }

        parsedPath = decoded;
        return parsedPath;
    }



    private void resolveUser() throws Exception
    {
        String userid = request.getHeader("Authorization");
        if(userid != null)
        {
            String lid = null;
            int indx1 = userid.indexOf("://");
            if(indx1 < 0) {
                indx1 = 0;
            }
            else {
                indx1 = indx1 + 3;
            }

            int indx2 = userid.indexOf(':', indx1);
            if(indx2 > 0)
            {
                lid = userid.substring(indx2+1);
                userid = userid.substring(0, indx2);
            }
            openid = userid;
            licenseid = lid;
        }
        else
        {
            openid = (String) session.getAttribute("openid");
        }
    }


    /**
    * Returns true if you have an actuall logged in (authenticated) user
    * Returns false if current access is anonymous.
    */
    public boolean isLoggedIn()
    {
        //logic is simple now, but might get more complex in future
        return (openid!=null);
    }

    public void setLoggedIn(String newId)
    {
        openid = newId;
        session.setAttribute("openid", openid);
    }


    public void assertLoggedIn(String opDescription)
        throws Exception
    {
        if (!isLoggedIn())
        {
            throw new Exception(opDescription + " This operation requires you "
                 +"to be logged in.  If you logged in earlier, your session may have timed out");
        }
    }

    /**
    * If the user had logged in in the past, we will have saved a copy of the
    * user id in the browser cookies.  This retrieve that ID from the cookies
    * if there is on, or return a zero length string if not.
    */
    public String getFormerId()
    {
        String possibleOpenID = "";
        Cookie[] cookies = request.getCookies();
        if (cookies!=null)
        {
            for (int i=0; i<cookies.length; i++)
            {
                Cookie oneCookie = cookies[i];
                if (oneCookie != null) {
                    String cName = oneCookie.getName();
                    if (cName != null && "previousId".equals(cName))
                    {
                        possibleOpenID = oneCookie.getValue();
                    }
                }
            }
        }
        return possibleOpenID;
    }


    /**
    * Return the URL that got us here, so we can redirect back as necessary.
    */
    public String getRequestURL()
    {
        if (request!=null)
        {
            return request.getRequestURL().toString();
        }
        return "unknown request url";
    }

    public String getServerPath()
    {
        String serverURL = "";
        if (request != null)
        {
            String ctxtroot = request.getContextPath();
            String requrl = request.getRequestURL().toString();
            int indx = requrl.indexOf(ctxtroot);
            serverURL = requrl.substring(0, indx) + ctxtroot + "/";
        }

        return serverURL;
    }


    /**
    * Convenience method.  If you want to write to the output stream of a
    * request, this will alow you to write without having to get the
    * output stream and call write on it.
    */
    public void write(String t)
        throws Exception
    {
        w.write(t);
    }
    public void write(char ch)
        throws Exception
    {
        w.write(ch);
    }



    public void writeHtml(String t) throws Exception {
        HTMLWriter.writeHtml(w,t);
    }

    public void writeHtmlWithLines(String t) throws Exception {
        HTMLWriter.writeHtmlWithLines(w,t);
    }

    public void writeJS(String t) throws Exception {
        JavaScriptWriter.encode(w,t);
    }

    
    
    public void writeURLData(String data)
        throws Exception
    {
        // avoid NPE.
        if (data == null || data.length() == 0)
        {
            return;
        }

        String encoded = URLEncoder.encode(data, "UTF-8");

        //here is the problem: URL encoding says that spaces can be encoded using
        //a plus (+) character.  But, strangely, sometimes this does not work, either
        //in certain combinations of browser / tomcat version, using the plus as a
        //space character does not WORK because the plus is not removed by Tomcat
        //on the other side.
        //
        //Strangely, %20 will work, so we replace all occurrances of plus with %20.
        //
        //I am not sure where the problem is, but if you see a URL with plus symbols
        //in mozilla, and the same URL with %20, they look different.  The %20 is
        //replaced with spaces in the status bar, but the plus is not.
        //
        int plusPos = encoded.indexOf("+");
        int startPos = 0;
        while (plusPos>=startPos)
        {
            if (plusPos>startPos)
            {
                //third parameter is length of span, not end character
                w.write(encoded, startPos, plusPos-startPos);
            }
            w.write("%20");
            startPos = plusPos+1;
            plusPos = encoded.indexOf("+", startPos);
        }
        int last = encoded.length();
        if (startPos<last)
        {
            //third parameter is length of span, not end character
            w.write(encoded, startPos, last-startPos);
        }
    }


    /**
    * sometimes TomCat will fail to decode the parameters as UTF-8
    * because the indication that the paramters are in UTF-8 come
    * in TOO LATE for the parsing.  So, instead of re-parsing the parameters
    * according to the desired character set, it leaves them in ISO-8859-1
    * which is the default asdefined by the servlet spec.
    * This flag indicates that we have detected this situation, and if it
    * is set to true, it will do an extra decoding of the parameter from
    * 8859-1 to UTF-8.
    */
    boolean needTomcatKludge = false;

    /**
    * This method should be called once, before fetching any of the parameters
    * It looks for a parameter called "encodingGuard" which it expects to see
    * with the Kanji characters for "Tokyo" in it.  If it sees the parameter,
    * and it sees that it is distorted, then it turns on the TomCat kludge.
    */
    public void setTomcatKludge(HttpServletRequest request)
    {
        //here we are testing is TomCat is configured correctly.  If it is this value
        //will be received uncorrupted.  If not, we will attempt to correct things by
        //doing an additional decoding
        String encodingGuard = request.getParameter("encodingGuard");
        needTomcatKludge = !(encodingGuard==null || "\u6771\u4eac".equals(encodingGuard));
    }


    /**
    * Get a paramter value from the request stream.  If that parameter
    * is not in the request, then look and see if it is an attribute of the
    * reuqest that was put there by code doing a server side redirect to the
    * JSP file.  If that is not there either, then return the default instead.
    */
    public String defParam(String paramName, String defaultValue) {
        String val = request.getParameter(paramName);
        if (val!=null)
        {
            // this next line should not be needed, but I have seen this hack recommended
            // in many forums.  See setTomcatKludge() above.
            if (needTomcatKludge) {
                try {
                    val = new String(val.getBytes("iso-8859-1"), "UTF-8");
                }
                catch (UnsupportedEncodingException e) {
                    // this is impossible.  UTF-8 is always supported
                }
            }
            return val;
        }

        //try and see if it a request attribute
        val = (String)request.getAttribute(paramName);
        if (val != null)
        {
            return val;
        }

        return defaultValue;
    }


    /**
    * Get a required parameter.  If the parameter i not found, generate an error
    * message for that.  When a page contains a link to another page, it should
    * have all of the require parameters in it.  If a parameter is missing, then
    * it is a basic programming error that should be caught and fixed before
    * release.  This routine is to make it easy to find and fix missing parameters.
    *
    * The exception that is thrown will not be seen by users.  Once all of the pages
    * have proper URLs constricted for redirecting to other pages, this error will
    * not occur.  Therefor, there is no need to localize this exception.
    */
    public String reqParam(String paramName) {
        String val = defParam(paramName, null);
        if (val == null || val.length()==0) {
            //The exception that is thrown will not be seen by users.  Once all of the pages
            //have proper URLs constricted for redirecting to other pages, this error will
            //not occur.  Therefor, there is no need to localize this exception.
            throw new SimpleException("A parameter named '%s' is required for page %s", paramName, getRequestURL());
        }
        return val;
    }



    /**
    * Given the name of a JSP file, this will call it, and the
    * output will appear in the place of the call.
    */
    public void invokeJSP(String JSPName) throws Exception {
        w.flush();
        response.setContentType("text/html;charset=UTF-8");
        String relPath = getRelPathFromCtx();
        RequestDispatcher rd = request.getRequestDispatcher(relPath + JSPName);
        rd.include(request, response);
        flush();
    }




    private String getRelPathFromCtx() throws Exception {
        if (request == null) {
            throw new Exception("getRelPathFromCtx requires a request object to be set, but it is null");
        }

        String pageUrl = request.getRequestURL().toString();
        String context = request.getContextPath() + "/";
        int contextPos = pageUrl.indexOf(context);
        if (contextPos == -1) {
            throw new Exception("Something is wrong, the context path can not be found in the current URL.  "
                    +"This should never happen.  Request URL is '"+pageUrl+"' and context is '"+context+"'");
        }

        StringBuffer relPath = new StringBuffer();
        String strOfIntrest = pageUrl.substring(contextPos + context.length());
        for (int i=0; i<strOfIntrest.length(); i++)  {
            char c = strOfIntrest.charAt(i);
            if (c == '/') {
                relPath.append("../");
            }
        }
        return relPath.toString();
    }


    //////////////////////// SESSION ///////////////////////////


    public String getSessionString(String paramName, String defaultValue) {
        String val = (String) session.getAttribute(paramName);
        if (val == null) {
            session.setAttribute(paramName, defaultValue);
            return defaultValue;
        }
        return val;
    }

    public void setSessionString(String paramName, String value) {
        session.setAttribute(paramName, value);
    }

    public int getSessionInt(String paramName, int defaultValue) {
        Integer val = (Integer) session.getAttribute(paramName);
        if (val == null) {
            session.setAttribute(paramName, Integer.valueOf(defaultValue));
            return defaultValue;
        }
        return val.intValue();
    }

    public void setSessionInt(String paramName, int val) {
        session.setAttribute(paramName, Integer.valueOf(val));
    }



}
