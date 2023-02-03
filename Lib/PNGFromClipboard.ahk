
PNGFromClipboard() {
global des
If (des="")
    Msgbox, Please specify the destination path!
; Open the clipboard with exponential backoff.
loop
   if DllCall("OpenClipboard", "ptr", A_ScriptHwnd)
      break
   else
      if A_Index < 6
         Sleep (2**(A_Index-1) * 30)
      else throw Exception("Clipboard could not be opened.")

; Prefer the PNG stream if available because of transparency support.
png := DllCall("RegisterClipboardFormat", "str", "png", "uint")
if DllCall("IsClipboardFormatAvailable", "uint", png) {
   if !(hData := DllCall("GetClipboardData", "uint", png, "ptr"))
      throw Exception("Shared clipboard data has been deleted.")

   ; Allow the stream to be freed while leaving the hData intact.
   ; Please read: https://devblogs.microsoft.com/oldnewthing/20210930-00/?p=105745
   DllCall("ole32\CreateStreamOnHGlobal", "ptr", hData, "int", false, "ptr*", pStream:=0, "uint")


   DllCall("shlwapi\SHCreateStreamOnFileEx"
            ,   "wstr", des             ; destination path
            ,   "uint", 0x1001          ; STGM_CREATE | STGM_WRITE
            ,   "uint", 0x80            ; FILE_ATTRIBUTE_NORMAL
            ,    "int", true            ; fCreate is ignored when STGM_CREATE is set.
            ,    "ptr", 0               ; pstmTemplate (reserved)
            ,   "ptr*", pFileStream:=0
            ,   "uint")
   DllCall("shlwapi\IStream_Size", "ptr", pStream, "ptr*", size:=0, "uint")
   DllCall("shlwapi\IStream_Reset", "ptr", pStream, "uint")
   DllCall("shlwapi\IStream_Copy", "ptr", pStream, "ptr", pFileStream, "uint", size, "uint")
   ObjRelease(pFileStream)

   ObjRelease(pStream)
}

DllCall("CloseClipboard")
}