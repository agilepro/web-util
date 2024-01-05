<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="org.workcast.wu.SimpleWebRequest"
%><%
    SimpleWebRequest wr = new SimpleWebRequest(request, response, out);
%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link href="dmn-index.css" rel="stylesheet">
    <link href="dmn-main.css" rel="stylesheet"></head>
    <link rel="stylesheet" href="dmn-jquery-modal/0.9.1/jquery.modal.min.css" />
    <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
    <title>DMN Test Page</title>
</head>
<body>



<style>

    .row {
        margin-right: 0px;
        margin-left: 0px;
    }

    #topContainer td {
        padding: 3px;
    }

    input,
    select {
        display: block;
        height: 28px;
        width: 100%;
        border: 1px dashed green;
        padding-left: 10px;
    }

    .error {
        position: absolute;
        top: 200;
        bottom: 200;
        left: 200;
        right: 200;
        border: 10px solid red;
        overflow: scroll;
        background: white;
        color: black;
        z-index: 100;
        font-family: monospace;
        font-size: large;
    }

    input[readonly] {
        background-color: #DDD;
    }

    #js-table {
        margin: 10px;
        height: 450px;
        overflow: auto;
        border-style: solid;
        border-width: 1px;
        border-color: grey;
        margin-left: 5%;
        width: 90%;
    }

    #downloadUpload {
        margin-left: 5%;
    }

    #topContainer {
        min-height: 100px;
        margin-bottom: 25px;
    }

    table {
        width: 100%;
    }

    table tr td:first-child {
        width: 30%;
        text-align: right;
    }

    table tr td.inputElement {
        width: 55%;
    }

    .fired td {
        background-color: rgb(0, 213, 255) !important;
    }

    #inputsContainer table {
        margin-bottom: 10px;
        table-layout: auto;
    }

    #inputsContainer table th,
    #inputsContainer table td {
        word-break: break-word;
    }

    #inputsContainer .inputTypeRef {
        width: 15%;
    }

    /* Style the header with a grey background and some padding */
    .header {
      overflow: hidden;
      background-color: #f1f1f1;
      padding: 20px 10px;
    }

    /* Style the header links */
    .header a {
      float: left;
      color: black;
      text-align: center;
      padding: 12px;
      text-decoration: none;
      font-size: 18px;
      line-height: 25px;
      border-radius: 4px;
    }

    /* Style the header links */
    .header span {
      color: black;
      text-align: center;
      padding: 12px;
      text-decoration: none;
      font-size: 25px;
      line-height: 40px;
      border-radius: 4px;
      font-weight: bold;
    }

    /* Style the logo link (notice that we set the same value of line-height and font-size to prevent the header to increase when the font gets bigger */
    .header a.logo {
      font-size: 25px;
      font-weight: bold;
      width: 65px;
      height: 65px;
    }

    /* Change the background color on mouse-over */
    .header span:hover {
      background-color: #ddd;
      color: black;
    }

    /* Float the link section to the right */
    .header-mid {
      text-align: center;
      padding: 12px;
    }

    /* Add media queries for responsiveness - when the screen is 500px wide or less, stack the links on top of each other */
    @media screen and (max-width: 500px) {
      .header a {
        float: none;
        display: block;
        text-align: left;
      }
      .header-right {
        float: none;
      }
    }
</style>

<div class="mainFrame">
    <h1>DMN Test Page</h1>



        <div class="content dmn-simulator" id="js-drop-zone">
            <div id="topContainer" class="row">
                <div id="inputs" class="col-md-6 col-xs-12">
                    <h2 id="inputsHeader">Inputs:</h2>
                    <table id="decisionTable">
                        <tr>
                            <td>Decision table:</td>
                            <td>
                                <select name="decisionTableName" id="decisionTableName">
            </select>
                            </td>
                    </table>
                    <div id="inputsContainer"></div>
                </div>
                <div id="outputs" class="col-md-6 col-xs-12">
                    <h2 id="outputsHeader">Outputs:</h2>
                    <table id="outputsContainer"></table>
                </div>
            </div>

            <div style="text-align: center;">
                <p>
                    <button id="simulateButton" class="btn btn-primary" id="download-button">Simulate now</button>
                </p>
            </div>

            <div id="js-table">

            </div>

            <div id="downloadUpload">
                <button id="uploadButton" class="btn btn-default" style="margin-top:20px !important">Upload DMN Table</button>
                <a id="downloadButton" class="btn btn-default " style="margin-top:20px !important">Download DMN Table</a>
            </div>
        </div>


        <!-- Modal -->
        <div class="modal" id="myModal" tabindex="-1"  aria-labelledby="myModalLabel">
            <div class="modal-header">
                <a href="#"  class="close" rel="modal:close"><span aria-hidden="true">&times;</span></a>
                <h4 class="modal-title" id="myModalLabel">Error in DMN execution</h4>
            </div>
            <div id="myModalBody" class="modal-body">
            </div>
        </div>


<% wr.invokeJSP("tileBottom.jsp"); %>
</div>

<script type="text/javascript" src="dmn-bundle.js"></script>
</body>
</html>
