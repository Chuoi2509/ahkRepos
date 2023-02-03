; ******* General ******* 
; COLORETTE
ScriptVersion := 2.1
; V 2.1: Removed DLG selection, improved hover tooltip.  
; Script created using Autohotkey (http www.autohotkey.com) 
; AHK version: AHK_L (www.autohotkey.net/~Lexikos/AutoHotkey_L)
;
; AUTHOR: sumon @ the Autohotkey forums
; License: sumon's Std License (see my forum signature)
;
; To add a "pick sound", add the pick_click.wav file and uncomment lines the lines with FileCreateDir, FileInstall (23, 24)
; 
; Thanks to: The Naked General _ jamixzol@gmail.com for his "Flashy and impractical color picker" which inspired me to this.
;
; || To-do ||
; Settings?

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force

; Setup
OnExit, Exit
;~ FileCreateDir, data
;~ FileInstall, data\pick_click.wav, data\pick_click.wav
ColoretteIcon := A_ScriptFullPath

; Hotkeys
Hotkey, Rbutton, CatchColor ; HEX (Default)
Hotkey, ^Rbutton, CatchColor ; RGB

; Initiation
Traytip, Colorette:, RIGHTCLICK to copy HEX value`nAdd CTRL for RGB value, 5
SetSystemCursor("IDC_Cross") ; Reset in OnExit

If (FileExist("colorette.exe"))
   Menu, Tray, Icon, Colorette.exe

; MAIN LOOP: Pick Color

Loop
{
   CoordMode, Mouse, Screen
   MouseGetPos X, Y
   PixelGetColor Color, X, Y, RGB
   ColorD := Color ; Build an int based variable
   StringRight, color, color, 6 ; Removes 0x prefix
   SetFormat, IntegerFast, d
   ColorD += 0  ; Sets Var (which previously contained 11) to be 0xb.
   ColorD .= ""  ; Necessary due to the "fast" mode.
   ;~ ModColor := HexModify(Color, 1)
   GetKeyState("LControl") ? ColorMessage := HextoRGB(Color, "Message") : ColorMessage := Color
   Gui, 2:Color, %color%
   Tooltip, %ColorMessage% ; (%ModColor%)
   CoordMode, Pixel 
   mX := X - 30 ; Offset Tooltip from Mouse
   mY := Y - 80
   Gui, 2:-Caption +ToolWindow +LastFound +AlwaysOnTop +Border ; +0x400000 OR +Border
   Gui, 2:Show, NoActivate x%mX% y%mY% w60 h60
}
return

CatchColor: ; Catch Hover'd color
If (A_ThisHotkey = "^Rbutton")
   Out := "RGB"
If (FileExist("data\pick_click.wav"))
   SoundPlay, data\pick_click.wav
; Continue

ColorPicked:
StringRight, color, color, 6 ; Color HEX to RGB (or RGB to RGB)

If (Out = "RGB")
{
   OutColor := HexToRGB(Color)
   OutMsg := HexToRGB(Color, "Message")
   Clipboard := OutMsg
   ;~ OutParse := HexToRGB(Color, "Parse") ; Returns "R,G,B"
}
else
{
   OutColor := Color
   OutMsg :=  "#" . Color  
   Clipboard := OutColor
}

Traytip, Colorette:, %outmsg% picked
RestoreCursors()
Gui, 2:Destroy
Sleep 500
Hotkey, ^Rbutton, Off
Hotkey, Rbutton, Off

Sleep 1500
Gosub, Exit
Return

esc::
Exit:
RestoreCursors()
ExitApp
return

; FUNCTIONS
; : SetSystemCursor() and RestoreCursors()
HexToRGB(Color, Mode="") ; Input: 6 characters HEX-color. Mode can be RGB, Message (R: x, G: y, B: z) or parse (R,G,B)
{
   ; If df, d is *16 and f is *1. Thus, Rx = R*16 while Rn = R*1
   Rx := SubStr(Color, 1,1), Rn := SubStr(Color, 2,1)
   Gx := SubStr(Color, 3,1), Gn := SubStr(Color, 4,1)
   Bx := SubStr(Color, 5,1), Bn := SubStr(Color, 6,1)
   
   AllVars := "Rx|Rn|Gx|Gn|Bx|Bn"
   Loop, Parse, Allvars, | ; Add the Hex values (A - F)
   {
      StringReplace, %A_LoopField%, %A_LoopField%, a, 10
      StringReplace, %A_LoopField%, %A_LoopField%, b, 11
      StringReplace, %A_LoopField%, %A_LoopField%, c, 12
      StringReplace, %A_LoopField%, %A_LoopField%, d, 13
      StringReplace, %A_LoopField%, %A_LoopField%, e, 14
      StringReplace, %A_LoopField%, %A_LoopField%, f, 15
   }
   R := Rx*16+Rn
   G := Gx*16+Gn
   B := Bx*16+Bn
   
   If (Mode = "Message") ; Returns "R: 255 G: 255 B: 255"
      Out := "R:" . R . " G:" . G . " B:" . B
   else if (Mode = "Parse") ; Returns "255,255,255"
      Out := R . "," . G . "," . B
   else
      Out := R . G . B ; Returns 255255255
    return Out
}

; ToBase / FromBase by Lazslo @ http://www.autohotkey.com/forum/post-276241.html#276241
ToBase(n,b) { ; n >= 0, 1 < b <= 36
   Return (n < b ? "" : ToBase(n//b,b)) . ((d:=mod(n,b)) < 10 ? d : Chr(d+87))
}
 
FromBase(s,b) { ; convert base b number s=strings of 0..9,a..z, to AHK number
   Return (L:=StrLen(s))=0 ? "":(L>1 ? FromBase(SubStr(s,1,L-1),b)*b:0) + ((c:=Asc(SubStr(s,0)))>57 ? c-87:c-48)
}

HexModify(n, Add="") ; MsgBox % HexModify("ffffff", -55)
{
   ;~ Hex := "0123456789abcdef"
   R := ToBase(FromBase(SubStr(n, 1, 2), 16) + Add, 16)
   G := ToBase(FromBase(SubStr(n, 3, 2), 16) + Add, 16)
   B := ToBase(FromBase(SubStr(n, 5, 2), 16) + Add, 16)
   return R . G . B
}

RestoreCursors()
{
   SPI_SETCURSORS := 0x57
   DllCall( "SystemParametersInfo", UInt,SPI_SETCURSORS, UInt,0, UInt,0, UInt,0 )
}

SetSystemCursor( Cursor = "", cx = 0, cy = 0 )
{
   BlankCursor := 0, SystemCursor := 0, FileCursor := 0 ; init
   
   SystemCursors = 32512IDC_ARROW,32513IDC_IBEAM,32514IDC_WAIT,32515IDC_CROSS
   ,32516IDC_UPARROW,32640IDC_SIZE,32641IDC_ICON,32642IDC_SIZENWSE
   ,32643IDC_SIZENESW,32644IDC_SIZEWE,32645IDC_SIZENS,32646IDC_SIZEALL
   ,32648IDC_NO,32649IDC_HAND,32650IDC_APPSTARTING,32651IDC_HELP
   
   If Cursor = ; empty, so create blank cursor 
   {
      VarSetCapacity( AndMask, 32*4, 0xFF ), VarSetCapacity( XorMask, 32*4, 0 )
      BlankCursor = 1 ; flag for later
   }
   Else If SubStr( Cursor,1,4 ) = "IDC_" ; load system cursor
   {
      Loop, Parse, SystemCursors, `,
      {
         CursorName := SubStr( A_Loopfield, 6, 15 ) ; get the cursor name, no trailing space with substr
         CursorID := SubStr( A_Loopfield, 1, 5 ) ; get the cursor id
         SystemCursor = 1
         If ( CursorName = Cursor )
         {
            CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )   
            Break               
         }
      }   
      If CursorHandle = ; invalid cursor name given
      {
         Msgbox,, SetCursor, Error: Invalid cursor name
         CursorHandle = Error
      }
   }   
   Else If FileExist( Cursor )
   {
      SplitPath, Cursor,,, Ext ; auto-detect type
      If Ext = ico 
         uType := 0x1   
      Else If Ext in cur,ani
         uType := 0x2      
      Else ; invalid file ext
      {
         Msgbox,, SetCursor, Error: Invalid file type
         CursorHandle = Error
      }      
      FileCursor = 1
   }
   Else
   {   
      Msgbox,, SetCursor, Error: Invalid file path or cursor name
      CursorHandle = Error ; raise for later
   }
   If CursorHandle != Error 
   {
      Loop, Parse, SystemCursors, `,
      {
         If BlankCursor = 1 
         {
            Type = BlankCursor
            %Type%%A_Index% := DllCall( "CreateCursor"
            , Uint,0, Int,0, Int,0, Int,32, Int,32, Uint,&AndMask, Uint,&XorMask )
            CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
            DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
         }         
         Else If SystemCursor = 1
         {
            Type = SystemCursor
            CursorHandle := DllCall( "LoadCursor", Uint,0, Int,CursorID )   
            %Type%%A_Index% := DllCall( "CopyImage"
            , Uint,CursorHandle, Uint,0x2, Int,cx, Int,cy, Uint,0 )      
            CursorHandle := DllCall( "CopyImage", Uint,%Type%%A_Index%, Uint,0x2, Int,0, Int,0, Int,0 )
            DllCall( "SetSystemCursor", Uint,CursorHandle, Int,SubStr( A_Loopfield, 1, 5 ) )
         }
         Else If FileCursor = 1
         {
            Type = FileCursor
            %Type%%A_Index% := DllCall( "LoadImageA"
            , UInt,0, Str,Cursor, UInt,uType, Int,cx, Int,cy, UInt,0x10 ) 
            DllCall( "SetSystemCursor", Uint,%Type%%A_Index%, Int,SubStr( A_Loopfield, 1, 5 ) )         
         }          
      }
   }   
}