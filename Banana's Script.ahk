if !A_IsAdmin
	; Run *RunAs "C:\Program Files\AutoHotkey\AutoHotkeyU64_UIA.exe" "%A_ScriptFullPath%"   
	Run *RunAs "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe" "%A_ScriptFullPath%"   
;UIA doesn't work reliably, this work even open script manually
#NoEnv                    ;\!!recommended for all scripts, disable enviroment variables
#MaxMem 256               ;futile, default is 64, intended to avoid bug only, but does affect WinGetText and ControlGetText
#KeyHistory 50            ;default=40
#WinActivateForce
#SingleInstance Force
#MenuMaskKey vkE8
#Warn ClassOverwrite        
if !thisConfigThread {
    SendMode, Input 					;Fallback to event if SendInput unavailable
    SetKeyDelay, -1, -1			            ;in case fallback to sendEvent
    SetMouseDelay, -1                       ;reconfigure when use sendEvent if needed
    SetDefaultMouseSpeed, 0                 ;in case fallback to sendEvent
    SetTitleMatchMode, 2
    Process, Priority,, H		;A=Above normal, H=High, https://www.autohotkey.com/boards/viewtopic.php?t=6413
    SetBatchLines, -1           ;Most important factor to speed, default=10ms, this could cause loop use more CPU, this can be offset by using sleep, which is recommended anyways    ;;optimization thread aboves
                                ;Also fix playsound delay
    SetWorkingDir %A_ScriptDir% 	; Ensures a consistent starting directory.
    SetCapslockState, AlwaysOff	
    SetNumLockState, AlwaysOn
    Coordmode, Mouse, Screen
    Coordmode, ToolTip, Screenimage.png
    CoordMode, Pixel, Screen
    CoordMode, Menu, Screen
    CoordMode, Caret, Screen#include <BrightnessSetter>
    #include <Gdip_All>
    #include <WinSysMenuAPI>
    #include <ExplorerGetPath>
    #include <urlDownloadToFile2>  
    #include <HBitmapToPng>
    #include <PNGFromclipboard>
    ; #include <Chrome.ahk_v1.2\Chrome>
    #include <Chrome.ahk_v1.2\tdChrome+LightJson>                ;teadrinker's editted version using LightParser instead of coco's slow and buggy Jxon()
    #include <UIAutomation-main\Lib\UIA_Interface>
    #include <UIAutomation-main\Lib\UIA_Constants>
    #include <UIAutomation-main\Lib\UIA_Browser>
    #include <getURL>
    #include <WinClip\WinClipAPI>       
    ;WinClipAPI above WinClip
    #include <WinClip\WinClip>
    #include <SetClipboardHTML>  
    #include <Markdown2HTML>
    #include <encodeHTML>
    #include <unHTML>
    #include <JSON>
    #include <Jxon>
    ; #include <ahkTTS>   
    #include <ggTTSArray>
    #include <ggTTS> 
    #include <myClipHistory>
    #include <dllLoadLibrary>
    #include <Eval>
}
;;; Pre-defined super-global variables/class
global centPath := "C:\Users\zlegi\AppData\Local\CentBrowser\Application\chrome.exe"
global vscPath := "C:\Users\zlegi\AppData\Local\Programs\Microsoft VS Code\Code.exe"
global nircmd := "C:\Windows\nircmd.exe"
; global brightSetter := new BrightnessSetter()
;;
if (Chromes := Chrome.FindInstances())
    global Cent := {"base": Chrome, "DebugPort": Chromes.MinIndex(), PID: Chromes[Chromes.MinIndex(), "PID"]}
else
    Msgbox,,, % "Please run Cent", 0.6
; global WinClip                ;not necessary as class names are super-global
global wc := new WinClip
global UIA := UIA_Interface()
; global uCent  ;so uCentInst() can affect uCent globally
if WinExist("ahk_exe chrome.exe")
    global uCent := new UIA_Chrome("Cent Browser ahk_exe chrome.exe")  ;must declared under UIA declaration, might contain return => accidentally end auto execute section
;if can't fetch elementss completely/find box is active, Cent will be activated
global A_Audio := "C:\0. Coding\ahkRepos\Audio"
; if !(pProcess = "chrome.exe")
; 	WinMinimize, ahk_exe chrome.exe
;;;
; soundPlay(A_Audio "LC - Let's see what you're made Up.mpeg", true, 30)
; FileRead, unit_ready, % "*c " A_Audio "Red Alert 2\Unit ready - ceva062.wav" 
; soundPlay(,,, unit_ready)
soundPlay(A_Audio "\Red Alert 2\Unit ready - ceva062.wav", true)
return ;;;;;;;;;;;;;;;;;;;;;    end auto-execute section
;;;;;;;;;;;;;;;;;;										 	testarea
` & t::
	Msgbox, % uCent.BrowserId
	return
` & 8::
	KeyWait("``")
	ppt := ComObjCreate("Powerpoint.Application")
	ppt.Visible := True
	ppt.Presentations.Open("C:\Users\zlegi\Desktop\misc.pptx")
	soundbeep
	return
` & 7::	
	KeyWait("``")
	Msgbox, % A_TitleMatchMode
	SetTitleMatchMode, regex
	if WinActive("i) Google Search ahk_exe chrome.exe")
		Msgbox, % "true!"
	return
;;
MenuHandler:
	Msgbox You selected %A_ThisMenuItem% from the menu %A_ThisMenu%.
	return
; #z::
; 	Menu, MyMenu, Add, Item1, MenuHandler
; 	Menu, MyMenu, Add, Item2, MenuHandler
; 	Menu, MyMenu, Add ; Add a separator line.
; 	Menu, Submenu1, Add, Item1, MenuHandler
; 	Menu, Submenu1, Add, Item2, MenuHandler
; 	Menu, Submenu1, Add, Item2, MenuHandler
; 	Menu, MyMenu, Add, My Submenu, :Submtextarea
; 	Menu, MyMenu, Add ; Add a separator line below the submenu.
; 	Menu, MyMenu, Add, Item3, MenuHandler ; Add another menu item beneath the submenu.
; 	Menu, MyMenu, Show ; i.e. press the Win-Z hotkey to show the menu.
; 	return
;;
; ` & ::																	;Download file
; 	InputBox, URL_original, File URL, Please enter the URL of the file,, 300, 100
; 	if ErrorLevel
; 		URL_original := "https://drive.google.com/file/d/1ToNpARX3Jycnb-lr2UFnLMzhxe79EPgP/view?usp=sharing"
; 	ID := RegExReplace(URL_original, "/d/|/view", "©")
; 	array := StrSplit(ID, "©")
; 	URL_modified := "https://drive.google.com/uc?export=download&id=" . array[2]
; 	UrlDownloadToFile, % URL_modified, C:\Users\zlegi\Desktop\text.txt
; 	Msgbox,,, done!, 0.6
; 	return
testdrag:
	run, % "https://drive.google.com/drive/u/2/folders/1GGj_--P8uoNrHgpYGer535EiVU2w7qZo"
	WinWait, 0. HX Upload - Google Drive - Google Chrome
	Sleep, 1000
	run, % "C:\Users\Administrator\Desktop\New folder"
	Sleep, 300
	WinMove, New folder ahk_exe Explorer.EXE,, 507, 216, 735, 626
	Sleep, 300
	click, 751, 365
	Send, {Shift Down}
	click, 755, 407
	Send, {Shift Up}
	Sleep, 500
	;MouseClickDrag, L, 755, 407, 361, 560, 100
	SetMouseDelay, 2000
	SendEvent {Click 755 407 Down}
	SendEvent {Click 361 560 Up}
	return
test1:
	SoundBeep,
	Loop 
	{
		PixelGetColor, color, 1438, 48
		Sleep, 300
		if (color = "0x424242") {
			Msgbox, % "found!"
			break
		} else
			continue
	}
	return
;` & 1::
	clipboard := ""
	if WinActive("ahk_exe chrome.exe")
		clipboard := getURL()
	else
		Send, ^c
	ClipWait, 1.5
	array := StrSplit(clipboard, "/", " `t")
	clipboard := array[1] . "/" . array[2] . "/" . array[3]
	;Msgbox,,, % clipboard, 0.6
	FileRead, myVar, C:\Users\zlegi\Desktop\test.txt
	if (myVar ~= clipboard) {
		Msgbox,,, this is old!, 0.5
		Send, ^s
	} else
		Msgbox,,, this is new!, 0.7
	;NumpadClear & v::
	if (keypresses > 0) { ; SetTimer already started, so we log the keypress instead.
		keypresses += 1
		return
	}
	; Otherwise, this is the first press of a new series. Set count to 1 and start
	; the timer:
	keypresses := 1
	SetTimer, KeyMulti, -800 ; Wait for more presses within a 400 millisecond window.
		return
	KeyMulti:
		if (keypresses = 1) ; The key was pressed once.
			Msgbox,,, 111, 1
		else if (keypresses = 2) ; The key was pressed twice.
			Msgbox,,, 222, 1
		else if (keypresses > 2)
			Msgbox,,, 333, 1
		; Regardless of which action above was triggered, reset the count to
		; prepare for the next series of presses:
		keypresses := 0
		return
+Numpad1::
	test_move := Func("WinMoveMsgbox").bind(title)
	SetTimer, % test_move, 50
	Msgbox, 4096, % title, % "DOS:`t" DOS "`n`nName:`t" PtName "`n`nDOB:`t" BD !
	return
;;;; fnarea 
_RangeNewEnum(r) {
	static enum := { "Next": Func("_RangeEnumNext") }
	return { base: enum, r: r, i: 0 }
}

