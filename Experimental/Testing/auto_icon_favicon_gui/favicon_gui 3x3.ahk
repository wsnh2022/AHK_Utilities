#SingleInstance Force           ; Force a single instance of the script
#Requires AutoHotkey v2.0+      ; Requires AutoHotkey v2.0 or later
~*^s:: Reload                    ; Quick script reload
Tray := A_TrayMenu, Tray.Delete() Tray.AddStandard() Tray.Add()
Tray.Add("Open Folder", (*) => Run(A_ScriptDir)) Tray.SetIcon("Open Folder", "shell32.dll", 5)
#Include 'Lib\favicon_downloader.ahk'

; === CORE CONFIGURATION ===
WINDOW_TITLE := "Dynamic Favicon Launcher"
ICON_SIZE := 32
ICON_SPACING := 20
GRID_COLUMNS := 4
ROW_SPACING := 30

; === EXTENDED ICON DEFINITIONS WITH ACTION TARGETS ===
IconConfigs := Map(
    ; First Row - Website Icons with Various Action Targets
    "github", { name: "new_icon", url: "https://quickref.me/", target: "https://github.com/yourusername" },
    "stackoverflow", { name: "stackoverflow_icon", url: "https://stackoverflow.com", target: "https://stackoverflow.com/questions/tagged/autohotkey" },
    "whimsical", { name: "whimsical_icon", url: "https://whimsical.com", target: "C:\Program Files\MyApp\launcher.exe" },
    "claude", { name: "claude_icon", url: "https://claude.ai", target: "cmd:/c echo Hello World && pause" },
    ; Second Row - More Examples of Different Action Types
    "youtube", { name: "youtube_icon", url: "https://youtube.com", target: "https://youtube.com/playlist?list=favorites" },
    "reddit", { name: "reddit_icon", url: "https://reddit.com", target: "ahk:C:\Scripts\MyScript.ahk" },
    "twitter", { name: "twitter_icon", url: "https://twitter.com", target: "file:C:\Users\Documents\important.txt" },
    "linkedin", { name: "linkedin_icon", url: "https://linkedin.com", target: "shell:startup" }
)

; === APPLICATION INITIALIZATION ===
Controls := Map()
mainGui := Gui("+Resize", WINDOW_TITLE)
mainGui.MarginX := 20
mainGui.MarginY := 20

; === RIGHT-CLICK MESSAGE HANDLER ===
OnMessage(0x0204, HandleRightClick)

; === PRECISE GRID INITIALIZATION WITH ABSOLUTE COORDINATES ===
LoadIcons() {
    index := 0

    for key, config in IconConfigs {
        ; Download favicon with production-grade error handling
        favicon := FaviconDownloader(config.name, config.url)

        ; Calculate absolute grid coordinates with mathematical precision
        row := index // GRID_COLUMNS
        col := index - (row * GRID_COLUMNS)

        ; Compute absolute pixel positions for deterministic layout
        xPos := mainGui.MarginX + (col * (ICON_SIZE + ICON_SPACING))
        yPos := mainGui.MarginY + (row * (ICON_SIZE + ROW_SPACING))

        ; Create control with absolute positioning for grid reliability
        options := "w" ICON_SIZE " h" ICON_SIZE " x" xPos " y" yPos
        control := mainGui.Add("Picture", options, favicon.FilePath)

        ; Maintain comprehensive control registry for reverse lookup
        Controls[key] := {
            control: control,
            config: config,
            hwnd: control.Hwnd
        }

        ; Bind closure-free event handlers with architectural consistency
        control.OnEvent("Click", HandleIconClick)

        index++
    }
}

; === INTELLIGENT ACTION LAUNCHER WITH MULTIPLE TARGET TYPES ===
HandleIconClick(control, *) {
    try {
        ; Perform reverse lookup to find which icon was clicked
        targetHwnd := control.Hwnd

        for key, ref in Controls {
            if (ref.hwnd = targetHwnd) {
                ; Get target from configuration (use URL if no target specified)
                target := ref.config.HasProp("target") ? ref.config.target : ref.config.url

                ; Launch target with smart action type detection
                LaunchTarget(target, key)
                return
            }
        }

        throw Error("Control not found in registry")

    } catch as err {
        MsgBox("Launch failed: " err.Message, "Error", "Iconx")
    }
}

