<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="java.io.Writer"
%>
<%

int[][] v = new int[9][9];

for (int i=0; i<9; i++) {
    for (int j=0; j<9; j++) {

        String varName = "a"+(i+1)+(j+1);
        String varVal = request.getParameter(varName);
        if (varVal == null) {
            v[i][j] = 0;
        }
        else if (varVal.length() <1) {
            v[i][j] = 0;
        }
        else {
            char ch = varVal.charAt(0);
            if (ch<'0' || ch > '9') {
                ch = '0';
            }
            v[i][j] = (int)ch - 48;
        }
    }
}

%>
<html>
<%
solve(out,v);
%>
<hr>
Number of solutions found: <%=count%>
</body></html>


<%!

static int limitNine = 9;
static Writer oout;
static int count;

public boolean solve(Writer out, int[][] v)
    throws Exception
{
    oout = out;
    count = 0;
    tryOne(v, 0, 0);
    return true;
}

public boolean tryOne(int [][] v, int i, int j)
    throws Exception
{
    if (i>=limitNine) {
        return true;   //gone too far, just return true if you made it this far
    }
    if (count>10000) {
        return false;   //give up
    }
    int nextj = j+1;
    int nexti = i;
    if (nextj>=limitNine) {
        nextj=0;
        nexti=i+1;
    }
    if (v[i][j]==0) {
        for (int n=1; n<10; n++) {
            v[i][j]=n;
            if (check(v,i,j)) {
                if (tryOne(v,nexti,nextj)) {
                    dump(v);
                }
            }
        }
        v[i][j]=0;
        return false;
    }
    else {
        return tryOne(v,nexti,nextj);
    }
}

public boolean check(int[][] v, int i, int j)
    throws Exception
{
    boolean[] hmap = new boolean[10];
    boolean[] vmap = new boolean[10];
    boolean[] qmap = new boolean[10];
    int qbasei = i - (i%3);
    int qbasej = j - (j%3);

    for (int k=0; k<limitNine; k++) {
        int n = v[i][k];
        if (n!=0 && hmap[n]) {
            return false;
        }
        hmap[n]=true;
        n = v[k][j];
        if (n!=0 && vmap[n]) {
            return false;
        }
        vmap[n]=true;
        n = v[qbasei + (k%3)][qbasej + (int)(k/3)];
        if (n!=0 && qmap[n]) {
            return false;
        }
        qmap[n]=true;
    }
    return true;
}

public void dump(int [][] v)
    throws Exception
{
    count++;
    if (count>20) {
        return;
    }
    if (count==20) {
        oout.write("Suppressing more than 20 solutions");
        return;
    }
    oout.write("Solution "+count+" is: \n<table>");
    for (int i=0; i<9; i++) {
        if ((i%3)==0) {
            oout.write("<tr align=\"center\"><td> + </td><td>----</td><td>----</td><td>----</td>"+
                       "<td> + </td><td>----</td><td>----</td><td>----</td>"+
                       "<td> + </td><td>----</td><td>----</td><td>----</td></tr>");
        }
        oout.write("<tr align=\"center\">");
        for (int j=0; j<9; j++) {
            if ((j%3)==0) {
                oout.write("<td> | </td>");
            }
            oout.write("<td>"+v[i][j]+"</td>");
        }
        oout.write("<td> | </td></tr>");
    }
            oout.write("<tr align=\"center\"><td> + </td><td>----</td><td>----</td><td>----</td>"+
                       "<td> + </td><td>----</td><td>----</td><td>----</td>"+
                       "<td> + </td><td>----</td><td>----</td><td>----</td><td> + </td></tr>");
    oout.write("</table>\n");

}

%>