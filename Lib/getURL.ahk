; Version: 2022.07.06.1
; https://gist.github.com/7cce378c9dfdaf733cb3ca6df345b140

;winParams* => ([WinTitle, WinText, ExcludeTitle, ExcludeText])
getURL(winParams*) {          
    active := WinExist("A") 
    Target := WinExist(winParams*)  
    WinGetClass wClass
    root := UIA_Interface().ElementFromHandle(Target)
    ; Gecko family
    if (wClass ~= "Mozilla")
        return root.FindFirstByType("Edit").CurrentValue
    ; Chromium-based, active
    if (active = Target)
        return root.FindFirstByType("Document").CurrentValue
    ; Chromium-based, inactive
    toolBar := root.FindFirstByType("ToolBar")
    vURL := toolBar.FindFirstByType("Edit").CurrentValue
    WinGetTitle wTitle
    ; Google Chrome
    if (InStr(wTitle, "- Cent Browser") && vURL && !(vURL ~= "^\w+:")) {
        rect := toolBar.FindFirstByType("MenuItem").CurrentBoundingRectangle
        w := rect.r - rect.l, h := rect.b - rect.t
        vURL := "http" (w > h*2 ? "" : "s") "://" vURL
    }
    ; Microsoft​ Edge
    static edge := "- Microsoft" Chr(0x200b) " Edge" ; Zero-width space
    if (InStr(wTitle, edge) && vURL && !(vURL ~= "^\w+:"))
        vURL := "http://" vURL
    return vURL
}