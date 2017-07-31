#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\ico\rotary_encoder_index_disc.jpg.ico
#AutoIt3Wrapper_Outfile=dysk x.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=Cezar z IT
#AutoIt3Wrapper_Res_Description=Cezar z IT
#AutoIt3Wrapper_Res_Fileversion=1.2.1.26
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Cezar z IT
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Res_Field=Cezar z IT|Cezar z IT
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <MsgBoxConstants.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <Array.au3>

Global $hQuery, $aRow, $aResult, $aNames, $listRout, $listRoutZamienNa
Global $sFileSelectFolder = FileSelectFolder("Select a start index folder", "")
Global $sSqlLitePatch = @ScriptDir & "\"
$listRout = $sFileSelectFolder
$listRoutZamienNa = $sFileSelectFolder



_SQLite_Startup($sSqlLitePatch & "sqlite3.dll", False, 1)
$DatabaseH = _SQLite_Open($sSqlLitePatch & "Baza.db")
_SQLite_Exec(-1, "DROP TABLE Indexy;") ; Remove the table
_SQLite_Exec(-1, "CREATE TABLE Indexy (a);") ; CREATE a Table

_SQLite_Exec(-1, "DROP TABLE Data;") ; Remove the table
_SQLite_Exec(-1, "CREATE TABLE Data (a);") ; CREATE a Table

ToolTip("Trwa indeksowanie dysku " & $listRout, 0, 0)

_SQLite_Exec(-1, "INSERT INTO Data(a) VALUES ('" & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & "');")

_filelist($listRout)

_SQLite_Exec(-1, "DROP TABLE szybkaTabela;")
_SQLite_Exec(-1, "CREATE VIRTUAL TABLE szybkaTabela USING fts3(a);")
_SQLite_Exec(-1, "Insert into szybkaTabela(a) select a from Indexy;")
_SQLite_Close(-1)
_SQLite_Shutdown()
MsgBox(0, "", "Skonczono indeksowanie dysku " & $listRout & "Wyniki Zapisano", 20)

Func _filelist($searchdir)
	$search = FileFindFirstFile($searchdir & "\*.*")
	If $search = -1 Then Return -1
	While 1
		$file = FileFindNextFile($search)
		If @error Then

			FileClose($search)
			Return
		ElseIf $file = "." Or $file = ".." Then
			ContinueLoop
		ElseIf StringInStr(FileGetAttrib($searchdir & "\" & $file), "D") Then
			_filelist($searchdir & "\" & $file)

		EndIf


		_SQLite_Exec(-1, 'INSERT INTO Indexy(a) VALUES ("' & StringReplace($searchdir, $listRout, $listRoutZamienNa) & "\" & $file & '");')

	WEnd
EndFunc   ;==>_filelist

Func CzyscBiale($string)
	For $x = 0 To 255
		If $x > 47 And $x < 58 Then ContinueLoop
		If $x > 64 And $x < 91 Then ContinueLoop
		If $x > 96 And $x < 123 Then ContinueLoop
;~ ConsoleWrite( $x & " =>  "& chr($x) & @crlf)
		$string = StringReplace($string, Chr($x), "_")
	Next
	Return $string
EndFunc   ;==>CzyscBiale
