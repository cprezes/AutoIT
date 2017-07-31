#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\ico\lupa.ico
#AutoIt3Wrapper_Outfile=Wyszukiwarka.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=Wyszukiwarka
#AutoIt3Wrapper_Res_Description=Wyszukiwarka
#AutoIt3Wrapper_Res_Fileversion=1.2.1.26
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

HotKeySet("{ESC}", "Terminate")
$dataPliku = ""
Dim $a_Results[1]
$a_Results[0] = 0

; Select file
;~ $Path = FileOpenDialog("Select the file to search", @WorkingDir & "\", "All Files (*.*)")
;~ If @error Then
;~     MsgBox(0, "Error", "Failed to locate file")
;~     Exit
;~ EndIf

;~ $Path = "\\nas01.mostwar1.local\Index$\dysk_x.txt"
$Path = FileOpenDialog("Wybierz plik do przeszukania", @ScriptDir & "\", "All (*.*)", $FD_FILEMUSTEXIST)
If @error Then
	; Display the error message.
	MsgBox($MB_SYSTEMMODAL, "", "No file was selected.")
	Exit 0
EndIf

; Request search string from the user
$s_SearchString = InputBox("Wyszukiwarka by Cezar", "Podstawowa wersja wyszukiwarki plików na dysku X jeżeli " & _
		"wyszukiwarka biedzie używana projekt będzie rozwijany. Pozdrawiamy IT.  " & @LF & @LF & "Wpisz nazwę szukanego pliku:")
If @error Then
	MsgBox(0, "Error", "Nic nie wpisałeś :)")
	Exit
EndIf

; Find the Average number of Characters (Bytes) Per Line from a sample of the file
$i_FileSize = FileGetSize($Path)
$h_file = FileOpen($Path, 0)
If $h_file = -1 Then
	MsgBox(0, "Error", "Nie moge znaleść pliku z indekem: " & $Path)
	Exit
EndIf
$i_bytes = 0
For $i = 1 To 50000 ; the 50k is arbitrary, but I found it took less than half a second to complete
	$line = FileReadLine($h_file)
	If @error = -1 Then ExitLoop
	$i_bytes += StringLen($line)
Next
FileClose($h_file)
$n_ABPL = $i_bytes / $i ; Average Bytes Per Line
$intResulsStop = 0 ;
; Re-open the file and begin search
$h_file = FileOpen($Path, 0)
$i_LineCount = 0
$i_sub = 0
While 1
	$line = FileReadLine($h_file)
	If @error = -1 Then ExitLoop
	$i_LineCount += 1
	$i_sub += 1
	If $i_LineCount = 1 Then $dataPliku = $line
	Select
		Case StringInStr($line, $s_SearchString) ; if string is found add it to the array
			_ArrayAdd($a_Results, $line)
			$a_Results[0] += 1
			$intResulsStop += 1
			If $intResulsStop = 5000 Then
				$a_Results[0] = "ponad 5000"
				ExitLoop
			EndIf
		Case $i_sub >= 5000 ; every 5k lines update the tooltip
			$n_Estimate = Int($i_LineCount * $n_ABPL)
			$prog = _StringAddThousandsSepEx($n_Estimate) & " / " & _StringAddThousandsSepEx($i_FileSize)
			$msg = "Szukam Wyrazu" & @LF & _
					$s_SearchString & @LF & @LF & _
					"Przeszukiwanie indeksów: " & $prog
			ToolTip($msg)
			$i_sub = 0
	EndSelect
WEnd
ToolTip("")

okienko($a_Results)

Func Terminate()
	MsgBox(0, "Abort", "Przerwano")
	Exit
EndFunc   ;==>Terminate



; #FUNCTION# ====================================================================================================================
; Name...........: _StringAddThousandsSepEx
; Description ...: Returns the original numbered string with the Thousands delimiter inserted.
; Syntax.........: _StringAddThousandsSep($sString[, $sThousands = -1[, $sDecimal = -1]])
; Parameters ....: $sString    - The string to be converted.
;                  $sThousands - Optional: The Thousands delimiter
;                  $sDecimal   - Optional: The decimal delimiter
; Return values .: Success - The string with Thousands delimiter added.
; Author ........: SmOke_N (orignal _StringAddComma
; Modified.......: Valik (complete re-write, new function name), KaFu (copied from 3.3.0.0, as function is deprecated in newer AU versions)
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; Yes
; ===============================================================================================================================
Func _StringAddThousandsSepEx($sString, $sThousands = -1, $sDecimal = -1)
	Local $sResult = "" ; Force string
	Local $rKey = "HKCU\Control Panel\International"
	If $sDecimal = -1 Then $sDecimal = RegRead($rKey, "sDecimal")
	If $sThousands = -1 Then $sThousands = RegRead($rKey, "sThousand")
;~  Local $aNumber = StringRegExp($sString, "(\d+)\D?(\d*)", 1)
	Local $aNumber = StringRegExp($sString, "(\D?\d+)\D?(\d*)", 1) ; This one works for negatives.
	If UBound($aNumber) = 2 Then
		Local $sLeft = $aNumber[0]
		While StringLen($sLeft)
			$sResult = $sThousands & StringRight($sLeft, 3) & $sResult
			$sLeft = StringTrimRight($sLeft, 3)
		WEnd
;~      $sResult = StringTrimLeft($sResult, 1) ; Strip leading thousands separator
		$sResult = StringTrimLeft($sResult, StringLen($sThousands)) ; Strip leading thousands separator
		If $aNumber[1] <> "" Then $sResult &= $sDecimal & $aNumber[1]
	EndIf
	Return $sResult
EndFunc   ;==>_StringAddThousandsSepEx

; Note that the user function MUST have TWO parameters even if you do not intend to use both of them

Func okienko($array)

	$dateien = $array
	$with = @DesktopWidth * 0.5
	$height = @DesktopHeight * 0.8
	; Create GUI

	$hGUI = GUICreate("Wyszukiwarka by Cezar", $with, $height, @DesktopWidth * 0.25, @DesktopHeight * 0.1, $WS_MINIMIZEBOX + $WS_SIZEBOX)
	GUICtrlCreateLabel("Znaleziono " & $array[0] & "  wyników. Ostatnia aktualizacja " & $dataPliku, 5, 5)
	$hListBox = GUICtrlCreateList("", 5, 25, $with - 12, $height - 75, $GUI_SS_DEFAULT_LIST)
	GUICtrlSetResizing(-1, 102)
	$btn_sel_all = GUICtrlCreateButton("Otwórz", 10, $height - 50, 80)
	$btn_copy = GUICtrlCreateButton("Kopiuj lokalizacje", (($with - 50) / 2) - 50, $height - 50, 100)
	$btn_transfer = GUICtrlCreateButton("Przejdź do folderu", $with - 160, $height - 50, 150)
	GUICtrlSetResizing($btn_transfer, 64 + 768)
	GUICtrlSetResizing($btn_copy, 64 + 768)
	GUICtrlSetResizing($btn_sel_all, 64 + 768)
	GUISetState()

	; Add strings
	_GUICtrlListBox_BeginUpdate($hListBox)
	For $i = 1 To UBound($dateien) - 1
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
		EndSelect
	WEnd


EndFunc   ;==>okienko

Func open($sParam)
	Local $sDrive = "", $sDir = "", $sFileName = "", $sExtension = ""
	Local $aPathSplit = _PathSplit($sParam, $sDrive, $sDir, $sFileName, $sExtension)
	Run('explorer.exe "' & $sDrive & $sDir & '"')
EndFunc   ;==>open
