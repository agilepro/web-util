<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="com.purplehillsbooks.streams.MemFile"
%><%@page import="com.purplehillsbooks.streams.HTMLWriter"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.util.List"
%><%@page import="java.util.ArrayList"
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
%><%@page import="org.workcast.wu.HtmlToWikiConverter2"
%><%@page import="org.workcast.wu.WikiConverter"
%><%
    SimpleWebRequest wr = new SimpleWebRequest(request, response, out);
    request.setCharacterEncoding("UTF-8");

    String enc  = request.getParameter("enc");
    if (enc==null) {
        enc = "UTF-8";
    }
    String path = request.getParameter("path");
    int threshold = 400;
    int articleThreshold = 400;
    
%>

<head>
  <title>Page Capture</title>
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



<%
    if (path==null || path.length()<=4) {
        %>

        <h1>Web Page Capture</h1>
        
        <form action="capture.jsp" method="get">
          <input type="text" name="path" value="" size="60">
          <input type="submit" value="Get">
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
    List<String> markDown = new ArrayList<>();
    if (path.length()>4) {
        HtmlToWikiConverter2 converter = new HtmlToWikiConverter2();
        markDown = converter.webPageToWiki(path);
    }
    List<String> articleText = new ArrayList<>();
    List<String> linkText = new ArrayList<>();
    for (String b2 : markDown) {
        if (b2.startsWith("!!")) {
            articleText.add(b2);
        }
        else if (WikiConverter.amtNonLinkedText(b2)>articleThreshold) {
            articleText.add(b2);
        }
        else if (b2.length()>threshold) {
            linkText.add(b2);
        }
        else {
            //ignore the text
        }
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
    color:teal;
}
h3 {
    color:green;
}
p {
    font-size:16px;
    line-height: 1.5;
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
.blockStyle {
    border: 2px solid brown;
    background-color: white;
    max-width:450px;
    padding: 15px;
    border-radius: 5px;
}
a {
    padding:0px;
}
</style>

<div class="cleanerHeader">
    <b>Capture Page: </b>
    <a href="<%=path%>">Original</a> /  
    <a href="capture.jsp">New URL</a> 
    <span><%=shortPath%></span>
</div>


<hr>
<style>

</style>
<div>
<table width="100%">
<%
    for (String block : articleText) {
        wr.write("\n<tr><td class=\"blockStyle\">\n");
        WikiConverter.writeWikiAsHtml(wr.w, block, "http://bobcat/wu/capture.jsp?path=");
        wr.write("\n</td></tr>\n");
    }
    for (String block : linkText) {
        wr.write("\n<tr><td class=\"blockStyle\">\n");
        WikiConverter.writeWikiAsHtml(wr.w, block, "http://bobcat/wu/capture.jsp?path=");
        wr.write("\n</td></tr>\n");
    }
%>
</table>

</div>






<!-- modified by cleaner.jsp -->
<a href="<%=path%>">Go There</a>
<a href="pagesource2.jsp?path=<%=URLEncoder.encode(path)%>">View Source</a>


<% wr.invokeJSP("tileBottom.jsp"); %>



<div class="mainFrame">
<%
    for (String block : markDown) {
        wr.write("\n<p>"+WikiConverter.amtNonLinkedText(block)+" / "+block.length()+"</p>\n<pre>\n");
        HTMLWriter.writeHtml(wr.w, block);
        wr.write("\n</pre>\n");
    }
%>

</div>
</body>
</html>

