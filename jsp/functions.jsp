<%@page import="java.io.Writer"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.io.InputStream"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.net.URL"
%><%@page import="java.util.Collections"
%><%@page import="java.util.Comparator"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Vector"
%><%@page import="javax.servlet.http.HttpServletRequest"
%><%@page import="javax.servlet.http.HttpSession"
%><%@page import="org.w3c.dom.Document"
%><%@page import="org.w3c.dom.Element"
%><%@page import="org.w3c.dom.Node"
%><%@page import="org.w3c.dom.NodeList"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.WebRequest"
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


    public void makeTabs (WebRequest wr, String current)
        throws Exception
    {
        String names[] = {"Set Up", "Source", "Links"};
        String addrs[] = {"setup.jsp", "source.jsp", "links.jsp"};

        int last = names.length;
        wr.write("\n<table><tr>");
        for (int i=0; i<last; i++)
        {
            if (names[i].equals(current)) {
                wr.write("\n  <td> &nbsp; <b>");
                wr.writeHtml(names[i]);
                wr.write("</b> &nbsp; </td>");
            }
            else {
                wr.write("\n  <td> &nbsp; <a href=\"");
                wr.writeHtml(addrs[i]);
                wr.write("\">");
                wr.writeHtml(names[i]);
                wr.write("</a> &nbsp; </td>");
            }
        }
        wr.write("\n</tr></table>");
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
        //if (htmlElementType==null) {
        //    htmlElementType = new Hashtable();
        //    htmlElementType.put("html","A");
        //}
        //StringBuffer retval = new StringBuffer();
//
        //recursiveExtractIgnore(parent, retval);
///
        //return retval.toString();
    }


