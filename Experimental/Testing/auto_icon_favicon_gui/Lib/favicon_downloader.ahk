#Requires AutoHotkey v2.0

/**
 * FaviconDownloader - Dynamic Favicon Download Library
 * 
 * Usage Examples:
 *   ; Basic usage with auto-detection
 *   favicon := FaviconDownloader("github_icon", "https://github.com")
 *   iconPath := favicon.FilePath
 *   
 *   ; Force specific format
 *   favicon := FaviconDownloader("google_icon", "https://google.com", "png")
 *   
 *   ; Use in GUI
 *   myGui.Add("Picture", "w32 h32", favicon.FilePath)
 * 
 *  favicon := FaviconDownloader("raindropio", "https://raindrop.io")
 *  iconPath := favicon.FilePath
 *  MsgBox("Favicon downloaded to: " favicon.FilePath)
 */
class FaviconDownloader {
    
    ; Class Properties
    Url := ""
    Filename := ""
    Format := ""
    FilePath := ""
    DownloadPath := ""
    LogEnabled := true
    UseCache := true
    
    ; Static Configuration
    static DefaultDownloadPath := A_ScriptDir "\favicon_cache\"
    static LogFile := A_ScriptDir "\favicon_downloader.log"
    
    /**
     * Constructor
     * @param {String} filename - Base filename (without extension)
     * @param {String} url - URL to download favicon from
     * @param {String} format - Optional: "ico", "png", or "auto" (default)
     * @param {String} downloadPath - Optional: Custom download directory
     * @param {Bool} useCache - Optional: Use cached icons when available (default true)
     */
    __New(filename, url, format := "auto", downloadPath := "", useCache := true) {
        this.Filename := this.SanitizeFilename(filename)
        this.Url := this.NormalizeUrl(url)
        this.Format := StrLower(format)
        this.DownloadPath := downloadPath || FaviconDownloader.DefaultDownloadPath
        this.UseCache := useCache
        
        ; Ensure download directory exists
        this.EnsureDirectoryExists()
        
        ; Perform the download with cache verification
        this.ExecuteDownload()
    }
    
    /**
     * Execute the favicon download with smart format detection
     */
    ExecuteDownload() {
        try {
            this.LogEvent("Initiating favicon download for: " this.Url)
            
            switch this.Format {
                case "ico":
                    this.FilePath := this.DownloadICO()
                case "png":
                    this.FilePath := this.DownloadPNG()
                case "auto":
                    this.FilePath := this.DownloadWithFallback()
                default:
                    throw Error("Invalid format specified: " this.Format)
            }
            
            this.LogEvent("Download successful: " this.FilePath)
            
        } catch as err {
            this.LogEvent("Download failed: " err.Message)
            throw Error("Favicon download failed for " this.Url ": " err.Message)
        }
    }
    
    /**
     * Download with smart fallback (ICO → PNG)
     */
    DownloadWithFallback() {
        ; Try ICO first
        try {
            this.LogEvent("Attempting ICO download")
            return this.DownloadICO()
        } catch {
            this.LogEvent("ICO failed, trying PNG fallback")
        }
        
        ; Fallback to PNG
        try {
            return this.DownloadPNG()
        } catch as err {
            throw Error("Both ICO and PNG download methods failed")
        }
    }
    
    /**
     * Download favicon in ICO format
     */
    DownloadICO() {
        baseUrl := this.GetBaseUrl(this.Url)
        faviconUrl := baseUrl "/favicon.ico"
        filePath := this.DownloadPath this.Filename "_favicon.ico"
        
        ; Check cache before downloading
        if (this.UseCache && this.CheckCache(filePath)) {
            this.LogEvent("Using cached ICO: " filePath)
            return filePath
        }
        
        if (this.PerformDownload(faviconUrl, filePath)) {
            return filePath
        }
        throw Error("ICO download failed")
    }
    
    /**
     * Download favicon in PNG format using Google's service
     */
    DownloadPNG() {
        domain := this.ExtractDomain(this.Url)
        faviconUrl := "https://www.google.com/s2/favicons?sz=64&domain=" domain
        filePath := this.DownloadPath this.Filename "_favicon.png"
        
        ; Check cache before downloading
        if (this.UseCache && this.CheckCache(filePath)) {
            this.LogEvent("Using cached PNG: " filePath)
            return filePath
        }
        
        if (this.PerformDownload(faviconUrl, filePath)) {
            return filePath
        }
        throw Error("PNG download failed")
    }
    
    /**
     * Check if a valid favicon already exists in cache
     */
    CheckCache(filePath) {
        if (FileExist(filePath) && FileGetSize(filePath) > 0) {
            return true
        }
        return false
    }
    
    /**
     * Execute the actual file download
     */
    PerformDownload(url, filePath) {
        ; Use URLDownloadToFile for reliable download
        result := DllCall("urlmon\URLDownloadToFileW", 
            "Ptr", 0, 
            "Str", url, 
            "Str", filePath, 
            "UInt", 0, 
            "Ptr", 0)
        
        ; Verify download success
        isSuccessful := (result = 0 && FileExist(filePath) && FileGetSize(filePath) > 0)
        
        if (isSuccessful) {
            this.LogEvent("Successfully downloaded: " url " → " filePath)
        }
        
        return isSuccessful
    }
    
