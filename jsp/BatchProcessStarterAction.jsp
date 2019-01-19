<%@page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"
%><%@page errorPage="error.jsp"
%><%@page import="java.net.URL"
%><%@page import="java.net.URLConnection"
%><%@page import="java.io.InputStream"
%><%@page import="java.io.Reader"
%><%@page import="java.io.InputStreamReader"
%><%@page import="java.io.StringReader"
%><%@page import="org.workcast.wu.WebRequest"
%><%
    WebRequest wr = WebRequest.getOrCreate(request, response, out);
    String pdid = wr.reqParam("pdid");
    boolean ignoreColumns = "yes".equals(wr.defParam("pdid", "no"));

    String csvSource = wr.reqParam("csvSource");
    Vector result = new Vector();   //empty by default
    if (csvSource.length()>5)
    {
        result = parseStream(new StringReader(csvSource));
    }

    Enumeration e = result.elements();
    if (!e.hasMoreElements())
    {
        throw new Exception("The CSV file does not have any rows in it, can't start processes with this");
    }
    Vector firstRow = (Vector)e.nextElement();
    if (!e.hasMoreElements())
    {
        throw new Exception("The CSV file has only one row.  the CSV input is required to have at least two rows: the first row is the column headers, and the second row is the values for the process to create.");
    }

    //now check to see if there are any invalid column headings
    Enumeration columns = firstRow.elements();
    while (columns.hasMoreElements())
    {
        String udaname = (String) columns.nextElement();

        if (!ignoreColumns)
        {
            //check here
            //if udaname is not a valid UDA name, then complain about it.
        }
    }

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
  <title>Batch Process Starter</title>
  <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>
<h1>Batch Process Starter Result</h1>

<hr>

<p>Process Definition Id: <%=pdid%></p>
<p><% if (ignoreColumns) { %>Ignoring Non Matching Columns<% } else { %> All columns must match a UDA <% } %>
<hr/>
<table>
<%
    int recNum = 0;
    while (e.hasMoreElements())
    {
        recNum++;
        Vector row = (Vector) e.nextElement();
        %><tr><td>#<%=recNum%>.</td>
        <%
        if (row.size()!=firstRow.size())
        {
            throw new Exception("Row "+recNum+" has "+row.size()+" entries, while the column header has "+firstRow.size()+" entries.  Each row should have the same number of entries as the header.");
        }

        //create the process instantiator at this point

        Enumeration e2 = row.elements();
        columns = firstRow.elements();
        while (e2.hasMoreElements())
        {
            String udavalue = (String)e2.nextElement();
            String udaname = (String)columns.nextElement();

            //set the uda 'udaname' to the value of udavalue

            %><td><% wr.writeHtml(udaname); %> = <% wr.writeHtml(udavalue); %></td>
            <%
        }
        %></tr>
        <%
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