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
%><%@page import="org.w3c.dom.NamedNodeMap"
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

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>JSON Grinder: <%wr.writeHtml(f);%></title>
  <script src="js/angular.js"></script>
  <link href="css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <script>
    var myApp = angular.module('myApp', []);

    myApp.controller('myCtrl', function ($scope) {
        $scope.fileName = "<%=f%>";
        
        $scope.goSelectFile = function() {
            window.location.assign("selectfile.jsp");
        }
        $scope.goEdit = function() {
            window.location.assign("xmledit.jsp?f="+encodeURIComponent($scope.fileName));
        }
        $scope.goDataView = function() {
            window.location.assign("dataview.jsp?f="+encodeURIComponent($scope.fileName));
        }
        $scope.goOperate = function() {
            window.location.assign("xmlop.jsp?f="+encodeURIComponent($scope.fileName));
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

<h1>JSON Grinder: <%wr.writeHtml(f);%></h1>
<table>
<tr><td>
   <button ng-click="goMode('selectfile.jsp')" class="btn btn-primary">Change File</button>
</td><td>
   <button ng-click="goMode('xmledit.jsp')" class="btn btn-primary">Text View</button>
<% if (mainDoc.isValidJSON()) { %>
</td><td>
   <button ng-click="goMode('dataview.jsp')" class="btn btn-primary">Data View</button>
</td><td>
   <button ng-click="goMode('fieldview.jsp')" class="btn btn-warning">Field Edit</button>
<% } %>
<% if (mainDoc.isValidJSON() || mainDoc.isValidXML()) { %>
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

<form action="fieldviewAction.jsp">
<input type="submit" name="act" value="Save Changes">
<input type="hidden" name="f" value="<%wr.writeHtml(f);%>">

<table><tr><td bgcolor="skyblue">
<% generateTables(wr, 800, "MAIN", mainDoc.getJSON()); %>
</td></tr></table>
</form>

<hr>
<% wr.invokeJSP("tileBottom.jsp"); %>
</div>
</body>
</html>

<!-- %@ include file="functions.jsp"% -->
<%!




    public void generateTables(OldWebRequest wr, int width, String name, Object me)
        throws Exception
    {
        String color = "LightCyan";
        if (width%50==0)
        {
            color = "lightyellow";
        }
        int cellwidth = width-25;
        if (me instanceof JSONObject) {
            JSONObject jo = ((JSONObject)me);
            wr.write("\n<table width=\""+(width-4)+"\">");
            wr.write("\n<col width=\"16\">");
            wr.write("\n<col width=\""+(cellwidth-4)+"\">");
            wr.write("\n  <tr><td colspan=\"2\"><b>");
            wr.writeHtml(name);
            wr.write("</b>");
            if (true) {
                wr.write("\n  </td></tr><tr><td>");
                wr.write("\n  </td><td bgcolor=\""+color+"\">");
                for (String key : jo.keySet()) {
                    Object o = jo.get(key);
                    if (o instanceof JSONObject) {
                        generateTables(wr, cellwidth, key, ((JSONObject)o));
                    }
                    else if (o instanceof JSONArray) {
                        generateTables(wr, cellwidth, key, ((JSONArray)o));
                    }
                    else if (o instanceof String) {
                        wr.writeHtml(key);
                        wr.write(" = <input type=\"text\" name=\"xxx\" value=\"");
                        wr.writeHtml((String)o);
                        wr.write("\"><br/>");
                    }
                    else  {
                        wr.writeHtml(key);
                        wr.write(" = ");
                        wr.writeHtml("no impplemented yet");
                        wr.write("<br/>");
                    }
                }
            }
            wr.write("\n  </td></tr>");
            wr.write("\n</table>");
        }
        else if (me instanceof JSONArray) {
            JSONArray ja = ((JSONArray)me);
            //wr.write("\n<table width=\""+(width-4)+"\">");
            //wr.write("\n<col width=\"16\">");
            //wr.write("\n<col width=\""+(cellwidth-4)+"\">");
            //wr.write("\n  <tr><td colspan=\"2\">");
            for (int i=0; i<ja.length(); i++) {
                Object o = ja.get(i);
                if (o instanceof JSONObject) {
                    generateTables(wr, width, name+"["+i+"]", ((JSONObject)o));
                }
                else if (o instanceof JSONArray) {
                    generateTables(wr, width, name+"["+i+"]", ((JSONArray)o));
                }
                else if (o instanceof String) {
                    wr.writeHtml(name+"["+i+"]");
                    wr.write(" = <input type=\"text\" name=\"xxx\" value=\"");
                    wr.writeHtml((String)o);
                    wr.write("\"><br/>");
                }
                else  {
                    wr.writeHtml(name+"["+i+"]");
                    wr.write(" = ");
                    wr.writeHtml("no impplemented yet");
                    wr.write("<br/>");
                }
            }
            //wr.write("\n  </td></tr>");
            //wr.write("\n  </table>");
        }
        else if (me instanceof String) {
            wr.writeHtml(name);
            wr.write(" = <input type=\"text\" name=\"xxx\" value=\"");
            wr.writeHtml((String)me);
            wr.write("\"><br/>");
        }
        else {
            wr.writeHtml(name);
            wr.write(" = ");
            wr.writeHtml("No implemento");
            wr.write("<br/>");
        }
    }

%>
