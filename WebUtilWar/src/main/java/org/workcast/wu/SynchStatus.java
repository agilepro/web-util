package org.workcast.wu;

import java.io.File;
import java.io.OutputStream;
import java.io.FileOutputStream;
import java.util.Vector;
import com.purplehillsbooks.xml.Mel;

/**
* Holds the data and logic for synchronizing a local file with a WebDAV remote file
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class SynchStatus
{
    public File containingFolder;
    public Mel status;


    //hard-coded for now
    static public File rootFolder = new File("c:\\projects\\");

    public SynchStatus(String projectName)
        throws Exception
    {
        File folder = new File(rootFolder, projectName);
        File statFile = new File(folder, "synch_status.xml");
        if (!folder.exists())
        {
            throw new Exception("The folder '"+folder+"' does not exist.");
        }
        if (!statFile.exists())
        {
            throw new Exception("The folder '"+folder+"' does not have a synch_status.xml file.  It must not be a synchronized project.");
        }
        status = Mel.readFile(statFile, Mel.class);
    }

    public static Vector<String> scanProjects()
        throws Exception
    {
        if (!rootFolder.exists())
        {
            throw new Exception("The c:\\projects\\ folder must exist on your machine in order to use this page.");
        }
        if (!rootFolder.isDirectory())
        {
            throw new Exception("The c:\\projects\\ file exists, but it must be a folder on your machine in order to use this page.");
        }
        Vector<String> res = new Vector<String>();
        for (File child : rootFolder.listFiles())
        {
            if (!child.isDirectory())
            {
                continue;
            }
            res.add(child.getName());
        }
        return res;
    }


    public static SynchStatus createNew(String projectName, String url)
        throws Exception
    {
        Mel conFile = Mel.createEmpty("synchstatus", Mel.class);
        conFile.setAttribute("url", url);

        File folder = new File(rootFolder, projectName);
        if (folder.exists())
        {
            throw new Exception("Project with the name '"+folder+"' already exists!");
        }
        File newConfig = new File(folder, "synch_status.xml");
        if (newConfig.exists())
        {
            throw new Exception("Project with the name '"+folder+"' already has a configuration file!");
        }
        folder.mkdirs();
        OutputStream os = new FileOutputStream(newConfig);
        conFile.writeToOutputStream(os);
        os.flush();
        os.close();
        return new SynchStatus(projectName);
    }


    public void Save()
        throws Exception
    {
        File newConfig = new File(containingFolder, "synch_status.xml");
        OutputStream os = new FileOutputStream(newConfig);
        status.writeToOutputStream(os);
        os.flush();
        os.close();
    }


    public String getURL()
    {
        return status.getAttribute("url");
    }


}
