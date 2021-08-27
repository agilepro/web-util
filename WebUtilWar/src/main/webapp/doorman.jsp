<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.Reader"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    request.setCharacterEncoding("UTF-8");

%>
<head>
  <title>Doorman</title>
  <meta name="viewport" content="user-scalable=no, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0" />
  <link rel="stylesheet" href="css/bootstrap.min.css">
  <link href='https://fonts.googleapis.com/css?family=Montserrat:200,400,700' 
        rel='stylesheet' type='text/css'>
  <link href="css/wustyle.css"       rel="stylesheet" type="text/css"/>
  <style>
  body {
      padding: 20px;
  }
  .mainbox {
      background-color: white;
      max-width: 100%;
      padding:10px;
  }
  h2 {
      text-align: center;
      font-weight: 600;
      color: #3F0E40;
  }
  h1 {
      text-align: center;
      *font-weight: 600;
      color: #3F0E40;
  }
  </style>
  <script>
  function goThere() {
      location.href = "https://zoom.us/j/9209429461";
      //alert("Still need to get the correct ZOOM link from Phillip for Thursday night");
      //location.href='https://us02web.zoom.us/j/88601177272';
  }
  </script>
</head>
<body ng-app="myApp" ng-controller="myCtrl">
<div>

The meeting you are about to attend requires that you read and agree to the following:
<div class="mainbox">

<h1>Philosophers and Gamblers</h1>
<h2>Norms of Engagement</h2>

<p>P&amp;G is a group or meeting place that aims to bring people together to discuss challenging, controversial or highly technical topics from a philosophical point of view.  We wish to gather people into the group who are interested in <b>learning</b> with others, <b>thinking</b> with others and <b>growing</b> with others.  We value vigorous intellectual discussions, explorations and debates, but we do not appreciate conflict for its own sake, nor people who join only to be heard and not to listen.  Although any idea can and should be challenged by a sound argument, P&amp;G is <b>NOT</b> a place for people to abuse, insult or attack others, nor is it anyone’s personal pulpit/platform.
</p>

<h1>CLUB RULES</h1>

<h2>No personal attacks or insults</h2> 

<p>
If you disagree with someone, first make sure you understand them.  Would you be able to articulate their point of view?  Perhaps consider asking clarifying questions.  In any case, arguments should be about ideas, not people.
</p>


<h2>No talking over others</h2>

<p>
Depending on the situation, P&amp;G adopts different methods of managing the flow of the discussion.  In all cases, it’s important to avoid interrupting other people, especially when interrupting to voice a disagreement.  Nothing will make someone feel more misunderstood than to be disagreed with before even completing their point.  We do not want to have to deal with tangled messes of people competing with each other over who can speak louder.
</p>

<h2>No preaching</h2>

<p>
Along with avoiding interruptions comes being considerate of others in how much time you spend making your point.  P&amp;G is a discussion <b>group</b>, not a stage starring just you.  Don’t take more time than necessary to say what you have to say, don’t monopolize the back and forth exchanges, and don’t use this group as a platform to turn every discussion into a discussion of your own personal stance or pet projects.
</p>


<p>
<b>Failure to abide by these rules may result in reprimand, removal from the discussion or a permanent ban, at the complete discretion of the moderator.</b>
</p>








</div>

<div style="padding:10px">
<button onclick="goThere()" 
        class="btn btn-primary">I agree, take me to the meeting</button>
<button onclick="location.href='https://www.meetup.com/Philosophers-and-Gamblers/'" 
        class="btn btn-primary">No Thanks</button>

</div>


<div style="height:400px"></div>
<% wr.invokeJSP("tileBottom.jsp"); %>

</div>
</body>
</html>


