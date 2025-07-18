# Must run with Admin for best effect
$ErrorActionPreference = "SilentlyContinue"

# File to erase from trace
$target = "ntdll.dll"
$targetLower = $target.ToLower()

# Get full recent folder path
$recentFolder = [Environment]::GetFolderPath("Recent")

# Remove .lnk from Recent
Get-ChildItem -Path $recentFolder -Filter "*.lnk" | ForEach-Object {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($_.FullName)
    if ($shortcut.TargetPath.ToLower().Contains($targetLower)) {
        Remove-Item $_.FullName -Force
        Write-Host "[+] Deleted Recent shortcut: $($_.Name)"
    }
}

# Remove from Quick Access / AutomaticDestinations Jump Lists
$jumpListPath = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"
Get-ChildItem -Path $jumpListPath -Filter "*.automaticDestinations-ms" | ForEach-Object {
    $filePath = $_.FullName
    $hex = [System.IO.File]::ReadAllBytes($filePath)

    $targetBytes = [System.Text.Encoding]::Unicode.GetBytes($target)
    $hexString = [BitConverter]::ToString($hex)
    $targetHex = [BitConverter]::ToString($targetBytes)

    if ($hexString -like "*$targetHex*") {
        Remove-Item $filePath -Force
        Write-Host "[+] Deleted JumpList: $($_.Name)"
    }
}

# Clear ShellBags MRU (Explorer Recent Usage)
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU" /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU" /f

# Clear Prefetch trace if exists
$prefetchFile = "$env:SystemRoot\Prefetch\NTDLL.DLL-*"
Remove-Item $prefetchFile -Force -ErrorAction SilentlyContinue

Write-Host "[✓] Attempted stealth cleanup of all known recent traces of 'ntdll.dll'| GOD AKSHIT - CODERS CORPORATION /discord.gg/hindustan"
