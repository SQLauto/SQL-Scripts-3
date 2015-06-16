@ECHO OFF
SETLOCAL

REM **************************************************************************************************
REM	Variable Definitions
REM
REM	SQLSERVER 		= Destination SQL Server
REM	DB	  		    = Database (typically nsdb)	
REM	SRC			    = Fully qualified path to folder containing the file(s) to import
REM	BIN			    = Fully qualified path to nsImport.cmd
REM	bArchive		= [True|False] Flag indicating whether files should be archived
REM	bArchiveFolders	= [True|False] If True, a new folder will be created each day to hold archived files.
REM					    Should be used if the source file names aren't guaranteed to be unique
REM	filename		= Name of the file to import.  Set filename = * if you wish to process *any* file 
REM					    in the src folder.  Use of the wildcard '*' is required unless you are 
REM					    expecting a specific filename.  e.g.  filename=*.csv will process all files
REM					    with the .csv extension.
REM 
REM FormatFile		= Name of the format file describing the destination table.
REM 
REM **************************************************************************************************

SET SQLSERVER=TORO
SET DB=SYNCRONEX_SUPPORT
SET DBUSER=sa
SET DBPASS=shorthorse!
SET bin=C:\Progra~1\Syncronex\Support\IISLogs
SET src=C:\Progra~1\Syncronex\Support\IISLogs
SET filename=ex*.log
SET FormatFile=bcp.fmt

ECHO Process started...
ECHO    Checking for valid paths...
IF NOT EXIST %src% ( 
	ECHO    Source folder %src% does not exist.  Process aborting... 
	GOTO ProcessFailed
)
	
IF NOT EXIST %bin% ( 
	ECHO    Bin folder %bin% does not exist.  Process aborting... 
	GOTO ProcessFailed
) ELSE (
	PUSHD %bin%
)	

IF NOT EXIST %bin%\err (
	ECHO    Creating folder %bin%\err...
	MD %bin%\err
)	

IF NOT EXIST %bin%\%FormatFile% (
	ECHO    Error format file does not exist.  
	GOTO ProcessFailed
)	


ECHO    Processing file(s)...

IF NOT EXIST %src%\%filename% ( 
	ECHO    Warning: No file found at this time.
	GOTO Done 
)

FOR %%F IN (%src%\%filename%) DO CALL bcp.cmd %%~fF || GOTO ProcessingError

GOTO Done

	
:Done	
REM ***************************************************************************
REM		Processing Complete.  Exit gracefully.
REM ***************************************************************************
	ECHO Process completed successfully!
	OSQL -S %SQLSERVER% -U %DBUSER% -P %DBPASS% -d %DB% -Q "SET NOCOUNT ON EXEC nsSystemLogInsert 1,0,'Process completed successfully!'"
	POPD
	EXIT /B 0

:ProcessingError
REM ***************************************************************************
REM		Error while process files...
REM ***************************************************************************
ECHO An error occurred while processing files!
OSQL -S %SQLSERVER% -U %DBUSER% -P %DBPASS% -d %DB% -Q "SET NOCOUNT ON EXEC nsSystemLogInsert 1,0,'Errors occurred while processing files!'"
GOTO ProcessFailed
EXIT /B 1

:ProcessFailed
REM ***************************************************************************
REM		Process failed!!!
REM ***************************************************************************
ECHO Process Failed!!!
REM ECHO Check %err% for details.
OSQL -S %SQLSERVER% -U %DBUSER% -P %DBPASS% -d %DB% -Q "SET NOCOUNT ON EXEC nsSystemLogInsert 1,0,'Process failed!!!'"
POPD
EXIT /B 1
	
