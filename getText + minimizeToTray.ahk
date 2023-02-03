If !A_IsAdmin
	; Run *RunAs "C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe" "%A_ScriptFullPath%"   
	Run *RunAs "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe" "%A_ScriptFullPath%"  
#NoEnv                    ;!!recommended for all scripts, disable enviroment variables
#SingleInstance,force
#MenuMaskKey vkFF   ;different from vkE8 to avoid conflict
#IfWinActive
Process, Priority,, H		;A=Above normal, H=High, https://www.autohotkey.com/boards/viewtopic.php?t=6413
Menu, Tray, Icon, C:\0. Downloaded Programs\0. Images\icons\geo\Project9.ico
Menu, Tray, NoStandard
; Menu, Tray, Add, About...,about
CoordMode, Mouse, Screen
if !UIA:=ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}","{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}"){
	Msgbox, % "UI Automation Failed!"
	ExitApp
}
Sendmode, Input
Process, Priority,, A		;No need to use High, https://www.autohotkey.com/boards/viewtopic.php?t=6413
; Minimize Window to Tray Menu
; http://www.autohotkey.com
; This script assigns a hotkey of your choice to hide any window so that
; it becomes an entry at the bottom of the script's tray menu.  Hidden
; windows can then be restored individually or all at once by selecting
; the corresponding item on the menu.  If the script exits for any reason,
; all the windows that it hid will be restored automatically.

; CONFIGURATION SECTION: Change the below values as desired.

; This is the maximum number of windows to allow to be hidden:
mwt_MaxWindows := 15

; This is the hotkey used to hide the active window:
; mwt_stack := "$!Esc"
; mwt_unStack := "NumpadClear & Esc"

; If you prefer to have the tray menu empty of all the standard items,
; such as Help and Pause, use N.  Otherwise, use Y:
mwt_StandardMenu = N

; These first few performance settings help to keep the action within
; the #HotkeyModifierTimeout period, and thus avoid the need to release
; and press down the hotkey's modifier if you want to hide more than one
; window in a row.  These settings are not needed you choose to have the
; script use the keyboard hook via #InstallKeybdHook or other means:
; #HotkeyModifierTimeout 100
; SetWinDelay 10
; SetKeyDelay 0

; The below are recommended for this script:
SetBatchLines 10ms


; ----------------------------------------------------

; Hotkey, % mwt_stack, mwt_Minimize
; Hotkey, % mwt_unStack, mwt_UnMinimize

; If the user terminates the script by any means, unhide all the
; windows first:
OnExit, mwt_RestoreAllThenExit

if mwt_StandardMenu = Y
	Menu, Tray, Add
else
{
	Menu, Tray, NoStandard
	Menu, Tray, Add, E&xit, mwt_RestoreAllThenExit
}
Menu, Tray, Add, &Restore All Hidden Windows, mwt_RestoreAll
Menu, Tray, Add  ; Another separator to make the above more special.
Menu, Tray, Add, Reload

return  ; End of auto-execute section
$^!LButton::
    if !WinActive("ahk_exe Obsidian.exe")
        Goto, main
    else
        Send, ^!{LButotn}
    return
$>!Esc::
    GoSub, mwt_UnMinimize
    return
$<!Esc::
    GoSub, mwt_Minimize
    return
Reload:
    reload
    return
mwt_Minimize:
if mwt_WindowCount >= %mwt_MaxWindows%
{
	MsgBox No more than %mwt_MaxWindows% may be hidden simultaneously.
	return
}

WinGet, ActiveID, ID, A
WinGetTitle, ActiveTitle, ahk_id %ActiveID%
; Because hiding the window won't deactivate it, activate the window
; beneath this one (if any). I tried other ways, but they wound up
; activating the task bar.  This way sends the active window (which is
; about to be hidden) to the back of the stack, which seems best:
Send, !{esc}
; Don't hide until after the above, since by default hidden windows are
; not detected:
WinHide, ahk_id %ActiveID%

; In addition to the tray menu requiring that each menu item name be
; unique, it must also be unique so that we can reliably look it up in
; the array when the window is later unhidden.  So make it unique if it
; isn't already:
Loop, %mwt_MaxWindows%
{
	if mwt_WindowTitle%a_index% = %ActiveTitle%
	{
		; Match found, so it's not unique.
		; First remove the 0x from the hex number to conserve menu space:
		StringTrimLeft, ActiveIDShort, ActiveID, 2
		StringLen, ActiveIDShortLength, ActiveIDShort
		StringLen, ActiveTitleLength, ActiveTitle
		ActiveTitleLength += %ActiveIDShortLength% ; Add up the new length
		ActiveTitleLength++ ; +1 for room for one space between title & ID.
		if ActiveTitleLength > 100
		{
			; Since max menu name is 100, trim the title down to allow just
			; enough room for the Window's Short ID at the end of its name:
			TrimCount = %ActiveTitleLength%
			TrimCount -= 100
			StringTrimRight, ActiveTitle, ActiveTitle, %TrimCount%
		}
		ActiveTitle = %ActiveTitle% %ActiveIDShort%  ; Build unique title.
		break
	}
}

