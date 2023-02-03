if !A_IsAdmin
	Run *RunAs "C:\Program Files\AutoHotkey\AutoHotkeyU64.exe" "%A_ScriptFullPath%"
#NoEnv                    ;/!!recommended for all scripts, disable enviroment variables
#SingleInstance, force
#Warn ClassOverwrite
if !thisConfigThread {
    Process, Priority,, H		;A=Above normal, H=High, https://www.autohotkey.com/boards/viewtopic.php?t=6413
    SendMode, Input
    SetTitleMatchMode, 2
    SetBatchLines, -1
    SetWorkingDir, %A_ScriptDir%
    Coordmode, Mouse, #include
    Coordmode, ToolTip, #include
    CoordMode, Pixel, #include
    CoordMode, Menu, #include
    CoordMode, Caret, #include
    ; #include <Chrome.ahk_v1.2\Chrome>
    #include <Chrome.ahk_v1.2\tdChrome+LightJson>                ;teadrinker's editted version using LightParser instead of coco's slow and buggy Jxon()
    #include <UIAutomation-main\Lib\UIA_Interface>
    #include <UIAutomation-main\Lib\UIA_Constants>
    #include <UIAutomation-main\Lib\UIA_Browser>
    #include <ExplorerGetPath>
    #include <getURL_UIA1>
    #include <WinClip\WinClipAPI>
    #include <WinClip\WinClip>
    #include <WinSysMenuAPI>
    #include <Markdown2HTML>
    #include <Jxon>
    #include <JSON>
    #include <encodeHTML>
    #include <unHTML>
    #include <ggTTSArray>
    #include <ggTTS>
    #include <myClipHistory>
    #include <Eval>
    global centPath := "C:\Users\zlegi\AppData\Local\CentBrowser\Application\chrome.exe"
    global vscPath := "C:\Users\zlegi\AppData\Local\Programs\Microsoft VS Code\Code.exe"
    global nircmd := "C:\Windows\nircmd.exe"
    if (Chromes := Chrome.FindInstances())
        global Cent := {"base": Chrome, "DebugPort": Chromes.MinIndex(), PID: Chromes[Chromes.MinIndex(), "PID"]}
    ; else
    ; 	Cent := new Chrome()
    global wc := new WinClip
}
global UIA := UIA_Interface()
; global uCent
if WinExist("ahk_exe chrome.exe")
    global uCent := new UIA_Chrome("Cent Browser ahk_exe chrome.exe")  ;must declared under UIA declaration, might contain return => accidentally end auto execute section
global A_Audio := "C:\0. Coding\ahkRepos\Audio"
; OnError("runtimeHandler")
FileRead, construction_complete, % "*c " A_Audio "\Red Alert 2\Construction complete.wav"
;preload to cache, might be significant with large file only
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;AHK
; uiaCent := objUIA("ahk_exe chrome.exe")
; Msgbox, % uiaCent.FindFirstByType("Document").Dump()

wefwefwef






