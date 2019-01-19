<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.List"
%><%@page import="java.util.Properties"
%><%@page import="org.openid4java.consumer.ConsumerManager"
%><%@page import="org.openid4java.consumer.InMemoryConsumerAssociationStore"
%><%@page import="org.openid4java.consumer.InMemoryNonceVerifier"
%><%@page import="org.openid4java.consumer.VerificationResult"
%><%@page import="org.openid4java.discovery.DiscoveryInformation"
%><%@page import="org.openid4java.message.AuthRequest"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.WebRequest"
%><%@page import="org.workcast.wu.OpenIDHelper"
%><%

    //clear out whatever error might have been recorded before
    session.setAttribute("error-msg", null);

    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    String go = wr.reqParam("go");
    String err = go;
    String act = wr.reqParam("act");

    if (act.equals("Log Out"))
    {
        wr.setLoggedIn(null);
        response.sendRedirect(go);
        session.setAttribute("login_trace", null);
        session.setAttribute("error-msg", null);
        return;
    }
    String uopenid = wr.reqParam("openid").trim();    //id user trying to log in as

    try
    {
        if (!act.equals("Log In"))
        {
            throw new Exception("no idea what action '"+act+"' means");
        }

        Properties traceProps = new Properties();
        session.setAttribute("login_trace", traceProps);
        traceProps.setProperty("original id", uopenid);


        // ************ READ THIS ************************

        // Login is complicated and must be done exactly right, and there are many factors

        // 1. this JSP must be located at the root of the application so that when cookies
        //    are set, they are set for the entire application.
        //
        // 2. This page is the first step in the OpenID protocol dance.  This page redirects
        //    to the OpenId provider, and then that will reirect to second step page.
        //
        // 3. Second step page = FujitsuProcessLeaves.jsp
        //    Name of second step page is visible to user, and must be name of application.
        //
        // 4. Parameters to this page are as follows:
        //    go = the page to return to when successful
        //    error = the page to redirect to when something fails
        //    openid = the id that user have provided for authentication
        //
        // 5. Values passed to the second step are passed in the session object, which
        //    unfortunately means that there is a small danger clash when a single user
        //    on  single machine attempts to log in with two browser windows at the same time.
        //    This is unlikely to be a serious problem.
        //
        // 6. Remember that the user may or may not be logged in.  For normal login they are
        //    not logged in, but there is also the case that they are adding an OpenId
        //    to an existing account, and in that case they are logged in to a user profile,
        //    and then separately are logging into a new OpenID.  Don't assume logged out.
        //
        // 7. When there is a failure, the error message will go in session attribute "error-msg"
        //    Receiving page must read this, and clear it.



        //open id login
        ConsumerManager manager = OpenIDHelper.newConsumerManager();

        String returnToUrl = "";
        String reqURL = request.getRequestURL().toString();
        returnToUrl = reqURL.substring(0,reqURL.lastIndexOf("/")+1)+"SwensonWebUtilities.jsp";
        traceProps.setProperty("return to URL", returnToUrl);

        // I don't like this hack, but I don't see any other way.  We need to redirect the user
        // back to the page they were on when they were logging in.  If we pass this as a parameter
        // in the returnToUrl, then they have to log into each page, since the OpenID site
        // asks for a verification for each return-to URL.
        // Solution here is store in the "session" the page that you were logging in to, and
        // retrieve that from the session after authentication.  This is a problem only if
        // one person logging in to two pages at once -- seems relatively unlikely and safe.
        session.setAttribute("login-page", go);
        session.setAttribute("login-err",  go);

        // perform discovery on the user-supplied identifier
        AuthRequest authReq = null;
        DiscoveryInformation discovered = null;
        List discoveries = manager.discover(uopenid);
        if (discoveries==null) {
            throw new Exception("Client Manager discover returned a null list of discoveries.");
        }
        traceProps.setProperty("Discoveries", discoveries.toString());

        //HttpRequestOptions hro = HttpRequestOptions.getDefaultOptionsForDiscovery();
        //traceProps.setProperty("max body size", Integer.toString(hro.getMaxBodySize()));

        // attempt to associate with an OpenID provider
        // and retrieve one service endpoint for authentication
        discovered = manager.associate(discoveries);

        if (discovered==null) {
            throw new Exception("Client Manager Associate returned a null Discovery Information.");
        }

        //traceProps.setProperty("OPEndpoint", discovered.getOPEndpoint().toString());
        if (discovered.getDelegateIdentifier()!=null) {
            traceProps.setProperty("DelegateIdentifier", discovered.getDelegateIdentifier());
        }
        if (discovered.getClaimedIdentifier()!=null) {
            traceProps.setProperty("ClaimedIdentifier", discovered.getClaimedIdentifier().toString());
        }
        traceProps.setProperty("Discovery Version", discovered.getVersion());
        traceProps.setProperty("Discovery", discovered.toString());

        // store the discovery information in the user's session
        session.setAttribute("openid-disco", discovered);

        // obtain a AuthRequest message to be sent to the OpenID provider
        authReq = manager.authenticate(discovered, returnToUrl);

        // Option 1: GET HTTP-redirect to the OpenID Provider endpoint
        // The only method supported in OpenID 1.x
        // redirect-URL usually limited ~2048 bytes
        response.sendRedirect(authReq.getDestinationUrl(true));
    }
    catch (Exception e)
    {
        Exception fatalError = new Exception("Unable to verify the supplied OpenID ("+uopenid
        +").  This could be for a number of reasons.  It might be that "
        +"network connectivity to the open id provider is down, the server is off line "
        +"temporarily, or the OpenId was not entered correctly.\n\nAdditional detail: ", e);

        //error message from one page to another page is passed as a session attribute
        //so that it does not become a permanent part of the URL that the user can see
        session.setAttribute("error-msg", fatalError);
        response.sendRedirect(err);
    }
%>
