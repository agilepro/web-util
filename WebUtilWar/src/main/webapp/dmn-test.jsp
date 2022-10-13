<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.ArrayList"
%><%@page import="java.io.Writer"
%><%@page import="org.workcast.wu.DOMFace"
%><%@page import="org.workcast.wu.FileCache"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%@page import="com.purplehillsbooks.xml.Mel"
%><%@page import="com.purplehillsbooks.streams.MemFile"
%><%@page import="com.purplehillsbooks.json.JSONObject"
%><%@page import="com.purplehillsbooks.json.JSONArray"
%><%@page import="com.purplehillsbooks.json.Dom2JSON"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);

    String f = wr.reqParam("f");
    Hashtable<String,FileCache> ht = (Hashtable<String,FileCache>) session.getAttribute("fileCache");
    FileCache mainDoc = (FileCache) ht.get(f);
    if (mainDoc==null) {
        throw new Exception("Unable to find a file with name = "+f);
    }
    
    Mel dmnFile = Mel.readInputStream(mainDoc.getInputStream(), Mel.class);
    MemFile mf = new MemFile();
    dmnFile.writeToOutputStream(mf.getOutputStream());
    
    Hashtable<String,Integer> hints = new Hashtable<String,Integer>();
    hints.put("input", 3);
    hints.put("output", 3);
    hints.put("rule", 3);
    hints.put("decision", 3);
    hints.put("contextEntry", 3);
    hints.put("decisionService", 3);
    hints.put("semantic:input", 3);
    
    
    JSONObject jo = Dom2JSON.convertDomToJSON(dmnFile.getDocument(), hints);
    
    recusiveStripNameSpace(jo);
    recursiveStripTag(jo, "DMNDI");
    recursiveStripTag(jo, "dc");
    recursiveStripTag(jo, "di");
    recursiveStripTag(jo, "dmn");
    recursiveStripTag(jo, "dmndi");
    recursiveStripTag(jo, "xmlns");
    recursiveStripTag(jo, "extensionElements");
    recursiveStripTag(jo, "kie");
    recursiveStripTag(jo, "namespace"); 
    
    
%><%!

    void recusiveStripNameSpace(JSONObject jo) throws Exception {
        ArrayList<String> keys = new ArrayList<String>();
        for (String key : jo.keySet()) {
            keys.add(key);
        }
        for (String key : keys) {
            int colonPos = key.indexOf(":");
            if (colonPos>0) {
                Object value = jo.get(key);
                jo.remove(key);
                String bareKey = key.substring(colonPos+1);
                jo.put(bareKey, value);
            }
        }
        for (String key : jo.keySet()) {
            Object value = jo.get(key);
            if (value instanceof JSONObject) {
                recusiveStripNameSpace((JSONObject)value);
            }
            else if (value instanceof JSONArray) {
                listStripNameSpace((JSONArray)value);
            }
        }
    }
    
    void listStripNameSpace(JSONArray ja) throws Exception {
        for (int i=0; i<ja.length(); i++) {
            Object value = ja.get(i);
            if (value instanceof JSONObject) {
                recusiveStripNameSpace((JSONObject)value);
            }
            else if (value instanceof JSONArray) {
                listStripNameSpace((JSONArray)value);
            }
        }
    }
    
    void recursiveStripTag(JSONObject jo, String tagName) throws Exception {
        if (jo.has(tagName)) {
            jo.remove(tagName);
        }
        ArrayList<String> keys = new ArrayList<String>();
        for (String key : jo.keySet()) {
            keys.add(key);
        }
        for (String key : jo.keySet()) {
            Object value = jo.get(key);
            if (value instanceof JSONObject) {
                recursiveStripTag((JSONObject)value, tagName);
            }
            else if (value instanceof JSONArray) {
                listStripNameSpace((JSONArray)value);
            }
        }
    }
    void listStripTag(JSONArray ja, String tagName) throws Exception {
        for (int i=0; i<ja.length(); i++) {
            Object value = ja.get(i);
            if (value instanceof JSONObject) {
                recursiveStripTag((JSONObject)value, tagName);
            }
            else if (value instanceof JSONArray) {
                listStripTag((JSONArray)value, tagName);
            }
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
        $scope.dmnObj = <% jo.write(out,2,2); %>;
        $scope.dataOut = {};
        $scope.dataIn = {};
        
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

<pre>
<% wr.writeHtml(jo.toString(2)); %>
</pre>

<div style="height:50px"></div>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>
<script type="text/javascript" src="dmn-bundle.js"></script></body>
</body>