<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.net.URLConnection"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Vector"
%><%@page import="java.util.TreeSet"
%><%@page import="org.w3c.dom.NamedNodeMap"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");

    FileCache mainDoc = FileCache.findFile(session, f);

    if (mainDoc==null) {
        //this is a clear indication of no session, so just redirect to the
        //file input page.
        response.sendRedirect("selectfile.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }

    if (!mainDoc.isValidJSON()) {
        response.sendRedirect("xmledit.jsp?f="+URLEncoder.encode(f, "UTF-8"));
        return;
    }

    String s = wr.reqParam("s");
    boolean useSchema = (s.equals("true"));

    TreeSet<String> allPaths = new TreeSet<String>();
    generateXPaths(allPaths, "", mainDoc.getJSON());


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>All Paths: <%wr.writeHtml(f);%></title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.fileName = "<%=f%>";
        
        $scope.goMode = function(page) {
            window.location.assign(page+"?f="+encodeURIComponent($scope.fileName));
        }

    });
  </script>
  <style>
  .datacell {
      padding:5px;
  }
  tr td {
      padding:5px;
  }
  </style>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">
<h1>All Paths: <%wr.writeHtml(f);%></h1>
<table>
<tr><td>
   <button ng-click="goMode('selectfile.jsp')" class="btn btn-primary">Change File</button>
</td><td>
   <button ng-click="goMode('xmledit.jsp')" class="btn btn-primary">Text View</button>
<% if (mainDoc.isValidJSON()) { %>
</td><td>
   <button ng-click="goMode('dataview.jsp')" class="btn btn-primary">Data View</button>
</td><td>
   <button ng-click="goMode('fieldview.jsp')" class="btn btn-primary">Field Edit</button>
</td><td>
   <button ng-click="goMode('xmlop.jsp')" class="btn btn-primary">Operation</button>
<% } %>
</td></tr>
<tr><td>
</table>
<p>Schema is
<%
    FileCache fcs = mainDoc.getSchema();
    if (fcs==null)
    {
        out.write("<i>not set</i>");
    }
    else
    {
        out.write(": ");
        wr.writeHtml(fcs.getName());
    }
%>
</p>
<hr>

<table width="800">
<%

    for (String line : allPaths) {
        %><tr><td><%
        wr.writeHtml(line);
        %></td></tr><%
    }

%>
</table>

<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
<%!

    public void generateXPaths(TreeSet<String> v, String pre, JSONObject jo)
        throws Exception
    {
        for (String key : jo.keySet()) {
            String newPre = pre + "." + key;
            Object o = jo.get(key);
            if (o instanceof JSONObject) {
                generateXPaths(v, newPre, (JSONObject)o);
            }
            else if (o instanceof JSONArray) {
                generateXPaths(v, newPre, (JSONArray)o);
            }
            else {
                v.add(newPre);
            }
        }

    }
    public void generateXPaths(TreeSet<String> v, String pre, JSONArray ja) 
        throws Exception {
        for (int i=0; i<ja.length(); i++) {
            String newPre = pre + "[#]";
            Object o = ja.get(i);
            if (o instanceof JSONObject) {
                generateXPaths(v, newPre, (JSONObject)o);
            }
            else if (o instanceof JSONArray) {
                generateXPaths(v, newPre, (JSONArray)o);
            }
            else {
                v.add(newPre);
            }
        }
    }

%>
