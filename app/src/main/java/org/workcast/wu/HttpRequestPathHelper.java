/*
 * NGLeafServlet.java
 */
package org.workcast.wu;
import java.io.PrintWriter;
import java.io.Writer;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
* Just to see what the various parts of the application are
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
@SuppressWarnings("serial")
public class HttpRequestPathHelper extends javax.servlet.http.HttpServlet {

    public void doGet(HttpServletRequest req, HttpServletResponse resp)  {
        OldWebRequest wr = null;
        try {
            wr = OldWebRequest.getOrCreate(req, resp, null);
            handleRequest(wr);
            wr.flush();
        }
        catch (Exception e)  {
            try  {
                if (wr!=null)  {
                    wr.write("<html><body>");
                    wr.write("\n<h3>Exception</h3><p>");
                    wr.writeHtml(e.toString());
                    wr.write("</p>\n<p>getRequestURI: ");
                    wr.writeHtml(wr.req.getRequestURI());
                    wr.write("</p>\n<p>getContextPath: ");
                    wr.writeHtml(wr.req.getContextPath());
                    wr.write("</p>\n<p>getServletPath: ");
                    wr.writeHtml(wr.req.getServletPath());
                    wr.write("</p>\n<pre>\n");
                    e.printStackTrace(new PrintWriter(wr.w));
                    wr.write("\n</pre>\n</body></html>");
                    wr.flush();
                }
            }
            catch (Exception exx) {
                //can't do anything about this.
            }
        }
    }

    //request to http://machine:port/application/jd/version/com/example/foo/MyClass.html
    private void handleRequest(OldWebRequest wr) throws Exception {

        String getContextPathStr = wr.req.getContextPath();
        String getPathInfoStr = wr.req.getPathInfo();
        String getPathTranslatedStr = wr.req.getPathTranslated();
        String getQueryStringStr = wr.req.getQueryString();
        String getRequestURIStr = wr.req.getRequestURI();
        String getRequestURLStr = wr.req.getRequestURL().toString();
        String getServletPathStr = wr.req.getServletPath();

        Writer out = wr.w;
        out.write("<html>\r\n");
        out.write("<head>\r\n");
        out.write("\r\n");
        out.write("</head>\r\n");
        out.write("\r\n");
        out.write("<body>\r\n");
        out.write("\r\n");
        out.write("<hr>\r\n");
        out.write("<table>\r\n");
        out.write("<tr><td> request.getRequestURL();  </td><td> ");
        wr.writeHtml(getRequestURLStr);
        out.write(" </td></tr>\r\n");

        out.write("<tr><td> request.getScheme();  </td><td> ");
        wr.writeHtml(wr.req.getScheme());
        out.write(" </td></tr>\r\n");
        out.write("<tr><td> request.getServerName();  </td><td> ");
        wr.writeHtml(wr.req.getServerName());
        out.write(" </td></tr>\r\n");
        out.write("<tr><td> request.getServerPort();  </td><td> ");
        wr.writeHtml(Integer.toString(wr.req.getServerPort()));
        out.write(" </td></tr>\r\n");

        out.write("<tr><td> request.getContextPath();  </td><td> ");
        wr.writeHtml(getContextPathStr);
        out.write(" </td></tr>\r\n");
        out.write("<tr><td> request.getPathInfo();  </td><td> ");
        wr.writeHtml(getPathInfoStr);
        out.write(" </td></tr>\r\n");
        out.write("<tr><td> request.getServletPath();  </td><td> ");
        wr.writeHtml(getServletPathStr);
        out.write(" </td></tr>\r\n");

        out.write("<tr><td> request.getQueryString();  </td><td> ");
        wr.writeHtml(getQueryStringStr);
        out.write(" </td></tr>\r\n");

        out.write("<tr><td> request.getRequestURI();  </td><td> ");
        wr.writeHtml(getRequestURIStr);
        out.write(" </td></tr>\r\n");

        out.write("<tr><td> request.getProtocol();  </td><td> ");
        wr.writeHtml(wr.req.getProtocol());
        out.write(" </td></tr>\r\n");
        out.write("<tr><td> request.getPathTranslated();  </td><td> ");
        wr.writeHtml(getPathTranslatedStr);
        out.write(" </td></tr>\r\n");
        out.write("</table>\r\n");
        out.write("\r\n");
        out.write("</body>\r\n");
        out.write("</html>\r\n");
    }



    public void init(ServletConfig config) throws ServletException {
    }

}
