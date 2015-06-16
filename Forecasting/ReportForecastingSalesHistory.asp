<%@ Language=VBScript %>
<%
'*****************************************************************************
'	ReportVariableDaysBack.asp - Created 6/28/2007 by kerry
'
'	Displays which VDB settings would be applied for a given AcctType and Pub.
'	Allows a user to test the settings for for a specific date.
'
'	Change History
'	-------------------------------------------------------------------------
'	$History: $
'	
'*****************************************************************************
Option Explicit
Server.ScriptTimeout = 300
%>
<!--#INCLUDE FILE="./Scripts/VBS/Globals.vbs"-->
<!--#INCLUDE FILE="./Scripts/VBS/Security.vbs"-->
<!--#INCLUDE FILE="./Scripts/VBS/Session.vbs"-->
<!--#INCLUDE FILE="./Scripts/VBS/ReportMaintenance.vbs"-->
<!--#INCLUDE FILE="./Scripts/VBS/RouteMaintenance.vbs"-->
<!--#INCLUDE FILE="./Scripts/VBS/PubMaintenance.vbs"-->
<!--#INCLUDE FILE="./Scripts/VBS/DBConnection.vbs"-->
<!--#INCLUDE FILE="./Scripts/VBS/DBRecordset.vbs"-->

<%
Response.Expires = -1

'==========================================================
'	Set the security level for this page/user
'==========================================================
Sub SetSecurity()
	Select case AuthorizeReporting()
		case ACCESS_READ
			m_bReadOnly = true
		case ACCESS_wRITE,ACCESS_READWRITE
			m_bReadOnly = false
		case else 'ACCESS_NONE or DENIED...
			' No access...Redirect out of here...
			Call Response.Redirect("AccessDenied.asp")
	end select
End Sub


'==========================================================
'	Main
'==========================================================
const ADPARAMETERINPUT = 1

Dim m_bReadOnly
Dim oCn
Dim oCd
Dim oRs
Dim fld


Dim cbWidth

if( timeout ) then
	Response.Redirect TIMEOUT_TARGET
end if

Call SetSecurity
cbWidth = 200

%>
<html>
<head>
	<title>Report - Sales History/Forecasting</title>
	<link rel="stylesheet" type="text/css" href="./Stylesheets/Report.css"></link>
	<link rel="stylesheet" type="text/css" href="./Stylesheets/nsGeneral.css">
	<link rel="stylesheet" type="text/css" href="./Stylesheets/calendar.css"></LINK>
	<script language="jscript" src="./scripts/choosedate.js"></script>
</head>
<body>
<table style="width: 800px;" >
	<tr>
		<td class=ReportTitle>Report - Sales History</td>
	</tr>
	<tr>
		<td class=ReportDescription style="width: 100%; visibility:hidden;">
			<table>
				<tr>
					<td style="border: none; vertical-align: middle; padding-bottom: 10px;">Sales History
					</td>
				</tr>
			</table>
		</td>
	</tr>			
</table>
<form action="<%=Request.ServerVariables("SCRIPT_NAME")%>" method="get" id="frmParams" name="frmParams">
<%

	Dim sDate
	sDate = Request.QueryString("Date")
	if(Not(isDate(sDate))) then
		sDate = cDate(FormatDateTime(now(),2))
	else
		sDate = cDate(sDate)
	end if

	Dim sAcct
	sAcct = Request.QueryString("Acct")
	
	Dim sPub
	sPub = Request.QueryString("Pub")
	
	Dim sMfst
	sMfst = Request.QueryString("Mfst")
	
	Response.Write ""
%>
<table class="param">
    <tr>
	    <td class=ParamTitle colspan=3>Forecasting Sales History Report Parameters</td>
    </tr>
	<tr>
	    <td class="paramLabel">Draw Date</td>
	    <td><img src="./images/trans1x1.gif" width=10 height=20></td>
		<td>
			<input type="text" id="Date" size="15" maxlength="15" NAME="Date" value="<%=sDate%>" />
			<script type="text/javascript" language="javascript"> stdDatePicker("frmParams.Date"); </script>
		</td>	
	</tr>
	<tr>
	    <td class="paramLabel">Mfst</td>
	    <td><img src="./images/trans1x1.gif" width=10 height=20></td>
		<td>
		    <input type="text" id="Mfst" size="20" maxlength="20" NAME="Mfst" value="<%=sMfst%>" />
        </td>		    
	</tr>	
	<tr>
	    <td class="paramLabel">Acct</td>
	    <td><img src="./images/trans1x1.gif" width=10 height=20></td>
		<td>
		    <input type="text" id="Acct" size="20" maxlength="20" NAME="Acct" value="<%=sAcct%>" />
        </td>		    
	</tr>
	<!--<tr>
	    <td class="paramLabel">Pub</td>	
	    <td><img src="./images/trans1x1.gif" width=10 height=20></td>
	    <td>
            <input type="text" id="Pub" size="5" maxlength="5" NAME="Pub" value="<%=sPub%>" />
	    </td>
	</tr>-->
