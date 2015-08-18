package org.workcast.wu;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.io.File;
import org.workcast.mendocino.Mel;

/**
* Represents a set of comments (notes) on a particular
* Java class, across multiple versions.
*
* Author: Keith Swenson
* Copyright: Keith Swenson, all rights reserved
* License: This code is made available under the GNU Lesser GPL license.
*/
public class JavaDocNotes
{
    Hashtable<String,Integer> commentCount = new Hashtable<String,Integer>();
    File noteFile;
    Mel me;

    /**
    * Pass in the File object to the file to read
    */
    public JavaDocNotes(File _noteFile)
        throws Exception
    {
        noteFile = _noteFile;
        if (noteFile.exists())
        {
            me = Mel.readFile(noteFile, Mel.class);
            for (Mel note : me.getChildren("note"))
            {
                String member = note.getScalar("member");
                Integer count = commentCount.get(member);
                if (count==null)
                {
                    commentCount.put(member, new Integer(1));
                }
                else
                {
                    commentCount.put(member, new Integer(count.intValue()+1));
                }
            }
        }
    }


    public void setNewNote(String member, String version, String comment)
        throws Exception
    {
        if (me==null)
        {
            //if the file was not read earlier, then it did not exist,
            //create it now
            noteFile.getParentFile().mkdirs();
            me = Mel.createEmpty("notefile", Mel.class);
        }
        Mel note = me.addChild("note", Mel.class);
        note.setScalar("member", member);
        note.setScalar("ver", version);
        note.setScalar("comment", comment);
        me.reformatXML();
        me.writeToFile(noteFile);
    }

    public int noteCount(String member)
    {
        Integer count = commentCount.get(member);
        if (count==null)
        {
            return 0;
        }
        else
        {
            return count.intValue();
        }
    }


    public List<Mel> getNotes(String member)
        throws Exception
    {
        Integer count = commentCount.get(member);
        ArrayList<Mel> list = new ArrayList<Mel>();
        if (count!=null)
        {
            for (Mel note : me.getChildren("note"))
            {
                String noteMember = note.getScalar("member");
                if (member.equals(noteMember))
                {
                    list.add(note);
                }
            }
        }
        return list;
    }

}
