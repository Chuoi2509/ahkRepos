global ClipHistory := new ClipboardHistory
if !ClipHistory.IsHistoryEnabled
   throw "This script requires Clipboard history to be enabled"
/*
; List of methods and properties
ClipHistory.Count ⇒ total clip items
ClipHistory.IsHistoryEnabled
ClipHistory.ClearHistory(
item2Content := ClipHistory.GetHistoryItemText(2)
ClipHistory.PutHistoryItemIntoClipboard(x) == clipboard := ClipHistory.GetHistoryItemText(x)
;
^!v::                                                      ;paste the 3rd, 2nd, and most recent items
   clipItemsCount := ClipHistory.Count                     ;total clip items
   loopCount := clipItemsCount < 3 ? clipItemsCount : 3    ;if total items <3 (e.g 2) loop, 2; else loop, 3
   Loop % loopCount 
   {
      ClipHistory.PutHistoryItemIntoClipboard(loopCount + 1 - A_Index)  
      ;clipboard := clip_item to paste
      ;e.g loopCount = 3
      ;1st item = 3 + 1 - 1 = item3   
      ;2nd item = 3 + 1 - 2 = item2   
      ;3rd item = 3 + 1 - 3 = item1  
      ;forward_order_formula = (A_Index)
      Send ^v
      Sleep, 400
      Send % A_Index == loopCount ? "{Enter}" : "{Tab}" 
      ;`t between pasted items, enter after done pasting
   }
Return
loopCount := ClipHistory.Count
loop, % loopCount
{
	msgbox, % itemX := ClipHistory.GetHistoryItemText(A_Index)
	ResultX .= "`r`n" itemX
}
Msgbox, % ResultX
*/

class ClipboardHistory
{
   __New() {
      static IID_IClipboardStatics2 := "{D2AC1B6A-D29F-554B-B303-F0452345FE02}"
      if (A_OSVersion ~= "^\D") {
         MsgBox, 48, Class ClipboardHistory, This class requires Windows 10 or later!
         Return ""
      }
      WrtStr := new WrtString("Windows.ApplicationModel.DataTransfer.Clipboard")
      riid := CLSIDFromString(IID_IClipboardStatics2, _)
      WrtStr.CreateInterface(riid, pIClipboardStatics2)
      this.ClipboardStatics2 := new IClipboardStatics2( pIClipboardStatics2 )
   }
   
   __Delete() {
      this.ClipboardStatics2 := ""
   }
   
   IsHistoryEnabled[] {
      get {
         Return this.ClipboardStatics2.IsHistoryEnabled
      }
   }
   
   Count[] {
      get {
         Return this._GetClipboardHistoryItems()
      }
   }
   
   ClearHistory() {
      Return this.ClipboardStatics2.ClearHistory()
   }
   
   GetHistoryItemText(index) { ; 1 based
      if !pIClipboardHistoryItem := this._GetClipboardHistoryItemByIndex(index)
         Return
      ClipboardHistoryItem := new IClipboardHistoryItem( pIClipboardHistoryItem )
      pIDataPackageView := ClipboardHistoryItem.Content
      DataPackageView := new IDataPackageView( pIDataPackageView )
      pIReadOnlyList := DataPackageView.AvailableFormats
      ReadOnlyList := new IReadOnlyList( pIReadOnlyList )
      Loop % ReadOnlyList.Count
         HSTRING := ReadOnlyList.Item[A_Index - 1]
      until (new WrtString(HSTRING, true)).GetText() = "Text" && textFound := true
      if !textFound
         Return
      DataPackageView.GetTextAsync(pIAsyncOperation)
      HSTRING := this._AsyncOperationGetResults(pIAsyncOperation)
      Return (new WrtString(HSTRING, true)).GetText()
   }
   
