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

import java.io.Writer;
import java.net.URLEncoder;
import java.util.List;

import com.purplehillsbooks.streams.HTMLWriter;

/**
 * Implements the Wiki formatting.
 * NOTE: this is NOT muti-thread safe!   Use on only one thread
 * at a time.  Usage pattern:
 *
 * WikiConverter wc = new WikiConverter(ar);
 * wc.writeWikiAsHtml(wikiData);
 *
 * writeWikiAsHtml can be called multiple times, but only from
 * a single thread.
 */
public class WikiConverter
{
    final static int NOTHING      = 0;
    final static int PARAGRAPH    = 1;
    final static int BULLET       = 2;
    final static int HEADER       = 3;
    final static int PREFORMATTED = 4;
    
    public final static char ESCAPE_CHAR = 'º';

    protected Writer ar;
    protected int majorState = 0;
    protected int majorLevel = 0;
    protected boolean isBold = false;
    protected boolean isItalic = false;
    protected String userKey;

    protected static String retPath = "";
    protected String linkConverter;

    /**
    * Construct on the AuthRequest that output will be to
    */
    public WikiConverter(Writer destination, String newLinkConverter)
    {
        ar = destination;
        linkConverter = newLinkConverter;
        if (linkConverter == null) {
            // arbitrary
            linkConverter = "/wu/capture.jsp?path=";
        }
    }

    /**
    * Static version create the object instance and then calls the
    * converter directly.   Convenience for the case where you are
    * going to use a converter only once, and only for HTML output.
    */
    public static void writeWikiAsHtml(Writer destination, String tv, String path) throws Exception {
        WikiConverter wc = new WikiConverter(destination, path);
        wc.writeWikiAsHtml(tv);
    }

    /**
    * Takes a block of data formatted in wiki format, and converts
    * it to HTML, outputting that to the writer that was
    * passed in when the object was constructed.
    */
    public void writeWikiAsHtml(String tv) throws Exception {
        LineIterator li = new LineIterator(tv);
        while (li.moreLines())
        {
            String thisLine = li.nextLine();
            formatText(thisLine);
        }
        terminate();
        ar.flush();
    }

    protected void formatText(String line) throws Exception {
        boolean isIndented = line.startsWith(" ");
        if (majorState != PREFORMATTED) {
            line = line.trim();
        }
        if (line.length() == 0) {
            if (majorState != PREFORMATTED) {
                terminate();
            }
        } else if (line.equals("{{{")) {
            startPRE();
        } else if (line.startsWith("}}}")) {
            terminate();
        } else if (line.startsWith("!!!")) {
            startHeader(line, 3);
        } else if (line.startsWith("!!")) {
            startHeader(line, 2);
        } else if (line.startsWith("!")) {
            startHeader(line, 1);
        } else if (line.startsWith("*****")) {
            startBullet(line, 5);
        } else if (line.startsWith("****")) {
            startBullet(line, 4);
        } else if (line.startsWith("***")) {
            startBullet(line, 3);
        } else if (line.startsWith("**")) {
            startBullet(line, 2);
        } else if (line.startsWith("*")) {
            startBullet(line, 1);
        } else if (line.startsWith(":")) {
            if (majorState == PARAGRAPH) {
                makeLineBreak();
            } else {
                startParagraph();
            }
            scanForStyle(line, 1);
        } else if (line.startsWith("----")) {
            terminate();
            makeHorizontalRule();
        } else if (isIndented) {
            // continue whatever mode there is
            scanForStyle(line, 0);
        } else if (line.startsWith("%%")) {
            fomatFontStyle(line);
        }else if (line.endsWith("%%")) {
            fomatFontStyle(line);
        }else {

            if (majorState != PARAGRAPH && majorState != PREFORMATTED) {
                startParagraph();
            }
            scanForStyle(line, 0);
        }
    }

    protected void terminate() throws Exception {
        if (isBold) {
            ar.write("</b>");
        }
        if (isItalic) {
            ar.write("</i>");
        }
        if (majorState == NOTHING) {
        } else if (majorState == PARAGRAPH) {
            ar.write("</p>\n");
        } else if (majorState == PREFORMATTED) {
            ar.write("</pre>\n");
        } else if (majorState == BULLET) {
            ar.write("</li>\n");
            while (majorLevel > 0) {
                ar.write("</ul>\n");
                majorLevel--;
            }
        } else if (majorState == HEADER) {
            switch (majorLevel) {
            case 1:
                ar.write("</h3>");
                break;
            case 2:
                ar.write("</h2>");
                break;
            case 3:
                ar.write("</h1>");
                break;
            }
        }
        majorState = NOTHING;
        majorLevel = 0;
        isBold = false;
        isItalic = false;
    }

    protected void startParagraph() throws Exception {
        terminate();
        ar.write("<p>\n");
        majorState = PARAGRAPH;
        majorLevel = 0;
    }

    protected void startPRE() throws Exception {
        terminate();
        ar.write("<pre>\n");
        majorState = PREFORMATTED;
        majorLevel = 0;
    }

    protected void makeLineBreak() throws Exception {
        ar.write("<br/>");
    }

