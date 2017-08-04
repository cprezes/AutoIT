#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\ico\footer_logo.jpg.ico
#AutoIt3Wrapper_Outfile=instlacje.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=Inwentaryzator
#AutoIt3Wrapper_Res_Description=Inwentaryzator Instalacji IT
#AutoIt3Wrapper_Res_Fileversion=1.2.1.8
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Res_LegalCopyright=Cezar z IT
#AutoIt3Wrapper_Res_Field=Cezar z IT|Cezar z IT
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Date.au3>
#include <File.au3>
#include 'array.au3'
$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")

Global Const $HTTP_STATUS_OK = 200
$komp = StringLower(@ComputerName)
$sServerAddress = "http://10.1.1.106/komputery/input.php"



Local $userPach, $flaga


$userPach = EnvGet("systemdrive") & "\users\" & StringLower(_GetUserName("localhost")) & "\"

$flaga = $userPach & "AppData\Local\czyszczono.txt"

Global $czas = _NowCalc()

If FileExists($flaga) Then
	Local $crt = FileGetTime($flaga, 1)
	If Sec_2_Time_Format(_DateDiff("s", $crt[0] & "/" & $crt[1] & "/" & $crt[2] & " 00:00:00", $czas)) > 14 Then FileDelete($flaga)
Else
	If Not _FileCreate($flaga) Then Exit
	If Not FileWrite($flaga, @YEAR & "-" & @MON & "-" & @MDAY & " => " & @UserName) Then Exit




	Local $wynikInwent = "", $a = _ComputerGetSoftware()
	If Not @error Then
;~ 	_Base64Encode(_ArrayToTabela($a))
		$kiedy = @YEAR & "|" & @MON & "|" & @MDAY & " => " & @UserName
		$wynikInwent = czyscPolskie(_ArrayToTabela($a))
		$wynikInwent = zamienTagi($wynikInwent)

		$wynikInwent = CzyscBiale($wynikInwent)
		$Request = "nazwa=" & $komp & "&kiedy=" & _Base64Encode($kiedy) & "&instalacje=" & _Base64Encode($wynikInwent)
		HttpPost($sServerAddress, $Request)
		If @error Then Exit
	EndIf
	Exit


EndIf
Exit



Func czyscPolskie($napis)
	Local $Literki[17][2] = [["ę", "e"], ["ó", "o"], ["ł", "l"], ["ś", "s"], ["ą", "a"], ["ż", "z"], ["ź", "z"], ["ć", "c"], ["ń", "n"], ["Ę", "E"], ["Ó", "O"], ["Ł", "L"], ["Ś", "S"], ["Ą", "A"], ["Ż", "Z"], ["Ć", "C"], ["Ń", "N"]]
	For $licznik = 0 To 16
		$napis = StringReplace($napis, $Literki[$licznik][0], $Literki[$licznik][1], 0, 1)
	Next
	Return $napis
EndFunc   ;==>czyscPolskie

Func _ComputerGetSoftware()

	Switch @OSArch
		Case 'X64'
			Local $sHKCU = 'HKEY_CURRENT_USER64', $sHKLM = 'HKEY_LOCAL_MACHINE64'
			Local $sSubKey1 = '\Software\Microsoft\Windows\CurrentVersion\Uninstall'
			Local $sSubKey2 = '\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
			Local $aKeys[4] = [3, $sHKCU & $sSubKey1, $sHKLM & $sSubKey1, $sHKLM & $sSubKey2]
		Case 'X86'
			Local $sHKCU = 'HKEY_CURRENT_USER', $sHKLM = 'HKEY_LOCAL_MACHINE'
			Local $sSubKey = '\Software\Microsoft\Windows\CurrentVersion\Uninstall'
			Local $aKeys[3] = [2, $sHKCU & $sSubKey, $sHKLM & $sSubKey]
		Case Else
			Return SetError(1)
	EndSwitch

	Local $array[5001][6] = [[5000, 'DisplayVersion', 'Publisher', 'InstallDate', 'MSI', 'NoRemove']]
	Local $sAppKey, $sDisplayName, $sKey, $UnInstKey, $index = 0

	For $i = 1 To $aKeys[0]
		$sKey = $aKeys[$i]
		For $j = 1 To $array[0][0]
			$sAppKey = RegEnumKey($sKey, $j)
			If @error Then ExitLoop
			$UnInstKey = $sKey & '\' & $sAppKey
			$sDisplayName = RegRead($UnInstKey, 'DisplayName')
			Select
				Case @error
				Case Not StringLen(StringStripWS($sDisplayName, 8))
				Case StringRegExp($sDisplayName, '(?i)(KB\d+)')
				Case RegRead($UnInstKey, 'SystemComponent')
				Case RegRead($UnInstKey, 'ParentKeyName')
				Case Else
					$index += 1
					$array[$index][0] = StringStripWS(StringReplace($sDisplayName, ' (remove only)', ''), 3)
					$array[$index][1] = StringStripWS(RegRead($UnInstKey, 'DisplayVersion'), 3)
					$array[$index][2] = StringStripWS(RegRead($UnInstKey, 'Publisher'), 3)
