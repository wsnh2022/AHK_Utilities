#SingleInstance Force
#Requires AutoHotkey v2.0+
~*^s:: Reload

^!p:: ShowPromptMenu()

ShowPromptMenu() {
    csvData := LoadCSV("prompts.csv")
    if !csvData.Length {
        MsgBox("No prompts found in CSV file.")
        return
    }

    menuTree := BuildMenuTree(csvData)
    menu := CreateMenuFromTree(menuTree)
    menu.Show()
}

LoadCSV(fileName) {
    if !FileExist(fileName) {
        MsgBox("CSV file not found: " . fileName)
        return []
    }

    csvData := []
    fileContent := FileRead(fileName)
    lines := StrSplit(fileContent, "`n")

    ; Skip header row
    for i in Range(2, lines.Length) {
        line := Trim(lines[i])
        if line = ""
            continue

        row := ParseCSVLine(line)
        if row.Length >= 5
            csvData.Push(row)
    }

    return csvData
}

ParseCSVLine(line) {
    result := []
    current := ""
    inQuotes := false

    loop parse, line {
        char := A_LoopField

        if char = '"' {
            inQuotes := !inQuotes
        } else if char = "," && !inQuotes {
            result.Push(Trim(current, ' "'))
            current := ""
        } else {
            current .= char
        }
    }

    ; Add the last field
    result.Push(Trim(current, ' "'))
    return result
}

BuildMenuTree(csvData) {
    tree := Map()

    for row in csvData {
        current := tree

        ; Navigate through categories/subcategories
        for i in Range(1, 4) {
            if i <= row.Length && Trim(row[i]) != "" {
                category := Trim(row[i])
                if !current.Has(category)
                    current[category] := Map()
                current := current[category]
            }
        }

        ; Add the prompt at the end
        if row.Length >= 5 {
            prompt := Trim(row[5])
            current["__PROMPT__"] := prompt
        }
    }

    return tree
}

CreateMenuFromTree(tree) {
    promptMenu := Menu()

    for key, value in tree {
        if key = "__PROMPT__" {
            continue
        }

        if Type(value) = "Map" {
            if value.Has("__PROMPT__") {
                ; This is a final item with a prompt
                promptMenu.Add(key, CreatePromptHandler(value["__PROMPT__"]))
            } else {
                ; This is a submenu
                submenu := CreateMenuFromTree(value)
                promptMenu.Add(key, submenu)
            }
        }
    }

    return promptMenu
}

CreatePromptHandler(prompt) {
    return (*) => PastePrompt(prompt)
}

PastePrompt(prompt) {
    A_Clipboard := prompt
    ClipWait(1)
    Send("^v")
}

Range(start, end) {
    result := []
    loop end - start + 1 {
        result.Push(start + A_Index - 1)
    }
    return result
}
