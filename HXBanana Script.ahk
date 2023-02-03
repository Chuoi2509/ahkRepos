#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetTitleMatchMode, 2
SetCapsLockState, AlwaysOff
#WinActivateForce
Process, Priority, , High
Coordmode, Mouse, screen
Coordmode, ToolTip, screen
CoordMode, Pixel, Screen
CoordMode, Menu, Screen
CoordMode, Caret, Screen
#SingleInstance Force 
SetCapsLockState, AlwaysOff 
#MenuMaskKey vkE8 
#Include C:\Users\windown10\Desktop\0. HX Upload\HXUpload\lib\WinSysMenuAPI.ahk
#Include C:\Users\windown10\Desktop\0. HX Upload\HXUpload\lib\WinClip.ahk
#Include C:\Users\windown10\Desktop\0. HX Upload\HXUpload\lib\WinClipAPI.ahk
#Include C:\Users\windown10\Desktop\0. HX Upload\HXUpload\Lib\ExtractRAR.ahk
#Include <ToolTipAddin>
#Include <Acc>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
class BrightnessSetter {
	; qwerty12 - 27/05/17
	; https://github.com/qwerty12/AutoHotkeyScripts/tree/master/LaptopBrightnessSetter
	static _WM_POWERBROADCAST := 0x218, _osdHwnd := 0, hPowrprofMod := DllCall("LoadLibrary", "Str", "powrprof.dll", "Ptr") 

	__New() {
		if (BrightnessSetter.IsOnAc(AC))
			this._AC := AC
		if ((this.pwrAcNotifyHandle := DllCall("RegisterPowerSettingNotification", "Ptr", A_ScriptHwnd, "Ptr", BrightnessSetter._GUID_ACDC_POWER_SOURCE(), "UInt", DEVICE_NOTIFY_WINDOW_HANDLE := 0x00000000, "Ptr"))) ; Sadly the callback passed to *PowerSettingRegister*Notification runs on a new threadl
			OnMessage(this._WM_POWERBROADCAST, ((this.pwrBroadcastFunc := ObjBindMethod(this, "_On_WM_POWERBROADCAST"))))
	}

	__Delete() {
		if (this.pwrAcNotifyHandle) {
			OnMessage(BrightnessSetter._WM_POWERBROADCAST, this.pwrBroadcastFunc, 0)
			,DllCall("UnregisterPowerSettingNotification", "Ptr", this.pwrAcNotifyHandle)
			,this.pwrAcNotifyHandle := 0
			,this.pwrBroadcastFunc := ""
		}
	}

	SetBrightness(increment, jump := False, showOSD := True, autoDcOrAc := -1, ptrAnotherScheme := 0)
	{
		static PowerGetActiveScheme := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerGetActiveScheme", "Ptr")
			  ,PowerSetActiveScheme := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerSetActiveScheme", "Ptr")
			  ,PowerWriteACValueIndex := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerWriteACValueIndex", "Ptr")
			  ,PowerWriteDCValueIndex := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerWriteDCValueIndex", "Ptr")
			  ,PowerApplySettingChanges := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerApplySettingChanges", "Ptr")

		if (increment == 0 && !jump) {
			if (showOSD)
				BrightnessSetter._ShowBrightnessOSD()
			return
		}

		if (!ptrAnotherScheme ? DllCall(PowerGetActiveScheme, "Ptr", 0, "Ptr*", currSchemeGuid, "UInt") == 0 : DllCall("powrprof\PowerDuplicateScheme", "Ptr", 0, "Ptr", ptrAnotherScheme, "Ptr*", currSchemeGuid, "UInt") == 0) {
			if (autoDcOrAc == -1) {
				if (this != BrightnessSetter) {
					AC := this._AC
				} else {
					if (!BrightnessSetter.IsOnAc(AC)) {
						DllCall("LocalFree", "Ptr", currSchemeGuid, "Ptr")
						return
					}
				}
			} else {
				AC := !!autoDcOrAc
			}

			currBrightness := 0
			if (jump || BrightnessSetter._GetCurrentBrightness(currSchemeGuid, AC, currBrightness)) {
				 maxBrightness := BrightnessSetter.GetMaxBrightness()
				,minBrightness := BrightnessSetter.GetMinBrightness()

				if (jump || !((currBrightness == maxBrightness && increment > 0) || (currBrightness == minBrightness && increment < minBrightness))) {
					if (currBrightness + increment > maxBrightness)
						increment := maxBrightness
					else if (currBrightness + increment < minBrightness)
						increment := minBrightness
					else
						increment += currBrightness

					if (DllCall(AC ? PowerWriteACValueIndex : PowerWriteDCValueIndex, "Ptr", 0, "Ptr", currSchemeGuid, "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt", increment, "UInt") == 0) {
						; PowerApplySettingChanges is undocumented and exists only in Windows 8+. Since both the Power control panel and the brightness slider use this, we'll do the same, but fallback to PowerSetActiveScheme if on Windows 7 or something
						if (!PowerApplySettingChanges || DllCall(PowerApplySettingChanges, "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt") != 0)
							DllCall(PowerSetActiveScheme, "Ptr", 0, "Ptr", currSchemeGuid, "UInt")
					}
				}

				if (showOSD)
					BrightnessSetter._ShowBrightnessOSD()
			}
			DllCall("LocalFree", "Ptr", currSchemeGuid, "Ptr")
		}
	}

	IsOnAc(ByRef acStatus)
	{
		static SystemPowerStatus
		if (!VarSetCapacity(SystemPowerStatus))
			VarSetCapacity(SystemPowerStatus, 12)

		if (DllCall("GetSystemPowerStatus", "Ptr", &SystemPowerStatus)) {
			acStatus := NumGet(SystemPowerStatus, 0, "UChar") == 1
			return True
		}

		return False
	}
	
	GetDefaultBrightnessIncrement()
	{
		static ret := 10
		DllCall("powrprof\PowerReadValueIncrement", "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", ret, "UInt")
		return ret
	}

	GetMinBrightness()
	{
		static ret := -1
		if (ret == -1)
			if (DllCall("powrprof\PowerReadValueMin", "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", ret, "UInt"))
				ret := 0
		return ret
	}

	GetMaxBrightness()
	{
		static ret := -1
		if (ret == -1)
			if (DllCall("powrprof\PowerReadValueMax", "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", ret, "UInt"))
				ret := 100
		return ret
	}

	_GetCurrentBrightness(schemeGuid, AC, ByRef currBrightness)
	{
		static PowerReadACValueIndex := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerReadACValueIndex", "Ptr")
			  ,PowerReadDCValueIndex := DllCall("GetProcAddress", "Ptr", BrightnessSetter.hPowrprofMod, "AStr", "PowerReadDCValueIndex", "Ptr")
		return DllCall(AC ? PowerReadACValueIndex : PowerReadDCValueIndex, "Ptr", 0, "Ptr", schemeGuid, "Ptr", BrightnessSetter._GUID_VIDEO_SUBGROUP(), "Ptr", BrightnessSetter._GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS(), "UInt*", currBrightness, "UInt") == 0
	}
	
	_ShowBrightnessOSD()
	{
		static PostMessagePtr := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "PostMessageW" : "PostMessageA", "Ptr")
			  ,WM_SHELLHOOK := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK", "UInt")
		if A_OSVersion in WIN_VISTA,WIN_7
			return
		BrightnessSetter._RealiseOSDWindowIfNeeded()
		; Thanks to YashMaster @ https://github.com/YashMaster/Tweaky/blob/master/Tweaky/BrightnessHandler.h for realising this could be done:
		if (BrightnessSetter._osdHwnd)
			DllCall(PostMessagePtr, "Ptr", BrightnessSetter._osdHwnd, "UInt", WM_SHELLHOOK, "Ptr", 0x37, "Ptr", 0)
	}

	_RealiseOSDWindowIfNeeded()
	{
		static IsWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", "IsWindow", "Ptr")
		if (!DllCall(IsWindow, "Ptr", BrightnessSetter._osdHwnd) && !BrightnessSetter._FindAndSetOSDWindow()) {
			BrightnessSetter._osdHwnd := 0
			try if ((shellProvider := ComObjCreate("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}"))) {
				try if ((flyoutDisp := ComObjQuery(shellProvider, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}"))) {
					 DllCall(NumGet(NumGet(flyoutDisp+0)+3*A_PtrSize), "Ptr", flyoutDisp, "Int", 0, "UInt", 0)
					,ObjRelease(flyoutDisp)
				}
				ObjRelease(shellProvider)
				if (BrightnessSetter._FindAndSetOSDWindow())
					return
			}
			; who knows if the SID & IID above will work for future versions of Windows 10 (or Windows 8). Fall back to this if needs must
			Loop 2 {
				SendEvent {Volume_Mute 2}
				if (BrightnessSetter._FindAndSetOSDWindow())
					return
				Sleep 100
			}
		}
	}
	
	_FindAndSetOSDWindow()
	{
		static FindWindow := DllCall("GetProcAddress", "Ptr", DllCall("GetModuleHandle", "Str", "user32.dll", "Ptr"), "AStr", A_IsUnicode ? "FindWindowW" : "FindWindowA", "Ptr")
		return !!((BrightnessSetter._osdHwnd := DllCall(FindWindow, "Str", "NativeHWNDHost", "Str", "", "Ptr")))
	}

	_On_WM_POWERBROADCAST(wParam, lParam)
	{
		;OutputDebug % &this
		if (wParam == 0x8013 && lParam && NumGet(lParam+0, 0, "UInt") == NumGet(BrightnessSetter._GUID_ACDC_POWER_SOURCE()+0, 0, "UInt")) { ; PBT_POWERSETTINGCHANGE and a lazy comparison
			this._AC := NumGet(lParam+0, 20, "UChar") == 0
			return True
		}
	}

	_GUID_VIDEO_SUBGROUP()
	{
		static GUID_VIDEO_SUBGROUP__
		if (!VarSetCapacity(GUID_VIDEO_SUBGROUP__)) {
			 VarSetCapacity(GUID_VIDEO_SUBGROUP__, 16)
			,NumPut(0x7516B95F, GUID_VIDEO_SUBGROUP__, 0, "UInt"), NumPut(0x4464F776, GUID_VIDEO_SUBGROUP__, 4, "UInt")
			,NumPut(0x1606538C, GUID_VIDEO_SUBGROUP__, 8, "UInt"), NumPut(0x99CC407F, GUID_VIDEO_SUBGROUP__, 12, "UInt")
		}
		return &GUID_VIDEO_SUBGROUP__
	}

	_GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS()
	{
		static GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__
		if (!VarSetCapacity(GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__)) {
			 VarSetCapacity(GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 16)
			,NumPut(0xADED5E82, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 0, "UInt"), NumPut(0x4619B909, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 4, "UInt")
			,NumPut(0xD7F54999, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 8, "UInt"), NumPut(0xCB0BAC1D, GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__, 12, "UInt")
		}
		return &GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS__
	}

	_GUID_ACDC_POWER_SOURCE()
	{
		static GUID_ACDC_POWER_SOURCE_
		if (!VarSetCapacity(GUID_ACDC_POWER_SOURCE_)) {
			 VarSetCapacity(GUID_ACDC_POWER_SOURCE_, 16)
			,NumPut(0x5D3E9A59, GUID_ACDC_POWER_SOURCE_, 0, "UInt"), NumPut(0x4B00E9D5, GUID_ACDC_POWER_SOURCE_, 4, "UInt")
			,NumPut(0x34FFBDA6, GUID_ACDC_POWER_SOURCE_, 8, "UInt"), NumPut(0x486551FF, GUID_ACDC_POWER_SOURCE_, 12, "UInt")
		}
		return &GUID_ACDC_POWER_SOURCE_
	}

}

BrightnessSetter_new() {
	return new BrightnessSetter()
}

BS := new BrightnessSetter()

![::
	BS.SetBrightness(-10)
;	send, #a 
;	sleep, 800
;	click, 61, 975
;	sleep, 500
;	send, {Esc}
	Return

!]::
	BS.SetBrightness(+20)
;	send, #a 
;	sleep, 800
;	click, 61, 975
;	sleep, 500
;	send, {Esc}
	Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive 							;;;;area0
F9::
	KeyHistory
	return
*^+::								
	send, {vkA2sc01D}{vkA0sc02A}
	Return
