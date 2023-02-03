Try{
	oExcel := ComObjActive("Excel.Application") ; Create a connection to an Excel Application object
}
Catch{
	oExcel := ComObjCreate("Excel.Application") ; Create an Excel Application object
	oExcel.Visible := true
}

oWorkSheet := oExcel.ActiveSheet
ComObjActive("Excel.Application").ActiveWindow.SmallScroll(0,0,0,1)
