<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.security.cert.CertificateException"
%><%@page import="java.security.cert.X509Certificate"
%><%@page import="javax.net.ssl.HostnameVerifier"
%><%@page import="javax.net.ssl.HttpsURLConnection"
%><%@page import="javax.net.ssl.SSLContext"
%><%@page import="javax.net.ssl.SSLSession"
%><%@page import="javax.net.ssl.TrustManager"
%><%@page import="javax.net.ssl.X509TrustManager"
%><%@page import="org.apache.http.HttpEntity"
%><%@page import="org.apache.http.HttpResponse"
%><%@page import="org.apache.http.Header"
%><%@page import="org.apache.http.client.HttpClient"
%><%@page import="org.apache.http.client.methods.HttpGet"
%><%@page import="org.apache.http.conn.ClientConnectionManager"
%><%@page import="org.apache.http.conn.scheme.Scheme"
%><%@page import="org.apache.http.conn.scheme.SchemeRegistry"
%><%@page import="org.apache.http.conn.ssl.SSLSocketFactory"
%><%@page import="org.apache.http.conn.ssl.SSLConnectionSocketFactory"
%><%@page import="org.apache.http.impl.client.DefaultHttpClient"
%><%@page import="com.purplehillsbooks.streams.SSLPatch"
%><%@page import="org.workcast.wu.SimpleWebRequest"
%><%
    SimpleWebRequest wr = new SimpleWebRequest(request, response, out);
    String enc  = wr.defParam("enc","UTF-8");
    String path = wr.defParam("path","");
    String pageSource = null;
    int amtTotal = 0;
    if (path!=null && path.length()>=5)
    {
        //SSLPatch.disableSSLCertValidation();

        pageSource = fetchDocUsingApache(path, enc);
        amtTotal = pageSource.length();
    }

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Page Source Display</title>
  <script src="js/angular.js"></script>
  <link href='https://fonts.googleapis.com/css?family=Montserrat:200,400,700' rel='stylesheet' type='text/css'>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.srctext = "";

    });
</script>
</head>
<body ng-app="genieApp" ng-controller="genieCtrl">
<div class="mainFrame">

<h1>Page Source Display</h1>

<hr>
<form action="pagesource2.jsp" method="get">
  <input type="text" name="path" value="<%= path %>" size=80>
  <input type="submit" value="Get">
  <input type="text" name="enc" value="<%= enc %>">
</form>

<%

    if (pageSource != null) {
        out.write("<textarea cols=\"120\" rows=\"40\">");
        wr.writeHtml(pageSource);
        wr.write("</textarea><p>Characters: ");
        wr.write(Integer.toString(amtTotal));
        wr.write("</p>\n<p>URL: <a target=\"other\" href=\"");
        wr.writeHtml(path);
        wr.write("\">");
        wr.writeHtml(path);
        wr.write("</a></p>");
    }

%>

<hr>

<p><font size="-1">This page can be help in debugging web applications.
Enter the URL into the box.  The page will be retrieved and then displayed
in the browser.  This conversion to displayable form is done <i>before</i>
the browser attempts to act on the data, which in some cases alters it.
For example, if XML is malformed, Internet Explorer will refuse to show you
the malformed XML source.  This page will retrieve the XML, and then display
it so that the browser is not involved in trying to interpret the XML.</p>

<p>Enter the desired page encoding for conversion from bytes to characters into
the second box if you know the page to be encoded in something other than UTF-8.</p>

<% wr.invokeJSP("tileBottom.jsp"); %>

</body>
</html>

<%@ include file="functions.jsp"%>
<%!

    public String fetchDocUsingApache(String pageUrl, String enc)
        throws Exception
    {
        URL testUrl = new URL(pageUrl);

        HttpClient httpclient = new DefaultHttpClient();
        //httpclient = wrapClient(httpclient);
        HttpGet httpget = new HttpGet(pageUrl);

        HttpResponse response = httpclient.execute(httpget);
        StringBuffer putBackTogether = new StringBuffer();
        Header[] allHeaders = response.getAllHeaders();
        if (allHeaders!=null) {
            for (int i=0; i<allHeaders.length; i++) {
                putBackTogether.append(allHeaders[i].getName() + ": " + allHeaders[i].getValue()+"\n");
            }
        }
        putBackTogether.append("-------------------------------------------\n\n");
        
        HttpEntity ent = response.getEntity();
        InputStream is = ent.getContent();
        if (is == null) {
            throw new Exception("Got a null content object!");
        }
        Reader r = new InputStreamReader(is, enc);
        char[] cb = new char[2048];

        int amtRead = r.read(cb);
        while (amtRead > 0) {
            putBackTogether.append(cb, 0, amtRead);
            amtRead = r.read(cb);
        }
        return putBackTogether.toString();
    }

    public static HttpClient wrapClient(HttpClient base) {
        try { 
            SSLContext ctx = SSLContext.getInstance("TLS");
            ctx.init(null, new TrustManager[]{SSLPatch.getDummyTrustManager()}, null);
            SSLConnectionSocketFactory ssf = new SSLConnectionSocketFactory(ctx,  
                     SSLConnectionSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
            ClientConnectionManager ccm = base.getConnectionManager();
            //SchemeRegistry sr = ccm.getSchemeRegistry();
            //sr.register(new Scheme("https", ssf, 443));
            return new DefaultHttpClient(ccm, base.getParams());
        } catch (Exception ex) {
            return null;
        }
    }
    
    public static HttpClient wrapClientBACK(HttpClient base) {
        try { 
            SSLContext ctx = SSLContext.getInstance("TLS");
            ctx.init(null, new TrustManager[]{SSLPatch.getDummyTrustManager()}, null);
            SSLSocketFactory ssf = new SSLSocketFactory(ctx);
            ssf.setHostnameVerifier(SSLSocketFactory.ALLOW_ALL_HOSTNAME_VERIFIER);
            ClientConnectionManager ccm = base.getConnectionManager();
            SchemeRegistry sr = ccm.getSchemeRegistry();
            sr.register(new Scheme("https", ssf, 443));
            return new DefaultHttpClient(ccm, base.getParams());
        } catch (Exception ex) {
            return null;
        }
    }    
%>