   PutHistoryItemIntoClipboard(index) { ; 1 based
      static SetHistoryItemAsContentStatus := ["Success", "AccessDenied", "ItemDeleted"]
      if !pIClipboardHistoryItem := this._GetClipboardHistoryItemByIndex(index)
         Return
      ClipboardHistoryItem := new IClipboardHistoryItem( pIClipboardHistoryItem )
      status := this.ClipboardStatics2.SetHistoryItemAsContent( pIClipboardHistoryItem )
      Return SetHistoryItemAsContentStatus[ status + 1 ]
   }
   
   _GetClipboardHistoryItemByIndex(index) { ; 1 based
      count := this._GetClipboardHistoryItems(ReadOnlyList)
      if (count < index) {
         MsgBox, 48, % " ", Index "%index%" exceeds items count!
         Return
      }
      Return pIClipboardHistoryItem := ReadOnlyList.Item[index - 1]
   }
   
   _GetClipboardHistoryItems(ByRef ReadOnlyList := "") {
      this.ClipboardStatics2.GetHistoryItemsAsync( pIAsyncOperation )
      pIClipboardHistoryItemsResult := this._AsyncOperationGetResults(pIAsyncOperation)
      ClipboardHistoryItemsResult := new IClipboardHistoryItemsResult( pIClipboardHistoryItemsResult )
      pIReadOnlyList := ClipboardHistoryItemsResult.Items
      ReadOnlyList := new IReadOnlyList( pIReadOnlyList )
      Return ReadOnlyList.Count
   }
   
