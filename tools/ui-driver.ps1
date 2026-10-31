# Helpers that drive the real Cowork window for documentation screenshots.
# Dot-source this file; see capture-screenshots.ps1 for the scenes.
#
# Text is typed with SendInput Unicode packets, never SendKeys letters: an active IME
# (Telex, Pinyin, ...) would rewrite typed letters and make the screenshots irreproducible.
# The clipboard is not used, so the user's clipboard is never touched.

Add-Type -AssemblyName System.Windows.Forms, System.Drawing
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public static class Win {
    [StructLayout(LayoutKind.Sequential)] public struct RECT { public int Left, Top, Right, Bottom; }
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, uint dx, uint dy, uint data, UIntPtr extra);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hwnd);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hwnd, IntPtr after, int x, int y, int cx, int cy, uint flags);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hwnd, out RECT rect);
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("kernel32.dll")] public static extern uint SetThreadExecutionState(uint flags);

    delegate bool EnumProc(IntPtr hwnd, IntPtr param);
    [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc proc, IntPtr param);
    [DllImport("user32.dll")] static extern uint GetWindowThreadProcessId(IntPtr hwnd, out uint pid);
    [DllImport("user32.dll")] static extern IntPtr GetForegroundWindow();

    /// Process id that owns the foreground window (the app and its native dialogs share one pid).
    public static uint ForegroundPid() {
        uint pid;
        GetWindowThreadProcessId(GetForegroundWindow(), out pid);
        return pid;
    }
    [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr hwnd);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] static extern int GetClassName(IntPtr hwnd, StringBuilder name, int max);

    /// The app's own top-level window. Debug builds also own a console window, which
    /// Process.MainWindowHandle can return instead, so windows are matched by process and class.
    public static IntPtr FindAppWindow(uint pid) {
        IntPtr found = IntPtr.Zero;
        EnumWindows((hwnd, param) => {
            uint owner;
            GetWindowThreadProcessId(hwnd, out owner);
            if (owner != pid || !IsWindowVisible(hwnd)) return true;
            var name = new StringBuilder(256);
            GetClassName(hwnd, name, 256);
            string cls = name.ToString();
            if (cls == "ConsoleWindowClass" || cls == "PseudoConsoleWindow" || cls.StartsWith("CASCADIA")) return true;
            found = hwnd;
            return false;
        }, IntPtr.Zero);
        return found;
    }

    [StructLayout(LayoutKind.Sequential)] public struct KEYBDINPUT {
        public ushort wVk; public ushort wScan; public uint dwFlags; public uint time; public IntPtr dwExtraInfo;
    }
    [StructLayout(LayoutKind.Sequential)] public struct MOUSEINPUT {
        public int dx; public int dy; public uint mouseData; public uint dwFlags; public uint time; public IntPtr dwExtraInfo;
    }
    [StructLayout(LayoutKind.Explicit)] public struct InputUnion {
        [FieldOffset(0)] public MOUSEINPUT mi;
        [FieldOffset(0)] public KEYBDINPUT ki;
    }
    [StructLayout(LayoutKind.Sequential)] public struct INPUT { public uint type; public InputUnion u; }
    [DllImport("user32.dll", SetLastError = true)]
    public static extern uint SendInput(uint count, INPUT[] inputs, int size);

    /// A key press carrying one UTF-16 unit; delivered as WM_CHAR, so no IME rewrites it.
    public static void TypeChar(char c) {
        var down = new INPUT { type = 1 };
        down.u.ki = new KEYBDINPUT { wScan = c, dwFlags = 0x0004 };
        var up = new INPUT { type = 1 };
        up.u.ki = new KEYBDINPUT { wScan = c, dwFlags = 0x0004 | 0x0002 };
        SendInput(2, new[] { down, up }, Marshal.SizeOf(typeof(INPUT)));
    }
}
"@
[void][Win]::SetProcessDPIAware()

$script:App = $null
$script:Hwnd = [IntPtr]::Zero

# Fail early with a clear message when nothing can be captured (locked screen, no session).
function Assert-Desktop {
    try {
        $bmp = New-Object System.Drawing.Bitmap 8, 8
        [System.Drawing.Graphics]::FromImage($bmp).CopyFromScreen(0, 0, 0, 0, (New-Object System.Drawing.Size 8, 8))
        $bmp.Dispose()
    } catch {
        throw "The desktop is not capturable (is the workstation locked?). Unlock it and run again."
    }
}

