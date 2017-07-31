#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\ico\lupa.ico
#AutoIt3Wrapper_Outfile=Wyszukiwarka.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=Wyszukiwarka
#AutoIt3Wrapper_Res_Description=Wyszukiwarka
#AutoIt3Wrapper_Res_Fileversion=1.2.1.30
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Res_LegalCopyright=Cezar z IT
#AutoIt3Wrapper_Res_Field=Cezar z IT|Cezar z IT
#AutoIt3Wrapper_Res_Comment=Cezar z IT
#AutoIt3Wrapper_Res_Description=Cezar z IT
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <array.au3>
#include <string.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <GUIListBox.au3>
#include <File.au3>
#include <AVIConstants.au3>
#include <GuiConstantsEx.au3>
#include <TreeViewConstants.au3>
#include <GUIConstants.au3>
#include <Process.au3>
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <Array.au3>

$sSqlLitePatch = @ScriptDir & "\"

Local $aResult, $iRows, $iColumns, $iRval, $hQuery, $aRow
HotKeySet("{ESC}", "Terminate")
$dataPliku = ""
Dim $a_Results[1]
$a_Results[0] = 0

Global $with = @DesktopWidth * 0.5
Global $height = @DesktopHeight * 0.8



$s_SearchString = InputBox("Wyszukiwarka by Cezar", "Szybka wyszukiwarka plików na dysku X " & _
		@LF & "Jest możliwość umieszczenie takiej wyszukiwarki na innych folderach sieciowych" & @LF & "W razie zapotrzebowania proszę o kontakt Pozdrawiamy dział IT.  " & @LF & @LF & @LF & "Wpisz nazwę lub fragment nazwy szukanego pliku:", "", "", 500, 180)

If @error Then
	If @error = 1 Then Exit

	MsgBox(0, "Error", "Nic nie wpisałeś :)")
	Exit
EndIf
ToolTip("Szukanie Wyrazu" & @LF & _
		$s_SearchString & @LF & @LF)


_SQLite_Startup($sSqlLitePatch & "sqlite3.dll", False, 1)
$DatabaseH = _SQLite_Open($sSqlLitePatch & "Baza.db")


_SQLite_Query(-1, "Select a FROM Data LIMIT 1 ;", $hQuery)
While _SQLite_FetchData($hQuery, $aRow) = $SQLITE_OK ; This get 1 row at a time
	$dataPliku = $aRow[0]
WEnd
_SQLite_QueryFinalize($hQuery)



$iRval = _SQLite_GetTable(-1, "SELECT * FROM szybkaTabela where a Match '" & $s_SearchString & "';", $aResult, $iRows, $iColumns)

If $iRval = $SQLITE_OK Then
	ToolTip("")
	closeDB()
	okienko($aResult)
Else
	ToolTip("")
	MsgBox($MB_SYSTEMMODAL, "SQL Error: " & $iRval, _SQLite_ErrMsg())
	Exit 0
EndIf


Func closeDB()
	_SQLite_QueryFinalize($aResult)
	_SQLite_Close(-1)
	_SQLite_Shutdown()
EndFunc   ;==>closeDB



Func Terminate()
	MsgBox(0, "Abort", "Przerwano")
	Exit 0
EndFunc   ;==>Terminate

Func noweWyszukiwanie()

	Run(@ScriptDir & "\" & @ScriptName)
	Exit 0

EndFunc   ;==>noweWyszukiwanie

Func okienko($array)
	$dateien = $array
	; Create GUI
	$hGUI = GUICreate("Wyszukiwarka by Cezar", $with, $height, @DesktopWidth * 0.25, @DesktopHeight * 0.1, $WS_MINIMIZEBOX + $WS_SIZEBOX)
	GUICtrlCreateLabel("Znaleziono " & $array[0] - 1 & "  wyników. Szukano: " & $s_SearchString & ". Ostatnia aktualizacja " & $dataPliku, 5, 5)
	GUICtrlSetResizing(-1, 768)
	$hListBox = GUICtrlCreateList("", 5, 25, $with - 12, $height - 75, $GUI_SS_DEFAULT_LIST)
	GUICtrlSetResizing(-1, 102)
	$btn_sel_all = GUICtrlCreateButton("Otwórz", 10, $height - 50, 80)
	$btn_new = GUICtrlCreateButton("Nowe Wyszukiwanie", 100, $height - 50, 120)
	$btn_copy = GUICtrlCreateButton("Kopiuj lokalizacje", $with - 220, $height - 50, 100)
	$btn_transfer = GUICtrlCreateButton("Przejdź do folderu", $with - 110, $height - 50, 100)
	GUICtrlSetResizing($btn_new, 2 + 64 + 768)
	GUICtrlSetResizing($btn_sel_all, 2 + 64 + 768)

	GUICtrlSetResizing($btn_copy, 4 + 64 + 768)
	GUICtrlSetResizing($btn_transfer, 4 + 64 + 768)
	GUISetState()

	; Add strings
	_GUICtrlListBox_BeginUpdate($hListBox)
	For $i = 2 To UBound($dateien) - 1
		_GUICtrlListBox_AddString($hListBox, $dateien[$i])
	Next
	_GUICtrlListBox_EndUpdate($hListBox)

	While 1
		$msg = GUIGetMsg()
		Select
			Case $msg = $GUI_EVENT_CLOSE
				Exit
			Case $msg = $btn_sel_all
				$selected = ''
				For $i = 0 To _GUICtrlListBox_GetCount($hListBox) - 1
					If _GUICtrlListBox_GetSel($hListBox, $i) Then
						$selected &= _GUICtrlListBox_GetText($hListBox, $i)
					EndIf
				Next
;~ 				MsgBox(0, "Selected items1", $selected)
				ClipPut($selected)
				ShellExecute($selected)
			Case $msg = $btn_transfer
				$selected = ''
				For $i = 0 To _GUICtrlListBox_GetCount($hListBox) - 1
					If _GUICtrlListBox_GetSel($hListBox, $i) Then
						$selected &= _GUICtrlListBox_GetText($hListBox, $i)
					EndIf
				Next
				open($selected)
			Case $msg = $btn_copy
				$selected = ''
				For $i = 0 To _GUICtrlListBox_GetCount($hListBox) - 1
					If _GUICtrlListBox_GetSel($hListBox, $i) Then
						$selected &= _GUICtrlListBox_GetText($hListBox, $i)
					EndIf
				Next
				ClipPut($selected)
				MsgBox(0, "", "Skopiowano " & @LF & $selected, 3)
			Case $msg = $btn_new
				noweWyszukiwanie()
		EndSelect
	WEnd


EndFunc   ;==>okienko

Func open($sParam)
	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sParam, $sDrive, $sDir, $sFileName, $sExtension)
	Run('explorer.exe "' & $sDrive & $sDir & '"')
EndFunc   ;==>open

