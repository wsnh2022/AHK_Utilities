# Walkthrough guidance

This file provides guidance for further development of the CSV2PromptMenu application when working with code in this repository.

## Project Overview

CSV2PromptMenu is a dynamic AutoHotkey v2 application that creates hierarchical context menus from CSV-structured prompts for instant AI prompt selection and clipboard integration. The system transforms a structured prompt database into an accessible hotkey-driven menu system.

## Core Architecture

### Application Flow
1. **CSV Parsing**: `LoadCSV()` reads and validates `prompts.csv` with 5-column structure
2. **Tree Building**: `BuildMenuTree()` constructs hierarchical Map structure from CSV data
3. **Menu Generation**: `CreateMenuFromTree()` recursively builds AutoHotkey Menu objects
4. **Clipboard Integration**: Selected prompts automatically paste at cursor location

### Key Components

**`CSV2PromptMenu.ahk`** - Main application with modular functions:
- `ShowPromptMenu()` - Entry point triggered by `Ctrl+Alt+P`
- `LoadCSV()` - CSV parser with quoted field handling
- `ParseCSVLine()` - Handles CSV escaping and multi-line content
- `BuildMenuTree()` - Creates nested Map structure for menu hierarchy
- `CreateMenuFromTree()` - Recursive menu builder with lambda handlers
- `PastePrompt()` - Clipboard integration for instant prompt insertion

**`prompts.csv`** - 5-column database: `Category,Subcategory1,Subcategory2,Subcategory3,Prompt`

## Common Commands

### Running the Application
```bash
"C:\Program Files\AutoHotkey\v2\AutoHotkey.exe" "CSV2PromptMenu.ahk"
```

### Development Workflow
- **Script Reload**: `Ctrl+S` (built-in hotkey for testing changes)
- **Menu Access**: `Ctrl+Alt+P` (opens prompt selection menu)
- **CSV Validation**: Script filters rows with fewer than 5 columns

### Adding New Prompts
CSV entries must follow exact 5-column format:
```csv
Category,Subcategory1,Subcategory2,Subcategory3,Prompt
```
Empty subcategories require comma placeholders: `Testing,Basic,,,,"Sample prompt"`

## Architecture Patterns

### CSV Structure Requirements
- **Exactly 5 columns** per row (script filters incomplete rows)
- **Hierarchical organization**: Category → Sub1 → Sub2 → Sub3 → Prompt
- **Quote handling**: Multi-line prompts and special characters properly escaped
- **Dynamic categorization**: No hardcoded categories, structure emerges from CSV

### Menu Tree Algorithm
The system builds nested Map objects where:
- Each category/subcategory becomes a Map key
- Final prompts stored with `"__PROMPT__"` key
- Recursive traversal creates submenu structure
- Lambda closures preserve prompt content for clipboard operations

### Critical Implementation Details
- **Variable scoping**: `CreateMenuFromTree()` uses local variables to avoid AutoHotkey v2 scoping issues
- **Lambda handling**: `CreatePromptHandler()` function prevents closure variable conflicts
- **CSV parsing**: Custom parser handles quoted fields, commas, and newlines correctly

## AI Assistant Integration

Use `master_prompts/Prompt for Organizing New Prompts into CSV.txt` with AI assistants to:
- Auto-format malformed CSV entries
- Suggest intelligent categorization based on prompt content
- Ensure 5-column compliance for all new prompts
- Maintain consistent hierarchical organization

The template includes dynamic categorization guidelines and prevents common CSV formatting mistakes that cause prompts to not appear in menus.