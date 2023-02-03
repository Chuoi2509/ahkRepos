; destPngFilePath := A_ScriptDir . "\ClipboardImage.png"
; hBitmap := GetBitmapFromClipboard()
; HBitmapToPng(hBitmap, destPngFilePath)
; DllCall("DeleteObject", "Ptr", hBitmap)
; Return


GetBitmapFromClipboard() {
   static CF_BITMAP := 2, CF_DIB := 8, SRCCOPY := 0x00CC0020
   if !DllCall("IsClipboardFormatAvailable", "UInt", CF_BITMAP)
      throw "There is no image in the Clipboard"
   if !DllCall("OpenClipboard", "Ptr", 0)
      throw "OpenClipboard failed"
   hDIB := DllCall("GetClipboardData", "UInt", CF_DIB, "Ptr")
   hBM  := DllCall("GetClipboardData", "UInt", CF_BITMAP, "Ptr")
   DllCall("CloseClipboard")
   if !hDIB
      throw "GetClipboardData failed"
   pDIB := DllCall("GlobalLock", "Ptr", hDIB, "Ptr")
   width  := NumGet(pDIB +  4, "UInt")
   height := NumGet(pDIB +  8, "UInt")
   bpp    := NumGet(pDIB + 14, "UShort")
   DllCall("GlobalUnlock", "Ptr", pDIB)
   
   hDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
   oBM := DllCall("SelectObject", "Ptr", hDC, "Ptr", hBM, "Ptr")
   
   hMDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
   hNewBM := CreateDIBSection(width, -height,, bpp)
   oPrevBM := DllCall("SelectObject", "Ptr", hMDC, "Ptr", hNewBM, "Ptr")
   DllCall("BitBlt", "Ptr", hMDC, "Int", 0, "Int", 0, "Int", width, "Int", height
                   , "Ptr", hDC , "Int", 0, "Int", 0, "UInt", SRCCOPY)
   DllCall("SelectObject", "Ptr", hDC, "Ptr", oBM, "Ptr")
   DllCall("DeleteDC", "Ptr", hDC), DllCall("DeleteObject", "Ptr", hBM)
   DllCall("SelectObject", "Ptr", hMDC, "Ptr", oPrevBM, "Ptr")
   DllCall("DeleteDC", "Ptr", hMDC)
   Return hNewBM
}

; ;CreateDIBSection(w, h, ByRef ppvBits := 0, bpp := 32) {
;    hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
;    VarSetCapacity(BITMAPINFO, 40, 0)
;    NumPut(40 , BITMAPINFO,  0)
;    NumPut( w , BITMAPINFO,  4)
;    NumPut( h , BITMAPINFO,  8)
;    NumPut( 1 , BITMAPINFO, 12)
;    NumPut(bpp, BITMAPINFO, 14)
;    hBM := DllCall("CreateDIBSection", "Ptr", hDC, "Ptr", &BITMAPINFO, "UInt", 0
;                                     , "PtrP", ppvBits, "Ptr", 0, "UInt", 0, "Ptr")
;    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
;    return hBM
; }

HBitmapToPng(hBitmap, destPngFilePath) {
   static CLSID_WICImagingFactory  := "{CACAF262-9370-4615-A13B-9F5539DA4C0A}"
         , IID_IWICImagingFactory  := "{EC5EC8A9-C395-4314-9C77-54D7A935FF70}"
         , GUID_ContainerFormatPng := "{1B7CFAF4-713F-473C-BBCD-6137425FAEAF}"
         , WICBitmapUseAlpha := 0x00000000, GENERIC_WRITE := 0x40000000
         , WICBitmapEncoderNoCache := 0x00000002
         
   VarSetCapacity(GUID, 16, 0)
   DllCall("Ole32\CLSIDFromString", "WStr", GUID_ContainerFormatPng, "Ptr", &GUID)
   IWICImagingFactory := ComObjCreate(CLSID_WICImagingFactory, IID_IWICImagingFactory)
   Vtable( IWICImagingFactory    , CreateBitmapFromHBITMAP := 21 ).Call("Ptr", hBitmap, "Ptr", 0, "UInt", WICBitmapUseAlpha, "PtrP", IWICBitmap)
   Vtable( IWICImagingFactory    , CreateStream            := 14 ).Call("PtrP", IWICStream)
   Vtable( IWICStream            , InitializeFromFilename  := 15 ).Call("WStr", destPngFilePath, "UInt", GENERIC_WRITE)
   Vtable( IWICImagingFactory    , CreateEncoder           :=  8 ).Call("Ptr", &GUID, "Ptr", 0, "PtrP", IWICBitmapEncoder)
   Vtable( IWICBitmapEncoder     , Initialize              :=  3 ).Call("Ptr", IWICStream, "UInt", WICBitmapEncoderNoCache)
   Vtable( IWICBitmapEncoder     , CreateNewFrame          := 10 ).Call("PtrP", IWICBitmapFrameEncode, "Ptr", 0)
   Vtable( IWICBitmapFrameEncode , Initialize              :=  3 ).Call("Ptr", 0)
   Vtable( IWICBitmapFrameEncode , WriteSource             := 11 ).Call("Ptr", IWICBitmap, "Ptr", 0)
   Vtable( IWICBitmapFrameEncode , Commit                  := 12 ).Call()
   Vtable( IWICBitmapEncoder     , Commit                  := 11 ).Call()
   for k, v in [IWICBitmapFrameEncode, IWICBitmapEncoder, IWICStream, IWICBitmap, IWICImagingFactory]
      ObjRelease(v)
}

Vtable(ptr, n) {
   return Func("DllCall").Bind(NumGet(NumGet(ptr+0), A_PtrSize*n), "Ptr", ptr)
}