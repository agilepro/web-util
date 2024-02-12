/*
 * Copyright 2013 Keith D Swenson
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Contributors Include: Shamim Quader, Sameer Pradhan, Kumar Raja, Jim Farris,
 * Sandia Yang, CY Chen, Rajiv Onat, Neal Wang, Dennis Tam, Shikha Srivastava,
 * Anamika Chaudhari, Ajay Kakkar, Rajeev Rastogi
 */

package org.workcast.wu;


import java.io.InputStream;
import java.io.LineNumberReader;
import java.io.Reader;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;

import javax.swing.text.MutableAttributeSet;
import javax.swing.text.html.HTML;
import javax.swing.text.html.HTMLEditorKit;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.conn.ssl.TrustAllStrategy;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.ssl.SSLContextBuilder;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.nodes.Entities;
import org.jsoup.nodes.Node;

import com.purplehillsbooks.streams.MemFile;
import com.purplehillsbooks.streams.SSLPatch;

/**
 * This is a object that takes a HTML value generated by WYSIWYG Editor and
 * generate the Wiki text according to the {@link WikiConverter}. Not sure
 * whether this covers everything. but it handles content that is copy paste
 * from the other resources as well for example outlook etc.
 *
 * NOTE: in March 2012 there was a change to the wiki format by adding the
 * ability to "escape" certain characters with a escape character (EC).  Prior to this,
 * if anyone typed a left square bracket, two underscores, two single quotes,
 * and sometimes other characters into the HTML editor, those would disappear
 * because those are the character sequences in the underlying wiki format
 * that cause styles to appear.  Inventing an escape mechanism means that
 * when those characters are encountered converting from HTML, an additional
 * EC will be added before the character.  Upon output, when
 * a EC is encountered in the wiki text followed by one of these
 * characters, the EC will be suppressed, and the following character will
 * appear without being interpreted as a styling character.  If a EC
 * character appears in the HTML input it will also need a preceeding an EC
 * so that it is not confused with being used to escape the following char.
 *
 * The EC is never seen by the user except when they edit using RAW wiki text.
 * So it does not matter what the EC character looks like.
 * RAW edit is still a possibility sometime, but typically a person who is
 * editing the raw text will put up with some special characters.
 * Because we already have a large body of wiki text to preserve, we would
 * like to pick a character that is not very commonly used, in order to reduce
 * the amount of conversion problems.  We would like to do conversion on the
 * fly so that there is no need to process the entire existing knowledge base.
 * As each note is edited, the new version will be saved with the escapes.
 *
 * EC will be ? (masculine ordinal indicator) because this is quite uncommonly
 * used, and almost certainly is not used in any of our existing documentation.
 *
 *     WIKI FORMAT         HTML
 *        ?                _
 *        ?'               '
 *        ?[               [
 *        ??               ?
 *
 * If the EC is seen in the wiki format followed by anything else, it is
 * technically an error (not allowed) but will be handled by simply outputting
 * the exact same sequence and NOT suppressing the EC:
 *
 *        ยบ?                ยบ?
 *
 * MIGRATION: because we have a lot of wiki-format information that does
 * not have the EC escapes, how is this migrated?
 * First of all, use of underscore, square bracket, and single quote were
 * ONLY allowed for formatting purposes.  The simply was no way to put a
 * square bracket in and not have it interpreted as a link.  Wiki format
 * simply did not support this so we should not expect a lot of this to exist.
 *
 * The biggest issue is for previous usage of the EC character.  A single
 * EC could have been in the text before, not for the purpose of escaping
 * the following character.  If the following character is not one of the
 * four characters that can be escaped, then it will be output exactly as
 * it had in the past.  If that is to the editor, and the user updates
 * then the EC will be escaped when it is input back to the system, and the
 * topic will be effectively converted.
 *
 * The only really undesirable situation occurs when the EC exists in a
 * topic already followed by an underscore, single quote, square bracket,
 * or another EC.  In that situation, the output will be distorted from what
 * it used to be.  We are hoping that the combination of using an
 * unusual EC, along with the unlikelyhood that it is followed by on of the
 * four special characters, we expect this to have minimal effect.
 * Any cases that might exist will have to be converted by hand, normally
 * by adding the EC back in (which had been suppressed) and re-styling
 * the following text to the way it had been.
 *
 * Once enough time has passed for the topics to be considered converted
 * it will be relatively safe to add new characters that can be escaped
 * for future special meanings.
 */
