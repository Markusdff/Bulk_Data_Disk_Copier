
**# Buld_Data_Disk_Copier**

This script automates the process of copying DVD contents to a selected destination folder. It continuously waits for a disc to be inserted, copies its contents, logs the process, and ejects the disc upon completion.

**Overview**
  This PowerShell script automates the process of copying DVD contents to a designated destination folder. It continuously monitors the selected DVD drive, detects when a new disc is inserted, copies its contents, logs the process, and ejects the disc upon completion. The script is designed to streamline the archiving of DVDs by minimizing manual intervention.  You can also run multiple instances of this script simultaneously if you have multiple optical drives.

**Features**
  Automatic Disc Detection: Waits for a new DVD to be inserted and starts the copying process automatically.
  Automated Copy Process: Uses robocopy to copy files efficiently while preserving metadata.
  Beep Notification: Alerts the user with a beep sound when the copying process is complete.
  Ejects Disc: Automatically ejects the disc after copying, prompting the user to insert the next one.
  Color-Coded Console Output: Improves readability with color-coded messages.
  Displays Disk Information:
  Shows used space of the inserted disc before copying.
  Displays the size of the destination folder after copying for comparison.
  Master Logging:
  Logs all script actions with timestamps.
  Saves logs in a file named DVD_Archive_MM-DD-YY_HH-MM-SS.txt in the script directory.
  Error Handling: Catches and logs errors during the copying process.

**Requirements**
  Windows 10 or later with PowerShell
  A DVD drive with readable discs
  robocopy (built into Windows)
  PowerShell execution policy set to allow script execution
  
**How It Works**

Drive Selection:
  The script detects available CD/DVD drives.
  The user selects the drive they wish to use for copying.

Destination Folder Selection:
  A folder browser window allows the user to select where the DVD contents should be archived. 

DVD Copy Process:
  The script waits for a disc to be inserted.
  It reads the disc’s volume label and available storage information.
  A new folder is created with the volume label as its name.
  The entire disc contents are copied to this folder.
  The script logs the copy operation, including source and destination file sizes.

Completion & Repeat:
  A beep alerts the user when copying is complete.
  The disc is ejected automatically.
  The script waits for the next disc and repeats the process.

Installation & Usage

  Download or Clone the Script:
    git clone https://github.com/your-repo/DVD-Archiving-Script.git
  
  Run PowerShell as Administrator.
  
  Set Execution Policy (if required):
  
  powershell
  Set-ExecutionPolicy Unrestricted -Scope Process
  
  Execute the Script:
  .\DVD_Archiving_Script.ps1
  
  Follow On-Screen Instructions:
    Select the DVD drive.
    Choose a destination folder.
    Insert a DVD and let the script handle the copying.
    When done, insert the next DVD.

Example Log Output
  [2025-02-03 14:30:01] Waiting for a new disc in drive D:...
  [2025-02-03 14:32:15] Detected Disc: Movie_Backup
  [2025-02-03 14:32:15] Used Space: 3.45 GB
  [2025-02-03 14:32:15] Destination Folder: C:\DVD_Backups\Movie_Backup
  [2025-02-03 14:45:52] Copy completed successfully.
  [2025-02-03 14:45:52] Destination Folder Size: 3.45 GB
  [2025-02-03 14:45:54] Beep sound notifying user!
  [2025-02-03 14:45:56] Drive D: has been ejected.
  [2025-02-03 14:45:56] Waiting for the next disc in drive D:...

Notes
  The script uses robocopy for copying, which is optimized for large file transfers.
  Destination folder names are based on the DVD’s volume label.
  The log file is saved in the same directory as the script.