   _AsyncOperationGetResults(pIAsyncOperation) {
      static AsyncStatus  := ["Started", "Completed", "Canceled", "Error"]
      AsyncOperation := new IAsyncOperation( pIAsyncOperation )
      AsyncOperation.QueryIAsyncInfo(pIAsyncInfo)
      AsyncInfo := new IAsyncInfo( pIAsyncInfo )
      Loop {
         Sleep, 10
         status := AsyncStatus[ AsyncInfo.Status + 1 ]
      } until status != "Started"
      if (status != "Completed")
         throw "AsyncInfo error, status: """ . status . """"
      AsyncOperation.GetResults( pResult )
      Return pResult
   }
}

class IClipboardStatics2 extends _InterfaceBase
{
   GetHistoryItemsAsync(ByRef pIAsyncOperation) {
      hr := DllCall(this.VTable(6), "Ptr", this.ptr, "UIntP", pIAsyncOperation)
      this.IsError(A_ThisFunc, hr)
   }
   ClearHistory() {
      hr := DllCall(this.VTable(7), "Ptr", this.ptr, "UIntP", res)
      this.IsError(A_ThisFunc, hr)
      Return res
   }
   SetHistoryItemAsContent(pIClipboardHistoryItem) {
      hr := DllCall(this.VTable(9), "Ptr", this.ptr, "Ptr", pIClipboardHistoryItem, "UIntP", res)
      this.IsError(A_ThisFunc, hr)
      Return res
   }
   IsHistoryEnabled[] {
      get {
         hr := DllCall(this.VTable(10), "Ptr", this.ptr, "UIntP", res)
         this.IsError(A_ThisFunc, hr)
         Return res
      }
   }
}

class IClipboardHistoryItemsResult extends _InterfaceBase
{
   Items[] {
      get {
         hr := DllCall(this.VTable(7), "Ptr", this.ptr, "PtrP", pIReadOnlyList)
         this.IsError(A_ThisFunc, hr)
         Return pIReadOnlyList
      }
   }
}

class IClipboardHistoryItem extends _InterfaceBase
{
   Content[] {
      get {
         hr := DllCall(this.VTable(8), "Ptr", this.ptr, "PtrP", pIDataPackageView)
         this.IsError(A_ThisFunc, hr)
         Return pIDataPackageView
      }
   }
}

class IDataPackageView extends _InterfaceBase
{
   AvailableFormats[] {
      get {
         hr := DllCall(this.VTable(9), "Ptr", this.ptr, "PtrP", pIReadOnlyList)
         this.IsError(A_ThisFunc, hr)
         Return pIReadOnlyList
      }
   }
   GetTextAsync(ByRef pIAsyncOperation) {
      hr := DllCall(this.VTable(12), "Ptr", this.ptr, "UIntP", pIAsyncOperation)
      this.IsError(A_ThisFunc, hr)
   }
}

class IReadOnlyList extends _InterfaceBase
{
   Item[index] {
      get {
         hr := DllCall(this.VTable(6), "Ptr", this.ptr, "Int", index, "PtrP", pItem)
         this.IsError(A_ThisFunc, hr)
         Return pItem
      }
   }
   Count[] {
      get {
         hr := DllCall(this.VTable(7), "Ptr", this.ptr, "UIntP", count)
         this.IsError(A_ThisFunc, hr)
         Return count
      }
   }
}

class IAsyncOperation extends _InterfaceBase
{
   QueryIAsyncInfo(ByRef pIAsyncInfo) {
      static IID_IAsyncInfo := "{00000036-0000-0000-C000-000000000046}"
      pIAsyncInfo := ComObjQuery(this.ptr, IID_IAsyncInfo)
   }
   GetResults(ByRef pResult) {
      hr := DllCall(this.VTable(8), "Ptr", this.ptr, "PtrP", pResult)
      this.IsError(A_ThisFunc, hr)
   }
}

class IAsyncInfo extends _InterfaceBase
{
   Status[] {
      get {
         hr := DllCall(this.VTable(7), "Ptr", this.ptr, "UIntP", status)
         this.IsError(A_ThisFunc, hr)
         Return status
      }
   }
}

class _InterfaceBase {
   __New(ptr) {
      this.ptr := ptr
   }
   __Delete() {
      ObjRelease(this.ptr)
   }
   VTable(idx) {
      Return NumGet(NumGet(this.ptr + 0) + A_PtrSize*idx)
   }
   IsError(method, result, exc := true) {
      if (result = 0)
         Return 0
      error := StrReplace(method, ".", "::") . " failed.`nResult: "
                              . ( result = "" ? "No result" : SysError(Format("{:#x}", result & 0xFFFFFFFF)) )
                              . "`nErrorLevel: " . ErrorLevel
      if !exc
         Return error
      throw error
   }
}

class WrtString {
   __New(string, isHandle := false) {
      if isHandle
         this.HSTRING := string
      else {
         DllCall("Combase\WindowsCreateString", "WStr", string, "UInt", StrLen(string), "PtrP", HSTRING)
         this.HSTRING := HSTRING
      }
   }
   __Delete() {
      DllCall("Combase\WindowsDeleteString", "Ptr", this.HSTRING)
   }
   GetText() {
      pBuff := DllCall("Combase\WindowsGetStringRawBuffer", "Ptr", this.HSTRING, "UIntP", len, "Ptr")
      Return StrGet(pBuff, len, "UTF-16")
   }
   CreateInterface(riid, ByRef pInterface) {
      hr := DllCall("Combase\RoGetActivationFactory", "Ptr", this.HSTRING, "Ptr", riid, "PtrP", pInterface)
      if (hr != 0)
         throw SysError(hr)
   }
}

CLSIDFromString(IID, ByRef CLSID) {
   VarSetCapacity(CLSID, 16, 0)
   if hr := DllCall("ole32\CLSIDFromString", "WStr", IID, "Ptr", &CLSID, "UInt")
      throw "CLSIDFromString failed. Error: " . Format("{:#x}", hr)
   Return &CLSID
}

SysError(errorNum = "") {
   static flags := (FORMAT_MESSAGE_ALLOCATE_BUFFER := 0x100) | (FORMAT_MESSAGE_FROM_SYSTEM := 0x1000)
   (errorNum = "" && errorNum := A_LastError)
   DllCall("FormatMessage", "UInt", flags, "UInt", 0, "UInt", errorNum, "UInt", 0, "PtrP", pBuff, "UInt", 512, "Str", "")
   Return (str := StrGet(pBuff)) ? str : ErrorNum
}