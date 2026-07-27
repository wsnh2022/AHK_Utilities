# How to Use: Favicon Launcher

This guide explains how to configure and customize your visual dashboard.

## 🖱️ Basic Interaction

### **Left-Click: Execute Action**
Clicking an icon will trigger the action assigned to it. Depending on how it's configured, it will:
- Open a website in your default browser.
- Open a specific file or folder.
- Run a terminal (CMD) command.
- Execute a separate AHK script.

### **Right-Click: Customize Icon**
Right-click any icon to open the **Icon Update Dialog**.
- **Favicon Source URL**: The website domain the script uses to find an icon.
- **Action Type**: Choose what happens when you click the icon.
- **Action Target**: The specific URL, path, or command to run.

---

## 📝 Manual Editing (Adding Icons via Code)

If you prefer to add many icons at once, you can edit `favicon_gui 3x3.ahk` directly.

1. Find the `IconConfigs` Map (around line 16).
2. Add a new line using this format:
   ```autohotkey
   "unique_id", {name: "icon_name", url: "https://source.com", target: "https://target.com"},
   ```
3. **Save and Reload**: Press `Ctrl + S` to see your changes.

### Grid Settings
You can also adjust the layout (around line 12):
- `GRID_COLUMNS`: Number of icons per row.
- `ICON_SIZE`: Pixel size of icons (default `32`).
- `ICON_SPACING`: Space between icons.

---

## ⚙️ Adding New Icons (Code Level)

To add more icons to your grid or change the default layout, open `favicon_gui 3x3.ahk` and look for the `IconConfigs` Map:

```autohotkey
IconConfigs := Map(
    "unique_key", {
        name: "file_name_for_icon", 
        url: "https://website-for-icon.com", 
        target: "https://your-actual-target.com"
    }
)
```

### **Target Prefixes**
When setting a target, use these prefixes to tell the script how to handle it:
- `https://...` → Opens a Website.
- `file:C:\path\to\file.txt` → Opens a File.
- `folder:C:\path\to\folder` → Opens a Folder.
- `cmd:/c echo Hello` → Runs a Command Prompt.
- `ahk:C:\path\to\script.ahk` → Runs an AHK script.
- `shell:startup` → Opens a Windows Shell folder.

---

## 💾 Cache Management

The script saves icons to a `favicon_cache` folder in the same directory.
- If you find an icon is outdated, you can delete the file inside this folder, and the script will redownload it next time it runs.
- **Tip**: You can clear the entire cache by deleting the folder; the script will recreate it automatically.

## ⌨️ Script Controls
- **Ctrl + S**: Reloads the script (useful while editing configuration).
- **Tray Icon**: Right-click the AutoHotkey icon in your taskbar to open the script folder quickly.
