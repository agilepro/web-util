<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.WebRequest"
%><%@page import="org.workcast.wu.OpenIDHelper"

%><%@ page import="org.openid4java.consumer.ConsumerManager"
%><%@ page import="org.openid4java.consumer.InMemoryConsumerAssociationStore"
%><%@ page import="org.openid4java.consumer.VerificationResult"
%><%@ page import="org.openid4java.discovery.DiscoveryInformation"
%><%@ page import="org.openid4java.discovery.Identifier"
%><%@ page import="org.openid4java.message.ParameterList"
%><%@ page import="org.openid4java.message.AuthSuccess"
%>


<%
    /*********************************************
    * The purpose of this page is that this is the return address of
    * an OpenID interaction.  People as essentially logging into
    * a product, and this page is the name of the product, so they
    * see that this is what they are logging into.
    *********************************************/

    // when requesting login, we stored the page that we were looking at when
    // entering the login id, and now we return to it.
    String go = (String) session.getAttribute("login-page");
    if (go==null)
    {
        throw new Exception("Program Logic Error: The session needs to have an attribute 'login-page'.  "
             +"Something was wrong with the login protocol.");
    }
    String err = (String) session.getAttribute("login-err");
    if (err==null)
    {
        throw new Exception("Program Logic Error: The session needs to have an attribute 'login-err'.  "
             +"Something was wrong with the login protocol.");
    }

    //these should be fetched ONLY ONCE, so get rid of them now.
    session.setAttribute("login-page", null);
    session.setAttribute("login-err", null);


    ConsumerManager manager = OpenIDHelper.newConsumerManager();
    // --- processing the authentication response

    // extract the parameters from the authentication response
    // (which comes in as a HTTP request from the OpenID provider)
    ParameterList responselist = new ParameterList(request.getParameterMap());

    // retrieve the previously stored discovery information
    DiscoveryInformation discovered = (DiscoveryInformation) session.getAttribute("openid-disco");

    // extract the receiving URL from the HTTP request
    StringBuffer receivingURL = new StringBuffer();
    receivingURL = request.getRequestURL();

    String queryString = request.getQueryString();
    if (queryString != null && queryString.length() > 0)
    receivingURL.append("?").append(request.getQueryString());

    // verify the response; ConsumerManager needs to be the same
    // (static) instance used to place the authentication request
    VerificationResult verification = manager.verify(receivingURL.toString(), responselist, discovered);

    // examine the verification result and extract the verified identifier
    Identifier verified = verification.getVerifiedId();
    if (verified == null)
    {
        String msg = "Unable to verify the supplied OpenID.  "
        +"This could be for a number of reasons.  It might be that "
        +"network connectivity to the open id provider is down, the server is off line "
        +"temporarily, or the OpenId was not entered correctly.";

        //error message from one page to another page is passed as a session attribute
        //so that it does not become a permanent part of the URL that the user can see
        session.setAttribute("error-msg", new Exception(msg));

        response.sendRedirect(err);
        return;
    }

    AuthSuccess authSuccess = (AuthSuccess) verification.getAuthResponse();

    String confirmedId = authSuccess.getIdentity();

    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    wr.setLoggedIn(confirmedId);

    response.sendRedirect(go);%>
%>