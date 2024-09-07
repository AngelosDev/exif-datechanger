# Check if exiftool is installed
if (!(Get-Command exiftool -ErrorAction SilentlyContinue)) {
    Write-Host "Error: exiftool is not installed or not in PATH. Please run the Install-ExifTool script first."
    exit 1
}

# Check if a directory is provided
if ($args.Count -eq 0) {
    $directory = Read-Host "Enter the full path to the directory containing MP4 files"
} else {
    $directory = $args[0]
}

# Check if the directory exists
if (!(Test-Path -Path $directory -PathType Container)) {
    Write-Host "Error: Directory '$directory' does not exist."
    exit 1
}

# Function to get the current date from metadata
function Get-FileDate($file) {
    $date = exiftool -s -s -s -DateTimeOriginal $file
    if (!$date) {
        $date = exiftool -s -s -s -CreateDate $file
    }
    if (!$date) {
        $date = exiftool -s -s -s -ModifyDate $file
    }
    if (!$date) {
        $date = "No date found"
    }
    return $date
}

# Function to update a single file
function Update-SingleFile($file) {
    Write-Host "Processing file: $file"
    
    $current_date = Get-FileDate $file
    
    Write-Host "Current date in metadata: $current_date"
    $change_date = Read-Host "Do you want to change this date? (y/n)"
    if ($change_date -eq "y" -or $change_date -eq "Y") {
        $new_date = Read-Host "Enter new date (YYYY:MM:DD HH:MM:SS)"
        Update-FileDate $file $new_date
    }
    else {
        Write-Host "Skipped $file"
    }
    
    Write-Host ""
}

# Function to update file date
function Update-FileDate($file, $new_date) {
    # Construct the ExifTool command
    $exifCommand = "exiftool -overwrite_original -fast2 `"-DateTimeOriginal=$new_date`" `"-CreateDate=$new_date`" `"-ModifyDate=$new_date`" `"$file`""
    
    # Output the command
    Write-Host "Executing command:"
    Write-Host $exifCommand
    
    # Update the media created date using exiftool
    $result = Invoke-Expression $exifCommand
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Updated date for $file"
    }
    else {
        Write-Host "Failed to update date for $file"
        Write-Host $result
    }
}

# Get all MP4 files in the directory
$mp4Files = Get-ChildItem -Path $directory -Filter *.mp4

# Ask user if they want to bulk update or update individually
$bulkUpdate = Read-Host "Do you want to bulk update files? (y/n)"

if ($bulkUpdate -eq "y" -or $bulkUpdate -eq "Y") {
    # Bulk update
    Write-Host "Files in the directory:"
    for ($i = 0; $i -lt $mp4Files.Count; $i++) {
        $currentDate = Get-FileDate $mp4Files[$i].FullName
        Write-Host "[$i] $($mp4Files[$i].Name) - Current date: $currentDate"
    }
    
    $selection = Read-Host "Enter the numbers of the files you want to update (comma-separated, or 'all' for all files)"
    $new_date = Read-Host "Enter the date to set for all selected files (YYYY:MM:DD HH:MM:SS)"
    
    if ($selection -eq "all") {
        $selectedFiles = $mp4Files
    }
    else {
        $selectedIndices = $selection -split ',' | ForEach-Object { [int]$_.Trim() }
        $selectedFiles = $selectedIndices | ForEach-Object { $mp4Files[$_] }
    }
    
    foreach ($file in $selectedFiles) {
        Update-FileDate $file.FullName $new_date
    }
}
else {
    # Individual update
    foreach ($file in $mp4Files) {
        Update-SingleFile $file.FullName
    }
}

Write-Host "All MP4 files processed."