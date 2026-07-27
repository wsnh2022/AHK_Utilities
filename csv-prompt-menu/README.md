# CSV2PromptMenu - Dynamic Prompt Selection System

A dynamic AutoHotkey v2 application that creates hierarchical menus from CSV-structured prompts for instant AI prompt selection and clipboard integration.

## Features

- **Dynamic CSV Parsing**: Automatically builds menus from CSV structure
- **Multi-Level Hierarchy**: Supports Category → Subcategory1 → Subcategory2 → Subcategory3 → Prompt
- **Hotkey Activation**: Press `Ctrl+Alt+P` to open the prompt menu
- **Clipboard Integration**: Selected prompts are automatically copied and pasted
- **No Hardcoding**: Add new prompts by simply updating the CSV file

## Files

- `CSV2PromptMenu.ahk` - Main application script
- `prompts.csv` - Prompt database with hierarchical structure
- `master_prompts/` - Reference materials and templates

## Usage

1. Run `CSV2PromptMenu.ahk` with AutoHotkey v2
2. Press `Ctrl+Alt+P` to open the prompt menu
3. Navigate through categories and subcategories
4. Click on a prompt to paste it at the cursor location

## CSV Format

```csv
Category,Subcategory1,Subcategory2,Subcategory3,Prompt
PromptingTechniques,Role Assignment,Instruction,Audience,"You are [role]. Explain [topic] for [audience 1], then for [audience 2]."
DataAnalysis,Python,Pandas,Churn Analysis,"Write Python code using Pandas to analyze customer churn from this dataset: [Insert Dataset Overview]."
```

## Adding New Prompts

Simply add new rows to `prompts.csv` following the format above. The menu will automatically update when the script is reloaded (`Ctrl+S`).

## Requirements

- AutoHotkey v2.0+
- Windows operating system