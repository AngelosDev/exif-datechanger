# Video Processing and Metadata Management Scripts

This repository contains a collection of scripts for video processing and metadata management, primarily focused on compressing videos while retaining metadata and updating MP4 file dates.

## Scripts Overview

1. **compress-video-and-retain.bat**: Compresses video files while retaining their original metadata.
2. **Install-ExifTool.ps1**: PowerShell script to install ExifTool.
3. **Run-InstallExifTool.bat**: Batch file to run the ExifTool installation script.
4. **Update-MP4Dates.ps1**: PowerShell script to update dates in MP4 files.
5. **Run-UpdateMP4Dates.bat**: Batch file to run the MP4 date update script.

## Prerequisites

- Windows operating system
- PowerShell (for running .ps1 scripts)
- Administrator privileges (for installing ExifTool)

## Installation

### Installing ExifTool

1. Run the `Run-InstallExifTool.bat` file.
2. This will execute the `Install-ExifTool.ps1` script with elevated privileges.
3. The script will download and install ExifTool, and add it to your system PATH.

### Installing HandBrakeCLI (required for video compression)

1. Visit the [HandBrake website](https://handbrake.fr/downloads.php) and download the latest version of HandBrake for Windows.
2. During installation, make sure to select the option to install HandBrakeCLI.
3. Add the HandBrakeCLI installation directory to your system's PATH environment variable.

## Usage

### Compressing Videos and Retaining Metadata

1. Double-click the `compress-video-and-retain.bat` script or run it from the command prompt.
2. Follow the on-screen prompts:
   a. Enter the full path of the directory containing the video files.
   b. Select a HandBrake preset from the provided list.
   c. Choose which files to compress by entering their numbers or 'all' for all files.
3. The script will process each selected file, compressing the video and retaining the original metadata.

### Updating MP4 File Dates

1. Double-click the `Run-UpdateMP4Dates.bat` file or run it from the command prompt.
2. This will execute the `Update-MP4Dates.ps1` script.
3. Follow the on-screen prompts:
   a. Enter the full path to the directory containing MP4 files.
   b. Choose between bulk update or individual file updates.
   c. For bulk updates, select files and enter a new date.
   d. For individual updates, review and update dates for each file as needed.

## Script Details

### compress-video-and-retain.bat

This script compresses video files using HandBrake while preserving the original metadata using ExifTool. It allows selection of different HandBrake presets and provides detailed logging of the process.

### Install-ExifTool.ps1

This PowerShell script automates the installation of ExifTool. It downloads the latest version, sets it up in the Program Files directory, and adds it to the system PATH.

### Run-InstallExifTool.bat

A simple batch file that runs the `Install-ExifTool.ps1` script with elevated privileges and bypasses the PowerShell execution policy.

### Update-MP4Dates.ps1

This PowerShell script allows users to update the metadata dates (DateTimeOriginal, CreateDate, ModifyDate) of MP4 files. It supports both bulk updates and individual file processing.

### Run-UpdateMP4Dates.bat

A batch file that executes the `Update-MP4Dates.ps1` script, bypassing the PowerShell execution policy.

## Troubleshooting

- If you encounter "command not found" errors, ensure that HandBrakeCLI and ExifTool are correctly installed and added to your system's PATH.
- For permission issues, try running the scripts as an administrator.
- Check the generated log files (for the compression script) for detailed error information.

## Additional Notes

- Compressed videos are saved with a `_compressed` suffix in the same directory as the original files.
- The compression script creates temporary files in the Windows temp directory, which are not automatically deleted to allow for post-processing inspection.
- Always ensure you have backups of your original files before running these scripts.

For any other issues or questions, please refer to the individual script comments or open an issue in this repository.