    protected void makeHorizontalRule() throws Exception {
        ar.write("<hr/>");
    }

    protected void startBullet(String line, int level) throws Exception {
        if (majorState != BULLET) {
            terminate();
            majorState = BULLET;
        } else {
            ar.write("</li>\n");
        }
        while (majorLevel > level) {
            ar.write("</ul>\n");
            majorLevel--;
        }
        while (majorLevel < level) {
            ar.write("<ul>\n");
            majorLevel++;
        }
        ar.write("<li>\n");
        scanForStyle(line, level);
    }

    protected void startHeader(String line, int level) throws Exception {
        terminate();
        majorState = HEADER;
        majorLevel = level;
        switch (level) {
        case 1:
            ar.write("<h3>");
            break;
        case 2:
            ar.write("<h2>");
            break;
        case 3:
            ar.write("<h1>");
            break;
        }
        scanForStyle(line, level);
    }

    protected void scanForStyle(String line, int scanStart) throws Exception {
        int pos = scanStart;
        int last = line.length();
        while (pos < last) {
            char ch = line.charAt(pos);
            switch (ch) {
            case '&':
                ar.write("&amp;");
                pos++;
                continue;
            case '"':
                ar.write("&quot;");
                pos++;
                continue;
            case '<':
                ar.write("&lt;");
                pos++;
                continue;
            case '>':
                ar.write("&gt;");
                pos++;
                continue;
            case '[':

                int pos2 = line.indexOf(']', pos);
                if (pos2 > pos + 1) {
                    String linkURL = line.substring(pos + 1, pos2);
                    outputLink(ar, linkURL);
                    pos = pos2 + 1;
                } else if (pos2 == pos + 1) {
                    pos = pos + 2;
                } else {
                    pos = pos + 1;
                }
                continue;
            case '_':
                if (line.length() > pos + 1 && line.charAt(pos + 1) == '_') {
                    pos += 2;
                    if (isBold) {
                        ar.write("</b>");
                    } else {
                        ar.write("<b>");
                    }
                    isBold = !isBold;
                    continue;
                }
                break;
            case '\'':
                if (line.length() > pos + 1 && line.charAt(pos + 1) == '\'') {
                    pos += 2;
                    if (isItalic) {
                        ar.write("</i>");
                    } else {
                        ar.write("<i>");
                    }
                    isItalic = !isItalic;
                    continue;
                }
                break;
            case ESCAPE_CHAR:
                if (line.length() > pos + 1) {
                    char escape = line.charAt(pos + 1);
                    if (escape == '[' || escape == '\'' || escape == '_'  || escape == ESCAPE_CHAR) {
                        //only these characters can be escaped at this time
                        //if one of these, eliminate the ยบ, and output the following character without interpretation
                        ch = escape;
                        pos++;
                    }
                }
                break;
            }
            ar.write(ch);
            pos++;
        }
        ar.write("\n");
    }


    /**
    * Returns either the position of a white space, or it
    * returns the length of the line if no white space char found
    */
    public static int findIdentifierEnd(String line, int pos) {
        int last = line.length();
        while (pos < last) {
            char ch = line.charAt(pos);
            if (!Character.isLetterOrDigit(ch) && ch!='_') {
                return pos;
            }
            pos++;
        }
        return pos;
    }

    /**
    * Given a block of wiki formatted text, this will find all the
    * links within the block, and return a vector with just the
    * links in them.
    */
    public void findLinks(List<String> v, String inputText) throws Exception {
        LineIterator li = new LineIterator(inputText);
        while (li.moreLines()) {
            String thisLine = li.nextLine();
            scanLineForLinks(thisLine, v);
        }
    }

    protected void scanLineForLinks(String thisLine, List<String> v) {
        int bracketPos = thisLine.indexOf('[');
        int startPos = 0;
        while (bracketPos >= startPos) {
            int endPos = thisLine.indexOf(']', bracketPos);
            if (endPos <= startPos) {
                return; // could not find any more closing brackets, leave
            }
            String link = thisLine.substring(bracketPos + 1, endPos);
            v.add(link);
            startPos = endPos + 1;
            bracketPos = thisLine.indexOf('[', startPos);
        }
    }

