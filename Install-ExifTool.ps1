# Self-elevate the script if required
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

# Temporarily bypass the execution policy for this script
$oldPolicy = Get-ExecutionPolicy
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force

    # Define variables
    $exiftoolUrl = "https://exiftool.org/exiftool-12.50.exe"
    $installDir = "C:\Program Files\ExifTool"
    $exiftoolPath = Join-Path $installDir "exiftool.exe"

    # Create installation directory
    New-Item -ItemType Directory -Force -Path $installDir | Out-Null

    # Download ExifTool
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $exiftoolUrl -OutFile $exiftoolPath

    # Add to PATH
    $path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($path -notlike "*$installDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$path;$installDir", "Machine")
    }

    Write-Host "ExifTool has been installed and added to your PATH."
    Write-Host "Please restart your PowerShell or Command Prompt to use ExifTool."
    Write-Host "You can verify the installation by running 'exiftool -ver' in a new terminal window."

} finally {
    # Revert the execution policy
    Set-ExecutionPolicy $oldPolicy -Scope Process -Force
}

# Pause to keep the window open
Read-Host -Prompt "Press Enter to exit"