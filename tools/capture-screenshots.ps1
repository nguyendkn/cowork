# Regenerates the screenshots used by the docs from the real app.
#
#   pwsh docs/tools/capture-screenshots.ps1                  # every scene
#   pwsh docs/tools/capture-screenshots.ps1 -Scene editor,find
#
# Needs a built app (`make build`). The script drives the real window with the mouse and
# keyboard for about a minute, so leave the machine alone while it runs. The app uses a
# throw-away config dir: your own session, keymap and command history never show up.

param(
    [string]$Exe = (Join-Path $PSScriptRoot "..\..\target\debug\app.exe"),
    [string]$OutDir = (Join-Path $PSScriptRoot "..\src\images"),
    [string[]]$Scene = @()
)

. (Join-Path $PSScriptRoot "ui-driver.ps1")
$Exe = (Resolve-Path $Exe).Path
$OutDir = [IO.Path]::GetFullPath($OutDir)
# The terminal prompt and the browser address bar show paths, so run from a neutral folder
# instead of the developer's home.
$Demo = "C:\Users\Public\cowork-demo"
New-Item -ItemType Directory -Force -Path $Demo | Out-Null
Copy-Item (Join-Path $PSScriptRoot "sample-page.html") (Join-Path $Demo "welcome.html") -Force
$SamplePage = Join-Path $Demo "welcome.html"
$Config = Join-Path $Demo "config"   # shown on the Settings page, so keep it neutral too

. (Join-Path $PSScriptRoot "ui-layout.ps1")

$Notes = "# Release checklist`n`nTODO: update the changelog`nTODO: bump the version in Cargo.toml`nTODO: tag the release`n`nContact: team@example.com"

function Want([string]$name) { ($Scene.Count -eq 0) -or ($Scene -contains $name) }
function Out([string]$name) { Join-Path $OutDir "$name.png" }

# A fresh app with the sample note open in a text tab, caret at the top.
function Open-Editor {
    Start-Cowork -Exe $Exe -ConfigDir $Config -WorkingDirectory $Demo
    Click-At $LauncherText[0] $LauncherText[1]
    Type-Text $Notes
    Press "^{HOME}"
}

if (Want "launcher") {
    Start-Cowork -Exe $Exe -ConfigDir $Config -WorkingDirectory $Demo
    Save-Shot (Out "launcher")
    Stop-Cowork
}

if (Want "editor") {
    Open-Editor
    Save-Shot (Out "editor")
    Save-Shot (Out "status-bar") -Y 770 -H 22
    Save-Shot (Out "tab-bar") -Y 32 -H 30
    Stop-Cowork
}

if (Want "find") {
    Open-Editor
    Press "^f"
    Type-Text "TODO"
    Save-Shot (Out "find") -H 290
    Stop-Cowork
}

if (Want "replace") {
    Open-Editor
    Press "^h"
    Type-Text "TODO"
    Click-At $ReplaceInput[0] $ReplaceInput[1]
    Type-Text "DONE"
    Save-Shot (Out "replace") -H 290
    Stop-Cowork
}

if (Want "go-to-line") {
    Open-Editor
    Press "^g"
    Type-Text "4"
    Save-Shot (Out "go-to-line") -H 290
    Stop-Cowork
}

if (Want "palette") {
    Open-Editor
    Press "^+p"
    Save-Shot (Out "command-palette")
    Type-Text "dupl"
    Save-Shot (Out "command-palette-search")
    Stop-Cowork
}

if (Want "shortcuts") {
    Open-Editor
    Click-At $StatusKeyboardShortcuts[0] $StatusKeyboardShortcuts[1]
    Save-Shot (Out "keyboard-shortcuts")
    Click-At $ShortcutRowKeys[0] $ShortcutRowKeys[1]
    Save-Shot (Out "shortcut-rebind")
    Stop-Cowork
}

if (Want "panes") {
    Open-Editor
    Press "^\"
    Press "^k{DOWN}"
    Save-Shot (Out "split-panes")
    Stop-Cowork
}

if (Want "terminal") {
    Start-Cowork -Exe $Exe -ConfigDir $Config -WorkingDirectory $Demo
    Click-At $LauncherTerminal[0] $LauncherTerminal[1]
    Start-Sleep -Seconds 2
    Type-Text "echo 'Hello from Cowork'`n" -Wait 1200
    Save-Shot (Out "terminal")
    Stop-Cowork
}

if (Want "browser") {
    Start-Cowork -Exe $Exe -ConfigDir $Config -WorkingDirectory $Demo
    Click-At $LauncherBrowser[0] $LauncherBrowser[1]
    Start-Sleep -Seconds 2
    Save-Shot (Out "browser-new-tab")
    Stop-Cowork

    # A page to show: the Home URL setting points new browser tabs at a local file.
    $pageUrl = "file:///" + $SamplePage.Replace('\', '/')
    Start-Cowork -Exe $Exe -ConfigDir $Config -WorkingDirectory $Demo -SettingsJson ('{"browser":{"home_url":"' + $pageUrl + '"}}')
    Click-At $LauncherBrowser[0] $LauncherBrowser[1]
    Start-Sleep -Seconds 2
    Click-At $BrowserAddPage[0] $BrowserAddPage[1]   # a new page tab opens the home URL
    Start-Sleep -Seconds 4
    Save-Shot (Out "browser")
    Stop-Cowork
}

if (Want "settings") {
    Start-Cowork -Exe $Exe -ConfigDir $Config -WorkingDirectory $Demo
    Press "^,"
    Start-Sleep -Seconds 1
    Save-Shot (Out "settings")
    # Nav entries of the settings tab (x is from the window's left edge).
    foreach ($page in @(@("terminal", 100, 168), @("editor", 91, 203), @("browser", 98, 238), @("agent", 69, 273))) {
        Click-At $page[1] $page[2]
        Save-Shot (Out ("settings-" + $page[0]))
    }
    Click-At 100 168
    Scroll-At 700 500 -8
    Save-Shot (Out "settings-terminal-more")
    Click-At 91 203
    Click-At 1175 367
    Save-Shot (Out "settings-editor-rebind")
    Press "{ESC}"
    Click-At 118 90
    Type-Text "font"
    Save-Shot (Out "settings-search") -H 520
    Stop-Cowork
}
