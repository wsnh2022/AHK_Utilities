# Dynamic-GitSync-Anyrepo

![Platform](https://img.shields.io/badge/platform-Windows-blue?logo=windows&logoColor=white)
![Shell](https://img.shields.io/badge/shell-Batch%20%28CMD%29-grey?logo=gnubash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)
![Requires Git](https://img.shields.io/badge/requires-Git-orange?logo=git&logoColor=white)

A zero-configuration Windows batch script for one-click GitHub sync. Drop it in any repo, run it, and it handles fetch, pull, stage, commit, push, and logging — fully dynamic, no hardcoded values anywhere.

---

## The Problem It Solves

Most personal projects do not need a CI pipeline. They need a reliable way to push changes without typing the same six git commands every time, forgetting to pull first, or accidentally pushing a diverged branch.

This script does exactly that — nothing more.

---

## What It Does

- Detects repo name, branch, and remote URL at runtime from git state
- Fetches remote state without modifying local
- Pulls automatically if remote is ahead — exits cleanly on merge conflict
- Untracks files that now match `.gitignore` rules without deleting them from disk
- Stages all remaining changes
- Generates a commit message from changed file names — no input required
- Pushes to `origin/<current-branch>`
- Appends a structured timestamped entry to `deploy-log.txt` in the repo root
- Creates and cleans up a `.gitsync.lock` file to guard against concurrent runs

---

## Requirements

| Dependency | Notes |
|---|---|
| Windows 10 / 11 | Batch — runs in CMD |
| Git (any recent version) | Must be in system PATH |

No APIs. No installs. No configuration.

---

## Setup

Place the script in the root of any git-tracked folder:

```
your-repo/
├── gitsync.bat
├── .gitignore
└── ...
```

That is it. No other steps required.

On first run the script automatically checks `.gitignore` for the following entries and appends any that are missing:

```gitignore
gitsync.bat
deploy-log.txt
.gitsync.lock
```

Each entry is checked individually. Already present entries are never duplicated. The script reads the repo name, branch, and remote URL from git itself at runtime — nothing is hardcoded.

---

## Usage

Run from an open terminal:

```cmd
cd C:\path\to\your-repo
gitsync.bat
```

Or to keep the window open when double-clicking, use the launcher wrapper:

```cmd
cmd /k gitsync.bat
```

---

## Execution Flow

```
START
  │
  ├─ Guard: is this a git repo?          No  ──► Exit with error
  ├─ Guard: does origin remote exist?    No  ──► Exit with error
  ├─ Acquire .gitsync.lock               Stale lock found? ──► Clear and continue
  │
  ├─ Read repo name, branch, remote URL from git state
  ├─ git fetch origin
  │
  ├─ Remote tracking ref exists?
  │     Yes ──► Count commits ahead / behind
  │
  ├─ Remote ahead?
  │     Yes ──► git pull ──► conflict? ──► Exit with FAILED log entry
  │
  ├─ git rm --cached  (untrack newly ignored files)
  ├─ git add -A
  │
  ├─ Nothing staged AND nothing unpushed?
  │     Yes ──► Exit with SKIPPED log entry
  │
  ├─ Nothing staged BUT unpushed commits exist?
  │     Yes ──► Push only, skip commit step
  │
  ├─ Staged changes exist?
  │     Yes ──► Build commit message from changed file names
  │             git commit
  │
  ├─ git push origin <branch>
  ├─ Write structured log entry to deploy-log.txt
  ├─ Delete .gitsync.lock
  └─ Print result (SUCCESS / FAILED)
```

---

## Commit Messages

Auto-generated from the staged file list — no user input required:

| Scenario | Generated Message |
|---|---|
| One file changed | `Update index.html` |
| Multiple files changed | `Update index.html and 2 more files` |
| Only unpushed commits | `Push existing unpushed commits` |

---

## Deploy Log

Each run appends a structured entry to `deploy-log.txt` in the repo root:

```
================================================
DATE       : Wed 04/03/2026
START TIME : 13:04:10.85
END TIME   : 13:04:18.43
ELAPSED    : 8 seconds
REPO       : AHK_Utilities
BRANCH     : main
STATUS     : SUCCESS
COMMIT MSG : Update index.html and 2 more files
CHANGES    : 3 files changed, 28 insertions(+), 12 deletions(-)
REMOTE URL : https://github.com/wsnh2022/AHK_Utilities/actions
================================================
```

| Status | Meaning |
|---|---|
| `SUCCESS` | Changes committed and pushed to remote |
| `SKIPPED` | Local and remote already in sync — nothing to do |
| `FAILED` | Pull conflict or push error — manual intervention required |

---

## Limitations

| Item | Detail |
|---|---|
| Platform | Windows only — CMD batch is not portable to macOS or Linux |
| Merge conflicts | Script exits on conflict and prompts manual resolution before re-run |
| Concurrency | Lock file guards against duplicate runs; true simultaneous execution on a shared machine is not safe |
| GitHub only | Remote URL parsing covers `https://github.com/` and `git@github.com:` formats only |

---

## License

MIT — free to use, modify, and redistribute.

---

*Tested on Windows 11, Git 2.x*
