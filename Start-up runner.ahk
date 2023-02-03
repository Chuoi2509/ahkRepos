if !A_IsAdmin
	Run *RunAs "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe" "%A_ScriptFullPath%"   
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode 2
Process, Priority, , High
Coordmode, Mouse, screen
#Include <WinClip\WinClipAPI>
#Include <WinClip\WinClip>
#Include <Gdip_All>
#Include <WinSysMenuAPI>

;Run, % "Explorer shell:appsFolder\Microsoft.Todos_8wekyb3d8bbwe!App"
;WinWaitActive, Microsoft To Do,, 5
;sleep, 300
SoundPlay, C:\0. Coding\ahkRepos\Audio\Red Alert 2\Establishing battle field control - ceva016.wav, WAIT   ;To Battle
sleep, 1000
run, C:\Program Files\Anki\anki.exe,,, UseErrorLevel 
WinWait, Banana - Anki ahk_exe anki.exe
WinActivate, Banana - Anki ahk_exe anki.exe
sleep, 2000
WinMove, Banana - Anki ahk_exe anki.exe,, 1334, -35, 597, 1065
DisableCloseButton(WinExist("ahk_exe anki.exe"))  
FileCopy, C:\0. Coding\ahkRepos\Banana's Script.ahk
, C:\0. Downloaded Programs\AHK_Backup\%A_DD%-%A_MM%-%A_YYYY%~%A_Hour%h%A_Min%.ahk
FileCopy, C:\0. Coding\ahkRepos\test.ahk
, C:\0. Downloaded Programs\AHK_Backup\AHK_Backup_temp\%A_DD%-%A_MM%-%A_YYYY%~%A_Hour%h%A_Min%_temp.ahk
run, C:\0. Downloaded Programs\EVKey\EVKey64.exe

;to avoid references caught from backup files => not placed in AHK_ScriptDir
; run, C:\0. Downloaded Programs\Bandicam_6.0.1.2003_Portable_by_elchupacabra\BandicamPortable.exe,, hide
; WinWaitActive, ahk_exe bdcam.exe
; Winset, Exstyle, +0x80, Bandicam ahk_exe bdcam.exe
;'WAIT' avoids ExitApp from stopping SoundPlay
Exitapp

DisableCloseButton(hWnd="") {
	 If hWnd=
	    hWnd:=WinExist("A")
	 hSysMenu:=DllCall("GetSystemMenu","Int",hWnd,"Int",FALSE)
	 nCnt:=DllCall("GetMenuItemCount","Int",hSysMenu)
	 DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-1,"Uint","0x400")
	 DllCall("RemoveMenu","Int",hSysMenu,"UInt",nCnt-2,"Uint","0x400")
	 DllCall("DrawMenuBar","Int",hWnd)
	Return ""
	}
toolTip(text:="", msTimeout:=2000, X:="", Y:="", WhichToolTip:="") {
    ToolTip, % text, % X, % Y, % WhichToolTip
	If (msTimeout!="")
		SetTimer, RemoveToolTip, % -msTimeout   ;Avoid pausing current thread with the use of Sleep 
}
RemoveToolTip:
	ToolTip
	return

