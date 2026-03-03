# Gemini CLI — Integration Attempt & Removal

**Environment:** Windows 11, PowerShell 7.5.4, Node v22.22.0
**Gemini CLI Version:** 0.30.0
**Date Investigated:** February 2026

---

## Summary

Gemini CLI was integrated into the git push script to generate AI-based commit messages. After investigation, the integration was removed and replaced with a deterministic time-based commit message. This document records why.

---

## What Was Attempted

Pipe `git diff --cached --stat` into Gemini CLI to generate a human-readable commit message on every push:

```bat
for /f "delims=" %%i in ('git diff --cached --stat 2^>nul ^| gemini -p "Write a concise Git commit message..."') do (
    if not defined AI_COMMIT set AI_COMMIT=%%i
)
```

---

## Issues Encountered

### Issue 1 — Startup Latency: 12–55 seconds

```powershell
Measure-Command { echo test | gemini -p "say hello" }
→ TotalSeconds: 47.169
```

Root cause: Gemini CLI 0.30.0 uses ES Modules (`"type": "module"`) with a 617-package dependency tree including React 19 and Ink. Cold-start on Windows is 12–14 seconds minimum regardless of hooks, PATH, or Node version. Total push time with Gemini: 40–80 seconds.

Investigated and ruled out: nvm-windows overhead, MCP server hooks, invalid hook event names, update check network calls, `.cmd` wrapper overhead. None reduced startup time.

---

### Issue 2 — stdin Piping Does Not Work with `-p`

Gemini CLI's `-p` flag does not receive piped stdin content. The diff was never reaching the model. Confirmed by inspecting the raw API request body — `contents` array contained only the session context, not the diff.

Attempted fix: write diff to temp file, read in PowerShell, POST directly to Gemini REST API.

---

### Issue 3 — Inline PowerShell Escaping in CMD

```bat
for /f "delims=" %%i in ('powershell -NoProfile -Command ^
    "$diff = ... -replace '\"','\\\"' ..."
') do (...)
```

CMD's quote and escape rules corrupt PowerShell syntax at char 187. The PS1 was generating `At line:1 char:187` errors instead of commit messages.

Attempted fix: write a static `.ps1` file and call it with `-File` to bypass CMD escaping entirely.

---

### Issue 4 — API Quota: 0 Available on Gemini 2.0 Flash

```
Model           RPM    TPM    RPD
Gemini 2.0 Flash  0/0    0/0    0/0
```

The `generativelanguage.googleapis.com` free tier showed zero quota for `gemini-2.0-flash` on this account. The Gemini CLI uses a separate backend (`cloudcode-pa.googleapis.com` — Google Code Assist) which has its own undocumented rate limits and hit 429 under repeated testing.

---

### Issue 5 — Agentic Responses Instead of Commit Messages

Even when the API call succeeded, the model occasionally returned explanation prose instead of a commit message:

```
I will analyze the diff and write a commit message for you...
```

Required a secondary `findstr` filter to detect and reject these, adding fragility.

---

## Decision

All five issues compound. The integration added 40–80 seconds of latency, two external dependencies (Gemini CLI + API), quota risk, and multiple failure modes — for a commit message that is cosmetically nicer but carries no structural value.

**Removed entirely. Replaced with:**

```bat
for /f "tokens=1-3 delims=/-" %%a in ("%date%") do (
    set DD=%%a& set MM=%%b& set YYYY=%%c
)
for /f "tokens=1-2 delims=:." %%a in ("%time: =0%") do (
    set HH=%%a& set MIN=%%b
)
set COMMIT_TIME=%YYYY%-%MM%-%DD% %HH%:%MIN%

for /f "delims=" %%i in ('git diff --cached --name-only 2^>nul') do (
    if not defined CHANGED_FILES (set CHANGED_FILES=%%i) else (set CHANGED_FILES=%CHANGED_FILES%, %%i)
)

set COMMIT_MSG=%REPO_NAME% — %COMMIT_TIME% — %CHANGED_FILES%
```

**Output:**
```
wsnh_portfolio — 2026-02-27 14:05 — index.html, README.md
```

Zero dependencies. Zero latency. Zero failure modes. Total push time: 5–10 seconds.

---

## Environment Reference

| Component | Value |
|---|---|
| OS | Windows 11 |
| Shell | PowerShell 7.5.4 |
| Node.js | v22.22.0 |
| Gemini CLI | @google/gemini-cli 0.30.0 |
| Gemini startup time | 12–14 seconds (cold) |
| Full push time with Gemini | 40–80 seconds |
| Full push time without Gemini | 5–10 seconds |

---

*Investigation log — archived for reference.*