; First, ensure that this ID doesn't already exist in the list, which can
; happen if a particular window was externally unhidden (or its app unhid
; it) and now it's about to be re-hidden:
mwt_AlreadyExists = n
Loop, %mwt_MaxWindows%
{
	if mwt_WindowID%a_index% = %ActiveID%
	{
		mwt_AlreadyExists = y
		break
	}
}

; Add the item to the array and to the menu: ; (and to the window order count)
if mwt_AlreadyExists = n
{
	Menu, Tray, add, %ActiveTitle%, RestoreFromTrayMenu
	mwt_WindowCount++
	Loop, %mwt_MaxWindows%  ; Search for a free slot.
	{
		; It should always find a free slot if things are designed right.
		if mwt_WindowID%a_index% =  ; An empty slot was found.
		{
			mwt_WindowID%a_index% = %ActiveID%
			mwt_WindowTitle%a_index% = %ActiveTitle%
			mwt_WindowNumber%a_index% = %mwt_WindowCount%
			break
		}
	}
}
return

mwt_UnMinimize:
if mwt_WindowCount = 0
{
	; Nothing to un hide
	return
}
Loop, %mwt_MaxWindows%
{
	if mwt_WindowID%a_index% <> ; A non-empty slot
	{
		if mwt_WindowNumber%a_index% = %mwt_WindowCount%
		{
			; This window is the one that needs to be removed
			StringTrimRight, IDToRestore, mwt_WindowID%a_index%, 0
			WinShow, ahk_id %IDToRestore%
			WinActivate ahk_id %IDToRestore%  ; Sometimes needed.
			StringTrimRight, winTitle, mwt_WindowTitle%a_index%, 0
			Menu, Tray, delete, %winTitle%
			mwt_WindowID%a_index% =  ; Make it blank to free up a slot.
			mwt_WindowTitle%a_index% =
			mwt_WindowCount--
			break
		}
	}
}
return
			

RestoreFromTrayMenu:
Menu, Tray, delete, %A_ThisMenuItem%
; Find window based on its unique title stored as the menu item name:
Loop, %mwt_MaxWindows%
{
	if mwt_WindowTitle%a_index% = %A_ThisMenuItem%  ; Match found.
	{
		StringTrimRight, IDToRestore, mwt_WindowID%a_index%, 0
		WinShow, ahk_id %IDToRestore%
		WinActivate ahk_id %IDToRestore%  ; Sometimes needed.

		; Loop through all the windows and decrement what is necessary
		StringTrimRight, winNumber, mwt_WindowNumber%a_index%, 0
		Loop, %mwt_MaxWindows%
		{
			if mwt_WindowNumber%a_index% > %winNumber%
			{
			mwt_WindowNumber%a_index%--
			}
		}

		mwt_WindowID%a_index% =  ; Make it blank to free up a slot.
		mwt_WindowTitle%a_index% =
		mwt_WindowCount--
		break
	}
}
return


mwt_RestoreAllThenExit:
Gosub, mwt_RestoreAll
ExitApp  ; Do a true exit.


mwt_RestoreAll:
Loop, %mwt_MaxWindows%
{
	if mwt_WindowID%a_index% <>
	{
		StringTrimRight, IDToRestore, mwt_WindowID%a_index%, 0
		WinShow, ahk_id %IDToRestore%
		WinActivate ahk_id %IDToRestore%  ; Sometimes needed.
		; Do it this way vs. DeleteAll so that the sep. line and first
		; item are retained:
		StringTrimRight, MenuToRemove, mwt_WindowTitle%a_index%, 0
		Menu, Tray, delete, %MenuToRemove%
		mwt_WindowID%a_index% =  ; Make it blank to free up a slot.
		mwt_WindowTitle%a_index% =
		mwt_WindowCount--
	}
	if mwt_WindowCount = 0
		break
}
return





menu,tray,NoStandard
menu,tray,add,Hotkey,hotkey
menu,tray,add,About...,about
menu,tray,add,Exit,exit
CoordMode,mouse,screen
KeyName := "^!Lbutton"
Hotkey, %KeyName%, main
if !UIA:=ComObjCreate("{ff48dba4-60ef-4201-aa87-54103eef594e}","{30cbe57d-d9d0-452a-ab13-7ac5ac4825ee}"){
	Msgbox, UI Automation Failed.
	ExitApp
}
return
hotkey:
	gui,1:Destroy
	gui,1:add,text,,New Hotkey
	gui,1:add,Hotkey,vChosenHotkey,%KeyName%
	gui,1:add,button,Default gbtnHK,Confirm
	gui,1:show,,%A_Space%
	return
about:
	gui,2:Destroy
	gui,2:add,link,,%intro%
	gui,2:show,,About ScreenReader 0.1.1a
	return
