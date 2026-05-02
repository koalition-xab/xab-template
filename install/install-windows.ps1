param(
    [switch]$Help,
    [switch]$Check,
    [switch]$Uninstall,
    [switch]$Force,
    [switch]$Yes,
    [string]$Path = ""
)

$ErrorActionPreference = "Stop"

########## XAB-TEMPLATE: INSTALL SCRIPT FOR WINDOWS SYSTEMS ##########

########## COLORS & OUTPUT ##########
function Write-Info { param($msg) Write-Host "  $msg"         -ForegroundColor Cyan }
function Write-Ok   { param($msg) Write-Host "  `u{2713} $msg" -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host "  `u{26A0} $msg" -ForegroundColor Yellow }
function Write-Err  { param($msg) Write-Host "  `u{2717} $msg" -ForegroundColor Red }

########## SPINNER ##########
function Invoke-WithSpinner {
    param([string]$Message, [string[]]$GitArgs)

    $tmpErr = [System.IO.Path]::GetTempFileName()

    $proc = Start-Process -FilePath "git" -ArgumentList $GitArgs `
        -RedirectStandardOutput "NUL" -RedirectStandardError $tmpErr `
        -NoNewWindow -PassThru

    $frames = @('⠋','⠙','⠹','⠸','⠼','⠴','⠦','⠧','⠇','⠏')
    $i = 0
    while (-not $proc.HasExited) {
        [Console]::Write("`r  $($frames[$i % $frames.Length]) $Message")
        $i++
        Start-Sleep -Milliseconds 100
    }
    $proc.WaitForExit()
    [Console]::Write("`r" + (" " * ($Message.Length + 6)) + "`r")

    if ($proc.ExitCode -ne 0) {
        Write-Err $Message
        Get-Content $tmpErr | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
        Remove-Item $tmpErr -ErrorAction SilentlyContinue
        Write-Host ""
        Write-Host "#################### Install failed :( ####################" -ForegroundColor Red
        exit $proc.ExitCode
    }

    Write-Ok $Message
    Remove-Item $tmpErr -ErrorAction SilentlyContinue
}

########## HELPERS ##########
function Confirm-Action {
    param([string]$Prompt, [string]$Default = "n")
    if ($Yes) { return $true }
    if ($Default -eq "y") {
        $response = Read-Host "  $Prompt [Y/n]"
        if ($response -eq "") { $response = "y" }
    } else {
        $response = Read-Host "  $Prompt [y/N]"
        if ($response -eq "") { $response = "n" }
    }
    return $response -match "^[Yy]$"
}

function Show-SubmoduleIssues {
    param($Issues)
    foreach ($line in $Issues) {
        $prefix = $line[0]
        $sha    = $line.Substring(1, 40)
        $path   = ($line.Substring(42) -split ' ')[0]
        switch ($prefix) {
            '-' { Write-Host "      ${path}: not initialised — files are missing" -ForegroundColor DarkGray }
            '+' {
                $expected = (git -C $TARGET rev-parse "HEAD:${path}" 2>$null)
                if ($LASTEXITCODE -eq 0 -and $expected) { $expected = $expected.Substring(0,7) } else { $expected = "unknown" }
                Write-Host "      ${path}: wrong commit — got $($sha.Substring(0,7)), template expects ${expected}" -ForegroundColor DarkGray
            }
            'U' { Write-Host "      ${path}: has unresolved merge conflicts" -ForegroundColor DarkGray }
        }
    }
}

function Show-Usage {
    Write-Host "Usage: install-windows.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Help          Show this help message"
    Write-Host "  -Check         Check for updates without installing"
    Write-Host "  -Uninstall     Remove the installed template"
    Write-Host "  -Force         Remove existing installation and reinstall from scratch"
    Write-Host "  -Yes           Non-interactive: answer yes to all prompts"
    Write-Host "  -Path <dir>    Custom install path"
}

