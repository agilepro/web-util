package com.purplehillsbooks.ohioscan;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;

import com.purplehillsbooks.streams.MemFile;

public class WebStuff {
    private List<String> cookies;
    private HttpURLConnection conn;
    File dataFolder = new File("./data");
    File logFolder = new File("./log");

    private final String USER_AGENT = "Mozilla/5.0";


    /**
     * Constructor that sets credential info
     * @param _credentials
     */
    public WebStuff() {
    }



    /**
     * postHttpRequest: used to ibpm http POST request handler, in return JSONObject
     * @param url
     * @param content
     * @return JSONObject
     * @throws Exception
     */
    public int postHttpRequestRaw(URL url, String body, MemFile output) throws Exception {
        try {

            HttpURLConnection httpCon = null;
            httpCon = (HttpURLConnection) url.openConnection();
            int retCode = -1;
            try {
                httpCon.setRequestMethod("POST");
                httpCon.setDoOutput(true);
                httpCon.setDoInput(true);
                httpCon.connect();

                OutputStream os = httpCon.getOutputStream();
                OutputStreamWriter osw = new OutputStreamWriter(os, "UTF-8");
                osw.write(body);
                osw.flush();
                osw.close();
                os.close();

                retCode = httpCon.getResponseCode();
                InputStream is = null;
                if (retCode == 200) {
                    is = httpCon.getInputStream();
                } else {
                    is = httpCon.getErrorStream();
                }
                try {
                    output.fillWithInputStream(is);
                }
                finally {
                    is.close();
                }
            }
            finally {
                httpCon.disconnect();
            }
            return retCode;
        }
        catch (Exception e) {
            throw new Exception("Failure during http PUT of: "+url, e);
        }
    }
    public int putHttpRequestRaw(URL url, String body, MemFile output) throws Exception {
        try {
            HttpURLConnection httpCon = null;
            httpCon = (HttpURLConnection) url.openConnection();
            int retCode = -1;
            try {
                httpCon.setRequestMethod("PUT");
                httpCon.setDoOutput(true);
                httpCon.setDoInput(true);
                httpCon.connect();

                OutputStream os = httpCon.getOutputStream();
                OutputStreamWriter osw = new OutputStreamWriter(os, "UTF-8");
                osw.write(body);
                osw.flush();
                osw.close();
                os.close();

                retCode = httpCon.getResponseCode();
                InputStream is = null;
                if (retCode == 200) {
                    is = httpCon.getInputStream();
                } else {
                    is = httpCon.getErrorStream();
                }
                try {
                    output.fillWithInputStream(is);
                }
                finally {
                    is.close();
                }
            }
            finally {
                httpCon.disconnect();
            }
            return retCode;
        }
        catch (Exception e) {
            throw new Exception("Failure during http PUT of: "+url, e);
        }
    }



    /**
     * getHttpRequest: used to ibpm http GET request handler, in return JSONObject
     * @param url
     * @param content
     * @return JSONObject
     * @throws Exception
     */
    public int getHttpRequestRaw(URL url, MemFile output) throws Exception {
        try {

            conn = (HttpURLConnection) url.openConnection();
            try {
                conn.setRequestMethod("GET");
                conn.setUseCaches(false);
                conn.setRequestProperty("User-Agent", USER_AGENT);
                conn.setRequestProperty("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
                conn.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
                if (cookies != null) {
                    for (String cookie : this.cookies) {
                        conn.addRequestProperty("Cookie", cookie.split(";", 1)[0]);
                    }
                }

                int retCode = conn.getResponseCode();

                InputStream is = null;
                try {
                    if (retCode >= 400) {
                        is = conn.getErrorStream();
                    } else {
                        is = conn.getInputStream();
                    }

                    if (is!=null) {
                        output.fillWithInputStream(is);
                    }
                }
                finally {
                    if (is!=null) {
                        is.close();
                    }
                }
                return retCode;
            }
            finally {
                conn.disconnect();
            }
        }
        catch (Exception e) {
            throw new Exception("Failure during http GET of: "+url, e);
        }
    }
    public int deleteHttpRequestRaw(URL url, MemFile output) throws Exception {
        try {

            conn = (HttpURLConnection) url.openConnection();
            try {
                conn.setRequestMethod("DELETE");
                conn.setUseCaches(false);
                conn.setRequestProperty("User-Agent", USER_AGENT);
                conn.setRequestProperty("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
                conn.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
                if (cookies != null) {
                    for (String cookie : this.cookies) {
                        conn.addRequestProperty("Cookie", cookie.split(";", 1)[0]);
                    }
                }

                int retCode = conn.getResponseCode();

                InputStream is = null;
                try {
                    if (retCode == 200) {
                        is = conn.getInputStream();
                    } else {
                        is = conn.getErrorStream();
                    }

                    output.fillWithInputStream(is);
                }
                finally {
                    is.close();
                }
                return retCode;
            }
            finally {
                conn.disconnect();
            }
        }
        catch (Exception e) {
            throw new Exception("Failure during http DELETE of: "+url, e);
        }
    }



    /**
     * createBPMconnection: it allows system to behave like browser cookies
     *
     */
    public String createBPMCookies(URL url) throws Exception {
        conn = (HttpURLConnection) url.openConnection();

        // default is GET
        conn.setRequestMethod("GET");
        conn.setUseCaches(false);

        // act like a browser
        conn.setRequestProperty("User-Agent", USER_AGENT);
        conn.setRequestProperty("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
        conn.setRequestProperty("Accept-Language", "en-US,en;q=0.5");
        System.out.println("\n********************* Setting Cookies Start **********************");
        if (cookies != null) {
            for (String cookie : this.cookies) {
                System.out.println("Sending 'cookie : " + cookie);
                conn.addRequestProperty("Cookie", cookie.split(";", 1)[0]);
            }
        }
        int responseCode = conn.getResponseCode();
        System.out.println("Sending 'GET' request to URL : " + url);
        System.out.println("Response Code : " + responseCode);

        BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String inputLine;
        StringBuffer response = new StringBuffer();

        while ((inputLine = in.readLine()) != null) {
            response.append(inputLine);
        }
        in.close();

        // Get the response cookies
        setCookies(conn.getHeaderFields().get("Set-Cookie"));
        if (cookies!=null) {
            for (String cookOne : cookies) {
                System.out.println("Cookie: "+cookOne);
            }
        }
        System.out.println("********************* Setting Cookies End **********************\n\n");

        return response.toString();
    }

    public List<String> getCookies() {
        return cookies;
    }

    public void setCookies(List<String> cookies) {
        this.cookies = cookies;
    }


}
