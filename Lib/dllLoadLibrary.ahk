/* ;Perforamance testing script LoadLibrary > 2-3x, only significant with repeated calls
loops := 1000000
SetBatchLines, -1
global gdiplus := LoadLibrary("gdiplus.dll")
VarSetCapacity(bin, 20, 0)
NumPut(1, bin, 0, "int")
DllCall(gdiplus.GdiplusStartup, "ptr*", token, "ptr", &bin, "ptr", 0)
DllCall(gdiplus.GdipCreateBitmapFromScan0, "int", 1, "int", 1, "int", 0, "int", 0x26200A, "ptr", 0, "ptr*", pBitmap)

start := A_TickCount
loop % loops
    DllCall("gdiplus\GdipBitmapGetPixel", "ptr", pBitmap, "int", 1, "int", 1, "uint*", col)
timeA := A_TickCount-start

start := A_TickCount
loop % loops
    DllCall(gdiplus.GdipBitmapGetPixel, "ptr", pBitmap, "int", 1, "int", 1, "uint*", col)
timeB := A_TickCount-start

DllCall(gdiplus.DisposeImage, "ptr", pBitmap)
DllCall(gdiplus.Cleanup, "ptr", token)
MsgBox % "Normal:`n" timeA "`n`nWith LoadLibrary:`n" timeB "`n`n" timeA/timeB 
 */
LoadLibrary(filename)
{
    static ref := {}
    if (!(ptr := p := DllCall("LoadLibrary", "str", filename, "ptr")))
        return 0
    ref[ptr,"count"] := (ref[ptr]) ? ref[ptr,"count"]+1 : 1
    p += NumGet(p+0, 0x3c, "int")+24
    o := {_ptr:ptr, __delete:func("FreeLibrary"), _ref:ref[ptr]}
    if (NumGet(p+0, (A_PtrSize=4) ? 92 : 108, "uint")<1 || (ts := NumGet(p+0, (A_PtrSize=4) ? 96 : 112, "uint")+ptr)=ptr || (te := NumGet(p+0, (A_PtrSize=4) ? 100 : 116, "uint")+ts)=ts)
        return o
    n := ptr+NumGet(ts+0, 32, "uint")
    loop % NumGet(ts+0, 24, "uint")
    {
        if (p := NumGet(n+0, (A_Index-1)*4, "uint"))
        {
            o[f := StrGet(ptr+p, "cp0")] := DllCall("GetProcAddress", "ptr", ptr, "astr", f, "ptr")
            if (Substr(f, 0)==((A_IsUnicode) ? "W" : "A"))
                o[Substr(f, 1, -1)] := o[f]
        }
    }
    return o
}

FreeLibrary(lib)
{
    if (lib._ref.count>=1)
        lib._ref.count -= 1
    if (lib._ref.count<1)
        DllCall("FreeLibrary", "ptr", lib._ptr)
}