Capslock & v::
	run, C:\Users\windown10\Desktop\0. HX Upload\HXUpload\VBAtoAHK.ahk
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 	Wcliparea & testarea
WinClipProcess() {
	WinClip.Copy()
	t := WinClip.GetText()
	loop,2 
	  t := RegExReplace( t, "m)(`t+|^)([\.\d]+)(`t+|$)", "`t<td>$2</td>`t" )
	loop,2
	  t := RegExReplace( t, "m)`t+([^<>`n`r]+?)(`t+|$)", "`t<td rowspan=""4"">$1</td>`t" )
	t := RegExReplace( t, "`t" )
	t := RegExReplace( t, "(`r`n)(?=.+)", "</tr>`n<tr align=""center"">" )
	t := RegExReplace( t, "^", "<tr align=""center"">" )
	StringTrimRight, t, t, 2
	t := RegExReplace( t, "$", "</tr>" )
	WinClip.SetText( t )
	return
}
$!+f::
	keywait, LAlt, L
	keywait, LShift, L
	WinClip.Clear()
	send, #+s
	clipwait,, 1
	sleep, 1000
	format := "png"
	des := "C:\Users\windown10\Desktop\haha." format
	WinClip.SaveBitmap(des, format)
	return
` & h::
	;WinClipProcess()
	WinClip.Copy()
	clipboard := WinClip.GetHTML()
	clipboard := clipboard
	RegExMatch(clipboard, "iU)href="".*""", match)
	Msgbox, % match := RegExReplace(match, "href=")
	Msgbox, % match := RegExReplace(match, """")
	return
` & r::	
	clipboard := "href=""Additional information"" hehehehe"" "
	RegExMatch(clipboard, "iU)href="".*""", match)
	match := RegExReplace(match, "href=")
	Msgbox, % match
	return
` & 6::
	ex := ComObjCreate("Excel.Application")
	ex.Workbooks.Open("C:\Users\windown10\Desktop\0. HX Upload\HXUpload\Excel File.xlsm")
	ex.sheets("vba test").range("A1:A3").copy ;ex.Worksheets("vba test").range("D5")
	return
` & 7::
	oExcel := ComObjCreate("Excel.Application")
	;oExcel.ActiveWorkbook.Worksheets("vba test").Range("A1:D4").Copy _ 
    oExcel.Range("A1").Value := 3 ; set cell A1 to 3
	oExcel.Range("A2").Value := 7 ; set cell A2 to 7
    return
` & 8::
	oExcel := ComObjCreate("Excel.Application") ; create Excel Application object
	oExcel.Workbooks.Add ; create a new workbook (oWorkbook := oExcel.Workbooks.Add)

	oExcel.Range("A1").Value := 3 ; set cell A1 to 3
	oExcel.Range("A2").Value := 7 ; set cell A2 to 7
	oExcel.Range("A3").Formula := "=SUM(A1:A2)" ; set formula for cell A3 to SUM(A1:A2)
	return
Capslock & f::
	wc := new WinClip
	html := "<b> this is bold text</b>"
	WinClip.SetHTML(html)
	WinClip.Paste()
	return


#IfWinActive, Google Drive - Cent Browser
;/::
	MouseGetPos, VarX, VarY
	CoordMode, mouse, screen
	send, {tab}
	sleep, 300
	click, 924, 163
	send, {LButton}
	click, %VarX%, %VarY%, 0
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Ifwinnotactive
Groupadd, NotActive, ahk_exe EXCEL.EXE
Groupadd, NotActive, ahk_exe POWERPNT.EXE
;#Ifwinnotactive ahk_group NotActive
#If !(WinActive("ahk_exe POWERPNT.EXE") || WinActive("ahk_exe EXCEL.EXE"))
+space::
	send, {WheelUp 4}
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Run Function Area
#IfWinActive 
;Unused ^.::
$+Rbutton::
	keywait, LShift, L
	Run "C:\Program Files\Sublime Text\sublime_text.exe" "C:\Users\windown10\Desktop\0. HX Upload\HXUpload\HXBanana Script.ahk"
	return
;;;;;;;;;;;;;;;;;;;;;;; Capsarea
;*CapsLock::
	KeyWait, CapsLock, L
	If (A_ThisHotkey = "*CapsLock")
		send, {enter}
	return
` & w::
	send, ^c
	sleep, 300
	run, https://en.wiktionary.org/w/index.php?search=%clipboard%
	return
Capslock::Enter
^Capslock::
 	SetCapsLockState, % GetKeyState("CapsLock","T") ? "Off" : "On"
	;SoundBeep, 500, 750
	return
Capslock & q::

	return
Capslock & e::
	
	return

Capslock & w::
	send, {Up}
	return
Capslock & a::
	send, {Left}
	return
Capslock & d::
	send, {Right}
	return
Capslock & s::
	send, {Down}
	return
Capslock & h::
	WinSet, ExStyle, ^0x80, A
	return
Capslock & c::							;Generate Hyperlink with Title
	WinGetActiveTitle, current
	clipboard := ""
	IfWinActive, ahk_exe chrome.exe
		{
			send, ^+j 
			clipwait 
		}
	else
		{
			send, ^c
			clipwait 
			run, %clipboard% 
			clipboard := ""
			WinWaitActive, ahk_exe chrome.exe
			sleep, 2000
			send, ^+j
			clipwait
		}
	WinGetTitle, title, A
	title := RegExReplace(title, " - Google Chrome")
	HTML := "<a href='$2'>$1</a>"
	HTML := StrReplace(HTML, "$1", title)
	HTML := StrReplace(HTML, "$2", clipboard)
	SetClipboardHTML(HTML)
	WinActivate, %current%
	MsgBox, ,,copied!,0.5
	Return

	SetClipboardHTML(HtmlBody, HtmlHead:="", AltText:="") {       ; v0.67 by SKAN on D393/D42B
	Local  F, Html, pMem, Bytes, hMemHTM:=0, hMemTXT:=0, Res1:=1, Res2:=1   ; @ tiny.cc/t80706
	Static CF_UNICODETEXT:=13,   CFID:=DllCall("RegisterClipboardFormat", "Str","HTML Format")

	  If ! DllCall("OpenClipboard", "Ptr",A_ScriptHwnd)
	    Return 0
	  Else DllCall("EmptyClipboard")

	  If (HtmlBody!="")
	  {
	      Html     := "Version:0.9`r`nStartHTML:00000000`r`nEndHTML:00000000`r`nStartFragment"
	               . ":00000000`r`nEndFragment:00000000`r`n<!DOCTYPE>`r`n<html>`r`n<head>`r`n"
	                         . HtmlHead . "`r`n</head>`r`n<body>`r`n<!--StartFragment -->`r`n"
	                              . HtmlBody . "`r`n<!--EndFragment -->`r`n</body>`r`n</html>"
	      Bytes    := StrPut(Html, "utf-8")
	      hMemHTM  := DllCall("GlobalAlloc", "Int",0x42, "Ptr",Bytes+4, "Ptr")
	      pMem     := DllCall("GlobalLock", "Ptr",hMemHTM, "Ptr")
	      StrPut(Html, pMem, Bytes, "utf-8")

	      F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","<html>", "Ptr") - pMem
	      StrPut(Format("{:08}", F), pMem+23, 8, "utf-8")
	      F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","</html>", "Ptr") - pMem
	      StrPut(Format("{:08}", F), pMem+41, 8, "utf-8")
	      F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","<!--StartFra", "Ptr") - pMem
	      StrPut(Format("{:08}", F), pMem+65, 8, "utf-8")
	      F := DllCall("Shlwapi.dll\StrStrA", "Ptr",pMem, "AStr","<!--EndFragm", "Ptr") - pMem
	      StrPut(Format("{:08}", F), pMem+87, 8, "utf-8")

	      DllCall("GlobalUnlock", "Ptr",hMemHTM)
	      Res1  := DllCall("SetClipboardData", "Int",CFID, "Ptr",hMemHTM)
	  }

	  If (AltText!="")
	  {
	      Bytes    := StrPut(AltText, "utf-16")
	      hMemTXT  := DllCall("GlobalAlloc", "Int",0x42, "Ptr",(Bytes*2)+8, "Ptr")
	      pMem     := DllCall("GlobalLock", "Ptr",hMemTXT, "Ptr")
	      StrPut(AltText, pMem, Bytes, "utf-16")
	      DllCall("GlobalUnlock", "Ptr",hMemTXT)
	      Res2  := DllCall("SetClipboardData", "Int",CF_UNICODETEXT, "Ptr",hMemTXT)
	  }

	  DllCall("CloseClipboard")
	  hMemHTM := hMemHTM ? DllCall("GlobalFree", "Ptr",hMemHTM) : 0

	Return (Res1 & Res2)
	return 
	}
Capslock & g::	
	send, ^+j
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   `area
` & d::															;Download file
	InputBox, URL_original, File URL, Please enter the URL of the file,, 300, 100
	If ErrorLevel
	URL_original := "https://drive.google.com/file/d/1ToNpARX3Jycnb-lr2UFnLMzhxe79EPgP/view?usp=sharing"
	ID := RegExReplace(URL_original, "/d/|/view", "©")
	array := StrSplit(ID, "©")
	URL_modified := "https://drive.google.com/uc?export=download&id=" . array[2] 
	UrlDownloadToFile, % URL_modified, C:\Users\Administrator\Desktop\file.pdf
	msgbox,,, done!, 0.6
	return
` & 4::
	;RemoveMenu(WinExist("ahk_exe chrome.exe"), ) 
	RETURN
` & 5::
	Gui,Color,0x000000
	Gui,-Caption
	Gui,Show, NA w%A_ScreenWidth% h%A_ScreenHeight%	
	Loop
	{
		If GetKeyState("Esc","P") 
		{
			BlockInput Off
			Break
		}
		else if (A_TimeIdlePhysical<500)
		{
			SendMessage, 0x112, 0xF170, 2,, A
			BlockInput On
		}
	}
	Gui,Destroy
	Return
+`::
	keywait, LShift, L
	send, {U+007E}
	return
`::
	sendinput, {U+0060}
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;					HXarea
Capslock & r::
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	InputBox, input, File URL, Please enter the URL of the file,, 300, 100
	If (input="")
		return
	exclude := "-etsy -ebay -amazon -pinterest -aliexpress -indiamart"
	country := "the us the uk new zealand australia taiwan italy austria singapore .io portugal france .com netherlands"
	;ccTLD := "ca us .uk .nz .au .tw .it .at .sg .io .pt .fr .co"
	loop, parse, country, % A_space
	{
		query := input . " " . A_LoopField . " " . exclude
		run, https://www.google.com/search?q=%query%&sourceid=chrome&ie=UTF-8
	}
	return
` & s::
	clipboard := ""
	If WinActive("ahk_exe chrome.exe")
		send, ^+j
	else 
		send, ^c 
	ClipWait
	array := StrSplit(clipboard, "/", " `t")
	clipboard := array[1] . "/" . array[2] . "/" . array[3]
	len := StrLen(clipboard)
	array := StrSplit(clipboard)
	If !(array[len] = "/")
		clipboard := clipboard . "/"
	;MsgBox,,, % clipboard, 
	FileRead, var, C:\Users\windown10\Desktop\0. HX Upload\HXUpload\sitelist.txt
	var := RegExReplace(var, "https://www.google.com/|chrome://bookmarks/")
	if (var ~= clipboard) or (clipboard ~= "chrome-extension://")
	{
		;msgbox,,, this is old!, 0.5
		sleep, 50
		send, ^s
	}
	else
	{
		msgbox, 4,, this is new!, 6
		IfMsgBox Yes
		{
			FileAppend, % clipboard . "`n", C:\Users\windown10\Desktop\0. HX Upload\HXUpload\sitelist.txt
			WinActivate, Google Chrome ahk_exe chrome.exe
			sleep, 100
			send, ^s
		}
		else IfMsgBox No
		{
			FileAppend, % clipboard . "`n", C:\Users\windown10\Desktop\0. HX Upload\HXUpload\sitelist.txt
			clipboard := clipboard
			winactivate, ahk_exe EXCEL.EXE
		}
		else 
			Msgbox,,, Error!, 0.5
	}
	return
` & a::
	msgbox,,, Please select Google page, 0.3
	keywait, a, D T3
	FileRead, var, C:\Users\windown10\Desktop\0. HX Upload\HXUpload\sitelist.txt
	var := RegExReplace(var, "https://www.google.com/|chrome://bookmarks/")
	WinGetTitle, old, A
	loop,
	{
		clipboard := ""
		send, ^+j
		clipwait, 5
		array := StrSplit(clipboard, "/", " `t")
		clipboard := array[1] . "/" . array[2] . "/" . array[3]
		len := StrLen(clipboard)
		array := StrSplit(clipboard)
		If !(array[len] = "/")
			clipboard := clipboard . "/"
		;msgbox, % clipboard
		if (var ~= clipboard)
		{
			sleep, 50
			send, ^s
			sleep, 100
		}
		else
		{
			send, ^q
			sleep, 100
			WinGetTitle, new, A
		}
	}	
	Until (new = old)
	return
