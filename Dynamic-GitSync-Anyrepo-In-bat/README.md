# Dynamic-GitSync-Anyrepo

![Platform](https://img.shields.io/badge/platform-Windows-blue?logo=windows&logoColor=white)
![Shell](https://img.shields.io/badge/shell-Batch%20%28CMD%29-grey?logo=gnubash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)
![Requires Git](https://img.shields.io/badge/requires-Git-orange?logo=git&logoColor=white)

A Windows batch script for one-click GitHub deployments. Drop it in any repo, run it, and it handles the fetch, pull, stage, commit, push, and log — without touching your workflow or requiring any configuration.

---

## 🧩 The Problem It Solves

Most personal projects don't need a CI pipeline. They need a reliable way to push changes without typing the same six git commands every time, forgetting to pull first, or accidentally committing with a blank message.

This script does exactly that — nothing more.

---

## ⚙️ What It Does

- Fetches remote state before touching anything
- Pulls automatically if GitHub is ahead of local (exits cleanly on merge conflict)
- Cleans ignored files out of git tracking, then stages all changes
- Generates a commit message from the names of changed files
- Pushes to `main` and reports the result
- Appends a timestamped log entry to `deploy-log.txt` on every run

---

## 📋 Requirements

| Dependency | Notes |
|---|---|
| Windows 10 / 11 | Batch script — runs in CMD or PowerShell |
| Git (any recent version) | Must be in PATH |

No APIs. No installs. No accounts.

---

## 🚀 Setup

Place the script in the root of any git-tracked folder:

```
your-repo/
├── Dynamic-GitSync-Anyrepo.bat
├── .gitignore
└── ...
```

Add both files to `.gitignore` so they stay local:

```gitignore
Dynamic-GitSync-Anyrepo.bat
deploy-log.txt
```

That's it. No editing required. The script reads the repo name and remote URL from git itself.

---

## ▶️ Usage

Double-click or run from terminal:

```bat
Dynamic-GitSync-Anyrepo.bat
```

---

## 🔁 Flow

```
START
  │
  ├─ Read repo name + Actions URL from git remote (HTTPS or SSH)
  ├─ git fetch origin
  │
  ├─ Remote ahead?
  │     Yes ──► git pull ──► conflict? Exit with message
  │
  ├─ git rm --cached  (clear ignored files from tracking)
  ├─ git add -A
  │
  ├─ Nothing to commit + already in sync?
  │     Yes ──► Exit (logged as SKIPPED)
  │
  ├─ Build commit message from changed file names
  ├─ git commit
  ├─ git push origin main
  │
  ├─ Write log entry
  └─ Print result
```

---

## 💬 Commit Messages

Generated from the file list — no input needed:

| Scenario | Message |
|---|---|
| One file changed | `Update index.html` |
| Multiple files changed | `Update index.html and 3 file(s)` |

---

## 📝 Deploy Log

Each run appends to `deploy-log.txt`:

```
================================================
DATE       : Fri 27-Feb-26
START TIME : 13:04:10.85
END TIME   : 13:04:18.43
ELAPSED    : 8 seconds
REPO       : wsnh_portfolio
STATUS     : SUCCESS
COMMIT MSG : Update index.html and 3 file(s)
CHANGES    : 3 files changed, 28 insertions(+), 12 deletions(-)
REMOTE URL : https://github.com/wsnh2022/wsnh_portfolio/actions
================================================
```

| Status | Meaning |
|---|---|
| ✅ `SUCCESS` | Pushed to remote |
| ⏭️ `SKIPPED` | Local and remote already in sync |
| ❌ `FAILED` | Pull conflict or push error |

---

## ⚠️ Limitations

| Item | Detail |
|---|---|
| Branch | Hardcoded to `main` — edit `origin/main` in the script for other branches |
| Merge conflicts | Script exits and prompts manual resolution |
| Platform | Windows only — not portable to macOS or Linux as-is |

---

## 📄 License

MIT — free to use, modify, and redistribute.

---

*Tested on Windows 11, Git 2.x.*
