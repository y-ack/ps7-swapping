# version 0.0.1206
[ConsoleColor]$prompt_pathcolor = [ConsoleColor]::Green

[ConsoleColor]$eprompt_idcolor = [ConsoleColor]::Gray
[ConsoleColor]$eprompt_idbg = [ConsoleColor]::DarkGray
[ConsoleColor]$eprompt_pathcolor = [ConsoleColor]::Gray
[ConsoleColor]$eprompt_bg = [ConsoleColor]::DarkGray
[ConsoleColor]$eprompt_infocolor = [ConsoleColor]::Black
[ConsoleColor]$eprompt_timecolor = [ConsoleColor]::Gray
[ConsoleColor]$eprompt_infobg = [ConsoleColor]::Red
[ConsoleColor]$eprompt_timebg = [ConsoleColor]::DarkRed

function shellprompt() {
	Write-Host ($pwd.Path) -ForegroundColor $prompt_pathcolor -NoNewline
	return "> "
}


function editprompt() {
	$lastcmd = Get-History -Count 1 -ErrorAction Ignore
	if ($lastcmd) { 
		$lastcmdtime = "({0:m\:ss\.fff} " -f $lastcmd.Duration
	} else {
		$lastcmdtime = "(... "
	}
	$time = "({0:hh\:mm}" -f (get-date)
	
	$length = 0
	$tmp = ("{0}]" -f $MyInvocation.HistoryId); $length += $tmp.Length
	Write-Host $tmp -ForegroundColor $eprompt_idcolor -BackgroundColor $eprompt_idbg -NoNewLine
	$tmp = $pwd.Path; $length += $tmp.Length
	Write-Host $tmp -ForegroundColor $eprompt_pathcolor -BackgroundColor $eprompt_bg -NoNewLine
	Write-Host (" " * (($Host.UI.RawUI.BufferSize.Width) - $length - $lastcmdtime.Length - $time.Length)) -BackgroundColor $eprompt_bg -NoNewLine
	Write-Host $lastcmdtime -ForegroundColor $eprompt_infocolor -BackgroundColor $eprompt_infobg -NoNewLine
	Write-Host $time -ForegroundColor $eprompt_timecolor -BackgroundColor $eprompt_timebg -NoNewLine
	return " "
}

function linestart($line, $cursor) {
	[int]$pos = $line.lastindexof("`n", [Math]::Max(0,$cursor))
	return $pos -ne -1 ? $pos + 1 : 0
}
function lastline($text, $cursor) {
	$linestart = linestart $text ($cursor-1)
	$lastlinestart = linestart $text ($linestart-2)
	return $text.Substring($lastlinestart, [Math]::Max(0,$linestart-1)-$lastlinestart)
}
function lastindent($text, $cursor) {
	$lastline = lastline $text $cursor
	if ($lastline -match "^(\s+)") {
		return $Matches[1]
	} else {
		return ""
	}
}
function unset-key([string[]]$Chord) {
	Remove-PSReadLineKeyHandler -Chord $Chord
}
function define-key([string[]]$Chord, [string]$Function) {
	Remove-PSReadLineKeyHandler -Chord $Chord
	Set-PSReadLineKeyHandler -Chord $Chord -Function $Function
}

