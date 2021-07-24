package org.workcast.wu;

import java.io.Writer;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;

import org.jsoup.nodes.Attribute;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;

import com.purplehillsbooks.streams.HTMLWriter;

/*
 * Represents a piece of text of various types like 
 * a hyperlink, bold, italics, or unstylized texts
 * 
 * Nested text can be used to represent text that is multiply styled
 */
public class SimplePageText {
    
    public static final int PLAIN_TEXT = 1;
    public static final int TAG        = 2;
    public static final int LINK       = 3;
    
    public SimplePage thePage;
    int textType;
    String content;
    String url;
    
    List<SimplePageText> nested = new ArrayList<SimplePageText>();
    
    public static SimplePageText createPlainText(SimplePage sp, String content) {
        SimplePageText sbt = new SimplePageText();
        sbt.thePage = sp;
        sbt.textType = PLAIN_TEXT;
        sbt.content = content;
        return sbt;
    }
    public static SimplePageText createStyle(SimplePage sp, String tagName) {
        SimplePageText sbt = new SimplePageText();
        sbt.thePage = sp;
        sbt.textType = TAG;
        sbt.content = tagName;
        return sbt;
    }
    public static SimplePageText createLink(SimplePage sp, String content, String url) {
        SimplePageText sbt = new SimplePageText();
        sbt.thePage = sp;
        sbt.textType = LINK;
        sbt.content = content;
        sbt.url     = url;
        return sbt;
    }
    
    
    
    
    public void addPlainText(String content) {
        SimplePageText sbt = SimplePageText.createPlainText(thePage, content);
        nested.add(sbt);
    }
    public SimplePageText addStyle(String tagName) {
        SimplePageText sbt = SimplePageText.createStyle(thePage, tagName);
        nested.add(sbt);
        return sbt;
    }
    
    public void fillContent(Writer wr, Element ele) throws Exception {
        String tagName = ele.nodeName().toLowerCase();
        if ("a".equals(tagName)) {
            streamLink(wr, ele);
            return;
        }
        SimplePageText spt = this;
        if ( SimplePageBlock.exposedTagType(tagName) ) {
            spt = SimplePageText.createStyle(thePage, tagName);
            nested.add(spt);
            wr.write("("+tagName+")");
        }
        else {
            wr.write("(-"+tagName+")");
        }

        for (Node child : ele.childNodes()) {
            if (child instanceof TextNode) {
                TextNode tNode = (TextNode) child;
                String t = tNode.getWholeText();
                spt.addPlainText(t);
                HTMLWriter.writeHtml(wr, t);
            }
            else if (child instanceof Element) {
                Element childEle = (Element) child;
                spt.fillContent(wr, childEle);
            }
        }        
        
        wr.write("(/"+tagName+")");
    }

    
    public void streamLink(Writer wr, Element ele) throws Exception {
        String url = "";
        for (Attribute att : ele.attributes()) {
            if (att.getKey().equalsIgnoreCase("href")) {
                url = att.getValue();
                if (url.toLowerCase().startsWith("http")) {
                    //nothing to do
                }
                else if (url.startsWith("/")) {
                    //root style relative URL
                    url = thePage.rootUrl + url;
                }
                else {
                    //relative URL to current context
                    url = thePage.contextUrl + url;
                }
            }
        }
        String val = ele.text().trim();
        if (val.length()==0) {
            return;
        }
        SimplePageText sbt = SimplePageText.createLink(thePage, val, url);
        nested.add(sbt);
        
        wr.write("<a href=\"cleaner4.jsp?path=");
        wr.write(URLEncoder.encode(url, "UTF-8"));
        wr.write("\">");
        HTMLWriter.writeHtml(wr,val);
        wr.write("</a>");
    }

    public void produceHtml(Writer w) throws Exception {
        if (textType == SimplePageText.TAG) {
            w.write("<"+content+">");
            for (SimplePageText sbt : nested) {
                sbt.produceHtml(w);
            }
            w.write("</"+content+">");
        }
        else if (textType == SimplePageText.PLAIN_TEXT) {
            HTMLWriter.writeHtml(w,content);
        }
        else if (textType == SimplePageText.LINK) {
            w.write("<a href=\"cleaner4.jsp?path=");
            w.write(URLEncoder.encode(url, "UTF-8"));
            w.write("\">");
            HTMLWriter.writeHtml(w,content);
            w.write("</a>");
        }
    }
    
}
