package com.purplehillsbooks.unbuilder;

import java.io.File;
import java.io.FileInputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
* Manages metadata for a file
* Non conflicting change from GitHub
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class FileInfo
{
    public String folder;
    public File path;
    long size = -1;
    long checksum = -1;

    public FileInfo(File _path) {
        path = _path;
        folder = _path.getParentFile().toString();
    }

    public String getName() {
        return path.getName();
    }

    public long getSize() {
        if (size<0) {
            size = path.length();
        }
        return size;
    }

    /**
    * getCheckSum
    */
    public long getChecksum() {
        if (checksum<0) {
            checksum = calculateChecksum(path);
        }
        return checksum;
    }

    private static long calculateChecksum(File path) {
        long value = 0;

        try {
            FileInputStream fis = new FileInputStream(path);
            int ch = fis.read();
            int count = 2000;
            while (ch>=0) {
                //white space, carriage returns, and line feeds are ignored
                if (ch>' ' && ch<'~') {
                    value += ch;
                    if (count-- <0) {
                        break;
                    }
                }
                ch = fis.read();
            }
            fis.close();
            return value;
        }
        catch (Exception e) {
            e.printStackTrace(System.out);
            return -value;
        }
    }


    public static List<FileInfo> findAllFiles(File path) {
        List<FileInfo> coll = new ArrayList<FileInfo>();
        recurseAllFolders(path, coll);
        return coll;
    }

    private static void recurseAllFolders(File path, List<FileInfo> coll) {
        for (File child : path.listFiles()) {
            if (child.isDirectory()) {
                recurseAllFolders(child, coll);
            }
            else {
                FileInfo fi = new FileInfo(child);
                coll.add(fi);
            }
        }
    }

    public static void sortByPath(List<FileInfo> coll) {
        Collections.sort(coll, new SortByPath());
    }
    public static void sortByName(List<FileInfo> coll) {
        Collections.sort(coll, new SortByName());
    }

/**
* Sortby Name
*/
    private static class SortByName implements Comparator<FileInfo> {
        public SortByName() {}

        // Used for sorting in ascending order of name
        public int compare(FileInfo a, FileInfo b) {
            return a.getName().compareTo(b.getName());
        }
    }
    private static class SortByPath implements Comparator<FileInfo> {
        public SortByPath() {}

        // Used for sorting in ascending order of path
        public int compare(FileInfo a, FileInfo b) {
            return a.path.compareTo(b.path);
        }
    }
}
