# Favicon Launcher & Downloader

A dynamic, icon-based shortcut dashboard for AutoHotkey v2. This tool automatically retrieves high-quality favicons from websites and organizes your most-used links, files, and commands into a clean, visual grid.

## 🚀 Features

- **Automatic Icon Retrieval**: Just provide a URL, and the script handles the download and caching of the favicon.
- **Smart Fallback**: Automatically tries to find native `.ico` files before falling back to high-resolution PNGs via Google's favicon service.
- **Multi-Type Launcher**: Open websites, local files, folders, or execute terminal commands directly from the icon grid.
- **Dynamic Updates**: Right-click any icon to change its target or icon source in real-time.
- **Modern AHK v2**: Built using a class-based architecture for clean, reusable code.

## 📂 Project Structure

- `favicon_gui 3x3.ahk`: The main dashboard application.
- `favicon_downloader.ahk`: The core library used for fetching and managing icons.
- `favicon_cache/`: (Auto-generated) Folder where your downloaded icons are stored.

## 🛠️ Quick Start

1. Ensure you have [AutoHotkey v2](https://www.autohotkey.com/v2/) installed.
2. Run `favicon_gui 3x3.ahk`.
3. Click any icon to launch its associated action.
4. Right-click an icon to customize it.

---

*For detailed instructions on configuration and advanced usage, see [HOW_TO_USE.md](./HOW_TO_USE.md).*
