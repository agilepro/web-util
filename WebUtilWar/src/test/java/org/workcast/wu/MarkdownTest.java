package org.workcast.wu;


import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.StringReader;
import java.io.Writer;

import org.junit.Assert;
import org.junit.Test;

import com.purplehillsbooks.streams.StreamHelper;

public class MarkdownTest {
    
    File resourceFolder = new File("src/test/resources");
    File tempFolder = new File("target/testTemp");
    
    @Test public void basicTest() throws Exception {
        
        System.out.println("Running Markdown Tester: "+tempFolder.getAbsolutePath());
        Assert.assertTrue(resourceFolder.exists()) ;
        if (!tempFolder.exists()) {
            tempFolder.mkdirs();
        }
        
        for (File child : resourceFolder.listFiles()) {
            String childName = child.getName();
            if (childName.endsWith(".html")) {
                String baseName = childName.substring(0, childName.length()-5);
                File outFile = new File(tempFolder, baseName+".md");
                File htmlFile = new File(tempFolder, baseName+".html");
                Reader reader = new  InputStreamReader(new FileInputStream(child), "UTF-8");
                HtmlToWikiConverter2 hwc = new HtmlToWikiConverter2();
                hwc.htmlStreamToWiki(reader, "https://noplace.com/1/2/3/4/5/foo.html");
                String markdown = hwc.resultString();
                StringReader forOutput = new StringReader(markdown);
                StreamHelper.copyReaderToUTF8File(forOutput, outFile);
                
                Writer htmlWriter = new OutputStreamWriter(new FileOutputStream(htmlFile), "UTF-8");
                WikiConverter.writeWikiAsHtml(htmlWriter, markdown, "https://noplace.com/converter?page=");
            }
        }
    }
    
    @Test public void textParsingTest() throws Exception {
        
        System.out.println("Running textParsingTest: ");
        
        String t1 =  "[foo|http://bar.com/baz]";
        Assert.assertEquals(0, WikiConverter.amtNonLinkedText(t1));
        
        
    }
}