_RangeEnumNext(enum, ByRef k, ByRef v:="") {
	stop := enum.r.stop, step := enum.r.step
	, k := enum.r.start + step*enum.i
	if (ret := step > 0 ? k < stop : k > stop)
		enum.i += 1
	return ret
}
runJS(pInput:="", method:="Cent", async = true) {
    if (pInput ~= "^[CD]:\\.+\.js") {
        if !vFile := FileOpen(pInput, "r")
            Throw, "The file does not exist!"
        pInput := vFile.Read()
    }
    if (method="Cent") {
        Page := Cent.GetPage()
        if (async = false)
            Page.Evaluate(pInput,, false)
        else
            Page.Evaluate(pInput)
        Page.Disconnect()
    } else if (method="uCent") {
        uCentInst()
        uCent.jsExec(pInput)
    }
}
hideRegion(vWin := "", regX := "", regY := "", regW := "", regH := "") {
	WinSet, Style, -0xC00000, % vWin
	DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist(vWin)
	, "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_DISABLED := 1, "uint", 4)
    ;ankiBrowse requires both to avoid side effects, testing needed for other apps
	WinSet, Region, %regX%-%regY% W%regW% H%regH%, % vWin
}
isDevTools() {
	uCentInst(true)
	if uCent.FindFirstBy("Name=DevTools && ControlType=Document")
		return true
	else
		return false
}
isTerminal() {
    vscUIA := objUIA("ahk_exe Code.exe")
	if ((vscUIA.FindByPath("1.1.7").LocalizedControlType) = "group")
	 	return true    
	else
		return false
}
vscClick(Name, controlType := "", msg := true) {
    WinActivate, ahk_exe Code.exe
	if !IsObject(vscUIA)
		vscUIA := objUIA("ahk_exe Code.exe")
	searchCriteria := "Name=" name 
	if (controlType != "")
		searchCriteria .= " && ControlType=" controlType
	if !vscUIA.FindFirstBy(searchCriteria).click() {
		if (msg=true)
			Msgbox, % "Can't find the element!"
		return ret := 0
	} else
		return ret := 1
}
countFrom(x := 1, y := "") {
	if !y
		Msgbox, % "Please define 'y'"
	while x<y 
		(A_Index=1) ? (result := x) : (result .= ", " ++x)
	Msgbox, % clipboard := result
}
unescapeStr(input, trimSpaces := false) {   ;convert \n to "`n" in 
	if (trimSpaces != false) 
		input := Trim(input, """")
	Loop 
	{
		count := 0   ;reset count after each replacement
		For char, esc in {n: "`n", r: "`r", b: "`b", t: "`t", v: "`v", a: "`a", f: "`f"}
			input := RegExReplace(input, "([^\\]|^)\K\\" char, esc, rep), count += rep ;multi-statment
		/* "([^\\]|^)\K\\" char
			([^\\]|^) ⇒ not \ OR start of line 
			\K ⇒ must match the pattern (different from "\\"), but omitted from match and replacement
			"\\" char ⇒ \n, \r, \b
			\n must precedes a chacracter other than \ or beginning of the line 
			"\\n" will not be matched because "\n" precedes \
			if needle = "\\" ⇒ above will be matched
		*/
	} Until !count	;Until there's no more replacement
	MsgBox, 64, Result, % input
	return input
}
HTMLToText(vHTML) {
	; vHTML := RegExReplace(vHTML, "`n)`n", "foobar")    ;temporary workaround because newlines don't get converted
	oHTML := ComObjCreate("HTMLFile")
	oHTML.write("<title>" vHTML "</title>")
	vText := oHTML.getElementsByTagName("title")[0].innerText
	; vText := RegExReplace(text, "foobar", "`r`n")
	return vText
}
TextToHTML(vText) {    ;encodeHTML() was also imported; Please test the difference
	oHTML := ComObjCreate("HTMLFile")
	oHTML.write("<title></title>")
	oHTML.getElementsByTagName("title")[0].value := vText
	vHTML := oHTML.getElementsByTagName("title")[0].outerHTML
	return SubStr(vHTML, 15, -10)     ;retrieve from pos15, omit last 10 characters
}
runtimeHandler(exception) {
	Sleep, 300  
	Edit
	WinWaitActive, ahk_exe Code.exe
	Send, ^g
	Sleep, 300
	Send, % exception.Line "{Enter}"
}

loadtimeHandler() {
    soundPlay(A_Audio "\Red Alert 2\Unable to comply - ceva047.wav")
	WinGet, winList, List, Banana's Script.ahk ahk_class #32770
	Loop, %winList% {
		WinGet, vStyle, Style, % "ahk_id " winList%A_Index% 
		if (vStyle = "0x94C803C5")  {				       ;Style of all MessageBox (includes error)
			titleID := "ahk_id " winList%A_Index% 
            WinGetText, controlText, % titleID
            if !vText
                vText := controlText
            else
                vTetx .= controlText
		}
	}
	errorLine := regexMatches(vText, "Error at line (\d+)\.",, 1)
	if !errorLine
		errorLine := regexMatches(vText, "--->\s+(\d+)", "text", 1)
	WinActivate, % titleID
	ControlFocus, OK, % titleID
	WinWaitClose, % titleID
    if !RegExMatch(errorLine, "\d+")
        Msgbox, % "Can't get the errorLine!"
    else {
        run, "%vscPath%" "%A_ScriptFullPath%"
        WinWait, Banana's Script.ahk ahk_exe Code.exe,, 3
        if ErrorLevel
            Throw, "Open script for edit timeout!"   ;issue with msgbox???
        WinActivate, Banana's Script.ahk ahk_exe Code.exe
        sleep, 300
        Send, ^g
        Send, % errorLine "{Enter}"
        soundPlay(A_Audio "\Red Alert 2\Select target - ceva065.wav")
        Send, {End}
	}
	return errorLine
}
EncodeDecodeURI(str, encode := true, component := true) {			;decoding ⇒ encode := false				
   static Doc, JS											
   if !Doc {
      Doc := ComObjCreate("htmlfile")
      Doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
      JS := Doc.parentWindow
      ( Doc.documentMode < 9 && JS.execScript() )
   }
   Return JS[ (encode ? "en" : "de") . "codeURI" . (component ? "Component" : "") ](str)
}
msgEnum(array, nested := false, IsCopy := false) { 			;nested object level 2 supported
	local
	global WinClip
	if !IsObject(array) {
		Msgbox, % "Can't detect the array!"
		return
	}
	if (nested=false) {
		for k, v in array
			vList .= k " : " v "`r`n"
	} else {
		for k, v in array {
			for k2, v2 in v {
				if (A_Index=1)
					pair := k2 "`t" v2        ;recommend to avoid freeing var beforehand
				else
					pair .= " : " k2 "`t" v2
			}
			if (A_Index=1)
				vList := A_Index " : " pair
			else
				vList .= "`n" A_Index " : " pair
		}
	} 
	Trim(vList, "`n")
	if (IsCopy=true)  
		WinClip.SetText(vList)
	Msgbox, % vList
}
escapeVar(input, trimSpaces := 0) {
	escapeChars := ["`,", "`%", "`;", "`::"]
	for index, value in escapeChars
		input := RegexReplace(input, value, "`" value)
	return input := RegExReplace(input, "(?<!^)""(?!$)", """""")
}
freeMem(varList) {
	loop, parse, varList, `,, %A_Space%			;delimiter '`' and omit spaces
		VarSetCapacity(%A_LoopField%, 0, 0)		;double-dereference to retrieve varName
}
runURL(pURl := "chrome-search://local-ntp/local-ntp.html", Disconnect := true, Activate := true) {       ;new tab if pURL is omitted
	if (Activate=true)
		WinActivate, ahk_exe chrome.exe
    Page := Cent.GetPage()				;Store most recent page as 'Page'
	if (winTitle(,, true) = "New Tab - Cent Browser ahk_exe chrome.exe")
		oTab := Page.Call("Page.navigate", {"url": pURL})
	else {
        oTab := Page.Call("Target.createTarget", {"url": pURL}) 
        Sleep, 100
    }
    ;Create a new tab with pURL in background, return 'oTab' object contains {"targetId" : 4B1B7AED121D8A72AA55E6B6F0699802}
    Page := Cent.GetPage()		;update Page object to contains new tab
    Page.WaitForLoad()
    if (Disconnect = true)
        Page.Disconnect()
    else
        return Page := Cent.GetPage()    			;Get new tab for continual execution
    ; msgbox, % var := oTab["targetID"]
}
regexMatches(haystack, needle, method := "text", subpattern := "") { 
	local vSubpattern
    if (needle = "") {
        Msgbox, % "Invalid needle!"
        ExitApp
    }
	if !RegexMatch(needle, "O.{0,8}\)") {	       ;options not begin with O
	    if !(needle ~= "^[^O)(\\]{1,8}\)")     ;options can't be ), (, \   
	        needle := "O)" needle
	    else 
	        needle := "O" needle
	}
    Result := [] ;new MatchCollection()
    start := 1
    loop 
    {
        if !RegexMatch(haystack, needle, M, start)  
		;call RegexMatch and break if there's no more matches
		;start is startPos, M is outputVar which is also an object with methods such as Value, Pos, Len, etc.
            break
        Result.Push(M)				;appends M to Result object
		if (subpattern != "") {
			if !vSubpattern
				vSubpattern := M.Value(subpattern)
			else
				vSubpattern .= "`r`n" M.Value(subpattern)
		}
        start := M.Pos + M.Len      ;startPos to search for next one
    }
	Length := Result.Length()
	if (subpattern != "") && (method = "array")
		return subArray := StrSplit(vSubpattern, "`n", "`r")
	else if (subpattern != "") && (method = "text") {
		return vSubpattern 
	} else if (method = "array")
		return Result
	else if (method = "text") {
		for i, matchObj in Result {
			if (A_Index=1)
				resultText := matchObj.Value
			else
				resultText .= "`r`n" matchObj.Value
		}
		return resultText
	}
}
thousandSep(number, Separator := ", ") {
	return RegExReplace(number, "\G\d+?(?=(\d{3})+(?:\D|$))", "$0" Separator)
}
; e.g thousandSep(1111, ", ") => 1, 111

;;;; winfn
isElevated(vPID) ;Process ID, e.g chrome.exe process can have zero to several windows with different hwnd
;1/0/-1: elevated/not elevated/error(probably elevated)
;e.g isElevated(8556), isElevated(12341)
{
	;PROCESS_QUERY_LIMITED_INFORMATION := 0x1000
	if !(hProc := DllCall("kernel32\OpenProcess", "UInt",0x1000, "Int",0, "UInt",vPID, "Ptr"))
		return -1
	;TOKEN_QUERY := 0x8
	hToken := 0
	if !(DllCall("advapi32\OpenProcessToken", "Ptr",hProc, "UInt",0x8, "Ptr*",hToken))
	{
		DllCall("kernel32\CloseHandle", "Ptr",hProc)
		return -1
	}
	;TokenElevation := 20
	vIsElevated := vSize := 0
	vRet := (DllCall("advapi32\GetTokenInformation", "Ptr",hToken, "Int",20, "UInt*",vIsElevated, "UInt",4, "UInt*",vSize))
	DllCall("kernel32\CloseHandle", "Ptr",hToken)
	DllCall("kernel32\CloseHandle", "Ptr",hProc)
	return vRet ? vIsElevated : -1
}
winAt(X, Y, ret := "process", fullTitle := false) { 	; by SKAN, Linear Spoon, and Banana259 													;from WindowFromPoint() native fn, 
	hwnd := DllCall( "GetAncestor", "UInt"			;can't detect hidden windows, even if active
		, DllCall( "WindowFromPoint", "UInt64", X | (Y << 32))
		, "UInt", 2 ) ; GA_ROOT
	ahkID := "ahk_id " hwnd
	if (ret= "hwnd")
		return hwnd
    if (ret = "title")
        return winTitle(ahkID, "title", fullTitle)
	if (ret = "id")
		return winTitle(ahkID, "id", fullTitle)
	if (ret = "process")
		return winTitle(ahkID,, fullTitle)
	if (ret = "class")
		return winTitle(ahkID, "class", fullTitle)
}
winCursor(winTitle) {
	MouseGetPos,,, ID
	if (winTitle = "A")
		return "ahk_id " ID
	if WinExist(winTitle " ahk_id " ID)	
		return 1
	else
		return 0
}
moveMsgbox(pTitle) {
	ID := WinExist(pTitle)
	if (ID) {
		WinMove, % "ahk_id " ID, 82, 300
		SetTimer ,, off
	}
	return
}
visibleTaskbar() {
	WinGetPos,, taskbarY,, taskbarHeight, ahk_class Shell_TrayWnd 
	if (taskbarY=(A_ScreenHeight-taskbarHeight))
		return true
}
isAppear(winTitle) {
	WinGet, minMax, MinMax, winTitle
	if WinActive(winTitle)
		return 1
	else if (minMax=0)
		return 1
	else
		return 0
}
centerWindow(WinTitle) {
	WinGetPos,,, Width, Height, %WinTitle%
	WinMove, %WinTitle%,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2)
}
winRestart(vTitle := "A", processPath := "", sleepAfter:=0) {
	local
	if (vTitle = "A")
		WinGet, processPath, ProcessPath, A
	if !processPath
		throw, "processPath undefined!"
	winID := winTitle(vTitle, "id")
	WinKill, % winID
	WinWaitClose, % winID,, 10
	if ErrorLevel
		forceClose(winID)
    Sleep, % sleepAfter
	run, % processPath
}
winList(ret := "array", msg := false, winTitle:="", excludeBlank := true) {
	WinGet, winList, List, % winTitle                 ;Get titles of all running and visible windows
	loop, %winList% {
		ahkID := "ahk_ID " winList%A_Index%                 ;winList is an pseudo-array
		vTitle := winTitle(ahkID, "ID", true)	
		if (excludeBlank=true) && (vTitle=ahkID)
			continue
		else if (ret = "array") {
			if !IsObject(Result)
				Result := []
			Result.Push(vTitle)
		}
		else if (ret = "text")
			Result .= ++index ". " vTitle "`r`n"
	}
	if  (ret = "array") && (msg = true)
		msgEnum(Result)
    else if (ret = "text") && (msg = true)
        Msgbox, % Result
	return Result
}
winTitle(pWin := "A", method := "process", fullTitle := false) {
	WinGetTitle, vTitle, % pWin
	if (method = "title")
		return vTitle
	else if (method = "process") {
		WinGet, vProcess, ProcessName, % pWin
		outputTitle := "ahk_exe " vProcess
	} else if (method = "class") {
		WinGetClass, vClass, % pWin
		outputTitle := "ahk_class " vClass
	} else if (method = "ID") {
		WinGet, vID, ID, % pWin
		outputTitle := "ahk_ID " vID
    } else if (method = "PID") {
        WinGet, vPID, PID, % pWin
        outputTitle := "ahk_PID " vPID
    }
    if (fullTitle=true) && (vTitle != "")
		outputTitle := vTitle " " outputTitle
	return outputTitle
}
isVisible(checkWin) {						
    static WS_VISIBLE := 0x10000000
    WinGet, Style, Style, % checkWin
    if (Style & WS_VISIBLE)
        return 1
    return 0
}
disableCloseButton(hWnd = "") {
	if hWnd=
		hWnd := WinExist("A")
	hSysMenu := DllCall("GetSystemMenu", "Int", hWnd, "Int", FALSE)
	nCnt := DllCall("GetMenuItemCount", "Int", hSysMenu)
	DllCall("RemoveMenu", "Int", hSysMenu, "UInt", nCnt-1, "Uint", "0x400")
	DllCall("RemoveMenu", "Int", hSysMenu, "UInt", nCnt-2, "Uint", "0x400")
	DllCall("DrawMenuBar", "Int", hWnd)
	return ""
}
resizeForce(ByRef hWND, X, Y, W, H) {
	DllCall("SetWindowPos"
		, "UInt", hwnd
		, "UInt", 0 ; hWndInsertAfter
		, "Int" , X ; X
		, "Int" , Y ; Y
		, "Int" , W ; cx (width)
		, "Int" , H ; cy (height)
	, "UInt", 4|0x400) ; uFlags
}
;;;; UIA/Chrome.ahk additional functions
uCentInst(activate := true, update := false) {
    global uCent	
	if (activate = true) || !uCent
		WinActivate, ahk_exe chrome.exe
	if (update = true)
		return uCent := new UIA_Chrome("ahk_exe chrome.exe")
	currentID := winGet("ID", "ahk_exe chrome.exe")
	if !uCent.BrowserId || (uCent.BrowserId != currentID)
		return uCent := new UIA_Chrome("ahk_exe chrome.exe")
}
objUIA(winTitle) {
	return UIA.ElementFromHandle(WinExist(winTitle))
}
elementToggle(element1, element2 := "", pMethod := "selector") {
	global Page := Cent.GetPage()
	if (pMethod = "selector")
		method := "querySelectorAll"
	else if (pMethod = "class")
		method := "getElementsByClassName"
	try
		Page.Evaluate("document." method "(""" element1 """)[0].click();")
	catch {
		try
			Page.Evaluate("document." method "(""" element2 """)[0].click();")
	}
	Page.Disconnect()
}
checkElement(elementSelector) {
    global Page
    if !IsObject(Page)
        Page := Cent.GetPage()
    JS = 
    (LTrim
        window.alert(document.querySelectorAll('%elementSelector%').length);
    )
    Page.Evaluate(JS)
}
queryElementSeq(pArray, byAttribute := "selector", method :="click", interval := 100, msTimeout := 8000) {
	global Page
	for aIndex, aValue in pArray
		queryElement(aValue, byAttribute, method, interval, msTimeout)
}
queryElement(element, byAttribute := "selector", method := "click", interval := 100, msTimeout := 8000) {	
	global Page
	startTime := A_TickCount
	if (byAttribute = "selector")
		JScript := "document.querySelectorAll(""" element """)[0]." method "();"
	else if (byAttribute = "class")
		JScript := "document.getElementsByClassName(""" element """)[0]." method "();"
	else if (byAttribute = "id")
		JScript := "document.getElementById(""" element """)." method "();"
	loop
	{
		; try 
		; {
		; 	Page.Evaluate(JScript)
		; 	throw, "fakeError"
		; }
		; catch, thisError  (run-time errors are objects)
		; {
		; 	if !IsObject(thisError)         ;e="fakeError" != object
		; 		break
		; 	else                            ;e="fakeError"=string
		; 		Sleep, % interval
		; }
        elapsedTime := A_TickCount - startTime
        if (elapseTime>=msTimeout) {
            Msgbox, % "Timeout!"
            break
        }
        try
            Page.Evaluate(JScript)
        catch, thisException              
            Sleep, % interval           ;sleep if catch exception
        if isObject(thisException) {
            thisException := ""         ;free exception and go to next attempt
            continue
        } else
            break
	}
}
;;;; v2fn/command converted~expanded functions/
;;potential functions: Msgbox(), 
soundPlay(filePathorCode := "", WAIT := false, byMaster := "", ByRef vInput:="") {
; *-1 = Simple beep.
; *16 = Hand (stop/error)
; *32 = Question
; *48 = Exclamation
; *64 = Asterisk (info)  ;disabled in System Sounds
    if (vInput != "") {
        return DllCall( "winmm.dll\sndPlaySoundA", UInt, &vInput
                        , UInt, ((SND_MEMORY:=0x4)|(SND_NODEFAULT:=0x2)) )
    }
    else if (byMaster != "") {
        if (WAIT=false)
            Throw, "volChange is only legitimate in WAIT mod!"
        static WMP := ComObjCreate("WMPlayer.OCX.7")
        WMP.Settings.Volume := byMaster     ;volume_new = byMaster * master volume
        if (filePathorCode ~= "\*\d{1,3}")
            Throw, "fileCode doesn't work with volChange"
        else
            WMP.url := filePathorCode
        while WMP.PlayState != 1
            Sleep, 10
        WMP.Settings.Volume := 100     ;reset WMP volume settings
    }
    else {
        SoundPlay, % filePathorCode, % WAIT    ;also use WMP volume settings somehow
        if ErrorLevel {
            Msgbox, % "Please check the sound path!"
            return !ErrorLevel
        }
    }
}
winMove(wTitle := "", X := "", Y := "", W := "", H := "", wText := "", ExcludeTitle := "", ExcludeText := "") {
	local
	winID := winTitle(wTitle, "id")
	WinGetPos, cX, cY, cW, cH, % winID
	if (X ~= "^(\+|--)\d+")
		X := cX + RegExReplace(X, "--", "-")
	if (Y ~= "^(\+|--)\d+")
		Y := cY + RegExReplace(Y, "--", "-")
	if (W ~= "^(\+|--)\d+")
		W := cW + RegExReplace(W, "--", "-")
	if (H ~= "^(\+|--)\d+")
		H := cH + RegExReplace(H, "--", "-")
    if (wTitle~="ahk_exe chrome\.exe") {
        if (H>1102)
            Msgbox, % "centH max is 1102"
    }
	loop, 3 
	{
		min_max := winGet("minmax", winID)
		if (min_max != 0)
			PostMessage, 0x0112, 0xF120,,, % winID, % wText
		else
			break
	}
    Sleep, 50
	WinMove, % winID, % wText, % X, % Y, % W, % H, % ExcludeTitle, % ExcludeText
}
Send(String, level := "", Raw := false, RawKeys := false) {      ;Send() with inline Sleep support 
;Send("Really, {2000} any Sleep !fcould{3000}{Enter} go+{Tab 8} here {3.5s}and it {500}should work.", 1)
;Raw=true ⇒ Raw mode ⇒ all character are literals except {Sleep}; RawKeys=true ⇒ affect {Alt}, not !
;{3000}={3s}  ; {-20} ⇒ ClipWait max 20s
; Support dynamic reference {" expression "}
; Sleep := 10000, Send("Sleeping for 10 seconds. Please Wait.... {" Sleep/2 "}Done Sleeping.")
; Send("+{Enter}+!{Tab 8}#!+^{Del}")     ;modifier keys are supported, {+}, {!} for literal +, !, etc.
    local
	if level {
		oldLevel := A_SendLevel
		SendLevel, %level%
	}
    D := "{", E = "}", S := String D, i=0, T=1, R=(Raw?1:(SubStr(S, 1, 5)="{RAW}"?1:0)), M = "+, !, #, ^", K=RawKeys
    While i := InStr(S, D, V, i+1)
	{
        Send, % (R?"{RAW}":"") SubStr(S, T, InStr(S, D, V, i)-T)
        B := SubStr(S, InStr(S, D, V, i)+1, InStr(S, E, V, i)-StrLen(S)-1), A=SubStr(B, 1, -1)
        if InStr(S, D, V, i+1)
            if (B&1 = "") {
                if (A&1 != "")
                    Sleep, % A*1000
                else {
                    L := (!R?(InStr(S, E, V, i)-StrLen(B)-2>4?4:InStr(S, E, V, i)-StrLen(B)-2):0)
                    Loop, %L% {
                        C := SubStr(SubStr(S, InStr(S, D, V, i)-L, L), A_Index, 1)
                        if C in %M%
                        {    C := SubStr(S, InStr(S, D, V, i)-(L+1-A_Index), L+1-A_Index)
                            break
                        } else C := ""
                    } Send, % (K?"{RAW}":"") C D B E
            }}else if (W := SubStr(B, 2))
                ClipWait, %W%
            else Sleep, %B%
        T := InStr(S, E, V, i+1)+1
	}
	SendLevel, % oldLevel
}
Deref(String) {     ;Deref("This string contains %var1% and %var2% content")
    spo := 1	  ;Deref("%var1%") returns var1
    out := ""
    while (fpo := RegexMatch(String, "(%(.*?)%)|``(.)", m, spo))
    {
        out .= SubStr(String, spo, fpo-spo)
        spo := fpo + StrLen(m)
        if (m1)
            out .= %m2%
        else switch (m3)
        {
            case "a": out .= "`a"
            case "b": out .= "`b"
            case "f": out .= "`f"
            case "n": out .= "`n"
            case "r": out .= "`r"
            case "t": out .= "`t"
            case "v": out .= "`v"
            default: out .= m3
        }
    }
    return out SubStr(String, spo)
}
winGet(subCommand, winTitle := "A", winText := "", excludeTitle := "", excludeText := "") {
    local outputVar
    if !(subCommand ~= "i)pos|ID|IDLast|PID|ProcessName|ProcessPath|Count|List|MinMax|ControlList|ControlListHwnd|Transparent|TransColor|Style|ExStyle")
        Throw, "Invalid argument: 'subCommand'"
    if (subCommand = "pos") {
        loop, 3 {
            min_max := winGet("minmax", winTitle)
            if (min_max != 0)
                PostMessage, 0x0112, 0xF120,,, % winTitle, % wText
            else
                break
        }
        WinGetPos, outX, outY, outW, outH, % winTitle, % winText, % excludeTitle, % excludeText
        outputVar := outX ", " outY ", " outW ", " outH
    } else if (subCommand = "text") {
        WinGetText, outputVar , % winTitle, % winText, % excludeTitle, % excludeText
    } else
        WinGet outputVar, % subCommand, % winTitle, % winText, % excludeTitle, % excludeText
    return outputVar
}
Input(Options := "", EndKeys := "", MatchList := "") { ; myInput := Input("V T5 L4 C", "{enter}{esc}.", "btw, otoh, fl, ahk, ca")
    local OutputVar			
    Input OutputVar, % Options, % EndKeys, % MatchList
    return OutputVar
}
toolTip(text := "", msTimeout := 2000, X := "", Y := "", WhichToolTip := "") {
    ToolTip, % text, % X, % Y, % WhichToolTip
	if (msTimeout != "")
		SetTimer, RemoveToolTip, % -msTimeout   ;Avoid pausing current thread with the use of Sleep 
}
RemoveToolTip:
	ToolTip
	return
KeyWait(keys, state := "L", sTimeout := 5, msg := true) {
	if (sTimeout =- 1)
		sTimeout := 1000000
	if (state = "P")
		state := ""
	keyArray := StrSplit(keys, "`, ", " ")
	for key, value in keyArray					;loop_parse doesn't work somehow
	{
		KeyWait, % value, % state " T" sTimeout
		if ErrorLevel && (msg=true)
			Msgbox, %value% Timeout!
	}
}
URLDownloadToVar(url, ByRef variable = "") {
    hObject := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    hObject.Open("GET", url)
    hObject.Send()
    hObject.WaitForResponse()
    return variable := hObject.ResponseText
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#ifWinActive
; ` & ::
	KeyWait("``")
	DetectHiddenWindows, On
	if WinExist("ReAltime Code tester ahk_exe Code Tester.exe") {
		WinShow, ReAltime Code tester ahk_exe Code Tester.exe
		WinActivate, ReAltime Code tester ahk_exe Code Tester.exe
	} else
		run, % "C:\0. Coding\ahkRepos\Lib\Code Tester.exe"
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			UIAarea

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;			Wcliparea
` & j::
	KeyWait("``")
	wc.iCopy()
	clipSize := wc.iSnap() ;copies clip data into inner buffer for later using
	objFormats := wc.iGetFormats()
	list =
	for nFmt, params in objFormats {
	list .= "`n" nFmt " : " params.name " : " params.size " : " params.GetCapacity( "buffer " )
	}
	Msgbox % list
	wc.iClear()
	return
;NumpadClear & v::
	hBitmap := WinClip.GetBitmap()
	Gui, Add, Picture, % "hwndPicHwnd +" SS_BITMAP := 0xE
	SendMessage, % STM_SETIMAGE := 0x0172, % IMAGE_BITMAP := 0, % hBitmap,, ahk_id %PicHwnd%
	DllCall("DeleteObject", "Ptr", hBitmap )
	Gui, Show, w1000 h700
	return
NumpadClear & 5::
	WinClip.AppendText("text appended")
	Soundbeep
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 			`area
` & b::
    WinActivate, Browse ahk_exe anki.exe
    return
` & f::										;Window Switch
	Input, output, I1 L1, {LShift}, 1, 2, 3, 4, 5
	if (output=1)
		WinActivate, ahk_exe chrome.exe
	if (output=2)
		WinActivate, ahk_exe hh.exe
	if (output=3)
		WinActivate, ahk_exe Code.exe
	;Msgbox,,, done!, 0.2
	return
` & c::	
	KeyWait("``")
	; wc_temp.iSnap()
	if !wcTemp
		wcTemp := new WinClip
	wcTemp_toAppend := wcTemp.iCopy()
	if !wcTemp_fullList
		wcTemp_fullList := wcTemp_toAppend
	else
		wcTemp_fullList .= "`r`n" wcTemp_toAppend
	ggTTS("text copied")
	return
` & v::
	KeyWait("``")
	if !wcTemp
		Msgbox, % "wc does not exist!"
	else {
		Msgbox, % clipboard := wcTemp_fullList
		wcTemp.iClear()
		freeMem("wcTemp_fullList")
	}
	return
; ` & e::
	KeyWait("``")
	if WinExist("ExExec.ahk ahk_exe AutoHotkeyU64.exe")
		WinActivate, ExExec.ahk ahk_exe AutoHotkeyU64.exe
	else
		run, % "C:\0. Coding\ahkRepos\ExExec.ahk"
	return
; ` & ::
	KeyWait("``")
	if GetKeyState("Xbutton2", "P")
		InputBox, query, CambridgeDict Query, Please enter the search query,, 300, 100
	else 
		query := WinClip.Copy()
	if (query != "")
		run, https://dictionary.cambridge.org/dictionary/english/%query%
	freeMem("query")
	return
` & s::
	KeyWait("``")`
	if GetKeyState("Xbu`tton2", "P")
		InputBox, query, Wikipedia Query, Please enter the search query,, 300, 100
	else 
		query := WinClip.Copy()
	if (query != "")
		run, https://en.wikipedia.org/w/index.php?search=%query%
	freeMem("query")
	return
` & q::
	KeyWait("``")
	if GetKeyState("Xbutton2", "P")
		InputBox, query, Ludwig.guru Query, Please enter the search query,, 300, 100
	else	
		query := WinClip.Copy()
	if (query != "")
		run, https://ludwig.guru/s/%query%
	freeMem("query")
	return
` & y::
	KeyWait("``")
	if GetKeyState("Xbutton2", "P")
		InputBox, query, YouTube Query, Please enter the search query,, 300, 100
	else
		query := WinClip.Copy()
    if (query != "")  
		run, https://www.youtube.com/results?search_query=%query%
	freeMem("query")
	return
` & w::
	KeyWait("``")
	if GetKeyState("Xbutton2", "P")
		InputBox, query, Wiktionary Query, Please enter the search query,, 300, 100
	else	
		query := WinClip.Copy()
    if (query != "")
        run, https://en.wiktionary.org/w/index.php?search=%query%
	freeMem("query")
	return

` & x::												;persitent black screen
	KeyWait("``")
	Gui, Color, 0x000000
	Gui, -Caption
	Gui, Show, NA w%A_ScreenWidth% h%A_ScreenHeight%
	Loop 
	{
		if GetKeyState("Escape", "P") {
			BlockInput Off
			Break
		} else if (A_TimeIdlePhysical<500) {
			SendMessage, 0x112, 0xF170, 2,, A
			BlockInput On
		}
	}
	Gui, Destroy
	return
` & 6::
	KeyWait("``")
	Loop 
	{
		if GetKeyState("Escape", "P") {
			BlockInput Off
			Break
		} else if (A_TimeIdlePhysical<500)
			BlockInput On
	}
	return
;;
; ` & 4::
	KeyWait("``")
	if !WinExist("Media Player ahk_exe ApplicationFrameHost.exe") {
		run, % "Explorer shell:appsFolder\Microsoft.ZuneMusic_8wekyb3d8bbwe!Microsoft.ZuneMusic"
		WinWait, Media Player ahk_exe ApplicationFrameHost.exe,, 5
		leftPattern("Media Player ahk_exe ApplicationFrameHost.exe")
	} else if !WinActive("Media Player ahk_exe ApplicationFrameHost.exe")
		WinActivate, Media Player ahk_exe ApplicationFrameHost.exe
	else
		WinMinimize, Media Player ahk_exe ApplicationFrameHost.exe
	return

 ;;
$+`::
	KeyWait("LShift")
	Send, {U+007E}
	return
`::
	Send, {U+0060} 
	return
` & 9::
	KeyWait("``")
	SplashTextOn, 1000, 200, Hiiiiii, The clipboard contains:`n%clipboard%
	WinGetPos,,, W, H, Hiiiiii
	pos1 := (A_ScreenWidth - W)/2
	pos2 := (A_ScreenHeight - H)/2
	WinMove, Hiiiiii,, %pos1%, %pos2%
	Sleep, 3000
	SplashTextOff
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 			;Abandonned projects
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
>!-::
	KeyWait("RAlt")
	InputBox, password, Enter Password, (your input will be hidden), hide
	InputBox, UserInput, Phone Number, Please enter a phone number.,, 640, 480
	if ErrorLevel
		Msgbox, % "CANCEL was pressed."
	else
		Msgbox, % "You entered " UserInput
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; numarea
; *Numlock::										;Disable Numlock Native Function
; 	if (A_ThisHotkey = "*Numlock") && GetKeyState("Control", "P")
; 		SetNumLockState, AlwaysOff
; 	; else (A_ThisHotkey = "*Numlock")
; 		; SetNumLockState, On
; 	return
` & Tab::	 
	Soundbeep, 523, 300
	SetCapslockState, % GetKeyState("Capslock", "T") ? "Off" : "On"
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;					;Xbuttonarea
; $+Xbutton2::
	KeyWait("LShift")
	X := -9, Y := -65, W := 1361
	if WinActive("Word ahk_exe WINWORD.EXE") and isVisible("ahk_exe WINWORD.EXE")
		PostMessage, 0x0112, 0xF020,,, Word ahk_exe WINWORD.EXE
	else if WinExist("Word ahk_exe WINWORD.EXE") {	
		WinActivate, Word ahk_exe WINWORD.EXE		
		WinWaitActive, Word ahk_exe WINWORD.EXE,, 2
		if ErrorLevel {
			DetectHiddenWindows, On
			WinKill, ahk_exe WINWORD.EXE
		}
		leftPattern()														
	} else {
		run, "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE" "C:\Users\zlegi\Desktop\wordNotes\mainNote.docx"
		WinWait, Word ahk_exe WINWORD.EXE
		WinActivate, Word ahk_exe WINWORD.EXE
		leftPattern()
	}
	return
XButton2::
	if winCursor("ahk_exe chrome.exe") {
		if !WinActive("ahk_exe chrome.exe")
			WinActivate, ahk_exe chrome.exe	
		oldTitle := winTitle("A")
		Send, !p
		Sleep, 100
		nTitle := winTitle("A")
		if (newTitle==oldTitle)
			Send, {Ctrl Down}{Shift Down}{Tab}{Ctrl Up}{Shift Up}
	}
    else 
        Send, {Ctrl Down}{Tab}{Ctrl Up}
	return
; Xbutton1 & Lbutton::								;!a
	; KeyWait("Xbutton1")
	; if winCursor("ahk_exe chrome.exe") {
	; 	if !WinActive("ahk_exe chrome.exe")
	; 		WinActivate, ahk_exe chrome.exe	
	; 	Send("^+{space}", 1)
	; }
	return
Xbutton2 & Lbutton::
	if winCursor("ahk_exe chrome.exe") || WinActive("ahk_exe chrome.exe") {
		if !WinActive("ahk_exe chrome.exe")
			WinActivate, ahk_exe chrome.exe	
		Send, ^s
	} else if WinActive("Banana - Anki ahk_exe anki.exe")
        Send, ^z
    else if WinActive("ahk_exe Code.exe") || WinActive("ahk_exe Obsidian.exe")
		Send, ^w
    else if WinActive("ahk_exe WindowsTerminal.exe")
        Send, ^+w
	else 
		WinClose, A
	return
Xbutton2 & Rbutton::
	if winCursor("ahk_exe chrome.exe") {
		if !WinActive("ahk_exe chrome.exe")
			WinActivate, ahk_exe chrome.exe	
		Send, ^+c
	} else if winCursor("ahk_exe anki.exe") {
        if !WinActive("Banana - Anki ahk_exe anki.exe")
		    WinActivate, Banana - Anki ahk_exe anki.exe
        Send, 1
    } else if WinActive("ahk_exe Code.exe") || WinActive("ahk_exe Obsidian.exe")
		Send, ^+t
	else
		Msgbox, % unassinged!
	return
$^Xbutton1::
	KeyWait("LCtrl")
	if WinActive("ahk_exe chrome.exe")
		Send, ^1
	else if WinActive("ahk_exe Code.exe") {
		if WinActive("Banana's Script.ahk ahk_exe Code.exe")
			soundPlay("*48")
		else if !vscClick("Banana's Script.ahk", "Text", false)
			run, "%vscPath%" "C:\0. Coding\ahkRepos\Banana's Script.ahk"
	} else if winCursor("ahk_exe chrome.exe") {
		WinActivate, ahk_exe chrome.exe
		Sleep, 50
		Send, ^1
	} else if WinActive("ahk_exe Obsidian.exe") {
        if WinActive("Banana's Script.ahk ahk_exe Obsidian.exe")
            soundPlay("*48")
        else
            run, "%vscPath%" "C:\0. Coding\ahkRepos\Banana's Script.ahk"
    } else
		Send, {Esc}
	return
$^Xbutton2::
	KeyWait("LCtrl")
	if WinActive("ahk_exe chrome.exe")
		Send, ^9	
	else if WinActive("ahk_exe Code.exe") {
		if WinActive("test.ahk ahk_exe Code.exe")
			Send, ^9
		else if !vscClick("test.ahk", "Text", false)
			run, "%vscPath%" "C:\0. Coding\ahkRepos\test.ahk"
	} else if winCursor("ahk_exe chrome.exe") {
		WinActivate, ahk_exe chrome.exe
		Sleep, 50
		Send, ^9
	}else if WinActive("ahk_exe Obsidian.exe") {
        if WinActive(" ahk_exe Obsidian.exe")
            soundPlay("*48")
        else
            run, x
    } else
		Msgbox,,, unassinged!, 0.6
	return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 					;capsarea
; NumpadClear & e::									;Open VBE
	if WinActive("Microsoft Visual Basic ahk_exe EXCEL.EXE")
		Send, {vkE8} 
	else if WinExist("Microsoft Visual Basic ahk_exe EXCEL.EXE") 
		WinActivate, Microsoft Visual Basic ahk_exe EXCEL.EXE
	else {
		WinActivate, ahk_exe EXCEL.EXE
		Send, !{F11}
		WinWaitActive, Microsoft Visual Basic ahk_exe EXCEL.EXE
	}
	leftPattern()
	return
NumpadClear & e::
	KeyWait("NumpadClear", "P")
    if GetKeyState("Xbutton2", "P") {
        Send("{RAlt Down}{RShift Down}k{RAlt Up}{RShift Up}", 1)
        soundPlay("C:\0. Coding\ahkRepos\Audio\Red Alert 2\Battle control terminated - ceva015.wav", true)
        return
    }
	if WinActive("ahk_exe Code.exe") { ;|| WinActive("test.ahk ahk_exe AutoHotkey64.exe") {
		if WinActive("Banana's Script.ahk ahk_exe Code.exe")
            soundPlay("*48")
        else if WinActive("test.ahk ahk_exe Code.exe") {
            Send, ^s          
            Sleep, 200
            run, % "C:\0. Coding\ahkRepos\test.ahk"
		} else {    
            ; Send, ^s              ;not necessary due to auto-save 
			; Sleep, 200
			Send, ^{F9}	
        }
	} else if !WinActive("ahk_exe Code.exe") && WinExist("ahk_exe Code.exe")
		run, "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe" /restart "C:\0. Coding\ahkRepos\test.ahk" 
    return
NumpadClear & i::
	WinSet, ExStyle, ^0x80, A
	return
NumpadClear & y::
    try { 
        ytbPage := Cent.GetPageByURL("https://www.youtube.com", "contains") 
        ytbPage.Call("Page.bringToFront")
        ytbPage.Disconnect()
        freeMem("ytbPage")
    } catch 
        run, https://www.youtube.com/
    return
	; SetTitleMatchMode, regex
	; if WinActive("i)YouTube ahk_exe chrome.exe") {
	; 	click, 431, 836, 0
	; 	currentURL := getURL()
	; 	Gui +LastFound +OwnDialogs +AlwaysOnTop
	; 	InputBox, input, YouTube URL, Please enter current timepoint,, 220, 123, 750, 525,, 12
	; 	if !ErrorLevel {
	; 		length := StrLen(input)
	; 		array := StrSplit(input,,, 5)
	; 		if (length=3) {
	; 			hour := 0
	; 			minute := array[1]
	; 			second := array[2] . array[3]
	; 		} else if (length=4) {
	; 			hour := 0
	; 			minute := array[1] . array[2]
	; 			second := array[3] . array[4]
	; 		} else if (length=5) {
	; 			hour := array[1]
	; 			minute := array[2] . array[3]
	; 			second := array[4] . array[5]
	; 		} 
	; 		time := (hour * 3600) + (minute * 60) + second
	; 		clipboard := currentURL "?t=" time
	; 		WinActivate, ahk_exe anki.exe
	; 		soundbeep
	; 		return
	; 	}
	; } else
	; return
; NumpadClear::LButton
; NumpadClear::Enter  
; ; NumpadClear::											;Disable NumpadClear Native Function
; ; 	if !GetKeyState("Xbutton2", "P")
; ; 		Send, {Enter}
; ; 	return
; $+NumpadClear::
; 	Send, +{Enter}
; 	return
; $^NumpadClear::
    ; Send, {Ctrl Down}{Enter}{Ctrl Up}
    ; return
$!NumpadClear::	
	if WinActive("ahk_exe sublime_text") || WinActive("ahk_exe Code.exe")
		Send, ^{Enter}
	else if WinActive("ahk_exe Explorer.EXE")
		Send, !{Enter}
	else {
		Send, {End}
		Sleep, 100
		Send, {enter}
	}
	return
;;;
` & space::
	X := -14, Y := -12, W := 1366
	if !WinExist("Clock ahk_exe ApplicationFrameHost.exe") {
		run, % "Explorer shell:appsFolder\Microsoft.WindowsAlarms_8wekyb3d8bbwe!App"
		WinWaitActive, Clock ahk_exe ApplicationFrameHost.exe
		WinSet, ExStyle, +0x80, Clock ahk_exe ApplicationFrameHost.exe
		Sleep, 100
		leftPattern()
	} else if WinActive("Clock ahk_exe ApplicationFrameHost.exe") {
		DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist("Window Title")
		, "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_DISABLED := 1, "uint", 4)
		leftPattern()
	} else
		WinACtivate, Clock ahk_exe ApplicationFrameHost.exe
    uiaClock := objUIA("Clock ahk_exe ApplicationFrameHost.exe")
    uiaClock.FindFirstBy("Name=Timer && ControlType=ListItem").click()
	return
;;;
$^+Backspace::
    KeyWait("LCtrl, LShift")
    Send, +{Home}
	Send, {delete}
    return
$^+space::														
    KeyWait("LCtrl, LShift")
	Send, +{Home}
	Send, {delete}
	return
$+space::
    KeyWait("LShift")
	Send, +{End}
	Send, {delete}
	return
; NumpadClear & Delete:: ;Delete all to the right
; 	Send, +{End}
; 	Send, {delete}
; 	return
; NumpadClear & Backspace::								;Delete all to the left
; 	Send, +{Home}
; 	Send, {delete}
; 	return
NumpadClear & u::										;shorten selected link
	WinClip.Copy()
	if WinExist("URL shortener ahk_exe AutoHotkeyU64.exe") {
		WinActivate, URL shortener ahk_exe AutoHotkeyU64.exe
		WinSet, AlwaysOnTop, On, URL shortener ahk_exe AutoHotkeyU64.exe
	} else {
		run, % "C:\0. Coding\ahkRepos\Shorten URL.ahk"
		WinWaitActive, URL shortener ahk_exe AutoHotkeyU64.exe
		WinSet, AlwaysOnTop, On, URL shortener ahk_exe AutoHotkeyU64.exe
	}
	return
NumpadClear & k::
	if WinActive("VBA to AHK code ahk_exe AutoHotkeyU64.exe")
		WinSet, ExStyle, +0x80, VBA to AHK code ahk_exe AutoHotkeyU64.exe
	else if WinExist("VBA to AHK code ahk_exe AutoHotkeyU64.exe") {
		WinActivate, VBA to AHK code ahk_exe AutoHotkeyU64.exe
		WinSet, ExStyle, +0x80, VBA to AHK code ahk_exe AutoHotkeyU64.exe
		disableCloseButton(WinExist("VBA to AHK code ahk_exe AutoHotkeyU64.exe"))
	} else {
		run, % "C:\0. Coding\ahkRepos\VBAtoAHK.ahk"
		WinWaitActive, VBA to AHK code ahk_exe AutoHotkeyU64.exe
		Sleep, 300
		WinSet, ExStyle, +0x80, VBA to AHK code ahk_exe AutoHotkeyU64.exe
		disableCloseButton(WinExist("VBA to AHK code ahk_exe AutoHotkeyU64.exe"))
	}
	return
NumpadClear & 3::											
	if WinActive("Bandicam ahk_exe bdcam.exe") {
		WinSet, ExStyle, +0x80, Bandicam ahk_exe bdcam.exe
		WinMinimize, Bandicam ahk_exe bdcam.exe
	} else if WinExist("Bandicam ahk_exe bdcam.exe") {
		WinActivate, Bandicam ahk_exe bdcam.exe
		WinSet, ExStyle, +0x80, Bandicam ahk_exe bdcam.exe
		disableCloseButton(WinExist("ahk_exe bdcam.exe"))
	} else {
		run, % "C:\0. Downloaded Programs\Bandicam_6.0.1.2003_Portable_by_elchupacabra\BandicamPortable.exe"
		WinWaitActive, Bandicam ahk_exe bdcam.exe
		Sleep, 300
		WinSet, ExStyle, +0x80, Bandicam ahk_exe bdcam.exe
		disableCloseButton(WinExist("ahk_exe bdcam.exe"))
	}
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 				HXarea
;NumpadClear & a::
	Msgbox,,, Please select Google page, 1
	KeyWait("LShift", "D")
	FileRead, var, C:\Users\zlegi\Desktop\HXUpload\sitelist.txt
	WinGetTitle, old, A
	loop {
		setkeydelay, 200
		clipboard := ""
		clipboard := getURL()
		ClipWait, 3
		array := StrSplit(clipboard, "/", " `t")
		clipboard := array[1] . "/" . array[2] . "/" . array[3]
		if (var ~= clipboard)
			Send, ^s
		else {
			Send, ^q
			Sleep, 100
			WinGetTitle, new, A
		}
	} Until (new = old)
	return
;NumpadClear & s::
	clipboard := ""
	if WinActive("ahk_exe chrome.exe")
		clipboard := getURL()
	else
		Send, ^c
	ClipWait, 1.5
	array := StrSplit(clipboard, "/", " `t")
	clipboard := array[1] . "/" . array[2] . "/" . array[3]
	;Msgbox,,, % clipboard, 0.6
	FileRead, var, C:\Users\zlegi\Desktop\HXUpload\sitelist.txt
	if (var ~= clipboard) {
		Msgbox,,, "This is old!", 0.5
		Send, {Ctrl Down}s{Ctrl Up}
	} else {
		Msgbox, 4,, "This is new!", 6
		ifMsgbox Yes 
		{
			len := StrLen(clipboard)
			array := StrSplit(clipboard)
			if !(array[len] = "/")
				clipboard := clipboard . "/"
			FileAppend, % clipboard . "`n", C:\Users\zlegi\Desktop\HXUpload\sitelist.txt
			Sleep, 500
			WinActivate, ahk_exe chrome.exe
			Sleep, 100
			Send, ^s
		} else
			winactivate, ahk_exe EXCEL.exe
	}
	return
$^Numpad3::										;Outlook Sending Messages
	KeyWait("LCtrl")
	SetScrollLockState, Off
	Winset, AlwaysOnTop, Off, ahk_exe EXCEL.EXE
	InputBox, input, Loop Count, Please enter the number of interations,, 200, 100
	Winset, AlwaysOnTop, On, ahk_exe EXCEL.EXE
	loop 
	{
		clipboard := ""
		Sleep, 500
		Send, ^c
		ClipWait, 1.5
		coordmode, mouse, screen
		WinActivate, ahk_exe OUTLOOK.EXE
		Sleep, 700
		Send, ^+1
		Sleep, 500
		Send, {delete 2}
		Sleep, 500
		Send, {Shift Down}{Tab 3}{Shift Up}
		Send, ^a
		Sleep, 500
		Send, ^v
		Sleep, 1200
		Send, {Shift Down}{Tab 3}{Shift Up}
		Send, {enter}
		Sleep, 300
		WinActivate, ahk_exe EXCEL.EXE
		Sleep, 300
		Send, {down}
		Sleep, 100
	} Until A_Index = input
	Winset, AlwaysOnTop, Off, ahk_exe EXCEL.EXE
	Msgbox, % "done!"
	return
;$#`::
	KeyWait("LWin")
	InputBox, call, Dialing Box, Please enter dialing number,, 220, 140,,,, 15
	clipboard := RegExReplace(call, "[^0-9]")
	clipboard := RegExReplace(call, "[^0-9]")
	if (clipboard ~= "[0-9]+") {
		;WinActivate, ahk_exe EXCEL.EXE
		run, "C:\Users\zlegi\AppData\Local\WhatsApp\WhatsApp.exe" "whatsapp://Send/?phone=%clipboard%"
		WinWaitActive, ahk_exe WhatsApp.exe
		WinSet, ExStyle, +0x80, ahk_exe WhatsApp.exe
	} else {
		Msgbox,,, error, 0.3
		return
	}
	KeyWait("LShift", "D")
	click, 816, 543
	Sleep, 50
	WinSet, ExStyle, +0x80, ahk_exe WhatsApp.exe
	WinActivate, ahk_exe chrome.exe
	return
;;;;;;;;;;;;;;;;												naviarea
NumpadClear & w::
	; if WinActive("ahk_exe Code.exe")
	; 	Send, {Esc}
	Send, {Up}
	return
NumpadClear & s::
	Send, {Down}
	return
NumpadClear & a::
    if WinActive("ahk_exe Code.exe") {
        if isTerminal()
            Send, {Left}
        else
            Send, {Numpad4}
    }
    else
        Send, {Left}
	return
NumpadClear & d::
    if WinActive("ahk_exe Code.exe") {
        if isTerminal()
            Send, {Right}
        else
            Send, {Numpad6}
    }
    else
        Send, {Right}
	return
;;;;;;;;;;;;;;;; ahkTTS					
NumpadClear & t::
	text_to_speak := WinClip.Copy(3)					  ;speed and pitch range: 0-2.0
    Sleep, 50
	if !text_to_speak {
		Msgbox, % "Can't copy, please try again!"
		return
	}
	; if RegExmatch(text_to_speak, "[^[:ascii:]“”]")		  ;non-English characters												
	if RegExMatch(text_to_speak, "á|ả|à|ạ|ã|ă|ắ|ẳ|ằ|ặ|ẵ|â|ấ|ẩ|ầ|ậ|ẫ|đ|é|ẻ|è|ẹ|ẽ|ê|ế|ể|ề|ệ|ễ|ó|ỏ|ò|ọ|õ|ô|ố|ổ|ồ|ộ|ỗ|ơ|ớ|ở|ờ|ợ|ỡ|ư|ứ|ử|ừ|ự|ữ|í|ỉ|ì|ị|ĩ")
		ggTTS(text_to_speak, 301)						  ;needle = "[^\x00-\x7F]" also works
	else
		ggTTS(text_to_speak, 308)  
	freeMem("text_to_speak")
	; myTTS(clipboard, "Microsoft Zira",,, 1.1)          ;Mark, Zira, David are the only available for this API
	; myTTS.SetPitch(0)				;pitch from -10 to 10, default=0
	; myTTS.SetVoice("Microsoft Zira Desktop")
	; myTTS.ToggleSpeak(gst())		;play/pause speech of selected text copied by gst()
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 				area0
; $!`::
; 	KeyWait("LAlt")
; 	SendLevel 1
; 	Sendevent, !`
; 	SendLevel 0
; 	return
; $!Esc::
; 	KeyWait("LAlt")
; 	SendLevel 1
; 	Sendevent, !{Esc}
; 	SendLevel 0
; 	return
$^!1::
    KeyWait("LCtrl, LAlt")
    numberList:
    	clipboard := ""
    	Send, ^c
    	Sleep, 150
        inputStr := clipboard
        inputStr := RegExReplace(inputStr, "m)^\s+|\s+$")                 
    	inputStr := RegExReplace(inputStr, "m`a)^\d{1,2}\.\s*")
    	inputStr := RegExReplace(inputStr, "m)(^(\r\n|\n|\r)$)|(^(\r\n|\n|\r))|^\s*$")    ;Remove blank lines
    	x := 0
    	for i, Match in regexMatches(inputStr, "m)^.*$", "array")
    	{	
    		numbered_line := ++x ". " Match.Value
    		if (A_Index=1)
    			numbered_text .= numbered_line
    		else 
    			numbered_text .= "`r`n" numbered_line
    	}
    	; Msgbox, % numbered_text
    	WinClip.SetText(numbered_text)
    	clipboard := clipboard			;convert to plain text to avoid anki error
    	Send, ^v
    	freeMem("inputStr, numbered_line, numbered_text")
    return
NumpadClear & g::
    ; vURL := uCent.GetCurrentURL()
	; vTitle := winTitle(, "title")
    playground := GetKeyState("Xbutton1", "P") ? true : false
    if GetKeyState("Xbutton2", "P")
        vText := WinClip.Copy()
    if !WinActive("ahk_exe chrome.exe")
        WinActivate, ahk_exe chrome.exe
    uCentInst()

	if !(playground ? WinActive("Playground - Cent Browser ahk_exe chrome.exe") : WinActive("ChatGPT - Cent Browser ahk_exe chrome.exe")) {						;UIA can't query all tabs' URLs
        ; vText := WinClip.Copy()
		try {
            Page_GPT := Cent.GetPageByURL(playground ? "platform.openai.com/playground" : "chat.openai.com/chat", "contains") 
			Page_GPT.Call("Page.bringToFront")
			Page_GPT.Disconnect()
		}
        if !IsObject(Page_GPT)
			runURL(playground ? "https://platform.openai.com/playground/p/default-chat" : "https://chat.openai.com/chat")
        Sleep, 300
        oParent := uCent.FindByPath("1.1")
        gptTextBox := oParent.FindFirstBy("ControlType=Edit",, 2)
        gptTextBox.click()
        if vText {
            vText := Trim(vText, " `r`n`t")
            gptTextBox.SetValue(vText)
        }
        soundPlay(A_Audio "\Invoker - Knowledge is power.mpeg")
	} else if !playground {				
        if !vText {
            if !vText := WinClip.Copy() {
                soundPlay(A_Audio "\ggTTS\chưa copy text.wav")
                return
            }
        }							
		vText := Trim(vText, " `r`n`t")     ;or needle := "^[ \t\r\n]+|[ \t\r\n]+$")"
		WinClip.SetText(vText)
		uCent.Reload()
		uCent.WaitPageLoad("ChatGPT - Cent Browser ahk_exe chrome.exe", 7000,, "regex")
		oParent := uCent.FindByPath("1.1")
		if (gptTextBox := oParent.WaitElementExist("ControlType=Edit",,,, 2000))
            gptTextBox.SetValue(vText)
        else
            soundPlay("*48")
	}
    freeMem("playground, text, oParent, gptTextBox, Page_GPT")
	return
NumpadClear & q::       
    KeyWait("NumpadClear")
    if WinActive("ahk_exe anki.exe") {       ;anki.Cards view
        Send, ^l
        Sleep, 300
        leftPattern("Card Types ahk_exe anki.exe",,,, -300)
    } else
        Send, {Esc}
	return
$^+Esc::
    Msgbox, % "Use ^Esc instead"
    return
$^Esc::
	KeyWait("LCtrl")
	Send, ^+{Esc}
	WinWaitActive, Task Manager ahk_exe Taskmgr.exe
	winMove("Task Manager ahk_exe Taskmgr.exe", 259, 101, 1093, 827)
	return
NumpadClear & Lbutton::                                    ;pause YouTube and Music player
	uCentInst(, true)
	if !uCent.FindFirstByName("Global Media Controls") {  ;when the dialog open, the dialog=1 and no child
		; if oParent := uCent.FindByPath("4.1.2.1.2") 
			; cent_videoControl := oParent.FindFirstBy("Name=Control your music, videos, and mor && ControlType=Button",, 1)
		if !IsObject(cent_videoControl) {
			if !cent_videoControl := uCent.FindByPath("4.1.2.1.2.9") 
				cent_videoControl := uCent.ElementFromPoint(1151, 63)
		}
		cent_videoControl.click()
	}
	if uCent.FindFirstBy("Name=Global Media Controls") {
		; cent_play_pause := uCent.SmallestElementFromPoint(746, 229)
		; cent_play_pause.click()
		click, 777, 222
	}
	freeMem("cent_play_pause")
    return
NumpadClear & f::   
	WinGetActiveTitle, activeWin
	WinMinimize, % activeWin
	Hotkey, *f, DoNothing, On UseErrorLevel   ;imitate "bk" code "*" in * is critical, otherwise 'f' will auto-repeat
	Sleep, 300
	KeyWait("f", "P", -1)
	WinActivate, % activeWin
	Hotkey, *f, Off
	return
	DoNothing:
	return
; NumpadClear & f Up::
; 	; WinSet, Transparent, Off, A
; 	WinActivate, % activeWin
; 	return
$!+w::	
	KeyWait("LAlt, LShift")
	winID := winCursor("A")
	if (winTitle(winID) != "ahk_exe Code.exe")
		WinKill, % winID
	else
		; PostMessage, 0x0112, 0xF060,,, % winID         ;WinClose
        soundPlay("*48")
	freeMem("winID")
	return
$+Xbutton2::
	KeyWait("LShift")
	if !WinExist("ahk_exe Obsidian.exe") {
		run, % "C:\Users\zlegi\AppData\Local\Obsidian\Obsidian.exe"
		WinWaitActive, ahk_exe Obsidian.exe
		leftPattern()
	} else if !WinActive("ahk_exe Obsidian.exe")
		WinActivate, ahk_exe Obsidian.exe
	return
; LShift::
	loop {
		Send, {WheelDown 3}
		Sleep, 100
		if GetKeyState("LShift", "P")
			break
	}
	return
#+e::
	KeyWait("LWin, LShift")
	Send, #+e
	return
NumpadClear & v::
	SendEvent, {vk5Bsc15B Down}v{vk5Bsc15B Up}
	return
$#v::
	; KeyWait("LWin")
	ClipHistory.PutHistoryItemIntoClipboard(2)
	Send, ^v
	return
; NumpadClear & h::
	if WinActive("Card Types ahk_exe anki.exe")
		WinMinimize, Card Types ahk_exe anki.exe
	else if WinExist("Card Types ahk_exe anki.exe")
		WinActivate, Card Types ahk_exe anki.exe
	else if WinActive("Banana - Anki ahk_exe anki.exe") && ankiPixelColor("0xFFFFFF") {
		Send, e
		WinWaitActive, Edit ahk_exe anki.exe
		Sleep, 300
		Send, ^l
	} else
		Send, ^l
	return
>^m::														;Mute Chrome
	KeyWait("RCtrl")
	run, % nircmd " muteappvolume chrome.exe 2"
	return
officeClose(vTitle, iteration:=3) {
    loop, %iteration% {
        WinActivate, % vTitle
        WinClose, % vTitle
        
        WinWait, ahk_class NUIDialog,, 1
        Sleep, 300
        Send, {Enter}
        WinWaitClose, % vTitle,, 6
        if ErrorLevel
            continue
        else
            break
    }
}
terminateProtocol:
    officeClose("ahk_exe POWERPNT.EXE")
	officeClose("ahk_exe EXCEL.EXE")
	officeClose("ahk_exe WINWORD.EXE")
	WinClose, ahk_exe anki.exe
	WinWaitClose, ahk_exe anki.exe,, 8
	WinGet, wList, List
	loop, %wList% {
        WinKill, % "ahk_id " wList%A_Index%
    }
	return
$![::
	run, % nircmd " changebrightness -8"
	return
$!]::
	run, % nircmd " changebrightness +8"
	return
NumpadClear & 1::
	Loop 
	{
		Send, ^{End}
		Sleep, 500
		if GetKeyState("Lbutton", "P")
			break
	}
	return
#e::
	KeyWait("LWin")
	if WinExist("ahk_class CabinetWClass") {
		WinActivate, ahk_class CabinetWClass
		leftPattern()
	} else {
		Send, #e
		WinWaitActive, File Explorer
		leftPattern()
	}
	return
NumpadClear & j::											;forceClose
    if GetKeyState("Xbutton2", "P") || WinActive("ahk_class WorkerW") {
        InputBox, process, % "forceClose()", Please enter the process to close,, 267, 133, 829, 384,, 30
        if !ErrorLevel {
            if (input ~= "ahk_") {
                if hwnd := WinExist(input)
                    WinKill, % input
            } else {
                if !(process ~= "\.\w{2,6}$")
                    process .= ".exe"
                if hwnd := WinExist("ahk_exe " process)
                    forceClose(process)
            }
            SoundBeep
        }
    } else 
        forceClose()
	return
	forceClose(process := "A") {
		if (process = "A")
			WinGet, process, ProcessName, A
		; process := RegExReplace(process, ".exe")
		; psScript =
		; (
		; 	stop-process -name %process%
		; )
		; RunWait, C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -Command &{%psScript%},, hide
		run, % nircmd " killprocess " process
	}
$^Numpad7::
	KeyWait("LCtrl")
	WinSet, Style, -0xC00000, A ;Remove Title bar
	WinSet, ExStyle, +0x80, A			;Remove from Alt-tab list
	return
; Insert::
; 	state := GetKeyState("ScrollLock", "T")
; 	SetScrollLockState, % state ? "Off" : "On"
; 	if (state=1) {
; 		SoundBeep, 600, 700
; 		Msgbox,,, % "ScrollLock is On.", 0.6
; 	} else {
; 		SoundBeep, 600, 700
; 		Msgbox,,, % "ScrollLock is Off.", 0.6
; 	}
; 	return
#o::
	KeyWait("LWin")
	run, % "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
	WinWait, Internet Security Warning ahk_exe OUTLOOK.EXE
	WinKill, Internet Security Warning ahk_exe OUTLOOK.EXE
	return
$^+v::
	KeyWait("LCtrl, LShift", "P")
	clipSave := clipboardAll
	clipboard := clipboard							; Convert to plain text
	Send ^v
	Sleep 100
	clipboard := clipSave
	freeMem("clipSave")				
	return
;#tab::
	KeyWait("LWin")
	Click, 433, 400, 0
	run, % "C:\Program Files\Alt-Tab Terminator\AltTabTer.exe"
	Hotkey, RButton, wintab
	return
	wintab:
	WinClose, ahk_exe AltTabTer.exe
	return
$>!p::
	KeyWait("RAlt")
	MouseGetPos, x, y
	PixelGetColor, color, %x%, %y%
	Msgbox,,, %color%, 1
	return
$>!c::															;Copy Process Path
	KeyWait("RAlt")
	WinGet, win, ProcessPath, A
	toolTip(win, 3000)
	clipboard := win
	return
$!5::
	if GetKeyState("Xbutton2", "P")
        expandMode := true
    expandMode ? rightPattern(, 1211,, 720) : rightPattern()
    if WinActive("ahk_exe Code.exe") || WinActive("ahk_exe Obsidian.exe")
        winMove("ahk_exe chrome.exe", -9, -12, 1238, 1041), expandMode := true
    Sleep, 300
    expandMode ? leftPattern(winAt(558, 589),,, 1238) : leftPattern(winAt(558, 589))
    freeMem("expandMode")
	return
rightPattern(pWin := "A", X :="1334", Y :="-35", W :="597", H_arg := "") {
    H_current := 1063
    H_anki := 1065
	fullProcess := winTitle(pWin,, true)
	; if (fullProcess ~= "ahk_exe anki\.exe")
	; 	return
	PostMessage, 0x0112, 0xF120,,, % fullProcess
    if (fullProcess ~= "ahk_exe Code\.exe") {
        X -= 127, Y:=-45, W += 210, H_current += 9
		WinSet, Style, -0xC00000, ahk_exe Code.exe
		DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist("ahk_exe Code.exe")
		, "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_DISABLED := 1, "uint", 4)
		WinSet, Region, 13-0 W%W% H%H_current%, ahk_exe Code.exe
    } else if (fullProcess ~= "ahk_exe Obsidian\.exe") {
        X -= 123, Y := -10, W += 123, H_current -= 28
		WinSet, Style, -0xC00000, ahk_exe Obsidian.exe
		DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist("ahk_exe Obsidian.exe")
		, "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_DISABLED := 1, "uint", 4)
		WinSet, Region, 9-0 W%W% H%H_current%, ahk_exe Obsidian.exe
    } else if (fullProcess ~= "ahk_exe POWERPNT\.EXE")
		H_current += 61
	else if (fullProcess ~= "Clock ahk_exe ApplicationFrameHost\.exe")
		H_current -= 1
	else if (fullProcess ~= "AutoHotkey Help ahk_exe hh\.exe")
		H_current -= 1
	WinMove, % fullProcess,, % X, % Y, % W, % H_current
}
	return
$!t::															;WinMove to left-side pattern
	if GetKeyState("Xbutton2", "P")
        condensedMod :=  true
    if WinActive("ahk_exe chrome.exe")
        moveAll := true
    else if WinActive("ahk_exe Obsidian.exe") {
    	WinSet, Style, +0xC00000, ahk_exe Obsidian.exe
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist("ahk_exe Obsidian.exe")
        , "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_ENABLED := 2, "uint", 4)
    } else if WinActive("ahk_exe Code.exe") {
    	WinSet, Style, +0xC00000, ahk_exe Code.exe
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist("ahk_exe Code.exe")
        , "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_ENABLED := 2, "uint", 4)
    }
    if (moveAll = true) {
        winArray := ["ahk_exe chrome.exe", "ahk_exe Obsidian.exe", "ahk_exe Code.exe"]
        for i, winValue in winArray {
            if (winValue = "ahk_exe Obsidian.exe") && (winGet("pos", "ahk_exe Obsidian.exe") = "1211, -10, 720, 1035")
                continue
            if (condensedMod = true) 
                leftPattern(winValue,,, 1238)
            else 
                leftPattern(winValue)
        }
        WinActivate, ahk_class Chrome_WidgetWin_1
        Gosub, ankimove
    } else {
        if (condensedMod = true) 
            leftPattern(,,, 1238)
        else 
            leftPattern()
    }
    freeMem("moveAll, moveAll, condensedMod, winValue, winArray")
	return
leftPattern(pWin := "A", X :=-9, Y :=-12, W :=1361, H_arg := "") {
    if !WinExist(pWin)
        return
    Sleep, 60
	; if visibleTaskbar() {
    H_current := 1041
    H_anki := 1065
	; } else {
		; H_current := 1100
		; H_anki := 1300
	; }
	fullProcess := winTitle(pWin,, true)
	if (fullProcess ~= "ahk_exe anki\.exe") && !(fullProcess ~= "^Browse.+ahk_exe anki\.exe")
		return
	if (fullProcess ~= "ahk_exe Code\.exe") {
        if (W = 1238)
            X := -14, Y :=- 10, W := 1234, H_current -= 8
        else
            X := -14, Y :=- 10, W := 1358, H_current -= 8
    }
	else if (fullProcess ~= "^Browse.+ahk_exe anki\.exe") {
        WinSet, Style, +0xC00000, Browse ahk_exe anki.exe
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist("Browse ahk_exe anki.exe")
        , "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_ENABLED := 2, "uint", 4)
        Y -= 24, H_current += 28
    }
	else if (fullProcess ~= "ahk_exe POWERPNT\.EXE")
		X := -9, Y := -65, H_current += 55
	else if (fullProcess ~= "ahk_exe WINWORD\.EXE")
		H_current += 55
	else if (fullProcess ~= "Clock ahk_exe ApplicationFrameHost\.exe")
		H_current -= 1
	else if (fullProcess ~= "AutoHotkey Help ahk_exe hh\.exe")
		H_current -= 1
	else if (fullProcess ~= "ahk_exe Obsidian\.exe") {
		H_current -= 6, W-=8
		WinSet, Style, +0xC00000, ahk_exe Obsidian.exe
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist("ahk_exe Obsidian.exe")
        , "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_ENABLED := 2, "uint", 4)
	}
	if (H_arg != "") {
		if RegexMatch(H_arg, "\d+")    
			H_current := H_arg
		else
			dH_current += H_arg
	}
	winMove(fullProcess, X, Y, W, H_current)
}
Xbutton1 & Lbutton::
    return
$#space::
    KeyWait("LWin")
Xbutton1 & Rbutton::                ;media controller
	Send, !+7
	return
Media_Prev::
	Send, ^+8
	return
NumpadClear & n::
Media_Next::
	Send, ^+9
	return
$^+z::																;Redo
	Send, ^y
	return
#3::
	KeyWait("LWin")
	WinActivate, ahk_exe chrome.exe
	Sleep, 50
	Send, !+1
	return
#4::
	KeyWait("LWin")
	WinActivate, ahk_exe chrome.exe
	Sleep, 50
	Send, !+2
	return
#5::
	KeyWait("LWin")
	WinActivate, ahk_exe chrome.exe
	Sleep, 50
	Send, !+3
	return
$>+q::											;Generate QR Code
	KeyWait("RShift")
	ControlFocus,, A
	Send ^a
	Send, ^c
	ClipWait, 1.5
	run, % "C:\0. Coding\ahkRepos\QR Generator.ahk"
	WinWaitActive, QR Generator.ahk
	Send, 10
	Send, {enter}
	Sleep 500
	Send, ^v
	Send, {enter}
	WinWaitActive, Success
	Send, {enter}
	return
$#z::
	KeyWait("LWin")
	escaped := WinClip.Copy()
	WinClip.Paste(escapeVar(escaped))
	freeMem("escaped")
	return
NumpadClear & z::												;Add/remove quotes
	KeyWait("LWin")
	if WinActive("ahk_exe Code.exe") 
        Send, +'
    else {
        if !WinActive("ahk_exe anki.exe")
            vText := WinClip.Copy()
        else {
            Send, ^c
            Sleep, 150
            vText := clipboard
        }
        vText := """" Trim(vText, """") """"
        WinClip.Paste(vText)
        if WinActive("Google ahk_exe chrome.exe")
            Send, {enter}
    }
	return
$!6::
	if GetKeyState("Xbutton2", "P")
        vText := WinClip.Copy()
	if WinExist("ahk_exe Everything.exe") {
		WinActivate, ahk_exe Everything.exe
	} else {
		run, % "C:\Program Files\Everything\Everything.exe"
		WinWait, ahk_exe Everything.exe
		WinActivate, ahk_exe Everything.exe
		Sleep, 500
	}   
    Send, ^f
	leftPattern()
    if vText
        WinClip.Paste(vText)
    freeMem("vText")
	return
$#w::
	KeyWait("LWin")
	WinMinimize, A
	return
$!F7::
	KeyWait("LAlt")
	ControlFocus,, YouTube - Cent Browser ahk_exe chrome.exe
	ControlSend,, {shift Down}n{shift Up}, YouTube - Cent Browser ahk_exe chrome.exe
	return
$>!b::
	KeyWait("RAlt")
	run, % "ms-settings:connecteddevices"
	WinWait, Settings ahk_class ApplicationFrameWindow
	obj := objUIA("Settings ahk_class ApplicationFrameWindow")
	Sleep, 1000
	obj.FindAllByName("More options")[2].click()
	obj.WaitElementExist("Name=Connect || Name=Disconnect").click()
	Sleep, 1000
	obj.WaitElementExist("Name=Paired || Name=Connected voice, music && Type=Text")
	; Sleep, 100
	; if !GetKeyState("LCtrl", "P")
		; WinClose, Settings ahk_class ApplicationFrameWindow
	return
!WheelDown::
	if !WinActive("ahk_exe Code.exe")
		SendEvent, {WheelDown 3}
	else
		SendEvent, {WheelDown 5}
	return
!WheelUp::
	if !WinActive("ahk_exe Code.exe")
		SendEvent, {WheelUp 3}
	else
		SendEvent, {WheelUp 5}
	return
;6:: ;WheelUp
;7:: ;WheelDown
	MouseGetPos, vPosX, vPosY, hWnd, hCtl, 2
	if hCtl
		hWnd := hCtl
	vNum := 1
	if InStr(A_ThisHotkey, "7")
		vNum *= -5 ;negative means Downwards
	PostMessage, 0x20A, % vNum<<16, % vPosX|(vPosY<<16),, % "ahk_id " hWnd ;WM_MOUSEWHEEL := 0x20A
	return
$^+F1::
	KeyWait("LCtrl, LShift")
	X := -12, Y := -5, W := 1364
	if WinActive("ahk_exe sublime_text.exe") {
		Send, ^f
	} else if WinExist("ahk_exe sublime_text.exe") {
		WinActivate, ahk_exe sublime_text.exe
		leftPattern()
		Send, ^f
	} else {
		run, "C:\Program Files\Sublime Text\sublime_text.exe" "C:\0. Coding\ahkRepos\Banana's Script.ahk"
		WinWait, ahk_exe sublime_text.exe
		Sleep, 100
		leftPattern()
		Send, ^f
		;if !(X=-9 and Y=-12 and W=1361 and H=1041)
	}
	return
$<+Rbutton::
	KeyWait("LShift")
	X := -14, Y := -12, W := 1358
	if WinActive("ahk_exe Code.exe") {
        if (winGet("pos", "ahk_exe Code.exe") = "1207, -45, 874, 1072")
            return
		leftPattern()
		Send, ^f
	} else if WinExist("ahk_exe Code.exe") {
        WinActivate, ahk_exe Code.exe
            ; Msgbox, % "hahah"
		;WinSet, ExStyle, +0x80, ahk_exe Code.exe
		; disableCloseButton(WinExist("ahk_exe Code.exe"))
	} else {
		run, % vscPath
		WinWait, ahk_exe Code.exe
		WinActivate, ahk_exe Code.exe
		Sleep, 100
		leftPattern()
		; disableCloseButton(WinExist("ahk_exe Code.exe"))  ;need to do closing twice if this is on
		Send, ^f
		;if !(X=-9 and Y=-12 and W=1361 and H=1041)
	}
	return
NumpadMult::
	KeyHistory
	WinWaitActive, C:\0. Coding\ahkRepos\Banana's Script.ahk ahk_exe AutoHotkeyU64.exe
	Sleep, 100
	Send, ^{End}
	return
$#Lbutton::
	KeyWait("LWin")
	MouseGetPos,,, win
	WinSet, Transparent, 0, ahk_id %win%
	WinSet, Transparent, 255, ahk_id %win%
	return
$!+a::									;Run a link or Google Search adaptibly
	KeyWait("LAlt, LShift", "P")
	dynamicRun()
	return
dynamicRun(inputURL := "") {
	if (inputURL = "") { 
		if !WinActive("ahk_exe anki.exe") 
			inputURL := WinClip.Copy()
		else {
			Send, {Ctrl Down}c{Ctrl Up}	
			Sleep, 250
			inputURL := clipboard
		} 
		if !inputURL
			Msgbox, % "Can't copy the query!"
	}
	inputURL := RegexReplace(inputURL, "^\s+|\s+$") 	;Trim leading and trailing spaces and tabs
	if (inputURL ~= "^[\w.-+]+@[\w.-+]+\.[a-zA-Z]{2,62}$")							 ;Email
		Msgbox, % "this is an email!"
	else if (inputURL ~= "i)https?://|www\.|\.com")					 ;HTTP/HTTPS
		run, "%centPath%" "%inputURL%"
	else if (inputURL ~= "i)^[\w-]+://") 			  ;other URI schemes
		runURL(inputURL)
	else {															 ;String
		encodedURL := EncodeDecodeURI(inputURL) 
		run, "%centPath%" "www.google.com/search?q=%encodedURL%"
	}
}
$^!w::														;Verbatim Searching
	KeyWait("LCtrl, LAlt")
	if !WinActive("ahk_exe anki.exe") {
		clipboard := ""
		Send, ^c								;Copy current selection, continue if no errors.
		ClipWait, 2
	} else {
		Send, ^c
		Sleep, 100
	}
	if !(ErrorLevel) {
		clipboard := """" . clipboard . """"
		run, www.google.com/search?q=%clipboard%
	}
	return
$!+q::													;run titled/file URL on anki
	KeyWait("LAlt, LShift")
	if WinActive("ahk_exe Code.exe") || WinActive("ahk_exe chrome.exe") {
		Send, !+q
		return
	}
 	Send, ^c
	Sleep, 200
	wcHTML := WinClip.GetHTML()
	if matchURI := regexMatches(wcHTML, "i)href=""(https?.+?|file:///.+?)""",, 1)
		dynamicRun(matchURI)
	else
		Msgbox, % "no URI found!"
	wc.iClear(), freeMem("wcHTML, matchURI")
	return
$!+g::
	KeyWait("LAlt, LShift")
	Msgbox, % "Keystroke unasigned!"
	return
$!+e::										   ;run multiple URLs
	KeyWait("LAlt, LShift")       ;another method for reference: https://tinyurl.com/26sccvzr
	if !WinActive("ahk_exe Code.exe") {
        urlList := WinClip.Copy()
        urlList := RegexReplace(urlList, "^\s+|\s+$|")
        urlList := RegexReplace(urlList, "`t|`r`n|`, ?", "©")
        ;list are separated by `t/`r`n/comma_space/comma (add any if needed)
        loop, parse, urlList, ©
            dynamicRun(A_LoopField)
    }
    else
        Send, !+e
	return
;^Backspace::  				;Delete a word to the left of cursor
; ^!g::			;Windows Recorder
; 	KeyWait("LCtrl, LAlt")
; 	Send, #g
; 	Sleep, 500
; 	Send, #!r
; 	SoundBeep, 750, 500
; 	Sleep, 1000
; 	click, 920, 484
; 	return
` & 3::												;lowercase/TitleCase/UPPERCAS
	KeyWait("LShift")
    if WinActive("ahk_exe anki.exe") {
        Send, ^c
        Sleep, 200
        oldStr := clipboard
    } else
        oldStr := WinClip.Copy()
    ; leadingSpaces := regexMatches(oldStr, "(^\s+)",, 1)
    ; trailingSpaces := regexMatches(oldStr, "(\s+$)",, 1)
	if !(oldStr ~= "[A-Z]")                     ;lower
		newStr := Format("{:U}", oldStr)
	else if !(oldStr ~= "[a-z]")                ;upper
		newStr := Format("{:T}", oldStr)
	else                                        ;title
		newStr := Format("{:L}", oldStr)
    WinClip.Paste(newStr)
	; WinClip.Paste(leadingSpaces . newStr . trailingSpaces)
    ; freeMem("leadingSpaces, trailingSpaces, oldStr, newStr")
	return  
$+F4::
	KeyWait("LShift")
	clipboard := ""
	Send ^c
	ClipWait, 1.5
	text := clipboard
	nospace := StrReplace(text, A_Space)
	if %nospace% is lower
		return
>^LButton::														;MouseGetPos current
	KeyWait("RCtrl")
	MouseGetPos, varX, varY
	mousePos := varX ", " varY
	clipboard := mousePos
	toolTip(mousePos, 2000, varX, varY)
	return
>!LButton::														;WinGetPos current
	KeyWait("RAlt")
	WinGetPos, X, Y, W, H, A
	clipboard := X ", " Y ", " W ", " H
	toolTip(X " " Y " " W " " H, 2000, 985, 551)
	return
NumpadSub:: hideShowTaskbar(hide := !hide) ;https://www.autohotkey.com/boards/viewtopic.php?t=60866
hideShowTaskbar(action) {
	static ABM_SETSTATE := 0xA, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
	VarSetCapacity(APPBARDATA, size := 2*A_PtrSize + 2*4 + 16 + A_PtrSize, 0)
	NumPut(size, APPBARDATA), NumPut(WinExist("ahk_class Shell_TrayWnd"), APPBARDATA, A_PtrSize)
	NumPut(action ? ABS_AUTOHIDE : ABS_ALWAYSONTOP, APPBARDATA, size - A_PtrSize)
	DllCall("Shell32\SHAppBarMessage", UInt, ABM_SETSTATE, Ptr, &APPBARDATA)
	; if action
	; 	WinHide, ahk_class Shell_TrayWnd
	; else
	; 	WinShow, ahk_class Shell_TrayWnd
	Sleep, 600
	; For 
	leftPattern()
	GoSub, ankiMove
}
	return
$!1::
	KeyWait("LAlt")
	chromeanki:
	WinGet, vProcess, ProcessName, A
    H_chrome := 1041
    H_anki := 1065
    ; if WinExist("ahk_exe Code.exe")
        ; winMove("ahk_exe Code.exe", -14, -10, 1358, 1033)
    WinActivate, - Cent Browser ahk_exe chrome.exe
	GoSub, ankiMove
	DisableWindowMoving(WinExist("ahk_exe chrome.exe"))		;disable by sysmenu, not ahk commands
	DeleteWindowMaximizing(WinExist("ahk_exe chrome.exe"))
	if (vProcess = "anki.exe")
		WinActivate, ahk_exe anki.exe,, Browse ahk_exe anki.exe
	return
	ankiMove:
    if !(winGet("pos", "- Cent Browser ahk_exe chrome.exe") = "-9, -12, 1238, 1041") {
        winMove("- Cent Browser ahk_exe chrome.exe", -11, -12, 1363, H_chrome)
        W_anki := 1334, X_anki := 597
    } else
        W_anki := 1211, X_anki := 720
	winMove("Banana - Anki ahk_exe anki.exe", W_anki, -35, X_anki, H_anki)
    if WinExist("Add ahk_exe anki.exe")
        WinMove, Add ahk_exe anki.exe,, W_anki, -35, % X_anki, H_anki
    if WinExist("Edit Current ahk_exe anki.exe")
        WinMove, Edit Current ahk_exe anki.exe,, W_anki, -35, X_anki, 1065
    if WinExist("Statistics ahk_exe anki.exe")
        WinMove, Statistics ahk_exe anki.exe,, 1045, -4, 893, 1030
	; WinMove, Browse ahk_exe anki.exe,, 1210, -35, 740, % H_anki   ;conflict with b
    if WinExist("Preview ahk_exe anki.exe")
        WinMove, Preview ahk_exe anki.exe,, 1332, 230, 598, 803
    if WinExist("Card Types ahk_exe anki.exe")
        WinMove, Card Types ahk_exe anki.exe,, 966, -35, 962, 1028
	return
$!Rbutton::
$#1::
	if GetKeyState("Xbutton2", "P")
        WinActivate, Browse ahk_exe anki.exe
    else if !WinActive("ahk_exe anki.exe") {
        GoSub, ankiLabel
        ; soundPlay(A_Audio "\ggTTS\anki.activated.wav")						
    }
	return
	ankiLabel:
	if WinExist("ahk_exe anki.exe") {
        if WinExist("Add ahk_exe anki.exe")
            WinActivate, Add ahk_exe anki.exe
        else if WinExist("Edit ahk_exe anki.exe")
            WinActivate, Edit ahk_exe anki.exe
		else
            WinActivate, Banana - ahk_exe anki.exe
	} else {
		RunWait, C:\Program Files\Anki\anki.exe,, UseErrorLevel, PID
		WinWait, Banana - ahk_exe anki.exe
		Sleep, 3000
		soundPlay("C:\Windows\Media\notify.wav")
        while (winGet("pos", "Banana - ahk_exe anki.exe") != "1334, -35, 597, 1065")
		    WinMove, Banana - ahk_exe anki.exe,, 1334, -35, 597, 1065
        soundPlay("C:\0. Coding\ahkRepos\Audio\Red Alert 2\Unit ready - ceva062.wav")
 	}
	return
$#2::
    WinActivate, ahk_exe chrome.exe
    return
$!w::
	KeyWait("LAlt")
	if WinActive("Task Manager - Cent Browser ahk_exe chrome.exe")
		WinClose, A
	else if WinActive("ahk_exe chrome.exe") {
        if (WinActive("ahk_exe chrome.exe")==uCent.BrowserId)
            WinMinimize, A
        else 
            WinClose, A
    }
    else if WinActive("ahk_exe Code.exe") || WinActive("ahk_exe Obsidian.exe")
        WinMinimize, A
	else if WinActive("ahk_exe FxSound.exe")
		WinHide, ahk_exe FxSound.exe
	; else if WinActive("GTAIV ahk_exe GTAIV.exe")
	; 	Msgbox, % "hehe"
	else 
		Send, !{F4}
	return

$!4::													;Maximize/Minimize Window
	KeyWait("LAlt")
NumpadClear & Mbutton::
	MouseGetPos,,, winID
	WinGet, status, MinMax, ahk_id %winID%
	if !WinActive("ahk_id " winID)
		WinActivate, ahk_id %winID%
	if WinActive("ahk_exe Obsidian.exe") {
		WinSet, Style, +0xC00000, ahk_exe Obsidian.exe
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist("ahk_exe Obsidian.exe")
        , "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_ENABLED := 2, "uint", 4)
	}
	else if WinActive("ahk_exe Code.exe") {
		WinSet, Style, +0xC00000, ahk_exe Code.exe
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", WinExist("ahk_exe Code.exe")
        , "uint", DWMWA_NCRENDERING_POLICY := 2, "int*", DWMNCRP_ENABLED := 2, "uint", 4)
	}
	if !(status = 0) {
		PostMessage, 0x0112, 0xF120,,, ahk_id %winID%		;WinRestore
		WinMaximize, ahk_id %winID%
	} else
		WinMaximize, ahk_id %winID%
	return
NumpadClear & Rbutton::
	; terminal := "Cmder ahk_exe ConEmu64.exe"
	; terminalPath := "C:\cmder\vendor\conemu-maximus5\ConEmu64.exe"
	terminal := "ahk_exe WindowsTerminal.exe"
	terminalPath := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Terminal.lnk"
	X := -14, Y := -12, W := 1366
	if !WinExist(terminal) {
		run, % terminalPath 
		WinWait, % terminal
		Sleep, 500
        soundPlay(A_Audio "\ggTTS\terminal.launched.wav")
	}
	WinActivate, % "ahk_id " WinExist(terminal)
	leftPattern()
	return
$!2::												;Open AHK Help
    if GetKeyState("Xbutton2", "P") {
        if WinExist("AutoHotkey Help ahk_exe hh.exe") {
            WinActivate, AutoHotkey Help ahk_exe hh.exe
            leftPattern(,, -8)
            disableCloseButton(WinExist("AutoHotkey Help ahk_exe hh.exe"))
        } else {
            run, % "C:\Program Files\AutoHotkey\AutoHotkey.chm"
            WinWait, AutoHotkey Help ahk_exe hh.exe
            leftPattern(,, -8)
            disableCloseButton(WinExist("AutoHotkey Help ahk_exe hh.exe"))
        }
        click, 274, 81
        click, 223, 143, 0
        Send, ^a
    } else {
        if !WinActive("ahk_exe chrome.exe")
            WinActivate, ahk_exe chrome.exe
        vURL := uCent.GetCurrentURL()
        vTitle := winTitle(, "title")
        if !(vURL ~= "https://www\.autohotkey\.com/docs") {						;UIA can't query all tabs' URLs
            if Page := Cent.GetPageByURL("https://www.autohotkey.com/docs", "contains") {
                Page.Call("Page.bringToFront")
                Page.Disconnect()
            } else
                runURL("https://www.autohotkey.com/docs/v1/",, true)
        }
        if (uCent.GetCurrentURL() ~= "https://www\.autohotkey\.com/docs") {
            click, 262, 119
            click, 134, 171, 0
            Send, ^a
        }
        freeMem("vURL, vTitle")
    }
	return
Mbutton::
    if WinExist("ahk_exe anki.exe")
        WinSet, ExStyle, +0x80, ahk_exe anki.exe
	SendEvent, {Alt Down}{Tab Down}{Tab Up}{Alt Up}
	return
$#Mbutton::
	KeyWait("LWin")
	Msgbox, % "unassigned!"
	return
$+Mbutton::
	KeyWait("LShift")
	if WinActive("PowerPoint ahk_exe POWERPNT.EXE") and isVisible("ahk_exe POWERPNT.EXE")
		PostMessage, 0x0112, 0xF020,,, PowerPoint ahk_exe POWERPNT.EXE
	else if WinExist("PowerPoint ahk_exe POWERPNT.EXE") {	
		WinActivate, PowerPoint ahk_exe POWERPNT.EXE		
		WinWaitActive, PowerPoint ahk_exe POWERPNT.EXE,, 2
		if ErrorLevel {
			DetectHiddenWindows, On
			WinKill, ahk_exe POWERPNT.exe
		}
		leftPattern()														
	} else {
		run, "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE" "C:\0. Downloaded Programs\0. Powerpoint Center\0. New\P1.pptx"
		WinWait, PowerPoint ahk_exe POWERPNT.EXE
		WinActivate, PowerPoint ahk_exe POWERPNT.EXE
		Sleep, 3000
		leftPattern()
	}
	return
$!MButton::
	KeyWait("LAlt")
	if WinActive("Excel ahk_exe EXCEL.EXE")
		PostMessage, 0x0112, 0xF020,,, Excel ahk_exe EXCEL.EXE
	else if WinExist("Excel ahk_exe EXCEL.EXE")
		WinActivate, Excel ahk_exe EXCEL.EXE
	else
		run, % "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
	return
$^MButton::
	KeyWait("LCtrl")
	if WinExist("ahk_exe chrome.exe") {
		WinActivate, ahk_exe chrome.exe
		if !(winAt(1610, 607) ~= "Obsidian\.exe|Code\.exe")
            WinActivate, ahk_exe anki.exe
	} else {
		run, % centPath
		WinWaitActive, ahk_exe chrome.exe
		WinActivate, ahk_exe anki.exe
		DisableWindowMoving(WinExist("ahk_exe chrome.exe"))   
		DeleteWindowMaximizing(WinExist("ahk_exe chrome.exe"))  ;disable by sysmenu, not ahk commands
		Sleep, 1000
		GoSub, chromeanki
	}
    return
#s::	;Emoji
	KeyWait("LWin")
	Send, #`;
	return
$!+f::
    KeyWait("LAlt, LShift")
    bitmapPath := "C:\0. Coding\ahkRepos\Bitmap\bitmap_temp.png"
    WinClip.SaveBitmap(bitmapPath, "png")
    while !status := FileExist(bitmapPath)
        Sleep, 200
    run, "C:\Windows\System32\OpenWith.exe" "%bitmapPath%"
    WinWait, ahk_exe OpenWith.exe
    WinWaitActive, Snipping Tool ahk_exe ApplicationFrameHost.exe,, 10
    if ErrorLevel
        Throw, "Waiting terminated!"
    leftPattern("Snipping Tool ahk_exe ApplicationFrameHost.exe")
    return
$!f::											;Snip
	KeyWait("LAlt")
	Send, #+s
	return
$#f::														;Snip and save to desktop
	KeyWait("Lwin")
	Send, #+s
	WinWaitActive, Screen Snipping ahk_exe ScreenClippingHost.exe
	ClipWait, 5, 1
	if ErrorLevel {
		Msgbox,,, Can't clip image!, 1
		return
	}
	random := ComObjCreate("Scripting.FileSystemObject").GetTempName()    ;e.g. rad19599.temp
	random := RegExReplace(random, "\.tmp$")
	format := "png"     ;or bmp, jpeg, gif, tiff
	filePath := "C:\0. Coding\ahkRepos\Bitmap\" random "." format
	WinClip.SaveBitmap(filePath, format)
	while !status := FileExist(filePath)
		Sleep, 200
	run, % filePath
	freeMem("random, format, filePath")
	return
		
$+F2::
	KeyWait("LShift")
	Send, #{PrintScreen}
	SoundBeep
	return
$!space::
	Send, {delete}
	return
$^space::
	Send, {Backspace}
	return
$#+a:: 												 ;Always on top
	KeyWait("LWin, LShift")
	Soundbeep, 500, 300
	Winset, AlwaysOnTop,, A
	WinGet, win, ID, A
	WinGet, ExStyle, ExStyle, ahk_id %win%
	if (ExStyle & 0x8)
		ExStyle = On AlwaysOnTop
	Else
		ExStyle = Off AlwaysOnTop
	ToolTip, %exstyle%, 873, 530
	Sleep, 1500
	ToolTip
	return
$!a::
	Send, {Alt Down}{left}{Alt Up}
	return
$!s::
	Send, {Alt Down}{right}{Alt Up}
	return
$!z::
	Send, {home}
	return
$!x::
	Send, {end}
	return
$^!x::
	Send, ^{End}
	return
$^!z::
	Send, ^{home}
	return
$!+x::										;Select All to the right
	Send, +{end}
	return
$!+z::										;Select All to the left
	Send, +{home}
	return
$!++::
    Send, ^+{Up}
    return
$!+-::
    Send, ^+{Down}
    return
$>!.::												;Decrease Volume
	;CoordMode, ToolTip
	;soundset, -5
	;SetFormat, float, 2.0
	;soundget, volume
	;ToolTip , Volume is %volume%, 985, 551
	;SetTimer, RemoveToolTip, -2000
	SendEvent, {Volume_Down}
	soundset, -2
	return
$>!;::												;Increase Volume
	;CoordMode, ToolTip
	;SetFormat, float, 2.0
	;soundget, volume
	;ToolTip , Volume is %volume%, 985, 551
	;SetTimer, RemoveToolTip, -2000
	SendEvent, {Volume_Up}
	soundset, +2
	return
$>!'::
	SoundSet, 0
	SetFormat, float, 2.0
	soundget, volume
	TrayTip, Mute, Volume is %volume%, 2
	return
$>!/::											;Volume Status
	SetFormat, float, 2.0
	soundget, volume
	ToolTip , Volume is %volume%, 985, 551
	; SetTimer, RemoveToolTip, -2000
	return

;;;;;;;;;;;;;;;;;;;;;;;;;clipboard
!=::
	Send, ^c
	StringUpper clipboard, clipboard, T
	Send, ^v
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Paragraph generating

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Hotstring - Universal Box Incorporation
#if WinActive("Universal Box ahk_exe AutoHotkeyU64.exe")
:*:mes::
	WinClose, A
	run, % "https://www.facebook.com/messages/t/100007585009451/"
	return
:*:peak::
	WinClose, A
	run, % "https://www.youtube.com/playlist?list=PLj6hqdcjhUHugv_9XBS5SfHu0wLTYvU9A"
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 	HotstringArea
#ifWinActive
;;;;;;;;;;;										SQLarea
::.select::SELECT
::.rollback::ROLLBACK
::.order by::ORDER BY
;;;;;;;;;;;                                     Patharea
:*X:.now.::Send, %A_Hour%h%A_Min%~%A_DD%-%A_MM%-%A_YYYY%
:*:.evkey::C:\0. Downloaded Programs\EVKey\EVKey64.exe
:*:.desktop::{raw}C:\Users\zlegi\Desktop
:*:.vsc::{raw}C:\Users\zlegi\AppData\Local\Programs\Microsoft VS Code\Code.exe
:*:.py::C:/0. Downloaded Programs/0. AHK Directory/0. Coding/pyRepos
:*:.cent::
	if !WinActive("Banana's Script.ahk ahk_exe Code.exe")
		WinClip.Paste("""C:\Users\zlegi\AppData\Local\CentBrowser\Application\chrome.exe""")
	return
:*:bnn::
	if WinExist("Open ahk_exe chrome.exe") {
		WinClip.SetText("C:\0. Coding\ahkRepos\Banana's Script.ahk")
		WinClip.Paste()
	}
	return
:*:.lib::C:\0. Coding\ahkRepos\Lib
;;;;;;;
:*:.pls::programming languages
:*?:ccc::
	SetTitleMatchMode, regex
	if WinActive("ahk_exe Code.exe") || WinActive("Sublime Text ahk_exe sublime_text.exe")
		Send, NumpadClear &{space}
	else if WinActive("i)(Godogle|New Tab) ahk_exe chrome.exe")
		Send, computing{enter}
	else if WinActive("ahk_exe anki.exe") {
		WinClip.SetHTML("<b><span style=""color: rgb(0, 0, 255);"">caps&nbsp</span></b>")
		WinClip.Paste()
	} else if WinActive("ahk_exe Obsidian.exe")
		Send, {text}|ctr|400
	else 
		Send, {text}ccc
	return
:*:@cc::©
:*:@4::export9@hxcorp.com.vn{tab}
:*:@5::84379004481{tab}
:*:@6::We bring you our high-quality supply of incense sticks from Vietnam{tab}
:*:@7::Hang Xanh Co., LTD{tab}
;;;;;;;
:*:hreff::
	Send, {text} <a href="url">text</a>
	if WinActive("ahk_exe anki.exe") {
		Send, +{end}
		Send, {delete}
	} else
		return
:*:@1::zlegioncommanderz@gmail.com
:*:@2::71802213@student.tdtu.edu.vn
:*:@3::conghao2509@gmail.com
:*:ppp::powerpoint
;:*:dont::don't
;:*:doesnt::doesn't
:*:qqq::
	BlockInput, on
	WinClip.Paste("wiki")
	Send, {enter}
	BlockInput, off
	return
:*:sss ::
	BlockInput, on
	WinClip.Paste("stackoverflow")
	Send, {enter}
	BlockInput, off
	return
;:*:cant::can't
;:*:wont::won't
;~ emojis
:*:#cc::
	WinClip.Paste("✅")
	return
:*:#xx::
	WinClip.Paste("❌")
	return
:*:#ff::							;Flushed Face
	WinClip.Paste("😳")
	return
:*:#oops::							;Face with Hand Over Mouth
	WinClip.Paste("🤭")
	return
:*:#sf::							;Sneezing Face
	WinClip.Paste("🤧")
	return
:*:#tu::👍							
;~									;SpecialChars
:*:hhh::autohotkey{enter}
; :*:@a ::{U+00E6}
; :*:@d ::{U+00F0}
; :*:@f ::{U+0283}
; :*:@g ::{U+0292}
; :*:@i ::{U+026A}
; :*:@o ::{U+03B8}
; :*:@t ::{U+0074}{U+0302}
; :*:@u ::{U+028A}
; :*:@x ::{U+028C}
:*:ʊ::{U+028A}
:*:@ss::{U+2282}
:*:-]::{U+2191}     ;↑
:*:-[::{U+2193}		;↓
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	   #ifArea 
#if !GetKeyState("Xbutton2", "P")
NumpadClear::Enter  
; NumpadClear::											;Disable NumpadClear Native Function
; 	if !GetKeyState("Xbutton2", "P")
; 		Send, {Enter}
; 	return
#if WinActive("ahk_exe WindowsTerminal.exe")            ;terminalarea
$^w::
    KeyWait("LCtrl")
    Send, ^+w
    return
$!+s::
    KeyWait("LAlt, LShift")
    Send, ^,
    return
$!e::
    KeyWait("LAlt")
    Send, ^+p
    return
$!c::
    KeyWait("LAlt")
    Send, ^+2
    return
#if (WinActive("ahk_exe anki.exe") || WinActive("ahk_exe Obsidian.exe")) && (winAt(552, 536, "title") ~= "Coursera - Cent Browser|LinkedIn Learning - Cent Browser|YouTube - Cent Browser")
NumpadClear & d::
Xbutton1 & WheelUp::
	ControlFocus,, Cent Browser ahk_class Chrome_WidgetWin_1
	ControlSend,, {right}, Cent Browser ahk_class Chrome_WidgetWin_1
    sleep, 200
	return
NumpadClear & a::
Xbutton1 & WheelDown::
	ControlFocus,, Cent Browser ahk_class Chrome_WidgetWin_1
	ControlSend,, {left}, Cent Browser ahk_class Chrome_WidgetWin_1
    sleep, 200
	return
#if WinActive("ahk_exe anki.exe") && WinExist("LinkedIn Learning - Cent Browser ahk_class Chrome_WidgetWin_1")
; Xbutton2 & WheelUp::
; 	ControlFocus,, Cent Browser ahk_class Chrome_WidgetWin_1
; 	ControlSend,, {right}, Cent Browser ahk_class Chrome_WidgetWin_1
; 	return
; Xbutton2 & WheelDown::
; 	ControlFocus,, Cent Browser ahk_class Chrome_WidgetWin_1
; 	ControlSend,, {left}, Cent Browser ahk_class Chrome_WidgetWin_1
; 	return
#if WinActive("ahk_exe anki.exe") && WinExist("YouTube Cent Browser ahk_class Chrome_WidgetWin_1")
; Xbutton2 & WheelUp::
; 	ControlFocus,, Cent Browser ahk_class Chrome_WidgetWin_1
; 	ControlSend,, {right}, Cent Browser ahk_class Chrome_WidgetWin_1
; 	return
; Xbutton2 & WheelDown::
; 	ControlFocus,, Cent Browser ahk_class Chrome_WidgetWin_1
; 	ControlSend,, {left}, Cent Browser ahk_class Chrome_WidgetWin_1
; 	return

; ::a::                  
; a::
; 	uCentInst(true)       ;hotkey label doesn't work well with 
; 	searchBox := uCent.FindFirstBy("Name=Search && ControlType=ComboBox")
;     if (searchBox.HasKeyboardFocus=1)
;         Send, a
;     else
;         Send, {left}
; 	return
; d::
; 	uCentInst(true)
; 	searchBox := uCent.FindFirstBy("Name=Search && ControlType=ComboBox")
;     if (searchBox.HasKeyboardFocus=1)
;         Send, d 
;     else 
;         Send, {right}
; 	return
#if WinActive("ahk_exe PomoDoneApp.exe")
$^b::
	Send, ^n
	return
#if WinActive("ahk_exe Obsidian.exe")						;obsarea
$^+v::	
	KeyWait("LCtrl, LShift")
	clipboard := RegExReplace(clipboard, "`a)\n")
	WinClip.Paste()
	Return
; ` & c::						;toggle checkbox status
; 	KeyWait("``")
; 	Send, ^j
; 	return
` & q::
	KeyWait("``")
	Send, ^+u
	return
` & w::
	KeyWait("``")
	Send, ^+y
	return
$^!a::
	Send, !{Up}
	return
$^!s::
	Send, !{Down}
	 
NumpadClear & r::	
	Send, !g
	soundbeep
	return
; NumpadClear & ::
	Send, {Rbutton}
	obs := objUIA("ahk_exe Obsidian.exe")
	obs.WaitElementExistByNameAndType("Delete", "Text").click()
	return
$!c::
	KeyWait("LAlt")
	Send, !c
	; WinClip.Copy()
	; WinClip.Paste("``````" clipboard "``````")
	return
NumpadClear & WheelDown::
	Send, {Ctrl Down}{Shift Down}{Tab}{Ctrl Up}{Shift Up}
	Sleep, 50
	return
NumpadClear & WheelUp::
	Send, {Ctrl Down}{Tab}{Ctrl Up}
	Sleep, 50
 	return
NumpadClear & c::
	soundbeep,, 200
	Send, ^e
	return
#if WinExist("- YouTube - Cent Browser ahk_exe chrome.exe")
NumpadClear & x::
	KeyWait("LShift", "P")
Xbutton1::
	elementToggle("ytp-play-button ytp-button",, "class")
	return
#if WinExist("Coursera ahk_exe chrome.exe")
NumpadClear & x::
	KeyWait("LShift")
Xbutton1::
    if WinActive("ahk_exe anki.exe")
        ankiActive := true
    else if WinActive("ahk_exe Obisidan.exe")
        obsActive := true
	elementToggle("main#main span.cif-2x.cif-fw.cif-play"
	, "main#main span.cif-2x.cif-fw.cif-pause")
    if (ankiActive = true)
        WinActivate, ahk_exe anki.exe
    else (obsActive = true)
        WinActivate, ahk_exe Obsidian.exe
	return
#if WinExist("LinkedIn Learning ahk_exe chrome.exe")
NumpadClear & x::
	KeyWait("LShift")
Xbutton1::
	elementToggle("button[class='vjs-play-control vjs-control vjs-button vjs-paused'][title=Play]"
	, "button[class='vjs-play-control vjs-control vjs-button vjs-playing'][title=Pause]")
	return
#if (winAt(1838, 970)="ahk_exe ShellExperienceHost.exe")
Esc::
	MouseGetPos, xPos, ypos
	SendMode, Event
	SetMouseDelay, 2
	click, 1519, 785, 0
	BlockInput, On
	Sleep, 2000
	BlockInput, Off
	click, 1753, 959
	click, %xpos%, %ypos%, 0
	return
#if WinExist("ahk_class TARGETRECT") || WinExist("ahk_class FULLSCREEN")     ;while recording
; ` & 1::
; 	KeyWait("``")
; 	; Msgbox, % "haha"
; 	Send, {vkA4sc038 Down}{vkA0sc02A Down}{vk76sc041}{vkA4sc038 Up}{vkA0sc02A Up}
; 	return
; ` & 2::
; 	KeyWait("``")
; 	Send, ^+{vk76sc041}
; 	return
#if WinExist("ahk_class Shell_LightDismissOverlay") ;clipboard Manager class exist but not active
c::
	Send, {vk26sc148}
	return
v::
	Send, {vk28sc150}
	return
#if WinActive("Banana's Script.ahk - AutoHotkey v1.1.34.03 ahk_class AutoHotkey") ;KeyHistory
!s::
	Send, ^k
	Sleep, 500
	Send, ^{End}
	return
!r::
	Send, {F5}
	return
#if WinExist("ahk_exe bdcam.exe")
#if WinActive("ahk_exe WindowsTerminal.exe")				;Terminalarea
:X:.app::Send, {text}Add-AppxPackage -Path "
:X:win::Send, {text}Add-WindowsPackage -Online -PackagePath "
:X:kb::Send, {text}Get-WindowsUpdate -Install -KBArticleID '
;;
#if WinActive("Cmder ahk_exe ConEmu64.exe")
$!w::
	KeyWait("LAlt")
	Winset, Exstyle, +0x80, Cmder ahk_exe ConEmu64.exe
	WinHide, Cmder ahk_exe ConEmu64.exe
	return
$^b::
	Send, ^t
	return
#if WinActive("ahk_exe anki.exe") && WinExist("Cent Browser ahk_exe chrome.exe")   ;ankicent
$^b::
    WinActivate, Cent Browser ahk_exe chrome.exe
	Sleep, 60
    send, ^b
    return
NumpadClear & WheelDown::
	WinActivate, Cent Browser ahk_exe chrome.exe
	Sleep, 60
	Send, {Ctrl Down}{Tab}{Ctrl Up}
	return
NumpadClear & WheelUp::
	WinActivate, Cent Browser ahk_exe chrome.exe
	Sleep, 60
	Send, ^q
 	return
#if winCursor("Banana - Anki ahk_exe anki.exe")
Rbutton::
	if !WinActive("Banana - Anki ahk_exe anki.exe")
		WinActivate, Banana - Anki ahk_exe anki.exe
	Send, {space}
	return
#if WinActive("Banana - Anki ahk_exe anki.exe")			  	;deck2 (review page)
$!d::
    KeyWait("LAlt")
    soundPlay("*48")
    return
t::
    if !WinExist("YouTube ahk_exe chrome.exe") || winCursor("Banana - Anki ahk_exe anki.exe") 
        Send, t
    else {
        WinActivate, ahk_exe chrome.exe
        Send, t
    }
    return
$!space::									;Delete card
	KeyWait("LAlt")
	Send, ^{delete}
	return	
NumpadClear & k::
	PixelGetColor, pixel, 1439, 656
	if (pixel = "0x3A3838")
	Send, !{F4}
	return
$^+a::
	KeyWait("LCtrl, LShift")
	Send, ^+a
	WinWaitActive, Add-ons ahk_exe anki.exe
	WinMove, Add-ons ahk_exe anki.exe,, 1334, -35, 597, 1065
	return
$^Enter::
	KeyWait("LCtrl")
	Send, ^{Enter}
	WinActivate, ahk_exe anki.exe,, Browse ahk_exe anki.exe
	return
#if WinActive("Browse ahk_exe anki.exe")		    ;Browsearea
:?*X:.dd::Send, deck:_*{enter}{space}        ;all
:?*X:.ss::Send, deck:current{enter}{space}   ;current deck
:?*X:.nn::Send, "deck:myEncyclopedia::2. Natural Sciences::Biology"{Enter}{space}
:?*X:.ee::Send, deck:English{Enter}{space}
:?*X:.cc::Send, "deck:myEncyclopedia::1. Formal Sciences-Engineering::0. Computing"{Enter}{space}
$!w::
	KeyWait("LAlt")
	WinSet, Bottom,, Browse ahk_exe anki.exe
	WinActivate, ahk_exe anki.exe
	return
$!4::
	KeyWait("LAlt")
t::
	Send, {vk54sc014d}
	return
NumpadClear & Mbutton::
	WinGetPos, xBrowse,, wBrowse, hBrowse, Browse ahk_exe anki.exe
	if (wBrowse=750) {
		addSize := 100
		newX := 1210-addSize
		newW := 750+addSize
		WinRestore, Browse ahk_exe anki.exe
		WinMove, Browse ahk_exe anki.exe,, % newX,, % newW,,
		WinSet, Region, 133-0 W%newW% H%hBrowse%, Browse ahk_exe anki.exe
	} else if !(wBrowse=750) {	
		WinRestore, Browse ahk_exe anki.exe
		WinMove, Browse ahk_exe anki.exe,, 1210,, 750,,
		WinSet, Region, 133-0 W750 H%hBrowse%, Browse ahk_exe anki.exe
	}
	return
$^+space::
	KeyWait("LCtrl, LShift")
	Send, ^{Delete}
    if WinActive("ahk_exe Code.exe")
        Send, {BackSpace}
	return
$^Enter::
	KeyWait("LCtrl")
	WinMinimize, Browse ahk_exe anki.exe
	WinActivate, ahk_exe anki.exe
	return
$!s::
	KeyWait("LAlt")
	WinMinimize, Browse ahk_exe anki.exe
	WinActivate, ahk_exe anki.exe,, Browse ahk_exe anki.exe
	return
#if WinActive("Banana - Anki ahk_exe anki.exe") && !ankiPixelColor("0xFFFEFF") 		;deckarea
;&& ankiPixelColor("0x3A3838")
d::
    sleep, 100
    send, d
    sleep, 100
    return
`::
	Send, /
	return
c::
	ankiClick("Computing", "Hyperlink")
	return
$+c::
	Send, /
	WinWaitActive, Study Deck,, 2
	WinClip.Paste("IT Fundamentals")
	Send, {enter}
	return
z::
	ankiClick("Business Analyst", "Hyperlink",, true)
	return
$+z::   
    ankiClick("Business Analyst", "Hyperlink")
    return
x::
	ankiClick("Project Management", "Hyperlink")
	return
w::
	ankiClick("SQL - RDBMS", "Hyperlink")
	return
q::
	ankiClick("Quotes - Communication", "Hyperlink")
	return
i::
	ankiClick("Interview", "Hyperlink")
	return
p::
	Send, /
	WinWaitActive, Study Deck,, 2
	WinClip.Paste("Psychology")
	Send, {enter}
	return
$+t::
    KeyWait("LShift")
    ankiClick("Terminal", "Hyperlink")
    return
$+n::   
    KeyWait("LShift")
	ankiClick("Biology", "Hyperlink")
	return
n::
	ankiClick("Neurobiology-Neuroscience", "Hyperlink")
	return
j::
	ankiClick("HTML-CSS-JS-webDev", "Hyperlink")
	return
o::
	ankiClick("Obsidian", "Hyperlink")
	return	
r::
	ankiClick("R - Python", "Hyperlink")
	return
g::
	ankiClick("Graphic Design", "Hyperlink")
	return
$+d::
	KeyWait("LShift")
	ankiClick("Data Science-AI", "Hyperlink")
	return
$+a::
	Send, /
	WinWaitActive, Study Deck,, 2
	WinClip.Paste("Autohotkey")
	Send, {enter}
	return
v::
	ankiClick("Microsoft Office-VBA", "Hyperlink")
	return
f::
	Send, /
	WinWaitActive, Study Deck,, 2
	WinClip.Paste("food")
	Send, {enter}
	return
m::
	ankiClick("Entertainment - Media", "Hyperlink")
	return
e::
    if !ankiPixelColor("0x3A3838") {
        Send, e
        WinWaitActive, Edit ahk_exe anki.exe,, 1
        Sleep, 250
        H_anki := 1065
        WinGetPos, X_anki,, W_anki,, Banana - Anki ahk_exe anki.exe
        winMove("Edit ahk_exe anki.exe", X_anki, -35, W_anki, H_anki)
    }
    else
        ankiClick("Eng_temp", "Hyperlink")
	return

$+e::
	ankiClick("Language Pronunciation", "Hyperlink")
	return
; #if WinActive("Banana - Anki ahk_exe anki.exe") &&  ;reviewArea  
a::
    if ankiPixelColor("0x3A3838")
        ankiClick("Autohotkey", "Hyperlink")
    else
        Gosub, ankiAdd
    return
    ankiAdd:
    Send, a
    WinWaitActive, Add ahk_exe anki.exe,, 1
    Sleep, 300
    H_anki := 1065
    WinGetPos, X_anki,, W_anki,, Banana - Anki ahk_exe anki.exe
    winMove("Add ahk_exe anki.exe", X_anki, -35, W_anki, H_anki)
    return
b::
browselabel:
    if WinExist("Browse ahk_exe anki.exe") {
        WinActivate, Browse ahk_exe anki.exe
        Sleep, 50
        Send, ^f
        Send, deck:current{Enter}
    } else {
        Send, b
        WinWaitActive, Browse ahk_exe anki.exe
        Sleep, 50
        Send, {tab}
        Send, {home}
        Send, +{tab}
        H_anki := 1065
        WinGetPos, X_anki,, W_anki,, Banana - Anki ahk_exe anki.exe
        winMove("Browse ahk_exe anki.exe", X_anki-124, -35, W_anki+153, H_anki)
        hideRegion("Browse ahk_exe anki.exe", 133, 0, W_anki+153, H_anki)
        WinSet, ExStyle, +0x80, Browse ahk_exe anki.exe
    }
	return
ankiClick(Name, controlType := "", enter := "{Enter}", disable = false) {
	; if GetKeyState("Lbutton", "P")
	; 	addMethod := true
	if GetKeyState("Xbutton2", "P")
		viewMethod := true
    if (WinActive("Banana - Anki ahk_exe anki.exe") && !ankiPixelColor("0x3A3838")) {
        if (disable = true)
            return
        Send, d
        while !ankiPixelColor("0x3A3838")
            Sleep, 100
    }
	if WinActive("ahk_exe anki.exe")
		ankiUIA := objUIA("A")
	else
		ankiUIA := objUIA("ahk_exe anki.exe")
	searchCriteria := "Name=" Name 
	if (controlType != "")
		searchCriteria .= " && ControlType=" controlType
	if (enter != "{Enter}")
		enter := ""
	if ankiElement := ankiUIA.WaitElementExist(searchCriteria,, 2, false, 1500) {
		ankiElement.click()
		Sleep, 70
		if (viewMethod != true)
			Send, % enter
		else
			return
	} else
		Msgbox, % "Can't find the element! Check if it's collapsed"
	if (addMethod=true) {
		Sleep, 200
		GoSub, ankiAdd
	}
}
ankiPixelColor(pPixel) {
	PixelGetColor, pixelAnki, 1414, 407
	return (pixelAnki=pPixel)        ;true if pixelAnki=pixelcolor else return false
}
#if WinActive("Change Deck ahk_exe anki.exe") || WinActive("Choose Deck ahk_exe anki.exe")
:*:tt::
    Send, biology{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:nn::
	Send, biology{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:ee::
	Send, english{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:ii::
	Send, Interview{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:zz::
	Send, Business An{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:ww::
	Send("SQL{100}{enter}")
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:xx::
	Send, Project Manag{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:rr::
	Send, R - Python{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:jj::
	Send, HTML{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:pp::
	Send, psychology{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:gg::
	Send, Graphic{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:mm::
	Send, Media{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
$+d::
	Sendevent, Data Science{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
$+a::
	Sendevent, Autohotkey{enter}
    Sleep, 300
    WinMinimize, Browse ahk_exe anki.exe
    sleep 100
    click, 1627, 451
	return
$+n::
	Send, Neuroscience{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:cc::
	Send, omputing{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:oo::
	Send, Obsidian{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:vv::
	Send, VBA{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return
:*:qq::
	Send, quotes{enter}
	Sleep, 300
	WinMinimize, Browse ahk_exe anki.exe
	sleep 100
    click, 1627, 451
	return								
#if WinActive("ahk_exe anki.exe")										;ankiarea
;;;; 										
ankitag(tagname, sendAfter:="") {         					;ankitags
	wcHTML := "<b><span style=""color: rgb(0, 0, 255);"">" tagname "</span></b>"
	WinClip.SetHTML(wcHTML)
	WinClip.Paste()
    if (sendAfter != "")
        Send, % sendAfter
    Send, ^r{space}
}
:X*:#vsc::ankitag("#vsc")
:X*:#webdev::ankitag("#webDev", "{Enter}")
:X*:#js::ankitag("#js")
:X*:#py::ankitag("#py")
:X*c:#sql::ankitag("#sql")
:X*c:#c::ankitag("#c")
:X*c:#ahk::ankitag("#ahk")
:X*c:#cmd::ankitag("cmd")
:X*c:#ps::ankitag("#ps")
:X*c:.vie::ankitag("vie")
:X*c:.eng::ankitag("eng")
:X*c:doit::ankitag("""do it""")
:X*c:111::ankitag("(1 usage)")
:X*c:222::ankitag("(2 usages)")
:X*c:333::ankitag("(1 phrase)")
:X*c:eee::ankitag("(1 example)")
:?:>=::{U+2265}		;>=
:?:<=>::{U+21D4}
:?:=>::{U+21D2}		;=>
:?:->::{U+2192}		;->
:?:<-::{U+2190}		;<-
;;;;
NumpadClear & b::
    Gosub, browselabel
    return
` & 2::                                         ;anki.pasteAsHTML
    vHTML := WinClip.GetHTML()
    vHTML := RegExReplace(vHTML, "Bahnschrift Light Condensed", "Bahnschrift Light")
    vHTML := regexMatches(vHTML, "s)(*ANYCRLF)<!--StartFragment-->\s*?(.+)\s*?<!--EndFragment-->",, 1)
    vHTML := RegExReplace(vHTML, "^\s+|\s+$")
    WinClip.Paste(vHTML)
    freeMem("vHTML")
    return
$^+c::
    KeyWait("LCtrl, LShift")
    Send, {Home}
    Send, ^+{End}
    return
$!g::									;anki.Change due date
	KeyWait("LAlt")
	Send, ^g
	return
$^1::
    KeyWait("LCtrl")
    GoSub, numberList
	return
$^tab::
	KeyWait("LCtrl")
	Send, {space 5}
	return
$!e::
	KeyWait("LAlt")
	ankiUIA := objUIA("Banana - Anki ahk_exe anki.exe")
	ankiELement1 := ankiUIA.WaitElementExist("Name=main webview && ControlType=Custom",, 2, false, 1000)
	ankiElement2 := ankiElement1.FindByPath("1.1.1").click("left")
	Send, {Enter}
	return
$!q::
	PixelSearch, p1, p2, 1352, 90, 1883, 458, 0x414141,, fast
	p1 := p1 + 10
	p2 := p2 + 12
	click, %p1% %p2%
	return
$^v::
	KeyWait("LCtrl")
	Send, ^v
	return
$^g::														;anki.Set due date
	KeyWait("LCtrl")
    if !WinExist("ahk_exe anki.exe")
        GoSub, browselabel
    else
        Send, b
	Send, b
	WinWaitActive, Browse ahk_exe anki.exe
	Send, ^+d
	WinWaitClose, Set Due Date
	WinMinimize, Browse ahk_exe anki.exe
	Sleep, 500
	if !winCursor("ahk_exe anki.exe")
		click, 1564, 483, 2
	else
		click, 2
	return
#+q::
	KeyWait("LAlt, LShift")
	Send, d
	WinActivate, Banana - Anki ahk_exe anki.exe
	Sleep, 50
	Send, /
	WinWaitActive, Study Deck
	Send, {text}z. Storage::School Area
	Send, {enter}
	Sleep, 300
	Send, {enter}
	return
;;;
$^+s::
    KeyWait("LCtrl, LShift")
    Send, ^r
    return
$^s::
    KeyWait("LCtrl")
	Send, ^r
	Send, {F7}
	Send, ^b
	return
$!+c::	
	KeyWait("LAlt, LShift")
	inputText := WinClip.Copy()
	formatText := "<span style=""color: rgb(255, 255, 255); background-color: rgb(0, 85, 255);""><b>" inputText "</b></span>"
	WinClip.SetHTML(formatText)
	WinClip.Paste()
	freeMem("inputText, formatText")
	return
$!+s::
	KeyWait("LAlt, LShift")
	if WinActive("Statistics ahk_exe anki.exe")
		WinMove, Statistics ahk_exe anki.exe,, 458, 97, 893, 870
	else {
		Send, t
		WinWaitActive, Statistics ahk_exe anki.exe
		Sleep, 1000
		WinMove, Statistics ahk_exe anki.exe,, 458, 97, 893, 870
	}
	return
$!w::
	KeyWait("LAlt")
    if WinActive("Add ahk_exe anki.exe") {
        WinClose, Add ahk_exe anki.exe,, , Banana - Anki
        WinWaitActive, Anki ahk_exe anki.exe,, 0.5
        Send, {tab}
    } else if !WinActive("Banana - Anki ahk_exe anki.exe")
        WinClose, A
	WinActivate, ahk_exe anki.exe,, Browse ahk_exe anki.exe
	return
NumpadClear & p::															;anki.Preview card
	Send, ^l
	WinWaitActive, Card Types ahk_exe anki.exe
	WinRestore, Card Types ahk_exe anki.exe
	WinMove, Card Types ahk_exe anki.exe,, 370, 86, 986, 867
	Sleep, 100
	click, 924, 223
	return
$^d::
	KeyWait("LCtrl")
	if !WinExist("ahk_exe anki.exe")
        GoSub, browselabel
    else
        Send, b
	WinWaitActive, Browse ahk_exe anki.exe
	Send, ^d
	WinWait, Change Deck ahk_exe anki.exe
	WinActivate, Change Deck ahk_exe anki.exe
	return
$!n::												;anki.Change note type
	KeyWait("LAlt")
	if !WinExist("ahk_exe anki.exe")
        GoSub, browselabel
    else
        Send, b
	Winwait, Browse ahk_exe anki.exe
	Sleep, 200.
	Send, ^+m
	return                                      
$!s::                                              ;anki.Save       
	KeyWait("LAlt")
    BlockInput, On
	Send, ^{enter}
	WinWait, Add ahk_exe anki.exe,, 1
    Sleep, 70
	WinClose, Add ahk_exe anki.exe
	; Sleep, 50
	; click, 1650, 449
	WinActivate, ahk_exe anki.exe,, Browse ahk_exe anki.exe
    BlockInput, Off
	return
$^Enter::

	KeyWait("LCtrl")
	Send, ^{enter}
	Sleep, 500
	WinClose, Add
	WinActivate, ahk_exe anki.exe
	return
$!+d::
	KeyWait("LAlt")
	Send, {delete}
	soundGenerator:
	Send, {F10}
	WinWait, AwesomeTTS ahk_exe anki.exe
	WinActivate, AwesomeTTS ahk_exe anki.exe
	Sleep, 100
	Send, ^v
	Send, ^{enter}
	return
$!d::
    KeyWait("LAlt")
	Send, ^c
	Sleep, 200
	vText := RegExReplace(clipboard, "m`n)\s*\n", "`, `r`n")
	ankiUIA := objUIA("A")
	if !ankiElement1 := ankiUIA.FindFirstBy("Name=Sound && ControlType=Text",, 2, false) {
		if !ankiElement1 := ankiUIA.FindFirstBy("Name=Front && ControlType=Text",, 2, false)
			Msgbox, % "Failed!" 
	}
	if !ankiElement2 := ankiElement1.FindByPath("P1.+1")
		Msgbox, % "Failed!"
	else
		ankiElement2.click()
	Send, ^a
	Send, {delete}
	GoSub, soundGenerator
	; vPath := ggTTS(vText, 83, "C:\Users\zlegi\AppData\Roaming\Anki2\Banana\collection.media")
	; clipboard := "[sound:" vText ".wav]"
	; soundPlay(vPath)
	freeMem("vText")
	return
#if WinActive("ahk_exe HD-Player.exe")
!a::
	Send, !a
	return
#if WinActive("ahk_class ConsoleWindowClass")
^v::
	KeyWait("LCtrl")
	Send {Raw}%clipboard%
	return
#if WinActive("AutoHotkey - Cent Browser ahk_exe chrome.exe")
$!e::
	Page := Cent.GetPage()
    Page.Call("Page.navigate", {"url": "https://www.autohotkey.com/docs/v1/"})
	return
#if WinActive("ahk_exe msedge.exe") ;edgearea
$^s::
	KeyWait("LCtrl")
	Send, ^w
	return
$^+s::
	KeyWait Ctrl
	KeyWait shift
	Send, !e
	Sleep, 200
	Send, s
	return
$^b::
	KeyWait("LCtrl")
	Send, ^t
	return
$^+c::
	KeyWait("LCtrl, LShift", "P")
	Send, ^+t
	return
$^+e::
	KeyWait("LCtrl, LShift")
	Send, ^t
	clipboard := "edge://extensions/"
	Send, ^v
	Sleep, 100
	Send, {enter}
	return
#if WinActive("TikTok ahk_exe msedge.exe")
;!a::
	WinMove, TikTok - Richard Wiley - ahk_exe msedge.exe,, -9, -12, 1361, 1041
	MouseGetPos, xPos, yPos
	click, 21, 7
	click, %xPos%, %yPos%, 0
	return
#if WinActive("iCloud Photos - Cent Browser")
space::
	SendEvent, {WheelDown 3}
	return
t::
	MouseGetPos, xPos, yPos
	click, 250, 116
	click, %xPos%, %yPos%, 0
	return
u::
	MouseGetPos, xPos, yPos
	click, 872, 154
	click, %xPos%, %yPos%, 0
	return
d::
	MouseGetPos, xPos, yPos
	click, 1098, 118
	click, %xPos%, %yPos%, 0
	return
f::
	MouseGetPos, xPos, yPos
	click, 983, 114
	click, %xPos%, %yPos%, 0
	return
a::													;Add to album
	click, 928, 116
	Sleep, 300
	click, 801, 382, 0
	return
#if WinActive("ahk_exe Everything.exe")			 	;Everythingarea
$^+c::
    KeyWait("LCtrl, LShift")
    clipboard := ""
    Send, ^+c
    ClipWait, 2
    if !ErrorLevel
        SoundBeep,, 500
    return
$!F1::
	KeyWait("LAlt")
	Send, ^+c
	Sleep, 150
    vscPath := StrReplace(A_AppData, "Roaming", "Local\Programs\Microsoft VS Code\Code.exe")
	run, "%vscPath%" "%clipboard%"
	WinActivate, ahk_exe Code.exe
	return
$!q::
	KeyWait("LAlt")         
	SendEvent, ^{Enter}            ;SendInput doesn't work
	WinWaitActive, ahk_exe Explorer.EXE
	leftPattern()
	return
#if WinActive("ahk_exe NOTEPAD.EXE")			 	;Notepad Area
$^w::
	Send, ^w
	return
$^s::
	Send, ^s
	return
;****************************************************
#if WinActive("ahk_exe EXCEL.EXE") || WinActive("ahk_exe WINWORD.EXE") || WinActive("ahk_exe POWERPNT.exe")

#if	WinActive("ahk_exe EXCEL.EXE")		 ;excelarea
NumpadClear & f::
	Send, ^+l
	return
$^1::
	Send, ^+l
	return
$!d::				;Insert a row above
	KeyWait("LAlt")
	Send, {Alt Down}{Alt Up}
	Sleep, 200
	Send, i
	Send, r
	return
NumpadClear & d::						;delete selected row(s)
	Send, +{space}
	Send, ^{-}
	return
$+WheelUp::
	SetScrollLockState, On
	SendInput {Left}
	SetScrollLockState, Off
	return
$+WheelDown::
	SetScrollLockState, On
	SendInput {Right}
	SetScrollLockState, Off
	return
^d::
	MouseGetPos, xPos, yPos
	click, 428, 148
	click, %xPos%, %yPos%
	return
$^w::
	Send, ^w
	return
$^s::
	Send, ^s
	return
!c::
	Send, !hfp
	return

;;; reviewed!
$!r::											;Remove formatting
	KeyWait("LAlt")
	Send, {Alt Down}{Alt Up}
	Send, eaf
	return
$!g::											;Merge cells and center
	KeyWait("LAlt")
	Send, {Alt Down}{Alt Up}
	Sleep, 600
	Send, hmc
	return
;***********************************************************************************************************
#if WinActive("ahk_exe POWERPNT.EXE") or WinActive("ahk_exe WINWORD.EXE") or WinActive("ahk_exe EXCEL.EXE")
$^!a::								;Increase Font Size
	Send, ^]
	return
$^!s::								;Decrease Font Size
	Send, ^[
	return
; $!t::
; 	KeyWait("LAlt")
; 	WinGetActiveTitle, title
; 	WinMove, %title%,, -9, -65, 1361, 1094
; 	return
#if WinActive("PowerPoint Slide Show - ahk_exe POWERPNT.EXE")
b::
	Send, p
	return
#if WinActive("PowerPoint ahk_exe POWERPNT.EXE")	 ; PowerPointArea
;reworked
$^+b::													;Bold
	KeyWait("LCtrl, LShift")
	Send, ^b
	return
$^b::													;New slide
	KeyWait("LCtrl")
	Send, ^m
	return
Mbutton::
	WinActivate, ahk_exe chrome.exe
	return
$!r::													;Format panel
	KeyWait("LAlt")
	Send, {Rbutton}					
	Sleep, 300
	Send, {up}{up}{enter}				
	return														
$!d::													;Duplicate
	Send, ^d
	return
$!c::													;Format painter
	KeyWait("LAlt")
	Send, ^+c
	return
$!v::													;Format painter
	KeyWait("LAlt")
	Send, ^+v
	return
$!a::													;Insert Textbox
	KeyWait("LAlt")
	MouseGetPos, xPos, yPos
	Send, {Alt Down}{Alt Up}
	Sleep, 100
	Send, n
	Send, sh
	Sleep, 400
	SetDefaultMouseSpeed, 2
	SendEvent, {click 405 432}
	SendEvent, {click %xPos% %yPos% }
	return
;;;;;;;;;;;;;
;!f::
;	Send, {Alt Down}{Alt Up}
;	Sleep, 300
;	Send, hvk
;	return
` & s::
	KeyWait("``")
	ppt := ComObjCreate("PowerPoint.Application")
	ppt.ActiveWindow.SlideShowWindows.Activate
	return
$+WheelUp:: ; scroll right
	if WinActive("ahk_class screenClass")
		return
	ppt := ComObjCreate("PowerPoint.Application")
	ppt.ActiveWindow.SmallScroll(0, 0, 1, 0)
	return
$+WheelDown:: ; scroll left
	if WinActive("ahk_class screenClass")
		return
	ComObjActive("PowerPoint.Application").ActiveWindow.SmallScroll(0, 0, 0, 1)
	;ppt := ComObjCreate("PowerPoint.Application")
	;ppt.ActiveWindow.SmallScroll(0, 0, 0, 1)
	return
$^d::								;Draw/Pen
	KeyWait("LCtrl")
	Send, {Alt Down}{Alt Up}
	Sleep, 300
	Send, jig
	Send, {right 5}{left 1}{enter}
	; Sleep, 300
	; MouseGetPos, x, y
	; SendEvent {click 290, 67}
	; click, %x%, %y%, 0
	SoundBeep
	return
$^q::
	KeyWait("LCtrl")
	Send, {Alt Down}{Alt Up}
	Sleep, 300
	Send, hvk
	return
!s::										;Open Selection Pane
	Send, {Alt Down}{Alt Up}
	Sleep 300w
	Send, h
	Send, g
	Send, p
	return
!6::							;Emoji
	Send, !
	Sleep 500
	Send, ny2
	return
!+6::							;Emoji
	Send, !
	Sleep 500
	Send, ny2
	return
!+5::							;Add Section
	Send, !
	Sleep, 500
	Send, ht1a
	return
!+4::
	Send, !
	Sleep, 500
	Send, ac
	return
!+3::							;Crop
	Send, !
	Sleep, 500
	Send, jivc
	return
;$!4::							;Bring Forward
	Sleep, 300
	Send, {Alt Down}{Alt Up}
	Sleep, 300
	Send, hgr
	return
;$!3::							;Bring Backward
	Sleep, 300
	Send, {Alt Down}{Alt Up}
	Sleep, 300
	Send, hgk
	return
^+::												;Open/hide note
	Send, ^+h
	return
$+space::									;Slideshow
	KeyWait("LShift")
	Send, +{f5}
	return
#space::
	Send, {f5}
	return
^!z::
	Send, ^[
	return
^!a::
	Send, ^]
	return
$^w::
	Send, ^w
	return
$^s::
	Send, ^s
	return
^1::
	Send, !h
	Sleep, 200
	Send, {Space}
	return
^2::
	Send, !n
	Sleep, 200
	Send, {Space}
	return
^3::
	Send, {Alt Down}{Alt Up}
	Send, a
	Sleep, 200
	Send, {Space}
	return
^4::
	Send, {Alt Down}{Alt Up}
	Send, k
	Sleep, 200
	Send, {space}
	return
^5::
	Send, {Alt Down}{Alt Up}
	Send, s
	Sleep, 200
	Send, {space}
	return
^6::
	Send, !g
	Sleep, 200
	Send, {space}
	return
$!e::
	KeyWait("LAlt")
	Send, {Alt Down}{Alt Up}
	Sleep, 50
	Send, z
	Send, {Space}
	return
$^+f::
	coordmode, mouse, screen
	Sleep, 300
	Send, {Alt Down}{Alt Up}
	Sleep, 200
	Send, w
	Sleep, 200
	Send, m
	click, 624, 124
	Sleep, 500
	click, 682, 281
	return
^m::										;???
	Send, ^b
	return
#if WinActive("ahk_exe WINWORD.EXE") 				;WordArea
NumpadClear & f::								
	Send, {Alt Down}{Alt Up}
	Send, f
	Send, {Alt Down}{Alt Up}
	return
$+WheelUp:: ; scroll left
	ComObjActive("Word.Application").ActiveWindow.SmallScroll(0, 0, 1, 0)
	return
$+WheelDown:: ; scroll left
	ComObjActive("Word.Application").ActiveWindow.SmallScroll(0, 0, 0, 1)
	return
!d::
	Send, {Alt Down}{Alt Up}
	Sleep, 300
	Send, p
	Sleep, 300
	Send, {enter}
	return
^d::
	MouseGetPos, xPos, yPos
	click, 523, 146
	click, %xPos%, %yPos%
	return
!c::
	Send, ^+c 		;format painter
	return
!v::				;format painter
	Send, ^+v
	return
$!a::
	Send, ^[
	return
$!s::
	Send, ^]
	return
$^w::
	Send, ^w
	return
$^s::
	Send, ^s
	return
#if WinActive("ahk_exe Code.exe")										;VSCarea
;;;
:*:runapp::
	clipboard := "run, % ""Explorer shell:appsFolder\Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"""
    ;Explorer or not does work, shell:appsFolder ~= path to appsFolder
    ;AppsName_8wekyb3d8bbwe!App
	Send, ^v
	Sleep, 100
	GoSub, !6
	Send, ^f
	Send, ^a
	Sleep, 100
	clipboard := "C:\Users\zlegi\AppData\Local\Packages\"
	Send, ^v
	return
;;snippets 
:*?:wcc::WinClip.(){left 2}
:*?:wcv::WinClip.Paste(){left}
:*:ahg::ahk_group group
:*:ahk_::ahk_exe{space}
:?:send,::Send,
:?:sleep,::Sleep,
; :*?X:regexreplace::Send("RegExReplace(){left}")
; :*?X:getkeystate::Send("GetKeyState(""""){left 2}")   
; :*?:soundbeep::SoundBeep,, 500{Esc}
:*?:clipwait::ClipWait, {space}
:?:msgb::Msgbox, %
:?:msg.aot::Msgbox, 262144,, %
:*:input box::{text}InputBo1727x, input, File URL, Please enter the URL of the file,, 300, 100
:*:.tick1::StarTime := A_TickCount
:*:.tick2::MsgBox, % EndTime := A_TickCount - StarTime
;;case corrections
:*:Explorer.exe::Explorer.EXE
:*:youtube::YouTube
:*C:#Include::#include
:*?:exitapp::ExitApp
::enter::Enter
;;;;;
NumpadClear & h::
    Send, ^k
    soundbeep, 100, 400
    soundbeep, 200, 300
    return
` & 1::
    Send, {Left}
    return
` & 2::
    Send, {right}
    return
NumpadClear & x::                               ;vsc_switchTerminalEditor
    Send, ^``
    ; SoundBeep,, 500
    return
Esc::
	PixelGetColor, pixel, 488, 997
	if (WinActive("ahk_exe Code.exe") && (pixel=0x5555FF))
		Send, +{F5}
    else
        ; Msgbox,,, % "use caps q instead", 0.5
        soundPlay("*48")
    return
` & 3::                                 ;vsc.Word Wrap
    Send, ^+6
    return
$^+v::
	KeyWait("LCtrl, LShift")
    textToTrim := WinClip.GetText()
    WinClip.Paste(RegExReplace(textToTrim, "`am)^\s*"))
	return
$^+WheelDown::
    sleep, 200
    Send, ^-
    return
$^+WheelUp::
    sleep, 200
    Send, ^=
    return
Left::
Right::
Up::
Down::
	return
$^+c::
	if GetKeyState("Xbutton2", "P") || GetKeyState("RAlt", "P")
		Send, !s
	else
		Send, !a
	return
$^b::                                                   ;vsc.New File
	KeyWait("LCtrl", "P")
	Send, ^b
	Sleep, 500
	Send("^km{Down}")
	return
NumpadClear & r::										;vsc.Find next
    if GetKeyState("Xbutton2", "P") 
        Send, ^+f
    else
        Send, {F3}
	return
; $!F1::											    ;vsc.Find previous
; 	KeyWait("LAlt")
; 	Send, +{F3}
; 	return
$!d::                           
    KeyWait("LAlt")
	; if GetKeyState("Xbutton2", "P") {
	; 	vText := Trim(WinClip.Copy(), " `t`r`n")
    ;     Send("!d{200}")
    ;     WinClip.Paste(vText)
    ; } else                                                
		Send, !d                                        ;vsc.Go To File
	return
$!a::
	if GetKeyState("Xbutton2", "P")
		Send, !+a
	else
		Send, !{Left}
	return
$!s::
	if GetKeyState("Xbutton2", "P")
		Send, !+s
	else
		Send, !{Right}
	return
$!+s::													
	KeyWait("LAlt, LShift") 
	if GetKeyState("Xbutton2", "P")     
		Send, ^,                                    ;vsc.Keyboard Shortcuts
	else {
		Send, ^k                                    ;vsc.Settings
		Send, ^s
	}
	return
$!+r::
	KeyWait("LAlt, LShift")
	Send, {F8}
	return
NumpadClear & WheelDown::
	Send, ^!6
	Sleep, 50
	return
NumpadClear & WheelUp::
	Send, ^!7
	Sleep, 50
 	return
$!g::                                       
	KeyWait("LCtrl", "P")
	if GetKeyState("Xbutton2", "P") {
		Send, ^{F7}
		WinWaitActive, ahk_class CabinetWClass
		Sleep, 500
		leftPattern("ahk_class CabinetWClass")
	} else {
		Send, !g
		SoundBeep,, 500
	}
	return
$#a::								            ;vsc.Toggle Activity Bar
	KeyWait("LWin")
	SendEvent, ^+6
	return
NumpadClear & space::											;vsc.Run & debug
	KeyWait("NumpadClear", "P")
	Sleep, 300
	Send, ^s
	PixelGetColor, pixel, 488, 997
	if WinActive("Banana's Script.ahk ahk_exe Code.exe")
		soundPlay("*-1")
	else if WinActive(".py ahk_exe Code.exe") && !(pixel=0x5555FF)         ;vsc.Debug Python
		Send, +{F9}
	else if WinActive(".py ahk_exe Code.exe") && (pixel=0x5555FF)     ;vsc.Restart
		Send, ^+{F5}
	else if WinActive(".ahk ahk_exe Code.exe") && !(pixel=0x5555FF)    ;vsc.Debug AHK
		Send, {F9}
	else if WinActive(".ahk ahk_exe Code.exe") && (pixel=0x5555FF)	   ;vsc.Restart
		Send, ^+{F5}
	else if WinActive("ahk_exe anki.exe")
		Send, {space}
	else
		Msgbox, % "unassigned!"
	return
NumpadClear & b::										;vsc.Bookmark navigator
	Send, ^!l
	click, 443, 149, 0
	return
$^!a::
	Send, !{Up}
	return
$^!s::
	Send, !{Down}
	return
$^+s::
	Send, ^]
	return
$^+a::
	Send, ^[
	return
$!+d::
	Send, !+{Down}
	return
NumpadClear & c::
    Send, ^+8
    return
NumpadClear & y::
	WinGet, minMax, MinMax, A
	if !(minMax = 1)
		WinMaximize, A
	else
		leftPattern()
	Send, ^+7
	return
$^s::																;vsc.Saveandreload
    KeyWait("LCtrl")
	Send, ^s
	if WinActive("Banana's Script.ahk ahk_exe Code.exe") {
		Sleep, 400
		toolTip("Script Reloaded!", 500, 664, 486)
		reload
		Sleep, 300
		loadtimeHandler()
	} else
		SoundBeep,, 200
	return
$!c::
	if GetKeyState("Xbutton2", "P")
        Send, ^+/
    else
        Send, ^/
	return
#if WinActive("ahk_exe sublime_text.exe") 						;Sublime Text 3  ;st3area
$!s::
	KeyWait("LAlt")
	Send, ^g
	return
^g::
	Msgbox, % "Altered!"
	return
$!c::
	KeyWait("LAlt")
	Send, ^/
	return
$^+v::
	KeyWait("LCtrl, LShift")
	Send, ^+v
	return
$!e::															;Fold All Subroutines
	KeyWait("LAlt")
	Send, ^k
	Send, ^1
	return
$!+e::															;Unfold All Subroutines
	KeyWait("LAlt, LShift")
	Send, ^k
	Send, ^j
	return
$^s::
	Send, ^s
	SetFormat, float, 2.0
	ToolTip, Script Reloaded!, 985, 551
	; SetTimer, RemoveToolTip, -700
	return
^+s::
	Send, ^s
	return
^w::
	Send, ^w
	return
#if WinActive("ahk_exe gamemd.exe")
1::Click, 1804, 253
2::Click, 1860, 260
3::Click, 1801, 305
4::Click, 1858, 320
5::Click, 1825, 349
6::Click, 1850, 359
$^Lbutton::
	KeyWait("LCtrl")
	Send, {Click 10}
	return
#if WinActive("Program Manager ahk_exe Explorer.EXE")
$!r::
	KeyWait("LAlt")
	Send, {F5}
	return
#if WinActive("ahk_exe Explorer.EXE")				; exparea
^WheelDown::
^WheelUp::
    soundPlay("*48")
    return
$!+s::
	KeyWait("LAlt, LShift")
	filePath := Explorer_GetSelected()
	SplitPath, % filePath, fileName
	FileCreateShortcut, % filePath, % A_Desktop "\" fileName ".lnk"
	return
$^c::
	KeyWait("LCtrl")
	clipboard := ""
	Send, ^{Ins}
	ClipWait, 2, 1
	if ErrorLevel
		Msgbox, % "Can't copy"
	else
		SoundBeep,, 500
	return
$^v::
	KeyWait("LCtrl")
	Send, +{Ins}
	return
$!F1::										;doesn't work in UIA mode
    vscPath := StrReplace(A_AppData, "Roaming", "Local\Programs\Microsoft VS Code\Code.exe")
    ;Local and Roaming folder of A_AppData issue??? https://github.com/karmaniverous/dot-code/blob/main/dot-code.ahk
	fileList := Explorer_GetSelected()
	loop, parse, fileList, `n, `r 
	{
		if (A_LoopField ~= "\.lnk$")
			FileGetShortcut, % A_LoopField, vscFilePath
		else
			vscFilePath := A_LoopField
		run, "%vscPath%" "%vscFilePath%"
		WinActivate, ahk_exe Code.exe
	}
	return
#t::																; Show/Hide Desktop Icons
	ControlGet, HWND, Hwnd,, SysListView321, ahk_class Progman
	if HWND =
		ControlGet, HWND, Hwnd,, SysListView321, ahk_class WorkerW
	if DllCall("IsWindowVisible", UInt, HWND)
		WinHide, ahk_id %HWND%
	Else
		WinShow, ahk_id %HWND%
	return
; $!space::
; 	KeyWait("LAlt")
; 	Send, {Appskey}
; 	Sleep, 300
; 	Send, d
; 	return
$^+c::
	KeyWait("LCtrl, LShift", "P")
	if !selected := Explorer_GetSelected() {
		clipboard := ""
		Send, ^+c
		clipwait
		clipboard := Trim(clipboard, """")
        selected := clipboard
	}
    selected := RegExReplace(selected, "^C:\\0\. Downloaded Programs\\0\. AHK Directory\\Audio(.+)", "A_Audio ""$1""")
    WinClip.SetText(selected)
	soundPlay(A_Audio "\ggTTS\copied.wav")
	return
!enter::
	Send, !{enter}
	return
$!r::													;Empty Recycle Bin
	KeyWait("LAlt")
	FileRecycleEmpty, C:\
	return
$!q::
	KeyWait("LAlt")
	clipboard := ""
	Send, ^+c
	clipwait
	lnkPath := Trim(clipboard, """")
	FileGetShortcut, % lnkPath, lnkSource
	if !ErrorLevel {
		Send, {AppsKey}
		Send, i
		WinWaitActive, ahk_exe Explorer.EXE
		leftpattern()
	}
	return
$!e::													;Extract files
	KeyWait("LAlt")
	Send, +{F10}
	Sleep, 100
	Send, w
	Sleep, 150
	Send, a
	WinWait, Extraction path and options ahk_exe WinRAR.exe
	WinActivate, Extraction path and options ahk_exe WinRAR.exe
	Send, {enter}
	Sleep, 2000
	run, % nircmd " shellrefresh"					;refresh Explorer
	return
$^f::
	KeyWait("LCtrl")
	DetectHiddenWindows, On
	ControlFocus,, ahk_exe Explorer.EXE
	ControlSend,, {F5}, ahk_exe Explorer.EXE
	return
$+WheelDown::
	SendEvent, {WheelRight}
	return
$+WheelUp::
	SendEvent, {WheelLeft}
	return
$^!h::										;Toggle visible hidden files
	KeyWait("LCtrl, LAlt")
	RegRead, ValorHidden, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden 
	if (ValorHidden=2) {
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1 
		toolTip("Visible")
	} else {
		RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2 
		toolTip("Hidden")
	}
	WinActivate, ahk_class ExploreWClass
    Send, !xo
    Sleep, 300
    Send, {Ctrl Down}{Tab}{Ctrl Up}
    Sleep, 300
    ControlClick, Button17, ahk_class #32770
    Sleep, 300
    Send, {F5}
	return
;!x::
;	background_file := "C:\Users\Cong Hao\Desktop\Images\Background\Screenshot (101).png"
;   DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, background_file, UInt, 2)
; 	return
#if WinActive("ahk_exe foobar2000.exe")
space::
	Send, ^+k
	return
^s::^s
^l::
	Send, {Alt Down}v{Alt Up}
	Send, l
return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 						AutoHotkey Center Area
#ifWinActive
$>!l::	
    Suspend, Permit
	KeyWait("RAlt")
	Send, {Esc}
	soundPlay(A_WinDir "\Media\Windows Battery Low.wav")
	run, % "C:\0. Coding\ahkRepos\Release All Keys.ahk"
	reload	
	Sleep, 1000
	loadtimeHandler()
	return
$!`::
	Suspend, Permit
    if GetKeyState("Xbutton2", "P")
        GoSub, $>!l
    else {
        if A_IsSuspended {
            Suspend, Off
            soundPlay(A_Audio "\Red Alert 2/Control online.mp3")
        } else {
            Suspend, On
            soundPlay(A_Audio "\Red Alert 2/Control terminated.mp3")
        }
    }
	return
$#Esc::
	KeyWait("LWin")
	if WinExist("UIAViewer ahk_exe AutoHotkeyU64.exe")
		WinActivate, UIAViewer ahk_exe AutoHotkeyU64.exe
	else {
		run, % "C:\0. Coding\ahkRepos\Lib\UIAutomation-main\UIAViewer.ahk"
		WinWaitActive, UIAViewer ahk_exe AutoHotkeyU64.exe
	}
	return
$^+Mbutton::																	 ;Open Window Spy
	KeyWait("LCtrl, LShift")
	if WinExist("Window Spy ahk_exe AutoHotkeyU64.exe")
		WinActivate, Window Spy ahk_exe AutoHotkeyU64.exe
	else {
		run, % "C:\Program Files\AutoHotkey\WindowSpy.ahk"
		WinWaitActive, ahk_exe AutoHotkeyU64.exe
		WinSet, AlwaysOnTop, On
	}
	return
$>!0:: 								 									; WinGetTitle current window
	KeyWait("RAlt")
	Msgbox, % clipboard := winTitle(, "process", true)
	return
#y:: 						 ;Mouse Gesture Position
	coordmode, mouse, screen
	MouseGetPos, xPos, yPos
	clipboard= %xPos%, %yPos% 
	return
Media_Play_Pause::													;Wifiarea
	wifi1 := "Cong Ty"
	wifi2	:= "INOX HANG XANG DBP"
	wifi3	:= ""
	run, % A_ComSpec " /c netsh wlan connect name=%wifi1%,, hide"
	run, % A_ComSpec " /c netsh wlan connect name=%wifi2%,, hide"
	run, % A_ComSpec " /c netsh wlan connect name=%wifi3%,, hide"
	SoundBeep,, 400
	return
NumpadHome::
	run, % A_ComSpec " /c netsh wlan connect name=Aerohive-5G,, hide"
	Soundbeep,, 600
	return
$>+Numpad4::
	KeyWait("RShift")
	Msgbox,,, connecting!, 0.3
	deviceName := "QCY-T13"

	DllCall("LoadLibrary", "str", "Bthprops.cpl", "ptr")
	VarSetCapacity(BLUETOOTH_DEVICE_SEARCH_PARAMS, 24+A_PtrSize*2, 0)
	NumPut(24+A_PtrSize*2, BLUETOOTH_DEVICE_SEARCH_PARAMS, 0, "uint")
	NumPut(1, BLUETOOTH_DEVICE_SEARCH_PARAMS, 4, "uint") ; freturnAuthenticated
	VarSetCapacity(BLUETOOTH_DEVICE_INFO, 560, 0)
	NumPut(560, BLUETOOTH_DEVICE_INFO, 0, "uint")
	loop 
	{
		if (A_Index = 1) {
			foundedDevice := DllCall("Bthprops.cpl\BluetoothFindFirstDevice", "ptr", &BLUETOOTH_DEVICE_SEARCH_PARAMS, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr")
			if !foundedDevice {
				Msgbox no bluetooth devices
				return
			}
		} else {
			if !DllCall("Bthprops.cpl\BluetoothFindNextDevice", "ptr", foundedDevice, "ptr", &BLUETOOTH_DEVICE_INFO) {
				Msgbox no found maybw
				break
			}
		}
		dev := StrGet(&BLUETOOTH_DEVICE_INFO+64)
		;   Msgbox dev
		if (StrGet(&BLUETOOTH_DEVICE_INFO+64) = deviceName) {
			VarSetCapacity(Handsfree, 16)
			DllCall("ole32\CLSIDFromString", "wstr", "{0000111e-0000-1000-8000-00805f9b34fb}", "ptr", &Handsfree) ; https://www.bluetooth.com/specifications/assigned-numbers/service-discovery/
			VarSetCapacity(AudioSink, 16)
			DllCall("ole32\CLSIDFromString", "wstr", "{0000110b-0000-1000-8000-00805f9b34fb}", "ptr", &AudioSink)

			hr1 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &Handsfree, "int", 0) ; voice
			hr2 := DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AudioSink, "int", 0) ; music
			if (hr1 = 0) and (hr2 = 0)
				break
			else {
				DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &Handsfree, "int", 1) ; voice
				DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AudioSink, "int", 1) ; music

				;DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &Handsfree, "int", 0)   ; voice
				;DllCall("Bthprops.cpl\BluetoothSetServiceState", "ptr", 0, "ptr", &BLUETOOTH_DEVICE_INFO, "ptr", &AudioSink, "int", 0)   ; music
				break
			}
		}
	}
	DllCall("Bthprops.cpl\BluetoothFindDeviceClose", "ptr", foundedDevice)
	soundbeep,, 600
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#if WinActive("New Tab - Cent Browser ahk_exe chrome.exe")					;newtab
; :*:f::
; 	Send, ^s
; 	return
; :*:in::
; 	Send, ^s
; 	return
#if WinActive("Google ahk_exe chrome.exe") || WinActive("New Tab ahk_exe chrome.exe") ;Quick Search
:*:333::site:w3schools.com{enter}
:*:fbb::facebook{enter}
:*X:.cli::runURL("chrome://settings/?search=command+line")
:*X:.flag::runURL("chrome://flags")
:*X:.winclip::runURL("https://apathysoftworks.com/ahk/index.html")
#if WinActive("ahk_exe chrome.exe")								;centarea
:*X:.js::Send("{vkC0sc029 3}javascript{400}}+{Enter 2}{vkC0sc029 3}{Up}")
:*X:.ahk::Send("{vkC0sc029 3}autohotkey{400}}+{Enter 2}{vkC0sc029 3}{Up}")
:*X:.c#::Send("{vkC0sc029 3}c#{400}}+{Enter 2}{vkC0sc029 3}{Up}")
; :*:#1::
; 	Fileread, content, C:\Users\zlegi\Desktop\HXUpload\product\testscr1.txt
; 	clipboard := content
; 	ClipWait, 1.5
; 	Send, ^v
; 	Send("{100}{backspace}{tab}")
; 	return
;;;;;;	
$^+s::
    KeyWait("LCtrl, LShift")                    ;cent.Tab List
    Send, !x
    return
$!+s::
    KeyWait("LAlt, LShift")
    Send, ^+s
    return
$!e::
    if GetKeyState("Xbutton2", "P") {
        cURL := getURL()
        cURL := StrReplace(cURL, regexMatches(cURL, "^(https?://www\.)?.+?\..+?(/.*)", "text", 2))
        run, % cURL
    }
    else 
        Send, !e
    return
$^+f::
    KeyWait("LCtrl, LShift")
    WinClip.Copy()
    send, ^f
    WinClip.Paste()
    return
$!+e::
	Send, !+e
	return
$!+q::
	KeyWait("LAlt, LShift")
	minMax := WinGet("minMax", A)
	if isDevTools() {
		Send, ^+i
		if (minMax=1)
			leftPattern()
	} else {
		Send, ^+i
		WinMaximize, A
	}
	return
$!q:: 
	KeyWait("LAlt")
	Send, !q
	if (WinGet("minMax", A)=0)
		WinMaximize, ahk_exe chrome.exe
	return
$!3::
	KeyWait("LAlt")
	Send, !+3
	Send, !5
	return
$^q::
	KeyWait("LCtrl")
	uCentInst()
	StarTime := A_TickCount
	if !IsObject(sidepanel_button) {
		sidepanel_button_P := uCent.FindByPath("4.1.2.1.2")
		sidepanel_button := sidepanel_button_P.FindFirstBy("Name=Show side panel && Type=Button")
	}
	sidepanel_button.click()
	toolTip(EndTime := A_TickCount - StarTime)
	return
$<!Lbutton:: 
    KeyWait("LAlt")
	if (getURL() ~= "https://github|dota2\.fandom\.com")
		Send, !{Lbutton}
    else if WinActive("- YouTube ahk_exe chrome.exe") {
        SoundBeep
        JS = 
        (
        function toggleControl() {
            let ytpControl = document.querySelector('.ytp-chrome-controls');
            if (ytpControl.style.visibility === 'visible') {
                ytpControl.style.visibility = 'hidden';
            } 
            else {
                ytpControl.style.visibility = 'visible';
            }
        }
        toggleControl();
        )
        Page := Cent.GetPage()
        Page.Evaluate(JS)
        Page.Disconnect()
    }
    else if WinActive("| Coursera ahk_exe chrome.exe") {
        SoundBeep
        JS = 
        (
        function toggleControl() {
            let ytpControl = document.querySelector('.ytp-chrome-controls');
            if (ytpControl.style.visibility === 'visible') {
                ytpControl.style.visibility = 'hidden';
            } 
            else {
                ytpControl.style.visibility = 'visible';
            }
        }
        toggleControl();
        )
        Page := Cent.GetPage()
        Page.Evaluate(JS)
        Page.Disconnect()
    }
	return
NumpadClear & r::	
 	Page := Cent.GetPageByTitle("Bookmarks", "contains")
	if IsObject(Page)
		Page.Call("Page.bringToFront")
	else 
		Send, ^+o
	Page.Disconnect()
	return
NumpadClear & c::										;Generate Hyperlink with Title
	WinGetActiveTitle, pTitle
	pTitle := RegExReplace(pTitle, "- Cent Browser")
	vURL := getURL()
	HTML := "<a href='$2'>$1</a>"
	HTML := StrReplace(HTML, "$1", pTitle)
	HTML := StrReplace(HTML, "$2", vURL)
	WinClip.SetHTML(HTML)
	soundPlay(A_Audio "\ggTTS\copied.wav")
	freeMem("pTitle, vURL, HTML")
	return
$^!d::
	KeyWait("LCtrl, LAlt")
	loop, 8 {
		Send, ^d
		Sleep, 200
		Send, ^s
		Sleep, 200
	}
	return
` & 2::
	KeyWait("``")
    if WinActive("Facebook ahk_exe chrome.exe") {
        ; currentPage := getURL()
        ; if !(currentPage ~= "https://www\.facebook\.com/?")
        ;     runURL("https://www.facebook.com", false)
        ; Page := Cent.GetPage()				
            ; Msgbox, % "Can't find page! Please check debug state"
        ; elementArray := ["div[aria-label='Options'][role='button']"
        ; , "html#facebook div:nth-child(7) > div.x6s0dn4.x78zum5.x1q0g3np.x1iyjqo2.x1qughib.xeuugli > div > div > span"
        ; , "html#facebook div > input"
        ; , "html#facebook div:nth-child(2) > div.x1i10hfl.xjbqb8w.x6umtig.x1b1mbwd.xaqea5y.xav7gou.x1ypdohk.xe8uvvx.xdj266r.x11i5rnm.xat24cr.x1mh8g0r.xexx8yu.x4uap5.x18d9i69.xkhd6sd.x16tdsg8.x1hl2dhg.xggy1nq.x1o1ewxj.x3x9cwd.x1e5q0jg.x13rtm0m.x87ps6o.x1lku1pv.x1a2a7pz.x9f619.x3nfvp2.xdt5ytf.xl56j7k.x1n2onr6.xh8yej3 > div > div.x6s0dn4.x78zum5.xl56j7k.xljgi0e.x1e0frkt > div > span > span"]
        ; queryElementSeq(elementArray)
        ; Page.Disconnect()
        JS_fb = 
        (` % Join`r`n
            elementArray = ["div[aria-label='Options'][role='button']"
            , "html#facebook div:nth-child(7) > div.x6s0dn4.x78zum5.x1q0g3np.x1iyjqo2.x1qughib.xeuugli > div > div > span"
            , "div > div > div:nth-child(3) > div > div > input"
            , "html#facebook div:nth-child(2) > div.x1i10hfl.xjbqb8w.x6umtig.x1b1mbwd.xaqea5y.xav7gou.x1ypdohk.xe8uvvx.xdj266r.x11i5rnm.xat24cr.x1mh8g0r.xexx8yu.x4uap5.x18d9i69.xkhd6sd.x16tdsg8.x1hl2dhg.xggy1nq.x1o1ewxj.x3x9cwd.x1e5q0jg.x13rtm0m.x87ps6o.x1lku1pv.x1a2a7pz.x9f619.x3nfvp2.xdt5ytf.xl56j7k.x1n2onr6.xh8yej3 > div > div.x6s0dn4.x78zum5.xl56j7k.xljgi0e.x1e0frkt > div > span > span"]
            async function clickElements(elementArray) {
              for (let i = 0; i < elementArray.length; i++) {
                const selector = elementArray[i];
                await waitForElementToExist(selector);
                const element = document.querySelector(selector);
                element.click();
              }
            }
            async function waitForElementToExist(selector) {
              while (!document.querySelector(selector)) {
                await new Promise(resolve => setTimeout(resolve, 150));
              }
            }
            clickElements(elementArray);
        )
        runJS(JS_fb,, false)   ;async=false
        SoundBeep,, 500
    }
    else if WinActive("YouTube ahk_exe chrome.exe") {
        SoundBeep
        JS = 
        (
        function toggleControl() {
            let ytpControl = document.querySelector('.ytp-chrome-controls');
            console.log(ytpControl);
            if (ytpControl.style.visibility === 'visible') {
                ytpControl.style.visibility = 'hidden';
            } 
            else {
                ytpControl.style.visibility = 'visible';
            }
        }
        toggleControl();
        )
        Page := Cent.GetPage()
        Page.Evaluate(JS)
        Page.Disconnect()
    }
	return
` & 4::
    runJS("document.body.contentEditable = document.body.contentEditable === 'true' ? 'false' : 'true';")
    SoundBeep,, 500
    return
;;
$^+Xbutton2::
	KeyWait("LCtrl, LShift")
	if (winTitle("A") ~= "LinkNeverDie")
		next_button := 
	else
		next_button := "pnnext"
	Page := Cent.GetPage()
	try
		queryElement(next_button, "id")
	catch
		Msgbox,,, no next_button found!, 0.6
	return
$^+Xbutton1::
	KeyWait("LCtrl, LShift")
	if (winTitle("A") ~= "LinkNeverDie")
		prev_button := 
	else
		prev_button := "pnprev"
	Page := Cent.GetPage()
	try
		queryElement(prev_button, "id")
	catch
		Msgbox,,, no prev_button found!, 0.6
	; Send ^l
	; Sleep, 200
	; Send, javascript   
	; Sleep, 100
	; WinClip.Paste(" :document.getElementById(""pnnext"").click()")
	; Sleep, 200
	; Send {enter}
	return
; NumpadClear & ::							;run all GS results		
	clipboard := getURL()
	pageSource := "view-source:" clipboard
	runURL(pageSource)
	Sleep, 500
	Send, ^a
	WinClip.Copy()
	Send, ^s
	haystack := clipboard
	needle := "O)data-header-feature=""0"".*?<a href="".*?"""
	for i, M in regexMatches(haystack, needle, "array")
	{	
		value := RegExReplace(M.Value, "data-header.*?href=""(.*?)""", "$1") 	;Retrieve URL
		run, % value
	}
	return
NumpadClear & WheelDown::
	Send, {Ctrl Down}{Shift Down}{Tab}{Ctrl Up}{Shift Up}
	Sleep, 50
	return
NumpadClear & WheelUp::
	Send, {Ctrl Down}{Tab}{Ctrl Up}
	Sleep, 50
 	return
` & z::
	KeyWait("``")
	Sendmode, event
	SetMouseDelay, 1
	Mousegetpos, xpos, ypos
	click, 1067, 64
	click, 873, 538
	click, %xpos%, %ypos%, 0
	return
$^2::
	KeyWait("LCtrl")
	Send, ^9
	return
$F11::
	PixelGetColor, pixel, 356, 1047
	if (pixel=0xCEE6F2)
		WinMaximize, ahk_exe chrome.exe
	Send, {F11}
    if WinActive("YouTube ahk_exe chrome.exe") {
        Send, !g
        sleep, 300
        Send, !3
    }
	return
$^WheelDown::
	Sleep, 200
    SendEvent, ^{WheelDown}
	return
$^WheelUp::
	Sleep, 200
    SendEvent, ^{WheelUp}
	return
NumpadClear & b::
	KeyWait("LAlt")
	Send, {Alt Down}b{Alt Up}
	Send, ^9
	return
$!b::
    KeyWait("LAlt")
	vURL := getURL()
	if (vURL = "")
		Msgbox, % "Can't retrieve the URL!"
	Send, ^s
	runURL(vURL)
	return
$!c::
	KeyWait("LAlt")
	clipboard := ""
	Send, !c
	ClipWait, 2
	if ErrorLevel
		Msgbox, % "Please try again!"
	Soundbeep
	return
^+h::
	KeyWait("LCtrl, LShift")
	archiveURL := getURL()
	run, https://web.archive.org/web/*/%archiveURL%
	freeMem("archiveURL")
	return
$^w::												;Translate selected text
	KeyWait("LCtrl")
	WinClip.Copy()
	Send, !+w
	Sleep, 600
	WinClip.Paste()
	Send, {enter}
	return
$>!j::	 						;Kill current tab
	KeyWait("RAlt")
	; Send, +{Esc}
	; WinWaitActive, Task Manager - Cent Browser
	; Send, +{tab}
	; Sleep, 300
	; Send, {enter}
	; WinClose, Task Manager - Cent Browser
	uCent := new UIA_Browser("ahk_exe chrome.exe")	;performance slightly slower but don't need open window
	vTitle := winTitle(, "title")
	vTitle := SubStr(vTitle, 1, -15)     ;trim "- Cent Browser"
	oParrent := uCent.FindByPath("4.2.1.1.1")						;save 300ms
	uCent.FindFirstBy("Name=" vTitle " && ControlType=TabItem",, 1).click("middle",,, "0 12")
	;relative 12 due to chrome.ypos=-12
	Send, ^9
	return
$>!k::	 						;Kill current tab and pin it
	KeyWait("RAlt")
	Send, +{Esc}
	WinWaitActive, Task Manager - Cent Browser
	Send, +{tab}
	Sleep, 300
	Send, {enter}
	WinClose, Task Manager - Cent Browser
	Sleep, 100
	Send, !b
	Sleep, 50
	Send, ^9
	return
!F5::
	Send, ^+r
	Sleep, 1000
	click, 673, 917
	Send, {Alt Down}x{Alt Up}
	return
#if WinActive("Bookmarks - Cent Browser ahk_exe chrome.exe") 			;Bookmarkarea
$!v::
	KeyWait("LAlt")
	Send, {Rbutton}
	Sleep, 300
	Send, {Down}{Enter}
	Sleep, 300
	WinClip.Paste("*********************************xxx*********************************")
	Sleep, 100
	Send, {tab}
	Sleep, 100
	WinClip.Paste("xxx")
	Sleep, 200
	Send, {enter}
	return
$!g::
	Send, {AppsKey}
	Sleep, 100
	Send, {Down}
	Sleep, 100
	Send, {Enter}
	return
$!+d::									; Duplicate current bookmark page
	KeyWait("LAlt, LShift")
    currentURL := getURL()
	Cent.GetPage().Call("Target.createTarget", {"url": currentURL}) 
	Sleep, 1000
	click, 936, 603
	Send, ^{Home}
	return
#if WinActive("Facebook - Cent Browser")
!v::
	Send, {esc}
	Send, /{tab}{tab}{tab}{tab}{tab}{tab}{enter}
	coordmode, mouse, Screen
	click, 1056, 248, 0
	return
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
>^+p::
	KeyWait("RCtrl, RShift")
	Gui, new
	Gui, guiname:new
	Gui, Color, 28C6D6
	Gui, font, s20, Verdana
	Gui, add, Text,, Please enter your name
	gui, add, edit
	;gui, menu, mymenubar
	Gui, Show
	Sleep, 3000
	gui, submit
	return
;>!o::
	KeyWait("RAlt")
	gui, new ,, To Do List
	gui, add, Text,, Hi Hao! Please enter what you have to do
	gui, add, edit, r9 vmyedit w200
	FileRead, FileContents, C:\Users\Cong Hao\Desktop\New Text Document.txt
	GuiControl,, MyEdit, %FileContents%
	gui, show , w250 h200 center
	Sleep, 6000
	FileDelete, C:\Users\Cong Hao\Desktop\New Text Document.txt
	FileAppend, %myedit%, C:\Users\Cong Hao\Desktop\New Text Document.txt
	gui, submit
	return

#ifWinActive               ;Script Center
$^`::
	KeyWait("LCtrl")
$+XButton1::									
	KeyWait("LShift")
	if WinExist("Universal Box ahk_exe AutoHotkeyU64.exe")
		WinActivate, Universal Box ahk_exe AutoHotkeyU64.exe
	else
		GoSub, Unibox
	return
UniBox:
	Gui +LastFound +OwnDialogs +AlwaysOnTop
	InputBox, scr, Universal Box, Please enter script code,, 220, 140,,,, 20
	if ErrorLevel {
		WinClose, Universal Box ahk_exe AutoHotkeyU64.exe
		return
	}
	if (SubStr(scr, 1, 4) = "http") {
		run, "%centPath%" "%scr%"
	}
    if (scr ~= "chrome://bookmarks") {
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		WinWait, New Tab ahk_exe chrome.exe
		WinClip.Paste(scr)
		Send, {enter}
	} else if (scr ~= "^ew") {
		scr := RegExReplace(scr, "^ew ?")
		run, % "https://en.wiktionary.org/w/index.php?search = " scr
	} else if (scr ~= "^ww") {
		scr := RegExReplace(scr, "^ww ?")
		run, % "https://en.wikipedia.org/w/index.php?search = " scr
	} else if (scr ~= "^ins") {
		; scr := RegExReplace(scr, "^ins ?")
		; run, % "https://www.instagram.com/" scr
	} else if (scr = "yt") {
		run, % "https://www.youtube.com/"
	} else if (scr ~= "^yt") {
		scr := RegExReplace(scr, "^yt ?")
		run, % "https://www.youtube.com/results?search_query = " scr
	} else if (scr ~= "^gg") {
		scr := RegExReplace(scr, "^gg ?")
		run, % "www.google.com/search?q = " scr
	} else if (scr ~= "^key") {
		WinClip.Clear()
		key := RegExReplace(scr, "^key ?")
		matchPos := RegExMatch(key, "iU)vk[\d]{1,3}sc[\d]{1,3}", match)
		if (matchPos != 0)
			key := match
		name := GetKeyName(key)
		vk   := GetKeyVK(key)
		sc   := GetKeySC(key)
		Msgbox, % Format("Name:`t{}`nVK:`t{:X}`nSC:`t{:X}", name, vk, sc)
		if WinClip.IsEmpty() {
			vk := Format("{:X}", vk)       ;encode to hexa
			sc := Format("{:X}", sc)  	   ;encode to hexa
			if (StrLen(sc)=2)
				sc := "0" sc
			clipboard := "vk" vk "sc" sc 
		}
	} else if (scr ~= "^\d{1,6}") {								;timer
        setAlarm(scr)
        setAlarm(time) {
            if !WinExist("Clock ahk_exe ApplicationFrameHost.exe") {
                run, % "Explorer shell:appsFolder\Microsoft.WindowsAlarms_8wekyb3d8bbwe!App"
                WinWaitActive, Clock ahk_exe ApplicationFrameHost.exe
                WinSet, ExStyle, +0x80, Clock ahk_exe ApplicationFrameHost.exe
            } else 
                WinActivate, Clock ahk_exe ApplicationFrameHost.exe
            leftPattern()
            Sleep, 500
            uClock := objUIA("Clock ahk_exe ApplicationFrameHost.exe")
            uClock.WaitElementExistByNameAndType("Timer", "ListItem").click()
            if pause := uClock.FindFirstByName("Timer running, Pause")
                pause.click()
            uClock.WaitElementExistByNameAndType("Edit timer, custom", "DataItem",, 2).click()
            length := StrLen(time)
            array := StrSplit(time,,, 5)
            if (length=1) {
                hour := 0
                minute := array[1]
                second := 0
            }
            if (length=2) {
                hour :=  0
                minute := array[1] . array[2]
                second := 0
            } 
            if (length=3) {
                hour := 0
                minute := array[1]
                second := array[2] . array[3]
            } else if (length=4) {
                hour := 0
                minute := array[1] . array[2]
                second := array[3] . array[4]
            } else if (length=5) {
                hour := array[1]
                minute := array[2] . array[3]
                second := array[4] . array[5]
            }
            ; Msgbox, % hour "`n" minute "`n" second
            uClock.WaitElementExistByName("hours").SetValue(hour)
            uClock.WaitElementExistByName("minutes").SetValue(minute)
            uClock.WaitElementExistByName("seconds").SetValue(second)
            uClock.WaitElementExistByName("Save").click()
            uClock.WaitElementExistByName("Timer paused, Start").click()
            WinMinimize, Clock ahk_exe ApplicationFrameHost.exe
            Soundbeep,, 300
        }
	} else if (scr = "app") {
		run, % "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"
	} else if (scr = "d") {
		run, % "https://drive.google.com/drive/folders/1ects5Qu5eDYu1Gj5skWiZCSoU_6iajnF?usp=sharing"
	} else if (scr = "touch") {
		WinClose, ahk_exe SearchHost.exe
		Send, {LWin}
		WinWait, ahk_exe SearchHost.exe
		WinClip.Paste("device manager")
		Sleep, 300
		Send, {enter}
		WinWaitActive, Device Manager
		Sleep, 700
		WinMove, Device Manager,, 403, 195, 994, 724
		click, 600, 626, 2
		WinWaitActive, Lenovo Keyboard Device Properties
		click, 740, 328
	} else if (scr = "app2") {
		;run, % "C:\Users\zlegi\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\System Tools\Command Prompt.lnk"
		;WinWaitActive, ahk_exe cmd.exe
		;Send, explorer shell:AppsFolder
		;Send, {enter}
		;WinClose, ahk_exe cmd.exe
		run, "explorer.exe" "shell`:`:`:{4234d49b-0245-4df3-B780-3893943456e1}"
		return
	} else if (scr = "ahk") {
		run, % "C:\0. Coding\ahkRepos"
		WinWaitActive, ahk_exe Explorer.EXE 
		leftPattern()
	} else if (scr = "py") {
		run, % "C:\0. Coding\ahkRepos\0. Coding\pyRepos"
		WinWaitActive, ahk_exe Explorer.EXE 
		leftPattern()
	} else if (scr = "lib") {
		run, % "C:\0. Coding\ahkRepos\Lib"
		WinWaitActive, ahk_exe Explorer.EXE 
		leftPattern()
	} else if (scr = "aud") {
		run, % "C:\0. Coding\ahkRepos\Audio"
		WinWaitActive, ahk_exe Explorer.EXE 
		leftPattern()
	} else if (scr = "list") {
		Gui, Add, ListView, xm r20 w700 vMyListView gMyListView, Name|In Folder|Size (KB)|Type
		LV_ModifyCol(3, "Integer")
	} else if (scr = "sc") {
		runURl("chrome://settings/cbManageShortcuts")
		Sleep, 300
		Send, ^+g
	} else if (scr = "se") {
		WinActivate, ahk_exe chrome.exe
		runURL("chrome://settings/siteData?search=cookies")
	} else if (scr = "ck") {
		WinActivate, ahk_exe chrome.exe
		runURL("chrome://settings/siteData?search=cookies")
	} else if (scr = "se") {
		WinActivate, ahk_exe chrome.exe
		runURL("chrome://settings/searchEngines")
	} else if (scr = "i") {
		run, % "https://www.icloud.com/photos/"
	} else if (scr = "edit") {
		Gui, Add, Edit, w600 +Wrap r25
		Gui, Show
	} else if (scr = "jpg") {
		run, % "https://www.icloud.com/photos/"
		run, % "https://png2jpg.com/#app"
		WinWaitActive, PNG to JPG ahk_exe chrome.exe
		Sleep, 1000
		click, 528, 487
	} else if (scr = "u") {
		run, % "https://www.facebook.com/uyen.phan.cute"
		run, % "https://www.instagram.com/_ukiee.p/"
	} else if (scr = "hihi") {
		run, % "C:\Users\zlegi\Desktop\Apps\Photos.lnk" ;"C:\Users\zlegi\Desktop\hihi.png"
	} else if (scr = "u1") {
		run, % "C:\Users\zlegi\Desktop\hihi.png"
	} else if (scr = "hbutton") {
		WinSet Style, -0xC00000, A
	} else if (scr = "t") {
		run, % "https://www.instagram.com/minhthong_811/"
		run, % "https://www.instagram.com/hey.iamharvey/"
		run, % "https://www.facebook.com/giahop.phan"
	} else if (scr = "flx") {
		run, % "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"
		WinWaitActive, ahk_exe msedge.exe
		Sleep, 300
		Send, ^t
		clipboard := "extension://diobnppoomflbfopidklhnonklfpigng/dash/dash.html?user=_ukiee.p&follower=true&following=false&profile=false&interval=30&www_claim=null&is_pro=0&v=2"
		Send, ^v
		Sleep, 100
		Send, {enter}
	} else if (scr = "fly") {
		run, % "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk"
		WinWaitActive, ahk_exe msedge.exe
		Sleep, 300
		Send, ^t
		clipboard := "extension://diobnppoomflbfopidklhnonklfpigng/dash/dash.html?user=_ukiee.p&follower=false&following=true&profile=false&interval=30&www_claim=null&is_pro=0&v=2"
		Send, ^v
		Sleep, 100
		Send, {enter}
	} else if (scr = "pass") {
		runURL("chrome://settings/passwords?search=pass")
		;Sleep, 2000
		;click, 1160, 205
		;run, % "https://passwords.google.com/"
	} else if (scr = "ul") {
		run, % "https://drive.google.com/drive/u/2/folders/1RiT9D1dQnr3otiEElHaIqiuGFK5LVhTw"
		WinWait, 0. Banana Upload - Google Drive - Cent Browser
		Sleep, 1000
		run, % "C:\0. Coding\ahkRepos"
		WinWait, 0. AHK Directory ahk_exe Explorer.EXE
		WinMove, 0. AHK Directory ahk_exe Explorer.EXE,, 749, 118, 748, 760
		Send, {Esc}
		SendEvent, {Shift Down}{Click left 1060 349}{Click left 1052 425}{Shift Up}
		SetDefaultMouseSpeed, 20
		SendEvent, {Click left 1060 349 Down}
		SendEvent, {Click left 572 264 Up}
	} else if (scr = "bnn") {
		run, % "https://drive.google.com/drive/u/2/folders/1RiT9D1dQnr3otiEElHaIqiuGFK5LVhTw"
		Sleep, 300
		Page := Cent.GetPage()
		Page.WaitForLoad()
		; if ErrorLevel
		; 	Msgbox, % "Can't reach the page"
		
		WinClip.Paste("C:\0. Coding\ahkRepos\Banana's Script.ahk")
		Send, {enter}
		Sleep, 700
		click, 866, 727
	} else if (scr = "up1") {
		run, % "https://www.upwork.com/nx/jobs/search/?ontology_skill_uid=1031626759027015680&sort=recency"
		winmaximize, ahk_exe chrome.exe
	} else if (scr = "up") {
		run, % "https://www.upwork.com/freelancers/~01b0e85fff1fc77e76"
		clipboard := "https://www.upwork.com/freelancers/~01b0e85fff1fc77e76"
	} else if (scr = "cn") {
		run, % "https://www.upwork.com/nx/plans/connects/history"
	} else if (scr = "bk") {												;Block Keyboard
		run, % "C:\0. Coding\ahkRepos\BlockKeyboardOnly.ahk"
	} else if (scr = "bm") {												;Block Mouse
		Loop 
		{
			if GetKeyState("Escape", "P") {
				BlockInput, MouseMoveOff
				Break
			} else if (A_TimeIdlePhysical<500) {
				BlockInput, MouseMove
			}
		}
	} else if (scr = "ba") {												;Block All Inputs
		Loop {
			if GetKeyState("Escape", "P") {
				BlockInput Off
				Break
			} else if (A_TimeIdlePhysical<500) {
				BlockInput On
			}
		}
	} else if (scr = "pp")
		run, % "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE"
	else if (scr = "p1") {													;Open Plan 1
		run, % "C:\0. Downloaded Programs\0. Powerpoint Center\0. New\P1.pptx"
		WinWait, P1.pptx - PowerPoint ahk_exe POWERPNT.EXE,, 2
		leftPattern("P1.pptx - PowerPoint ahk_exe POWERPNT.EXE")
	} else if (scr = "cop") {
		WinMove, ahk_exe chrome.exe,, -9, -12, 1361, 1041
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		WinWaitActive, New Tab - Cent Browser
		WinClip.Paste("chrome://extensions/?id=aefehdhdciieocakfobpaaolhipkcpgc")
		click, 1052, 330, 0
		Sleep, 300
		Send, {enter}
		Sleep, 1500
		click, 1052, 330
		Sleep, 500
		Send, ^s
	} else if (scr = "mes")
		run, % "https://www.facebook.com/messages/t/100007585009451/"
	else if (scr ~= "^c\d$") {      ;Coursera
        switch scr {
            case "c1": run, % "https://www.linkedin.com/learning/paths/career-essentials-in-business-analysis-by-microsoft-and-linkedin"
            case "c2": run, % "https://app.datacamp.com/learn/skill-tracks/sql-for-business-analysts" 
            case "c3": run, % "https://www.coursera.org/professional-certificates/google-project-management" 
            case "c4": run, % "https://www.coursera.org/learn/analysis-for-business-systems?specialization=information-systems" 
            case "c5": run, % "https://www.coursera.org/learn/technical-support-fundamentals#syllabus" 
            case "c6": run, % "https://www.coursera.org/learn/principles-of-ux-ui-design#syllabus"
            default:
                Msgbox, % "Case undefined"
        }
    }								
	else if (scr = "aot")
		run, % "https://www.bilibili.tv/en/play/1042594/11132148?bstar_from=bstar-web.pgc-video-detail.episode.0"
	else if (scr = "px") {
		MouseGetPos, x, y
		PixelGetColor, pixel, %x%, %y%
		Msgbox,,, % clipboard := pixel, 1
	} else if (scr = "nw")
		run, % "C:\Windows\System32\ncpa.cpl"
	else if (scr = "s") {
		MyImage = C:\0. Downloaded Programs\0. Images\Cover shape.png
		run, "%centPath%" "%MyImage%"
		WinWaitActive, ahk_exe chrome.exe
		WinActivate, ahk_exe chrome.exe
		Click, 661, 424
		Send, ^c
		ClipWait, 1.5
		Send, ^s
	} else if (scr = "ah")
		run, % "https://www.youtube.com/c/AndrewHubermanLab/videos"
	else if (scr = "uni")
		run, % "https://unicode.scarfboy.com"
	else if (scr = "r")
		run, % "C:\0. Downloaded Programs\OpenSaveFilesView.exe"
	else if (scr = "f")
		run, % "C:\Windows\Fonts"
	else if (scr = "w")
		run, C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE
	else if (scr = "x") {
		run, % "C:\0. Coding\ahkRepos\Excel Center.xlsx"
		WinWait, Excel Center.xlsx ahk_exe EXCEL.EXE
		leftPattern("Excel Center.xlsx ahk_exe EXCEL.EXE")
	} else if (scr = "id") {
		Sleep, 300
		Msgbox, % clipboard := winTitle("", "id", true)
	} else if (scr = "v2") {
		run, "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" "https://www.autohotkey.com/docs/v2/"
		WinWaitActive, Microsoft​ Edge ahk_exe msedge.exe
		leftPattern()
	}else if (scr = "li")
		run, % "https://www.linkedin.com/learning/paths/career-essentials-in-business-analysis-by-microsoft-and-linkedin"
	else if (scr = "tp") {
		run, % "ms-settings:devices-touchpad"
	} else if (scr = "wh")
		run, % "https://wordtohtml.net/"
	else if (scr = "hl")
		runURL("chrome://extensions/?id=bmhcbmnbenmcecpmpepghooflbehcack")
	else if (scr = "re")
		run, % "https://regex101.com/r/hE9gB4/1"
	else if (scr = "clpicker")
		run, % "C:\0. Coding\ahkRepos\SimpleColorPicker.ahk"
	else if (scr = "x1") {
		run, % "C:\Users\zlegi\Desktop\Excel File.xlsx.lnk"
		WinWaitActive, Excel File.xlsx ahk_exe EXCEL.EXE
		WinWaitActive, Microsoft Excel ahk_exe EXCEL.EXE
		ControlClick, Button2, ahk_exe EXCEL.EXE, Do&n't Update, left, 2
		WinWaitClose, Microsoft Excel ahk_exe EXCEL.EXE
		leftPattern("Excel File.xlsx ahk_exe EXCEL.EXE")
	} else if (scr = "g")
		run, % "C:\Users\zlegi\Videos\Captures"
	else if (scr = "act")
		run, % "https://www.facebook.com/banana259/allactivity"
	else if (scr = "act1")
		run, https://www.facebook.com/stories/?card_id=UzpfSVNDOjE2ODEyMjMxMjU1NDI3NzM`%3D&view_single=true
	else if (scr = "ico")
		run, % "C:\0. Downloaded Programs\0. Images\icons"
	else if (scr = "df")
		run, % "C:\0. Downloaded Programs\DefenderControl.lnk"
	else if (scr = "m1")
		run, % "https://mail.google.com/mail/u/0"
	else if (scr = "d3")
		run, % "https://drive.google.com/drive/u/2/"
	else if (scr = "d2")
		run, % "https://drive.google.com/drive/u/1/"
	else if (scr = "bbt")
		run, % "https://drive.google.com/drive/u/1/folders/1fGLMjAVCyleeBzq2Xgit7-ACdpU3Aubg"
	else if (scr = "hx")
		run, % "https://drive.google.com/drive/u/2/folders/1GGj_--P8uoNrHgpYGer535EiVU2w7qZo"
	else if (scr = "d1")
		run, % "https://drive.google.com/drive/u/0/"
	else if (scr = "dp")
		run, % "C:\0. Downloaded Programs"
	else if (scr = "vid") {
		run, % "C:\0. Downloaded Programs\Videos"
		WinWaitActive,
		WinMaximize, A
	} else if (scr = "rt") {
		soundbeep
		GoSub, terminateProtocol
		Shutdown, 6
	} else if (scr = "sd") {
		soundPlay(A_Audio "\Red Alert 2\Battle control terminated - ceva015.wav", true)
		GoSub, terminateProtocol
		Shutdown, 5
	} else if (scr = "sl")
		DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
	else if (scr = "hb")
		DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)
	else if (scr = "so")
		run, % "C:\0. Downloaded Programs\Screen Off.lnk"
	else if (scr = "exp") {
		run, % "C:\0. Downloaded Programs\Rexplorer_x64.exe"
	} else if (scr = "32")
		run, % "C:\Windows\System32"
	else if (scr = "2")
		run, % "https://www.youtube.com"
	else if (scr = "3")
		run, % "https://translate.google.com/"
	else if (scr = "11") {
        setAlarm(11)
		run, % "C:\Users\zlegi\Desktop\11.mp4"
	} else if (scr = "0") {
		inputbox, text, Google Translate Script, Please enter text here,, 250, 130
		if ErrorLevel
			WinClose, google translate script
		else
			run, https://translate.google.com/?source=osdd#view=home&op=translate&sl=en&tl=vi&text=%text%
	} else if (scr = "mot")															;Open Max OT
		run C:\ARCHANGEL\1.Learning\Sách chuyên ngành\4.Đời sống - Thường thức\1.Thể thao - Thể dục\2.Thể hình\Max OT\Tập thể hình theo phương pháp Max-OT.pdf
	else if (scr = "ss") {														;Open Screenshots
		run C:\Users\Cong Hao\Pictures\Screenshots
		Sleep, 700
		Send, !x
	} else if (scr = "bg")
		run, % "C:\Users\Cong Hao\Desktop\Images\Background"
	else if (scr = "yt")															;Open YouTube Sub
		run https://www.youtube.com/feed/subscriptions
	else if (scr = "tt") {														;Open YouTube Sub
		RunWait, % "Explorer shell:appsFolder\BytedancePte.Ltd.TikTok_6yccndn6064se!App"
		;run, % "C:\0. Downloaded Programs\TikTok.lnk"
		WinWaitActive, TikTok ahk_exe msedge.exe,, 5
		Sleep, 300
		leftPattern()
	} else if (scr = "fbs")															
		run, % "https://snapsave.app/download-private-video"
	else if (scr = "fb") 													;Open Facebook
		; run, % "https://www.facebook.com"
		return
	else if (scr = "fm")															;Open Brain.fm
		run, % "https://brain.fm/app/player"
	else if (scr = "m")															;Open Messages
		run, % "https://www.facebook.com/messages/t/"
	else if (scr = "chres")	 {													;Open Messages
		winRestart("ahk_exe chrome.exe", "C:\Users\zlegi\AppData\Local\CentBrowser\Application\chrome.exe")
		WinWaitActive, ahk_exe chrome.exe
		Sleep, 1000
		leftPattern("ahk_exe chrome.exe")
	} else if (scr = "ankires") {							;Restart anki
		winRestart("ahk_exe anki.exe", "C:\Program Files\Anki\anki.exe", 1000)
	} else if (scr = "vscres") {							;Restart anki
		winRestart("ahk_exe Code.exe", vscPath)
		WinWait, ahk_exe Code.exe
		leftPattern("ahk_exe Code.exe")
	} else if (scr = "love") {												;Open Love-Sex
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		WinWaitActive, New Tab - Cent Browser
		WinClip.Paste("chrome://bookmarks/?id=60900")
		Send, {enter}
		Sleep, 800
		click, 679, 933
		Send, !x
	} else if (scr = "bvm") {															;Open Bai viet moi
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		WinWaitActive, New Tab - Cent Browser
		WinClip.Paste("chrome://bookmarks/?id=5754")
		Send, {enter}
		Sleep, 800
		click, 679, 933
		Send, !x
	} else if (scr = "bvm") {										;Open Bai viet moi
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		Send, chrome://bookmarks/?id=87547
		Send, {enter}
		Sleep, 800
		click, 679, 933
		Send, !x
	} else if (scr = "sing") {												;Open Singing
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		Send, chrome://bookmarks/?id=71729
		Send, {enter}
		Sleep, 800
		click, 660, 614
	} else if (scr = "ytc") {															;Open YouTube Channels
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		Send, chrome://bookmarks/?id=12393
		Send, {enter}
		Sleep, 800
		click, 660, 614
	} else if (scr = "autohotkey") {													;Open Autohotkey
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		Send, chrome://bookmarks/?id=68295
		Send, {enter}
		Sleep, 800
		click, 660, 614
	} else if (scr = "cn") {														;Open Chinese
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		Send, chrome://bookmarks/?id=71184
		Send, {enter}
		Sleep, 800
		click, 660, 614
	} else if (scr = "ex") {																;Open Excel
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		Send, chrome://bookmarks/?id=69794
		Send, {enter}
		Sleep, 800
		click, 660, 614
		Send, !x
	} else if (scr = "tgk") {															;Open Thi giua ki
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		Send, chrome://bookmarks/?id=85305
		Send, {enter}
		Sleep, 800
		click, 660, 614
	} else if (scr = "dk") {
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		Send, chrome://bookmarks/?id=86182
		Send, {enter}
		Sleep, 800
		click, 660, 614
	} else if (scr = "av") {															;Open TOEIC
		WinActivate, ahk_exe chrome.exe
		Sleep, 300
		Send, ^b
		Send, chrome://bookmarks/?id=85901
		Send, {enter}
		Sleep, 800
		click, 660, 614
		Send, !x
	} else if (scr = "idm") {															;Turn On/Off IDM Extension
		WinActivate, ahk_exe chrome.exe
		Send, ^b
		Send, chrome://extensions/?id=ngpampappnmepgilojfohadhhmbhlaek
		Send, {enter}
		Sleep, 1600
		click, 1342, 370
		Sleep, 300
		Send, ^w
	} else if (scr = "cn1")														;Open Tsinghua Chinese
		run, % "https://courses.edx.org/courses/course-v1:TsinghuaX+TM01x+1T2019/course/"
	else if (scr = "desktop")													;Copy desktop's address to clipboard
		clipboard=C:\Users\Cong Hao\Desktop
	else if (scr = "4") {
		if WinExist("ahk_exe ONENOTE.EXE")
			WinActivate, ahk_exe ONENOTE.EXE
		Else
			run, % "C:\Users\Cong Hao\Desktop\OneNote 2016.lnk"
	} else if (scr = "elf")														;Open Excel Learning File
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\ELF.xlsx"
	else if (scr = "g1")
		run, % "https://mail.google.com/mail/u/0/#inbox"
	else if (scr = "g2")
		run, % "https://mail.google.com/mail/u/1/#inbox"
	else if (scr = "g3")
		run, % "https://mail.google.com/mail/u/2/#all"
	else if (scr = "e1") {														;Open English 1
		WinActivate, ahk_exe POWERPNT.EXE
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\English 1.pptx"
	} else if (scr = "e2") {														;Open English 2
		WinActivate, ahk_exe POWERPNT.EXE
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\English 2.docx"
	} else if (scr = "e3") {														;Open English Storage 1
		WinActivate, ahk_exe POWERPNT.EXE
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\English Storage 1.pptx"
	} else if (scr = "e4") {													;Open English Storage 2
		WinActivate, ahk_exe POWERPNT.EXE
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\English Storage 2.pptx"
	} else if (scr = "g1") {													;Open Gym Note
		WinActivate, ahk_exe POWERPNT.EXE
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\Gym Note.pptx"
	} else if (scr = "plf") {												;Open Powerpoint Learning File
		WinActivate, ahk_exe POWERPNT.EXE
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\Powerpoint Learning File.pptx"
	} else if (scr = "w1")												;Open Word Note
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\Word Note.docx"
	else if (scr = "'")														;Open Learning Center
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\Learning Center.pptx"
	else if (scr = "[")
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\Academic.pptx"
	else if (scr = "tdt")
		run, % "https://www.facebook.com/groups/k22.tdtu/"
	else if (scr = "cnlf")													;Open Chinese Learning File
		run, % "C:\Users\Cong Hao\Desktop\Language\Tiếng Trung\Chinese Learning File.docx"
	else if (scr = "mp3") {
		run, % "https://y2mate.com/vi/YouTube-to-mp3"
		Sleep, 2000
		winwait, Tải nhạc MP3 từ YouTube - Cent Browser,, 1
		click, 662, 409
		Send, ^v
		Sleep, 100
		click, 1076, 620
		Sleep, 1000
		click, 949, 280
		Send, {esc}
		Sleep, 1000
		Send, ^{w 2}
		return
	} else if (scr = "]") {													;Open
		run, % "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Free Alarm Clock.lnk"
		WinWait, ahk_exe FreeAlarmClock.exe
		Sleep, 400
		Send, ^n
	} else if (scr = "fb2") {
		Sleep, 500
		WinActivate, ahk_exe chrome.exe
		Send, ^g
		Sleep, 400
		Send, fb.com
		Send, {enter}
		Sleep, 5000
		Send, zyurimasterz@gmail.com
		Sleep, 300
		Send, {down}
		Send, {enter 2}
	} else if (scr = "f12")
		clipboard= document.body.contentEditable = true
	else if (scr = "gr")
		run, % "https://app.grammarly.com/ddocs/493628191"
	else if (scr = "=") {
		run, % "C:\Users\Cong Hao\Desktop\Learning Files\Math.pptx"
		WinActivate, ahk_exe POWERPNT.EXE
	} else if (scr = "gt")
		run, % "C:\Users\Cong Hao\Desktop\thongke\XXX. Giáo Trình TK Tiếng Anh FULL.pdf"
	else {
		Msgbox,,, Please type again, 0.8
		Goto, UniBox
	}
	return
	