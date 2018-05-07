<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.WebRequest"
%><%@page import="org.htmlparser.Parser"
%><%@page import="org.htmlparser.Remark"
%><%@page import="org.htmlparser.util.NodeIterator"
%><%@page import="org.htmlparser.Node"
%><%@page import="org.htmlparser.Tag"
%><%@page import="org.htmlparser.util.NodeList"
%><%@page import="org.htmlparser.Text"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
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
        <form action="cleaner2.jsp" method="get">
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

        Parser parser = new Parser (path);
        NodeIterator ni = parser.elements();
        while (ni.hasMoreNodes()) {
            Node node = ni.nextNode();
            if (node instanceof Tag) {
                Tag tag = (Tag)node;
                if ("html".equals(tag.getRawTagName().toLowerCase())) {
                    outputCleanPage(wr, tag, "");
                }
            }
        }

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
    
    
    public void outputCleanPage(WebRequest wr, Tag tag, String s) throws Exception {
        String tagName = tag.getRawTagName().toLowerCase();
        String p = s + " / " + tagName;
        if ("a".equals(tagName)) {
            dumpLink(wr, tag);
            return;
        }
        if (tagName.startsWith("/")) {
            wr.write("\n == found endtag:"+tagName+"<br/>");
            return;
        }
        wr.write("\nTAG: "+p+"<br/>");
        if ("script".equals(tagName)) {
            return;
        }
        if ("noscript".equals(tagName)) {
            return;
        }
        if ("style".equals(tagName)) {
            return;
        }
        if ("form".equals(tagName)) {
            return;
        }
        
        NodeList nl = tag.getChildren();
        if (nl!=null) {
            for (Node n : nl.toNodeArray()) {
                if (n instanceof Tag) {
                    Tag subTag = (Tag) n;
                    outputCleanPage(wr, subTag, p);
                }
                else if (n instanceof Text) {
                    Text tNode = (Text) n;
                    String t = n.getText().trim();
                    if (t.length()>0) {
                        wr.write("\n   - <b>");
                        wr.writeHtml(convertEntities(t));
                        wr.write("</b><br/>");
                    }
                }
                else if (n instanceof Remark) {
                    wr.write("\n   - <span style=\"color:green\">");
                    wr.writeHtml(n.toHtml());
                    wr.write("</span><br/>");
                }
                else {
                    wr.write("\n   - ? <span style=\"color:red\">");
                    wr.writeHtml(n.toHtml());
                    wr.write("</span><br/>");
                }
            }
        }
    }
    public void dumpLink(WebRequest wr, Tag node) throws Exception  {
        StringBuilder sb = new StringBuilder();
        gatherAllText(node, sb);
        wr.write("\nLINK: <span style=\"color:blue\">");
        wr.writeHtml(convertEntities(sb.toString()));
        wr.write("</span><br/>");
    }
    
    public void gatherAllText(Tag tag, StringBuilder sb) throws Exception  {
        NodeList nl = tag.getChildren();
        if (nl!=null) {
            for (Node n : nl.toNodeArray()) {
                if (n instanceof Tag) {
                    Tag subTag = (Tag) n;
                    gatherAllText(subTag, sb);
                }
                else if (n instanceof Text) {
                    Text tNode = (Text) n;
                    String t = n.getText();
                    sb.append(t);
                }
            }
        }
    }
    
    public String convertEntities(String in) {
        int pos = in.indexOf("&");
        if (pos<0) {
            return in;
        }
        StringBuilder out = new StringBuilder();
        int start = 0;
        while (pos>=start) {
            out.append(in.substring(start,pos));
            start = pos;
            int semi = in.indexOf(";", pos);
            if (semi>pos) {
                String ent = in.substring(pos+1, semi);
                appendEntity(out,ent);
                start = semi+1;
            }
            else {
                out.append("(!)");
            }
            pos = in.indexOf("&", start);
        }
        out.append(in.substring(start));
        return out.toString();
    }
    public void appendEntity(StringBuilder out,String ent) {
        if (ent.charAt(0)=='#') {
            if (ent.charAt(1)=='x') {
                appendHexChar(out,ent,2);
            }
        }
        else if ("lt".equals(ent)) {
            out.append('<');
        }
        else if ("gt".equals(ent)) {
            out.append('>');
        }
        else if ("amp".equals(ent)) {
            out.append('&');
        }
        else if ("quot".equals(ent)) {
            out.append('\"');
        }
        else if ("lt".equals(ent)) {
            out.append("(");
            out.append(ent);
            out.append(")");
        }
    }
    public void appendHexChar(StringBuilder out,String hex, int start) {
        int res = 0;
        for (int pos=start; pos<hex.length(); pos++) {
            int ch = hex.charAt(pos);
            res = res * 16;
            if (ch >= '0' && ch <= '9') {
                res = res + ch - '0';
            }
            else if (ch >= 'A' && ch <= 'F') {
                res = res + ch + 10 - 'A';
            }
            else if (ch >= 'a' && ch <= 'f') {
                res = res + ch + 10 - 'a';
            }
        }
        out.append( (char) res );
    }
%>
