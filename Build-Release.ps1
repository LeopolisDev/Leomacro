param(
    [string]$ReleaseDir = (Join-Path $PSScriptRoot 'release')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path $PSScriptRoot).Path
$macroRoot = Join-Path $repoRoot 'TDS_Macro'

$mainAhk = Join-Path $macroRoot 'Main.ahk'
$iconPath = Join-Path $macroRoot 'icon.ico'
$resourcesPath = Join-Path $macroRoot 'Resources'
$libPath = Join-Path $macroRoot 'lib'
$submacrosPath = Join-Path $macroRoot 'submacros'
$licensePath = Join-Path $macroRoot 'LICENSE'
$readmePath = Join-Path $macroRoot 'README.md'

function Get-FirstExistingPath {
    param(
        [string[]]$Candidates
    )

    foreach ($candidate in $Candidates) {
        if ([string]::IsNullOrWhiteSpace($candidate)) {
            continue
        }
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    return $null
}

function Copy-Tree {
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Missing required folder: $Source"
    }

    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Copy-Item -Path (Join-Path $Source '*') -Destination $Destination -Recurse -Force
}

$compilerCommand = Get-Command Ahk2Exe.exe -ErrorAction SilentlyContinue
$compiler = Get-FirstExistingPath @(
    $(if ($compilerCommand) { $compilerCommand.Source } else { $null }),
    'C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe',
    'C:\Program Files\AutoHotkey\v2\Compiler\Ahk2Exe.exe'
)

if (-not $compiler) {
    throw "Could not find Ahk2Exe.exe. Install AutoHotkey v2 with the compiler, or update Build-Release.ps1 with your compiler path."
}

$runtime = Get-FirstExistingPath @(
    'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe',
    'C:\Program Files\AutoHotkey\v2\AutoHotkey.exe'
)

if (-not $runtime) {
    throw "Could not find the AutoHotkey v2 runtime EXE."
}

if (-not (Test-Path -LiteralPath $mainAhk)) {
    throw "Missing main script: $mainAhk"
}

$releaseFull = [System.IO.Path]::GetFullPath($ReleaseDir)
if (-not $releaseFull.StartsWith($repoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Release folder must stay inside the repository root."
}

if (Test-Path -LiteralPath $releaseFull) {
    Remove-Item -LiteralPath $releaseFull -Recurse -Force
}

New-Item -ItemType Directory -Path $releaseFull -Force | Out-Null

Copy-Tree -Source $resourcesPath -Destination (Join-Path $releaseFull 'Resources')
Copy-Tree -Source $libPath -Destination (Join-Path $releaseFull 'lib')
Copy-Tree -Source $submacrosPath -Destination (Join-Path $releaseFull 'submacros')

Copy-Item -LiteralPath $iconPath -Destination (Join-Path $releaseFull 'icon.ico')
Copy-Item -LiteralPath $licensePath -Destination (Join-Path $releaseFull 'LICENSE')
Copy-Item -LiteralPath $readmePath -Destination (Join-Path $releaseFull 'README.md')
Copy-Item -LiteralPath $mainAhk -Destination (Join-Path $releaseFull 'Main.ahk')

$outputExe = Join-Path $releaseFull 'Leomacro.exe'

& $compiler '/in' $mainAhk '/out' $outputExe '/icon' $iconPath '/bin' $runtime

Write-Host "Release folder is ready: $releaseFull"
Write-Host "Compiled executable: $outputExe"
