# AHK_LatestVersionLauncher

An AutoHotkey v2 utility that scans a directory, extracts version strings from matching filenames, and returns the full path of the latest versioned executable. Intended for use in launcher scripts where the target executable filename changes with each build.

---

## Motivation

Every time a new build dropped, I had to manually update the file path in my launcher script to point to the latest version. Doing that repeatedly got old fast. So I wrote this to handle it automatically.

---

## Requirements

- Windows
- AutoHotkey v2.0+

---

## How It Works

1. `Loop Files` scans the target directory using a wildcard pattern.
2. A regex extracts the version string from each matching filename. The version must follow a space, dash, underscore, or the letter `v`.
3. Version segments are compared numerically per segment. Leading zeros are normalized.
4. The full path of the highest versioned match is returned.

---

## Supported Filename Formats

| Filename | Extracted Version | Result |
|---|---|---|
| `AppName 1.2.0.exe` | `1.2.0` | supported |
| `AppName-1.2.0.exe` | `1.2.0` | supported |
| `AppName_1.2.0.exe` | `1.2.0` | supported |
| `AppName v1.2.0.exe` | `1.2.0` | supported — `v` treated as separator |
| `AppName 1.2.0-beta.exe` | `1.2.0` | supported — suffix stripped |
| `AppName 1.2.0-beta-portable.exe` | `1.2.0` | supported — full suffix stripped |
| `AppName 1.2.0-rc1.exe` | `1.2.0` | supported — suffix stripped |
| `AppName 01.30.01.exe` | `1.30.1` | supported — leading zeros normalized |
| `AppName 1.3.exe` | `1.3` | supported — two-segment version |
| `AppName 2.0.0.0.exe` | `2.0.0.0` | supported — four-segment version |
| `AppName 01.30.01-beta-portable.exe` | `1.30.1` | supported — leading zeros and suffix both handled |
| `AppName2 1.2.0.exe` | `1.2.0` | supported — trailing digit in name, version follows space |
| `App2Name 1.2.0.exe` | `1.2.0` | supported — mid digit in name, version follows space |
| `AppName 1.2.0 Setup.exe` | `1.2.0` | supported — trailing text after version ignored |
| `AppName xx.xx.xx.exe` | arbitrary | supported — any segment count, any digit width |
| `2AppName 1.2.0.exe` | none | **not supported** — name starts with digit, no valid separator before version |

---

## Usage

**Single executable:**

```ahk
APP_DIR     := "C:\path\to\folder"
APP_PATTERN := "AppName*.exe"

APP_EXE := ResolveLatestExe(APP_DIR, APP_PATTERN)

if (APP_EXE = "")
    MsgBox("No matching exe found in:`n" APP_DIR, "Error", 16), ExitApp()

try {
    Run(APP_EXE)
} catch as e {
    MsgBox("Failed to run:`n" APP_EXE "`n`nError: " e.Message, "Error", 16)
}
```

**Multiple executables in a launcher array:**

```ahk
POPSEARCH_EXE := ResolveLatestExe("C:\dev\portable_files\popsearch", "PopSearch*.exe")
OTHERTOOL_EXE := ResolveLatestExe("C:\tools\othertool", "OtherTool*.exe")

scripts := [
    "C:\tools\MyScript.ahk",
    POPSEARCH_EXE,
    OTHERTOOL_EXE,
]

for script in scripts {
    try {
        Run(script)
    } catch as e {
        MsgBox("Failed: " script "`n" e.Message, "Error", 16)
    }
    Sleep(200)
}
```

---

## API Reference

### `ResolveLatestExe(dir, pattern)`

Scans `dir` for files matching `pattern`. Returns the full path of the highest versioned match. Returns an empty string if no match is found — the caller is responsible for handling that case.

| Parameter | Type | Description |
|---|---|---|
| `dir` | String | Absolute path to the directory to scan |
| `pattern` | String | `Loop Files` wildcard e.g. `PopSearch*.exe` |

---

### `CompareVersions(a, b)`

Compares two dot-separated version strings numerically per segment.

| Parameter | Type | Description |
|---|---|---|
| `a` | String | Version string e.g. `1.3.01` |
| `b` | String | Version string to compare against |

Returns `1` if `a > b`, `-1` if `a < b`, `0` if equal.

---

## Known Limitations

- Filenames where the app name begins with a digit and has no separator before the version string are not supported.
- If multiple files resolve to the same highest version, the last one iterated by the filesystem is returned. Remove stale builds to avoid ambiguity.
- Non-numeric pre-release identifiers (e.g. `alpha`, `beta`) are stripped entirely before comparison. Two files differing only by pre-release label are treated as equal versions.

---

## Files

```
AHK_LatestVersionLauncher/
├── ResolveLatestExe_Template.ahk
└── README.md
```
