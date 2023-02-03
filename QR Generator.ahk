#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
SetBatchLines, -1
SetTitleMatchMode, 2
START:
inputbox, PixelSize,, Type 10-25
if (ErrorLevel=1)
  ExitApp
if PixelSize is not integer
{
  Msgbox, 0x10, Error, size must an integer - try again
  Goto START
}
if (PixelSize<0)
{
  Msgbox, 0x10, Error, size must be positive - try again
  Goto START
}
Winactivate, ahk_exe chrome.exe
inputbox, Test,, Type in a message and a corresponding QR Code image will be generated and saved in the scripts directory.`nOr click Cancel to Exit.
if (ErrorLevel=1)
  ExitApp
MATRIX_TO_PRINT := BARCODER_GENERATE_QR_CODE(test)
if (MATRIX_TO_PRINT = 1)
{
  Msgbox, 0x10, Error, The input message is blank. Please input a message to succesfully generate a QR Code image.
  Goto START
}

If MATRIX_TO_PRINT between 1 and 7
{
  Msgbox, 0x10, Error, ERROR CODE: %MATRIX_TO_PRINT% `n`nERROR CODE TABLE:`n`n1 - Input message is blank.`n2 - The Choosen Code Mode cannot encode all the characters in the input message.`n3 - Choosen Code Mode does not correspond to one of the currently indexed code modes (Automatic, numeric, alphanumeric or byte).`n4 - The choosen forced QR Matrix version (size) cannot encode the entire input message using the choosen ECL Code_Mode. Try forcing a higher version or choosing automated version selection (parameter value 0).`n5 - The input message is exceeding the QR Code standards maximum length for the choosen ECL and Code Mode.`n6 - Choosen Error Correction Level does not correspond to one of the standard ECLs (L, M, Q and H).`n7 - Forced version does not correspond to one of the QR Code standards versions.
  Goto START
}

  ; Start gdi+
  If !pToken := Gdip_Startup()
  {
    MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
    ExitApp
  }

  pBitmap := Gdip_CreateBitmap((MATRIX_TO_PRINT.MaxIndex() + 8) * PixelSize, (MATRIX_TO_PRINT.MaxIndex() + 8) * PixelSize) ; Adding 8 pixels to the width and height here as a "quiet zone" for the image. This serves to improve the printed code readability. QR Code specs require the quiet zones to surround the whole image and to be at least 4 modules wide (4 on each side = 8 total width added to the image). Don't forget to increase this number accordingly if you plan to change the pixel size of each module.
  G := Gdip_GraphicsFromImage(pBitmap)
  Gdip_SetSmoothingMode(pBitmap, 3)
  pBrush := Gdip_BrushCreateSolid(0xFFFFFFFF)
  Gdip_FillRectangle(G, pBrush, 0, 0, (MATRIX_TO_PRINT.MaxIndex() + 8) * PixelSize, (MATRIX_TO_PRINT.MaxIndex() + 8) * PixelSize) ; Same as above.
  Gdip_DeleteBrush(pBrush)

  Loop % MATRIX_TO_PRINT.MaxIndex() ; Acess the Rows of the Matrix
  {
    CURRENT_ROW := A_Index
    Loop % MATRIX_TO_PRINT[1].MaxIndex() ; Access the modules (Columns of the Rows).
    {
      CURRENT_COLUMN := A_Index
      If (MATRIX_TO_PRINT[CURRENT_ROW, A_Index] = 1)
      {
        ;Gdip_SetPixel(pBitmap, A_Index + 3, CURRENT_ROW + 3, 0xFF000000) ; Adding 3 to the current column and row to skip the quiet zones.
        Loop %PixelSize%
        {
          CURRENT_REDIMENSION_ROW := A_Index
          Loop %PixelSize%
          {
            Gdip_SetPixel(pBitmap, (CURRENT_COLUMN * PixelSize) + (3*PixelSize) - 1 + A_Index, (CURRENT_ROW * PixelSize) + (3*PixelSize) - 1 + CURRENT_REDIMENSION_ROW, 0xFF000000)
          }
      }
    }
      If (MATRIX_TO_PRINT[CURRENT_ROW, A_Index] = 0) ; White pixels need some more attention too when doing multi pixelwide images.
      {
        Loop %PixelSize%
        {
          CURRENT_REDIMENSION_ROW := A_Index
          Loop %PixelSize%
          {
            Gdip_SetPixel(pBitmap, (CURRENT_COLUMN * PixelSize) + (3*PixelSize) - 1 + A_Index, (CURRENT_ROW * PixelSize) + (3*PixelSize) -1 + CURRENT_REDIMENSION_ROW, 0xFFFFFFFF)
          }
        }
      }
    }
  }
  StringReplace, FILE_NAME_TO_USE, test, `" ; We can't use all the characters that byte mode can encode in the name of the file. So we are replacing them here (if they exist).
  Options = x0 y0 cFF000000 r4 s20
  Gdip_TextToGraphics(G, test, Options, "Arial")
  FILE_PATH_AND_NAME := A_ScriptDir . "\" . SubStr(RegExReplace(FILE_NAME_TO_USE, "[\t\r\n\\\/\`:\`?\`*\`|\`>\`<]"), 1) ; Same as above.
  If (StrLen(FILE_PATH_AND_NAME)>252)
    FILE_PATH_AND_NAME:=SubStr(FILE_PATH_AND_NAME,1,252)
  FILE_PATH_AND_NAME:=FILE_PATH_AND_NAME . ".png"
  IfExist,%FILE_PATH_AND_NAME%
  {
    MsgBox,4144,Error,%FILE_PATH_AND_NAME%`nalready exists - try again,1
    Run, %FILE_PATH_AND_NAME%
    WinActivate, Photos ahk_exe ApplicationFrameHost.exe
    return 
  }
  Gdip_SaveBitmapToFile(pBitmap, FILE_PATH_AND_NAME)
  Gdip_DisposeImage(pBitmap)
  Gdip_DeleteGraphics(G)
  Gdip_Shutdown(pToken)

;MsgBox,4,Success, QR Code Created. Would you like to continue?
;fMsgBox Yes
 ;   Goto START
;else
    Run, %FILE_PATH_AND_NAME%
    WinActivate, Photos ahk_exe ApplicationFrameHost.exe
   	Return
#Include %A_ScriptDir%/BARCODER.ahk
#Include %A_ScriptDir%/Gdip_All.ahk