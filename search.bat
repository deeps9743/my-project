@echo off
setlocal enabledelayedexpansion

set "MODULE_PATH=%1"

rem Loop through immediate subdirectories
for /d %%L in ("%MODULE_PATH%\*") do (
	echo %%L ... "%%~nxL"
    rem Loop through the immediate subdirectories of each first-level subdirectory
    for /d %%D in ("%%L\*") do (
        if /i "%%~nxD"=="test" (
            echo Found directory: %%D
            rem Example: list the contents of the directory
            dir "%%D"
        )
    )
)

endlocal
