#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

ExecScript(Script, Wait:=true)
{
    shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec("AutoHotkey.exe /ErrorStdOut *")
    exec.StdIn.Write(script)
    exec.StdIn.Close()
    if Wait
        return exec.StdOut.ReadAll()
}

; Example:
InputBox, expr,, Enter an expression to evaluate as a new script.,,,,,,,, Asc("*")
result := ExecScript("FileAppend % (" expr "), *")
MsgBox % "Result: " result

GuiClose:
GuiEscape:
ExitApp