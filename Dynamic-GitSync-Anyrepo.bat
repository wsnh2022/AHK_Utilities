@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Capture start time
set START_TIME=%TIME%

:: Get remote URL and extract repo path (works for both HTTPS and SSH)
for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do set REMOTE_URL=%%i

:: Strip HTTPS prefix
set REPO_PATH=%REMOTE_URL:https://github.com/=%

:: Strip SSH prefix
set REPO_PATH=%REPO_PATH:git@github.com:=%

:: Strip trailing .git if present
if "%REPO_PATH:~-4%"==".git" set REPO_PATH=%REPO_PATH:~0,-4%

:: Extract repo name
for /f "tokens=2 delims=/" %%i in ("%REPO_PATH%") do set REPO_NAME=%%i

set ACTIONS_URL=https://github.com/%REPO_PATH%/actions
set LOG_FILE=%~dp0deploy-log.txt

echo.
echo ========================================
echo   🚀 Deploying %REPO_NAME% to GitHub
echo ========================================
echo.

:: Fetch remote state without merging
echo Checking remote for updates...
git fetch origin >nul 2>&1

:: Count commits remote has that local doesn't
for /f %%i in ('git rev-list HEAD..origin/main --count 2^>nul') do set REMOTE_AHEAD=%%i

:: Count commits local has that remote doesn't
for /f %%i in ('git rev-list origin/main..HEAD --count 2^>nul') do set LOCAL_AHEAD=%%i

if not defined REMOTE_AHEAD set REMOTE_AHEAD=0
if not defined LOCAL_AHEAD set LOCAL_AHEAD=0

:: If remote has new commits, pull first
if %REMOTE_AHEAD% gtr 0 (
    echo Remote has %REMOTE_AHEAD% new commit(s^). Pulling first...
    git pull origin main
    if %ERRORLEVEL% neq 0 (
        echo.
        echo ========================================
        echo   ❌ Pull failed. Resolve conflicts manually.
        echo ========================================
        echo.
        call :write_log "FAILED" "Pull failed - merge conflict" "N/A"
        pause
        exit /b 1
    )
    echo Pull successful.
    echo.
)

:: Clean up ignored files from tracking
echo Cleaning up ignored files from tracking...
git rm -r --cached . >nul 2>&1

:: Suppress LF/CRLF warnings
git config core.autocrlf true

:: Stage all local changes
echo Staging local changes...
git add -A 2>nul

:: Check if there is anything to commit
git diff --cached --quiet
if %ERRORLEVEL% equ 0 (
    if %LOCAL_AHEAD% equ 0 (
        echo.
        echo ========================================
        echo   ✅ Already in sync. Nothing to deploy.
        echo ========================================
        echo.
        call :write_log "SKIPPED" "Already in sync" "N/A"
        pause
        exit /b 0
    )
    goto :push
)

:: Capture diff stat for log
for /f "delims=" %%i in ('git diff --cached --stat --no-color 2^>nul ^| findstr "changed"') do set DIFF_SUMMARY=%%i

:: Generate commit message from changed file names
for /f "delims=" %%i in ('git diff --cached --name-only 2^>nul') do (
    if not defined FIRST_FILE set FIRST_FILE=%%i
    set /a FILE_COUNT+=1
)
if not defined FILE_COUNT set FILE_COUNT=0
if not defined FIRST_FILE set FIRST_FILE=files

if %FILE_COUNT% equ 1 (
    set AUTO_COMMIT=Update %FIRST_FILE%
) else (
    set AUTO_COMMIT=Update %FIRST_FILE% and %FILE_COUNT% file(s^)
)

echo Commit: %AUTO_COMMIT%
echo.
git commit -m "%AUTO_COMMIT%"

:push
:: Push to remote
echo Pushing to GitHub...
git push origin main
set PUSH_RESULT=%ERRORLEVEL%

if %PUSH_RESULT% equ 0 (
    call :write_log "SUCCESS" "!AUTO_COMMIT!" "!DIFF_SUMMARY!"
    echo.
    echo ========================================
    echo   ✅ Success! %REPO_NAME% is live.
    echo   Commit: !AUTO_COMMIT!
    echo   Check %ACTIONS_URL%
    echo   Log saved to deploy-log.txt
    echo ========================================
) else (
    call :write_log "FAILED" "Push failed" "!DIFF_SUMMARY!"
    echo.
    echo ========================================
    echo   ❌ Push failed. Check your connection
    echo   or branch permissions.
    echo ========================================
)

echo.
pause
exit /b

:: Log Writer Subroutine
:write_log
set END_TIME=%TIME%

for /f "tokens=1-4 delims=:,. " %%a in ("%START_TIME%") do (
    set /a SH=%%a, SM=%%b, SS=%%c, SCS=%%d
)

for /f "tokens=1-4 delims=:,. " %%a in ("%END_TIME%") do (
    set /a EH=%%a, EM=%%b, ES=%%c, ECS=%%d
)

set /a ELAPSED=(EH-SH)*3600 + (EM-SM)*60 + (ES-SS)

echo. >> "%LOG_FILE%"
echo ================================================ >> "%LOG_FILE%"
echo DATE       : %date% >> "%LOG_FILE%"
echo START TIME : %START_TIME% >> "%LOG_FILE%"
echo END TIME   : %END_TIME% >> "%LOG_FILE%"
echo ELAPSED    : %ELAPSED% seconds >> "%LOG_FILE%"
echo REPO       : %REPO_NAME% >> "%LOG_FILE%"
echo STATUS     : %~1 >> "%LOG_FILE%"
echo COMMIT MSG : %~2 >> "%LOG_FILE%"
echo CHANGES    : %~3 >> "%LOG_FILE%"
echo REMOTE URL : %ACTIONS_URL% >> "%LOG_FILE%"
echo ================================================ >> "%LOG_FILE%"
exit /b