/*
    public void recursiveExtractIgnore(Element parent, StringBuffer retval)
    {
        Enumeration eee = getChildElements(parent);
        while (eee.hasMoreElements()) {
            Element ele = (Element)eee.nextElement();
            String eleName = ele.getTagName();
            if (eleName==null) {
                //do nothing
            } else if(eleName.equalsIgnoreCase("html")) {
                recursiveExtractIgnore(ele, retval);
            } else if(eleName.equalsIgnoreCase("body")) {
                recursiveExtractWiki(ele, retval);
            } else if(eleName.equalsIgnoreCase("div")) {
                wikiBlock(ele, retval);
            } else if(eleName.equalsIgnoreCase("p")) {
                wikiBlock(ele, retval);
            } else if(eleName.equalsIgnoreCase("h1")) {
                wikiBlock(ele, retval);
            } else if(eleName.equalsIgnoreCase("h2")) {
                wikiBlock(ele, retval);
            } else if(eleName.equalsIgnoreCase("h3")) {
                wikiBlock(ele, retval);
            } else if(eleName.equalsIgnoreCase("table")) {
                //purposefully strip this out
            } else if(eleName.equalsIgnoreCase("head")) {
                //purposefully strip this out
            } else if(eleName.equalsIgnoreCase("script")) {
                //purposefully strip this out
            } else {
                recursiveExtractIgnore(ele, retval);
            }
        }
    }

    public void recursiveExtractWiki(Element parent, StringBuffer retval)
    {
        Enumeration eee = getChildElements(parent);
        while (eee.hasMoreElements()) {
            Element ele = (Element)eee.nextElement();
            String eleName = ele.getTagName();
            if (eleName==null) {
                //do nothing
            } else if(eleName.equalsIgnoreCase("html")) {
                recursiveExtractWiki(ele, retval);
            } else if(eleName.equalsIgnoreCase("body")) {
                recursiveExtractWiki(ele, retval);
            } else if(eleName.equalsIgnoreCase("div")) {
                wikiBlock(ele, retval);
            } else if(eleName.equalsIgnoreCase("p")) {
                wikiBlock(ele, retval);
            } else if(eleName.equalsIgnoreCase("h1")) {
                wikiBlock(ele, retval);
            } else if(eleName.equalsIgnoreCase("h2")) {
                wikiBlock(ele, retval);
            } else if(eleName.equalsIgnoreCase("h3")) {
                wikiBlock(ele, retval);
            } else if(eleName.equalsIgnoreCase("table")) {
                //purposefully strip this out
            } else if(eleName.equalsIgnoreCase("head")) {
                //purposefully strip this out
            } else if(eleName.equalsIgnoreCase("script")) {
                //purposefully strip this out
            } else {
                recursiveExtractIgnore(ele, retval);
            }
        }
    }

    public void wikiBlock(Element parent, StringBuffer retval)
    {
        String eleName = parent.getTagName();
        String trailer = "";
        if (eleName.equalsIgnoreCase("p")) {
            retval.append("\n\n");
            trailer = "\n";
        } else if (eleName.equalsIgnoreCase("h1")) {
            retval.append("\n!!!");
            trailer = "\n";
        } else if (eleName.equalsIgnoreCase("h2")) {
            retval.append("\n!!");
            trailer = "\n";
        } else if (eleName.equalsIgnoreCase("h3")) {
            retval.append("\n!");
            trailer = "\n";
        } else if (eleName.equalsIgnoreCase("table")) {
            return;   //strip out tables
        } else if (eleName.equalsIgnoreCase("ol")) {
            return;   //strip out tables
        } else if (eleName.equalsIgnoreCase("ul")) {
            return;   //strip out tables
        } else if (eleName.equalsIgnoreCase("tr")) {
            return;   //strip out tables
        } else if (eleName.equalsIgnoreCase("td")) {
            return;   //strip out tables
        } else if (eleName.equalsIgnoreCase("img")) {
            return;   //strip out images
        } else if (eleName.equalsIgnoreCase("strong")) {
            wikiStyle(parent, retval);
            return;
        } else if (eleName.equalsIgnoreCase("a")) {
            wikiStyle(parent, retval);
            return;
        } else if (eleName.equalsIgnoreCase("hr")) {
            retval.append("\n----\n");
            return;
        } else if (eleName.equalsIgnoreCase("span")) {
            wikiStyle(parent, retval);
            return;
        } else if (eleName.equalsIgnoreCase("b")) {
            wikiStyle(parent, retval);
            return;
        } else if (eleName.equalsIgnoreCase("i")) {
            wikiStyle(parent, retval);
            return;
        } else if (eleName.equalsIgnoreCase("div")) {
            //ok, no debug output
        } else {
            retval.append("\n---block "+eleName+"\n");
        }
        NodeList childNdList = parent.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++) {
            org.w3c.dom.Node n = childNdList.item(i) ;
            if (n.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                Element ele = (Element)n;
                eleName = parent.getTagName();
                if (eleName.equalsIgnoreCase("p")) {
                    wikiBlock(ele, retval);
                } else if (eleName.equalsIgnoreCase("h1")) {
                    wikiBlock(ele, retval);
                } else if (eleName.equalsIgnoreCase("h2")) {
                    wikiBlock(ele, retval);
                } else if (eleName.equalsIgnoreCase("h3")) {
                    wikiBlock(ele, retval);
                } else if (eleName.equalsIgnoreCase("div")) {
                    wikiBlock(ele, retval);
                } else if (eleName.equalsIgnoreCase("table")) {
                    //strip out tables
                } else if (eleName.equalsIgnoreCase("tr")) {
                    //strip out tables
                } else if (eleName.equalsIgnoreCase("td")) {
                    //strip out tables
                } else {
                    wikiStyle(ele, retval);
                }
            }
            else {
                retval.append(n.getNodeValue());
            }
        }
        retval.append(trailer);
    }

    public void wikiStyle(Element parent, StringBuffer retval)
    {
        String styleText = "";
        String eleName = parent.getTagName();
        if(eleName.equalsIgnoreCase("b")) {
            styleText="__";
        }
        if(eleName.equalsIgnoreCase("strong")) {
            styleText="__";
        } else if(eleName.equalsIgnoreCase("i")) {
            styleText="''";
        } else if(eleName.equalsIgnoreCase("span")) {
            styleText="";
        } else if(eleName.equalsIgnoreCase("a")) {
            //wikiLink(parent, retval);
            return;
        } else if(eleName.equalsIgnoreCase("hr")) {
            retval.append("\n----(inside style)\n");
            return;
        } else if (eleName.equalsIgnoreCase("img")) {
            return;   //strip out images
        } else {
            retval.append("\n---style for "+eleName+"\n");
        }
        retval.append(styleText);
        NodeList childNdList = parent.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++) {
            org.w3c.dom.Node n = childNdList.item(i) ;
            if (n.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                Element ele = (Element)n;
                wikiStyle(ele, retval);
            }
            else {
                retval.append(n.getNodeValue());
            }
        }
        retval.append(styleText);
    }

/*
    public void wikiLink(Element parent, StringBuffer retval)
    {
        String linkName = DOMFace.textValueOf(parent, true);
        String linkAddr = parent.getAttribute("href");
        //probably need to clean up this link somewhat...
        retval.append("[");
        retval.append(linkName);
        retval.append("|");
        retval.append(linkAddr);
        retval.append("]");

    }

    public String dita2Wiki(Element parent)
    {
        StringBuffer retval = new StringBuffer();

        recursiveDita(parent, retval);

        return retval.toString();
    }

    public void recursiveDita(Element parent, StringBuffer retval)
    {
        Enumeration eee = getChildElements(parent);
        while (eee.hasMoreElements()) {
            Element ele = (Element)eee.nextElement();
            String eleName = ele.getTagName();
            if (eleName==null) {
                //do nothing
            } else if(eleName.equalsIgnoreCase("title")) {
                retval.append("\n!!!");
                retval.append(DOMFace.textValueOf(ele, true));
                retval.append("\n");
            } else if(eleName.equals("taskbody")) {
                recursiveDita(ele, retval);
            } else if(eleName.equals("prereq")) {
                recursiveDita(ele, retval);
            } else if(eleName.equals("context")) {
                recursiveDita(ele, retval);
            } else if(eleName.equals("steps")) {
                recursiveDita(ele, retval);
            } else if(eleName.equals("result")) {
                recursiveDita(ele, retval);
            } else if(eleName.equals("p")) {
                ditaBlock(ele, retval);
            } else if(eleName.equals("step")) {
                ditaBlock(ele, retval);
            } else {
                retval.append("\n--what is "+eleName+"?\n");
            }
        }
    }

    public void ditaBlock(Element parent, StringBuffer retval)
    {
        String eleName = parent.getTagName();
        String trailer = "";
        if (eleName.equalsIgnoreCase("p")) {
            retval.append("\n");
            trailer = "\n";
        } else if (eleName.equals("uicontrol")) {
            ditaStyle(parent,retval);
            return;
        } else if (eleName.equals("b")) {
            //fake a p since it is missing
            retval.append("\n");
            ditaStyle(parent,retval);
            retval.append("\n");
            return;
        } else if (eleName.equals("cmd")) {
            //nothing special needed
        } else if (eleName.equals("info")) {
            //nothing special needed
        } else if (eleName.equals("stepresult")) {
            //nothing special needed
        } else if (eleName.equals("note")) {
            retval.append("\nNote: ");
        } else if (eleName.equals("step")) {
            retval.append("\n* ");
            trailer = "\n";
        } else {
            retval.append("\n--unknown block "+eleName+"\n");
        }
        NodeList childNdList = parent.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++) {
            org.w3c.dom.Node n = childNdList.item(i) ;
            if (n.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                Element ele = (Element)n;
                eleName = parent.getTagName();
                if (eleName.equals("cmd")) {
                    ditaBlock(ele, retval);
                } else if (eleName.equals("info")) {
                    ditaBlock(ele, retval);
                } else if (eleName.equals("p")) {
                    ditaBlock(ele, retval);
                } else if (eleName.equals("cmd")) {
                    ditaBlock(ele, retval);
                } else if (eleName.equals("step")) {
                    ditaBlock(ele, retval);
                } else {
                    ditaStyle(ele, retval);
                }
            }
            else {
                retval.append(n.getNodeValue());
            }
        }
        retval.append(trailer);
    }

    public void ditaStyle(Element parent, StringBuffer retval)
    {
        String styleText = "";
        String trailer = "";
        String eleName = parent.getTagName();
        if(eleName.equals("b")) {
            styleText="__";
            trailer="__";
        } else if(eleName.equals("strong")) {
            styleText="__";
            trailer="__";
        } else if (eleName.equals("uicontrol")) {
            styleText="\"";
            trailer="\"";
        } else if (eleName.equals("note")) {
            retval.append("\nNote: ");
        } else {
            styleText="\n+++style for "+eleName+"\n";
            trailer="\n---style for "+eleName+"\n";
        }
        retval.append(styleText);
        NodeList childNdList = parent.getChildNodes();
        for (int i = 0 ; i < childNdList.getLength(); i++) {
            org.w3c.dom.Node n = childNdList.item(i) ;
            if (n.getNodeType() == org.w3c.dom.Node.ELEMENT_NODE) {
                Element ele = (Element)n;
                ditaStyle(ele, retval);
            }
            else {
                retval.append(n.getNodeValue());
            }
        }
        retval.append(trailer);
    }
*/


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