public class HtmlToWikiConverter2 {

    public final static char ESCAPE_CHAR = 'º';
    public MemFile htmlValue;
    public List<ParseFrame2> wikiFrames = new ArrayList<>();
    public List<String> wikiValue = new ArrayList<>();
    private int bulletIndentationLevel = 0;
    private String baseUrl;
    
    List<ParseFrame2> wikiStack = new ArrayList<>();
    ParseFrame2 currentFrame;
    

    /**
     * This method takes a HTML String generated by the Editor and will use
     * {@link HTMLParser2} to parse the HTML to generate WIKI text from that.
     *
     * @param htmlValue
     * @return
     * @throws Exception
     */
    public List<String> htmlToWiki(String htmlValue, String path) throws Exception {
        // HtmlToWikiConverter.baseURL = baseURL;
        // There was some problem saving &nbsp; in XML file so replaced it with
        // the space.
        htmlValue = htmlValue.replaceAll( "&nbsp;", " " ).replaceAll( "\r", "" );

        Reader reader = new StringReader( htmlValue );
        return htmlStreamToWiki(reader, path);
    }
    
    int frameCount = 0;
    public List<String>  htmlStreamToWiki(Reader reader, String path) throws Exception {
        baseUrl = findContainingUrl(path);
        
        currentFrame = new ParseFrame2();
        currentFrame.tagType = "ROOT";
        currentFrame.frameNo = ++frameCount;
        currentFrame.isIgnoring = false;
        wikiFrames.add(currentFrame);
        
        MemFile mf = new MemFile();
        mf.fillWithReader(reader);
        
        Document doc = Jsoup.parse(mf.getInputStream(), "UTF-8", baseUrl);
        Element body = doc.body();
        scanMajorElement(body, "=  ");
        genAllText();
        return wikiValue;
    }
    
    public void recurseNodes(Node node, String depth) {
        System.out.println(depth + node.nodeName());
        for (Node child : node.childNodes()) {
            recurseNodes(child, depth + "  ");
        }
    }
    