;~                     $array[$index][3] = StringStripWS(RegRead($UnInstKey, 'UninstallString'), 3)
					$array[$index][3] = StringStripWS(RegRead($UnInstKey, 'InstallDate'), 3)
					$array[$index][4] = StringStripWS(RegRead($UnInstKey, 'WindowsInstaller'), 3) = 1
					$array[$index][5] = StringStripWS(RegRead($UnInstKey, 'NoRemove'), 3) = 1
			EndSelect
		Next
	Next

	ReDim $array[$index + 1][6]
	$array[0][0] = "AppName"
	_ArraySort($array, 0, 1)
	Return $array
EndFunc   ;==>_ComputerGetSoftware




Func _ArrayToTabela(ByRef $aArray)
	If Not IsArray($aArray) Then Return SetError(1, 0, -1)
	Local $sOutput = "<table border=1>"
	Local $iCase = 0

	For $i = 0 To UBound($aArray, 1) - 1
		$sOutput &= '<tr>'
		For $j = 0 To UBound($aArray, 2) - 1
			$sOutput &= (($i = 0) ? '<th>' : '<td>')
			$sOutput &= $aArray[$i][$j]
			$sOutput &= (($i = 0) ? '</th>' : '</td>')
		Next
		$sOutput &= '</tr>'
	Next
	$sOutput &= '</table>'
	Return $sOutput
EndFunc   ;==>_ArrayToTabela



Func CzyscBiale($string)
	For $x = 0 To 255
		If $x = 32 Or $x = 61 Or $x = 94 Or $x = 92 Or $x = 96 Then ContinueLoop
		If $x > 42 And $x < 58 Then ContinueLoop
		If $x > 64 And $x < 123 Then ContinueLoop
;~ ConsoleWrite( $x & " =>  "& chr($x) & @crlf)
		$string = StringReplace($string, Chr($x), "")
	Next
	Return $string
EndFunc   ;==>CzyscBiale

Func zamienTagi($string)
	$string = StringReplace($string, "<", "[+]")
	$string = StringReplace($string, ">", "[-]")
	Return $string
EndFunc   ;==>zamienTagi



Func MyErrFunc()
	$HexNumber = Hex($oMyError.number, 8)
	Return wyjdz()
EndFunc   ;==>MyErrFunc

Func wyjdz($wy1 = "", $wy2 = "", $wy3 = "")
	Exit 0
EndFunc   ;==>wyjdz



Func HttpPost($sURL, $sData = "")
	Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1", "MyErrFunc")

	$oHTTP.Open("POST", $sURL, False)
	If (@error) Then wyjdz(1, 0, 0)

	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")

	$oHTTP.Send($sData)
	If (@error) Then Exit

	If ($oHTTP.Status <> $HTTP_STATUS_OK) Then wyjdz(3, 0, 0)

EndFunc   ;==>HttpPost



Func _Base64Encode($sData)
	Local $oXml = ObjCreate("Msxml2.DOMDocument")
	If Not IsObj($oXml) Then
		wyjdz(1, 1, 0)
	EndIf

	Local $oElement = $oXml.createElement("b64")
	If Not IsObj($oElement) Then
		wyjdz(2, 2, 0)
	EndIf

	$oElement.dataType = "bin.base64"
	$oElement.nodeTypedValue = Binary($sData)
	Local $sReturn = $oElement.Text

	If StringLen($sReturn) = 0 Then
		wyjdz(3, 3, 0)
	EndIf

	Return $sReturn
EndFunc   ;==>_Base64Encode



Func _GetUserName($strClient)
	Local $objWMIService, $objItem, $colItems, $strUser, $strDomain, $Result
	$objWMIService = ObjGet("winmgmts:{impersonationLevel=impersonate}!\\" & $strClient)
	$colItems = $objWMIService.InstancesOf("Win32_Process")
	If IsObj($colItems) Then
		For $objItem In $colItems
			If ($objItem.Caption = "explorer.exe") Then
				$Result = $objItem.GetOwner($strUser, $strDomain)
				If (Not @error) And ($Result = 0) Then Return $strUser
			EndIf
		Next
	EndIf
	Return ""
EndFunc   ;==>_GetUserName




Func Sec_2_Time_Format($iSec) ;coded by UEZ
	Local $days = 0
	Local $sec = Mod($iSec, 60)
	Local $min = Mod(Int($iSec / 60), 60)
	Local $hr = Int($iSec / 60 ^ 2)
	If $hr > 23 Then
		$days = Floor($hr / 24)
		$hr -= $days * 24
	EndIf
	Return StringFormat("%01i", $days)
EndFunc   ;==>Sec_2_Time_Format