$#`::
	KeyWait, LWin, L
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	InputBox, call, Dialing Box, Please enter dialing number,,220,140,,,, 15
	If (StrLen)
	clipboard := RegExReplace(call, "[^0-9]")
	clipboard := RegExReplace(call, "[^0-9]")
	if (clipboard ~= "[0-9]+")
	{	
		;WinActivate, ahk_exe EXCEL.EXE
		run, "C:\Users\windown10\AppData\Local\WhatsApp\WhatsApp.exe" "whatsapp://send/?phone=%clipboard%",, max
		WinWaitActive, ahk_exe WhatsApp.exe
		WinSet, ExStyle, -0x80, ahk_exe WhatsApp.exe
	}
	else
	{
		msgbox,,, error, 0.3
		return
	}
	WinSet, ExStyle, +0x80, ahk_exe WhatsApp.exe
	KeyWait, LShift, D T6
	click, 816, 543
	sleep, 50
	WinActivate, ahk_exe chrome.exe
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;					WinCliptest
` & j::
	keywait, LShift, D
	;clipData := clipboardall
	;clipSize := WinClip.Snap( clipData )
	;paste( "this is text" )
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 				
F1::
` & t::
	setdefaultmousespeed, 30
	sendevent, {click left 818 382 down}
	sendevent, {click left 390 203 up}
	return
$>!0:: 								 									; WinGetTitle current window
	KeyWait, LAlt, L
	WinGetTitle, title, A 
	WinGet, title2, ProcessName, A
	clipboard=%title% ahk_exe %title2%
	MsgBox,,, %title% ahk_exe %title2%, 2
	return
>!c::															;Copy Process Path
	KeyWait, RAlt, L
	WinGet, win, ProcessPath, A
	ToolTip, %win%
	clipboard := win
	Settimer, RemoveToolTip, -3000
	return
` & g::										;gmail automation
	SetScrollLockState, Off
	WinActivate, ahk_exe chrome.exe
	MsgBox, Please check if Gmail is opening
	WinActivate, ahk_exe EXCEL.EXE
	MsgBox,,, Please select data and press LCtrl!, 1
	Keywait, LCtrl, D
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	InputBox, input, Loop Count, Please enter number of loops,,200,100
	loop, %input%
	{
	clipboard := ""
	send, ^c
	clipwait
	WinActivate, ahk_exe chrome.exe
	sleep, 100
	click, 51, 166
	sleep, 800
	click, 661, 427
	send, ^v
	sleep, 300
	send, {tab}
	sleep, 100
	send, % "High quality INCENSE PRODUCTS from Vietnam that might intrigue you"
	sleep, 500
	click, 1154, 946
	sleep, 600
	click, 988, 720, 0
	sleep, 800
	click, 695, 769
	sleep, 2300
	click, 670, 939
	Winactivate, ahk_exe EXCEL.EXE
	sleep, 300
	send, {down}
	}
	return
` & 2::  ; make the color under the mouse cursor invisible.
	MouseGetPos, MouseX, MouseY, MouseWin
	PixelGetColor, MouseRGB, %MouseX%, %MouseY%, RGB
	WinSet, TransColor, Off, ahk_id %MouseWin%
	WinSet, TransColor, %MouseRGB% 220, ahk_id %MouseWin%
	sleep, 4000
	WinSet, TransColor, %MouseRGB%, ahk_id %MouseWin%
	return
#w::
	keywait, LWin, L
	WinMinimize, A
	return
#2::
	keywait, LWin, L
	clipboard := "" 	
	Send, ^c
	ClipWait, 0.5
	If ErrorLevel
	{
		InputBox, input, Wiktionary Search, , , , , , , , 10, Default
		run, https://translate.google.com/?sl=auto&tl=en&text=%input%&op=translate
	}
	else
		run, https://translate.google.com/?sl=auto&tl=en&text=%clipboard%&op=translate
	return
#Esc::
	KeyWait, LAlt, L
	send, ^+{Esc}
	return
;Down::
;	send, {Down 5}
;	return
;Up::
; send, {Up 5}
; return

;^`::
	clipboard =
	Send, ^c
	ClipWait,
	Sleep 300
	cb = %clipboard% incense
	run, "C:\Program Files\Google\Chrome\Application\chrome.exe" "http://www.google.com/search?q=%cb%
	return
!Numpad2::
	CoordMode, mouse, screen
	KeyWait, ctrl
	WinActivate, ahk_exe chrome.exe
	send, ^c 
	clipwait
	send, {ctrl down}2{ctrl up}
	send, ^z
	sleep, 300
	click, 203, 585
	sleep, 200
	send, ^a
	return
>+q::
	KeyWait, Rshift
	send, ^c 
	clipwait
	WinActivate, ahk_exe chrome.exe
	sleep, 500
	send, ^b
	sleep, 500
	send, gg 
	send, {space}
	send, ^v
	sleep, 600
	send {enter}
	sleep, 3000
	click, 710, 382
	sleep, 500
	send, /
	send, ^a
	sleep, 300
	setmousedelay, 10
	SendEvent {Click 471, 113 Down}{Click 334, 116 Up}
	return 
^+v::
    Clip0 = %ClipBoardAll%
    ClipBoard = %ClipBoard% ; Convert to plain text
    Send ^v
    Sleep 1000
    ClipBoard = %Clip0%
    VarSetCapacity(Clip0, 0) ; Free memory
    Return
#x::												;Add/remove quotes
	KeyWait, LWin, L 
	IfWinActive, Google Search ahk_exe chrome.exe
		{
			send, ^a
		}
	else 
		{
		}
	clipboard := ""
	send, ^c 
	clipwait
	oldstr := clipboard
	IfInString, oldstr, "
	{
		StringReplace, newstr, oldstr, ",,All
		clipboard = %newstr%
		send, ^v
	}
	else
	{
		quote:= """"
		clipboard = %quote%%clipboard%%quote%
		sendinput, ^v 
	}
	send, {enter}
	return
` & 3::
	;ControlSend, _WwG1, {vk2Esc153 2}, ahk_exe OUTLOOK.EXE
	outlooksend()
	return
	outlooksend()
	{
	clipboard := ""
	sleep, 100
	send, ^c  
	clipwait
	WinActivate, ahk_exe OUTLOOK.EXE
	sleep, 500
	send, ^+1
	WinWait, Message ahk_exe OUTLOOK.EXE
	sleep, 300			
	send, {Tab 3}
	sleep, 100		
	send, {delete 2}
	ControlSetText, RichEdit20WPT2, % clipboard, ahk_exe OUTLOOK.EXE
	sleep, 500
	ControlFocus, &Send, ahk_exe OUTLOOK.EXE
	send, {vk20sc039}
	loop {
		sleep, 300
		If WinExist("ahk_class #32770") 
		{
			traytip, 11, hehe
			WinKill, ahk_class #32770
			ControlFocus, &Send, ahk_exe OUTLOOK.EXE
			send, {vk20sc039}
		}
		else
			break
	}
	WinWaitClose, Message ahk_exe OUTLOOK.EXE
	WinActivate, ahk_exe EXCEL.EXE
	sleep, 100
	send, {down}
	sleep, 300
	}
	return
` & f::
	WinKill, ahk_class #32770
	return
$^Numpad3::										;Outlook Sending Messages
	KeyWait, LCtrl, L
	SetScrollLockState, Off
	Winset, AlwaysOnTop, Off, ahk_exe EXCEL.EXE    
	InputBox, input, Loop Count, Please enter the number of interations,, 200, 100
	If ErrorLevel
		return
	Winset, AlwaysOnTop, On, ahk_exe EXCEL.EXE    
	loop 
	{
		OutlookSend()
	} 
	Until A_Index = input
	Winset, AlwaysOnTop, Off, ahk_exe EXCEL.EXE 
	MsgBox, done!
	return
#s::
	KeyWait, Lwin
	send, {RButton}
	sleep, 500
	send, v
	WinWaitActive, Save As
	sleep, 500 
	send, {enter}
	return
>^delete::
	KeyWait, ctrl
	send, {text} export9@hxcorp.com.vn
	sleep, 300
	send, {tab}
	send, {text} Richard Truong
	sleep, 300
	send, {tab}  
	send, {text} +84 379 004481
	sleep, 300
	send, {tab} 
	send, {text} Agarbatti/Incense sticks
	send, {tab}
	send, v 
	send, {down 2}
	send, {tab}
	send, {text} Ho Chi Minh
	sleep, 500
	send, {tab}
	sleep, 300
	WinActivate, ahk_exe POWERPNT.EXE
	sleep, 300
	sendinput, {ctrl down}c{ctrl up}
	sleep, 500 
	WinActivate, ahk_exe chrome.exe
	sleep, 500
	send, ^v 
	sleep, 300
	send, {backspace}
	sleep, 300
	send, {tab}
	send, {enter}
	sleep, 1000
	send, {tab}
	send, {enter}
	return
!6::
	keywait, LAlt, L
	run, C:\Program Files\Everything\Everything.exe
	return 
$!F7::
	SetTitleMatchMode, 2
	ControlSend, , {shiftdown}n{shiftup}, - YouTube - Cent Browser ahk_class Chrome_WidgetWin_1
	return 
#q::
	Ifwinexist Music
	WinMaximize, Music
	else  
	run, C:\Users\zlegi\Desktop\Music
	WinWaitActive, Music 
	WinMaximize, Music	
	return 
^+h::
	clipboard := ""
	send, ^+j
	ClipWait
	run, https://web.archive.org/web/*/%clipboard% 
	return 
$!F6::
	WinGet, WinStatus, MinMax, A
	if (WinStatus != 0)
	WinRestore, P1 - PowerPoint
	CoordMode, Mouse, Screen 
	WinMove, A,, -9, -12, 1361, 1039
	return 
#b::
	BlockInput, on 
	sendinput, {LWin}
	sleep, 300
	send, bluetooth
	sleep, 300 
	send, {enter}
	BlockInput, off 
	return
$!WheelDown::
	SendInput, {WheelDown 2}
	return 
$!WheelUp::
	SendInput, {WheelUp 2}
	return 
;$^!s::						;Search Google
	KeyWait, ctrl
	KeyWait, alt
	clipboard =
	Send, ^c
	ClipWait,
	Sleep 300
	cb = %clipboard%
	run, "C:\Program Files\Google\Chrome\Application\chrome.exe" "http://www.google.com/search?q=%cb%"
	return
Capslock & z::
	send, +{Home}
	send, {delete}
	return 
Capslock & x::
	send, +{End}
	send, {delete}
	return 
!enter::
	send, {end}
	sleep, 300
	send, {enter}
	Return 
^!g::
	run,   C:\Users\windown10\Desktop\0. HX Upload\Release All Keys.ahk
	send, #g 
	sleep, 500
	send, #!r
	soundbeep, 750, 500
	sleep, 1000
	click, 920, 484
	return
$!+a::															;Run a link or Google Search adaptibly
	KeyWait, LAlt, L
	KeyWait, LShift, L
	browser="C:\Program Files\Google\Chrome\Application\chrome.exe"	
	If !WinActive("ahk_exe anki.exe")
	{
		clipboard := ""		
		Send, ^c				 
		clipwait, 1.5
	}
	else
	{
		Send, ^c	
		sleep, 150
	}
	if !(ErrorLevel) {
	Clipboard := Clipboard         ;Convert Clipboard to text, auto-trim leading and trailing spaces and tabs.
	clipboard := RegexReplace(clipboard, "^\s+|\s+$") ; trim leading and trailing spaces and tabs in case the above doesn't work properly
	;Clean Clipboard: change carriage returns to spaces, change >=1 consecutive spaces to +
	Clipboard := RegExReplace(RegExReplace(Clipboard, "\r?\n"," "), "\s+","+") 
	if Clipboard contains chrome://
		{
			clipboard := RegexReplace(clipboard, "\+", "") 
			WinActivate, ahk_exe chrome.exe
			send, ^b
			WinWaitActive, New Tab - ahk_exe chrome.exe
			sleep, 50
			send, ^v 
			sleep, 200
			send, {enter}
		}
	else if Clipboard contains @ 
		{
			run, mailto:%clipboard%
		}
	else if Clipboard contains +,..      ;Open URLs, Google non-URLs. URLs contain . but do not contain + or .. or @
	Run, %browser% www.google.com/search?q=%Clipboard%
	else if Clipboard not contains .
	Run, %browser% www.google.com/search?q=%Clipboard%
	else
	Run, %browser% %Clipboard%
	}
	return
!+s::
	KeyWait, LAlt, L
	KeyWait, LShift, L
	Clipboard := ""					
	Send, ^c
	clipwait	
	clipboard := RegExReplace(clipboard, """|^\s+|\s+$")
	msgbox, % clipboard
	clipboard := """" . clipboard . """"
	run, www.google.com/search?q=%Clipboard%
	return
$!+w::														;Verbatim Searching
	KeyWait, LAlt, L
	KeyWait, LShift, L
	If !WinActive("ahk_exe anki.exe")
		{
			clipboard := ""		
			Send, ^c					;Copy current selection, continue if no errors.
			ClipWait, 2
		}
		else
		{
			send, ^c
			sleep, 100
		}
	if !(ErrorLevel) 
	{
		clipboard := """" . clipboard . """"
		run, www.google.com/search?q=%Clipboard%
	}
	return
$!+e::											;run multiple URLs
	keywait, LAlt, L
	keywait, LShift, L
	clipboard := ""
	send, ^c
	clipwait
	if !(ErrorLevel) 
	{
		Clipboard := Clipboard         
		sleep, 50
		Clipboard := RegexReplace(Clipboard, "^\s+|\s+$|")
		Clipboard := RegexReplace(Clipboard, "`t|`r`n", "©") 
		;msgbox, % clipboard
		loop, parse, clipboard, ©
		{
			run, % A_LoopField
		}
	}
	return