; === RIGHT-CLICK HANDLER ===
HandleRightClick(wParam, lParam, msg, hwnd) {
    ; Identify which control was right-clicked
    for key, controlRef in Controls {
        if (controlRef.hwnd = hwnd) {
            UpdateIcon(key)
            return 0  ; Message handled
        }
    }
    return  ; Let default processing continue
}

; === MULTI-TARGET ACTION EXECUTOR ===
LaunchTarget(target, iconName := "") {
    try {
        ; Skip empty targets
        if (!target) {
            throw Error("Empty target specified")
        }

        ; Log the action for debugging and analytics
        actionType := DetermineTargetType(target)
        actionTarget := StripTargetPrefix(target, actionType)

        ; Execute appropriate action based on target type
        switch actionType {
            case "url":
                Run(NormalizeUrl(actionTarget))

            case "file":
                if (!FileExist(actionTarget)) {
                    throw Error("File not found: " actionTarget)
                }
                Run(actionTarget)

            case "folder":
                if (!DirExist(actionTarget)) {
                    throw Error("Folder not found: " actionTarget)
                }
                Run(actionTarget)

            case "cmd":
                Run(A_ComSpec " " actionTarget)

            case "ahk":
                if (!FileExist(actionTarget)) {
                    throw Error("AutoHotkey script not found: " actionTarget)
                }
                Run(actionTarget)

            case "shell":
                Run("shell:" actionTarget)

            default:
                throw Error("Unknown target type: " target)
        }

    } catch as err {
        throw Error("Failed to launch target: " err.Message)
    }
}

; === TARGET TYPE DETECTION WITH PREFIX RECOGNITION ===
DetermineTargetType(target) {
    ; Default to URL for backward compatibility
    if (!target) {
        return "url"
    }

    ; Check for explicit prefixes
    if (RegExMatch(target, "i)^(https?|ftp)://")) {
        return "url"
    }

    if (RegExMatch(target, "i)^file:")) {
        return "file"
    }

    if (RegExMatch(target, "i)^folder:")) {
        return "folder"
    }

    if (RegExMatch(target, "i)^cmd:")) {
        return "cmd"
    }

    if (RegExMatch(target, "i)^ahk:")) {
        return "ahk"
    }

    if (RegExMatch(target, "i)^shell:")) {
        return "shell"
    }

    ; Implicit type detection for common patterns
    if (RegExMatch(target, "i)^[a-z]:\\") || RegExMatch(target, "i)^\\\\")) {
        ; Path starts with drive letter or UNC path
        if (DirExist(target)) {
            return "folder"
        }
        return "file"
    }

    ; Default to URL for anything else
    return "url"
}

; === TARGET PREFIX STRIPPER ===
StripTargetPrefix(target, targetType) {
    ; Remove type-specific prefixes for execution
    switch targetType {
        case "file":
            return RegExReplace(target, "i)^file:", "")

        case "folder":
            return RegExReplace(target, "i)^folder:", "")

        case "cmd":
            return RegExReplace(target, "i)^cmd:", "")

        case "ahk":
            return RegExReplace(target, "i)^ahk:", "")

        case "shell":
            return RegExReplace(target, "i)^shell:", "")

        default:
            return target
    }
}

; === RIGHT-CLICK HANDLER ===
; HandleRightClick(wParam, lParam, msg, hwnd) {
;     for key, ref in Controls {
;         if (ref.hwnd = hwnd) {
;             UpdateIcon(key)
;             return 0
;         }
;     }
; }

; ; === ICON UPDATE SYSTEM ===
; UpdateIcon(iconKey) {
;     try {
;         ref := Controls[iconKey]
;         currentUrl := ref.config.url

;         ; Get new URL from user
;         input := InputBox(
;             "Update " StrTitle(iconKey) " icon:`n`nCurrent: " currentUrl,
;             "Icon Update",
;             "w400",
;             currentUrl
;         )

;         if (input.Result !== "OK" || !input.Value) {
;             return
;         }

;         newUrl := Trim(input.Value)

;         ; Validate URL format
;         if (!IsValidUrl(newUrl)) {
;             MsgBox("Invalid URL format. Please enter a valid web address.", "Invalid URL", "Iconx")
;             return
;         }

;         ; Update icon
;         ExecuteUpdate(iconKey, newUrl)

;     } catch as err {
;         MsgBox("Update failed: " err.Message, "Error", "Iconx")
;     }
; }

