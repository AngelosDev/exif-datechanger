@echo off
setlocal enabledelayedexpansion

REM Check if required tools are installed
where HandBrakeCLI >nul 2>&1 || (echo HandBrakeCLI is required but not installed. Aborting. && exit /b 1)
where exiftool >nul 2>&1 || (echo ExifTool is required but not installed. Aborting. && exit /b 1)

REM Prompt for directory
set /p "input_dir=Enter the directory path containing the videos: "

REM Prompt for HandBrake preset
echo.
echo Select a HandBrake preset:
echo 1. Fast 1080p30 (Default)
echo 2. HQ 1080p30 Surround
echo 3. Very Fast 1080p30
echo 4. Very Fast 720p30
echo 5. Fast 720p30
echo 6. Ultra Fast 1080p30
echo.
set /p "preset_choice=Enter the number of your chosen preset (or press Enter for default): "

if "%preset_choice%"=="" set "preset_choice=1"

if "%preset_choice%"=="1" (
    set "handbrake_preset=Fast 1080p30"
) else if "%preset_choice%"=="2" (
    set "handbrake_preset=HQ 1080p30 Surround"
) else if "%preset_choice%"=="3" (
    set "handbrake_preset=Very Fast 1080p30"
) else if "%preset_choice%"=="4" (
    set "handbrake_preset=Very Fast 720p30"
) else if "%preset_choice%"=="5" (
    set "handbrake_preset=Fast 720p30"
) else if "%preset_choice%"=="6" (
    set "handbrake_preset=Ultra Fast 1080p30"
) else (
    echo Invalid choice. Using default preset.
    set "handbrake_preset=Fast 1080p30"
)

echo Selected preset: %handbrake_preset%

REM List files with numbering, file size, and metadata created date
echo.
echo Files in the directory:
set /a count=0
for %%F in ("%input_dir%\*.mp4" "%input_dir%\*.avi" "%input_dir%\*.mov") do (
    set /a count+=1
    set "file[!count!]=%%F"
    set "size=%%~zF"
    set "size_mb=!size:~0,-6!.!size:~-6,2! MB"
    for /f "usebackq delims=" %%D in (`exiftool -s -s -s -CreateDate "%%F"`) do (
        echo !count!. %%~nxF - Size: !size_mb! - Created: %%D
    )
)
echo.
set /p "file_selection=Enter the numbers of the files to compress (e.g., 1,3,5 or 'all' for all files): "

REM Process selected files
set "temp_dir=%temp%\video_processing"
mkdir "%temp_dir%" 2>nul
set "summary_file=%temp_dir%\compression_summary.txt"
set "log_file=%temp_dir%\process_log.txt"
echo Video Compression Summary > "%summary_file%"
echo ========================== >> "%summary_file%"
echo Video Processing Log > "%log_file%"
echo ==================== >> "%log_file%"
echo Selected HandBrake preset: %handbrake_preset% >> "%log_file%"

if /i "%file_selection%"=="all" (
    for /L %%i in (1,1,%count%) do (
        call :ProcessFile "!file[%%i]!"
    )
) else (
    for %%N in (%file_selection%) do (
        call :ProcessFile "!file[%%N]!"
    )
)

REM Display summary
type "%summary_file%"
echo.
echo Process completed. Summary saved in: %summary_file%
echo Detailed log saved in: %log_file%

goto :eof

:ProcessFile
set "input_file=%~1"
set "output_file=%~dpn1_compressed.mp4"

echo.
echo Processing: "%input_file%"
echo.

echo [%date% %time%] Processing: "%input_file%" >> "%log_file%"

REM Display important metadata in console
echo.
echo Important metadata from input file:
echo ==================================
for %%T in (CreateDate FileModifyDate TrackCreateDate MediaCreateDate) do (
    exiftool -s -s -%%T "%input_file%"
)
echo.

REM Compress video
echo Compressing video...
HandBrakeCLI -i "%input_file%" -o "%output_file%" --preset="%handbrake_preset%" 2>> "%log_file%"
if %errorlevel% neq 0 (
    echo Error compressing video. Check log file for details.
    echo [%date% %time%] Error compressing "%input_file%" >> "%log_file%"
    goto :eof
)

REM Output the full path of the compressed video
echo.
echo Compressed video saved to: "%output_file%"
echo.

REM Copy metadata
echo Copying metadata...
call :MetadataCopy "%input_file%" "%output_file%"
if %errorlevel% neq 0 (
    echo Error copying metadata. Check log file for details.
    echo [%date% %time%] Error copying metadata from "%input_file%" to "%output_file%" >> "%log_file%"
    set "status=Metadata copy failed"
) else (
    set "status=Metadata successfully copied"
)

echo.
echo %~nx1: !status! >> "%summary_file%"
echo %~nx1: !status!
echo [%date% %time%] %~nx1: !status! >> "%log_file%"
echo.

goto :eof

:MetadataCopy
set "source_file=%~1"
set "destination_file=%~2"
exiftool -overwrite_original -TagsFromFile "%source_file%" "-all:all>all:all" "%destination_file%" 2>> "%log_file%"
exit /b %errorlevel%