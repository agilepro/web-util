<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Vector"
%><%@page import="java.util.List"
%><%@page import="java.util.ArrayList"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%@page import="com.purplehillsbooks.streams.MemFile"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
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
    if (!mainDoc.isValidJSON() && !mainDoc.isValidXML())
    {
        throw new Exception("How did you get here?  File '"+f+"' is not valid JSON or XML, and this page works only with valid JSON or XML.");
    }



    List<String> otherFiles = new ArrayList<String>();
    JSONArray otherList = new JSONArray();
    for (FileCache fc : FileCache.listFiles(session)) {
        String name = fc.getName();
        if (name.equals(f)) {
            continue;
        }
        otherFiles.add(name);
        otherList.put(name);
    }


%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>File Operations: <%wr.writeHtml(f);%></title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.fileName = "<% wr.writeJS(f); %>";
        $scope.fileType = "<% wr.writeJS(mainDoc.getType()); %>";
        $scope.baseName = $scope.fileName;
        var dotPos = $scope.fileName.indexOf(".");
        if (dotPos>0) {
            $scope.baseName = $scope.fileName.substring(0, dotPos);
        }
        $scope.otherName = <% otherList.write(out, 2, 2); %>;
        
        $scope.goof = function() {
            window.open("dmn-test.jsp?f="+$scope.fileName);
        }
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
<h1>{{fileType}} Operations: <%wr.writeHtml(f);%></h1>

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
<% } %>
<% if (mainDoc.isValidJSON() || mainDoc.isValidXML()) { %>
</td><td>
   <button ng-click="goMode('xmlop.jsp')" class="btn btn-warning">Operation</button>
<% } %>
</td></tr>
<tr><td>
</table>

<h2>Operations</h2>
<p>Schema is
<%
    FileCache fcs = mainDoc.getSchema();
    if (fcs==null)
    {
        out.write("<i>not set</i>");
    }
    else
    {
        wr.write(" <b>");
        wr.writeHtml(fcs.getName());
        wr.write("</b>");
    }
%>
</p>


<% if (mainDoc.isValidJSON()) { %>
<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="{{fileName}}">
   <input type="submit" name="act" value="Gen Schema">
   to file name: <input type="text" name="destFile" value="{{baseName}}.schema.json">
   </form></p>




<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="{{fileName}}">
   <input type="submit" name="act" value="Validate">
   using schema: <select type="text" name="otherFile">
<%
    for (String oFile : otherFiles) {
        wr.write("\n   <option>");
        wr.writeHtml(oFile);
        wr.write("</option>");
    }
%>
   </select>
   output to: <input type="text" name="destFile" value="{{baseName}}.validation.txt">
   </form></p>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="{{fileName}}">
   <input type="submit" name="act" value="Set Schema">
   to the file:  <select type="text" name="otherFile">
<%
    for (String oFile : otherFiles) {
        wr.write("<option>");
        wr.writeHtml(oFile);
        wr.write("</option>");
    }
%>
   </select>
   </form></p>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="{{fileName}}">
   <input type="submit" name="act" value="Save As">
   file to new name: <input type="text" name="destFile" value="{{fileName}}">
   </form></p>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="{{fileName}}">
   <input type="submit" name="act" value="Save to Path">
   file to new name: <input type="text" name="path" value="">
   </form></p>



<p><form action="showxpath.jsp" method="GET">
   <input type="hidden" name="f" value="{{fileName}}">
   <input type="hidden" name="s" value="false">
   <input type="submit" name="act" value="Show XPaths">
   </form></p>

<p><form action="xmleditAction.jsp" method="POST">
   <input type="text" name="sn" value="">
   <input type="hidden" name="f" value="{{fileName}}">
   <input type="submit" name="act" value="Register XMLSchema">
   </form></p>

<% } %>
<% if (mainDoc.isValidXML()) { %>
<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="{{fileName}}">
   <input type="submit" name="act" value="Generate JSON">
   </form></p>
<p><form action="xmleditAction.jsp" method="POST">
   <input type="hidden" name="f" value="{{fileName}}">
   <input type="submit" name="act" value="Reformat">
   to put the file in canonical form
   </form></p>
<% } %>


<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>
</body>
</html>

