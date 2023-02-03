#NoEnv
#SingleInstance, Fzorce
#Warn ClassOverwrite 
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
#include C:\0. Downloaded Programs\0. AHK Directory\enumComMembers.ahk

;;;; Format()

{Index:Format} => both are optional => {:i}, {1}, {2}
s       => string 
c       => char code, similar to Chr(n)
d or i  => signed decimal
u       => unsigned decimal
x or X  => signed hex
o       => unsigned octal integer
f, e, E, g, G, a, A => floatting-point but different format/limit
p       => convert to hexa memory address

;;;; Pin a window with desktop/like a part of desktop, doesn't support well with UWP apps
#o::
  Current := WinExist("A")
  ;ParentID := WinExist("ahk_exe Explorer.EXE ahk_class Progman ")
  ;MsgBox, %ParentID%
  Parent := Parent ? 0 : DllCall("GetShellWindow") ; <-- toggle
  ;Parent := Parent ? 0 : ParentID ; <-- toggle
  ; the window will be dettached if 0 is passed as parent's hWnd
  DllCall("SetParent", UInt, Current, UInt, Parent )
;;;;hokey-sensitive label
Launch_Mail::
if A_ThisHotkey = Launch_Mail
	Send, {F1}
else if A_ThisHotkey = Browser_Home
	Send, {F2}
else if A_ThisHotkey = Launch_App2
	Send, {F3}