    public void scanMajorElement(Node ele, String depth) {
        for (Node child : ele.childNodes()) {
            String nodeName = child.nodeName().toLowerCase();
            
            if (child instanceof Element) {
                // System.out.println(depth + "<"+nodeName+">");
                if ("style".equals(nodeName)) {
                    continue; // we don't care about styles or any contents
                }
                else if ("script".equals(nodeName)) {
                    continue; // we don't care about script or any contents
                }
                else if ("figure".equals(nodeName)) {
                    continue; // we don't care about figures
                }
                else if ("div".equals(nodeName)) {
                    push("div", false);
                    scanMajorElement((Element)child, depth+"  ");
                    pop();
                }
                else if ("p".equals(nodeName)) {
                    if (!isInside("li")) {
                        currentFrame.addBlock("");
                    }
                    scanMajorElement((Element)child, depth+"* ");
                }
                else if ("td".equals(nodeName) || "th".equals(nodeName)) {
                    currentFrame.addBlock("");
                    scanMajorElement((Element)child, depth+"* ");
                }
                else if ("h1".equals(nodeName)) {
                    currentFrame.addBlock("!!!");
                    formatText(child, depth+"- ");
                }
                else if ("h2".equals(nodeName)) {
                    currentFrame.addBlock("!!");
                    formatText(child, depth+"- ");
                }
                else if ("h3".equals(nodeName) || "h4".equals(nodeName) || "h5".equals(nodeName) || "h6".equals(nodeName)) {
                    currentFrame.addBlock("!");
                    formatText(child, depth+"- ");
                }
                else if ("hr".equals(nodeName)) {
                    currentFrame.addBlock("");
                    currentFrame.addText("----");
                    currentFrame.addBlock("");
                }
                else if ("br".equals(nodeName)) {
                    currentFrame.addBlock(":");
                }
                else if ("pre".equals(nodeName)) {
                    currentFrame.addBlock("{{{\n");
                    unformatPreserveNewline(child, depth+"- ");
                    currentFrame.addText("\n}}}");
                }
                else if ("ol".equals(nodeName) || "ul".equals(nodeName)) {
                    bulletIndentationLevel++;
                    scanMajorElement((Element)child, depth+"* ");
                    bulletIndentationLevel--;
                }
                else if ("li".equals(nodeName)) {
                    startBlock("*");
                    scanMajorElement((Element)child, depth+"  ");
                }
                else if ("b".equals(nodeName) || "strong".equals(nodeName)) {
                    currentFrame.addText("__");
                    formatText(child, depth+"b ");
                    currentFrame.addText("__");
                }
                else if ("i".equals(nodeName) || "emphasis".equals(nodeName)) {
                    currentFrame.addText("''");
                    formatText(child, depth+"i ");
                    currentFrame.addText("''");
                }
                else if ("a".equals(nodeName)) {
                    String href = ((Element)child).attr("href");
                    if (href!=null && href.length()>5 && !href.startsWith("mailto")) {
                        StringBuilder sb = new StringBuilder();
                        unformatText(child, depth+"u ", sb);
                        String linkedText = sb.toString().trim();
                        if (linkedText.length()>0) {
                            currentFrame.addText("[");
                            currentFrame.addText(linkedText.toString());
                            currentFrame.addText("|");
                            currentFrame.addText(convertToGlobalUrl(href));
                            currentFrame.addText("]");
                        }
                    }
                }
                else if ("span".equals(nodeName)) {
                    //apparently the text editor we are using will inclue span tags for
                    //certain kinds of styling, so need to respond.  Difficult, however
                    //to match the right end tag when there are multiple nested spans.
                    //Might consider tracking each span as nested in.
                    String clazz = ((Element)child).attr( "style" );
                    if (clazz.contains( "bold;" )) {
                        currentFrame.addText("__");
                        formatText(child, depth+"b ");
                        currentFrame.addText("__");
                    }
                    else if (clazz.contains( "italic;" )) {
                        currentFrame.addText("''");
                        formatText(child, depth+"i ");
                        currentFrame.addText("''");
                    }
                    else {
                        formatText(child, depth+"i ");
                    }
                }
                else if ("#text".contentEquals(nodeName)) {
                    copyWhileEscaping(child.toString(), true);
                }
                else {
                    // we don't know what it is, just scan the contents as if it is these contents.
                    scanMajorElement(child, depth + ":  ");
                }
            }
            else {
                if ("#comment".equals(nodeName)) {
                    continue; // we don't care about comments
                }
                else if ("#text".equals(nodeName)) {
                    copyWhileEscaping(child.toString(), true);
                }
            }
        }        
    }
    
    private boolean isInside(String tag) {
        for (ParseFrame2 pf : wikiStack) {
            if (pf.tagType.equals(tag)) {
                return true;
            }
        }
        return false;
    }
    
