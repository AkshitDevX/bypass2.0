# Ensure script runs as Admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as Administrator!" -ForegroundColor Red
    exit
}

function Get-RandomName($ext) {
    return -join ((65..90) + (97..122) | Get-Random -Count 8 | ForEach-Object {[char]$_}) + $ext
}

# Get all imgui.ini files on the PC
$files = Get-ChildItem -Path C:\ -Recurse -Filter "imgui.ini" -Force -ErrorAction SilentlyContinue

foreach ($file in $files) {
    try {
        $originalPath = $file.FullName
        $currentPath = $originalPath

        # Step 1-3: Rename to random .txt 3 times
        for ($i = 0; $i -lt 3; $i++) {
            $newName = Get-RandomName ".txt"
            $newPath = Join-Path -Path $file.DirectoryName -ChildPath $newName
            Rename-Item -Path $currentPath -NewName $newName -Force
            $currentPath = $newPath
        }

        # Step 4: Rename to random .pf (prefetch-like)
        $pfName = Get-RandomName ".pf"
        $pfPath = Join-Path -Path $file.DirectoryName -ChildPath $pfName
        Rename-Item -Path $currentPath -NewName $pfName -Force
        $currentPath = $pfPath

        # Step 5: Rename to random .tmp and move to %TEMP%
        $tmpName = Get-RandomName ".tmp"
        $tempPath = Join-Path -Path $env:TEMP -ChildPath $tmpName
        Move-Item -Path $currentPath -Destination $tempPath -Force

        # Step 6: Set LastWriteTime and CreationTime to 3 days ago
        (Get-Item $tempPath).CreationTime = (Get-Date).AddDays(-3)
        (Get-Item $tempPath).LastWriteTime = (Get-Date).AddDays(-3)

        # Step 7: Delete the file
        Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue

        Write-Host "Sanitized and deleted: $originalPath  | GOD AKSHIT - COSERS CORPORATION | discord.gg/hindustan" -ForegroundColor Green
    }
    catch {
        Write-Host "Error handling $($file.FullName): $_| GOD AKSHIT - COSERS CORPORATION | discord.gg/hindustan" -ForegroundColor Red
    }
}
