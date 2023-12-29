<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="com.purplehillsbooks.streams.MemFile"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.jsoup.Jsoup"
%><%@page import="org.jsoup.nodes.Attribute"
%><%@page import="org.jsoup.nodes.Comment"
%><%@page import="org.jsoup.nodes.Document"
%><%@page import="org.jsoup.nodes.Element"
%><%@page import="org.jsoup.nodes.Node"
%><%@page import="org.jsoup.nodes.TextNode"
%><%@page import="org.workcast.wu.SimplePage"
%><%@page import="org.workcast.wu.SimpleWebRequest"
%><%
    SimpleWebRequest wr = new SimpleWebRequest(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String enc  = request.getParameter("enc");
    if (enc==null) {
        enc = "UTF-8";
    }
    String path = request.getParameter("path");
    
%>

<head>
  <title>Web Page Cleaner</title>
  <script src="js/angular.js"></script>
  <link href='https://fonts.googleapis.com/css?family=Montserrat:200,400,700' rel='stylesheet' type='text/css'>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.srctext = "";

    });
</script>
</head>
<body ng-app="genieApp" ng-controller="genieCtrl">
<div class="mainFrame">

<h1>Web Page Cleaner</h1>

<%
    if (path==null || path.length()<=4) {
        %>
        <html>

        <form action="cleaner4.jsp" method="get">
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
    String shortPath = path;
    if (path.length()>48) {
        shortPath = path.substring(0,45) + "...";
    }
%>

<style>
ddbody
{
    font-family:"Helvetica";
    font-size:12px;
    background-color:#eeeeee;
    max-width:600px;
    margin-right:25px;
    margin-left:25px;
}
h1 {
    color:darkblue;
}
h2 {
    color:blue;
}
h3 {
    color:green;
}
p {
    font-size:16px;
}
.showText {
    padding: 8px;
    background-color: lightblue;
}
.showLink {
    padding: 8px;
    background-color: lightgreen;
}
.showBogus {
    padding: 8px;
    background-color: pink;
}
.cleanerHeader {
    padding: 10px;
    border: 2px solid gray;
    border-radius: 5px;
    margin: 10px;
}

</style>
</head>

</body>
<div class="cleanerHeader">
    <b>Cleaned Page: </b>
    <a href="<%=path%>">Original</a> /  
    <a href="cleaner4.jsp">New URL</a> 
    <span><%=shortPath%></span>
</div>

<%
    MemFile mf = new MemFile();
    if (path.length()>4) {

        Writer wx = mf.getWriter();
        SimplePage sp = SimplePage.consumeWebPage(wx, path);
        wx.flush();
        sp.produceHtml(wr.w);
        wr.w.flush();
%>

<hr/>
<hr/>


<%
        mf.outToWriter(wr.w);
        wr.flush();
    }
%>

<hr>
<!-- modified by cleaner.jsp --><a href="<%=path%>">Go There</a>

<% wr.invokeJSP("tileBottom.jsp"); %>

</div>
</body>
</html>

<%!
    boolean outputMode = true;
    boolean showDebug = false;


    public void outputCleanPage(SimpleWebRequest wr, Element ele, String s) throws Exception {
        String tagName = ele.nodeName().toLowerCase();
        String p = s + " / " + tagName;

        if ("noscript".equals(tagName)) {
            return;
        }
        if ("script".equals(tagName)) {
            return;
        }
        if ("svg".equals(tagName)) {
            return;
        }
        if ("style".equals(tagName)) {
            return;
        }
        if ("form".equals(tagName)) {
            return;
        }
        if ("figure".equals(tagName)) {
            return;
        }

        int kind = kindOfBlock(ele);
        if ("a".equals(tagName)) {
            dumpLink(wr, ele);
            return;
        }
        if (tagName.startsWith("/")) {
            wr.write("\n == found endtag:"+tagName+"<br/>");
            return;
        }
        if (kind == 3) {
            wr.write("\n<span style=\"color:gray\">container: "+p+"</span><br/>");
        }
        else if (kind == 2) {
            int[] stats = new int[2];
            stats[0] = 0;
            stats[1] = 0;
            getContentStats(stats, ele);
            wr.write("\n<span style=\"color:blue\"> stats: "+stats[0]+","+stats[1]
                +","+tagName+"</span><br/>");
            if (stats[0]>stats[1]) {
                wr.write("\n<div class=\"showText\">");
                streamNonBlock(wr,ele);
                wr.write("\n</div>");
            }
            else if (stats[1]>0) {
                wr.write("\n<div class=\"showBogus\">");
                streamNonBlock(wr,ele);
                wr.write("\n</div>");
            }
            return;
        }
        else {
            wr.write("\n<span style=\"color:red\">TAG "+kind+": "+p+"</span><br/>");
        }
        if ("button".equals(tagName)) {
            return;
        }
        
        for (Node child : ele.childNodes()) {
            if (child instanceof TextNode) {
                TextNode tNode = (TextNode) child;
                String t = tNode.getWholeText().trim();
                if (t.length()>0) {
                    wr.write("\n<div class=\"showText\">");
                    wr.writeHtml(t);
                    wr.write("</div>");
                }
            }
            else if (child instanceof Element) {
                Element subTag = (Element) child;
//                int subKind = kindOfBlock(subTag);
//                if (kind == 3 && subKind == 1) {
//                    wr.write("\n     <span style=\"yellow\">non-leaf in container</span><br/>");
//                }
                outputCleanPage(wr, subTag, p);
            }
            else if (child instanceof Comment) {
                wr.write("\n   - <span style=\"color:green\">");
                wr.writeHtml(((Comment)child).getData());
                wr.write("</span><br/>");
            }
            else {
                wr.write("\n   - ? <span style=\"color:red\">");
                wr.writeHtml(child.nodeName());
                wr.write("</span><br/>");
            }
        }
    }
 
    
    /** 1 = not a block instead span or text style, 
        2 == leaf block,  
        3 == containing block, 
        0 == unknown */

    public int kindOfBlock(Element ele) {
        if (!ele.isBlock()) {
            return 1;
        }
        boolean hasChildBlock = false;
        for (Element child : ele.children()) {
            int kind = kindOfBlock(child);
            if (kind==3 || kind==2) {
                // if inside the current block we find either a leaf block
                // or containing block, then the current block is a containing block.
                // nothing else has to be looked at.
                return 3;
            }   
        }
        return 2;
    }
    
   
    public void dumpLink(SimpleWebRequest wr, Element ele) throws Exception  {
        String val = ele.text().trim();
        if (val.length()==0) {
            return;
        }
        wr.write("\n<div class=\"showLink\">");
        streamLink(wr, ele);
        wr.write("</div>");
    }
    
    public void streamNonBlock(SimpleWebRequest wr, Element ele) throws Exception {
        String tagName = ele.nodeName().toLowerCase();
        boolean ignore = true;
        if ("a".equals(tagName)) {
            streamLink(wr, ele);
            return;
        }
        if ("p".equals(tagName) || "i".equals(tagName)|| "b".equals(tagName)  
            || "h1".equals(tagName) || "h2".equals(tagName)
            || "h3".equals(tagName) || "h4".equals(tagName) ) {
            ignore = false;
        }
        if (!ignore) {
            wr.write("<"+tagName+">");
        }
        for (Node child : ele.childNodes()) {
            if (child instanceof TextNode) {
                TextNode tNode = (TextNode) child;
                String t = tNode.getWholeText();
                if (t.length()>0) {
                    wr.writeHtml(t);
                }
            }
            else if (child instanceof Element) {
                Element childEle = (Element) child;
                streamNonBlock(wr,childEle);
            }
        }        
        if (!ignore) {
            wr.write("</"+tagName+">");
        }
    }
    
    public void streamLink(SimpleWebRequest wr, Element ele) throws Exception {
        String url = "";
        for (Attribute att : ele.attributes()) {
            if (att.getKey().equalsIgnoreCase("href")) {
                url = att.getValue();
            }
        }
        String val = ele.text().trim();
        if (val.length()==0) {
            return;
        }
        wr.write("<a href=\"cleaner4.jsp?path=");
        wr.write(URLEncoder.encode(url, "UTF-8"));
        wr.write("\">");
        wr.writeHtml(val);
        wr.write("</a>");
    }
    
    public void getContentStats (int[] res, Element ele) {
        String tagName = ele.nodeName().toLowerCase();
        if ("a".equals(tagName)) {
            res[1] += ele.text().trim().length();
            return;
        }
        for (Node child : ele.childNodes()) {
            if (child instanceof TextNode) {
                res[0] += ((TextNode) child).getWholeText().trim().length();
            }
            else if (child instanceof Element) {
                Element childEle = (Element) child;
                getContentStats(res,childEle);
            }
        }                
    }
%>
