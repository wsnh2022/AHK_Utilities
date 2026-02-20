#SingleInstance Force
#Requires AutoHotkey v2.0+
~*^s::Reload
Tray := A_TrayMenu, Tray.Delete() Tray.AddStandard() Tray.Add()
Tray.Add("Open Folder", (*)=> Run(A_ScriptDir)) Tray.SetIcon("Open Folder", "shell32.dll",5)
; -----------------

; ============================================
; New GitHub Repo Setup — Git Command Menu
; Hotkey : Ctrl + Shift + N
; ============================================
^+n::
{
    commands := Map(
        ; Step 1 — creates a new empty .git folder in current directory, starts tracking
        "1. Init local repo (Edit path)✏️"                              , "cd `"C:\Users\" A_UserName "\Documents\ahk_public_repo_name`" && git init",

        ; Step 2 — links local repo to GitHub remote, replace REPO_NAME before running
        "2. Add remote origin (Edit Repo Name)✏️"                       , "git remote add origin https://github.com/wsnh2022/REPO_NAME.git",

        ; Step 3 — pulls existing commits from GitHub (README, .gitignore etc) before first push, prevents rejection
        "3. Pull remote main (Edit No Need)✅"                          , "git pull origin main",

        ; Step 4 — stages all files, commits with message, pushes and sets upstream tracking to origin/main
        "4. Stage, commit and push (Edit commit message)✏️"             , "git add -A && git commit -m `"feat: initial commit`" && git push -u origin main",

        ; Step 5 — removes a file from remote repo tracking without deleting it locally, then commits and pushes
        "5. Untrack file from remote (Edit filename)✏️"                 , "git rm --cached FILENAME && git commit -m `"chore: untrack FILENAME`" && git push origin main",
    )

    labels := []
    for label, _ in commands
        labels.Push(label)

    gm := Gui("+AlwaysOnTop -MaximizeBox", "New GitHub Repo — Setup Steps")
    gm.SetFont("s10", "Consolas")
    gm.AddText("x10 y10", "Run steps in order — pastes into active terminal:")

    lb := gm.AddListBox("x10 y35 w500 h155 +AltSubmit", labels)

    gm.AddText("x10 y198 w500 0x10")   ; divider between list and buttons

    gm.SetFont("s9", "Segoe UI")
    btnPaste := gm.AddButton("x10 y210 w240 h30 Default", "Paste into Terminal")
    btnClose := gm.AddButton("x260 y210 w250 h30", "Close")

    btnPaste.OnEvent("Click", PasteCommand)
    btnClose.OnEvent("Click", (*) => gm.Destroy())
    lb.OnEvent("DoubleClick", PasteCommand)

    gm.Show("w520 h255")

    PasteCommand(*) {
        selected := lb.Text
        if (selected = "")
            return
        cmd := commands[selected]
        A_Clipboard := cmd
        gm.Destroy()
        Sleep(100)
        Send "^v"
    }
}