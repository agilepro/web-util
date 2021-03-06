<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String enc  = request.getParameter("enc");
    if (enc==null) {
        enc = "UTF-8";
    }
    String path = request.getParameter("path");
    if (path==null || path.length()<=4) {
        %>
        <html>
        <head>
            <title>Web Page Cleaner</title>
            <link href="mystyle.css" rel="stylesheet" type="text/css"/>
        </head>
        <body BGCOLOR="#E6FDF5">
        <h1>Web Page Cleaner</h1>
        <form action="cleaner.jsp" method="get">
          <input type="text" name="path" value="" size=80>
          <input type="submit" value="Get">
          <input type="text" name="enc" value="<%= enc %>">
        </form>
        <p>Enter the URL of a page on the web.  This utility will read the page, and
        then attempt to strip all of the graphics, applets, and scripts out of the page.
        The result is a page that is composed mostly of text with some styling of the
        left.  Sometimes I am on a slow link,
        and the pages I am trying to browse through have an annoying amount of
        graphics and other large files attached.  What I want to do is to
        prevent the downloading of all the junk I am not going to look at, and
        focus instead on the textual content which is what I am looking for.
        This is an attempt to make a utility which strips out all the graphics
        and leaves just the text.  Scripts are disabled as well.  In some cases
        links can still be followed, and in other cases the links (and maybe
        even the entire page) will be broken.  This is actually not very useful
        in the current form, so I am looking for a better solution, but in some
        senses loading a page through the "cleaner" will be somewhat safer
        than loading it directly because it prevents a lot of the page side effects.</p>
        <p>I think the next step is to incorporate an actualy HTML parser, and then
        use the DOM tree to clean out all the undesirable elements completely, and then
        possibly re-organize the text in order to make the result more readable.
        Yup, this is a research topic.
        <% wr.invokeJSP("tileBottom.jsp"); %>
        </body>
        </html>
        <%
        return;
    }
    int lastSlash = path.lastIndexOf("/");
    if (lastSlash<0) {
        throw new Exception("Hey, you have to have at least one slash in that URL!");
    }
    String basePath = path.substring(0, lastSlash+1);
%>
<html>
<head>
<style>
body
{
    font-family:"Helvetica";
    font-size:12px;
    background-color:#eeeeee;
    width:600px;
    margin-right:50px;
    margin-left:50px;
}
h1
{
    font-family:"Helvetica";
    color:darkblue;
}
h2
{
    font-family:"Helvetica";
    color:blue;
}
h3
{
    font-family:"Helvetica";
    color:green;
}
p
{
    font-family:"Helvetica";
    font-size:16px;
}
</style>
</head>

<%
    if (path.length()>4) {
        URL testUrl = new URL(path);
        URLConnection uc = testUrl.openConnection();
        if (uc == null) {
            throw new Exception("Got a null URLConnection object!");
        }
        InputStream is = uc.getInputStream();
        if (is == null) {
            throw new Exception("Got a null content object!");
        }
        Reader r = new InputStreamReader(is, "UTF-8");
        char[] cb = new char[2048];
        StringBuffer putBackTogether = new StringBuffer();
        int amtRead = r.read(cb);
        int amtTotal = amtRead;
        while (amtRead > 0) {
            putBackTogether.append(cb, 0, amtRead);
            amtRead = r.read(cb);
            amtTotal += amtRead;
        }
        if (amtTotal <= 0) {
            throw new Exception("Strange, the total read is "+amtTotal+" which is not valid.  For some reason the site it not able to be read.  Are you being redirected to https?");
        }
        StringBuffer res = new StringBuffer(amtTotal);
        String sourcePage = putBackTogether.toString();
        int startPos = 0;
        int pos = 0;
        boolean inTag = false;
        while (pos < amtTotal) {
            char ch = sourcePage.charAt(pos++);
            if (ch != '<' && ch != '>') {
                continue;
            }
            else if (inTag) {
                String command = sourcePage.substring(startPos, pos);
                startPos = pos;
                if (command.length()<5) {
                    out.write(command);
                }
                else {
                    outTag(out, command, basePath);
                }
                inTag = false;
            }
            else if (ch == '<') {
                if (outputMode) {
                    out.write(sourcePage.substring(startPos, pos-1));
                }
                startPos = pos-1;
                inTag = true;
            }
        }
        out.write(sourcePage.substring(startPos));
    }