$ShellReadLineOptions = @{
	EditMode = "Windows"
	#CommandValidationHandler =
	ContinuationPrompt = ">> "
	ExtraPromptLineCount = 0
	HistoryNoDuplicates = $true
	HistorySearchCursorMovesToEnd = $false
	HistorySaveStyle = "SaveAtExit"
	HistorySearchCaseSensitive = $false
	PredictionSource = "History"
	PromptText = "> "
	ShowToolTips = $true
	WordDelimiters = ";:,.[]{}()/\|^&*-=+'`"-—―"
}
function set-shellreadline() {
	Set-PSReadLineOption @ShellReadLineOptions
}
$EditReadLineOptions = @{
	EditMode = "Emacs"
	#CommandValidationHandler =
	PromptText = " "
	ContinuationPrompt = " "
	ExtraPromptLineCount = 0
	HistoryNoDuplicates = $true
	HistorySearchCursorMovesToEnd = $true
	HistorySaveStyle = "SaveAtExit"
	HistorySearchCaseSensitive = $false
	PredictionSource = "None"
	ShowToolTips = $true
	WordDelimiters = ";:,.[]{}()/\|^&*-=+'`"-—―"
}
function set-editreadline() {
	Set-PSReadLineOption @EditReadLineOptions
	define-key  "Enter"  AddLine
	Remove-PSReadlineKeyHandler "Enter"
	Set-PSReadLineKeyHandler -Key "Enter" -BriefDescription "NewLine" -LongDescription "add line after with automatic indentation" -ScriptBlock {
		[Microsoft.PowerShell.PSConsoleReadLine]::AddLine()
		$line = $null
		$cursor = $null
		[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,
        [ref]$cursor)
		[Microsoft.PowerShell.PSConsoleReadLine]::Insert((lastindent $line $cursor))
		if ((lastline $line $cursor) -match "{\s*$") {
			[Microsoft.PowerShell.PSConsoleReadLine]::Insert("  ")
		}
			
	}
	define-key  "Ctrl+Enter"  AcceptLine
	define-key  "Alt+w" Copy
	Set-PSReadLineKeyHandler -Chord "Ctrl+w" -ScriptBlock { 
		[int]$start=0;[int]$len=0; if ([Microsoft.PowerShell.PSConsoleReadLine]::GetSelectionState([ref]$start, [ref]$len)) { 
		[Microsoft.PowerShell.PSConsoleReadLine]::KillRegion()
		} else {
		[Microsoft.PowerShell.PSConsoleReadLine]::KillLine()
		}
	}

	define-key  "Ctrl+e"  Yank
	define-key  "Ctrl+v"  Paste
	define-key  "Ctrl+z"  Undo
	define-key  "Ctrl+Z"  Redo
	define-key  "Ctrl+f"  SearchForward
	define-key  "Ctrl+F"  SearchForward
	define-key  "Ctrl+j"  BackwardChar
	define-key  "Ctrl+l"  ForwardChar
	define-key  "Ctrl+i"  PreviousLine
	define-key  "Ctrl+k"  NextLine
	define-key  "Ctrl+Alt+j"  ShellBackwardWord
	define-key  "Ctrl+Alt+l"  ShellForwardWord
	define-key  "Ctrl+Alt+i"  GotoBrace
	define-key  "Ctrl+Alt+k"  GotoBrace
	define-key  "Ctrl+LeftArrow"  ShellBackwardWord
	define-key  "Ctrl+RightArrow"  ShellForwardWord
	define-key  "Ctrl+UpArrow"  GotoBrace
	define-key  "Ctrl+DownArrow"  GotoBrace
	define-key  "Ctrl+Alt+J"  BeginningOfLine
	define-key  "Ctrl+Alt+L"  EndOfLine
	define-key  "Ctrl+Alt+I"  GotoBrace
	define-key  "Ctrl+Alt+K"  GotoBrace
	define-key  "Ctrl+J"  SelectBackwardChar
	define-key  "Ctrl+L"  SelectForwardChar
	Set-PSReadLineKeyHandler -Chord "Ctrl+I"  -ScriptBlock {
		$line = $null
		$cursor = $null
		[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,
        [ref]$cursor)
		[Microsoft.PowerShell.PSConsoleReadLine]::SelectBackwardsLine()
		[Microsoft.PowerShell.PSConsoleReadLine]::SelectBackwardChar()
	}
	Set-PSReadLineKeyHandler -Chord "Ctrl+K"  -ScriptBlock {
		$line = $null
		$cursor = $null
		[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line,
        [ref]$cursor)
		[Microsoft.PowerShell.PSConsoleReadLine]::SelectLine()
		[Microsoft.PowerShell.PSConsoleReadLine]::SelectForwardChar()
	}

	define-key  "Ctrl+a"  BackwardDeleteChar
	define-key  "Ctrl+Alt+a"  BackwardDeleteWord
	define-key  "Ctrl+d"  DeleteChar
	define-key  "Ctrl+Alt+d"  DeleteWord

	define-key  "Ctrl+x,h"  SelectAll

	define-key  "Ctrl+="  MenuComplete
	define-key  "Alt+="  PossibleCompletions
	define-key  "Ctrl+;"  SetMark

	Remove-PSReadlineKeyHandler "tab"
	Set-PSReadLineKeyHandler -Key "tab" -BriefDescription "completeorindent" -LongDescription "complete at point or indent if at beginning of line" -ScriptBlock {
	    $line = $null
	$cursor = $null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
	$linestart = linestart $line ($cursor-1)
	$starttocursor = $line.Substring($linestart, $cursor - $linestart)
	if ($starttocursor -match "^( |`t)*$") {
	        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("  ")
	} else {
		#use menuComplete?
		[Microsoft.PowerShell.PSConsoleReadLine]::MenuComplete()
	}
	}
	Remove-PSReadlineKeyHandler "shift+tab"
	Set-PSReadLineKeyHandler -Key "shift+tab" -BriefDescription "completebackwardsordeindent" -LongDescription "complete backwards at point or decrease indent if at beginning of line" -ScriptBlock {
	    $line = $null
	$cursor = $null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
	$linestart = linestart $line ($cursor-1)
	$starttocursor = $line.Substring($linestart, $cursor - $linestart)
	if ($starttocursor -match "^( |`t)*$") {
	        [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar()
		[Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar()
	} else {
		[Microsoft.PowerShell.PSConsoleReadLine]::MenuComplete()
	}
	}
}

function shell() {
	$function:prompt = $function:shellprompt
	set-shellreadline
}
function edit([string]$filepath = $null) {
	#[path] Resolve-Path $filepath
	$function:prompt = $function:editprompt
	set-editreadline
}
