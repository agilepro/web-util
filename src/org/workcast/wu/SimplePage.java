package org.workcast.wu;

import java.io.InputStream;
import java.io.Writer;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Node;
import org.jsoup.nodes.TextNode;
import org.jsoup.nodes.Comment;

import com.purplehillsbooks.streams.HTMLWriter;

/*
 * Represents a simplified html page.
 * Is a lost of blocks
 */
public class SimplePage {

    List<SimplePageBlock> blockItems = new ArrayList<SimplePageBlock>();
    SimplePageBlock linkList = new SimplePageBlock(this, SimplePageBlock.MENUNAVBLOCK);
    String rootUrl = "";   //no slash on end
    String contextUrl = "";    //slash on end
    
    public static SimplePage consumeWebPage(Writer wr, String path) throws Exception {
        SimplePage sp = new SimplePage();
        int slashPos = path.lastIndexOf("/"); 
        if (slashPos>1) {
            sp.contextUrl = path.substring(0,slashPos+1);
        }
        slashPos = path.indexOf("//");
        if (slashPos>0) {
            slashPos = path.indexOf("/", slashPos+3);
            if (slashPos>0) {
                sp.rootUrl = path.substring(0,slashPos);
            }
        }
        InputStream input = new URL(path).openStream();
        Document doc = Jsoup.parse(input, null, path);
        Element body = doc.body();
        sp.outputCleanPage(wr,body,"");
        return sp;
    }

    public void outputCleanPage(Writer wr, Element ele, String s) throws Exception {
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
        if ("meta".equals(tagName)) {
            return;
        }

        int kind = kindOfBlock(ele);
        if ("a".equals(tagName)) {
            wr.write("\n<div class=\"showLink\">");
            linkList.captureLinks(wr,ele);
            wr.write("\n</div>");
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
                SimplePageBlock spb = new SimplePageBlock(this, SimplePageBlock.TEXTBLOCK);
                blockItems.add(spb);
                wr.write("\n<div class=\"showText\">");
                spb.fillContent(wr,ele);
                wr.write("\n</div>");
            }
            else if (stats[1]>0) {
                //SimplePageBlock throwAway = new SimplePageBlock(SimplePageBlock.UNKNOWN);
                wr.write("\n<div class=\"showLink\">");
                linkList.captureLinks(wr,ele);
                linkList.addPlainText(", ");
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
                    HTMLWriter.writeHtml(wr,t);
                    wr.write("</div>");
                }
            }
            else if (child instanceof Element) {
                Element subTag = (Element) child;
                outputCleanPage(wr, subTag, p);
            }
            else if (child instanceof Comment) {
                wr.write("\n   - <span style=\"color:green\">");
                HTMLWriter.writeHtml(wr,((Comment)child).getData());
                wr.write("</span><br/>");
            }
            else {
                wr.write("\n   - ? <span style=\"color:red\">");
                HTMLWriter.writeHtml(wr,child.nodeName());
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
    
    public void produceHtml(Writer w) throws Exception {
        int i = 0;
        for (SimplePageBlock sbp : blockItems) {
            w.write("\n<!-- block "+(++i)+" -->\n");
            sbp.produceHtml(w);
        }
        w.write("\n<hr/>\n<h1>Extra Links</h1><p>\n");
        linkList.produceHtml(w);
        w.write("\n</p>");
    }
}