+F3::
	CLIPBOARD =
	Send ^c
	ClipWait 1
	text := Clipboard
	If text =
		Return
	If (mode = "U")
	{
		StringLower text, text, T	; Title case
		mode = T
	}
	Else If (mode = "T")
	{
		StringLower text, text
		mode = L
	}
	Else	; Default
	{
		StringUpper text, text
		mode = U
	}
	Clipboard := text
	ClipWait 1
	Send ^v 
return
^space::														;pause Youtube
	send, {backspace}
	return 
>^LButton::														;MouseGetPos current
	CoordMode, mouse, screen
	MouseGetPos, varx, vary
	tooltip, %varx% - %vary%, 985, 551
	SetTimer,RemoveToolTip, -2000
	clipboard = %varx%, %vary%
	return 
>!LButton::														;WinGetPos current
	CoordMode, mouse, screen
	WinGetpos, X, Y, W, H, A
	tooltip, %X%  %Y%  %W%  %H%, 985, 551
	SetTimer,RemoveToolTip, -2000
	clipboard = %X%, %Y%, %W%, %H%
	return 
^!`::
#Persistent
SetTimer, WatchCursor, 100
return
WatchCursor:
MouseGetPos, , , id, control
WinGetTitle, title, ahk_id %id%
WinGetClass, class, ahk_id %id%
ToolTip, ahk_id %id%`nahk_class %class%`n%title%`nControl: %control%
return
#h::														;Youtube watch mode
	CoordMode, mouse, screen
	click, 1275, 51
	sleep, 300
	send, !h
	send, !+3  
	send, !3
	return 
$!1::
	KeyWait, LAlt, L
	MouseGetPos, xpos, ypos
	WinMaximize, ahk_exe chrome.exe
	WinActivate, ahk_exe chrome.exe
	WinGet, WinStatus, MinMax, ahk_exe anki.exe
	if (WinStatus != 0)
		WinRestore, ahk_exe anki.exe
	WinActivate, ahk_exe anki.exe
   	WinMove, ahk_exe anki.exe,, 832, 386, 470, 603
   	gosub, hideregion
	click, 51, 733, 0
	click, %xpos%, %ypos%, 0
   	return

   	hideregion:
   	;WinSet, Style, -0xC00000, ahk_exe anki.exe
	DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist("ahk_exe anki.exe")
  , "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_DISABLED := 1, "uint", 4)
	WinSet, Region, 22-85 W470 H511, ahk_exe anki.exe
	;keywait, LShift, D
	;WinSet, Region,, ahk_exe anki.exe
	return 
!4::													;Maximize/Minimize Window
	WinGet, status, MinMax, A
	If (status) = 1
	PostMessage, 0x0112, 0xF120,,, A
	else
	WinMaximize, A
	return
$!w::
	KeyWait, LAlt, L
	send, !{F4}
	return 
