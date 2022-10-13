<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.File"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Hashtable"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%@page import="com.purplehillsbooks.streams.MemFile"
%><%


    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);


    MemFile mf = new MemFile();
    mf.fillWithInputStream(request.getInputStream());
    String contentx = mf.toString();

    JSONObject post = new JSONObject(contentx);
    
    String fileName = post.getString("fileName");
    String fileType = post.optString("fileType", "TXT");
    String content = post.getString("content");
    
    JSONObject result = new JSONObject();
    result.put("status", "running");
    result.put("fileType", fileType);
    result.put("fileName", fileName);
    result.put("lentgh", content.length());


    FileCache mainDoc = new FileCache(fileName);
    mainDoc.setContents(content);
    FileCache.storeFile(session, mainDoc);
    

    result.put("status", "received");
    result.put("numFiles", FileCache.listFiles(session).size());
    result.write(wr.w, 2, 2);
%>