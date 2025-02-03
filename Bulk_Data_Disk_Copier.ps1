##########################################################################
# Enhanced DVD Archiving Script
# Features:
# - Beeps when a DVD copy completes
# - Color-coded output for clarity
# - Displays disk used space before copying
# - Shows copied folder size after completion
# - Creates a detailed log with timestamps
##########################################################################

Add-Type -AssemblyName System.Windows.Forms

# Generate log file name based on current timestamp
$timestamp = Get-Date -Format "MM-dd-yy_HH-mm-ss"
$logFile = Join-Path -Path $PSScriptRoot -ChildPath "DVD_Archive_$timestamp.txt"

# Function to log messages to file
function Write-Log {
    param ([string]$Message)
    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timeStamp] $Message"
    Add-Content -Path $logFile -Value $logEntry
}

function Restart-Script {
    Write-Host "`nRestarting script..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    Start-Process powershell.exe -ArgumentList @('-NoProfile','-File',$global:ScriptPath)
    exit
}

function Get-DriveUsedSpace {
    param ([string]$DriveLetter)
    
    $drive = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "${DriveLetter}:" }
    
    if ($drive -and $drive.Size -match '^\d+$' -and $drive.FreeSpace -match '^\d+$') {
        return "{0:N2} GB" -f (($drive.Size - $drive.FreeSpace) / 1GB)
    }
    
    return "Unknown"
}

function Get-FolderSize {
    param ([string]$FolderPath)
    if (Test-Path $FolderPath) {
        $size = (Get-ChildItem -Path $FolderPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
        return "{0:N2} GB" -f ($size / 1GB)
    }
    return "0 GB"
}

function Copy-DVDContents {
    param ([Parameter(Mandatory)] $DriveLetter, [Parameter(Mandatory)] $BaseDestination)

    while ($true) {
        Write-Host "`nWaiting for a new disc in drive ${DriveLetter}..." -ForegroundColor Cyan
        Write-Log "Waiting for a new disc in drive ${DriveLetter}..."

        while (-not (Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "${DriveLetter}:" -and $_.VolumeName -ne $null })) {
            Start-Sleep -Seconds 5
        }

        $drivePath = "${DriveLetter}:"
        $volumeLabel = (Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "${DriveLetter}:" }).VolumeName
        $usedSpace = Get-DriveUsedSpace -DriveLetter $DriveLetter

        if (-not $volumeLabel) { $volumeLabel = "Unknown_Disc" }
        $destinationPath = Join-Path -Path $BaseDestination -ChildPath $volumeLabel

        if (-not (Test-Path -Path $destinationPath)) {
            New-Item -ItemType Directory -Path $destinationPath | Out-Null
        }

        Write-Host "`nDetected Disc: $volumeLabel" -ForegroundColor Green
        Write-Host "Used Space: $usedSpace" -ForegroundColor Yellow
        Write-Host "Destination Folder: $destinationPath" -ForegroundColor Cyan
        Write-Log "Detected Disc: $volumeLabel, Used Space: $usedSpace, Destination: $destinationPath"

        Write-Host "`nCopying files from ${drivePath} to ${destinationPath}..." -ForegroundColor Magenta
        Write-Log "Starting copy from ${drivePath} to ${destinationPath}..."

        try {
            robocopy $drivePath $destinationPath /E /COPY:DAT /R:2 /W:2 /MT:8 /XJ /V /LOG:"${destinationPath}\copy_log.txt" | Out-Null
            Write-Host "Copy completed successfully." -ForegroundColor Green
            Write-Log "Copy completed successfully. Log saved to ${destinationPath}\copy_log.txt."
        } catch {
            Write-Host "Error copying files: $_" -ForegroundColor Red
            Write-Log "Error copying files: $_"
            return
        }

        $copiedSize = Get-FolderSize -FolderPath $destinationPath
        Write-Host "Destination Folder Size: $copiedSize" -ForegroundColor Cyan
        Write-Log "Destination Folder Size: $copiedSize"

        Start-Sleep -Seconds 2

        Write-Host "`nBeep sound notifying user!" -ForegroundColor Yellow
        [console]::beep(1000, 200)

        $ejectResult = (New-Object -comObject Shell.Application).Namespace(17).ParseName($drivePath)
        if ($ejectResult -ne $null) {
            $ejectResult.InvokeVerb("Eject")
            Write-Host "Drive ${DriveLetter} has been ejected." -ForegroundColor Green
            Write-Log "Drive ${DriveLetter} has been ejected."
        } else {
            Write-Host "Failed to eject drive ${DriveLetter}." -ForegroundColor Red
            Write-Log "Failed to eject drive ${DriveLetter}."
        }

        Write-Host "`nWaiting for the next disc in drive ${DriveLetter}..." -ForegroundColor Cyan
        Write-Log "Waiting for the next disc in drive ${DriveLetter}..."
    }
}

function Select-Drive {
    while ($true) {
        CLS
        Write-Host "`nDetecting available CD/DVD drives..." -ForegroundColor Cyan
        $drives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 5 }

        if (!$drives) {
            Write-Host "No CD/DVD drives detected." -ForegroundColor Red
        } else {
            Write-Host "`nAvailable CD/DVD drives:" -ForegroundColor Green
            $drives | ForEach-Object { Write-Host "$($_.DeviceID) - $($_.VolumeName)" -ForegroundColor Yellow }
        }

        Write-Host "`n[R] Restart script" -ForegroundColor Magenta
        Write-Host "[X] Exit" -ForegroundColor Magenta
        $choice = Read-Host "`nEnter the drive letter to copy from (e.g., D), 'R' to restart, or 'X' to exit"

        switch ($choice.ToUpper()) {
            'R' { Restart-Script }
            'X' { Write-Host "Exiting program." -ForegroundColor Red; exit }
            default {
                if ($choice -match '^[A-Z]$') { return $choice }
                Write-Host "Invalid option. Try again." -ForegroundColor Red
            }
        }
    }
}

$driveLetter = Select-Drive
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = "Select the destination folder to copy DVD contents to:"
$folderBrowser.ShowNewFolderButton = $true

if ($folderBrowser.ShowDialog() -ne "OK") {
    Write-Host "No destination selected. Exiting..." -ForegroundColor Red
    exit
}

$baseDestination = $folderBrowser.SelectedPath

Write-Host "`nSelected drive: ${driveLetter}:" -ForegroundColor Green
Write-Host "Selected destination: $baseDestination" -ForegroundColor Cyan
Write-Log "Selected drive: ${driveLetter}, Destination: $baseDestination"

Write-Host "`nInsert a disc into drive ${driveLetter} to begin copying." -ForegroundColor Yellow
Write-Log "Insert a disc into drive ${driveLetter} to begin copying."

Copy-DVDContents -DriveLetter $driveLetter -BaseDestination $baseDestination