    public void formatText(Node node, String depth) {
        for (Node child : node.childNodes()) {
            String nodeName = child.nodeName().toLowerCase();
            if ("b".equals(nodeName) || "strong".equals(nodeName)) {
                currentFrame.addText("__");
                formatText(child, depth+"b ");
                currentFrame.addText("__");
            }
            else if ("i".equals(nodeName) || "emphasis".equals(nodeName)) {
                currentFrame.addText("''");
                formatText(child, depth+"i ");
                currentFrame.addText("''");
            }
            else if ("a".equals(nodeName)) {
                String href = ((Element)child).attr("href");
                if (href!=null && href.length()>5) {
                    StringBuilder sb = new StringBuilder();
                    unformatText(child, depth+"u ", sb);
                    if (sb.length()>0) {
                        currentFrame.addText("[");
                        currentFrame.addText(sb.toString());
                        currentFrame.addText("|");
                        currentFrame.addText(convertToGlobalUrl(href));
                        currentFrame.addText("]");
                    }
                }
            }
            else if ("span".equals(nodeName)) {
                //apparently the text editor we are using will inclue span tags for
                //certain kinds of styling, so need to respond.  Difficult, however
                //to match the right end tag when there are multiple nested spans.
                //Might consider tracking each span as nested in.
                String clazz = ((Element)child).attr( "style" );
                if (clazz.contains( "bold;" )) {
                    currentFrame.addText("__");
                    formatText(child, depth+"b ");
                    currentFrame.addText("__");
                }
                if (clazz.contains( "italic;" )) {
                    currentFrame.addText("''");
                    formatText(child, depth+"i ");
                    currentFrame.addText("''");
                }
            }
            else if ("br".equals(nodeName)) {
                currentFrame.addBlock(":");
            }
            else if ("#text".contentEquals(nodeName)) {
                copyWhileEscaping(child.toString(), true);
            }
            else {
                formatText(child, depth+"% ");
            }
        }        
    }
    public void unformatText(Node node, String depth, StringBuilder sb) {
        for (Node child : node.childNodes()) {
            String nodeName = child.nodeName().toLowerCase();
            if ("#text".contentEquals(nodeName)) {
                copyWhileEscaping(child.toString(), false, sb);
            }
            else {
                unformatText(child, depth+"% ", sb);
            }
        }        
    }
    public void unformatPreserveNewline(Node node, String depth) {
        for (Node child : node.childNodes()) {
            String nodeName = child.nodeName().toLowerCase();
            if ("#text".contentEquals(nodeName)) {
                copyWhileEscaping(child.toString(), false);
            }
            else if ("br".contentEquals(nodeName)) {
                currentFrame.addText("\n");
            }
            else {
                unformatPreserveNewline(child, depth+"% ");
            }
        }        
    }
    
    private void copyWhileEscaping(String input, boolean allowBraces) {
        StringBuilder sb = new StringBuilder();
        copyWhileEscaping(input, allowBraces, sb);
        currentFrame.addText(sb.toString());
    }
    private void copyWhileEscaping(String input, boolean allowBraces, StringBuilder sb) {
        input = Entities.unescape(input);
        
        //walk through and escape special characters that would
        //otherwise cause possible styling errors
        //StringBuilder debug = new StringBuilder();
        for (int i=0; i<input.length(); i++) {
            char ch = input.charAt(i);
            if (ch<32) {
                if (ch==9 || ch==10 || ch==13) {
                    //these are the only valid characters less than 32, strip out any others
                    //this is critical because inclusion of these characters can cause the 
                    //XML parsing to fail for the entire workspace
                    //  \t = 9,  \n = 10, \r = 13
                    sb.append( ch );
                }
            }
            else if (!allowBraces && ch=='[') {
                sb.append( '(' );
            }
            else if (!allowBraces && ch==']') {
                sb.append( ')' );
            }
            else if (ch=='[' || ch=='_' || ch=='\'' || ch==ESCAPE_CHAR) {
                sb.append(ESCAPE_CHAR);
                sb.append( ch );
            }
            else {
                sb.append( ch );
            }
        }
        //System.out.println("--("+debug.toString()+")");
    }
    
    public String niceText(String in) {
        if (in.length()>30) {
            in = in.substring(0, 30);
        }
        return in;
    }
    
