<#
    ➤ Script by: GOD AKSHIT
    ➤ Discord: https://discord.gg/hindustan
    ➤ Action: Stealth multi-phase rename ➜ send to %TEMP% ➜ permanent delete
#>

function Get-RandomName($ext) {
    return -join ((48..57) + (65..90)) | Get-Random -Count 12 | ForEach-Object { [char]$_ } + ".$ext"
}

$FilesToHandle = @(
    "$env:USERPROFILE\imgui.ini",
    "$env:TEMP\adb.log",
    "C:\Windows\SystemApps\Microsoft.ECApp_8wekyb3d8bbwe\GazeInputInternal.dll",
    "C:\Windows\SystemApps\Microsoft.ECApp_8wekyb3d8bbwe\Gazentdll.dll",
    "C:\Windows\System32\Windows.Mirage.ntdll.dll",
    "C:\Windows\System32\Windows.Mirage.Internal.dll"
)

$TempPath = [System.IO.Path]::GetTempPath()

foreach ($file in $FilesToHandle) {
    if (Test-Path $file) {
        try {
            $txtName = Join-Path $TempPath (Get-RandomName "txt")
            $pngName = Join-Path $TempPath (Get-RandomName "png")
            $tmpName = Join-Path $TempPath (Get-RandomName "tmp")

            # Phase 1: Copy as .txt
            Copy-Item -Path $file -Destination $txtName -Force
            Remove-Item -Path $file -Force
            Start-Sleep -Milliseconds 300

            # Phase 2: Rename .txt ➜ .png
            Rename-Item -Path $txtName -NewName ([IO.Path]::GetFileName($pngName)) -Force
            Start-Sleep -Milliseconds 300

            # Phase 3: Rename .png ➜ .tmp
            Rename-Item -Path $pngName -NewName ([IO.Path]::GetFileName($tmpName)) -Force
            Start-Sleep -Milliseconds 300

            # Final Phase: Delete .tmp permanently
            Remove-Item -Path $tmpName -Force
            Write-Host "✅ Processed & deleted '$file' stealthily | CODERS CORP / CREDIT - GOD AKSHIT" -ForegroundColor Green
        } catch {
            Write-Host "⚠️ Error processing $file - $_ | CODERS CORP / CREDIT - GOD AKSHIT" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ File not found: $file | CODERS CORP / CREDIT - GOD AKSHIT" -ForegroundColor Red
    }
}