soundPlay(,,,construction_complete)
ExitApp    ;force close because soundPlay above contain 'return'
;;;functions and subroutines
SetScreenReaderActiveStatus(isActive) {
    SPI_SETSCREENREADER := 0x0047
    SPIF_SENDCHANGE := 0x0002

    return DllCall( "SystemParametersInfo"
                  , "uint", SPI_SETSCREENREADER
                  , "uint", !!isActive
                  , "ptr", 0
                  , "uint", SPIF_SENDCHANGE )
}
ankiPixelColor(pPixel) {
	PixelGetColor, pixelAnki, 1414, 407
	return (pixelAnki=pPixel)        ;true if pixelAnki=pixelcolor else return false
}
range(start, stop:="", step:=1) {

	static range := { _NewEnum: Func("_rangeNewEnum") }
	if !step
		throw "range(): Parameter 'step' must not be 0 or blank"
	if (stop == "")
		stop := start, start := 0
	; Formula: r[i] := start + step*i ; r = range object, i = 0-based index
	; For a postive 'step', the constraints are i >= 0 and r[i] < stop
	; For a negative 'step', the constraints are i >= 0 and r[i] > stop
	; No result is returned if r[0] does not meet the value constraint
	if (step > 0 ? start < stop : start > stop) ;// start == start + step*0
		return { base: range, start: start, stop: stop, step: step }
}
_rangeNewEnum(r) {
	static enum := { "Next": Func("_rangeEnumNext") }
	return { base: enum, r: r, i: 0 }
}
_rangeEnumNext(enum, ByRef k, ByRef v:="") {
	stop := enum.r.stop, step := enum.r.step
	, k := enum.r.start + step*enum.i
	if (ret := step > 0 ? k < stop : k > stop)
		enum.i += 1
	return ret
}
runJS(pInput:="", method:="Cent", async = false) {
    if (pInput ~= "^[CD]:\\.+\.js") {
        if !vFile := FileOpen(pInput, "r") {
            Msgbox, % "The file does not exist!"
            return
        }
        pInput := vFile.Read()
    }
    if (method="Cent") {
        Page := Cent.GetPage()
        if (async = false) {
            response := Page.Evaluate(pInput)
            msgEnum(response)
        }
        else
            Page.Evaluate(pInput)
        Page.Disconnect()
    } else if (method="uCent") {
        uCentInst()
        uCent.jsExec(pInput)
    }
    soundPlay(A_Audio "\Red Alert 2\Mission accomplished - ceva013.wav")
}
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
soundPlay(filePathorCode := "", WAIT := true, byMaster := "", ByRef vInput:="") {
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
winList(ret := "array", msg := false, winTitle:="", excludeBlank := true) {
	WinGet, winList, List, % winTitle                 ;Get titles of all running and visible windows
	loop, %winList%
	{
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
isTerminal() {
    vscUIA := objUIA("ahk_exe Code.exe")
	if ((vscUIA.FindByPath("1.1.7").LocalizedControlType) = "group")
	 	return true    
	else
		return false
}
isDevTools() {
	uCentInst(true)
	if uCent.FindFirstBy("Name=DevTools && ControlType=Document")
		return 1
	else
		return 0
}
vscClick(Name, controlType := "", msg := true) {
    WinActivate, ahk_exe Code.exe
	if !IsObject(vscUIA)
		vscUIA := objUIA("ahk_exe Code.exe")
	searchCriteria := "Name=" name
	if (controlType != "")
		searchCriteria .= " && ControlType=" controlType
	if !vscUIA.FindFirstBy(searchCriteria,, 2, false).click() {
		if (msg=true)
			Msgbox, Can't find the element!
		return ret := 0
	}
	else
		return ret := 1
}
countFrom(x := 1, y := "") {
	if !y
		Msgbox, % "Please define 'y'"
	while x<y
		(A_Index=1) ? (result := x) : (result .= ", " ++x)
	Msgbox, % clipboard := result
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
			Msgbox, Can't copy the query!
	}
	inputURL := RegexReplace(inputURL, "^\s+|\s+$") 	;Trim leading and trailing spaces and tabs
	if (inputURL ~= "i)[\w-]+@[\w-]+\.[\w-]+")							 ;Email
		Msgbox, % "this is an email!"
	else if (inputURL ~= "i)https?://|www\.|\.com")					 ;HTTP/HTTPS
		run, %centBrowser% "%inputURL%"
	else if (inputURL ~= "i)^[\w-]+://") 			  ;other URI schemes
		runURL(inputURL)
	else {															 ;String
		encodedURL := EncodeDecodeURI(inputURL)
		run, %centBrowser% www.google.com/search?q=%encodedURL%
	}
}
winAt(X, Y, return := "process", fullTitle := false) { 	; by SKAN, Linear Spoon, and Banana259 													;from WindowFromPoint() native fn,
	hwnd := DllCall( "GetAncestor", "UInt"			;can't detect hidden windows, even if active
		, DllCall( "WindowFromPoint", "UInt64", X | (Y << 32))
		, "UInt", 2 ) ; GA_ROOT
	ahkID := "ahk_id " hwnd
	if (return = "hwnd")
		return hwnd
	if (return = "id")
		return winTitle(ahkID, "id", fullTitle)
	if (return = "process")
		return winTitle(ahkID,, fullTitle)
	if (return = "class")
		return winTitle(ahkID, "class", fullTitle)
}
uCentInst(activate := true, update := false) {
    global uCent
	if (activate=true) || !uCent
		WinActivate, ahk_exe chrome.exe
	if (update=true)
		return uCent := new UIA_Chrome("ahk_exe chrome.exe")
	currentID := winGet("ID", "ahk_exe chrome.exe")
	if !uCent.BrowserId || (uCent.BrowserId != currentID)
		return uCent := new UIA_Chrome("ahk_exe chrome.exe")
}
Send(String, Raw := false, RawKeys := false) {
    D := "{", E = "}", S := String D, i=0, T=1, R=(Raw?1:(SubStr(S, 1, 5)="{RAW}"?1:0)), M = "+, !, #, ^", K=RawKeys
    while i := InStr(S, D, V, i+1)
	{
        Send, % (R?"{RAW}":"") SubStr(S, T, InStr(S, D, V, i)-T)
        B := SubStr(S, InStr(S, D, V, i)+1, InStr(S, E, V, i)-StrLen(S)-1), A=SubStr(B, 1, -1)
        if InStr(S, D, V, i+1)
            if(B&1 = "") {
                if(A&1 != "")
                    Sleep, % A*1000
                else {
                    L := (!R?(InStr(S, E, V, i)-StrLen(B)-2>4?4:InStr(S, E, V, i)-StrLen(B)-2):0)
                    loop, %L%
					{
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
}
DisplayHTML(inputHTML, w := 1000, h := 800) {
	static wb
	Gui, margin, 0, 0
	Gui, Add, ActiveX, x0 y0 w%w% h%h% vWB, shell explorer
	wb.Silent := True
	wb.Navigate("about:blank")
	wb.document.Write(inputHTML)
	Gui, Show,, HTML Show
}
Deref(String) {     ;Deref("This string contains %var1% and %var2% content")				  ;Deref("varName") returns var
    spo := 1
    out := ""
    while (fpo := RegexMatch(String, "(%(.*?)%)|``(.)", m, spo))
    {
        out .= SubStr(String, spo, fpo-spo)
        spo := fpo + StrLen(m)
        if (m1)
            out .= %m2%
        else switch (m3) {
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
HTMLToText(vHTML) {
	; vHTML := RegExReplace(vHTML, "`n)`n", "foobar")    ;temporary workaround because newlines don't get converted
	oHTML := ComObjCreate("HTMLFile")
	oHTML.write("<title>" vHTML "</title>")
	vText := oHTML.getElementsByTagName("title")[0].innerText
	; vText := RegExReplace(text, "foobar", "`r`n")
	return vText
}
;To retrieve text from HTML, use unHTML()
;e.g. HTM = <a href="/intl/en/ads/">Advertising Programs</a>  =>> Advertising Programs
TextToHTML(vText) {     ;encodeHTML() was also imported; Please test the difference
	oHTML := ComObjCreate("HTMLFile")
	oHTML.write("<title></title>")
	oHTML.getElementsByTagName("title")[0].value := vText
	vHTML := oHTML.getElementsByTagName("title")[0].outerHTML
	freeMem("oHTML")
	return SubStr(vHTML, 15, -10)
}
runtimeHandler(exception) {    ;exception object will be thrown by OnError()
;param1.Message := "new error message"
;function will be executed first, error message will follow
	Sleep, 300
	Edit
	WinWaitActive, ahk_exe Code.exe
	Send, ^g
	Sleep, 300
	Send, % exception.Line "{Enter}"
}
winGet(subCommand, winTitle := "A", winText := "", excludeTitle := "", excludeText := "") {
    local outputVar
    if !(subCommand ~= "i)pos|ID|IDLast|PID|ProcessName|ProcessPath|Count|List|MinMax|ControlList|ControlListHwnd|Transparent|TransColor|Style|ExStyle")
        Throw, "Invalid argument: 'subCommand'"
    if (subCommand = "pos") {
        WinGetPos, outX, outY, outW, outH, % winTitle, % winText, % excludeTitle, % excludeText
        outputVar := outX ", " outY ", " outW ", " outH
    } else if (subCommand = "text") {
        WinGetText, outputVar , % winTitle, % winText, % excludeTitle, % excludeText
    } else
        WinGet outputVar, % subCommand, % winTitle, % winText, % excludeTitle, % excludeText
    return outputVar
}
EncodeDecodeURI(str, encode := true, component := true) { 			;decoding ⇒ encode := false
   static Doc, JS
   if !Doc {
      Doc := ComObjCreate("htmlfile")
      Doc.write("<meta http-equiv=""X-UA-Compatible"" content=""IE=9"">")
      JS := Doc.parentWindow
      ( Doc.documentMode < 9 && JS.execScript() )
   }
   Return JS[ (encode ? "en" : "de") . "codeURI" . (component ? "Component" : "") ](str)
}
toolTip(text := "", msTimeout := 1000, X := "", Y := "", WhichToolTip := "") {
    ToolTip, % text, % X, % Y, % WhichToolTip
	if (msTimeout != "") {
		Sleep, % msTimeout   ;Avoid ExitApp
		ToolTip
	}
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
    else
        Throw, "Invalid 'method' argument provided!"
    if (fullTitle=true) && (vTitle != "")
		outputTitle := vTitle " " outputTitle
	return outputTitle
}
winRestart(winTitle := "A", processPath := "") {
	if (winTitle = "A")
		processPath := "A"
	if (processPath = "")
		throw, "processPath undefined!"
	else if (processPath = "A") {
		WinGet, processPath, ProcessPath, A
	}
	if (winTitle = "A") {
		WinGet, pID, ID, A
		winTitle := "ahk_ID " pID
	}
	WinKill, % winTitle
	WinWaitClose, % winTitle,, 10
	if ErrorLevel
		forceClose(winTitle)
	RunWait, % processPath
}
forceClose(process := "A") {
		if (process = "A")
			WinGet, process, ProcessName, A
		run, % nircmd " killprocess " process
	}
ankiClick(name, type := "", enter := "{Enter}") {
    WinActivate, ahk_exe anki.exe
	if !IsObject(ankiUIA)
		ankiUIA := objUIA("ahk_exe anki.exe")
	searchCriteria := "Name=" name
	if (type != "")
		searchCriteria .= " && ControlType=" type
	if (enter != "{Enter}")
		enter := ""
	if ankiElement := ankiUIA.WaitElementExist(searchCriteria,, 2, false, 1000) {
		ankiElement.click()
		Send, % enter
	} else
		Msgbox, Can't find the element!
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
elementToggle(element1, element2 := "", pMethod := "selector") {
	global Page
	Page := Cent.GetPage()
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
unescapeStr(input, trimSpaces := false) {    ;convert \n to "`n" in
	if (trimSpaces != false)
		input := Trim(input, """")
	loop
	{
		count := 0   ;reset count after each replacement
		for char, esc in {n: "`n", r: "`r", b: "`b", t: "`t", v: "`v", a: "`a", f: "`f"}
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
	MsgBox, 64, Result, %input%
	return input
}
freeMem(varList) {
	loop, parse, varList, `,, %A_Space%
		VarSetCapacity(%A_loopField%, 0, 0)
}
objUIA(winTitle) {
	return UIA.ElementFromHandle(WinExist(winTitle))
}
winCursor(winTitle) {
    MouseGetPos,,, ID
	if (winTitle = "A")
		return "ahk_id " ID
    if WinExist(winTitle " ahk_id " ID)
        return 1
    else return 0
}
WinMoveMsgBox(pTitle) {
    ID := WinExist(pTitle)
    if (ID) {
        WinMove, % "ahk_id " ID, 82, 300
        SetTimer ,, off
    }
    return
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
queryElementSeq(pArray, SleepTime := 50, byAttribute := "selector", method :="click") {
	global Page
	for aIndex, aValue in pArray {
		queryElement(aValue, byAttribute, method)
		Sleep, % SleepTime
	}
}
queryElement(element, byAttribute := "selector", method := "click", interval := 100, timeout := 8000) {
	global Page
	startTime := A_TickCount
	if (byAttribute = "selector")
		methodArgs := "document.querySelectorAll(""" element """)[0]." method "();"
	else if (byAttribute = "class")
		methodArgs := "document.getElementsByClassName(""" element """)[0]." method "();"
	else if (byAttribute = "id")
		methodArgs := "document.getElementById(""" element """)." method "();"
	loop
	{
		try
		{
			Page.Evaluate(methodArgs)
			throw, "fakeError"
		}
		catch, thisError
		{
			if !IsObject(thisError)
				break
			else
				Sleep, % interval
			thisError := ""
		}
		elapsedTime := A_TickCount - startTime
		if (elapseTime>=timeout) {
			Msgbox, Timeout!
			break
		}
	}
}
;;;
isAppear(winTitle) {
    WinGet, minMax, MinMax, winTitle
    if WinActive(winTitle)
        return 1
    else if (minMax=0)
        return 1
    else
        return 0
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
URLDownloadToVar(url, ByRef variable = "") {
    hObject := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    hObject.Open("GET", url)
    hObject.Send()
    hObject.WaitforResponse()
    return variable := hObject.ResponseText
}
visibleTaskbar() {
	WinGetPos,, taskbarY,, taskbarHeight, ahk_class Shell_TrayWnd
	if (taskbaraY=(A_#includeHeight-taskbarHeight))
		return true
}
>!>+k::
	ExitApp
	return

