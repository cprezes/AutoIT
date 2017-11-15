#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\ico\footer_logo.jpg.ico
#AutoIt3Wrapper_Outfile=To_UTF8_converter.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/om /cn=0 /cs=0 /sf=1 /sv=1
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters= /so /pe /rm /rsln
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=Cezar z IT
#AutoIt3Wrapper_Res_Description=Cezar z IT
#AutoIt3Wrapper_Res_Fileversion=0.2.1.36
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Cezar z IT
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Res_Field=Cezar z IT|Cezar z IT
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****



Local $msg
GUICreate("Konwerter UTF8 by CEZAR", 320, 150, -1, -1, -1, $WS_EX_ACCEPTFILES)
$button = GUICtrlCreateButton(">> Drop your file on this place <<", 10, 10, 300, 130) ;Drop TXT file
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
GUISetState(@SW_SHOW)
While 1
	$msg = GUIGetMsg()
	If $msg = $GUI_EVENT_DROPPED Then

		$wynik = StringRight(@GUI_DragFile, 3)
		If $wynik = "txt" Then
			Call("zmien", @GUI_DragFile)
		Else
			MsgBox(0, "Info", "Plik musi być w formacie TXT", 5)
		EndIf

	EndIf
	If $msg = $GUI_EVENT_CLOSE Then ExitLoop
WEnd
GUIDelete()

Func Asc2Unicode($UniString)
	If Not IsBinary($UniString) Then
		SetError(1)
		Return $UniString
	EndIf

	Local $UniStringLen = StringLen($UniString)
	Local $BufferLen = $UniStringLen * 2
	Local $Input = DllStructCreate("byte[" & $BufferLen & "]")
	Local $Output = DllStructCreate("char[" & $BufferLen & "]")
	DllStructSetData($Input, 1, $UniString)
	Local $Return = DllCall("kernel32.dll", "int", "WideCharToMultiByte", _
			"int", 65001, _
			"int", 0, _
			"ptr", DllStructGetPtr($Input), _
			"int", $UniStringLen / 2, _
			"ptr", DllStructGetPtr($Output), _
			"int", $BufferLen, _
			"int", 0, _
			"int", 0)
	Local $Utf8String = DllStructGetData($Output, 1)
	$Output = 0
	$Input = 0
	Return $Utf8String
EndFunc   ;==>Asc2Unicode

Func _ConvertAnsiToUtf8($sText)
	Local $tUnicode = _WBD_WinAPI_MultiByteToWideChar($sText)
	If @error Then Return SetError(@error, 0, "")
	Local $sUtf8 = _WBD_WinAPI_WideCharToMultiByte(DllStructGetPtr($tUnicode), 65001)
	If @error Then Return SetError(@error, 0, "")
	Return SetError(0, 0, $sUtf8)
EndFunc   ;==>_ConvertAnsiToUtf8

Func _WBD_WinAPI_MultiByteToWideChar($sText, $iCodePage = 0, $iFlags = 0)
	Local $iText, $pText, $tText

	$iText = StringLen($sText) + 1
	$tText = DllStructCreate("wchar[" & $iText & "]")
	$pText = DllStructGetPtr($tText)
	DllCall("Kernel32.dll", "int", "MultiByteToWideChar", "int", $iCodePage, "int", $iFlags, "str", $sText, "int", $iText, "ptr", $pText, "int", $iText)
	If @error Then Return SetError(@error, 0, $tText)
	Return $tText
EndFunc   ;==>_WBD_WinAPI_MultiByteToWideChar

Func _WBD_WinAPI_WideCharToMultiByte($pUnicode, $iCodePage = 0)
	Local $aResult, $tText, $pText

	$aResult = DllCall("Kernel32.dll", "int", "WideCharToMultiByte", "int", $iCodePage, "int", 0, "ptr", $pUnicode, "int", -1, "ptr", 0, "int", 0, "int", 0, "int", 0)
	If @error Then Return SetError(@error, 0, "")
	$tText = DllStructCreate("char[" & $aResult[0] + 1 & "]")
	$pText = DllStructGetPtr($tText)
	$aResult = DllCall("Kernel32.dll", "int", "WideCharToMultiByte", "int", $iCodePage, "int", 0, "ptr", $pUnicode, "int", -1, "ptr", $pText, "int", $aResult[0], "int", 0, "int", 0)
	If @error Then Return SetError(@error, 0, "")
	Return DllStructGetData($tText, 1)
EndFunc   ;==>_WBD_WinAPI_WideCharToMultiByte

Func zmien($File)

	$File1 = FileOpen($File, 4) ; 4 - raw read mode
	$Unicode = FileRead($File1, FileGetSize($File))
	$AscString = _ConvertAnsiToUtf8($Unicode)
	FileClose($File1)

	zapisz($AscString, $File)
EndFunc   ;==>zmien


Func zapisz($File, $nazwaPliku = @ScriptDir & "\FileWrite.txt")
	; Create a constant variable in Local scope of the filepath that will be read/written to.
	Local Const $wynik = StringMid($nazwaPliku, 1, StringLen($nazwaPliku) - 4)
	Local Const $sFilePath = $wynik & "_utf8.txt"

	Local $hFileOpen = FileOpen($sFilePath, $FO_APPEND)
	If $hFileOpen = -1 Then
		MsgBox($MB_SYSTEMMODAL, "", "Nie mogę odczytać pliku.")
		Return False
	EndIf


	FileWrite($hFileOpen, $File)
	FileClose($hFileOpen)


	MsgBox($MB_SYSTEMMODAL, "", "Plik zapisany w lokalizacji:" & @CRLF & $sFilePath, 5)


EndFunc   ;==>zapisz

Func FileCreate($sFilePath, $sString)
	Local $bReturn = True ;
	If FileExists($sFilePath) = 0 Then $bReturn = FileWrite($sFilePath, $sString) = 1
	Return $bReturn
EndFunc   ;==>FileCreate


