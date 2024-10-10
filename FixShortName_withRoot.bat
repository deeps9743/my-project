@echo off
setlocal enabledelayedexpansion

REM Convert current directory to Windows-style path
for /f "delims=" %%i in ('cd') do set "CURRENT_DIR=%%i"

REM Set the module path from the first argument
set MODULE_PATH=%1
set "status=NA"

if "%MODULE_PATH%"=="" (
  echo.
  echo Usage: %0 "<MODULE_ROOT>"
  echo.
  exit /b 1
)

REM Assign the XSLT file and Saxon JAR path
set XSLT_FILE=%CURRENT_DIR%\shortname.xsl
set SAXON_JAR=%CURRENT_DIR%\saxon-he-12.5.jar

REM Define the file extensions to search for
set extensions=epc epc.m4 asc arxml arxml.m4
set "fileCount=0"
set "MESSAGES="
	
set "TEMP_FILE=%TEMP%\xmlstarlet_output.txt"

REM Process each directory and its files
echo.
echo -------------------------------------------------------------------------------------------------
echo Conditional SHORT-NAME changes: %MODULE_PATH% 
echo =================================================================================================
echo.
echo Searching to perform conditional changes on test input files ...

REM Call the function to process files
call :ProcessFiles

REM Clean up the temporary file
del "%TEMP_FILE%"

echo.
echo Total files modified: %fileCount%
REM Output the total number of files modified
echo -------------------------------------------------------------------------------------------------
echo.

REM End of script
goto :eof

:ProcessFiles
if exist "%MODULE_PATH%\test" (
	call :ProcessModule "%MODULE_PATH%\test"
) else (
    REM Iterate through the specified extensions
	for /d %%L in ("%MODULE_PATH%\*") do (
		rem Loop through the immediate subdirectories of each first-level subdirectory
		for /d %%D in ("%%L\*") do (
			if /i "%%~nxD"=="test" (
				call :ProcessModule "%%D"
			)
		)
	)
)

exit /b

:ProcessModule
set "filepath=%~1"
for %%e in (%extensions%) do (
    REM Recursively search for files with the given extension
    for /r %filepath% %%f in (*%%e) do (
        call :ProcessFile "%%f"
    )
)
exit /b

:ProcessFile
set "filepath=%~1"
set "dirpath=%%~dp1"
set "dirpath=!dirpath:~0,-1!"
set "filename=%%~nxf"



REM Run XMLStarlet and check output
xml.exe sel -N "a=http://autosar.org/schema/r4.0" -t ^
    -m "//a:ECUC-CONTAINER-VALUE[a:DEFINITION-REF/@DEST='ECUC-CHOICE-CONTAINER-DEF']" ^
    -m "a:SUB-CONTAINERS/a:ECUC-CONTAINER-VALUE[a:DEFINITION-REF/@DEST='ECUC-PARAM-CONF-CONTAINER-DEF' and not(a:SHORT-NAME=../../a:SHORT-NAME) and concat('/', a:SHORT-NAME)=substring(a:DEFINITION-REF, string-length(a:DEFINITION-REF) - string-length(a:SHORT-NAME))]" ^
    -nl -o "     Container: " -v "a:SHORT-NAME" -o " renamed to " -v "../../a:SHORT-NAME" ^
    -o " of DEFINITION-REF: " -v "a:DEFINITION-REF" ^
    -nl "%filepath%" > "%TEMP_FILE%" 2>nul 

REM Check if the output file is empty
if exist "%TEMP_FILE%" ( 
	set "temp="

    for /f "delims=" %%a in ('type "%TEMP_FILE%"') do (
      if not "%%a"=="" (
		for %%f in ("%filepath%") do set "filename=%%~nxf"
          REM Compare file path with temp
          if not "!temp!"=="%filename%" (
			  echo.
              echo %filepath%
              set "temp=%filename%"
			  set /a fileCount+=1
          )
		echo %%a
        REM Apply XSLT transformation using Saxon (if needed)
        java -jar "%SAXON_JAR%" -xsl:"%XSLT_FILE%" -s:"%filepath%" -o:"%filepath%"
      )
    )
)
exit /b