%>
<hr>
<!-- modified by cleaner.jsp --><a href="<%=path%>">Go There</a>
<% wr.invokeJSP("tileBottom.jsp"); %>
<%!
    boolean outputMode = true;
    boolean showDebug = false;

    public void outTag(Writer out, String command, String basePath)
        throws Exception
    {
        String clc = command.toLowerCase();
        if (clc.startsWith("<img")) {
            if (showDebug) {
                out.write("<img src=\"delicon.gif\">");
            }
            return;
        }
        if (clc.startsWith("<a ")) {
            fixTagField(out, command, clc, "href", basePath);
            return;
        }
        if (clc.startsWith("<!--")) {
            return;
        }
        if (clc.startsWith("<meta")) {
            return;
        }
        //base tags can disrupt the relative addressing to clean linked pages
        if (clc.startsWith("<base")) {
            return;
        }
        if (clc.startsWith("<font")) {
            return;
        }
        if (clc.startsWith("</font")) {
            return;
        }
        if (clc.startsWith("<iframe")) {
            if (showDebug) {
                out.write("<img src=\"delicon.gif\">");
            }
            return;
        }
        if (clc.startsWith("<scri")) {
            if (showDebug) {
                out.write("SCRIPT{");
            }
            outputMode = false;
            return;
        }
        if (clc.startsWith("</scri")) {
            if (showDebug) {
                out.write("}");
            }
            outputMode = true;
            return;
        }
        if (clc.startsWith("</iframe")) {
            return;
        }
        if (clc.startsWith("<noscri")) {
            if (showDebug) {
                out.write("<img src=\"delicon.gif\">");
            }
            return;
        }
        if (clc.startsWith("</noscri")) {
            return;
        }
        if (clc.startsWith("<styl")) {
            if (showDebug) {
                out.write("STYLE{");
            }
            outputMode = false;
            return;
        }
        if (clc.startsWith("</styl")) {
            if (showDebug) {
                out.write("}");
            }
            outputMode = true;
            return;
        }
        if (clc.startsWith("<link")) {
            if (showDebug) {
                out.write("{LINK");
            }
            return;
        }
        if (clc.startsWith("</link")) {
            if (showDebug) {
                out.write("}");
            }
            return;
        }
        if (clc.startsWith("<div")) {
            return;
        }
        if (clc.startsWith("</div")) {
            return;
        }
        out.write(command);
    }

    public
    void
    fixTagField(Writer out, String command, String clc, String field, String basePath)
        throws Exception
    {
        int addrPos = clc.indexOf("href");
        if (addrPos < 0) {
            out.write("<!--no href-->");
            out.write(command);
            return;
        }
        addrPos+=4;
        if (command.charAt(addrPos)!='=') {
            out.write("<!--no equals-->");
            out.write(command);
            return;
        }
        addrPos++;
        String addr1 = null;
        boolean hasQuotes = (command.charAt(addrPos)=='\"');
        if (hasQuotes) {
            addrPos++;
            int endPos = command.indexOf("\"", addrPos);
            if (endPos<0) {
                out.write("<!--no closing quote-->");
                out.write(command);
                return;
            }
            addr1 = command.substring(addrPos, endPos);
        }
        else {
            int endPos = command.indexOf(" ", addrPos);
            if (endPos<0) {
                out.write("<!--cant get addr-->");
                out.write(command);
                return;
            }
            addr1 = command.substring(addrPos, endPos);
        }
        if (addr1.startsWith("http")) {
            out.write("\n<!--found http-->");
        }
        else if (addr1.startsWith("/")) {
            out.write("\n<!--found base rel-->");
            int thirdslash = basePath.indexOf("/", 9);
            String realBase = basePath.substring(0,thirdslash);
            addr1 = realBase+addr1;
        }
        else if (addr1.startsWith("'")) {
            //out.write("\n<!--script: "+addr1+"-->");
        }
        else {
            out.write("\n<!--relative?-->");
            addr1 = basePath+addr1;
        }
        String subAddr = "cleaner.jsp?path="+URLEncoder.encode(addr1);
        out.write("<a href=\""+subAddr+"\">");
    }
%>