    /**
    * outputLink does the job of parsing the "wiki link" value and
    * producing a valid HTML link to the desire thing.
    * Wiki Link values may have a vertical bar character separating the
    * display name of the link from the address.  If that vertical bar is
    * not there, then the entire thing is taken as an address.
    *
    * Either    [ link-name | link-address ]
    * or        [ link-address ]
    *
    * The address can either be the name of another page, or an HTTP hyperlink.
    * If the address is missing or invalid (no page can be named that)
    * then the display name is written without being a hyper link.
    * If the address is to an external page, then a normal hyperlink is made.
    * If the address is the name of a wiki page, then a hyperlink to that
    * page is made.  If the address is a valid name, but no page exists
    * with that name, then a link to the "CreatePage" function is created.
    *
    * The name part of the link
    */
    private void outputLink(Writer ar, String linkURL) throws Exception {
        boolean isImage = linkURL.startsWith("IMG:");

        int barPos = linkURL.indexOf("|");
        String linkName = linkURL.trim();
        String linkAddr = linkName;

        if (barPos >= 0) {
            linkName = linkURL.substring(0, barPos).trim();
            linkAddr = linkURL.substring(barPos + 1).trim();
        }

        // We treat any address that has forward slashes in it as an external
        // address which is included literally into the href.
        boolean pageExists = true;
        String specialGraphic = null;
        String target = null;
        String titleValue = linkURL;

        // if the link is missing, then just write the name out
        // might also include an indicator of the problem ....
        if (linkAddr.length() == 0) {
            HTMLWriter.writeHtml(ar, linkName);
            return;
        }
        
        linkAddr = linkConverter + URLEncoder.encode(linkAddr, "UTF-8");

        
        if (isImage) {
            linkName = linkName.substring(4);
            if (pageExists) {
                ar.write("<a href=\"");
                HTMLWriter.writeHtml(ar, linkAddr);
                ar.write("\" title=\"");
                HTMLWriter.writeHtml(ar, titleValue);
                ar.write("\">");
                ar.write("<img src=\"");
                HTMLWriter.writeHtml(ar, linkName);
                ar.write("\"/>");
                ar.write("</a>");
            } else {
                ar.write("<img src=\"");
                HTMLWriter.writeHtml(ar, linkName);
                ar.write("\"/>");
            }
        }
        else { // not an image
            if (pageExists) {
                ar.write("<a href=\"");
                HTMLWriter.writeHtml(ar, linkAddr);
                ar.write("\" title=\"");
                HTMLWriter.writeHtml(ar, titleValue);
                if (target != null) {
                    ar.write("\" target=\"");
                    HTMLWriter.writeHtml(ar, target);
                }
                ar.write("\">");
                scanForStyle(linkName, 0);
                ar.write("</a>");
            } else {
                ar.write("<a href=\"");
                HTMLWriter.writeHtml(ar, linkAddr);
                ar.write("\" title=\"");
                HTMLWriter.writeHtml(ar, titleValue);
                ar.write("\">");
                scanForStyle(linkName, 0);
                // the icon indicates condition of page
                ar.write("<img src=\"");
                ar.write(retPath);
                ar.write(specialGraphic);
                ar.write("\"/>");
                ar.write("</a>");
            }
        }

    }


    protected void fomatFontStyle(String line) throws Exception{
        boolean scan = false;
        if(line.startsWith("%%(")){
            int indx = line.indexOf(')');
            String attr = line.substring(3,indx);
            attr = attr.replaceAll(":", "=");
            ar.write("<FONT " + attr + ">");
            line = line.substring(indx + 1);
            scan = true;
        }
        if(line.endsWith("%%")){
            line = line.substring(0, line.lastIndexOf("%%"));
            scanForStyle(line, 0);
            scan = false;
            ar.write("</FONT>");
        }
        if(scan){
            scanForStyle(line, 0);
        }
    }
    
    
    /**
     * Many blocks of text from the web consists entirely of links, and those are 
     * related to button bas, menus, etc.  In order to distinguish these blocks, which can be 
     * quite large, this will return the amount of text that is NOT linked, as that usually
     * indicates the body of readable text from a web page.
     * @param sample
     * @return
     */
    public static int amtNonLinkedText(String sample) {
        int total = 0;
        
        int lineStart = 0;
        while (lineStart < sample.length()) {
            // skip any spaces that might exist
            lineStart = span(sample, lineStart, ' ');
            
            // find the end of the line
            int lineEnd = findNext(sample, lineStart, sample.length(), '\n');
            int textStart = skipFormatting(sample, lineStart);
            total = total + unbracedTextCount(sample, textStart, lineEnd);
            
            // find beginning of next line after any number of newlines
            lineStart = span(sample, lineEnd, '\n');
        }
        
        return total;
    }

    private static int findNext(String sample, int start, int end, char ch) {
        int pos = sample.indexOf(ch, start);
        if (pos >= end) {
            return end;
        }
        if (pos >= 0) {
            return pos;
        }
        return end;
    }
    
    private static int skipFormatting(String sample, int start) {
        if (start >= sample.length()) {
            return start;
        }
        char firstChar = sample.charAt(start);
        if (firstChar == '*') {
            start = span(sample, start, '*');
            return span(sample, start, ' ');
        }
        if (firstChar == '!') {
            start = span(sample, start, '!');
            return span(sample, start, ' ');
        }
        if (firstChar == ':') {
            return start + 1;
        }
        return start;
    }
    
    private static int span(String sample, int start, char ch) {
        while (start < sample.length() && sample.charAt(start)==ch) {
            start++;
        }
        return start;
    }
    
    private static int unbracedTextCount(String sample, int start, int end) {
        int amt = 0;
        int pos = start;
        
        while (pos < end) {
            int bracePos = findNext(sample, pos, end, '[');
            // include the amount before the brace
            amt = amt + bracePos - pos;
            pos = bracePos;
            pos = findNext(sample, pos, end, ']')+1;
        }
        return amt;
    }
}