    public List<String> webPageToWiki(String path) throws Exception {
        
        htmlValue = new MemFile();

        HttpClient httpclient = getGoodClient();
        HttpGet httpget = new HttpGet(path);

        HttpResponse response = httpclient.execute(httpget);
        InputStream input = response.getEntity().getContent();
        
        htmlValue.fillWithInputStream(input);
        input.close();
        
        return htmlStreamToWiki(htmlValue.getReader(), path);
    }
    
    
    public HttpClient getGoodClient() {
        try { 
            /*
            HttpClient base = new DefaultHttpClient();
            ClientConnectionManager ccm = base.getConnectionManager();
            
            SSLContext ctx = SSLContext.getInstance("TLS");
            ctx.init(null, new TrustManager[]{SSLPatch.getDummyTrustManager()}, null);
            SSLConnectionSocketFactory ssf = new SSLConnectionSocketFactory(ctx,  
                     SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
            //SchemeRegistry sr = ccm.getSchemeRegistry();
            //sr.register(new Scheme("https", ssf, 443));
            return new DefaultHttpClient(ccm, base.getParams());
            */
            HttpClientBuilder hcb = HttpClientBuilder.create();
            hcb.setSSLContext(new SSLContextBuilder().loadTrustMaterial(null, TrustAllStrategy.INSTANCE).build());
            hcb.setSSLHostnameVerifier(SSLPatch.getAllHostVerifier());
            return hcb.build();
            
        } catch (Exception ex) {
            return null;
        }
    }

    public String resultString() {
        genAllText();
        return String.join("\n\n", wikiValue);
    }
    
    public void push(String newTagType, boolean ignore) {
        wikiStack.add(currentFrame);
        currentFrame = new ParseFrame2();
        currentFrame.tagType = newTagType;
        currentFrame.isIgnoring = ignore;
        currentFrame.frameNo = ++frameCount;
        wikiFrames.add(currentFrame);
        //System.out.println("Created: "+currentFrame.tagType+":"+currentFrame.frameNo);
    }
    
    public void pop() {
        //System.out.println("-end-  : "+currentFrame.tagType+":"+currentFrame.frameNo);
        if (wikiStack.size()>0) {
            currentFrame = wikiStack.remove(wikiStack.size()-1);
        }
    }
    private void startBlock(String blockType) {
        if ("*".equals(blockType)) {
            StringBuilder startChars = new StringBuilder();
            for (int i = 0; i < bulletIndentationLevel; i++) {
                startChars.append( "*" );
            }
            startChars.append( " " );
            blockType = startChars.toString();
        }
        currentFrame.addBlock(blockType);
    }
    
    public String convertToGlobalUrl(String relativeUrl) {
        if (relativeUrl.startsWith("http")) {
            // it already is global so just return it
            return relativeUrl;
        }
        
        // site global or root relative URL starts with a slash
        if (relativeUrl.startsWith("/")) {
            return siteRootPath() + relativeUrl;
        }
        
        // get rid of any .. elements from the beginning
        String containerPath = baseUrl;
        while (relativeUrl.length()>3 && relativeUrl.startsWith("../")) {
            relativeUrl = relativeUrl.substring(3);
            containerPath = findContainingUrl(containerPath);
        }

        return containerPath + "/" + relativeUrl;
    }
    
    /**
     * @return the "https://sitename" without a slash on the end
     */
    public String siteRootPath() {
        // https:// is 8 letters long
        int firstSlash = baseUrl.indexOf("/", 9);
        if (firstSlash > 0) {
            return baseUrl.substring(0, firstSlash);
        }
        // we have to assume here that it already is the site root
        return baseUrl;
    }

    public String findContainingUrl(String url) {
        int index = url.lastIndexOf("/");
        if (index > 10) {
            return url.substring(0, index);
        }
        // if we don't find a slash more than 10 characters in
        // then just return the whole thing, there is no  container.
        return url;
    }
    
    public void genAllText() {
        wikiValue = new ArrayList<>();
        for (ParseFrame2 frame : wikiFrames) {
            String result = frame.getFinalText();
            if (result.length()>0) {
                // only add the resulting string if there is something there.
                // otherwise we can just ignore this block
                wikiValue.add(result);
            }
        }
            
    }
}


class WikiBlock2 {
    public String startChars = "";
    StringBuilder text = new StringBuilder();
}


class ParseFrame2 {
    public String tagType = "UNKNOWN";
    public boolean isIgnoring = true;
    public int frameNo = -1;
    List<WikiBlock2> blocks = new ArrayList<>();
    WikiBlock2 currentBlock = new WikiBlock2();
    