; === SOPHISTICATED ICON UPDATE DIALOG ===
UpdateIcon(iconKey) {
    try {
        ref := Controls[iconKey]

        ; Get current URL and target
        currentUrl := ref.config.url
        currentTarget := ref.config.HasProp("target") ? ref.config.target : currentUrl

        ; Create modal update dialog
        updateGui := Gui("+Owner" mainGui.Hwnd " +ToolWindow +AlwaysOnTop", "Update " StrTitle(iconKey) " Icon")
        updateGui.OnEvent("Escape", (*) => updateGui.Destroy())
        updateGui.OnEvent("Close", (*) => updateGui.Destroy())
        updateGui.MarginX := 15
        updateGui.MarginY := 15

        ; Add icon source URL field
        updateGui.Add("Text", "w320", "Favicon Source URL:")
        urlEdit := updateGui.Add("Edit", "w320", currentUrl)

        ; Add action type dropdown
        updateGui.Add("Text", "w320 y+15", "Action Type:")
        actionTypes := ["URL", "File", "Folder", "Command (CMD)", "AutoHotkey Script", "Shell Command"]
        actionTypeDropdown := updateGui.Add("DropDownList", "w320 Choose1", actionTypes)

        ; Add target field
        updateGui.Add("Text", "w320 y+10", "Action Target:")
        targetEdit := updateGui.Add("Edit", "w320", StripTargetPrefix(currentTarget, DetermineTargetType(currentTarget)))

        ; Add browse button (initially hidden)
        browseButton := updateGui.Add("Button", "w80 x+5 yp-1 Hidden", "Browse...")

        ; Add save button
        saveButton := updateGui.Add("Button", "w100 x135 y+20 Default", "Save")

        ; Handle action type change
        actionTypeDropdown.OnEvent("Change", (*) => UpdateActionControls(actionTypeDropdown, targetEdit, browseButton))

        ; Set initial action type based on current target
        initialType := GetActionDropdownIndex(DetermineTargetType(currentTarget))
        actionTypeDropdown.Value := initialType
        UpdateActionControls(actionTypeDropdown, targetEdit, browseButton)

        ; Handle browse button click
        browseButton.OnEvent("Click", (*) => HandleBrowseClick(actionTypeDropdown, targetEdit))

        ; Handle save button click
        saveButton.OnEvent("Click", (*) => SaveIconUpdate(updateGui, iconKey, urlEdit.Value, actionTypeDropdown,
            targetEdit.Value))

        ; Show dialog centered to main window
        updateGui.Show("Center")

    } catch as err {
        MsgBox("Failed to open update dialog: " err.Message, "Error", "Iconx")
    }
}

; === DYNAMIC CONTROL MANAGEMENT FOR ACTION TYPES ===
UpdateActionControls(dropdown, targetEdit, browseButton) {
    ; Update controls based on selected action type
    selection := dropdown.Value

    ; Show/hide browse button based on type
    if (selection = 2 || selection = 3 || selection = 5) {
        ; File, Folder, or AHK Script - show browse button
        browseButton.Visible := true
        browseButton.GetPos(&x, &y, &w, &h)
        targetEdit.Move(, , 320 - w - 10)  ; Resize target edit to make room
    } else {
        ; URLs, CMD, Shell - hide browse button
        browseButton.Visible := false
        targetEdit.Move(, , 320)  ; Restore full width
    }

    ; Update placeholder and tooltip based on type
    placeholder := ""
    switch selection {
        case 1: placeholder := "https://example.com/page"
        case 2: placeholder := "C:\Path\To\File.exe"
        case 3: placeholder := "C:\Path\To\Folder"
        case 4: placeholder := "/c echo Hello && pause"
        case 5: placeholder := "C:\Path\To\Script.ahk"
        case 6: placeholder := "startup (or other shell folder name)"
    }

    ; Cannot directly set placeholder in AHK v2, but could show as tooltip
    if (targetEdit.Value = "") {
        targetEdit.Value := placeholder
        targetEdit.Focus()
        SendInput("^a")  ; Select all for easy replacement
    }
}

