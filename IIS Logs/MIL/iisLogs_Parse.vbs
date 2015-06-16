Option Explicit

'--||	Arguments:
'--||		srcFile		= Fully qualified path to the manifest file from PBS 

'Variables
	const ForReading = 1
	const ForWriting = 2
	const AdVarChar = 200
	const AdInteger = 3
	const AdParamInput = 1
	
	dim msg
	dim lSeverity
	dim lCompanyID
	
	lCompanyID = 1
		
	dim blnWriteLine
	
	dim i
	dim srcFile
	dim tgtFile
	dim args
	
	blnWriteLine = true
	
	set args = WScript.Arguments

	srcFile = args(0)
	tgtFile = srcFile & ".parsed"
	
	'msgbox( "srcFile=" & srcFile & ", sTgtPath=" & sTgtPath & ", sDataSource=" & sDataSource & ", sCatalog=" & sCatalog & ", sUser=" & sUser & ", sPass=" & sPass )

	
'************************************************************************
'		Check the argurments
'************************************************************************
	if srcFile = "" then
		WScript.Quit 1
	end if	

'Initialize File System Object
	dim fso
	dim flcontents
	dim tsread	'TextStreamObject
	dim tswrite
	
	set fso = CreateObject("Scripting.FileSystemObject")

	'Get folder contents
	
	'Read the file
	set tsread = fso.OpenTextFile( srcFile,ForReading )

	'Create the parsed output file
	set tswrite = fso.CreateTextFile( tgtFile, true)
	
	while not ( tsread.AtEndOfStream )
		'Read Line
		flcontents = tsread.ReadLine

		'Parse Line
		if left(flcontents,1) = "#" then
			'Write Line
		Else	
			tswrite.WriteLine(flcontents)
		End If
	wend

	tsread.close
	tswrite.close

