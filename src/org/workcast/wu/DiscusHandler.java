package org.workcast.wu;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import com.purplehillsbooks.json.JSONArray;
import com.purplehillsbooks.json.JSONException;
import com.purplehillsbooks.json.JSONObject;
import com.purplehillsbooks.web.JSONHandler;
import com.purplehillsbooks.web.SessionManager;
import com.purplehillsbooks.web.WebRequest;

public class DiscusHandler extends JSONHandler {

    private File dataFolder;
    private String article;

    public DiscusHandler(WebRequest wr, SessionManager smgr) throws Exception {
        super(wr, smgr);
        dataFolder = new File("d:/cogData/discus/");
    }

    @Override
    public JSONObject handleRequest() throws Exception {
        if (!dataFolder.exists()) {
            throw new Exception("Can't find the main data folder: "+dataFolder.getAbsolutePath());
        }
        if (wr.pathFinished()) {
            throw new Exception("This basically never happens.");
        }
        String token = wr.consumePathToken();
        if (!"ds".equals(token)) {
            throw new Exception("STRANGE, for some reason the first token is not 'ds' as it should be");
        }
        if (wr.pathFinished()) {
            //this is the ping request
            JSONObject ret = new JSONObject();
            ret.put("hello", "world");
            return ret;
        }
        token = wr.consumePathToken();
        if ("List".equals(token)) {
            return getDiscussionListing();
        }
        else if (token.startsWith("d=")) {
            return handleDiscussion(token.substring(2));
        }
        throw new JSONException("Don't understand the path element ({0})", token);
    }

    /*
     * handles   ds/List
     */
    private JSONObject getDiscussionListing() throws Exception  {
        JSONObject discussionList = new JSONObject();

        for( File child : dataFolder.listFiles()) {
            String childName = child.getName();
            if (childName.endsWith(".disc")) {
                String topic = childName.substring(0, childName.length()-5);
                JSONObject discussion = discussionList.requireJSONObject(topic);
                discussion.requireJSONArray("comments");
            }
            else if (childName.endsWith(".comm")) {
                String combo = childName.substring(0, childName.length()-5);
                int dotPos = combo.lastIndexOf(".");
                String topic = combo.substring(0, dotPos);
                String user = combo.substring(dotPos+1);
                JSONObject discussion = discussionList.requireJSONObject(topic);
                JSONArray comments = discussion.requireJSONArray("comments");
                comments.put(user);
            }
        }
        return discussionList;
    }

    /*
     * handles
     *    ds/d={art}/Article
     *    ds/d={art}/AllComments
     */
    private JSONObject handleDiscussion(String art) throws Exception {
        article = art;
        File discussionFile = new File(dataFolder, art+".disc");
        if (!discussionFile.exists()) {
            throw new JSONException("Can't find the discussion file: {0}", discussionFile.getAbsolutePath());
        }
        if (wr.pathFinished()) {
            throw new Exception("Nothing returned at this level: need another path element");
        }
        String token = wr.consumePathToken();
        try {
            if ("Article".equals(token)) {
                return getOneDiscussionDocument();
            }
            else if ("AllComments".equals(token)) {
                return getAllComments();
            }
        }
        catch (Exception e) {
            throw new JSONException("Failure handling path element ({0})", e, token);
        }
        throw new JSONException("Don't understand the path element ({0})", token);
    }

    private JSONObject getOneDiscussionDocument() throws Exception {
        File discussionFile = new File(dataFolder, article+".disc");
        JSONObject discussion = JSONObject.readFromFile(discussionFile);
        return discussion;
    }

    private JSONObject getAllComments() throws Exception {
        List<String> commenters = new ArrayList<String>();
        for( File child : dataFolder.listFiles()) {
            String childName = child.getName();
            if (!childName.startsWith(article)) {
                continue;
            }
            if (childName.endsWith(".comm")) {
                String combo = childName.substring(0, childName.length()-5);
                int dotPos = combo.lastIndexOf(".");
                String user = combo.substring(dotPos+1);
                commenters.add(user);
            }
        }

        JSONObject allComments = new JSONObject();
        for (String user : commenters) {
            File commentFile = new File(dataFolder, article + "." + user + ".comm");
            if (commentFile.exists()) {
                JSONObject ucomm = JSONObject.readFromFile(commentFile);
                allComments.put(user, ucomm);
            }
        }
        return allComments;
    }


}