btnHK:
	gui,1:submit
	if (ChosenHotkey!=KeyName){
		Hotkey,%KeyName%,,off
		KeyName:=ChosenHotkey
		Hotkey,%KeyName%,main,on
	}
	gui,1:Destroy
	return
main:
    MouseGetPos,x,y
    ;DllCall(vt)
    item:=GetElementItem(x,y)
    if !item.1
        return
    gui,3:Destroy
    ;gui,3:new,ToolWindow
    SoundPlay, C:\0. Coding\ahkRepos\Audio\ggTTS\copied.wav
    for k,v in item
    {
        gui,3:add,edit,x5 w480 -Tabstop vedit%k%,%v%
        gui,3:add,button,X+5 yp-2 vbtn%k% gcp2cb,To Clipboard
    }
        gui,3:show,,You Get
    return
vas(obj,ByRef txt){
	for k,v in obj
		if (v=txt)
			return 0
	return 1
}
cp2cb:
	n:=SubStr(A_GuiControl,4)
	GuiControlGet,txt,,edit%n%
	if txt
		Clipboard:=txt
	gui,3:Destroy
return
3GuiEscape:
	gui,3:Destroy
	return
GetPatternName(id){
	global uia
	DllCall(vt(uia,50),"ptr",uia,"uint",id,"ptr*",name)
	return StrGet(name)
}
GetPropertyName(id){
	global uia
	DllCall(vt(uia,49),"ptr",uia,"uint",id,"ptr*",name)
	return StrGet(name)
}
GetElementItem(x,y){
	global uia
	item:={}
	DllCall(vt(uia,7),"ptr",uia,"int64",x|y<<32,"ptr*",element) ;IUIAutomation::ElementFromPoint
        if !element
            return
	DllCall(vt(element,23),"ptr",element,"ptr*",name) ;IUIAutomationElement::CurrentName
	DllCall(vt(element,10),"ptr",element,"uint",30045,"ptr",variant(val)) ;IUIAutomationElement::GetCurrentPropertyValue::value
	DllCall(vt(element,10),"ptr",element,"uint",30092,"ptr",variant(lname)) ;IUIAutomationElement::GetCurrentPropertyValue::lname
	DllCall(vt(element,10),"ptr",element,"uint",30093,"ptr",variant(lval)) ;IUIAutomationElement::GetCurrentPropertyValue::lvalue
	a:=StrGet(name,"utf-16"),b:=StrGet(NumGet(val,8,"ptr"),"utf-16"),c:=StrGet(NumGet(lname,8,"ptr"),"utf-16"),d:=StrGet(NumGet(lval,8,"ptr"),"utf-16")
	a?item.Insert(a):0
	b&&vas(item,b)?item.Insert(b):0
	c&&vas(item,c)?item.Insert(c):0
	d&&vas(item,d)?item.Insert(d):0
	DllCall(vt(element,21),"ptr",element,"uint*",type) ;IUIAutomationElement::CurrentControlType
	if (type=50004)
		e:=GetElementWhole(element),e&&vas(item,e)?item.Insert(e):0
	ObjRelease(element)
	return item
}
GetElementWhole(element){
	global uia
	static init:=1,trueCondition,walker
	if init
		init:=DllCall(vt(uia,21),"ptr",uia,"ptr*",trueCondition) ;IUIAutomation::CreateTrueCondition
		,init+=DllCall(vt(uia,14),"ptr",uia,"ptr*",walker) ;IUIAutomation::ControlViewWalker
	DllCall(vt(uia,5),"ptr",uia,"ptr*",root) ;IUIAutomation::GetRootElement
	DllCall(vt(uia,3),"ptr",uia,"ptr",element,"ptr",root,"int*",same) ;IUIAutomation::CompareElements
	ObjRelease(root)
	if same {
		return
	}
	hr:=DllCall(vt(walker,3),"ptr",walker,"ptr",element,"ptr*",parent) ;IUIAutomationTreeWalker::GetParentElement
	if parent {
		e:=""
		DllCall(vt(parent,6),"ptr",parent,"uint",2,"ptr",trueCondition,"ptr*",array) ;IUIAutomationElement::FindAll
		DllCall(vt(array,3),"ptr",array,"int*",length) ;IUIAutomationElementArray::Length
		loop % length {
			DllCall(vt(array,4),"ptr",array,"int",A_Index-1,"ptr*",newElement) ;IUIAutomationElementArray::GetElement
			DllCall(vt(newElement,23),"ptr",newElement,"ptr*",name) ;IUIAutomationElement::CurrentName
			e.=StrGet(name,"utf-16")
			ObjRelease(newElement)
		}
                ObjRelease(array)
		ObjRelease(parent)
		return e
	}
}
variant(ByRef var,type=0,val=0){
	return (VarSetCapacity(var,8+2*A_PtrSize)+NumPut(type,var,0,"short")+NumPut(val,var,8,"ptr"))*0+&var
}
vt(p,n){
	return NumGet(NumGet(p+0,"ptr")+n*A_PtrSize,"ptr")
}
