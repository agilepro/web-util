package org.workcast.wu;

import java.io.Writer;
import java.net.URLEncoder;
import javax.servlet.RequestDispatcher;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.purplehillsbooks.streams.HTMLWriter;
import com.purplehillsbooks.streams.JavaScriptWriter;

/**
* convenient class for handling JSP calls
*/

public class SimpleWebRequest {

    public HttpServletRequest  req;
    public HttpServletResponse resp;
    public Writer w;

    /**
    * First look to see if this request already has constructed a WebRequest object
    * and if so, use that.  If not, construct one.  This prevents many copies of the
    * object (with different settings) from being created along the way.
    *
    * From a JSP you have to pass in the writer, because the JSP framework plays
    * with the writer.  From other places you can pass null.
    */
    public SimpleWebRequest(HttpServletRequest  areq, HttpServletResponse aresp, Writer aw)
            throws Exception {
        req = areq;
        resp = aresp;
        w = aw;
    }

    public void flush() throws Exception {
        w.flush();
    }

    /**
    * Convenience method.  If you want to write to the output stream of a
    * request, this will alow you to write without having to get the
    * output stream and call write on it.
    */
    public void write(String t) throws Exception {
        w.write(t);
    }
    public void write(char ch) throws Exception {
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
    
    public void writeURLData(String data) throws Exception {
        // avoid NPE.
        if (data == null || data.length() == 0) {
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
    * Get a paramter value from the request stream.  If that parameter
    * is not in the request, then look and see if it is an attribute of the
    * reuqest that was put there by code doing a server side redirect to the
    * JSP file.  If that is not there either, then return the default instead.
    */
    public String defParam(String paramName, String defaultValue)
        throws Exception
    {
        String val = req.getParameter(paramName);
        if (val != null) {
            return val;
        }

        //try and see if it a request attribute
        val = (String)req.getAttribute(paramName);
        if (val != null) {
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
    public String reqParam(String paramName) throws Exception {
        String val = defParam(paramName, null);
        if (val == null || val.length()==0) {
            //The exception that is thrown will not be seen by users.  Once all of the pages
            //have proper URLs constricted for redirecting to other pages, this error will
            //not occur.  Therefor, there is no need to localize this exception.
            throw new Exception("A parameter named '"+paramName+"' is required for page "+req.getRequestURI());
        }
        return val;
    }

    /**
    * Given the name of a JSP file, this will call it, and the
    * output will appear in the place of the call.
    */
    public void invokeJSP(String JSPName) throws Exception {
        w.flush();
        resp.setContentType("text/html;charset=UTF-8");
        String relPath = getRelPathFromCtx();
        RequestDispatcher rd = req.getRequestDispatcher(relPath + JSPName);
        rd.include(req, resp);
        flush();
    }
    
    private String getRelPathFromCtx() throws Exception  {
        if (req == null)
        {
            throw new Exception("getRelPathFromCtx requires a request object to be set, but it is null");
        }

        String pageUrl = req.getRequestURL().toString();
        String context = req.getContextPath() + "/";
        int contextPos = pageUrl.indexOf(context);
        if (contextPos == -1) {
            throw new Exception("Something is wrong, the context path can not be found in the current URL.  "
                    +"This should never happen.  Request URL is '"+pageUrl+"' and context is '"+context+"'");
        }

        StringBuffer relPath = new StringBuffer();
        String strOfIntrest = pageUrl.substring(contextPos + context.length());
        for (int i=0; i<strOfIntrest.length(); i++) {
            char c = strOfIntrest.charAt(i);
            if (c == '/') {
                relPath.append("../");
            }
        }
        return relPath.toString();
    }

}