!F12:: HideShowTaskbar(hide := !hide)
HideShowTaskbar(action) {
   static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
   VarSetCapacity(APPBARDATA, size := 2*A_PtrSize + 2*4 + 16 + A_PtrSize, 0)
   NumPut(size, APPBARDATA), NumPut(WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
   NumPut(action ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)
   DllCall("Shell32\SHAppBarMessage", UInt, ABM_SETSTATE, Ptr, &APPBARDATA)
}
return
$!Rbutton::
	keywait, LAlt, L
	If !WinExist("ahk_exe anki.exe")
	{
		run, C:\Program Files\Anki\anki.exe
		WinWaitActive, ahk_exe anki.exe
		sleep, 2000
		gosub, hideregion
	}
	else if !WinActive("ahk_exe anki.exe")
	{
		WinActivate, ahk_exe anki.exe
		gosub, hideregion
	}
	else 
	{
		WinMinimize, ahk_exe anki.exe
	}
	return
^Numpad7::
	WinSet, Style, -0xC00000, A
	WinSet, ExStyle, +0x80, A
	return
$!2::
	KeyWait, LAlt, L
	IfWinExist, ahk_exe hh.exe
	{
		WinActivate, ahk_exe hh.exe
		return
	}
	else 
	{
		run, C:\Program Files\AutoHotkey\AutoHotkey.chm,, Max
		WinWaitActive, ahk_exe hh.exe
		sleep, 500
		click, 218, 72
		return
	}
$#Mbutton::
	IfWinExist, ahk_exe anki.exe
	{
		WinActivate, ahk_exe anki.exe
		return
	}
	else 
	{
		run, C:\Program Files\Anki\anki.exe
		WinWaitActive, ahk_exe anki.exe
		sleep, 2000
		WinActivate, ahk_exe anki.exe
		return 
	}
$+Mbutton::
	KeyWait, LShift, L
	Winget, current, ProcessName, A
	if (current = "POWERPNT.EXE")
		PostMessage, 0x0112, 0xF020,,, A
	else if WinExist("ahk_exe POWERPNT.EXE")
		WinActivate, ahk_exe POWERPNT.EXE
	else
		Run, "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE" "C:\Users\windown10\Desktop\0. HX Upload\0. P1CH(HX).pptx",, max
	return
!Mbutton::
	KeyWait, LAlt, L
	WinGet, current, ProcessName, A
	if (current = "EXCEL.EXE")
		PostMessage, 0x0112, 0xF020,,, A 
	else
		WinActivate, ahk_exe EXCEL.EXE
	return
Capslock & Mbutton::
	WinGet, status, MinMax, A
	If (status) = 1
		PostMessage, 0x0112, 0xF120,,, A
	else
		WinMaximize, A
	return
Mbutton::
	KeyWait, MButton, L
	SetKeyDelay, 100
	send, {alt down}
	send, {tab}
	send, {alt up}
	return
^MButton::
	KeyWait, LCtrl, L
	IfWinExist, ahk_exe chrome.exe
	{
		WinActivate, ahk_exe chrome.exe 
	}
	else 
	{
		run, "C:\Program Files\Google\Chrome\Application\chrome.exe"
		WinWaitActive, ahk_exe chrome.exe
		WinActivate, ahk_class Chrome_WidgetWin_1 
	}
	return
*$!`::
	KeyWait, LAlt, L
	run, C:\Users\windown10\Desktop\0. HX Upload\Release All Keys.ahk
	reload
	Return
$!f::								;Snip
	keywait, LAlt, L
	send, #+s
	Return
!F2::
send, #{PrintScreen}
Return
!Space::
send, {Delete}
Return

^!a:: 			           ;Always on top
	CoordMode, tooltip, screen
	WinSet, Alwaysontop, , A       	
	mousegetpos, x, y, win
	WinGet, ExStyle, ExStyle, ahk_id %win%
	If (ExStyle & 0x8)
  	ExStyle = On AlwaysOnTop
	Else
 	ExStyle = Off AlwaysOnTop
	tooltip, %exstyle%, 646, 486
	SetTimer, RemoveToolTip, -2000
	return
!z::
	send, {home}
	return
!x::
	send, {end}
	return
!a::
	send, {alt down}{left}{alt Up}
	return
!s::
	send, {alt down}{right}{alt Up}
	return
$^!x::
	KeyWait, LCtrl, L
	KeyWait, LAlt, L
	send, ^{End}
	Return
$^!z::
	KeyWait, LCtrl, L
	KeyWait, LAlt, L
	send, ^{home}
	Return
!+x::										;Select All to the right
	send, +{end}
	Return
!+z::										;Select All to the left
	send, +{home}
	Return
!left::                                   ;Previous
send, +p
return 
	
!right::								  ;Next
send, +n
return
!.::								;Increase Volume
	CoordMode, ToolTip, screen
	soundset, -5
	SetFormat, float, 2.0
	SoundGet, volume 
	ToolTip , Volume is %volume%, 618, 544
	SetTimer, RemoveToolTip, -2000
	Return
!;::												;Decrease Volume
	CoordMode, ToolTip, screen
	soundset, +5
	SetFormat, float, 2.0
	SoundGet, volume 
	ToolTip , Volume is %volume%, 618, 544
	SetTimer, RemoveToolTip, -2000
	Return
!'::
	CoordMode, ToolTip
	SoundSet, 0
	SetFormat, float, 2.0
	SoundGet, volume 
	ToolTip , Volume is %volume%, 985, 551
	SetTimer, RemoveToolTip, -2000
	Return
!/::											;Volume Status 
	CoordMode, ToolTip
	SetFormat, float, 2.0
	SoundGet, volume 
	ToolTip , Volume is %volume%, 985, 551
	SetTimer, RemoveToolTip, -2000
	return
#t::																; Show/Hide Desktop Icons 
	ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
	If HWND =
		ControlGet, HWND, Hwnd,, SysListView321, ahk_class WorkerW
	If DllCall("IsWindowVisible", UInt, HWND)
		WinHide, ahk_id %HWND%
	Else
		WinShow, ahk_id %HWND%
Return
;~~~~~~~~~~~~~~~~~~ Clipboard ~~~~~~~~~~~~~~~~~~~~
!g::
    Clip0 = %ClipBoardAll%
    ClipBoard = %ClipBoard% ; Convert to plain text
    Send ^v
    Sleep 1000
    ClipBoard = %Clip0%
    VarSetCapacity(Clip0, 0) ; Free memory
    Return
!=::
	send, ^c
	StringUpper Clipboard, Clipboard, T
	send, ^v
	RETURN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 	Hotstrings Area


;;;;
:*:@1::zlegioncommanderz@gmail.com
:*:@c::©
:*:@2::71802213@student.tdtu.edu.vn
:*:@3::Richard Truong{tab}
:*:@4::export9@hxcorp.com.vn{tab}
:*:@5::84379004481{tab}
:*:@6::High quality INCENSE STICKS from Vietnam that might intrigue you{tab}
:*:@7::Hang Xanh Co., LTD{tab}
:*:@8::173 Dien Bien Phu, Binh Thanh District{tab}
:*:dfff::different between {spacce}
:*:ppp::powerpoint
:*:aaa::about
:*R:ggg::http://www.google.com/search?q=
:*:qqq::wiki{enter}
:*:fbb::facebook{enter}
:*:iii::
	BlockInput, on
	send, {text}incenso
	send, {enter}
	sleep, 500
	BlockInput, off
	return
:*:rrr::
	BlockInput, on
	send, {text}røgelse
	send, {enter}
	sleep, 700
	BlockInput, off
	return
:*c1:sss::
	BlockInput, on
	send, % "incense"
	send, {enter}
	sleep, 700
	BlockInput, off
	return
:*:dont::don't
:*:doesnt::doesn't	
:*:cant::can't
:*:wont::won't
:*:hhh::autohotkey{enter}
:*:ahk::ahk_exe
:*:input box::InputBox, input, File URL, Please enter the URL of the file,, 300, 100
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 	#IfWinActive Area 
#IfWinActive Alibaba Manufacturer Directory
;^2::
	KeyWait, Lctrl, L
	send, {esc}
	send, ^f
	sleep, 300
	sendinput, % "Photos and videos"
	send, {enter}
	sleep, 300
	send, {enter}
	sleep, 300
	click, 439, 601
	sleep, 1000
	click, 460, 224
	return
#IfWinActive  ahk_exe OUTLOOK.EXE
$!1::
	KeyWait, LAlt, L
	send, ^+1
	WinWaitActive, ahk_class rctrl_renwnd32,, 1
	sleep, 300
	click, 73, 313
	send, {delete 2}
	sleep, 500
	send, {Shift Down}{Tab 3}{Shift Up}
	send, ^a
	sleep, 500
	send, ^v
	sleep, 50
	click, 28, 178, 0
	return
^+1::
	send, ^+1
	return
#IfWinActive Browse ahk_exe anki.exe  
!s::
	KeyWait, LAlt, L
	WinClose, Browse ahk_exe anki.exe  
	return
!d::
	KeyWait, LAlt, L
	CoordMode, mouse, screen
	WinMove, Browse ahk_exe anki.exe,, 858, 429, 421, 548
	WinActivate, Browse ahk_exe anki.exe
	click, 1162, 746
	sleep, 500
	send, ^v
	sleep, 500
	send, ^{enter}
	return
^d::
	send, ^d 
	return 
#If WinActive("User 1 - Anki ahk_exe anki.exe") 
$!w::
	return
#If WinActive("User 1 - Anki ahk_exe anki.exe") and PixelGet("0xF0F0F0")
$!w::
	return
a::
	send, a
	WinWait, Add ahk_exe anki.exe
	WinActivate, Add ahk_exe anki.exe
	WinSet, Style, -0xC00000, A
	WinMove, A,, 811, 378, 470, 603
	return
;;;;
`::
	send, /
	return
g::
	send, /
	WinWait, Study Deck
	send, graphic{enter}
	return
c::
	send, /
	WinWait, Study Deck
	send, computing{enter}
	return
q::
	send, /
	WinWait, Study Deck
	send, quotes{enter}
	return
i::
	send, /
	WinWait, Study Deck
	send, int'l{enter}
	return
n::
	send, /
	WinWait, Study Deck
	send, natural sciences_temp{enter}
	return
e::
	send, /
	WinWait, Study Deck
	send, eng_temp{enter}
	return
h::
	send, /
	WinWait, Study Deck
	send, HTML{enter}
	return
v::
	send, /
	WinWait, Study Deck
	send, VBA{enter}
	return
x::
	send, /
	WinWait, Study Deck
	send, BA-DA{enter}
	return
r::
	send, /
	WinWait, Study Deck
	send, R - Python{enter}
	return
z::
	send, /
	WinWait, Study Deck
	send, SQL{enter}
	return
f::
	send, /
	WinWait, Study Deck
	send, food{enter}
	return

PixelGet(pixelcolor) {
	PixelGetColor, pixel, 1252, 878
	return (pixel=pixelcolor)
}
;	if (pixel="0xF0F0F0")
;	{
;		send, a
;		winwaitactive, Add ahk_exe anki.exe
;		sleep, 100
;		winmove, Add ahk_exe anki.exe,, 1334, -35, 597, 1064
;	}
#IfWinActive Change Deck ahk_exe anki.exe 
:*:pp::
	send, pronunciation{enter}
	WinClose, Browse ahk_exe anki.exe
	sleep, 300
	click, 
	return
:*:zz::
	send, SQL{enter}
	WinClose, Browse ahk_exe anki.exe
	sleep, 300
	click, 
	return
:*:cc::
	send, computing{enter}
	WinClose, Browse ahk_exe anki.exe
	sleep, 300
	click, 
	return
:*:ee::
	send, eng_temp{enter}
	WinClose, Browse ahk_exe anki.exe
	sleep, 300
	click, 
	return
:*:qq::
	send, quotes{enter}
	WinClose, Browse ahk_exe anki.exe
	sleep, 300
	click, 
	return
:*:hh::
	send, HTML{enter}
	WinClose, Browse ahk_exe anki.exe
	sleep, 300
	click, 
	return
:*:xx::
	send, BA-DA{enter}
	WinClose, Browse ahk_exe anki.exe
	sleep, 300
	click, 
	return
:*:rr::
	send, R - Python{enter}
	WinClose, Browse ahk_exe anki.exe
	sleep, 300
	click, 
	return
:*:nn::
	send, natural sciences{enter}
	WinClose, Browse ahk_exe anki.exe
	sleep, 300
	click, 
	return
#IfWinActive ahk_exe anki.exe 	     ;ankiarea
$!g::
	Keywait, LAlt, L
	send, b
	WinWaitActive, Browse ahk_exe anki.exe
	send, ^+d
	WinWaitClose, Set Due Date
	WinClose, Browse ahk_exe anki.exe
	WinWaitActive, Anki ahk_exe anki.exe
	sleep, 500
	WinClose, Anki ahk_exe anki.exe
	return
$!r::	
	KeyWait, LAlt, L
	send, ^r
	return
!c::
	KeyWait, LAlt, L
	send, ^r
	send, {F7}
	send, ^b
	return
$!w::
	KeyWait, LAlt, L
	send, !{F4}
	return
!v::
	CoordMode, mouse, screen
	KeyWait, Lalt
	send, ^l
	WinWaitActive, Card Types for
	winmove,, Card Types for, 614, 434, 666, 524
	click, 1062, 539
	return
$^enter::
	keywait, LCtrl, L
	send, ^{enter}
	sleep, 500
	WinClose, Add 
	WinActivate, ahk_exe anki.exe
	sleep, 300
	send, d
	return 
!a::
	send, a
	WinSet, Alwaysontop, Off, ahk_exe anki.exe
	WinActivate, Add ahk_exe anki.exe
	WinSet, Alwaysontop, On, Add ahk_exe anki.exe
	WinWaitClose, Add ahk_exe anki.exe
	WinSet, Alwaysontop, On, ahk_exe anki.exe
	return
!e::
	send, e
	WinSet, Alwaysontop, Off, ahk_exe anki.exe
	WinActivate, Edit ahk_exe anki.exe
	WinSet, Alwaysontop, On, Edit ahk_exe anki.exe
	WinWaitClose, Edit ahk_exe anki.exe
	WinSet, Alwaysontop, On, ahk_exe anki.exe
	return
^+v::
    Clip0 = %ClipBoardAll%
    ClipBoard = %ClipBoard% ; Convert to plain text
    Send ^v
    Sleep 1000
    ClipBoard = %Clip0%
    VarSetCapacity(Clip0, 0) ; Free memory
    Return
$^d::
	KeyWait, LCtrl, L 
	send, b
	WinWaitActive, Browse ahk_exe anki.exe
	send, ^d
	WinWaitActive, Change Deck ahk_exe anki.exe
	WinWaitClose, Change Deck ahk_exe anki.exe
	WinClose, Browse ahk_exe anki.exe
	WinWaitClose, Browse ahk_exe anki.exe
	WinActivate, ahk_exe anki.exe
	sleep, 500
	MouseGetPos,,, winid 
	WinGetTitle, title, ahk_id %winid%
	If !(title ~= "i)anki")
		click, 1010, 699
	else
		click
	return
^+p::
	return
!space::	
	send, ^{delete}
	return
!s::	
	send, ^{enter}
	sleep, 500
	WinClose, Add 
	WinActivate, ahk_exe anki.exe
	return 
$!d::
	keywait, LAlt, L
	send, {delete}
	send, {F10}
	sleep, 300
	send, ^v 
	sleep, 100
	send, ^{enter}
	return
#IfWinActive ahk_exe HD-Player.exe
!a::
	send, !a 
	return 

#IfWinActive AutoHotkey - Cent Browser
!e::
	send, !d
	Clipboard= C:\Users\Cong Hao\Desktop\AHK Storage\AutoHotkey_L-Docs-master\docs\AutoHotkey.htm
	send, ^v
	send, {enter}
	return 
#IfWinActive, TikTok - ahk_exe msedge.exe
z::Up
c::Down
#IfWinActive, iCloud Photos - Cent Browser
space::
	send, {WheelDown 3}
	return
t::
	CoordMode, mouse, screen 
	mousegetpos, xpos, ypos
	click, 250, 116
	click, %xpos%, %ypos%, 0 
	return 
u::
	CoordMode, mouse, screen 
	mousegetpos, xpos, ypos
	click, 867, 115
	click, %xpos%, %ypos%, 0
	return 
d::
	CoordMode, mouse, screen 
	mousegetpos, xpos, ypos
	click, 1098, 118
	click, %xpos%, %ypos%, 0
	return 	
f::
	CoordMode, mouse, screen 
	mousegetpos, xpos, ypos
	click, 983, 114
	click, %xpos%, %ypos%, 0
	return 	
a::														;Add to album
	CoordMode, mouse, screen 
	click, 928, 116 
	sleep, 300
	click, 801, 382, 0
	return 
				 
#IfWinActive, ahk_exe AoE2DE_s.exe  		;AOE2 DE
!esc::
	send, {F10}
	return
!1::
	send, +.
	return 
#IfWinActive, ahk_exe AoK HD.exe			; AOE2 HD
#7::
	send, !o 
	return
^`::
	send, {F10}
	return
#IfWinActive, ahk_exe Everything.exe             ;Everything
#b::
	oldClip := Clipboard
	Send, ^c
	ClipWait, 1
	Run, % "Explorer.exe /select,""" Clipboard """"
	Clipboard := oldClip
	return	
#IfWinActive, ahk_exe NOTEPAD.EXE  				 ;Notepad Area
^w::
	send, ^w
	Return
^s::
	send, ^s
	return
;***********************************************************************************************************
#IfWinActive, ahk_exe EXCEL.EXE  			     ;excelarea
Capslock & c::
	send, !{F11}
	return
` & 1::
	loop, 50
	{
	clipboard := ""	
	send, ^c
	clipwait
	clipboard := RegExReplace(clipboard, "[^0-9]")
	if (clipboard ~= "[0-9]+")
		run, "C:\Users\windown10\AppData\Local\WhatsApp\WhatsApp.exe" "whatsapp://send/?phone=%clipboard%",, max
	sleep, 6000
	PixelGetColor, pixel, 848, 543
	If (pixel="0x627514")
	{
		msgbox, error!
		return
	}
	else
	{
		gosub, whatsapp
		sleep, 1000
		Winactivate, ahk_exe EXCEL.EXE
		sleep, 200
		send, {down}
		sleep, 200
	}
	}
	return
^tab::
	KeyWait, LCtrl, L
	send, ^{PgDn}
	return
^+tab::
	KeyWait, LCtrl, L
	KeyWait, LShift, L
	send, ^{PgUp}
	return
$^space::
	KeyWait, LCtrl, L
	send, +{space}
	send, +{F10}
	sleep, 300
	send, d
	return
+WheelUp:: 	
    SetScrollLockState, On 
    SendInput {Left} 
    SetScrollLockState, Off 
	Return 
+WheelDown:: 
    SetScrollLockState, On 
    SendInput {Right} 
    SetScrollLockState, Off 
	Return 
!r::				;Insert a row above
	KeyWait, alt
	send, {alt down}{alt up}
	sleep, 200
	send, i
	send, r 
	return
^d:: 	
	mousegetpos, xpos, ypos
	click, 428, 148
	click, %xpos%, %ypos%
	return
!space::
	send, {delete}
	Return
delete:: 
	send, ^{space}
	Return
^w::	
	send, ^w
	return
^s::
	send, ^s
	return
!c::
	send, !hfp 
	Return
;***********************************************************************************************************
#IfWinActive Instagram ahk_exe chrome.exe
$^1::
	KeyWait, LCtrl, L
	click, 615, 915
	sleep, 300
	send, % "Hi there!"
	send, {enter}
	keywait, LCtrl, D
	click, 615, 915
	send, % "I am Sophia from Hang Xanh Co., Ltd. We bring you our high-quality source of INCENSE STICKS from Vietnam. Our company has over 15 years of experience in exporting incense sticks and incense materials around the globe."
	sleep, 300
	send, {enter}
	sleep, 300
	click, 615, 915
	Fileread, content, C:\Users\Administrator\Desktop\New folder\whatsapp.txt
	clipboard = %content%
	send, ^v
	sleep, 300
	send, {enter}
	sleep, 300
	click, 615, 915
	send, % "Here are some visuals of our products."
	send, {enter}
	sleep, 1000
	click, 1010, 908
	WinWaitActive, Open
	sleep, 300
	send, % "1111.png"
	sleep, 300
	send, {enter}
	sleep, 7000
	click, 1010, 908
	WinWaitActive, Open
	sleep, 300
	send, % "2222.png"
	sleep, 300
	send, {enter}
	sleep, 7000
	click, 1010, 908
	WinWaitActive, Open
	sleep, 300
	send, % "3333.png"
	sleep, 300
	send, {enter}
	sleep, 7000
	click, 1010, 908
	WinWaitActive, Open
	sleep, 300
	send, % "4444.png"
	sleep, 300
	send, {enter}
	sleep, 7000
	click, 1010, 908
	WinWaitActive, Open
	sleep, 300
	send, % "5555.png"
	sleep, 300
	send, {enter}
	sleep, 7000
	click, 615, 915
	send, % "Please chat with us for the price and other information if you find any of these above products interesting"
	send, {enter}
	return
#IfWinActive ahk_exe WhatsApp.exe
$^1::
	KeyWait, LCtrl, L
	whatsapp:
	click, 695, 951
	sleep, 300
	send, % "Hi there!"
	send, {enter}
	;KeyWait, LCtrl, D
	;send, {LCtrl Up}
	sleep, 10000
	click, 695, 951
	send, % "I am Sophia from Hang Xanh Co., Ltd. We bring you our high-quality source of INCENSE STICKS from Vietnam. Our company has over 15 years of experience in exporting incense sticks and incense materials around the globe."
	sleep, 300
	send, {enter}
	sleep, 300
	click, 695, 951
	Fileread, content, C:\Users\Administrator\Desktop\New folder\whatsapp.txt
	clipboard = %content%
	send, ^v
	sleep, 300
	send, {enter}
	sleep, 300
	click, 695, 951
	send, % "Here are some visuals of our products."
	send, {enter}
	sleep, 500
	click, 518, 941
	sleep, 300
	click, 520, 889
	WinWaitActive, Open
	sleep, 300
	sendinput, "2222.png" "1111.png" "3333.png" "4444.png" "5555.png"
	send, {enter}
	click, 1226, 925, 0
	sleep, 3000
	click, 1226, 925
	sleep, 2000
	click, 695, 951
	send, % "Please chat with us for the price and other information if you find any of these above products interesting"
	send, {enter}
	return
^2::
	send, % "Thank you for the info. We'll get in touch shortly."
	return
#IfWinActive, ahk_exe POWERPNT.EXE   			 ; PowerPointArea
;!f::
;	send, {altdown}{altup}
;	sleep, 300
;	send, hvk
;	Return
!s::							;Open Selection Pane
	send, {AltDown}{AltUp}
	sleep 300
	send hgp
	return
!+s::							;Open Selection Pane
	send, {AltDown}{AltUp}
	sleep 300
	send hgp
	return
!6::							;Emoji
	send, !
	sleep 500
	send, ny2
	Return
!+6::							;Emoji
	send, !
	sleep 500
	send, ny2
	Return
!5::							;Add Section										
	send, !
	sleep, 500
	send, ht1a	
	Return
!+5::							;Add Section										
	send, !
	sleep, 500
	send, ht1a	
	Return
!+4::
	send, !
	sleep, 500
	send,ac
	Return
!+3::							;Crop				
	send, !
	sleep, 500
	send, jivc
	Return
$!4::							;Bring Forward
	sleep, 300
	send, {altdown}{altup}
	sleep, 300
	send, hgr
	Return
$!3::							;Bring Backward
	sleep, 300
	send, {altdown}{altup}
	sleep, 300
	send, hgk
	Return
!space::
	SendInput, {Delete}
	Return
$!d::
	send, +{f10}
	send, {up}{up}{enter}
	Return
$!c::
	sendinput, {ctrldown}{shiftdown}c{ctrlup}{shiftup}		;format painter		
	Return
$!v::				;format painter	
	sendinput, {ctrldown}{shiftdown}v{ctrlup}{shiftup}
	Return
!+v::
    Clip0 = %ClipBoardAll%
    ClipBoard = %ClipBoard% ; Convert to plain text
    Send ^v
    Sleep 1000
    ClipBoard = %Clip0%
    VarSetCapacity(Clip0, 0) ; Free memory
    Return
^+::												;Open/hide note
	send, ^+h 	
	Return
^n::
	send, ^m 
	return 
!r::
	send, ^d 
	return
+space::
	send, +{f5}
	Return
#space::
	send, {f5}
	return
^!z::
	send, ^[
	Return
^!a::
	send, ^]
	Return
^w::
	send, ^w
	Return
^d::								;Design Ideas
	send, !gd
	return
^s::^s 
^1::
	send, !h 
	sleep, 200
	send, {Space}
	Return
^2::
	send, !n 
	sleep, 200
	send, {Space}
	Return
^3::
	send, {alt down}{alt up}
	send, a
	sleep, 200
	send, {Space}
	Return
^4::
	send, {alt down}{alt up}
	send, k 
	sleep, 200
	send, {space}
	Return
^5::
	send, {alt down}{alt up}
	send, s 
	sleep, 200
	send, {space}
	Return
^6::
	send, !g
	sleep, 200
	send, {space}
	Return
!`::															;Shape Format or Picture Format
	SetMouseDelay, 0
	CoordMode, mouse, screen 
	click, 1295, 56 
	Return
!e::
	sleep, 200
	send, {alt down}{alt up}
	send, z
	send, {Space}
	Return
!a::											;Insert Shape
	CoordMode, mouse, screen 
	mousegetpos, xpos, ypos
	send, {alt down}{alt up}
	sleep, 300
	send, n
	send, sh
	sleep, 400
	click, 265, 146
	sleep, 200
	click, %xpos%, %ypos%
	return 
$^+f::
	CoordMode, mouse, screen 
	sleep, 300
	send, {altdown}{altup}   
	sleep, 200
	send, w 
	sleep, 200
	send, m 
	click, 624, 124
	sleep, 500
	click, 682, 281
	return
^m::										;???
	send, ^b
	Return
#IfWinActive ahk_exe WINWORD.EXE                    ;Word Area
!d::
	send, {alt down}{alt up}
	sleep, 300
	send, 1p
	sleep, 300
	send, {enter}
	Return
^d::
	mousegetpos, xpos, ypos
	click, 523, 146
	click, %xpos%, %ypos%
	return
!c::
	send, ^+c 		;format painter		
	Return
!v::				;format painter	
	send, ^+v
	Return
^+v::
    Clip0 = %ClipBoardAll%
    ClipBoard = %ClipBoard% ; Convert to plain text
    Send ^v
    Sleep 1000
    ClipBoard = %Clip0%
    VarSetCapacity(Clip0, 0) ; Free memory
    Return
!a::
	send, ^[
	Return
	send, ^]
	Return
^w::
	send, ^w
	Return
^s::^s 
^tab::^q 
^q::^tab 
#IfWinActive ahk_exe sublime_text.exe     ;Sublime Text st3area
::ccc::Capslock &
^s::
	send, ^s
	SetFormat, float, 2.0
	ToolTip, Script Reloaded, 985, 551
	SetTimer, RemoveToolTip, -700
	Return
	RemoveToolTip:
	ToolTip
	Reload
	Return
^+s::
	send, ^s
	Return
^w::
	send, ^w
	Return
#IfWinActive, ahk_exe explorer.exe 					; Exparea
!F1::
	KeyWait, LAlt, L
	clipboard := ""
	send, ^c
	ClipWait
	clipboard := clipboard
	run, "C:\Program Files\Sublime Text\sublime_text.exe" "%clipboard%"
	return
!v::
	Clipboard =
	Send ^c
	ClipWait, 1
	Run, "C:\Program Files (x86)\Vector Magic\vmde.exe" `"%clipboard%`"
	return 
^+c::
	Clipboard =
	Send, ^c
	ClipWait, 1 
	Clipboard = %Clipboard%
	return 
!enter::
	send, !{enter}
	return
#b::
	oldClip := Clipboard
	Send, ^c
	Run, % "Explorer.exe /select,""" Clipboard """"
	Clipboard := oldClip
	return 	
^!c:: 
	IfWinExist, ahk_exe Lossless Audio Checker.exe
	{
		WinActivate, ahk_exe Lossless Audio Checker.exe
		return 
	}
	else 
	{
		run, C:\Users\zlegi\Desktop\Lossless Audio Checker.exe
  		WinActivate, ahk_exe Lossless Audio Checker.exe
		return
	}
^v::	
	WinActivate, A
	send, ^v
	return
!space::
	send, {delete}
	return
!r::													;Empty Recycle Bin
	FileRecycleEmpty, C:\
	return
#f::													;Extract Files 
	BlockInput, On 
	sleep, 700
	send, {shift down}{f10}{shift up}
	send, w
	sleep, 500
	send, a
	sleep, 500
	send, {Enter}
	send, {F5}
	BlockInput, Off 
	Return
$!e::												;Extract here
	keywait, LAlt, L
	send, +{F10}
	sleep, 100
	send, e
	Return
+WheelDown::
	send, WheelRight
	Return
+WheelUp::
	send, WheelLeft
	Return
!h:: 
	keywait, LALt, L
    RegRead, ValorHidden, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden 
    if ValorHidden = 2 
      RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1 
    else 
      RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2 
    WinActivate, ahk_class ExploreWClass
    Send, !xo
    Sleep, 300
    Send, ^{TAB}
    Sleep, 300
    ControlClick, Button17, ahk_class #32770
    Sleep, 300
    Send, {F5}
return
^!+v::
    Clip0 = %ClipBoardAll%
    ClipBoard = %ClipBoard% ; Convert to plain text
    Send ^v
    Sleep 1000
    ClipBoard = %Clip0%
    VarSetCapacity(Clip0, 0) ; Free memory
    Return
^b::
	send, +{f10}
	send, b
	Return
;!x::
;	background_file := "C:\Users\Cong Hao\Desktop\Images\Background\Screenshot (101).png"
;   DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, background_file, UInt, 2) 
; 	return        
#IfWinActive, ahk_exe foobar2000.exe
^s::^s
^l::
	send, {alt down}v{alt up}
	send, l
	Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 						AutoHotkey Center Area
#IfWinActive
>!m::
	Suspend
	send, {alt up}
	Return
>!h::
	Pause
	send, {alt up}	
	Return
Capslock & Rbutton::
*$>!l::	
	KeyWait, LAlt, L
	run, C:\Users\windown10\Desktop\0. HX Upload\Release All Keys.ahk
	reload
	Return
^esc::																	 ; Mở Spy nè
	IfWinExist, ahk_exe AutoHotkeyU32_UIA.exe
	{
		WinActivate, ahk_exe AutoHotkeyU32_UIA.exe
		return 
	}
	else 
	{
		run, "C:\Program Files\AutoHotkey\WindowSpy.ahk"           
		WinActivate, ahk_exe AutoHotkeyU32_UIA.exe
		WinSet, AlwaysOnTop, On
		return
	}
#0:: 								 ; Lấy title này
	clipboard=%title%
	WinGetTitle, Title, A 
	Return
#y::        						 ;Mouse Gesture Position 
	CoordMode, mouse, screen 
	MouseGetPos, xpos, ypos
	Clipboard= %xpos%, %ypos% 
	Return 
pause::													;Wifi 
	CoordMode, Mouse, Screen
	sleep, 200
	click, 1699, 1060
	sleep, 300
	click, 1718, 371
	sleep, 500
	click, 1807, 477
	Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;					GCarea
#IfWinActive Google Chrome ahk_exe chrome.exe 
$^s::
	send, ^w
	return
$^+z:: 
	send, ^y 
	return 
$!r::
	keywait, LAlt, L
	send, {F5}
	return
$!e::
	keywait, LAlt, L
	Clipboard := ""
	send, ^+j
	ClipWait
	array := StrSplit(clipboard, "/", " `t")
	clipboard := array[1] . "/" . array[2] . "/" . array[3]
	send, !d
	sleep, 200
	send, ^v
	sleep, 300
	send, {enter}
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;					centarea
#IfWinActive ahk_exe chrome.exe
:*:ccc::contact
:*:#1::
	Fileread, content, C:\Users\Administrator\Desktop\New folder\product\testscr1.txt
	clipboard = %content%
	clipwait
	send, ^v
	send, {backspace}
	send, {tab}
	return
:*:list1::
	clipboard := "-wish -desertcart -weincense -daraz -.vn -etsy -ebay -amazon -tripadvisor -news -stock -pinterest -walmart -aliexpress -shopee -yelp -tiki -lazada -airbnb -ubuy -Flipkart.com -indiamart -dial4trade -carrefour -phool -oriental -sensia -meesho -youtube -jiomart -justdial -twitter -linked"
	send, ^v	
	return
$!w::
	KeyWait, LAlt, L
	send, ^c
	clipwait
	send, !+w
	sleep, 1000
	send, ^v 
	send, {enter}
	return
!esc::
	KeyWait, alt
	send, !+u
	return
>!k::
	KeyWait, RAlt, L
	send, +{esc}
	WinWaitActive, Task Manager ahk_exe chrome.exe
	sleep, 300
	send, +{tab}
	sleep, 200
	send, {enter}
	WinClose, Task Manager ahk_exe chrome.exe
	sleep, 300
	send, !b
	send, !q
	return
$>!j::
	KeyWait, RCtrl, L
	send, +{esc}
	WinWaitActive, Task Manager ahk_exe chrome.exe
	sleep, 300
	send, +{tab}
	sleep, 200
	send, {enter}
	WinClose, Task Manager ahk_exe chrome.exe
	sleep, 300
	send, !q
	return
^Capslock::
	send, {Mbutton}
	return 
!t::
	send, ^t 
	return 
>^'::												;And quotes to keyword
	send, ^a 
	send, ^c
	ClipWait, 1
	send, `"%clipboard%"
	send, {enter}
	return 
#3::
	send, !+1
	return
#4::
	send, !+2
	return
#5::
	send, !+3
	return
!+q::
	send, ^c
	ClipWait, 1
	send, !w
	sleep, 800
	send, ^v
	send, {enter}
	Return
!F5::
	send, ^+r 
	sleep, 1000
	click, 673, 917
	send, {alt down}x{Alt Up}
	return 
!+space::
	send, ^+y
	Return
;#space
>^\::
	click, 448,26
	Return
#IfWinActive Bookmarks - ahk_exe chrome.exe              ;Bookmark Center 
^r::
	send, ^l
	sleep, 300
	send ^c 
	ClipWait, 1
	send, ^b 
	send, ^v 
	send {enter}
	sleep, 1000
	click, 936, 603
	send, ^!x
	return
!e::
	BlockInput, MouseMove
	send, !d
	sleep, 200
	send, chrome://bookmarks/?id=8200
	send, {enter}
	sleep, 1000
	click, 678, 879
	send, !x
	BlockInput, MouseMoveOff
	Return
#IfWinActive Facebook - Cent Browser
!v::
	send, {esc}
	send, /{tab}{tab}{tab}{tab}{tab}{tab}{enter}
	CoordMode, mouse, Screen
	click, 1056, 248, 0
	Return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#IfWinActive                                              ;GUI Center 
>^+p::
	Gui, new
	Gui, guiname:new 
	Gui, Color, 28C6D6 
	Gui, font, s20, Verdana
	Gui, add, Text,, Please enter your name
	gui, add, edit
	;gui, menu, mymenubar
	Gui, Show
	sleep, 3000
	gui, submit
	Return
>!o::
	gui, new ,,To Do List
	gui, add, Text,,Hi Hao! Please enter what you have to do 
	gui, add, edit,r9 vmyedit w200
	FileRead, FileContents, C:\Users\Cong Hao\Desktop\New Text Document.txt
	GuiControl,, MyEdit, %FileContents%
	gui, show ,w250 h200 center
	sleep, 6000
	FileDelete, C:\Users\Cong Hao\Desktop\New Text Document.txt
	FileAppend, %myedit%, C:\Users\Cong Hao\Desktop\New Text Document.txt
	gui, submit 
	Return
^!0::
	gui, new,, Google
	Gui, Font, underline
	Gui, Add, Text, cBlue ggg, Click here to launch Google.
	; Alternatively, Link controls can be used:
	Gui, Add, Link,, Click <a href="www.google.com">here</a> to launch Google.
	Gui, Add, Link,, This is a <a href="https://autohotkey.com">link</a>
	Gui, Font, norm
	Gui, Show, w250 h200 center
	Gui, Add, Text,, &First Name:
	Gui, Add, Edit
	return
	gg:
	Run www.google.com
	return	
>!-::
InputBox, password, Enter Password, (your input will be hidden), hide 
InputBox, UserInput, Phone Number, Please enter a phone number., , 640, 480
if ErrorLevel
    MsgBox, CANCEL was pressed.
else
    MsgBox, You entered "%UserInput%"
    return
#IfWinActive                                  ;Script Center
+\::
	Clipboard=\
	send, ^v 
	Return
\::																				;Open UniBox
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	InputBox, scr, Universal Box, Please enter script code,,220,140,,,,10
	if errorlevel 
		{
			WinClose, Control Center
			return
		}
	if (scr="1")																;Open Cent Browser 
		{	
			If WinExist("ahk_exe chrome.exe")
			WinActivate, ahk_exe chrome.exe
			else run, "C:\Users\zlegi\AppData\Local\CentBrowser\Application\chrome.exe"
		}
	else if (InStr(scr, "ca") = "1") 
	{
		scr := RegExReplace(scr, "^ca")
		run, https://dictionary.cambridge.org/dictionary/english/%scr%
	}
	else if (InStr(scr, "ew") = "1") 
	{
		scr := RegExReplace(scr, "^ew")
		run, https://en.wiktionary.org/w/index.php?search=%scr%
	}
	else if (InStr(scr, "ww") = "1") 
	{
		scr := RegExReplace(scr, "^ww")
		run, https://en.wikipedia.org/w/index.php?search=%scr%
	}	
	else if (InStr(scr, "ins") = "1")
	{
		scr := RegExReplace(scr, "^ins")
		run, https://www.instagram.com/%scr%
	}	
	else if (scr = "yt")
	{
		run, https://www.youtube.com/
	}
	else if (InStr(scr, "yt") = "1")
	{
		scr := RegExReplace(scr, "^yt")
		run, https://www.youtube.com/results?search_query=%scr%
	}
	else if (InStr(scr, "gg") = "1")
	{
		scr := RegExReplace(scr, "^gg")
		run, www.google.com/search?q=%scr%
	}
	else if (scr="app")
		{
			run, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\
		}
	else if (scr="n")
		{
			run, C:\Users\Administrator\Desktop\New folder
		}
	else if (scr="u")
		{
			run, https://www.icloud.com/photos/
		}
	else if (scr="cop")
		{
			WinActivate, ahk_exe chrome.exe
			send, ^b
			WinWaitActive, New Tab - ahk_exe chrome.exe
			sendinput, % "chrome://extensions/?id=aefehdhdciieocakfobpaaolhipkcpgc"
			sleep, 300
			send, {enter}
			WinWaitActive, Extensions - Simple Allow Copy
			sleep, 300
			click, 943, 265
			sleep, 300
			send, ^s
			sleep, 300
			send, !r
		}
	else if (scr="i")
		{
			run, https://www.icloud.com/photos/
		}
	else if (scr="ul")
	{
		WinActivate, ahk_exe EXCEL.EXE
		sleep, 500
		send, ^s
		sleep, 600
		run, https://drive.google.com/drive/u/2/folders/1GGj_--P8uoNrHgpYGer535EiVU2w7qZo
		WinWait, 0. HX Upload - Google Drive - Google Chrome
		sleep, 1000
		run, C:\Users\Administrator\Desktop\New folder
		WinWaitActive, New folder ahk_exe Explorer.EXE
		WinRestore, New folder ahk_exe Explorer.EXE
		sleep, 100
		WinMove, New folder ahk_exe Explorer.EXE,, 588, 191, 617, 626
		sleep, 300
		click, 804, 337
		send, {Shift Down}
		click, 818, 382
		send, {Shift Up}
		sleep, 1000
		setdefaultmousespeed, 30
		sendevent, {click left 818 382 down}
		sendevent, {click left 390 203 up}
		sleep, 1000
		click, 794, 644
		WinClose, New folder ahk_exe Explorer.EXE
		return
	}
	else if (scr="bnn")
	{
		URl_original := "https://drive.google.com/file/d/10K_O-8QAgkT3kfFRQn6TkzwNxZ5cNuwQ/view?usp=sharing"
		ID := RegExReplace(URL_original, "/d/|/view", "©")
		array := StrSplit(ID, "©")
		URL_modified := "https://drive.google.com/uc?export=download&id=" . array[2] 
		UrlDownloadToFile, % URL_modified, C:\Users\Administrator\Desktop\Banana's Script.ahk
		Msgbox,,, done!, 0.6
	}
	else if (scr="up1")
		{
			run, https://www.upwork.com/nx/jobs/search/?ontology_skill_uid=1031626759027015680&sort=recency/
		}
	else if (scr="pp")
		{
			run, C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE
		}
	else if (scr="p1")										;Open Plan 1
	{
		run, C:\Users\windown10\Desktop\0. HX Upload\0. P1CH(HX).pptx,, 2
	}	
	else if (scr="ass")
		{
			run, C:\Windows\System32\SystemPropertiesAdvanced.exe
			WinWaitActive, ahk_exe SystemPropertiesAdvanced.exe
			click, 258, 464, 0
			sleep, 50
			send, s
		}	
	else if (scr="mes")
		{
			run, https://www.facebook.com/messages/t/
		}	
	else if (scr="ali")
		{
			run, https://us-productposting.alibaba.com/product/manage_products.htm?spm=a2700.siteadmin-custom.0.0.40ea6c9fvooCOR#/product/approved/1-10/ydtState=&groupId=&boutiqueTag=-1&ownerMemberId=&gmtModifiedFrom=&gmtModifiedTo=&bkGmtModified=&gmtCreatedFrom=&gmtCreatedTo=&bkGmtCreate=&categoryId=&displayStatus=all&isToAddSpecific=&ydtSearchKey=&isWindowProduct=false&isGoods=false&isPrivate=false&isVideo=false&uiAdvanceSearch=false&isSpecific=false&gmtModified=desc&subject=incense&size=10&productId=&noFreightCost=&tradeType=&detailType=&powerScoreLayer=-1&isManualEdit=&isCountry=&isOriginal=all&dropShipping=
		}	
	else if (scr="sl")
	{	
		run, C:\Users\Administrator\Desktop\New folder\old letters\0. Sales Letter.docx
	}
	else if (scr="p1")
		{
			run, C:\Users\windown10\Desktop\0. HX Upload\HXUpload\0. P1.pptx
			WinWaitActive, P1 - PowerPoint
			WinGet, WinStatus, MinMax, P1 - PowerPoint
			if (WinStatus != 0)
			WinRestore, P1 - PowerPoint
			CoordMode, Mouse, Screen 
			WinMove, P1 - PowerPoint,, -10, -2, 1361, 1039
		}
	else if (scr="p2")
		{
			run, C:\Users\windown10\Desktop\0. HX Upload\HXUpload\0. P1 old.pptx
			WinWaitActive, P1 - PowerPoint
			WinGet, WinStatus, MinMax, P1 - PowerPoint
			if (WinStatus != 0)
			WinRestore, P1 - PowerPoint
			CoordMode, Mouse, Screen 
			WinMove, P1 - PowerPoint,, -10, -2, 1361, 1039
		}
	else if (scr="aot")
		{
			run, https://www.bilibili.tv/en/play/1042594/11132148?bstar_from=bstar-web.pgc-video-detail.episode.0
		}
	else if (scr="s")
		{
			run, C:\Users\Administrator\Desktop\New folder\old letters\0. Sales Letter.docx
			clipboard := "C:\Users\Administrator\Desktop\New folder\old letters\0. Sales Letter.docx"
			Msgbox,,, Done!, 0.7
		}
	else if (scr="ah")
		{
			run, https://www.youtube.com/c/AndrewHubermanLab/videos	
		}		
	else if (scr="uni")
		{
			run, https://unicode.scarfboy.com		
		}
	else if (scr="r")
		{
			run, C:\0. Downloaded Programs\OpenSaveFilesView.exe
		}
	else if (scr="w")
	{
		run, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Office\Microsoft Word 2010.lnk
	}
	else if (scr="x")
	{
		run, C:\Users\windown10\Desktop\0. HX Upload\HXUpload\Excel File.xlsm,, Max
		WinWait, ahk_exe EXCEL.EXE
		WinActivate, ahk_exe EXCEL.EXE
		WinWait, Microsoft Excel ahk_exe EXCEL.EXE,, 3
		sleep, 200
		ControlClick, Button1, ahk_exe EXCEL.EXE,,, 2
	}	
	else if (scr="x1")
	{
		run, C:\Users\Administrator\Desktop\New folder\product\Bảng tính giá.xlsx,, Max
	}	
	else if (scr="g")
	{
		run, C:\Users\zlegi\Videos\Captures
	}
	else if (scr="act")
	{
		run, https://www.facebook.com/100007585009451/allactivity/?activity_history=false&category_key=MANAGEINTERACTIONS&manage_mode=true&should_load_landing_page=false

	}
	else if (scr="ico")
		{
			run, C:\0. Downloaded Programs\0. Images\icons
		}
	else if (scr="df")
		{
			run, C:\0. Downloaded Programs\DefenderControl.lnk
		}
	else if (scr="scr1")
		{
			run, "C:\Windows\system32\notepad.exe" "C:\Users\Administrator\Desktop\New folder\testscr1.txt"
		}
	else if (scr="m1")
		{
			run, https://mail.google.com/mail/u/0
		}
	else if (scr="d3")
		{
			run, https://drive.google.com/drive/u/2/folders/1GGj_--P8uoNrHgpYGer535EiVU2w7qZo
		}
	else if (scr="d2")
		{
			run, https://drive.google.com/drive/u/1/
		}
	else if (scr="d1")
		{
			run, https://drive.google.com/drive/u/0/
		}
	else if (scr="g1")
		{
			run, https://mail.google.com/mail/u/0/#inbox
		}
	else if (scr="g2")
		{
			run, https://mail.google.com/mail/u/1/#inbox
		}
	else if (scr="g3")
		{
			run, https://mail.google.com/mail/u/2/#inbox
		}
	else if (scr="dp")
		{
			run, C:\0. Downloaded Programs
			WinActivate, 0.Downloaded Programs
			WinMaximize, A 
		}
	else if (scr="vid")
		{
			run, C:\0. Downloaded Programs\Videos
			WinWaitActive,
			WinMaximize, A 
		}
	else if (scr="rt")
		{
			run, C:\0. Downloaded Programs\Restart.lnk
		}
	else if (scr="sd")
		{	
			WinClose, ahk_exe anki.exe 
			WinWaitClose, ahk_exe anki.exe,, 8
			sleep, 3000
			run, C:\Users\Administrator\Desktop\New folder\shutdown.exe.lnk
		}
	else if (scr="sl")
		{
			run, C:\Users\Administrator\Desktop\New folder\sleep.exe.lnk
		}
	else if (scr="exp")
		{
			run, C:\Users\Administrator\Desktop\New folder\Rexplorer.exe
		}
	else if (scr="32")
		{
			run, C:\Windows\System32
			WinMaximize, A 
		}
	else if (scr="2")
		{
			run, C:\Users\Cong Hao\Desktop\AHK Storage\AutoHotkey_L-Docs-master\docs\AutoHotkey.htm
		}
	else if (scr="3")
		{
			run, https://translate.google.com/
		}
	else if (scr="4")
		{
			 run, https://www.facebook.com/groups/Toeictuhoc/?fref=nf
		}
	else if (scr="0")
		{
			inputbox, text, Google Translate Script, Please enter text here,,250, 130
			if ErrorLevel
				WinClose, google translate script
			else 
				run, https://translate.google.com/?source=osdd#view=home&op=translate&sl=en&tl=vi&text=%text%
		}
	else if (scr="mot")															;Open Max OT
		{
			run C:\ARCHANGEL\1.Learning\Sách chuyên ngành\4.Đời sống - Thường thức\1.Thể thao - Thể dục\2.Thể hình\Max OT\Tập thể hình theo phương pháp Max-OT.pdf
		}
	else if (scr="ss")															;Open Screenshots 
		{
			run C:\Users\Cong Hao\Pictures\Screenshots
			sleep, 700
			send, !x
		}
	else if (scr="bk")												;Block Keyboard
	{
		run, "C:\0. Downloaded Programs\0. AHK Directory\BlockKeyboardOnly.ahk"
	}
	else if (scr="bm")												;Block Mouse
	{
		Loop
		{
			If GetKeyState("Escape","P") 
			{
				BlockInput, MouseMoveOff
				Break
			}
			else if (A_TimeIdlePhysical<500)
			{
				BlockInput, MouseMove
			}
		}
	}
	else if (scr="ba")												;Block All Inputs
	{
		Loop
		{
			If GetKeyState("Escape","P") 
			{
				BlockInput Off
				Break
			}
			else if (A_TimeIdlePhysical<500)
			{
				BlockInput On
			}
		}
	}
	else if (scr="bg")
		{
			run, C:\Users\Cong Hao\Desktop\Images\Background
		}
	else if (scr="yt")															;Open Youtube Sub 
		{
			run https://www.youtube.com/feed/subscriptions
		}
	else if (scr="fb")															;Open Facebook
		{
			run, https://www.facebook.com
		}	
	else if (scr="fm")															;Open Brain.fm
		{
			run, https://brain.fm/app/player 
		}
	else if (scr="px")
		{
			MouseGetPos, x, y
			PixelGetColor, pixel, %x%, %y%, RGB
			clipboard := pixel
			MsgBox,,, %pixel%, 1
		}	
	else if (scr="sc")
		{
		 	winactivate, ahk_exe chrome.exe
		 	send, ^b 
		 	winwaitactive, New Tab - ahk_exe chrome.exe
		 	send, % "chrome://settings/cbManageShortcuts"
		 	sleep, 300
		 	send, {enter}
		 	winwaitactive, Manage shortcut keys - Cent Browser
		 	sleep, 300
		 	send, ^+g		 	
		}
	else if (scr="m")															;Open Messages 
	 	{
	 		WinActivate, ahk_exe chrome.exe 
	 		run, https://www.facebook.com/messages/t/
	 	}
	else if (scr="love")														;Open Love-Sex
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=60900
			send, {enter}
			sleep, 800
			click, 679, 933
			send, !x
		}
	else if (scr="bvm")															;Open Bai viet moi
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=5754
			send, {enter}
			sleep, 800	
			click, 679, 933
			send, !x
		}
	else if (scr="bvm")															;Open Bai viet moi
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=87547
			send, {enter}
			sleep, 800	
			click, 679, 933
			send, !x
		}
	else if (scr="sing")														;Open Singing
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=71729
			send, {enter}
			sleep, 800
			click, 660, 614
		}	
	else if (scr="ytc")														;Open Youtube Channels
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=12393
			send, {enter}
			sleep, 800
			click, 660, 614
		}	
	else if (scr="autohotkey")													;Open Autohotkey
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=68295
			send, {enter}
			sleep, 800
			click, 660, 614
		}
	else if (scr="cn")															;Open Chinese
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=71184
			send, {enter}
			sleep, 800
			click, 660, 614			
		}
	else if (scr="ex")															;Open Excel
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=69794
			send, {enter}
			sleep, 800
			click, 660, 614	
			send, !x		
		}
	else if (scr="tgk")															;Open Thi giua ki 
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=85305		
			send, {enter}
			sleep, 800
			click, 660, 614			
		}
	else if (scr="dk")														    
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=86182
			send, {enter}
			sleep, 800
			click, 660, 614			
		}
	else if (scr="av")															;Open TOEIC
		{
			WinActivate, ahk_exe chrome.exe
			sleep, 300
			send, ^b
			send, chrome://bookmarks/?id=85901
			send, {enter}
			sleep, 800
			click, 660, 614	
			send, !x		
		}
	else if (scr="idm")															;Turn On/Off IDM Extension 
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b 
			send, chrome://extensions/?id=ngpampappnmepgilojfohadhhmbhlaek
			send, {enter}
			sleep, 1600
			click, 1342, 370
			sleep, 300
			send, ^w
		}
	else if (scr="vdh")															;Turn On/Off Video DownloadHelper
		{
		    WinActivate, ahk_exe chrome.exe 
			send, ^b 
			send, chrome://extensions/?id=lmjnegcaeklhafolokijcfjliaokphfk
			send, {enter}
			sleep, 2200
			click, 1342, 370
			sleep, 300	
			send, ^w
		}
	else if (scr="joy")															;Turn On/Off eJoy
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b 
			send, chrome://extensions/?id=amfojhdiedpdnlijjbhjnhokbnohfdfb
			send, {enter}
			sleep, 1000
			click, 1342, 370
			sleep, 300
			send, ^w
		}
	else if (scr="zoom")														;Turn On/Off Hover Zoom Extension
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b 
			send, chrome://extensions/?id=pccckmaobkjjboncdfnnofkonhgpceea
			send, {enter}
			sleep, 1000
			click, 1342, 370
			sleep, 300
			send, ^w
		}
	else if (scr="2c")															;Turn On/Off Two Captions Extension
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b 
			send, chrome://extensions/?id=lpeonmjfimoijceaalocpgjjchocbiap	
			send, {enter}
			sleep, 1000
			click, 1342, 370
			sleep, 300
			send, ^w
		}	
	else if (scr="gs")															;Turn On/Off Gray Scale Extension
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b 
			send, chrome://extensions/?id=mblmpdpfppogibmoobibfannckeeleag
			send, {enter}
			sleep, 1000
			click, 1342, 370
			sleep, 300
			send, ^w
		}
	else if (scr="cn1")														;Open Tsinghua Chinese 
		{
			run, https://courses.edx.org/courses/course-v1:TsinghuaX+TM01x+1T2019/course/
		}
	else if (scr="desktop")													;Copy desktop's address to clipboard
		{
			clipboard=C:\Users\Cong Hao\Desktop
		}
	else if (scr="4")
		{
			if winexist("ahk_exe ONENOTE.EXE")
			WinActivate, ahk_exe ONENOTE.EXE
			Else
			run, C:\Users\Cong Hao\Desktop\OneNote 2016.lnk
		}
	else if (scr="elf")														;Open Excel Learning File
		{
			run, C:\Users\Cong Hao\Desktop\Learning Files\ELF.xlsx
		}
	else if (scr="e1")														;Open English 1
	 	{
	 		WinActivate, ahk_exe POWERPNT.EXE
	 		run, C:\Users\Cong Hao\Desktop\Learning Files\English 1.pptx
	 	}
	else if (scr="e2")														;Open English 2
		{
			WinActivate, ahk_exe POWERPNT.EXE
			run, C:\Users\Cong Hao\Desktop\Learning Files\English 2.docx
		}
 	else if (scr="e3")														;Open English Storage 1
		{
			WinActivate, ahk_exe POWERPNT.EXE
			run, C:\Users\Cong Hao\Desktop\Learning Files\English Storage 1.pptx
		}
	else if (scr="e4")														;Open English Storage 2
		{
			WinActivate, ahk_exe POWERPNT.EXE
			run, C:\Users\Cong Hao\Desktop\Learning Files\English Storage 2.pptx
		}
	else if (scr="g1")														;Open Gym Note
		{	
			WinActivate, ahk_exe POWERPNT.EXE
			run, C:\Users\Cong Hao\Desktop\Learning Files\Gym Note.pptx		
		}
	else if (scr="p1")														;Open Plan 1
		{
			WinActivate, ahk_exe POWERPNT.EXE
			run, C:\Users\Cong Hao\Desktop\Learning Files\Plan 1.pptx
		}	
	else if (scr="plf")														;Open Powerpoint Learning File
		{
			WinActivate, ahk_exe POWERPNT.EXE
			run, C:\Users\Cong Hao\Desktop\Learning Files\Powerpoint Learning File.pptx
		}
	else if (scr="w1")														;Open Word Note
		{
			run, C:\Users\Cong Hao\Desktop\Learning Files\Word Note.docx
		}
	else if (scr="'")														;Open Learning Center
		{
			run, C:\Users\Cong Hao\Desktop\Learning Files\Learning Center.pptx
		}
	else if (scr="[")
		{
			run, C:\Users\Cong Hao\Desktop\Learning Files\Academic.pptx
		}
	else if (scr="tdt")
		{
			run, https://www.facebook.com/groups/k22.tdtu/
		}
 	else if (scr="cnlf")													;Open Chinese Learning File
 		{
 			run, C:\Users\Cong Hao\Desktop\Language\Tiếng Trung\Chinese Learning File.docx
 		}	
 	else if (scr="mp3")
 		{	
 			run, https://y2mate.com/vi/youtube-to-mp3
 			sleep, 2000
 			winwait, Tải nhạc MP3 từ YouTube - Cent Browser,,1
 			click, 662, 409
 			send, ^v
 			sleep, 700
 			click, 1076, 620
 			sleep, 1000
 			click, 949, 280
  			send, {esc}
 			sleep, 1000
 			send, ^{w 2}
 			return
 		}
 	else if (scr="book1")
 	  	{
 	  		run, C:\ARCHANGEL\1.Learning\Sách chuyên ngành\2.Văn học\2.Trinh Thám - Hình sự\3.Tiểu thuyết của Dan Brown\Bộ Robert Langdon\1.Thiên thân và ác quỷ\Thien Than Va Ac Quy - Dan Brown.epub
 	  		sleep, 1000
 	  		send, #{up}
 	  		sleep, 500
 	  		send, {alt down}{alt up}
 	  		sleep, 400
 	  		send, v
 	  		sleep,400
 	  		send, d{down}{enter}
 	  		Return
 	  	}
	else if scr between 0 and 100
		{
			soundset, %scr%
		}
	else if (scr="]")														;Open Free Alarm Clock 
		{
			run, C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Free Alarm Clock.lnk
			WinWait, ahk_exe FreeAlarmClock.exe
			sleep, 400
			send, ^n
		}
	else if (scr="fb2")
		{
			sleep, 500
			WinActivate, ahk_exe chrome.exe 
			send, ^g
			sleep, 400
			send, fb.com
			send, {enter}
			sleep, 5000
			send, zyurimasterz@gmail.com
			sleep, 300
			send, {down}
			send, {enter 2}
		    Return
		}
 	else if (scr="f12")
 		{
 			clipboard= document.body.contentEditable = true
 		}
 	else if (scr="gr")
 		{
 			run, https://app.grammarly.com/ddocs/493628191
 		}
	else if (scr="tk")														;Open thongke
		{
			WinActivate, ahk_exe chrome.exe 
			send, ^b
			send, chrome://bookmarks/?id=89285
			send, {enter}
			sleep, 800
			click, 660, 614
		}	
	else if (scr="=")
		{
			run, C:\Users\Cong Hao\Desktop\Learning Files\Math.pptx
			WinActivate, ahk_exe POWERPNT.EXE
		}
	else if (scr="gt")
		{
			run, C:\Users\Cong Hao\Desktop\thongke\XXX. Giáo Trình TK Tiếng Anh FULL.pdf 
		}
	Return

