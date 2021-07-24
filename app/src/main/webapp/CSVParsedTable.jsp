<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.StringReader"
%><%@page import="org.workcast.wu.OldWebRequest"
%><%
    OldWebRequest wr = OldWebRequest.getOrCreate(request, response, out);
    String enc  = wr.defParam("enc","UTF-8");
    String csvSource = wr.reqParam("csvSource");
    Vector result = new Vector();   //empty by default
    if (csvSource.length()>5)
    {
        result = parseStream(new StringReader(csvSource));
    }
    Enumeration e = result.elements();

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>CSV Parser Result</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>CSV Parser Result</h1>

<hr>

<p><font size="-1">Cut and paste the CSV into the edit box above, then
press "Parse CSV" to have that CSV read, parsed, and a table generated.
This will only work on well formed XML.  If the XML is not well formed,
</p>
<table>
<%
    while (e.hasMoreElements())
    {
        Vector row = (Vector) e.nextElement();
        %><tr>
        <%
        Enumeration e2 = row.elements();
        while (e2.hasMoreElements())
        {
            String cell = (String)e2.nextElement();

            %><td><% wr.writeHtml(cell); %></td>
            <%
        }
    }
%>

</table>
</body>
</html>

<%@ include file="functions.jsp"%>
<%!

    public Vector parseStream(Reader input)
        throws Exception
    {
        boolean inQuote = false;
        boolean possibleEndQuote = false;
        Vector  results = new Vector();
        Vector  currentRow = new Vector();
        StringBuffer currentValue = new StringBuffer();

        int ch = input.read();
        for (; ch != -1; ch = input.read())
        {
            if (inQuote)
            {
                if (ch == '"')
                {
                    inQuote=false;
                    possibleEndQuote = true;
                }
                else
                {
                    currentValue.append((char)ch);
                }
                continue;
            }
            if (possibleEndQuote)
            {
                possibleEndQuote = false;
                if (ch == '"')
                {
                    //this is the double quote case, go back to
                    //quoted mode
                    inQuote=true;
                    currentValue.append('"');
                    continue;
                }
                //otherwise drop into normal character processing that follows
            }

            if (ch == '"')
            {
                inQuote=true;
            }
            else if (ch == ',')
            {
                //terminate the current value, start another
                currentRow.add(currentValue.toString());
                currentValue = new StringBuffer();
            }
            else if (ch == '\n')
            {
                //terminate the current value, start another
                //also terminate the current row, start another
                currentRow.add(currentValue.toString());
                currentValue = new StringBuffer();
                results.add(currentRow);
                currentRow = new Vector();
            }
            else
            {
                currentValue.append((char)ch);
            }
        }

        currentRow.add(currentValue.toString());
        results.add(currentRow);
        return results;
    }


%>