;;;; WinClip      ;read WinCliptest.ahk_exe for more examples
Copy(timeout := 1)  => Snap() => Clear() -> send, ^c -> Clipwait, 1, 1 -> If can't copy, Restore()
Paste(text := "")   => Snap()+Clear()+SetText() => send ^v => wait 3s for text to paste, if !text restore
;WinClip.SetText(var) => WinClip.Paste()
;WinClip.Paste("text of var")
;WinClip.Paste(var) doesn't work somehow
formats := WinClip.GetFormats()    => returns all formats in an object
if WinClip.HasFormat(format)       => format = [""]
Snap(Byref vData)        => save WinClip to vData
Restore(Byref vData)	 => restore data from vData
Save(filepath)           => save WinClip to filepath
Load(filepath)			 => load from filepath
Clear()					 => empty WinClip
IsEmpty()                => if (clipboard = "")
GetText()                => get text with UTF-16 format
SetText(textData)        => SetText("string"), SetText(var), SetText(snapData)
AppendText(textData)     => add to current text clip item
GetHTML()			     => GetHTML() gets HTML clip item
SetHTML(html, source := "") => source is just the source of the set html added as metadata
GetBitmap(), WinClip.SetBitmap(pngPath) => set to clipboard
SaveBitmap(filepath, format)   => format~bmp, jpeg, gif, tiff, png
GetRTF(), SetRTF()                   
GetFiles(), SetFiles(), AppendFiles()    =>    
;;;; HTTP requests
;;;WinHttp.WinHttpRequest.5.1
;;;Msxml2.XMLHTTP
link := "https://www.google.com"
req := ComObjCreate("Msxml2.XMLHTTP")
req.open("GET", link, False)
req.Send()
MsgBox, % req.responseText
;If You use Msxml2.XMLHTTP You have to set cache related headers to avoid getting response text from cache.
req.SetRequestHeader("Pragma", "no-cache")
req.SetRequestHeader("Cache-Control", "no-cache, no-store")
req.SetRequestHeader("If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT")
;;;; Regular Expressions
;;;options
i) =>  case-insensitive
m) =>  multiline =>  change (^) and ($) ; D) is ignored
=>  ^pattern$ =>  every line with this exact pattern
s) =>  change (.) to match newlines ; 1 CRLF = `r`n = 2 dots (.); 1n = 1 dot (.)
x) =>  omit whitespace characters (`s, `t, `n) (AHK), except "\s", "\t", "\n" (PCRE) and [ x]
A) =>  whole (^)
D) =>  whole ($)
J) =>  allow duplicate named subpatterns??
U) =>  universal ungreedy;  affects *, ?, +, and {min, max}
;? for ungreedy individual quantifier
;U) + ? =>  greedy individual quantifier
P) =>  position mode =>  returns 
O) =>  stores all match information to OutputVar object
S) =>  study mod =>  used for complex pattern executed many times to search faster
`n) and `r) =>  affects anchors (^ and $), and `n=`r=1 dot in s)
`a) acceps all types of newlines =>  `r, `n, `v, `f, etc.
(*ANYCRLF) =>  im) (*ANYCRLF) ^abc$ =>  accepts `r, `n, `r`n as new line
;;;elements
. =>  any single character except newline ;affected by s), `n), `r), `a), (*ANYCRLF)
;; *, ?, +, {min, max} affects their respective preceding character/class/subpattern
* =>  zero or more
? =>  zero or one
+ =>  one ormore 
.* =>  consumes anything, stopped by newlines (change by above)
{min, max}; {min, }-min only ; {, max}-max only ; {x}-exact
;;[...], [^...], \d, \s, \w =>  class and class equivalents
[...] =>  a list/range of character
;[abc] =>  a/b/c   ;[a-z0-9 ] =>  a-z + 0-9 + space 
[[:xxx:]] =>  POSIX named sets
;xxx = alnum/alpha/ascii/blank/cntrl/digit/xdigit/print/graph/punct/lower/upper/space/word
;e.g [[:word:]] = \w = [a-zA-Z0-9_]
;!characters don't need to be escaped in class except these special ones: \, [, ], -, ^
;[\\a] =>  \ and a   ;[\^a] =>  ^ and a (because of [^...])
;[a\-b] =>  a, -, and b ;[a\]] =>  a and ]
;;anchors: ^ and $
[^...] =>  not class
\d = [0-9]   \D = [^0-9]

\s = [ \t\r\n]   \S = [^ \t\r\b\n]

Look-ahead assertions:           "abc123xyz abc123def abc456xyz"
;positive look-ahead "(?=...)"   abc(?=\w+xyz)   ;abc abc
;needle := run, ([^%](?!.+")(?!.+%)(?!.+ ).+) ;file run patterns not start with %, not contain ", %, /s behind
;negative look-ahead "(?!...)"   abc(?!\w+xyz)   ;abc(2)
Look-behind assertions     ;!doesn't support *, ., + like look-ahead
;positive look-behind "(?<=...)"  (?<=\w)xyz    ;xyz xyz
;positive look-behind "(?<!...)"  (?<![123])xyz    ;xyz(2)
~= \K 
;e.g  (\(.*?)(?<! ):=(?! )(.*?\)) => find all default arguments like this abc:="arg"

;;;; Objects bult-in methods
Obj.InsertAt()
Obj.
Obj.
;;;; Rectangle painting by DllCall()
VarSetCapacity(Rect, 16, 0)  ; Set capacity to hold four 4-byte integers and initialize them all to zero.
NumPut(A_ScreenWidth//2, Rect, 8, "Int")  ; The third integer in the structure is "rect.right".
NumPut(A_ScreenHeight//2, Rect, 12, "Int") ; The fourth integer in the structure is "rect.bottom".
hDC := DllCall("GetDC", "Ptr", 0, "Ptr")  ; Pass zero to get the desktop's device context.
hBrush := DllCall("CreateSolidBrush", "UInt", 0x0000FF, "Ptr")  ; Create a red brush (0x0000FF is in BGR format).
DllCall("FillRect", "Ptr", hDC, "Ptr", &Rect, "Ptr", hBrush)  ; Fill the specified rectangle using the brush above.
DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)  ; Clean-up.
DllCall("DeleteObject", "Ptr", hBrush)  ; Clean-up.
;;;; Continuation Section
conSect = 
(Join,`s LTrim RTrim0 C % )
    var element = document.querySelectorAll('[aria-label = "Options"][role="button"]');
    window.alert(el.length);
    element[0].click();
)
Join,`s =>  connect lines with ", " as delimiters, "`s" is only usable with conSec
LTrim =>  LTrim " `t"
RTrim0 =>  turn off default RTrim of every line 
C => allow ";" comments
% =>  take % as literal rather than variable reference (legacy syntax only)
, => take , as delimiter, not literal ???
) => lines with ) will be interpreted as expression ???
;;;; UIA_Browser
uCent := new UIA_Browser("ahk_exe chrome.exe")   
uCent.BrowserId     => ahk_id of uCent instance
uCent.BrowserType   => "Chrome", "Edge", "Mozilla" or "Unknown"
uCent.MainPaneElement  => 
	uCent.NavigationBarElement => omni box+extensions+tabs+...
		uCent.URLEditElement  => omni box element

