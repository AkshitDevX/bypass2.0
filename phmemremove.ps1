Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

public class MemTools {
    [Flags]
    public enum ProcessAccessFlags : uint {
        QueryInformation = 0x0400,
        VMRead = 0x0010,
        VMWrite = 0x0020,
        VMOperation = 0x0008
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct MEMORY_BASIC_INFORMATION {
        public IntPtr BaseAddress;
        public IntPtr AllocationBase;
        public uint AllocationProtect;
        public IntPtr RegionSize;
        public uint State;
        public uint Protect;
        public uint Type;
    }

    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenProcess(ProcessAccessFlags dwDesiredAccess, bool bInheritHandle, int dwProcessId);

    [DllImport("kernel32.dll")]
    public static extern bool ReadProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, int dwSize, out int lpNumberOfBytesRead);

    [DllImport("kernel32.dll")]
    public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, int dwSize, out int lpNumberOfBytesWritten);

    [DllImport("kernel32.dll")]
    public static extern int VirtualQueryEx(IntPtr hProcess, IntPtr lpAddress, out MEMORY_BASIC_INFORMATION lpBuffer, uint dwLength);
}
"@ -PassThru

function Wipe-ExactMemoryString {
    $target = [System.Text.Encoding]::ASCII.GetBytes("imgui\imgui.ini\ini")
    $targetLength = $target.Length

    $proc = Get-Process -Name "ProcessHacker" -ErrorAction SilentlyContinue
    if (!$proc) {
        Write-Host "[-] ProcessHacker.exe not found."
        return
    }

    $pid = $proc.Id
    $access = [MemTools+ProcessAccessFlags]::QueryInformation -bor `
              [MemTools+ProcessAccessFlags]::VMRead -bor `
              [MemTools+ProcessAccessFlags]::VMWrite -bor `
              [MemTools+ProcessAccessFlags]::VMOperation

    $hProc = [MemTools]::OpenProcess($access, $false, $pid)
    if ($hProc -eq [IntPtr]::Zero) {
        Write-Host "[-] Could not open Process Hacker."
        return
    }

    $addr = [IntPtr]::Zero
    $mbiSize = [System.Runtime.InteropServices.Marshal]::SizeOf([type]::GetType("MemTools+MEMORY_BASIC_INFORMATION"))

    while ($true) {
        $mbi = New-Object MemTools+MEMORY_BASIC_INFORMATION
        $res = [MemTools]::VirtualQueryEx($hProc, $addr, [ref]$mbi, [uint32]$mbiSize)

        if ($res -eq 0) { break }

        if ($mbi.State -eq 0x1000 -and $mbi.Protect -band 0x04 -eq 0 -and $mbi.Protect -band 0x100 -eq 0) {
            $regionSize = $mbi.RegionSize.ToInt32()
            $buffer = New-Object byte[] $regionSize
            [int]$bytesRead = 0

            if ([MemTools]::ReadProcessMemory($hProc, $mbi.BaseAddress, $buffer, $regionSize, [ref]$bytesRead)) {
                for ($i = 0; $i -le $bytesRead - $targetLength; $i++) {
                    $match = $true
                    for ($j = 0; $j -lt $targetLength; $j++) {
                        if ($buffer[$i + $j] -ne $target[$j]) {
                            $match = $false
                            break
                        }
                    }
                    if ($match) {
                        $nulls = New-Object byte[] $targetLength
                        [int]$bytesWritten = 0
                        [MemTools]::WriteProcessMemory($hProc, [IntPtr]::Add($mbi.BaseAddress, $i), $nulls, $targetLength, [ref]$bytesWritten) | Out-Null
                        Write-Host "[+] Wiped at offset 0x$("{0:X}" -f [IntPtr]::Add($mbi.BaseAddress, $i))| GOD AKSHIT - CODERS CORPORATION /discord.gg/hindustan"
                    }
                }
            }
        }

        $addr = [IntPtr]::Add($mbi.BaseAddress, $mbi.RegionSize.ToInt32())
    }

    Write-Host "[*] Scan complete.| GOD AKSHIT - CODERS CORPORATION /discord.gg/hindustan"
}

Wipe-ExactMemoryString