    public void addText(String value) {
        if (!isIgnoring) {
            currentBlock.text.append(value);
            String text = value;
            if (text.length()>40) {
                text = value.substring(0, 40);
            }
            //System.out.println("text   : "+tagType+":"+frameNo+": "+text);
        }
    }
    
    public void addChar(char value) {
        if (!isIgnoring) {
            currentBlock.text.append(value);
        }
    }
    
    public void addBlock(String blockChars) {
        if (currentBlock.text.length()>0) {
            blocks.add(currentBlock);
            currentBlock = new WikiBlock2();
        }
        currentBlock.startChars = blockChars;
    }
    public void finish() {
        if (currentBlock!=null && currentBlock.text.length()>0) {
            blocks.add(currentBlock);
        }
        currentBlock = null;
    }
    
    public String getFinalText() {
        StringBuilder finalText = new StringBuilder();
        boolean needBlankLine = false;
        finish();
        for (WikiBlock2 block: blocks) {
            if (block.text.length()>0) {
                if(block.startChars.length()==0) {
                    if (needBlankLine) {
                        finalText.append("\n");
                    }
                    needBlankLine = true;
                }
                else {
                    finalText.append(block.startChars);
                }
                finalText.append(block.text);
                finalText.append("\n");
            }
        }
        return finalText.toString().trim();        
    }
}


/**
 * This class is subclass of {@link HTMLEditorKit.ParserCallback}. This class
 * implemented method to parse HTML and convert WIKI text from that.
 *
 */
class HTMLParser2 extends HTMLEditorKit.ParserCallback {

    public final static char ESCAPE_CHAR = 'º';

    private String href = "";
    private StringBuilder linkText = new StringBuilder();

    private int BULLETS_INDENTATION_LEVEL = 0;
    private boolean isBold      = false;
    private boolean isItalics   = false;
    private String  inBlock     = null;

    //these are set instead of outputting a style prefix
    //and they actually cause the output when the first non-whitespace
    //text is output
    private boolean prepareBold = false;
    private boolean prepareItal = false;
    private boolean prepareLineFeed = false;
    
    List<String> wikiFinal = new ArrayList<>();
    List<ParseFrame2> wikiStack = new ArrayList<>();
    ParseFrame2 currentFrame;
    
    public HTMLParser2(String fullUrl, LineNumberReader newReader) {
        //baseUrl = findContainingUrl(fullUrl);
        currentFrame = new ParseFrame2();
        currentFrame.tagType = "ROOT";
    }
    

    public void handleText(char[] data, int pos) {

        String tempStr = new String(data);
        tempStr = tempStr.trim();
        if (tempStr.length()==0) {
            return;   //don't do any processing below because not non-white
        }

        //none of these should be output unless the is non-empty text
        if (inBlock==null) {
            //outputting text without any block should cause a paragraph block to start
            startBlock("\n");
        }
        if (prepareLineFeed) {
            currentFrame.addText("\n:");
            prepareLineFeed = false;
        }
        if (prepareBold) {
            currentFrame.addText("__");
            prepareBold = false;
            isBold = true;
        }
        if (prepareItal) {
            currentFrame.addText("''");
            prepareItal = false;
            isItalics = true;
        }
        if (currentFrame.isIgnoring) {
            //if you are inside a link, then append the text to this
            linkText.append(data);
        }
        else {
            //this text is NOT in a link.  We need to escape dangerous
            //characters, and also to look for unlinked URLS for automatic
            //conversion to a link.
            StringBuilder smallerBuffer = new StringBuilder();

            //copy over -- don't escape here, do it lower down
            for (char ch : data) {
                smallerBuffer.append( ch );
            }

            //now search for occurrences of http:// and https://
            int start = 0;
            while (start<smallerBuffer.length()) {
                int pos1 = smallerBuffer.indexOf("http://", start);
                int pos2 = smallerBuffer.indexOf("https://", start);
                if (pos1<start && pos2<start) {
                    //nothing else found, so copy the rest of the string and quit
                    copyWhileEscaping(currentFrame, smallerBuffer.substring(start));
                    start = smallerBuffer.length();
                    break;
                }

                //figure out whether http or https is earlier
                if ((pos2>=start && pos2<pos1) || pos1<start) {
                    pos1 = pos2;
                }
                //find the end of the link by a space character.
                int endPos = smallerBuffer.indexOf(" ", pos1);
                if (endPos<pos1) {
                    endPos = smallerBuffer.length();
                }

                //now copy the link inside of square brackets
                copyWhileEscaping(currentFrame, smallerBuffer.substring(start, pos1));
                currentFrame.addText("[");
                currentFrame.addText(smallerBuffer.substring(pos1, endPos));
                currentFrame.addText("]");
                start = endPos;
            }
        }
    }