# Every run's log verdict, filled by Stop-Cowork and printed by Write-LogChecks.
$script:LogChecks = @()

# Reads the app's log (`<config dir>\logs`) with logcheck: errors, panics, HANG, LEAK, LIMIT and SLOW
# lines fail it. Build it with `cargo build -p logger --bin logcheck` (`make smoke` does).
function Test-CoworkLogs([string]$ConfigDir) {
    $logcheck = Join-Path $PSScriptRoot "..\..\target\debug\logcheck.exe"
    if (-not (Test-Path $logcheck)) { throw "logcheck is not built: cargo build -p logger --bin logcheck" }
    $output = & $logcheck (Join-Path $ConfigDir "logs") 2>&1
    [pscustomobject]@{ Dir = $ConfigDir; Ok = ($LASTEXITCODE -eq 0); Output = ($output -join "`n") }
}

# Prints each run's log verdict; returns how many runs showed signals to fix or optimize.
function Write-LogChecks {
    $bad = 0
    foreach ($check in $script:LogChecks) {
        if ($check.Ok) { Write-Host "PASS  logs: $($check.Dir)" }
        else { Write-Host "FAIL  logs: $($check.Dir)`n$($check.Output)"; $bad++ }
    }
    return $bad
}

function Start-Cowork {
    param([string]$Exe, [string]$ConfigDir, [int]$Width = 1280, [int]$Height = 800, [string]$SettingsJson = "", [string]$WorkingDirectory = "", [string]$StderrFile = "", [switch]$KeepConfig)
    # ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED: no idle lock while we work.
    [void][Win]::SetThreadExecutionState([uint32]2147483651)
    Assert-Desktop
    # A throw-away config folder per run, unless the run is a restart that must see the last one.
    if (-not $KeepConfig) { Remove-Item $ConfigDir -Recurse -Force -ErrorAction SilentlyContinue }
    if ($SettingsJson) {
        New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
        Set-Content -Path (Join-Path $ConfigDir "settings.json") -Value $SettingsJson -Encoding UTF8
    }
    $env:COWORK_CONFIG_DIR = $ConfigDir
    $env:COWORK_HEALTH_INTERVAL_MS = "2000"   # several [health] samples in a short run
    $launch = @{ FilePath = $Exe; PassThru = $true }
    if ($WorkingDirectory) { $launch.WorkingDirectory = $WorkingDirectory }
    if ($StderrFile) {
        # A panic message goes to stderr; keep it so a check can show it.
        $launch.RedirectStandardError = $StderrFile
        $launch.RedirectStandardOutput = "$StderrFile.out"
    }
    $script:App = Start-Process @launch
    for ($i = 0; $i -lt 60 -and $script:Hwnd -eq [IntPtr]::Zero; $i++) {
        Start-Sleep -Milliseconds 250
        $script:Hwnd = [Win]::FindAppWindow([uint32]$script:App.Id)
    }
    if ($script:Hwnd -eq [IntPtr]::Zero) { throw "Cowork window did not appear" }
    # SWP_SHOWWINDOW; a fixed size and place keeps click offsets and images stable.
    [void][Win]::SetWindowPos($script:Hwnd, [IntPtr]::Zero, 60, 40, $Width, $Height, 0x0040)
    [void][Win]::SetForegroundWindow($script:Hwnd)
    Start-Sleep -Seconds 2
}

function Stop-Cowork {
    $ran = [bool]$script:App
    if ($script:App -and -not $script:App.HasExited) {
        # The browser runs in helper processes of the same exe; end the whole tree so the next
        # launch does not find the previous run's browser cache locked.
        & taskkill.exe /PID $script:App.Id /T /F 2>&1 | Out-Null
        [void]$script:App.WaitForExit(5000)
    }
    $script:App = $null
    $script:Hwnd = [IntPtr]::Zero
    Start-Sleep -Milliseconds 800
    if ($ran) { $script:LogChecks += Test-CoworkLogs $env:COWORK_CONFIG_DIR }
}

function Get-Rect {
    $r = New-Object Win+RECT
    [void][Win]::GetWindowRect($script:Hwnd, [ref]$r)
    $r
}

