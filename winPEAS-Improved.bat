@ECHO OFF
SETLOCAL EnableDelayedExpansion
TITLE WinPEAS - Windows Local Privilege Escalation Script
COLOR 0F
CALL :SetOnce

REM :: WinPEAS - Windows Local Privilege Escalation Awesome Script
REM :: Optimized and Improved by Limn0

SET long=false

REM Check if the current path contains spaces
SET "CurrentFolder=%~dp0"
IF "%CurrentFolder%" NEQ "%CurrentFolder: =%" (
    ECHO winPEAS.bat cannot run if the current path contains spaces.
    EXIT /B 1
)

:Splash
ECHO.
CALL :ColorLine "            %E%32m((,.,/((((((((((((((((((((/,  */%E%97m"
CALL :ColorLine "     %E%32m,/*,..*(((((((((((((((((((((((((((((((((,%E%97m"              
CALL :ColorLine "   %E%32m,*/((((((((((((((((((/,  %E%92m.*//((//**,%E%32m .*((((((*%E%97m"
ECHO.
ECHO.                       by carlospolop
ECHO.
ECHO.

:Advisory
ECHO Advisory: WinPEAS - Windows Local Privilege Escalation Script
CALL :ColorLine "   %E%41mWinPEAS should be used for authorized penetration testing and/or educational purposes only.%E%40;97m"
CALL :ColorLine "   %E%41mAny misuse of this software will not be the responsibility of the author or any collaborator.%E%40;97m"
CALL :ColorLine "   %E%41mUse it on authorized networks only.%E%40;97m"
ECHO.

:SystemInfo
CALL :ColorLine "%E%32m[*]%E%97m BASIC SYSTEM INFO"
CALL :ColorLine " %E%33m[+]%E%97m WINDOWS OS"
ECHO.   [i] Check for vulnerabilities for the OS version with the applied patches
ECHO.   [?] https://book.hacktricks.xyz/windows-hardening/windows-local-privilege-escalation#kernel-exploits
systeminfo
CALL :ProgressUpdate 2

:ListHotFixes
CALL :CheckHotFixes

:BasicUserInfo
CALL :ColorLine "%E%32m[*]%E%97m BASIC USER INFO"
CALL :DisplayBasicUserInfo
CALL :ProgressUpdate 2

:NetworkShares
CALL :ColorLine "%E%32m[*]%E%97m NETWORK"
CALL :ColorLine " %E%33m[+]%E%97m CURRENT SHARES"
net share
CALL :ProgressUpdate 2

:CheckRunningProcesses
CALL :ColorLine " %E%33m[+]%E%97m RUNNING PROCESSES"
tasklist /SVC
CALL :CheckPermissions
CALL :ProgressUpdate 3

:RunAtStartup
CALL :ColorLine " %E%33m[+]%E%97m RUN AT STARTUP"
CALL :CheckRunAtStartup

:: -- More checks below as per your original script structure --

:Completion
ECHO.---
ECHO.Scan complete.
PAUSE >NUL 
EXIT /B

:: Subroutines

:SetOnce
SET "E=0x1B["
SET "PercentageTrack=0"
EXIT /B

:ProgressUpdate
SET "Percentage=%~1"
SET /A "PercentageTrack+=Percentage"
TITLE WinPEAS - Scanning... !PercentageTrack!%%
EXIT /B

:ColorLine
SET "CurrentLine=%~1"
FOR /F "delims=" %%A IN ('FORFILES.EXE /P %~dp0 /M %~nx0 /C "CMD /C ECHO.!CurrentLine!"') DO ECHO.%%A
EXIT /B

:CheckHotFixes
CALL :ColorLine "%E%33m[+]%E%97m Checking Installed Hotfixes"
wmic qfe get Caption,Description,HotFixID,InstalledOn | more
EXIT /B

:CheckPermissions
ECHO Checking file and directory permissions of running processes...
FOR /F "tokens=2 delims='='" %%x IN ('wmic process list full ^|find /i "executablepath"^|find /i /v "system32"^|find ":"') DO (
    FOR /F eol^=^"^ delims^=^" %%z IN ('ECHO.%%x') DO (
        icacls "%%z" 2>nul | findstr /i "(F) (M) (W) :\\" | findstr /i ":\\ everyone authenticated users todos %username%" && ECHO.
    )
)
EXIT /B

:DisplayBasicUserInfo
ECHO Checking current user and group information...
net user %username%
net localgroup
EXIT /B

:CheckRunAtStartup
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run 2>nul
EXIT /B