# Windows PowerShell Script - Sync photos and generate JSON
# Usage: Run directly or via .bat

param(
    [string]$Src = "photos",
    [string]$Dst = "photos",
    [string]$JsonPath = "gallery.json"
)

$ErrorActionPreference = "Stop"

# 1. Ensure paths exist
$SrcPath = Resolve-Path $Src -ErrorAction SilentlyContinue
if (-not $SrcPath) {
    Write-Host "Error: Source directory '$Src' does not exist!" -ForegroundColor Red
    exit 1
}
$DstPath = $Dst
if (-not (Test-Path $DstPath)) {
    New-Item -ItemType Directory -Path $DstPath | Out-Null
}
$DstAbsPath = Resolve-Path $DstPath

# 2. Supported extensions
$ImageExts = @(".jpg", ".jpeg", ".png", ".webp", ".gif", ".avif")

Write-Host "Scanning photos..." -ForegroundColor Cyan

# 3. Scan source files
$Files = @(Get-ChildItem -Path $SrcPath -Recurse -File | Where-Object { 
    $ext = $_.Extension.ToLower()
    $ImageExts -contains $ext -and $_.Name -notmatch "^\\."
})

$Photos = @()
$Count = 0

# Sort files
$FileList = $Files | Sort-Object LastWriteTime -Descending

foreach ($File in $FileList) {
    # Calculate relative path for web access
    $Url = ""
    
    if ($File.DirectoryName.StartsWith($DstAbsPath.Path)) {
        # File is inside the destination folder (in-place update)
        $RelPath = $File.FullName.Substring($DstAbsPath.Path.Length + 1).Replace("\", "/")
        $Url = "$Dst/$RelPath"
    } else {
        # File is outside. For now we skip copying logic and warn user
        # In a full sync tool we would copy it, but here we assume user put photos in 'photos' folder
        Write-Warning "Skipping file outside '$Dst': $($File.FullName)"
        continue
    }

    # Extract date
    $DateStr = ""
    # Try filename YYYYMMDD or YYYY-MM-DD
    if ($File.Name -match "(\d{4})[-_]?(\d{2})[-_]?(\d{2})") {
        $Y = $Matches[1]
        $M = $Matches[2]
        $D = $Matches[3]
        $DateStr = "$Y-$M-$D"
    } else {
        # Use modification time
        $DateStr = $File.LastWriteTime.ToString("yyyy-MM-dd")
    }
    
    # Generate caption
    $Caption = $File.BaseName -replace "[-_]", " "
    
    $Photos += @{
        src = $Url
        caption = $Caption
        date = $DateStr
        place = ""
    }
    $Count++
}

# 4. Generate JSON
$Data = @{
    updated_at = (Get-Date).ToString("yyyy-MM-dd")
    photos = $Photos
}

$JsonContent = $Data | ConvertTo-Json -Depth 3

$JsonFile = [System.IO.Path]::GetFullPath($JsonPath)
[System.IO.File]::WriteAllText($JsonFile, $JsonContent, [System.Text.Encoding]::UTF8)

Write-Host "Processed $Count photos." -ForegroundColor Green
Write-Host "JSON updated: $JsonPath" -ForegroundColor Gray
