package org.workcast.wu;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Hashtable;
import java.util.List;
import java.io.File;

/**
* Represents a single set of java doc documentation.
* The JavaDocServlet will handle any number of 'versions' of
* a set of documentation.  As a matter of fact, each version
* can be a completely different set of documentation, or it
* can literally be different releases of the same documentation.
*
* The only thing that matters is that the java doc itself is placed
* in a folder that is named for the version.  The name of that folder
* is used as the name of the version.
*
* All data is held in a root "jd" folder.  Inside that a folder
* for each version.  Inside those, the document tree for the
* java doc.
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class JavaDocSet
{
    private File rootFolder;
    public String name;

    private static File noteFolder;
    private static Hashtable<String,JavaDocSet> allVersions =
            new Hashtable<String,JavaDocSet>();


    public static JavaDocSet getSet(String setName)
    {
        String lcname = setName.toLowerCase();
        return allVersions.get(lcname);
    }

    public static List<JavaDocSet> listSets()
    {
        ArrayList<JavaDocSet> list = new ArrayList<JavaDocSet>();
        list.addAll(allVersions.values());
        Collections.sort(list, new JDVComparator());
        return list;
    }


    /**
    * Given the path within the doc set to a document,
    * this tells whether the document exists.
    */
    public boolean docExists(String docPath)
    {
        File docFile = new File(rootFolder, docPath);
        return docFile.exists();
    }
    public File getDocFile(String docPath)
    {
        return new File(rootFolder, docPath);
    }

    public File getNoteFile(String docPath)
    {
        File noteFile = new File(noteFolder, docPath+".note");
        return noteFile;
    }



    private JavaDocSet(File _rootFolder)
    {
        rootFolder = _rootFolder;
        name = _rootFolder.getName();
    }

    static void initializeAllSets(File root)
    {
        File[] children = root.listFiles();
        if (children == null)
        {
            //list files returns a null if the file itself (the folder) does not exist
            //so just return in this case.
            return;
        }
        for (File child : children)
        {
            if (!child.isDirectory())
            {
                continue;
            }
            String lcname = child.getName().toLowerCase();
            if ("(note)".equals(lcname))
            {
                noteFolder = child;
                continue;
            }

            JavaDocSet jds = new JavaDocSet(child);
            allVersions.put(lcname, jds);
        }
    }

    static class JDVComparator implements Comparator<JavaDocSet>
    {
        public JDVComparator() {}

        public int compare(JavaDocSet o1, JavaDocSet o2)
        {
            String name1 = o1.name;
            String name2 = o2.name;
            return name1.compareToIgnoreCase(name2);
        }
    }
}
