; ============================================
; AHK_LatestVersionLauncher — AHK v2 Template
; Purpose : Dynamically resolves and runs the highest
;           versioned exe matching a given name pattern.
; Author  : The_Thinker
; Requires: AutoHotkey v2.0+
; ============================================
#SingleInstance Force
#Requires AutoHotkey v2.0+

; ── CONFIG ───────────────────────────────────
; Set the directory and wildcard pattern for each exe you want to resolve.
; Pattern supports standard AHK Loop Files wildcards.
; Examples:
;   "MyApp*.exe"         → matches MyApp-1.2.0.exe, MyApp 2.0.1-beta.exe
;   "PopSearch*.exe"     → matches PopSearch Beta Setup 1.2.0-beta.exe
APP_DIR     := "C:\path\to\your\app\folder"   ; folder containing versioned exes
APP_PATTERN := "YourAppName*.exe"             ; wildcard — keep prefix fixed, version floats

; ── RESOLVE ──────────────────────────────────
APP_EXE := ResolveLatestExe(APP_DIR, APP_PATTERN)

if (APP_EXE = "")
    MsgBox("No matching exe found in:`n" APP_DIR "`n`nCheck folder or pattern.", "Startup Error", 16), ExitApp()

; ── RUN ──────────────────────────────────────
try {
    Run(APP_EXE)
} catch as e {
    MsgBox("Failed to run:`n" APP_EXE "`n`nError: " e.Message, "Launch Error", 16)
}

; ── FUNCTIONS ────────────────────────────────

; Scans dir for files matching pattern.
; Returns full path of the highest versioned match.
; Returns empty string if no match found — caller must handle.
ResolveLatestExe(dir, pattern) {
    best_path := ""
    best_ver  := ""
    Loop Files dir "\" pattern
    {
        ; version must follow a space, dash, underscore, or "v" — prevents grabbing digits from app name
        if RegExMatch(A_LoopFileName, "(?<=[\s\-\_v])(\d[\d.]+)", &m)
        {
            ver := RegExReplace(m[], "-.*$", "")               ; strip suffix e.g. -beta, -rc1, -portable
            if (best_path = "" || CompareVersions(ver, best_ver) > 0)
            {
                best_ver  := ver
                best_path := A_LoopFileFullPath                ; keep highest version found so far
            }
        }
    }
    return best_path
}

; Returns 1 if a > b, -1 if a < b, 0 if equal.
; Compares dot-separated version strings numerically per segment.
; Handles arbitrary depth and leading zeros e.g. 01.3.001 vs 1.3.1
CompareVersions(a, b) {
    a_parts := StrSplit(a, ".")
    b_parts := StrSplit(b, ".")
    loop Max(a_parts.Length, b_parts.Length)
    {
        av := (A_Index <= a_parts.Length) ? Integer(a_parts[A_Index]) : 0   ; missing segment treated as 0
        bv := (A_Index <= b_parts.Length) ? Integer(b_parts[A_Index]) : 0
        if (av > bv)
            return 1
        if (av < bv)
            return -1
    }
    return 0
}
