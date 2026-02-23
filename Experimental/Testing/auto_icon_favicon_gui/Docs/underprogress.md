# future improvements: Favicon Launcher Roadmap

This file tracks the current status and planned improvements for the Favicon Launcher project.

## 🏗️ Current Status
- [x] Basic Favicon Downloading (ICO/PNG)
- [x] Grid-based GUI Launcher
- [x] Right-Click context menu for updates
- [x] Manual configuration via AHK Map

## 🚀 Planned Stability Improvements

### 1. Data Persistence (JSON Config)
Move icon definitions from the `.ahk` file into a `config.json` file.
- **Why**: Allows adding/removing icons without touching the script code.
- **Status**: Not Started

### 2. Dynamic Flow Layout
Replace absolute positioning with a responsive wrap layout.
- **Why**: Allows the GUI to resize and icons to rearrange themselves.
- **Status**: Not Started

### 3. User Experience Polish
- **Hover Tooltips**: Show the shortcut name or target path on hover.
- **Generic Fallback Icons**: Use a standard icon if a website favicon can't be fetched.
- **Loading States**: Visual feedback while an icon is being downloaded.

### 4. Code Maintenance
- **Single Downloader Instance**: Improve performance when downloading many icons.
- **Log Rotation**: Manage the `favicon_downloader.log` size automatically.

---
*Note: This file is a living document and will be updated as features are implemented.*