    private void copyWhileEscaping(ParseFrame2 dest, String input) {
        //walk through and escape special characters that would
        //otherwise cause possible styling errors
        for (int i=0; i<input.length(); i++) {
            char ch = input.charAt(i);
            if (ch<32) {
                if (ch==9 || ch==10 || ch==13) {
                    //these are the only valid characters less than 32, strip out any others
                    //this is critical because inclusion of these characters can cause the 
                    //XML parsing to fail for the entire workspace
                    dest.addChar( ch );
                }
            }
            else if (ch=='[' || ch=='_' || ch=='\'' || ch==ESCAPE_CHAR) {
                dest.addChar(ESCAPE_CHAR);
                dest.addChar( ch );
            }
            else {
                dest.addChar( ch );
            }
        }
    }

    //text block is H1, H2, H3, P
    private void startBlock(String blockType) {
        if (inBlock != null) {
            //this is a clean up situation ... a block was started without concluding another
            //block, this could happen if it put one block inside another block
            //this code will terminate the outer block, and start a new block for the inner.
            concludeBlock();
        }
        inBlock = blockType;
        if ("*".equals(blockType)) {
            StringBuilder startChars = new StringBuilder();
            for (int i = 0; i < BULLETS_INDENTATION_LEVEL; i++) {
                startChars.append( "*" );
            }
            startChars.append( " " );
            blockType = startChars.toString();
        }
        currentFrame.addBlock(blockType);
    }

    private void concludeBlock() {
        if (isItalics) {
            currentFrame.addText("''");
        }
        if (isBold) {
            currentFrame.addText("__");
        }
        if (inBlock != null) {
            currentFrame.addText("\n");
        }
        inBlock = null;
        prepareBold = false;
        isBold = false;
        prepareItal = false;
        isItalics = false;
        prepareLineFeed = false;
    }


    public void handleStartTag(HTML.Tag t, MutableAttributeSet a, int pos) {
        if (t == HTML.Tag.H1)
        {
            startBlock("!!!" );
        }
        else if (t == HTML.Tag.H2)
        {
            startBlock("!!" );
        }
        else if (t == HTML.Tag.H3)
        {
            startBlock("!" );
        }
        else if (t == HTML.Tag.P)
        {
            startBlock("\n");
        }
        else if (t == HTML.Tag.PRE)
        {
            startBlock("{{{\n");
        }
        else if (t == HTML.Tag.LI)
        {
            startBlock("*");
        }
        else if (t == HTML.Tag.UL || t == HTML.Tag.OL)
        {
            concludeBlock();
            BULLETS_INDENTATION_LEVEL++;
        }
        else if (t == HTML.Tag.A)
        {
            Object o = a.getAttribute( HTML.Attribute.HREF );
            if (o!=null) {
                href = o.toString().trim();
            }
            else {
                href= "";
            }
            currentFrame.isIgnoring = true;
            linkText.setLength(0);
        }
        else if (t == HTML.Tag.B || t == HTML.Tag.STRONG)
        {
            prepareBold = true;
        }
        else if (t == HTML.Tag.I || t == HTML.Tag.EM)
        {
            prepareItal = true;
        }
        else if (t == HTML.Tag.SPAN)
        {
            //apparently the text editor we are using will inclue span tags for
            //certain kinds of styling, so need to respond.  Difficult, however
            //to match the right end tag when there are multiple nested spans.
            //Might consider tracking each span as nested in.
            String clazz = "";
            if (a.getAttribute( HTML.Attribute.STYLE ) != null)
            {
                clazz = a.getAttribute( HTML.Attribute.STYLE ).toString();
            }
            if (clazz.contains( "bold;" ) && !isBold)
            {
                prepareBold = true;
            }
            if (clazz.contains( "italic;" ) && !isItalics)
            {
                prepareItal = true;
            }

        }
        else if (t == HTML.Tag.DIV) {
            //some cases have DIV tags only, and we need to treat them like 
            //paragraphs.
            push("DIV", false);
        }
        else if (t == HTML.Tag.TD || t == HTML.Tag.TH) {
            //if you are in a table, then we should treat the cells in the table as creating
            //new paragraph blocks.
            startBlock("\n");
        }
        else if (t == HTML.Tag.STYLE) {
            push("STYLE", true);
        }
        else if (t == HTML.Tag.SCRIPT) {
            push("SCRIPT", true);
        }
        else if (t == HTML.Tag.HEAD) {
            push("HEAD", true);
        }
        else if (t == HTML.Tag.BODY) {
            push("BODY", false);
        }
    }

