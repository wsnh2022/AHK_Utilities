; Functions inside classes are strictly "Methods" (In v2)
#SingleInstance Force

; ==============================================================================
; STYLE 1: NORMAL FUNCTIONS
; ==============================================================================
; These are standard functions that can use anywhere in the script.
; They are simple to write, but if having too many, they can get mixed up
; with functions from other scripts.

SendTextWithDelay(text, delay := 20) {
    SetKeyDelay delay
    Send text
}

ActivateWindowByTitle(title) {
    if WinExist(title)
        WinActivate
    else
        MsgBox "Could not find the window: " . title
}

ClickAt(x, y) {
    Click x, y
}

; ==============================================================================
; STYLE 2: FUNCTIONS INSIDE CLASSES (Called "Methods")
; ==============================================================================
; Here, we put functions inside a "Class" to keep them organized.
; This keeps them neat and prevents them from interfering with other scripts.
; To use them, just type the Class name first (like TextUtils or WindowUtils).

class TextUtils {
    static Capitalize(text) {
        return StrUpper(SubStr(text, 1, 1)) . SubStr(text, 2)
    }

    static RemoveSpaces(text) {
        return StrReplace(text, A_Space, "")
    }
}

class WindowUtils {
    static MoveWindowToPosition(title, x, y, width, height) {
        if WinExist(title) {
            WinMove x, y, width, height
            return true
        }
        return false
    }

    static IsWindowActive(title) {
        return WinActive(title)
    }
}

; ==============================================================================
; STYLE 3: PREVENTING NAME CLASHES
; ==============================================================================
; With normal functions, you cannot have two functions with the same name.
; But with Classes, you can have a ".Save()" for files and a ".Save()" for logs.

class FileTools {
    static Save(text) {
        MsgBox "Saving to a file: " . text
    }
}

class LogTools {
    static Save(text) {
        MsgBox "Saving to a log: " . text
    }
}

; ==============================================================================
; STYLE 4: FUNCTIONS SHARING INFORMATION
; ==============================================================================
; A class can "remember" a piece of information (like a Prefix) so all its
; functions can use it. This is much cleaner than using global variables.

class MessageTools {
    static Prefix := "[MY APP] "

    static Show(text) {
        MsgBox this.Prefix . text
    }

    static SetPrefix(newPrefix) {
        this.Prefix := newPrefix
    }
}

; ==============================================================================
; STYLE 5: CLIPBOARD TOOLS (Daily Use Case)
; ==============================================================================
; Classes are great for handling the Clipboard correctly by backing it up
; and restoring it afterwards.

class ClipboardTools {
    static SavedContent := ""

    static Backup() {
        this.SavedContent := ClipboardAll()
        A_Clipboard := "" ; Clear it to prepare for new data
    }

    static Restore() {
        A_Clipboard := this.SavedContent
        this.SavedContent := "" ; Clear the memory
    }
}

; ==============================================================================
; STYLE 6: APP SETTINGS (Modern Config Handling)
; ==============================================================================
; You can store your script's name and settings file path in one place.
; Every part of your script can then ask the "Settings" class for details.

class AppSettings {
    static Name := "My Tiny Tool"
    static Version := "1.0.0"
    static ConfigFile := A_ScriptDir . "\settings.ini"

    static GetInfo() {
        return this.Name . " v" . this.Version . " (File: " . this.ConfigFile . ")"
    }
}

; ==============================================================================
; STYLE 7: PATH TOOLS (Folder & File Helpers)
; ==============================================================================
; Classes help you group tools for handling computer paths and folders.

class PathTools {
    static EnsureFolder(folderPath) {
        if !DirExist(folderPath) {
            DirCreate(folderPath)
            return "Created folder: " . folderPath
        }
        return "Folder already exists."
    }

    static GetExt(filePath) {
        SplitPath(filePath, , , &ext)
        return ext
    }
}

; ==============================================================================
; HOW TO USE THEM
; ==============================================================================

; --- Style 1: Normal Functions ---
Run "calc.exe"
if WinWait("Calculator", , 3)
    ActivateWindowByTitle("Calculator")
ClickAt(100, 100)

; --- Style 2: Functions in Groups ---
MsgBox TextUtils.Capitalize("hello")
MsgBox TextUtils.RemoveSpaces("Hello World")

; --- Style 3: Same Names, No Conflict ---
FileTools.Save("My Document")
LogTools.Save("User logged in")

; --- Style 4: Shared Information ---
MessageTools.Show("Ready to go!")
MessageTools.SetPrefix("[ALERT] ")
MessageTools.Show("Something happened!")

; --- Style 5: Clipboard Management ---
ClipboardTools.Backup()
A_Clipboard := "Some temporary text"
MsgBox "Clipboard currently has: " . A_Clipboard
ClipboardTools.Restore()
MsgBox "Clipboard restored to original state!"

; --- Style 6: App Info ---
MsgBox AppSettings.GetInfo()

; --- Style 7: Path Management ---
MsgBox PathTools.EnsureFolder(A_ScriptDir . "\TestFolder")
MsgBox "File extension is: " . PathTools.GetExt("myscript.ahk")

if WindowUtils.MoveWindowToPosition("Calculator", 0, 0, 800, 600)
    MsgBox "Moved successfully"