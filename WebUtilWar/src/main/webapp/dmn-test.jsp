<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.ArrayList"
%><%@page import="java.util.Map"
%><%@page import="java.util.HashMap"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="org.workcast.wu.XMLScrub"
%><%@page import="com.purplehillsbooks.xml.Mel"
%><%@page import="com.purplehillsbooks.streams.MemFile"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%@page import="com.purplehillsbooks.json.Dom2JSON"
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
    
    if (!mainDoc.isValidXML()) {
        throw new Exception("This page needs XML");
    }
    
    XMLScrub scrubber = new XMLScrub();
    
    Mel root = mainDoc.getXML();
    Map<String, Integer> counts = scrubber.collectAllNamespaceCounts(root);
    
    JSONArray errors = new JSONArray();
    JSONArray mapCounts = new JSONArray();
    JSONObject prefixUsage = new JSONObject();
    Map<String,String> usedDefs = new HashMap<String,String>();
    
    
    for (String key : counts.keySet()) {
        Integer count = counts.get(key);
        int barPos = key.indexOf("|");
        String token = key.substring(0,barPos);
        String url = key.substring(barPos+1);
        JSONObject jo = new JSONObject();
        jo.put("token", token);
        jo.put("url", url);
        jo.put("count", count.intValue());
        mapCounts.put(jo);
        
        String oldUrl = usedDefs.get(token);
        if (oldUrl!=null) {
            if (!oldUrl.equals(url)) {
                errors.put("Namespace declaration for '"+token+"' defined more than once with different URL values");
            }
        }
        else {
            usedDefs.put(token, url);
        }
        
        int colonPos = token.indexOf(":");
        if (colonPos>0) {
            String prefix = token.substring(colonPos+1);
            int countx = scrubber.countPrefixUse(root, prefix);
            prefixUsage.put(prefix, countx);
            if (countx==0) {
                errors.put("Unnecessary prefix '"+prefix+"' defined but never used in the file");
            }
        }
    }
    
    scrubber.calculateIdRefCounts(root);
    
    JSONArray idScan = new JSONArray();
    for (String id : scrubber.idToPath.keySet() ) {
        JSONObject jo = new JSONObject();
        jo.put("id", id);
        jo.put("path", scrubber.idToPath.get(id));
        jo.put("count", scrubber.refCount.getCount(id));
        jo.put("ref", scrubber.refToPath.get(id));
        idScan.put(jo);
    }
    for (String ref : scrubber.refToPath.keySet() ) {
        if (scrubber.idToPath.get(ref)==null) {
            errors.put("Dangling reference to undefined id: '"+ref+"'");
        }
    }
    
%>
<html lang="en">
<head>
  <title>DMN Test Page</title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.dataOut = {};
        $scope.dataIn = {};
        $scope.counts = <% mapCounts.write(out,2,2); %>;
        $scope.usage = <% prefixUsage.write(out,2,2); %>;
        $scope.errors = <% errors.write(out,2,2); %>;
        $scope.idScan = <% idScan.write(out,2,2); %>;
        
        
        $scope.selectFile = function() {
            window.location.href = "selectfile.jsp?f="+$scope.fileName;
        }
        $scope.visualFile = function() {
           window.location.href = "dmn-simulation.jsp?f="+$scope.fileName;
        }
        $scope.executeModel = function() {
           alert("running");
        }

    });
  </script>
  
  
  
  
  <style>
  .titleRow {
      background-color: lightskyblue;
  }
  </style>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div class="mainFrame">
<h1>DMN Test: <%wr.writeHtml(f);%></h1>

<div>
  <button class="btn btn-primary"  ng-click="selectFile()">Change File</button>
  <button class="btn btn-primary"  ng-click="visualFile()">Visualize</button>
</div>

<h2>Errors</h2>
<table class="table">
<tr ng-repeat="row in errors">
  <td><span style="color:red">{{row}}</span></td>
</tr>
<tr><td></td></tr>
</table>


<h2>Namespace Definitions</h2>
<table class="table">
<tr ng-repeat="row in counts">
  <td>{{row.token}}</td>
  <td>{{row.url}}</td>
  <td>{{row.count}}</td>
</tr>
<tr><td></td><td></td><td></td></tr>
</table>


<h2>Use of Namespace Prefix</h2>
<table class="table">
<tr ng-repeat="(ps,counta) in usage">
  <td>{{ps}}</td>
  <td>{{counta}}</td>
</tr>
<tr><td></td><td></td></tr>
</table>

<h2>All IDS</h2>
<table class="table">
<tr ng-repeat="row in idScan">
  <td>{{row.id}}</td>
  <td>{{row.count}}</td>
  <td>{{row.path}}<br/>
      {{row.ref}}</td>
</tr>
<tr><td></td><td></td></tr>
</table>


<div ng-repeat="deci in dmnObj.definitions.decision">
    <h2>Input for {{deci.id}}</h2>

    <table class="table">
    <tr class="titleRow">
        <td>Label</td>
        <td>TypeRef</td>
        <td>Value</td>
        <td>Id</td>
    </tr>
    <tr ng-repeat="input in deci.decisionTable.input">
        <td>{{input.label}}</td>
        <td>{{input.inputExpression.typeRef}}</td>
        <td><input class="form-control" ng-model="dataIn.{{input.label}}"/></td>
        <td>{{input.id}}</td>
    </tr>
    </table>
</div>



<div>
  <button class="btn btn-primary"  ng-click="executeModel()">Run</button>
</div>

<div ng-repeat="deco in dmnObj.definitions.decision">
    <h2>Output from {{deco.name}}</h2>

    <table class="table">
    <tr class="titleRow">
        <td>Label</td>
        <td>TypeRef</td>
        <td>Value</td>
        <td>Id</td>
    </tr>
    <tr ng-repeat="outRow in deco.decisionTable.output">
        <td>{{outRow.label}}</td>
        <td>{{outRow.typeRef}}</td>
        <td><input class="form-control" ng-model="dataOut.{{outRow.id}}"/></td>
        <td>{{outRow.id}}</td>
    </tr>
    </table>
</div>


<div style="height:50px"></div>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>
<script type="text/javascript" src="dmn-bundle.js"></script></body>
</body>