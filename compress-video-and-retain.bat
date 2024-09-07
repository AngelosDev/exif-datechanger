@echo off
setlocal enabledelayedexpansion

REM Check if required tools are installed
where HandBrakeCLI >nul 2>&1 || (echo HandBrakeCLI is required but not installed. Aborting. && exit /b 1)
where exiftool >nul 2>&1 || (echo ExifTool is required but not installed. Aborting. && exit /b 1)

REM Prompt for directory
set /p "input_dir=Enter the directory path containing the videos: "

REM List files with numbering, file size, and metadata created date
echo.
echo Files in the directory:
set /a count=0
for %%F in ("%input_dir%\*.mp4" "%input_dir%\*.avi" "%input_dir%\*.mov") do (
    set /a count+=1
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
echo Video Compression Summary > "%summary_file%"
echo ========================== >> "%summary_file%"

if /i "%file_selection%"=="all" (
    for %%F in ("%input_dir%\*.mp4" "%input_dir%\*.avi" "%input_dir%\*.mov") do (
        call :ProcessFile "%%F"
    )
) else (
    for %%N in (%file_selection%) do (
        set /a count=0
        for %%F in ("%input_dir%\*.mp4" "%input_dir%\*.avi" "%input_dir%\*.mov") do (
            set /a count+=1
            if !count!==%%N call :ProcessFile "%%F"
        )
    )
)

REM Display summary
type "%summary_file%"
echo.
echo Process completed. Summary saved in: %summary_file%

REM Clean up
rmdir /s /q "%temp_dir%"

goto :eof

:ProcessFile
set "input_file=%~1"
set "output_file=%~dpn1_compressed.mp4"
set "metadata_file=%temp_dir%\%~n1_metadata.txt"

echo.
echo Processing: %input_file%
echo Metadata will be stored in: %metadata_file%
echo.

REM Extract metadata
echo Extracting metadata...
exiftool -all:all -G3 -a "%input_file%" > "%metadata_file%"

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
HandBrakeCLI -i "%input_file%" -o "%output_file%" -e x264 -q 22 -B 160

REM Apply metadata
echo Applying metadata...
exiftool -overwrite_original -TagsFromFile "%metadata_file%" "-all:all>all:all" "%output_file%"

REM Verify metadata
echo.
echo Verifying metadata...
echo ====================
set "important_tags=CreateDate FileModifyDate TrackCreateDate MediaCreateDate"
for %%T in (%important_tags%) do (
    for /f "usebackq delims=" %%A in (`exiftool -s -s -s -%%T "%input_file%"`) do set "input_%%T=%%A"
    for /f "usebackq delims=" %%B in (`exiftool -s -s -s -%%T "%output_file%"`) do set "output_%%T=%%B"
    if "!input_%%T!"=="!output_%%T!" (
        echo %%T: Matched
    ) else (
        echo %%T: Mismatch
        echo   Input:  !input_%%T!
        echo   Output: !output_%%T!
        echo Metadata mismatch for %%T >> "%summary_file%"
        set "status=Metadata application incomplete"
    )
)

if not defined status (
    set "status=Metadata successfully applied"
)

echo.
echo %~nx1: !status! >> "%summary_file%"
echo %~nx1: !status!
echo.

goto :eof