# Click at an offset from the window's top-left (positive) or bottom/right edge (negative).
function Click-At {
    param([int]$X, [int]$Y, [switch]$Double)
    $r = Get-Rect
    $x = if ($X -ge 0) { $r.Left + $X } else { $r.Right + $X }
    $y = if ($Y -ge 0) { $r.Top + $Y } else { $r.Bottom + $Y }
    [void][Win]::SetCursorPos($x, $y)
    Start-Sleep -Milliseconds 120
    $times = if ($Double) { 2 } else { 1 }
    1..$times | ForEach-Object {
        [Win]::mouse_event(2, 0, 0, 0, [UIntPtr]::Zero)
        [Win]::mouse_event(4, 0, 0, 0, [UIntPtr]::Zero)
        Start-Sleep -Milliseconds 60
    }
    Start-Sleep -Milliseconds 450
}

# Turn the mouse wheel at a window position; negative notches scroll the content down.
function Scroll-At {
    param([int]$X, [int]$Y, [int]$Notches = -5)
    Move-Mouse $X $Y
    $delta = [BitConverter]::ToUInt32([BitConverter]::GetBytes([int]($Notches * 120)), 0)
    [Win]::mouse_event(0x0800, 0, 0, $delta, [UIntPtr]::Zero)
    Start-Sleep -Milliseconds 500
}

function Move-Mouse {
    param([int]$X, [int]$Y)
    $r = Get-Rect
    [void][Win]::SetCursorPos($r.Left + $X, $r.Top + $Y)
    Start-Sleep -Milliseconds 300
}

# Keys and typed text go to the foreground window: refuse to send them anywhere but the app (or its
# native dialogs, same pid). One refocus attempt, then fail the step instead of typing into
# another program (a terminal, an editor).
function Assert-AppForeground {
    if (-not $script:App) { return }
    $appPid = [uint32]$script:App.Id
    for ($i = 0; $i -lt 2; $i++) {
        if ([Win]::ForegroundPid() -eq $appPid) { return }
        if ($i -eq 0) { [void][Win]::SetForegroundWindow($script:Hwnd); Start-Sleep -Milliseconds 300 }
    }
    $other = (Get-Process -Id ([Win]::ForegroundPid()) -ErrorAction SilentlyContinue).ProcessName
    throw "the app (pid $appPid) is not the foreground window (foreground: $other); not sending input"
}

function Press {
    param([string]$Keys, [int]$Wait = 400)
    Assert-AppForeground
    [System.Windows.Forms.SendKeys]::SendWait($Keys)
    Start-Sleep -Milliseconds $Wait
}

# Type text literally. "`n" presses Enter and "`t" presses Tab (they are keys, not characters).
function Type-Text {
    param([string]$Text, [int]$Wait = 400, [int]$Delay = 8)
    Assert-AppForeground
    foreach ($c in $Text.ToCharArray()) {
        switch ($c) {
            "`r" { }
            "`n" { [System.Windows.Forms.SendKeys]::SendWait("{ENTER}") }
            "`t" { [System.Windows.Forms.SendKeys]::SendWait("{TAB}") }
            default { [Win]::TypeChar($c) }
        }
        Start-Sleep -Milliseconds $Delay
    }
    Start-Sleep -Milliseconds $Wait
}

# Save the app window as a PNG. X/Y/W/H pick a sub-rectangle, in pixels from the top-left of the
# visible window (Windows adds an invisible 8px resize border on the left, right and bottom,
# which is cropped away). W/H of 0 mean "to the edge".
function Save-Shot {
    param([string]$Path, [int]$X = 0, [int]$Y = 0, [int]$W = 0, [int]$H = 0)
    $r = Get-Rect
    $visibleW = ($r.Right - $r.Left) - 16
    $visibleH = ($r.Bottom - $r.Top) - 8
    if ($W -le 0) { $W = $visibleW - $X }
    if ($H -le 0) { $H = $visibleH - $Y }
    $bmp = New-Object System.Drawing.Bitmap $W, $H
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen($r.Left + 8 + $X, $r.Top + $Y, 0, 0, (New-Object System.Drawing.Size $W, $H))
    $g.Dispose()
    New-Item -ItemType Directory -Force -Path (Split-Path $Path) | Out-Null
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "saved $Path"
}

# True while the app process is still running (a crash ends it).
function Test-CoworkAlive {
    return ($script:App -and -not $script:App.HasExited)
}
