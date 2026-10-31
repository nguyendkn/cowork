# Where things are in the real window, as offsets from its top-left (negative = from the bottom
# or right edge). The window is placed at 1280x800 by Start-Cowork. If the UI moves, fix these
# here once: the screenshot script and the release checks all read them.

$LauncherTerminal = @(792, 330)
$LauncherBrowser = @(792, 406)
$LauncherText = @(792, 482)
$LauncherSettings = @(792, 558)
$TabBarNewTab = @(1231, 47)
$StatusKeyboardShortcuts = @(50, -12)
$ReplaceInput = @(135, 106)
$ShortcutRowKeys = @(264, 106)   # the keys box of the first row in the drawer
$BrowserUrlBar = @(640, 108)
$BrowserAddPage = @(203, 77)     # the + in the browser's own tab strip
$BrowserCloseFirstPage = @(173, 77)  # the x on the first page tab (with two page tabs open)
