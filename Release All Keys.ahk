#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

OnExit:
Loop, 26 ;handles all letters
  Send % "{" Chr(96+A_Index) " Up}"
Loop, 10 ;handles all numbers
  Send % "{" A_Index-1 " Up}"
ExitApp