package org.workcast.wu;

import java.net.URL;

import com.purplehillsbooks.json.JSONArray;
import com.purplehillsbooks.json.JSONObject;
import com.purplehillsbooks.web.JSONHandler;
import com.purplehillsbooks.web.SessionManager;
import com.purplehillsbooks.web.WebClient;
import com.purplehillsbooks.web.WebRequest;

public class AuthHandler extends JSONHandler {

    JSONObject postBody;

    private static String trustedProviderUrl = "http://bobcat:8080/eid/";

    public AuthHandler(WebRequest _wr, SessionManager score) throws Exception {
        super(_wr,score);
        JSONObject config = smgr.getConfigSettings();
        trustedProviderUrl = config.getString("trustedProviderUrl");
    }


    /**
     * request url:   {baseUrl}/auth/{this}/...
     *
     * In the {this} position you can either have
     *
     * {baseUrl}/auth/getChallenge
     *
     * This receives a request for a challenge value, generates a challenge
     * value, associates the challenge with the current session, and returns
     * the challenge in a JSON file.
     *
     * {baseUrl}/auth/verifyToken
     *
     * This receives a JSON with the challenge, the token from the auth
     * provider.  This will make a call to the auth provider, and if
     * it gets an acceptable response (verified) then it records the
     * user information in the session, and returns a value saying
     * that the user is logged in.
     *
     *
     */
    public JSONObject handleRequest() throws Exception {
        if (wr.pathFinished()) {
            //this should not be possible ... there should always be 'api'
            //this is just a consistency check
            throw new Exception("Program Logic Error: unexpected internal path is missing the 'auth' entry from path");
        }
        String zeroToken = wr.consumePathToken();
        if (!"auth".equals(zeroToken)) {
            //this should not be possible ... there should always be 'api'
            //this is just a consistency check
            throw new Exception("Program Logic Error: the first path element is expected to be 'auth' but was instead '"+zeroToken+"'");
        }

        if (wr.pathFinished()) {
            return getUserStatus();
        }

        String firstToken = wr.consumePathToken();
        if ("logout".equals(firstToken)) {
            wr.setAuthUserId(null);
            return getUserStatus();
        }
        if ("query".equals(firstToken)) {
            return getUserStatus();
        }

        if (wr.isPost()) {
            postBody = wr.getPostedObject();
        }

        if ("getChallenge".equals(firstToken)) {
            JSONObject jo = getUserStatus();
            String challenge = generateChallenge();
            wr.setSessionProperty("challenge", challenge);
            jo.put("challenge",  challenge);
            return jo;
        }
        if ("verifyToken".equals(firstToken)) {
            return verifyToken();
        }
        throw new Exception("BPM AUTH is unable to understand the first path element: "+firstToken);
    }

    private JSONObject getUserStatus() throws Exception {
        JSONObject userStatus = new JSONObject();
        JSONArray providers = new JSONArray();
        providers.put(trustedProviderUrl);
        userStatus.put("providers", providers);
        String userId = wr.getAuthUserId();
        if (userId==null) {
            userStatus.put("msg", "User is not logged in");
            return userStatus;
        }
        userStatus.put("userId",  userId);
        userStatus.put("msg", "User logged in");

        return userStatus;
    }

    private static long lastKey = System.currentTimeMillis();
    private static char[] thirtySix = new char[] {'0','1','2','3','4','5','6','7','8','9',
        'a','b','c','d','e','f','g','h','i','j','k','l','m',
        'n','o','p','q','r','s','t','u','v','w','x','y','z'};
    /**
    * Generates a value based on the current time, and the time of
    * the previous id generation, but checking also
    * that it has not given out this value before.  If a key has
    * already been given out for the current time, it increments
    * by one.  This method works as long as on the average you
    * get less than one ID per millisecond.
    */
    private synchronized static String generateChallenge() {
        long ctime = System.currentTimeMillis();
        if (ctime <= lastKey) {
            ctime = lastKey+1;
        }
        long lastctime = lastKey;
        lastKey = ctime;

        //now convert timestamp into cryptic alpha string
        //start with the server defined prefix based on mac address
        StringBuffer res = new StringBuffer(8);
        while (ctime>0) {
            res.append(thirtySix[(int)(ctime % 36)]);
            res.append(thirtySix[(int)(lastctime % 10)]);  //always a numeral
            ctime = ctime / 36;
            lastctime = lastctime / 10;
        }
        return res.toString();
    }


    private JSONObject verifyToken() throws Exception {

        String chg1 = wr.getSessionProperty("challenge");
        String chg2 = postBody.getString("challenge");
        String token = postBody.getString("token");

        if (token==null || token.length()==0) {
            throw new Exception("Need to have a 'token' member of the passed JSON in order to verify it.");
        }
        if (chg2==null || chg2.length()==0) {
            throw new Exception("Need to have a 'challenge' value in the post body.");
        }
        if (chg1==null) {
            throw new Exception("For some reason there is no prior stored challenge value when asked to verify a challenge token.  Authentication transaction aborted.  Please start over.");
        }

        if (!chg1.equals(chg2)) {
            wr.setSessionProperty("challenge", null);
            throw new Exception("Got a request to verify a token and challenge that is not that which was given out.  Authentication transaction aborted.  Please start over.");
        }

        if (trustedProviderUrl==null || trustedProviderUrl.length()==0) {
            throw new Exception("the AuthHandler has not been initialized with the address of the provider");
        }

        //Now, actually call the provider and see if this is true
        String destUrl = trustedProviderUrl + "?openid.mode=apiVerify";
        WebClient client = new WebClient();
        JSONObject response = client.postToRemote(new URL(destUrl), postBody);
        boolean valid = response.getBoolean("verified");

        if (valid) {
            String userId = response.getString("userId");
            wr.setAuthUserId(userId);
            wr.setSessionProperty("userName", response.optString("userName", userId));
            wr.setSessionProperty("email", response.optString("email", userId));
        }
        else {
            //after a failed login, don't leave any previous login around....
            wr.setAuthUserId(null);
            wr.setSessionProperty("userName",null);
            wr.setSessionProperty("email",null);
        }
        return response;
    }

}
