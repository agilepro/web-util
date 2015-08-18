package org.workcast.wu;

import javax.net.ssl.SSLContext;
import org.apache.http.conn.ssl.SSLSocketFactory;
import org.openid4java.consumer.ConsumerManager;
import org.openid4java.consumer.InMemoryConsumerAssociationStore;
import org.openid4java.consumer.InMemoryNonceVerifier;
import org.openid4java.discovery.Discovery;
import org.openid4java.discovery.html.HtmlResolver;
import org.openid4java.discovery.yadis.YadisResolver;
import org.openid4java.server.RealmVerifierFactory;
import org.openid4java.util.HttpFetcherFactory;
import org.workcast.streams.SSLPatch;

/**
* Manages an OpenID4Java session
*/
public class OpenIDHelper
{

    private static ConsumerManager manager;


    public OpenIDHelper() throws Exception
    {
        manager = newConsumerManager();
    }


    /**
    * Creating the proper consumer manager is not easy if you want to disable the
    * SSL certificate validation.  This method does that.
    */
    public static ConsumerManager newConsumerManager() throws Exception
    {
        // Install the all-trusting trust manager SSL Context
        SSLContext sc = SSLPatch.disableSSLCertValidation();

        HttpFetcherFactory hff = new HttpFetcherFactory(sc, SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
        YadisResolver yr = new YadisResolver(hff);
        RealmVerifierFactory rvf = new RealmVerifierFactory(yr);
        Discovery d = new Discovery(new HtmlResolver(hff),yr,Discovery.getXriResolver());

        manager=new ConsumerManager(rvf, d, hff);
        manager.setAssociations(new InMemoryConsumerAssociationStore());
        manager.setNonceVerifier(new InMemoryNonceVerifier(5000));
        return manager;
    }

/*
    public String startAndGetRedirectAddress() throws Exception
    {
        // perform discovery on the user-supplied identifier
        List discoveries = manager.discover(uopenid);
        if (discoveries==null) {
            throw new Exception("Client Manager discover returned a null list of discoveries.");
        }

        // attempt to associate with an OpenID provider
        // and retrieve one service endpoint for authentication
        DiscoveryInformation discovered = manager.associate(discoveries);
        if (discovered==null) {
            throw new Exception("Client Manager Associate returned a null Discovery Information.");
        }

        // obtain a AuthRequest message to be sent to the OpenID provider
        AuthRequest authReq = manager.authenticate(discovered, returnToUrl);

        // Option 1: GET HTTP-redirect to the OpenID Provider endpoint
        // The only method supported in OpenID 1.x
        // redirect-URL usually limited ~2048 bytes
        return authReq.getDestinationUrl(true);
    }


    public String completeAndVerify(request)
    {
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
            session.setAttribute("error-msg", msg);

            response.sendRedirect(err);
            return;
        }

        AuthSuccess authSuccess = (AuthSuccess) verification.getAuthResponse();

        String confirmedId = authSuccess.getIdentity();

    }
    */

}
