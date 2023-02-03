#Include ../Eval.ahk
#SingleInstance Force
SetBatchLines, -1

; Math Expressions
Expression := "-(2.616700)-193,2**(4*-1+10)/Floor(-1.3) /*`nThis is a multiline comment`n*/,SomeText:=(2<<1)*-3/Sin(4),1+5*3 `;this is a single line comment`n . "" Appended line"""
Result := Eval(Expression)
r := StrJoin(Result, "`n")
MsgBox, 1, Math Expression, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" r
IfMsgBox, Cancel, ExitApp

; Operators 
Expression := "VarY:=10, (VarY*2)>40||(VarY<20), VarY<0, VarY<=10 AND VarY<>0, VarY^=3"
Result := Eval(Expression)
r := StrJoin(Result, "`n")
MsgBox, 1, Operators, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" r
IfMsgBox, Cancel, ExitApp

; Variable Assignment
Expression := "A := 100, B := A - 5 - 10 - 15, B, C := A - B - 5, VarA := 123,VarB := VarA - 23,VarX := ""First,Second,Third,Fourth"""
Result := Eval(Expression)
r := StrJoin(Result, "`n")
MsgBox, 1, Variable Assignment, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" r
IfMsgBox, Cancel, ExitApp

; String & Function
Expression := """Result is:`n"" . SubStr(VarX, 6)"
Result := Eval(Expression)
MsgBox, 1, String & Function, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" Result[1]
IfMsgBox, Cancel, ExitApp

; Function Returning Object
Expression := "VarY := StrSplit(VarX, "","")"
Result := Eval(Expression)
r := ""
For k, v in VarY
	r .= "VarY." k ": " v "`n"
MsgBox, 1, Function Returning Object, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" r
IfMsgBox, Cancel, ExitApp

; StrSplit() without Assignment
Expression := "StrSplit(VarX, "","")[2]"
Result := Eval(Expression)
MsgBox, 1, StrSplit() without Assignment, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" Result[1]
IfMsgBox, Cancel, ExitApp

; Nested Functions
Expression := "SubStr(StrReplace(""a,b,c,d,e"", "",""), 3)"
Result := Eval(Expression)
MsgBox, 1, Nested Functions, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" Result[1]
IfMsgBox, Cancel, ExitApp

; Custom Variables & Pseudo-Arrays
CVars := {}
StringSplit, VarY, VarX, `,
Loop, %VarY0%
{
	CVars["A_Index"] := A_Index
	MsgBox, 1, Custom Variables & Pseudo-Arrays, % Eval("""A_Index: "" A_Index ""``ny%A_Index%: "" VarY%A_Index%", CVars)[1]
	IfMsgBox, Cancel,	 ExitApp
}

; Create Array Object
Expression := "Fibonacci := [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]"
Result := Eval(Expression)
r := StrJoin(Fibonacci, ", ")
MsgBox, 1, Create Array Object, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" r
IfMsgBox, Cancel, ExitApp

; Object Method
Expression := "Fibonacci.Push(144, 233, 377, 610, 987, 1597, 2584)"
Result := Eval(Expression)
r := StrJoin(Fibonacci, ", ")
MsgBox, 1, Object Method, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" r
IfMsgBox, Cancel, ExitApp

; Sequenced Assignment
Expression := "Fi := Fibonacci.9, Fi += Fi10 := Fibonacci.10"
Result := Eval(Expression)
MsgBox, 1, Sequenced Assignment, % "Expression: `n`n" Expression "`n`n`nResults:`n`nFi: " Fi "`nFi10: " Fi10
IfMsgBox, Cancel, ExitApp

; Create Associative Array Object
Expression := "Person := {Name: ""John"", Age: 25}"
Result := Eval(Expression)
r := ""
For k, v in Person
	r .= "Person." k ": " v "`n"
MsgBox, 1, Create Associative Array Object, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" r
IfMsgBox, Cancel, ExitApp

; Get Object Property
Expression := "Person.Name, Person.Age"
Result := Eval(Expression)
r := StrJoin(Result, "`n")
MsgBox, 1, Get Object Property, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" r
IfMsgBox, Cancel, ExitApp

; Set Object Property and Assign it to a Variable
Expression := "Person.Gender := ""Male"", Gender := Person.Gender"
Result := Eval(Expression)
MsgBox, 1, Set Object Property and Assign it to a Variable, % "Expression: `n`n" Expression "`n`n`nResults:`n`nGender: " Gender
IfMsgBox, Cancel, ExitApp

; Create and Read Multi-dimensional Array
Expression := "Person.Grades := [10,9,8,10], Person[""Grades""][2]"
Result := Eval(Expression)
MsgBox, 1, Create and Read Multi-dimensional Array, % "Expression: `n`n" Expression "`n`n`nResults:`n`n " Result[2]
IfMsgBox, Cancel, ExitApp

; Multi-dimensional Array in [key, key] format
Expression := "Obj := [], Obj[1, ""Pi""] := 3.141593, Obj[1, ""Pi""]"
Result := Eval(Expression)
MsgBox, 1, Multi-dimensional Array in [key`, key] format, % "Expression: `n`n" Expression "`n`n`nResults:`n`n " Result[3]
IfMsgBox, Cancel, ExitApp

; Dynamic function call
Expression := "fn := Func(""StrLen"").Bind(""Test""), %fn%(), fn.Call()"
Result := Eval(Expression)
MsgBox, 1, Dynamic function call, % "Expression: `n`n" Expression "`n`n`nResults:`n`n " Result[2] "`n " Result[3]
IfMsgBox, Cancel, ExitApp

; Ternary Operator
Eval("Level := 4")
Loop, 3
{
	Eval("Level *= 2")
	Expression := """Current Level: "" Level ""`nStatus: "" ((Level >= 10 && Level <= 20) ? ""Normal"" : Level < 10 ? ""Too Low!"" : ""Too High!"")"
	Result := Eval(Expression)
	MsgBox, 1, Ternary Operator, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" Result[1]
	IfMsgBox, Cancel,	 ExitApp
}

; Ternary Operator with Objects
Expression := "Level < Person.Age ? ""Result '"" VarY[1] ""' was found."" : ""Result '"" VarY[2] ""' was found."""
Result := Eval(Expression)
MsgBox, 1, Ternary Operator with objects, % "Expression: `n`n" Expression "`n`n`nResults:`n`n" Result[1]
IfMsgBox, Cancel, ExitApp

; COM Object Expressions
Expression := "ie := ComObjCreate(""InternetExplorer.Application""), ie.Visible := true, ie.Navigate(""www.autohotkey.com/search/"")"
MsgBox, 1, COM Object Expressions, % "Expression: `n`n" Expression "`n`n`nPress OK to execute"
IfMsgBox, Cancel, ExitApp
Result := Eval(Expression)

; Set COM Object Property
Expression := "ie.document.getElementsByName(""search"")[0].Value := ""comobjcreate"""
MsgBox, 1, Set COM Object Property, % "Expression: `n`n" Expression "`n`n`nPress OK to execute"
IfMsgBox, Cancel, ExitApp
Result := Eval(Expression)

; Get COM Object Property
Expression := "Query := ie.document.getElementsByName(""search"")[0].Value"
Result := Eval(Expression)
MsgBox,, Get COM Object Property, % "Expression: `n`n" Expression "`n`n`nResults:`n`nQuery: " Query