<tr>
	<td class="paramLabel" title="Publication">Pub:</td>
	<td><img src="./images/trans1x1.gif" width=10 height=20></td>
	<td><%= GenericListBox("Pub",1,GetPubList,-1,true,false,175,false,false) %> </td>

</tr>

	<tr>
	    <td colspan=3 style="text-align:right;">
	    <input type="submit" value="Submit" id="submit1" name="submit1" />	    
	    <input type=reset  value="Reset" id=reset1 name=reset1>
	    </td>
	</tr>	
</table>
<%
If Request.QueryString("submit1") = "Submit" Then

        const ARG_DATE		= "@drawDate"
        const ARG_ACCT		= "@acct"
        const ARG_PUB		= "@pub"
        const ARG_MFST		= "@mfst"
        const ARG_MANIFESTTYPE = "@manifestType"
        
	    Set oCn = OpenDefaultConnection()

	    Set oCd = Server.CreateObject("ADODB.Command")
	    Set oCd.ActiveConnection = oCn
	    oCd.CommandType = adCmdStoredProc 					' 4 = stored procedure
        oCd.CommandTimeout = 300
        
	    oCd.CommandText = "scReports_ForecastingSalesHistory"
	    Call oCd.Parameters.Append( oCd.CreateParameter(ARG_DATE,ADDATE,ADPARAMETERINPUT) )
	    Call oCd.Parameters.Append( oCd.CreateParameter(ARG_ACCT,ADVARWCHAR,ADPARAMETERINPUT,20) )
	    Call oCd.Parameters.Append( oCd.CreateParameter(ARG_PUB,ADVARWCHAR,ADPARAMETERINPUT,5) )
	    Call oCd.Parameters.Append( oCd.CreateParameter(ARG_MFST,ADVARWCHAR,ADPARAMETERINPUT,20) )
	    Call oCd.Parameters.Append( oCd.CreateParameter(ARG_MANIFESTTYPE,ADVARWCHAR,ADPARAMETERINPUT,80) )
    	
	    oCd.Parameters(0).Value = sDate
        Call SetNewNullableParm(oCd.Parameters(ARG_ACCT),sAcct,NULL_VALUE)
	    Call SetNewNullableParm(oCd.Parameters(ARG_PUB),sPub,NULL_VALUE)
	    Call SetNewNullableParm(oCd.Parameters(ARG_MFST),sMfst,NULL_VALUE)
	    oCd.Parameters(4).Value = "Delivery"
    	
	    Set oRS = oCd.Execute()

	    Response.Write "<div class=paramSummary>"
	    Response.Write "</div>"
    	
	    'If (oRs.eof) Then
	    '	Response.Write "<div class=Warning>No Results</div>"
	    '	Response.End
	    'End If
    	
	    Response.Write "<table class=Results style='behavior:url(./scripts/sort.htc) url(./scripts/rowHighlight.htc);' hlcolor='lightsteelblue' slcolor=''>"
	    Response.Write "<thead><tr>"

	    For Each fld in oRs.Fields
		    'Response.Write "<th style=""text-align: center;"">" & fld.name & "</th>"
		    Response.Write "<th style=""vertical-align: middle;"">" & fld.name & "</th>"
	    Next
	    Response.Write "</tr></thead>"
	    Response.Write "<tbody>"

	    Do While Not (oRs.eof)
		    'Write the data to the table
		    Response.Write "<tr>"

	        For Each fld in oRs.Fields
			    if fld.Value <> "" then	
				    Response.Write "<td class=Result>" & fld.Value & "</td>"
			    else
				    Response.Write "<td class=Result>&nbsp;</td>"
			    end if	
		    Next

		    Response.Write "</tr>"
		    oRs.MoveNext
	    Loop
	    Response.Write "</tbody>"
	    Response.Write "</table>"
    End If	    
%>
</form>
</body>
</html>	