    /**
     * Get file size in KB for convenience
     */
    GetFileSizeKB() {
        if (!this.FilePath || !FileExist(this.FilePath)) {
            return 0
        }
        return Round(FileGetSize(this.FilePath) / 1024, 2)
    }
    
    /**
     * Check if download was successful
     */
    IsDownloadSuccessful() {
        return (this.FilePath && FileExist(this.FilePath) && FileGetSize(this.FilePath) > 0)
    }
    
    /**
     * Get the downloaded file extension
     */
    GetFileExtension() {
        if (!this.FilePath) {
            return ""
        }
        
        SplitPath(this.FilePath, , , &ext)
        return StrLower(ext)
    }
    
    ; === UTILITY METHODS ===
    
    /**
     * Extract base URL from full URL
     */
    GetBaseUrl(url) {
        if (RegExMatch(url, "i)(https?://[^/]+)", &match)) {
            return match[1]
        }
        return url
    }
    
    /**
     * Extract domain from URL
     */
    ExtractDomain(url) {
        if (RegExMatch(url, "i)https?://(?:www\.)?([^/]+)", &match)) {
            return match[1]
        }
        return url
    }
    
    /**
     * Normalize URL format
     */
    NormalizeUrl(url) {
        url := Trim(url)
        if (!RegExMatch(url, "i)^https?://")) {
            url := "https://" url
        }
        return url
    }
    
    /**
     * Sanitize filename for filesystem compatibility
     */
    SanitizeFilename(filename) {
        ; Remove invalid characters
        filename := RegExReplace(filename, '[<>:"/\\|?*]', "_")
        filename := RegExReplace(filename, '\.+$', "")  ; Remove trailing dots
        filename := Trim(filename)
        
        ; Ensure filename is not empty
        if (!filename) {
            filename := "favicon_" FormatTime(, "yyyyMMdd_HHmmss")
        }
        
        return filename
    }
    
    /**
     * Ensure download directory exists
     */
    EnsureDirectoryExists() {
        if (!DirExist(this.DownloadPath)) {
            DirCreate(this.DownloadPath)
            this.LogEvent("Created download directory: " this.DownloadPath)
        }
    }
    
    /**
     * Log events if logging is enabled
     */
    LogEvent(message) {
        if (!this.LogEnabled) {
            return
        }
        
        try {
            timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
            logEntry := "[" timestamp "] " message "`n"
            FileAppend(logEntry, FaviconDownloader.LogFile)
        } catch {
            ; Silent fail for logging errors
        }
    }
    
    ; === STATIC UTILITY METHODS ===
    
    /**
     * Quick download method for simple use cases
     */
    static QuickDownload(url, filename := "", useCache := true) {
        if (!filename) {
            domain := FaviconDownloader.ExtractDomainStatic(url)
            filename := StrReplace(domain, ".", "_") "_quick"
        }
        
        return FaviconDownloader(filename, url, "auto", "", useCache)
    }
    
    /**
     * Static domain extraction for utility use
     */
    static ExtractDomainStatic(url) {
        if (RegExMatch(url, "i)https?://(?:www\.)?([^/]+)", &match)) {
            return match[1]
        }
        return url
    }
    
    /**
     * Check if a URL appears valid
     */
    static IsValidUrl(url) {
        if (!url) {
            return false
        }
        url := Trim(url)
        return RegExMatch(url, "i)^(https?://)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}")
    }
    
    /**
     * Clear the favicon cache directory
     */
    static ClearCache(downloadPath := "") {
        cachePath := downloadPath || FaviconDownloader.DefaultDownloadPath
        
        if (DirExist(cachePath)) {
            try {
                ; Delete all files in the cache directory
                Loop Files, cachePath "*.*" {
                    FileDelete(A_LoopFileFullPath)
                }
                return true
            } catch {
                return false
            }
        }
        return true
    }
    
    /**
     * Verify if cached icons exist for a specific domain
     * @param {String} domain - Domain to check (e.g. "github.com")
     * @param {String} downloadPath - Optional: Custom download directory
     * @return {Object} - Object with .ico and .png status
     */
    static CheckDomainCache(domain, downloadPath := "") {
        cachePath := downloadPath || FaviconDownloader.DefaultDownloadPath
        sanitizedDomain := StrReplace(domain, ".", "_")
        
        ; Initialize result object
        result := {ico: false, png: false, paths: {ico: "", png: ""}}
        
        ; Check for ICO files
        icoPattern := cachePath sanitizedDomain "*_favicon.ico"
        Loop Files, icoPattern {
            result.ico := true
            result.paths.ico := A_LoopFileFullPath
            break
        }
        
        ; Check for PNG files
        pngPattern := cachePath sanitizedDomain "*_favicon.png"
        Loop Files, pngPattern {
            result.png := true
            result.paths.png := A_LoopFileFullPath
            break
        }
        
        return result
    }
}