function Invoke-FontCheck {
    $systemFonts = "$env:SystemRoot\Fonts"
    $userFonts   = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $missing = @()
    foreach ($font in $RequiredFonts) {
        $found = $false
        foreach ($dir in @($systemFonts, $userFonts)) {
            if ((Test-Path $dir) -and (Get-ChildItem $dir -ErrorAction SilentlyContinue |
                Where-Object { $_.BaseName -like "*$($font.Pattern)*" })) {
                $found = $true; break
            }
        }
        if (-not $found) { $missing += $font.Name }
    }
    if ($missing.Count -eq 0) {
        Write-Ok "All required fonts are installed"
    } else {
        Write-Warn "Missing required fonts:"
        $missing | ForEach-Object { Write-Host "      • $_" -ForegroundColor DarkGray }
    }
}

function Print-Summary {
    $version = (git -C $TARGET describe --tags --always 2>$null)
    if (-not $version) { $version = (git -C $TARGET rev-parse --short HEAD) }
    Write-Host ""
    Write-Host "  ──────────────────────────────────────────" -ForegroundColor White
    Write-Host "  Installed to:  " -NoNewline; Write-Host $TARGET  -ForegroundColor Cyan
    Write-Host "  Version:       " -NoNewline; Write-Host $version -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Add to your typst document:"
    Write-Host "  #import `"@local/xab-template:$VERSION`": *" -ForegroundColor DarkGray
    Write-Host "  ──────────────────────────────────────────" -ForegroundColor White
    Write-Host ""
}

########## VARIABLES ##########
$LINK        = "https://github.com/koalition-xab/xab-template.git"
$VERSION     = "1.0.0"
$DESTINATION = if ($Path -ne "") { "$Path\" } else { "$env:APPDATA\typst\packages\local\xab-template\" }
$TARGET      = "$DESTINATION$VERSION"
$RequiredFonts = @(
    @{ Name = "Open Sans";     Pattern = "OpenSans" },
    @{ Name = "Montserrat";    Pattern = "Montserrat" },
    @{ Name = "STIX Two Math"; Pattern = "STIXTwoMath" }
)

########## SCRIPT ##########
if ($Help) { Show-Usage; exit 0 }

Write-Host ""
Write-Host "#################### XAB TEMPLATE INSTALLER ####################" -ForegroundColor White
Write-Host ""

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Err "git is required but not installed."
    exit 1
}

if ($Check) {
    if (-not (Test-Path "$TARGET\.git")) {
        Write-Warn "Not installed — run without -Check to install"
        Write-Host ""
        exit 0
    }
    Write-Info "Fetching remote version info..."
    $localSha        = (git -C $TARGET rev-parse HEAD).Trim()
    $remoteShaLine   = git ls-remote $LINK HEAD
    if ($LASTEXITCODE -ne 0) { Write-Err "Failed to reach remote."; exit 1 }
    $remoteSha       = ($remoteShaLine -split '\s+')[0]
    $submoduleIssues = git -C $TARGET submodule status --recursive | Where-Object { $_ -match '^[-+U]' }
    Write-Host ""
    Write-Host "  Installed: $($localSha.Substring(0,7))" -ForegroundColor White
    Write-Host "  Latest:    $($remoteSha.Substring(0,7))" -ForegroundColor White
    Write-Host ""
    if ($localSha -ne $remoteSha) {
        Write-Warn "Update available — run without -Check to update"
    }
    if ($submoduleIssues) {
        Write-Warn "Submodule issues detected:"
        Show-SubmoduleIssues $submoduleIssues
    }
    if (($localSha -eq $remoteSha) -and (-not $submoduleIssues)) {
        Write-Ok "Installation complete — everything is up to date"
    }
    Invoke-FontCheck
    Write-Host ""
    exit 0
}

if ($Uninstall) {
    if (-not (Test-Path $TARGET)) {
        Write-Warn "No installation found at $TARGET"
        exit 0
    }
    if (Confirm-Action "Remove installation at ${TARGET}?" "n") {
        Remove-Item -Recurse -Force $TARGET
        Write-Ok "Uninstalled successfully"
    } else {
        Write-Info "Aborted."
    }
    exit 0
}

New-Item -ItemType Directory -Force -Path $DESTINATION | Out-Null

if ($Force -and (Test-Path $TARGET)) {
    if (Confirm-Action "Remove existing installation at ${TARGET} and reinstall?" "n") {
        Remove-Item -Recurse -Force $TARGET
    } else {
        Write-Info "Aborted."
        exit 0
    }
}

if (Test-Path "$TARGET\.git") {
    $localChanges    = git -C $TARGET status --porcelain | Where-Object { $_ -notmatch '^\?\?' }
    $submoduleIssues = git -C $TARGET submodule status --recursive | Where-Object { $_ -match '^[-+U]' }
    $localSha        = (git -C $TARGET rev-parse HEAD).Trim()
    $remoteShaLine   = git ls-remote $LINK HEAD
    if ($LASTEXITCODE -ne 0) { Write-Err "Failed to reach remote."; exit 1 }
    $remoteSha       = ($remoteShaLine -split '\s+')[0]
    $needsPull       = $localSha -ne $remoteSha

    if ((-not $localChanges) -and (-not $submoduleIssues) -and (-not $needsPull)) {
        Write-Ok "Already up to date — installation complete ($($localSha.Substring(0,7)))"
        Invoke-FontCheck
        Write-Host ""
        exit 0
    }

    Write-Host ""
    Write-Warn "The following issues were found:"
    if ($needsPull) {
        Write-Host "  ⚠ Update available: $($localSha.Substring(0,7)) → $($remoteSha.Substring(0,7))" -ForegroundColor Yellow
    }
    if ($submoduleIssues) {
        Write-Host "  ⚠ Submodule issues:" -ForegroundColor Yellow
        Show-SubmoduleIssues $submoduleIssues
    }
    if ($localChanges) {
        Write-Host "  ⚠ Uncommitted local changes:" -ForegroundColor Yellow
        $localChanges | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    }
    Write-Host ""
    if (-not (Confirm-Action "Proceed and apply fixes?" "y")) {
        Write-Info "Aborted."
        exit 0
    }

    if ($localChanges) {
        Invoke-WithSpinner "Resetting local changes"  @("-C", $TARGET, "reset", "--hard", "HEAD")
    }
    if ($needsPull) {
        Invoke-WithSpinner "Pulling latest changes"   @("-C", $TARGET, "pull", "--ff-only")
    }
    Invoke-WithSpinner "Syncing submodule URLs"       @("-C", $TARGET, "submodule", "sync", "--recursive")
    Invoke-WithSpinner "Updating submodules"          @("-C", $TARGET, "submodule", "update", "--init", "--recursive")

    $newSha = (git -C $TARGET rev-parse HEAD).Trim()
    if ($localSha -ne $newSha) {
        Write-Host ""
        Write-Info "What changed:"
        git -C $TARGET log --oneline "${localSha}..${newSha}" | ForEach-Object {
            Write-Host "    • $_" -ForegroundColor DarkGray
        }
    }
} elseif (Test-Path $TARGET) {
    Write-Err "Target path exists but is not a git repository: $TARGET"
    Write-Err "Please remove it manually or use -Force to reinstall."
    exit 1
} else {
    Write-Host ""
    Write-Info "Template will be installed to $TARGET"
    Write-Host ""
    if (-not (Confirm-Action "Proceed with installation?" "y")) {
        Write-Info "Aborted."
        exit 0
    }
    Invoke-WithSpinner "Cloning repository"      @("clone", $LINK, $TARGET)
    Invoke-WithSpinner "Initialising submodules" @("-C", $TARGET, "submodule", "update", "--init", "--recursive")
}

########## FINISH ##########
Print-Summary
Invoke-FontCheck
Write-Host "#################### All done :) ####################" -ForegroundColor Green
Write-Host ""
