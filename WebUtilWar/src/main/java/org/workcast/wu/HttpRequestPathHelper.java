/*
 * NGLeafServlet.java
 */
package org.workcast.wu;
import java.io.PrintWriter;
import java.io.Writer;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
* Just to see what the various parts of the application are
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
@SuppressWarnings("serial")
public class HttpRequestPathHelper extends jakarta.servlet.http.HttpServlet {

    public void doGet(HttpServletRequest req, HttpServletResponse response)  {
        SimpleWebRequest wr = null;
        try {
            wr = new SimpleWebRequest(req, response, null);
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
                    wr.writeHtml(wr.request.getRequestURI());
                    wr.write("</p>\n<p>getContextPath: ");
                    wr.writeHtml(wr.request.getContextPath());
                    wr.write("</p>\n<p>getServletPath: ");
                    wr.writeHtml(wr.request.getServletPath());
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
    private void handleRequest(SimpleWebRequest wr) throws Exception {

        String getContextPathStr = wr.request.getContextPath();
        String getPathInfoStr = wr.request.getPathInfo();
        String getPathTranslatedStr = wr.request.getPathTranslated();
        String getQueryStringStr = wr.request.getQueryString();
        String getRequestURIStr = wr.request.getRequestURI();
        String getRequestURLStr = wr.request.getRequestURL().toString();
        String getServletPathStr = wr.request.getServletPath();

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
        wr.writeHtml(wr.request.getScheme());
        out.write(" </td></tr>\r\n");
        out.write("<tr><td> request.getServerName();  </td><td> ");
        wr.writeHtml(wr.request.getServerName());
        out.write(" </td></tr>\r\n");
        out.write("<tr><td> request.getServerPort();  </td><td> ");
        wr.writeHtml(Integer.toString(wr.request.getServerPort()));
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
        wr.writeHtml(wr.request.getProtocol());
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
