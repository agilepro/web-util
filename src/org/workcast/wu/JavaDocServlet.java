/*
 * NGLeafServlet.java
 */
package org.workcast.wu;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URLEncoder;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import com.purplehillsbooks.xml.Mel;

/**
* This servlet serves up JavaDoc documentation with
* annotations and the ability to comment.
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
@SuppressWarnings("serial")
public class JavaDocServlet extends javax.servlet.http.HttpServlet {

    public void doGet(HttpServletRequest req, HttpServletResponse resp)
    {
        OldWebRequest wr = null;
        try
        {
            wr = OldWebRequest.getOrCreate(req, resp, null);
            handleRequest(wr);
        }
        catch (Exception e)
        {
            try
            {
                if (wr!=null)
                {
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
            catch (Exception exx)
            {
                //can't do anything about this.
            }
        }
    }

    //request to http://machine:port/application/jd/version/com/example/foo/MyClass.html
    private void handleRequest(OldWebRequest wr) throws Exception
    {
        //get request URI includes a starting slash, everything after machine:port
        //format:  /wu/jd/version/com/example/foo/MyClass.html
        String reqURI = wr.req.getRequestURI();

        //get the name of the application, with slash before it
        //format:  /wu
        String path3 = wr.req.getContextPath();
        int lenOfContext = path3.length();

        //get the name within the application, that the servlet is at
        //format: /jd
        String path2 = wr.req.getServletPath();
        int lenOfServlet = path2.length();


        if (reqURI.length()<lenOfServlet+lenOfContext)
        {
            //seems like this should never happen
            throw new Exception("Strange, path is not long enough to get to this servlet? "+reqURI);
        }
        int docSetNameStart = lenOfServlet+lenOfContext+1;
        if (reqURI.length()<docSetNameStart)
        {
            //this is the case that they are missing a slash on the end
            //and relative references will be messed up, so redirect to a better place
            wr.resp.sendRedirect(reqURI+"/");
            return;
        }
        if (reqURI.length()==docSetNameStart)
        {
            //this has a slash, but nothing else, just show the doc sets immediately
            showDocSets(wr,"");
            return;
        }

        int slashPos = reqURI.indexOf("/", docSetNameStart);
        String docSetName = null;
        if (slashPos<0)
        {
            docSetName = reqURI.substring(docSetNameStart);
        }
        else
        {
            docSetName = reqURI.substring(docSetNameStart, slashPos);
        }

        JavaDocSet jds = JavaDocSet.getSet(docSetName);
        if (jds==null)
        {
            showDocSets(wr, docSetName);
            return;
        }

        if (slashPos<0)
        {
            //this is the case that they are missing a slash on the end
            //and relative references will be messed up, so redirect to a better place
            wr.resp.sendRedirect(reqURI+"/index.html");
            return;
        }
        if (slashPos==reqURI.length()-1)
        {
            //path ends with a slash so redirect to default page.
            wr.resp.sendRedirect(reqURI+"index.html");
            return;
        }

        String docPath = reqURI.substring(slashPos+1);


        String realPath = wr.req.getSession().getServletContext().
                getRealPath("/jd/"+docSetName+"/"+docPath);

        if (docPath.endsWith("$note"))
        {
            getComment(docPath, wr, jds);
            return;
        }

        if (docPath.endsWith("$upd"))
        {
            updateComment(docPath, wr, jds);
            return;
        }

        //not a comment, check for file
        File theFile = jds.getDocFile(docPath);

        if (theFile.exists())
        {
            streamFile(jds, docPath, wr);
            return;
        }

        //debug message
        wr.write("<html><body>");
        wr.write("getServletPath: ");
        wr.writeHtml(path2);
        wr.write("<br/>getContextPath: ");
        wr.writeHtml(path3);
        wr.write("<br/>getRequestURI: ");
        wr.writeHtml(reqURI);
        wr.write("<br/>doc path: ");
        wr.writeHtml(docPath);
        wr.write("<br/>real path: ");
        wr.writeHtml(realPath);
        wr.write("<br/>file exists? : ");
        wr.write("no, nothing there.");
        wr.write("</body></html>");
        wr.flush();
    }

    private void showDocSets(OldWebRequest wr, String nonSet)
        throws Exception
    {
        wr.write("<html><body>");
        if (nonSet.length()>0)
        {
            wr.write("\n<p>No document set named '"+nonSet+"' exists.</p>");
        }
        wr.write("\n<p>Select one of these doc sets at this site:</p>\n<ul>");
        for (JavaDocSet jds : JavaDocSet.listSets())
        {
            wr.write("\n<li><a href=\"");
            wr.write(wr.req.getContextPath());
            wr.write(wr.req.getServletPath());
            wr.write("/");
            wr.writeURLData(jds.name);
            wr.write("\">");
            wr.writeHtml(jds.name);
            wr.write("</li>");
        }


        wr.write("\n</ul>");
        wr.write("</body></html>");
        wr.flush();
    }



    private String getFileNamePart(String path)
    {
        int lastSlash = path.lastIndexOf("/")+1;
        if (lastSlash>0 && lastSlash<path.length())
        {
            return path.substring(lastSlash);
        }
        return path;
    }

    private void streamFile(JavaDocSet jds, String docPath, OldWebRequest wr)
        throws Exception
    {
        File theFile = jds.getDocFile(docPath);
        File noteFile = jds.getNoteFile(docPath);
        JavaDocNotes jdn = new JavaDocNotes(noteFile);

        String fileName = getFileNamePart(docPath);
        FileInputStream fis = new FileInputStream(theFile);
        InputStreamReader r = new InputStreamReader(fis, "UTF-8");
        int ch = r.read();
        while (ch>-1)
        {
            if (ch=='<')
            {
                wr.write(seek(r, fileName, wr, jds.name, jdn));
            }
            else
            {
                wr.write((char)ch);
            }
            ch = r.read();
        }
        wr.flush();
    }


    private static final String patt = "A NAME=";

    private String seek(InputStreamReader r, String fileName, OldWebRequest wr,
        String setName, JavaDocNotes jdn)
        throws Exception
    {
        StringBuffer buf = new StringBuffer("<");
        for (int i=0; i<patt.length(); i++)
        {
            int ch = r.read();
            buf.append((char)ch);
            if (ch!=patt.charAt(i))
            {
                return buf.toString();
            }
        }

        //it matched so far, now get the name
        StringBuffer name = new StringBuffer();
        int ch2 = r.read();
        buf.append((char)ch2);
        if (ch2=='\"')
        {
            ch2 = r.read();
            buf.append((char)ch2);
        }

        //everything up to the next quote is the name
        while (ch2!='\"')
        {
            name.append((char)ch2);
            ch2 = r.read();
            buf.append((char)ch2);
        }

        while (ch2!='>')
        {
            ch2 = r.read();
            buf.append((char)ch2);
        }

        wr.write(buf.toString());

        String member = name.toString().toLowerCase();
        int navbar = member.indexOf("navbar");
        if (navbar<0)
        {
            int count = jdn.noteCount(member);
            wr.write("<table STYLE=\"background: ");
            if (count>0)
            {
                wr.write("yellow");
            }
            else
            {
                wr.write("lightyellow");
            }
            wr.write("\" width=\"99%\"><tr><td>");
            wr.write(Integer.toString(count));
            wr.write(" Notes   <a href=\"");
            wr.write(fileName);
            wr.write("$note?f=");
            wr.writeURLData(member);
            wr.write("\">Add Note</a> ");
            wr.writeHtml(setName);
            wr.write(": <b>");
            wr.writeHtml(member);
            wr.write("</b>");
            if (count>0)
            {
                for (Mel note : jdn.getNotes(member))
                {
                    wr.write("</td></tr>\n<tr><td>");
                    wr.writeHtml(note.getScalar("ver"));
                    wr.write(": ");
                    wr.writeHtml(note.getScalar("comment"));
                }
            }
            wr.write("</td></tr></table>");
        }

        return "";
    }


    private void getComment(String ipart, OldWebRequest wr, JavaDocSet jds)
        throws Exception
    {
        //the ipath ends with $note, strip that off
        String jdocPath = ipart.substring(0, ipart.length()-5);

        File noteFile = jds.getNoteFile(jdocPath);
        JavaDocNotes jdn = new JavaDocNotes(noteFile);

        String fileName = getFileNamePart(jdocPath);
        int dotPos = fileName.lastIndexOf(".");
        if (dotPos<0)
        {
            throw new Exception("can not find the file extension for :"+fileName);
        }
        String className = fileName.substring(0, dotPos);
        String f = wr.reqParam("f");
        wr.write("<html><body>");
        wr.write("\n<h3>Enter Comment</h3>\n<b>Class:</b> ");
        wr.writeHtml(className);
        wr.write("\n<br/><b>Method:</b>");
        wr.writeHtml(f);
        wr.write("</h3>\n<form action=\"");
        wr.writeHtml(fileName);
        wr.write("$upd\" method=\"post\">");
        wr.write("\n<textarea name=\"com\" rows=\"10\" cols=\"70\">");
        wr.write("</textarea><br/>\n<input type=\"submit\" value=\"Save\">\n");
        wr.write("\n<input type=\"hidden\" name=\"f\" value=\"");
        wr.writeHtml(f);
        wr.write("\">\n</form>");

        wr.write("reading from: ");
        wr.writeHtml(noteFile.getAbsolutePath());

        if (noteFile.exists())
        {
            for (Mel note : jdn.getNotes(f))
            {
                wr.write("\n<p>Comment: (");
                wr.writeHtml(note.getScalar("ver"));
                wr.write(") ");
                wr.writeHtml(note.getScalar("comment"));
                wr.write("</p>");
            }
        }

        wr.write("</body></html>");
        wr.flush();
    }

    private void updateComment(String ipart, OldWebRequest wr, JavaDocSet jds)
        throws Exception
    {
        //the ipath ends with $upd, strip that off
        String jdocPath = ipart.substring(0, ipart.length()-4);
        String f = wr.reqParam("f");
        String com = wr.reqParam("com");

        File noteFile = jds.getNoteFile(jdocPath);
        JavaDocNotes jdn = new JavaDocNotes(noteFile);

        jdn.setNewNote(f, jds.name, com);

        String fileName = getFileNamePart(jdocPath);
        String fileWithAnchor = fileName + "#" + URLEncoder.encode(f, "UTF-8");
        wr.resp.sendRedirect(fileWithAnchor);
        wr.flush();
    }


    public void doPost(HttpServletRequest req, HttpServletResponse resp)
    {
        doGet(req, resp);
    }

    public void doPut(HttpServletRequest req, HttpServletResponse resp)
    {
    }

    public void doDelete(HttpServletRequest req, HttpServletResponse resp)
    {
    }

    public void init(ServletConfig config)
          throws ServletException
    {
        String root = config.getServletContext().getRealPath("/jd");
        File rootFolder = new File (root);
        JavaDocSet.initializeAllSets(rootFolder);
    }

}