uCent.GetCurrentMainPaneElement() =>  updates and returns MainPaneElement
uCent.GetCurrentDocumentElement()
uCent.GetAllText()
uCent.GetAllLinks()       ;returns array of URLs
uCent.WaitTitleChange(targetTitle = "", timeOut=-1)    
uCent.WaitPageLoad(targetTitle = "", timeOut=-1, sleepAfter=500, titleMatchMode=3, titleCaseSensitive=True) 
;wait to load to targetTitle if specified (title might change several times 'til the target)
uCent.Back(), uCent.Forward(), uCent.Reload()    ;click respective button
uCent.Home()   ;if exists
uCent.GetCurrentURL(fromAddressBar=False)     ;fromAddressBar=True =>  not necessarily the same with actual URL/might not contains https://
uCent.SetURL(newUrl, navigateToNewUrl = False)   ;set URl bar value and navigate if needed
uCent.Navigate(url, targetTitle = "", waitLoadTimeOut=-1, sleepAfter=500)   ;Navigate and wait for load
uCent.NewTab()      ;click new tab button
uCent.GetTab(searchPhrase = "", matchMode=3, caseSensitive=True)  
;returns tab element with searchPhrase is tab's title else current
uCent.GetTabs(searchPhrase = "", matchMode=3, caseSensitive=True)
uCent.GetAllTabNames()
uCent.SelectTab(tabName, matchMode=3, caseSensitive=True) 
uCent.CloseTab(tabElementOrName = "", matchMode=3, caseSensitive=True)
uCent.IsBrowserVisible()   ;returns true if not hidden, minimized
uCent.GetAlertText()       ;gets the text from an alert box
uCent.CloseAlert()		   ;closes an alert box
uCent.JSExecute(js)        ;using address bar
uCent.JSReturnThroughClipboard(js)    ;returns result of JS by clipboard, restores clipboard later
uCent.JSReturnThroughTitle(js)        ;less reliable 
uCent.JSSetTitle(js)
uCent.JSGetElementPos(selector, useRenderWidgetPos=False)    ;
uCent.JSClickElement(selector)
;use JSExecute()+Click() method, might not be supported all the time
uCent.ClickJSElement(selector, WhichButton = "", ClickCount=1, DownOrUp = "", Relative = "", useRenderWidgetPos=False)
;use JSReturnThroughClipboard()+ahkClick on element position, might be a bit slower (waiting for clipboard to returns the position)
uCent.ControlClickJSElement(selector, WhichButton = "", ClickCount = "", Options = "", useRenderWidgetPos=False)
;


;;;; UIA_Interface 
UIA := UIA_Interface()     ;access UIA tree through Interface object, don't use new keyword
UIA.CompareElements(el1, el2)
UIA.CompareRuntimeIds(id1, id2)
UIA.GetRootElement()		;return current desktop element ("Desktop 1")
hwnd := WinExist("ahk_exe Obsidian.exe")
UIA.ElementFromHandle(hwnd, ChromiumAccesibility := True) ;element of a window through its hwnd
;ChromiumAccesibility sends message to Chromium app for accessiblity
UIA.ElementFromPoint(x, y)  ;Element from x, y
UIA.SmallestElementFromPoint(x, y)
bounds := element.CurrentBoundingRectangle     ;similar to highlight
=> bounds.l, bounds.r, bounds.t, bounds.b      ;left, right, top, bottom
UIA.GetFocusedElement() =>  get current element that has focus
UIA.ElementFromIAccessible() ;Using Acc/MSAA Object (predecessor of UIA)
;For more info https://github.com/Descolada/UIAutomation/wiki/02.-UIA-tree#:~:text=elements%20as%20well.-, elementfromiaccessible, -UIA_Interface.ElementFromIAccessible
UIA.ElementFromChromium(winTitle = "A")        ;work for Chromium apps such as Obsidian
UIA.GetChromiumContentElement(winTitle = "A")

msgbox, % el.DumpAll()      ;all info about the element, empty if !element
;Alternative when ElementFromHandle, ElementFromChromium doesn't work

;;UIA Elements =>  nodes from UIA tree
;;Button, Edit, Checkbox, etc. can have child element contain image or text
;;Pane, Table elements =>  container of other elements

;Working with elements:
1. Retrieve properties =>  name, size, location, type, etc.
2. interact with elements =>  click, focus, or other through Patterns
3. Find() methods =>  find elements from root element
Wait() methods =>  wait for the elements to appear

;Element properties  : 
;Exists, Value, ProcessId, ControlType, LocalizedControlType, Name, AcceleratorKey
;AccessKey, HasKeyboardFocus, IsKeyboardFocusable, IsEnabled, AutomationId, ClassName
;HelpText, Culture, IsControlElement, IsContentElement, IsPassword, NativeWindowHandle
;ItemType, Orientation, FrameworkId, IsRequiredForForm, ItemStatus, BoundingRectangle
;LabeledBy, AriaRole, AriaProperties, IsDataValidForForm, ControllerFor, DescribedBy
;FlowsTo, ProviderDescription

UIA.el.Value := "set value using Value Pattern" 
;most of properties are string 
=>  Msgbox, % el.Name

;Control pattern properties (list: https://github.com/Descolada/UIAutomation/wiki/04.-Elements#:~:text=control%20pattern%20properties-, runtimeid, -%2C%20BoundingRectangle%2C%20ProcessId%2C%20ControlType)
;ProcessId, ControlType, LocalizedControlType, Name, AcceleratorKey, AccessKey

;;Interaction methods
el.SetFocus()     ;usually also activate the window
el.SetValue(...)
= el.Value := ...
= el.CurrentValue := ...
el.Click(ButtonOrSleepTime = "", ClickCountAndSleepTime=1, DownOrUp = "", Relative = "")
; using pattern methods: Invoke(), Toggle(), Expand(), Collapse(), Select()
;for LegacyIAccessible DoDefaultAction(), ClickCount is ignored

;e.g. Click("left", "20 200") =>  left click 20 times and then sleep 200ms (not after every click)
;usually click at the center of the element =>  adjust by e.g. Relative = "-5 10"
el.ControlClick(WinTitleOrSleepTime = "", WinTextOrSleepTime = "", WhichButton = ""
, ClickCount = "", Options = "", ExcludeTitle = "", ExcludeText = "")

;;Find methods	
el.FindFirstBy("Name=Skype AND ControlType=Window") ;Find first element that matches the criteria
el.FindAllBy("Name=Skype AND ControlType=Window")
;FindByPath(searchPath := "", c := ""), c =>  condition
UIA_Interface.CreateCondition("ControlType", "Button") =>  ControlType=Button only
=>  UIA_el.FindByPath("+2", UIA_Interface.CreateCondition("ControlType", "Button"))
el.FindByPath("+1") => the next sibling element (under it in the tree)
el.FindByPath("-2") =>  above it in the tree
el.FindByPath("2")  =>  the 2nd child element
el.FindByPath("P2") =>  the parent of its parent (2 level above)
ankiElement2 := ankiElement1.FindByPath("P1.+1")     ;combine mulitiple criteria with .
searchPath = "P1-1.1.1.2" -> gets the parent element, then the previous sibling element of the parent
, and then "1.1.2" gets the second child of the first childs first child. 
;
el.FindAll(condition, scope)    ;Find all matched elements
el.FindFirst(condition, scope)  ;condition doesn't support expression like FindFirstBy, FindAllBy

;FindByType =>  ControlType
el.FindFirstByNameAndType("name", "type")


;;Wait methods
el.WaitElementExist()
el.WaitElementExistByName()
el.WaitElementExistByType()
el.WaitElementExistBy()
el.WaitElementNotExist()

if (foundElement := el.WaitElementExistByName("Skype"))
	continue

;;Patterns
Invoke, Selection, Value, RangeValue, Scroll, ScrollItem, ExpandCollapse, Grid
, GridItem, MultipleView, Window, SelectionItem, Dock, Table, TableItem, Text, Toggle
, Transform, LegacyIAccessible, ItemContainer

;;Pattern method
el.GetCurrentPatternAs("Invoke").Invoke()      ;GetCurrentPatternAs() returns pattern object
el.GetCurrentPatternAs("LegacyIAccessible").SetValue(val)

;;Scope
; TreeScope_None := 0x0  
; TreeScope_Element := 0x1
; TreeScope_Children := 0x2    =>  all direct child elements
; TreeScope_Descendants := 0x4 =>  all decendants, include children
; TreeScope_Parent := 0x8      =>  direct parent
; TreeScope_Ancestors := 0x10  =>  element ancestors, including its parent
; TreeScope_Subtree := 0x7   
;;
CreatePropertyCondition(propertyId, value, type := "Variant")
propertyId =>  ControlType, Name, Value, AutomationId
Value =>  Value of propertyId
this.EditControlCondition =>  "ControlType=Edit"
;;
GetCurrentPropertyValue(UIA_Enum.UIA_IsInvokePatternAvailablePropertyId)
propertyID=UIA_Enum.UIA_IsInvokePatternAvailablePropertyId
UIA_IsInvokePatternAvailablePropertyId := 30031
=>  el.GetCurrentPropertyValue(30031) =>  if 1 el can be invoked
;other properties are like from Inspect.exe
;;
TreeTraversalOptions_Default := 0x0
TreeTraversalOptions_PostOrder := 0x1
TreeTraversalOptions_LastToFirstOrder := 0x2
;;
conReload := uCent.CreateAndCondition(uCent.CreateCondition("Name", "Reload"), uCent.CreateCondition("ControlType", "Button"))
CreateAndCondition(c1, c2)
CreateCondition(property, value)
TreeWalker object
myWalker := UIA.CreateTreeWalker(condition)
myWalker.condition  
GetPreviousSiblingElement()
GetNextSiblingElement()
GetFirstChildElement()
GetLastChildElement()
GetParentElement()
=> FindPath() for nested levels
Built-in TreeWalkers => 
TreeWalkerTrue.GetLastChildElement() => match "any" last child element
ControlViewWalker.GetLastChildElement() => match last child element that is control
ContentViewWalker.GetLastChildElement() => match last child element that contains content
;;
vsc := objUIA("A")
vsc.FindFirstByName("File").Highlight() ; Highlight element
;;
TreeTraversalOptions_Default := 0x0     =>  0 : foward (preorder)
TreeTraversalOptions_PostOrder := 0x1	=>  1 : siblings (left->right, topmos) => parents =>  siblings of parents ...
TreeTraversalOptions_LastToFirstOrder := 0x2 =>  2 : backward, similar to above but right to left (from bottmost)
FindFirstWithOptions(scope := 0x4, c := "", traversalOptions := 0, root := 0))
;;; Caching
uCentInst(true)             
cacheRequest := uCent.CreateCacheRequest()
cacheRequest.TreeScope := 5 ; (optional) Set TreeScope to include the starting element and all descendants as well
cacheRequest.AddProperty("Name")
cacheRequest.AddProperty("ControlType")
cacheRequest.AddPattern("Window") ; To use cached patterns, first add the pattern
npEl := uCent.FindFirstBuildCache("Name=Search && ControlType=ComboBox",, cacheRequest)
Msgbox, % npEl.Name  => "Search"
;;;;
haystack =
(
1. tag wrangler (bulk tag edit)
2. excalidraw
3. hotkeys++
4. citations
5. ankification
6. calendar
7. advanced tables
8. Kanban board for PM
9. Dataview
10. Sliding Panes
11. Natural Language Dates
12. Editor Syntax Highlight: enable SH in editor mode
13. Underline: support underline to md
14. Highlightr: 
15. PDF Highlights: 
16. Footnote Shortcut: create foodnote
17. Zoom
18. 
)
msgbox, % clipboard := RegExReplace(haystack, "`nm)^\d{1, 2}\.\s?",, vOcc)

;;;;Common logic gates

NOT gate::
if (input=On?outputOff:outputOn)

AND gate::
if (inputA=On && inputB=On)
	output=On
else
	output=Off

OR gate::
if (inputA=On || inputB=On)
	output=On
else 
	output=Off

XOR Gate::
if (inputA=On || inputB=On) && !(inputA=On && inputB=On)
	output=On
else
	output=Off

NAND gate::
if (inputA=On && inputB=On)
	output=Off
else 
	output=On

XNOR gate::
If (inputA=inputB)
	output=On
else 
	output=Off

;;;;
WinGet, winList, List,                ;Get titles of all running and visible windows
Loop, %winList% {
	ID := winList%A_Index%              ;winList is an pseudo-array
	WinGetTitle, title, % "ahk_id" ID
	If (title!="")
		Msgbox, % title
}                             
;;;;
#Include <Chrome.ahk_v1.2\Chrome>    
;~~~With default profile
if (Chromes := Chrome.FindInstances())							 ;Find running instances of Chrome and return their DebugPorts
	Cent := {"base": Chrome, "DebugPort": Chromes.MinIndex()}    ;use first instance's DebugPort to create 'Cent' object
else
	Error! Please check if Cent is in debug mode!
Page := Cent.GetPage()     
;~~~With alternate profile
FileCreateDir, ChromeProfile         ;create ChromeProfile in WorkingDir 
Cent := new Chrome(ChromeProfile)    ;load profile
;~~~Use running instance if exists, else create new Profile
if (Chromes := Chrome.FindInstances())
	ChromeInst := {"base": Chrome, "DebugPort": Chromes.MinIndex()}
else
	ChromeInst := new Chrome(ProfilePath)
;new Chrome(ProfilePath, URLs := "about:blank", Flags, ChromePath, DebugPort)
;URLs are those loaded when ChromeIns opens
;~~~Work with current tab
Page := Cent.GetPage()		;call GetPage() method and return value to TabInst
;in this case create 'TabInst' as an object representing current tab
Page.Evaluate("alert('hi!');")      ;Evaluate("JSCode") =>  run JSCode on the page
;Evaluate("alert(""some text"");")  or  Evaluate("alert('some text');")
jsCode := "prompt(""Please enter your name"", ""Harry Potter"");"
Page.Evaluate(jsCode)
;;Method list
Chrome.FindInstances()     ;find running instances of Chrome
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetPageList()  ;
pageList := Cent.GetPageList()				  ;retrieve pageList as an array	
for n, pageData in pageList 				  ;pageList includes additional extension background pages (can be excluded to keep only visible pages)
	Msgbox, % n " is " pageData["url"] 
	;or Msgbox, % n " is " pageData["title"]
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetPageBy(Key, Value, MatchMode := "exact", Index := 1, fnCallback := "") ;
Key =>  "url"/"title"/"type"
Value =>  value corresponds to key
MatchMode =>  "exact"/"contains"/"startswith"/"regex"
Index =>  index of the match to return in case there're multiple matches
fnCallback =>  func to be called whenever message is receive from the page
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetPageByURL(Value, MatchMode := "startswith", Index := 1, fnCallback := "")
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetPageByTitle(Value, MatchMode := "startswith", Index := 1, fnCallback := "")
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GetPage(Index := 1, Type := "page", fnCallback := "")
Page := GetPage()							;connect to active tab
Page := GetPage(2)   					    ;2nd recently activated tab
Page.Evaluate("alert('hello there!');")     ;alert in 2nd tab without activating it
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Call("Domain.xMethod", Params := "", WaitForResponse := True)
Params =>  an associative array of params     ;for reference: https://chromedevtools.github.io/devtools-protocol/tot/Page/#method-printToPDF
;;
Base64PDF := PageInst.Call("Page.printToPDF", {"printBackground":Chrome.Jxon_True(), "landscape": Chrome.Jxon_True()}).data
;;
PageInst.Call("Page.printToPDF", {"scale": 0.5 ; Numeric Value
, "landscape": Chrome.Jxon_True() ; Boolean Value
, "pageRanges: "1-5, 8, 11-13"}) ; String value
;;
Page.Call("Page.navigate", {"url": "https://autohotkey.com/"})
Page.WaitForLoad()
;;
Page := Cent.GetPage(2)
sleep, 2000
Page.Call("Page.bringToFront")			;activate Page
Page.Call("Page.reload")                ;[hard reload, JStoEvaluateafterReload]
Page.Call("Page.close")					;close page
;; select and click an element based on CSS selector

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Evaluate()

;;
Page.Evaluate("document.getElementById('fname').value = 'Jack'") ;set value to input text element
Page.Evaluate("editor.setValue('test');")
Page.Evaluate("alert('Hello World!');")
Page.Evaluate("document.getElementsByTagName('button')[0].click();")
Page.Evaluate("document.getElementById(""pnprev"").click()")
Page.Evaluate("document.querySelectorAll('nav#p-lang li.interlanguage-link.interwiki-fr.mw-list-item > a > span')[0].click()")
;;document.querySelectorAll('CSSSelector1[, Selector2, Select3...]')  =>  JS method for HTML DOM
;reference: https://tinyurl.com/2xqoblnt, https://tinyurl.com/ozq47rc, 
;=>  return the Nodelist (an array), [0] to retrieve the first match (JS has zero-base indexing)
;el.click()  =>  click on an element
;el.focus()  =>  not visible by default (can check by Enter)

;querySelectorAll(), querySelector()
querySelectorAll('input[value][type = "checkbox"]:not([value = ""])')     
;get all "input" elements with the attribute "value" (not blank) and attribute "type"='checkbox'
querySelector("style[type='text/css'], style:not([type])");
"[aria-label=Options][role=button]"					; attr='value' doesn't work due to quote incompatibility
elementToggle("button[class='vjs-play-control vjs-control vjs-button vjs-paused'][title=Play]"
, "button[class='vjs-play-control vjs-control vjs-button vjs-playing'][title=Pause]")
;single quotes are required if attribute's value contains spaces
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WaitForLoad(DesiredState := "complete", Interval := 100)
;wait for the page to load completely; recommended after Page.navigate
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Kill() ;kill Chrome process by PID
;~~~~Additional functions
clickElementSeq(array)
clickElement(Element)



;;;https://www.autohotkey.com/boards/viewtopic.php?t=73273





