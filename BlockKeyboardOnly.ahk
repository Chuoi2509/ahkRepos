#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; Script Function:
; 	This script disables keyboard and mouse inputs until a hotkey is pressed.
;
; Note: the quit hotkey MUST be based on at least one of these: Control, Shift, Alt
;
; AutoHotkey built-in function BlockInput cannot be used because it prevents the script
; from receiving inputs, thus it prevents the quit hotkey from being fired.
;
; ******************************************************************************

QUIT_HOTKEY=Esc
; ______________________________________________________________________________
;
#NoEnv ; Avoids checking empty variables to see if they are environment variables
Menu,Tray,Icon,shell32.dll,48 	; systray icon is a padlock
; install the quit hotkey
Hotkey,%QUIT_HOTKEY%,ExitSub
; AFTER the quit hotkey is installed, block inputs
BlockKeyboardInputs("On")		
;;;;;;;;;;;BlockMouseClicks("On")
;;;;;;;;;;;BlockInput MouseMove
return
; ______________________________________________________________________________
;
ExitSub:
ExitApp ; The only way for an OnExit script to terminate itself is to use ExitApp in the OnExit subroutine.

; ******************************************************************************
; Function:
; 	BlockKeyboardInputs(state="On") disables all keyboard key presses,
;	but Control, Shift, Alt (thus a hotkey based on these keys can be used to unblock the keyboard)
;
; Param
;	state [in]: On or Off
;
BlockKeyboardInputs(state = "On")
{
	static keys
	keys=Space,Enter,Tab,BackSpace,Del,Ins,Home,End,PgDn,PgUp,Up,Down,Left,Right,CtrlBreak,ScrollLock,PrintScreen,CapsLock
,Pause,AppsKey,LWin,LWin,NumLock,Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadDot
,NumpadDiv,NumpadMult,NumpadAdd,NumpadSub,NumpadEnter,NumpadIns,NumpadEnd,NumpadDown,NumpadPgDn,NumpadLeft,NumpadClear
,NumpadRight,NumpadHome,NumpadUp,NumpadPgUp,NumpadDel,Media_Next,Media_Play_Pause,Media_Prev,Media_Stop,Volume_Down,Volume_Up
,Volume_Mute,Browser_Back,Browser_Favorites,Browser_Home,Browser_Refresh,Browser_Search,Browser_Stop,Launch_App1,Launch_App2
,Launch_Mail,Launch_Media,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22
,1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
,²,&,é,",',(,-,è,_,ç,à,),=,$,£,ù,*,~,#,{,[,|,``,\,^,@,],},;,:,!,?,.,/,§,<,>,vkBC
	Loop,Parse,keys, `,
		Hotkey, *%A_LoopField%, KeyboardDummyLabel, %state% UseErrorLevel
	Return
; hotkeys need a label, so give them one that do nothing
KeyboardDummyLabel:
Return
}

; ******************************************************************************
; Function:
; 	BlockMouseClicks(state="On") disables all mouse clicks
;
; Param
;	state [in]: On or Off
;

;BlockMouseClicks(state = "On")
;{
;	static keys="RButton,LButton,MButton,WheelUp,WheelDown"
;	Loop,Parse,keys, `,
;		Hotkey, *%A_LoopField%, MouseDummyLabel, %state% UseErrorLevel
;	Return
; hotkeys need a label, so give them one that do nothing
;MouseDummyLabel:
;Return
;}