package org.workcast.wu;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import com.purplehillsbooks.json.JSONArray;
import com.purplehillsbooks.json.JSONException;
import com.purplehillsbooks.json.JSONObject;
import com.purplehillsbooks.json.JSONSchema;
import com.purplehillsbooks.web.JSONHandler;
import com.purplehillsbooks.web.SessionManager;
import com.purplehillsbooks.web.WebRequest;

public class DiscusHandler extends JSONHandler {

    private File dataFolder;
    private String article;

    public DiscusHandler(WebRequest wr, SessionManager smgr) throws Exception {
        super(wr, smgr);
        dataFolder = new File(smgr.getAppDataFolder(), "discus");
    }

    /**
     * This is the root level.   All paths start with /ds/  here are the options
     *
     * /ds/          -- a hello world ping response
     * /ds/List      -- list all discussions
     * /ds/Create    -- create a new discussion article (POST)
     * /ds/d={art}/  -- go to article specific commands
     *
     *
     */
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
        else if ("Create".equals(token)) {
            return createNewTopic();
        }
        else if (token.startsWith("d=")) {
            return handleDiscussion(token.substring(2));
        }
        else  if ("GenerateSchema".equals(token)) {
            return handleSchemaGen();
        }
        else  if ("validateJSON".equals(token)) {
            return validateJSON();
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
                int dotPos = combo.indexOf(".");
                String topic = combo.substring(0, dotPos);
                String user = combo.substring(dotPos+1);
                JSONObject discussion = discussionList.requireJSONObject(topic);
                JSONArray comments = discussion.requireJSONArray("comments");
                comments.put(user);
            }
        }
        return discussionList;
    }

    private JSONObject createNewTopic() throws Exception {
        try {
            if (!wr.isPost()) {
                throw new Exception("The Create command requires a JSON object posted to it.");
            }
            JSONObject newTopic = wr.getPostedObject();
            if (!newTopic.has("key")) {
                throw new Exception("The Create request needs a 'key' value fo rthe new article.");
            }
            String key = newTopic.getString("key");
            assertKeyIsUnique(key);

            JSONObject newArticle = new JSONObject();
            newArticle.put("fullName",    newTopic.optString("fullName"));
            newArticle.put("description", newTopic.optString("description"));
            newArticle.put("content",     newTopic.optJSONObject("fullName"));
            newTopic.requireJSONObject("content");

            String targetName = key + ".disc";
            File targetFile = new File(dataFolder, targetName);

            if (targetFile.exists()) {
                throw new JSONException("An article with the key '{0}' is already in use.", key);
            }
            newArticle.writeToFile(targetFile);
            return newArticle;
        }
        catch (Exception e) {
            throw new JSONException("Unable to create new discussion article");
        }
    }

    private void assertKeyIsUnique(String key) throws Exception {
        String targetName = key + ".comm";
        for( File child : dataFolder.listFiles()) {
            String childName = child.getName();
            if (childName.equals(targetName)) {
                throw new JSONException("The key '{0}' is already in use.", key);
            }
        }
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
            else if ("MakeComment".equals(token)) {
                return makeUserComment();
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
        if (wr.isPost()) {
            JSONObject updateObj = wr.getPostedObject();
            if (updateObj.has("fullName")) {
                discussion.put("fullName", updateObj.getString("fullName"));
            }
            if (updateObj.has("description")) {
                discussion.put("description", updateObj.getString("description"));
            }
            if (updateObj.has("content")) {
                discussion.put("content", updateObj.getJSONObject("content"));
            }
            discussion.writeToFile(discussionFile);
        }
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
                int dotPos = combo.indexOf(".");
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

    private JSONObject makeUserComment() throws Exception {
        if (!wr.isPost()) {
            throw new Exception("The MakeComment command requires a posted object");
        }
        JSONObject newComment = wr.getPostedObject();
        String user = newComment.getString("user");
        String rowNo = newComment.getString("row");
        String text = newComment.getString("text");

        File commentFile = new File(dataFolder, article + "." + user + ".comm");
        JSONObject comments;
        if (commentFile.exists()) {
            comments = JSONObject.readFromFile(commentFile);
        }
        else {
            comments = new JSONObject();
        }
        JSONObject content = comments.requireJSONObject("content");
        JSONObject newEntry = new JSONObject();
        newEntry.put("txt", text);
        content.put(rowNo, newEntry);
        comments.writeToFile(commentFile);
        return comments;
    }
    
    private JSONObject  handleSchemaGen() throws Exception {
        if (!wr.isPost()) {
            throw new Exception("schema generator needs a JSON object passed to it");
        }
        JSONObject source = wr.getPostedObject().getJSONObject("src");
        JSONObject schema = JSONSchema.generateSchema(source);
        return schema;
    }

    private JSONObject  validateJSON() throws Exception {
        if (!wr.isPost()) {
            throw new Exception("schema generator needs a JSON object passed to it");
        }
        JSONObject src = wr.getPostedObject().getJSONObject("src");
        JSONObject schema = wr.getPostedObject().getJSONObject("schema");
        JSONSchema converter = new JSONSchema();
        boolean isOK = converter.checkSchema(src, schema);
        JSONObject result = new JSONObject();
        result.put("success", isOK);
        if (!isOK) {
            JSONArray errors = new JSONArray();
            for (String err : converter.getErrorList()) {
                errors.put(err);
            }
            result.put("errors", errors);
        }
        return schema;
    }
    
}