; === BROWSE DIALOG HANDLER ===
HandleBrowseClick(dropdown, targetEdit) {
    selection := dropdown.Value

    switch selection {
        case 2:  ; File
            filePath := FileSelect("3", , "Select File", "All Files (*.*)")
            if (filePath) {
                targetEdit.Value := filePath
            }

        case 3:  ; Folder
            folderPath := DirSelect(, 3, "Select Folder")
            if (folderPath) {
                targetEdit.Value := folderPath
            }

        case 5:  ; AHK Script
            ahkPath := FileSelect("3", , "Select AutoHotkey Script", "AHK Files (*.ahk)")
            if (ahkPath) {
                targetEdit.Value := ahkPath
            }
    }
}

; === ICON UPDATE SAVE HANDLER ===
SaveIconUpdate(updateGui, iconKey, newUrl, actionTypeDropdown, targetValue) {
    try {
        ; Validate URL
        if (!newUrl || !IsValidUrl(newUrl)) {
            MsgBox("Invalid favicon source URL. Please enter a valid web address.", "Validation Error", "Iconx")
            return
        }

        ; Get selected action type and format target
        actionPrefix := GetActionPrefix(actionTypeDropdown.Value)
        formattedTarget := FormatActionTarget(actionPrefix, targetValue)

        ; Update icon with new values
        ExecuteCustomUpdate(iconKey, newUrl, formattedTarget)

        ; Close dialog
        updateGui.Destroy()

    } catch as err {
        MsgBox("Failed to save changes: " err.Message, "Error", "Iconx")
    }
}

; === ENHANCED UPDATE EXECUTION === v2
ExecuteCustomUpdate(iconKey, newUrl, formattedTarget) {
    ref := Controls[iconKey]

    ; Store the old favicon path so we can delete it later
    oldFaviconPath := ref.control.Value

    ; Download new favicon with consistent name (no timestamp)
    newFavicon := FaviconDownloader(ref.config.name, newUrl, "auto", "", true)

    ; Update control and config with new values
    ref.control.Value := newFavicon.FilePath
    ref.config.url := newUrl
    ref.config.target := formattedTarget

    ; Delete the old favicon file if it exists and differs from new one
    if (FileExist(oldFaviconPath) && oldFaviconPath != newFavicon.FilePath)
        FileDelete(oldFaviconPath)

    ; Provide user feedback
    ToolTip(StrTitle(iconKey) " updated successfully!")
    SetTimer(() => ToolTip(), -2000)
}
; === ENHANCED UPDATE EXECUTION === v1
; ExecuteCustomUpdate(iconKey, newUrl, formattedTarget) {
;     ref := Controls[iconKey]

;     ; Download new favicon
;     newFavicon := FaviconDownloader(ref.config.name "_" A_TickCount, newUrl, "auto", "", true)

;     ; Update control and config with new values
;     ref.control.Value := newFavicon.FilePath
;     ref.config.url := newUrl
;     ref.config.target := formattedTarget

;     ; Provide user feedback
;     ToolTip(StrTitle(iconKey) " updated successfully!")
;     SetTimer(() => ToolTip(), -2000)
; }

; === ACTION TYPE UTILITIES ===
GetActionDropdownIndex(actionType) {
    switch actionType {
        case "url": return 1
        case "file": return 2
        case "folder": return 3
        case "cmd": return 4
        case "ahk": return 5
        case "shell": return 6
        default: return 1
    }
}

GetActionPrefix(dropdownIndex) {
    switch dropdownIndex {
        case 1: return ""      ; URL (no prefix)
        case 2: return "file:"
        case 3: return "folder:"
        case 4: return "cmd:"
        case 5: return "ahk:"
        case 6: return "shell:"
        default: return ""
    }
}

FormatActionTarget(prefix, target) {
    ; Nothing to do for empty target
    if (!target) {
        return ""
    }

    ; If it's URL prefix (empty), ensure it has proper protocol
    if (prefix = "" && !RegExMatch(target, "i)^(https?|ftp)://")) {
        return "https://" target
    }

    ; Otherwise, just combine prefix and target
    return prefix target
}

; === UTILITY FUNCTIONS ===
IsValidUrl(url) {
    return RegExMatch(url, "i)^(https?://)?([\w\-]+\.)+[\w\-]+(:[0-9]+)?(/.*)?$")
}

NormalizeUrl(url) {
    return RegExMatch(url, "i)^https?://") ? url : "https://" url
}

; === APPLICATION STARTUP ===
LoadIcons()
mainGui.Show()
mainGui.OnEvent("Close", (*) => ExitApp())