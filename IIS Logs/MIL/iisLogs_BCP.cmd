@ECHO OFF

SETLOCAL

REM	Arg is fully qualified path to the input file...
IF .%1. == .. GOTO usage
SET FileArg=%1

IF NOT EXIST %1 (
	GOTO nofile
)

CALL iisLogs_Parse.vbs %1

REM BCP SYNCRONEX_SUPPORT..IISLogs in %1 -f bcp.fmt -S %SQLSERVER% -U %DBUSER% -P %DBPASS% -e .\err\bcp.err -o .\err\bcp.out
BCP SYNCRONEX_SUPPORT..IISLogs in %1.parsed -f bcp.fmt -S %SQLSERVER% -U %DBUSER% -P %DBPASS% -e .\err\bcp.err -o .\err\bcp.out
findstr /I /C:"Error" .\err\bcp.out >nul && GOTO BCP_ERROR


GOTO done

EXIT /B 1

:nofile
REM **
REM ** input file does not exist...No processing to do
REM **
ECHO No File

EXIT /B 0

:BCP_ERROR
REM **
REM ** Error condition. Return non-zero ret code and log to our LogSystem messages table
REM **
ECHO       BCP ERROR!  See nsLogSystem for more details.

ENDLOCAL
	
EXIT /B 0

:done
REM ** 
REM ** Success condition. Return zero ret code
REM **
ENDLOCAL

EXIT /B 0