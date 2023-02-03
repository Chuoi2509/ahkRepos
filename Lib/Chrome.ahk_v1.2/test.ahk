#Include tdChrome.ahk
SetTitleMatchMode, 2
;FileCreateDir, ChromeProfile


ChromeInst := new Chrome("ChromeProfile")
Sleep, 3000
PageInstance := ChromeInst.GetPage()
PageInstance.Call("Page.navigate", {"url": "https://the-internet.herokuapp.com/javascript_alerts"})
PageInstance.WaitForLoad()
sleep, 3000


global PageInst
PageInst := ChromeInst.GetPage(,,"callback")
PageInst.Call("Page.enable")

PageInstance.Evaluate("document.querySelector(""button[onclick='jsAlert()']"").click();")


; ┌─────────────────────────┐
; │  Close Browser routine  │
; └─────────────────────────┘

msgbox, ,Exiting, Exiting script, 2
PageInstance.Call("Browser.close")


PageInstance.Disconnect()
PageInstance := ""
ChromeInst := ""
ChromeInstance.Kill()
WinKill, chrome.exe

; Kill conhost.exe so it doesn't hang around.
; 
DetectHiddenWindows, On
; From GeekDude's tips and tricks: https://www.autohotkey.com/boards/viewtopic.php?f=7&t=7190
Run, cmd,, Hide, PID
WinWait, ahk_pid %PID%
DllCall("AttachConsole", "UInt", PID)

; Run another process that would normally
; make a command prompt pop up, such as
; RunWait, cmd /c dir > PingOutput.txt
Runwait, taskkill /im conhost.exe /f 
; Thanks to @flyingDman post from 2010, 
; https://autohotkey.com/board/topic/49732-kill-process/

; Close the hidden command prompt process
Process, Close, %PID%
ExitApp

callback(event)																				
{
   if (event.method = "Page.javascriptDialogOpening") {
      sleep, 3000
      PageInst.Call("Page.handleJavaScriptDialog", {"accept": LightJson.true}, false)
   }
}


/* new malcev code
global PageInst
PageInst := ChromeInst.GetPage(,,"callback")
PageInst.Call("Page.enable")
return

callback(event)																				
{
   if (event.method = "Page.javascriptDialogOpening")
      PageInst.Call("Page.handleJavaScriptDialog", {"accept": LightJson.true}, false)
}

*/