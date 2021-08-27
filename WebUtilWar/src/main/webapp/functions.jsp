<%@page import="java.io.Writer"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Collections"
%><%@page import="java.util.Comparator"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.List"
%><%@page import="java.util.Map"
%><%@page import="java.util.Vector"
%><%@page import="javax.servlet.http.HttpServletRequest"
%><%@page import="javax.servlet.http.HttpSession"
%><%@page import="org.w3c.dom.Document"
%><%@page import="org.w3c.dom.Element"
%><%@page import="org.w3c.dom.Node"
%><%@page import="org.w3c.dom.NodeList"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%!

    //stores the current document so that it is not always being passed around
    Document currentDoc = null;

    //set the current page
    public void setPage(Document newPage)
    {
        currentDoc = newPage;
    }

    //convenience to add a child with text to the current page
    public void appendText(Element parent, String content)
        throws Exception
    {
        if (currentDoc==null) {
            throw new Exception("programming error: must set current page document before calling 'newChild'");
        }
        parent.appendChild(currentDoc.createTextNode(content));
    }


 

    public String fetchDoc(HttpSession session, HttpServletRequest request)
        throws Exception
    {
        String pageSource = (String) session.getAttribute("source");
        String pageUrl = (String) session.getAttribute("url");
        String path = request.getParameter("path");
        if (path==null) {
            return pageSource;
        }
        if (path.equals(pageUrl)) {
            return pageSource;
        }
        if (path.length()<4) {
            return pageSource;
        }
        String enc  = request.getParameter("enc");
        if (enc==null) {
            enc = "UTF-8";
        }
        pageSource = fetchDoc(path, enc);
        session.setAttribute("source", pageSource);
        session.setAttribute("url", path);
        return pageSource;
    }

    public String fetchDoc(String pageUrl, String enc)
        throws Exception
    {
        URL testUrl = new URL(pageUrl);
        URLConnection uc = testUrl.openConnection();
        if (uc == null) {
            throw new Exception("Got a null URLConnection object!");
        }
        InputStream is = uc.getInputStream();
        if (is == null) {
            throw new Exception("Got a null content object!");
        }
        StringBuffer putBackTogether = new StringBuffer();
        Reader r = new InputStreamReader(is, enc);
        char[] cb = new char[2048];

        Map<String,List<String>> fields = uc.getHeaderFields();
        for (String fieldName: fields.keySet()) {
            List<String> vals = fields.get(fieldName);
            for (String oneVal : vals) {
                putBackTogether.append(fieldName+": "+oneVal+"\n");
            }
        }
        putBackTogether.append("-----------------------------\n");

        int amtRead = r.read(cb);
        while (amtRead > 0) {
            putBackTogether.append(cb, 0, amtRead);
            amtRead = r.read(cb);
        }
        return putBackTogether.toString();
    }

    public String postDoc(String pageUrl, String body, String enc)
        throws Exception
    {
        URL testUrl = new URL(pageUrl);
        URLConnection uc = testUrl.openConnection();
        if (uc == null) {
            throw new Exception("Got a null URLConnection object!");
        }
        InputStream is = uc.getInputStream();
        if (is == null) {
            throw new Exception("Got a null content object!");
        }
        StringBuffer putBackTogether = new StringBuffer();
        Reader r = new InputStreamReader(is, enc);
        char[] cb = new char[2048];

        Map<String,List<String>> fields = uc.getHeaderFields();
        for (String fieldName: fields.keySet()) {
            List<String> vals = fields.get(fieldName);
            for (String oneVal : vals) {
                putBackTogether.append(fieldName+": "+oneVal+"\n");
            }
        }
        putBackTogether.append("-----------------------------\n");

        int amtRead = r.read(cb);
        while (amtRead > 0) {
            putBackTogether.append(cb, 0, amtRead);
            amtRead = r.read(cb);
        }
        return putBackTogether.toString();
    }

    public String stripIndent(String source)
    {
        StringBuffer sb = new StringBuffer(source.length());
        int pos = 0;
        int npos = source.indexOf(">\r", pos);
        while (npos>0) {

            sb.append(source.substring(pos, npos+1));
            pos = source.indexOf("<", npos);
            if (pos<0) {
                break;
            }
            if (pos>npos) {
                npos = source.indexOf(">\r", pos);
            }
        }
        if (pos>=0) {
            sb.append(source.substring(pos));
        }
        return sb.toString();
    }

    public void seekAndDestroy(Element parent, String tagName)
        throws Exception
    {
        if (parent==null)
        {
            throw new RuntimeException("seekAndDestroy must have a non null parameter 'parent'");
        }
        Vector list = new Vector() ;
        NodeList childNdList = parent.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++) {
            org.w3c.dom.Node n = childNdList.item(i) ;
            if (n.getNodeType() != org.w3c.dom.Node.ELEMENT_NODE)
            {
                continue ;
            }
            Element ele = (Element) n;
            String eleName = ele.getTagName();
            if (eleName!=null && eleName.equals(tagName)) {
                parent.removeChild(ele);
            }
            else {
                seekAndDestroy(ele, tagName);
            }
        }
    }


    public Hashtable htmlElementType = null;

    public String extractWiki(Element parent)
    {
        return "DISABLED";
    }



    public static Enumeration getChildElements(Element from)
    {
        if (from==null)
        {
            throw new RuntimeException("getChildElements must have a non null parameter 'from'");
        }
        Vector list = new Vector() ;
        NodeList childNdList = from.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++) {
            org.w3c.dom.Node n = childNdList.item(i) ;
            if (n.getNodeType() != org.w3c.dom.Node.ELEMENT_NODE) {
                continue ;
            }
            list.add((Element) n) ;
        }
        return list.elements() ;
    }



%>