    public void handleEndTag(HTML.Tag t, int pos) {
        if (t == HTML.Tag.A) {
            currentFrame.isIgnoring = false;
            String lText = linkText.toString().trim();
            if (lText.length()>0) {
                currentFrame.addText("[");
                currentFrame.addText(lText);
                if (href!=null && href.length()>0)  {
                    currentFrame.addText("|");
                    currentFrame.addText(convertToGlobalUrl(href));
                }
                currentFrame.addText("]");
            }
            href=null;
        }
        else if (t == HTML.Tag.STYLE) {
            pop();
            return;
        }
        else if (t == HTML.Tag.SCRIPT) {
            pop();
            return;
        }
        else if (t == HTML.Tag.H1 || t == HTML.Tag.H2
            || t == HTML.Tag.H3 || t == HTML.Tag.P 
            || t == HTML.Tag.TD || t == HTML.Tag.TH ) {
            concludeBlock();
        }
        else if (t == HTML.Tag.DIV)
        {
            concludeBlock();
            pop();
        }
        else if (t == HTML.Tag.PRE)
        {
            currentFrame.addText("\n}}}" );
            concludeBlock();
        }
        else if (t == HTML.Tag.UL)
        {
            concludeBlock();
            BULLETS_INDENTATION_LEVEL--;
        }
        else if (t == HTML.Tag.LI)
        {
            concludeBlock();
        }
        else if (t == HTML.Tag.B || t == HTML.Tag.STRONG) {
            if (isBold) {
                currentFrame.addText("__");
            }
            isBold = false;
            prepareBold = false;
        }
        else if (t == HTML.Tag.I || t == HTML.Tag.EM) {
            if (isItalics) {
                currentFrame.addText("''");
            }
            isItalics = false;
            prepareItal = false;
        }
        else if (t == HTML.Tag.SPAN) {
            /**
             * This will basically handle the span tag. The WYSIWYG editor
             * generate span tag for bold and italic text closing span tag will
             * be replaced accordingly.
             *
             */
            if (isItalics) {
                currentFrame.addText( "''" );
                isItalics = false;
            }
            prepareItal = false;
            if (isBold) {
                currentFrame.addText( "__" );
                isBold = false;
            }
            prepareBold = false;
        }
        else if (t == HTML.Tag.HEAD) {
            pop();
        }
        else if (t == HTML.Tag.BODY) {
            pop();
        }
    }

    public void handleSimpleTag(HTML.Tag t, MutableAttributeSet a, int pos) {
        if (t == HTML.Tag.BR)
        {
            prepareLineFeed = true;
        }
        else if (t == HTML.Tag.HR)
        {
            currentFrame.addText( "\n----\n" );
        }
    }
    
    public void push(String newTagType, boolean ignore) {
    }
    
    public void pop() {
    }
    
    public String findContainingUrl(String url) {
        return "";
    }
    
    public String convertToGlobalUrl(String relativeUrl) {
        return "";
    }

    public String siteRootPath() {
        return "";
    }
}
