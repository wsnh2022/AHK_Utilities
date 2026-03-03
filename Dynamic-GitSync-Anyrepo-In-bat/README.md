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

Place the script anywhere inside a git-tracked folder — repo root or any subfolder:

```
your-repo/
├── gitsync.bat              ← works here
├── tools/
│   └── gitsync.bat          ← or here
├── tools/scripts/
│   └── gitsync.bat          ← or here
├── .gitignore
└── ...
```

The script uses `git rev-parse --show-toplevel` to locate the repo root at runtime regardless of where it is placed. All paths — log file, lock file, `.gitignore` — resolve to the repo root, not the script's own directory.

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
   │  [PHASE 1 — GUARDS]
   │  Verify environment is safe before touching anything
   │
   ├─ Is this a git repository?
   │     No  ──► Print error. Exit.
   │
   ├─ Does a remote named 'origin' exist?
   │     No  ──► Print error. Exit.
   │
   ├─ Is .gitsync.lock already present?
   │     Yes ──► Stale lock from a crashed run. Clear it. Continue.
   │
   ├─ Acquire .gitsync.lock  (prevent concurrent runs)
   ├─ Detect repo name, current branch, remote URL from git state
   ├─ Auto-update .gitignore with missing entries (gitsync.bat, deploy-log.txt, .gitsync.lock)
   │
   │
   │  [PHASE 2 — FETCH + DIVERGENCE CHECK]
   │  Get latest remote state without modifying local
   │
   ├─ git fetch origin
   │
   ├─ Does origin/<branch> tracking ref exist?
   │     Yes ──► Count how many commits remote is ahead  (REMOTE_AHEAD)
   │             Count how many commits local is ahead   (LOCAL_AHEAD)
   │     No  ──► Treat as new branch. Skip divergence counts. Continue.
   │
   │
   │  [PHASE 3 — PULL]
   │  Sync remote changes to local before staging anything
   │
   ├─ Is REMOTE_AHEAD > 0?  (GitHub has commits local does not)
   │     Yes ──► git pull origin <branch>
   │               │
   │               ├─ Pull succeeded? ──► Continue
   │               └─ Merge conflict? ──► Log FAILED. Print instructions. Exit.
   │     No  ──► Skip pull. Local is already up to date with remote.
   │
   │
   │  [PHASE 4 — STAGE]
   │  Clean tracking index, then stage everything
   │
   ├─ git rm --cached  (remove files from tracking that now match .gitignore)
   │                    Local files are NOT deleted from disk
   ├─ git add -A       (stage all remaining local changes)
   │
   │
   │  [PHASE 5 — COMMIT + PUSH]
   │  Decide what action is needed based on current state
   │
   ├─ Nothing staged AND LOCAL_AHEAD = 0?
   │     Yes ──► Local and remote are identical. Log SKIPPED. Exit.
   │
   ├─ Nothing staged BUT LOCAL_AHEAD > 0?
   │     Yes ──► Unpushed commits exist. Skip commit. Go to push.
   │
   ├─ Staged changes exist?
   │     Yes ──► Build commit message from changed file names
   │               1 file  → "Update filename.ext"
   │               N files → "Update filename.ext and N more files"
   │             git commit
   │
   ├─ git push origin <branch>
   │
   │
   │  [PHASE 6 — LOG + CLEANUP]
   │  Record result and release lock on every exit path
   │
   ├─ Append structured entry to deploy-log.txt
   ├─ Delete .gitsync.lock
   └─ Print SUCCESS or FAILED with Actions URL
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
