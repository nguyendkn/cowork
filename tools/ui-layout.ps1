# Where things are in the real window, as offsets from its top-left (negative = from the bottom
# or right edge). The window is placed at 1280x800 by Start-Cowork. If the UI moves, fix these
# here once: the screenshot script and the release checks all read them.

# The launcher is centered in the pane, so these follow the window height (800): measured from a
# screenshot of the real window, the "Open" pills of the four rows.
# Five rows now (Project joined): the block is centered, so every row moved up 38px.
$LauncherTerminal = @(792, 292)
$LauncherBrowser = @(792, 368)
$LauncherProject = @(792, 444)
$LauncherText = @(792, 520)
$LauncherSettings = @(792, 596)
$TabBarNewTab = @(1231, 47)
# Project Search view inputs (default layout) and its Replace All button; the Source Control commit box.
$ProjectSearchQuery = @(100, 120)
$ProjectSearchReplace = @(100, 151)
$ProjectSearchReplaceAll = @(260, 151)
$ProjectScmMessage = @(130, 137)
$ProjectScmCommit = @(139, 166)
# Source Control panes: the Graph header and the splitter above it (default sizes, 2 changes listed).
$ProjectScmGraphHeader = @(60, 544)
$ProjectScmSplitter = @(140, 533)
# Graph header once Graph is closed: bottom of the sidebar.
$ProjectScmGraphHeaderClosed = @(60, 780)
# Refresh button of the Source Control view (top right of the branch row).
$ProjectScmRefresh = @(260, 113)
# Explorer rows (smoke project, nothing expanded): the `src` folder, and the context menu items
# relative to where it was right-clicked (menu anchored at the pointer, 26px items, 4px padding).
$ProjectExplorerSrcRow = @(60, 158)
$ExplorerMenuNewFile = @(60, 16)
$ExplorerMenuNewFolder = @(60, 42)
# "Open Folder" button of the native folder dialog (measured from a screenshot).
$FolderDialogOpen = @(1022, 681)
# Project tab sidebar header icons (measured from a screenshot of the real window).
$ProjectSidebarExplorer = @(106, 80)
$ProjectSidebarSearch = @(138, 80)
$ProjectSidebarSourceControl = @(171, 80)
# First commit row of the Source Control graph (the smoke project has 2 changes listed above it).
$ProjectGraphFirstCommit = @(120, 568)
# Second commit row once the first one is open to its two files.
$ProjectGraphSecondCommit = @(120, 640)
$StatusExplorer = @(17, -12)   # explorer icon, far left of the status bar
$StatusKeyboardShortcuts = @(-17, -12)   # keyboard icon, far right of the status bar
$ReplaceInput = @(135, 106)
$ShortcutRowKeys = @(-56, 106)   # the keys box of the first row in the drawer
$BrowserUrlBar = @(640, 108)
$BrowserAddPage = @(203, 77)     # the + in the browser's own tab strip
$BrowserCloseFirstPage = @(173, 77)  # the x on the first page tab (with two page tabs open)
# Settings > Appearance (sidebar row; General is expanded on launch).
$SettingsAppearanceRow = @(100, 213)
$AppearanceModeDropdown = @(1195, 236)
$AppearanceLightDropdown = @(1181, 311)
