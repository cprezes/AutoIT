#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\ico\history2.ico
#AutoIt3Wrapper_Outfile=Navis_log_parser.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=Navis Licence log parser Cp
#AutoIt3Wrapper_Res_Description=Navis Licence log parser Cp
#AutoIt3Wrapper_Res_Fileversion=1.1.1.21
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Cezar z IT
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Res_Field=Cezar z IT|Cezar z IT
#AutoIt3Wrapper_Add_Constants=n
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs
	Run this script
	Point your browser to http://localhost:8081/
#ce
#include <File.au3>
#include <Array.au3>
#include "TCPServer.au3"



_TCPServer_OnReceive("received")

_TCPServer_DebugMode(False)
_TCPServer_SetMaxClients(10)

_TCPServer_Start(8081)

While 1
	Sleep(1000)
WEnd

Func received($iSocket, $sIP, $sData, $sParam)
	Global $aUserInOut[0], $aUserName[0], $aUserMovement[0], $aUserMovementScore[0]

	_TCPServer_Send($iSocket, czyscPolskie("HTTP/1.0 200 OK" & @CRLF & _
			"Content-Type: text/html" & @CRLF & @CRLF & _
			parseLog() & @CRLF & _
			clearOutUser() & @CRLF & _
			@CRLF & "<br/><br/>v.:" & FileGetVersion(@AutoItExe) & " (Cp)"))
	_TCPServer_Close($iSocket)

	$aUserInOut = 0
	$aUserName = 0
	$aUserMovement = 0
	$aUserMovementScore = 0

EndFunc   ;==>received


Func parseLog()
	Local $aPlik, $line
	Local $sOut = @YEAR & "/" & @MON & "/" & @MDAY & "   " & @HOUR & ":" & @MIN & ":" & @SEC & "</br>" & @CRLF & "<table>"

	Local $file = "c:\Autodesk\Network License Manager\Logs\debug.log"

	If Not _FileReadToArray($file, $aPlik) Then Return ("<center> <h1> Wystąpił błąd: Nie można odczytać pliku log <br> Skontaktuj się z działem IT")
	$ileWierszy = UBound($aPlik) - 10000
	If $ileWierszy < 1 Then $ileWierszy = 1
	For $i = UBound($aPlik) - 1 To $ileWierszy Step -1
		$line = $aPlik[$i]
		If StringInStr($line, "86767NAVSIM_2017_0F") Then
			$sOut = $sOut & "<tr><td> "
			$sOut = $sOut & StringLeft($line, 8) ; godzina
			$sOut = $sOut & "</td><td>"
			If StringInStr(StringRight(StringLeft($line, 26), 10), "IN:") Then
				$sOut = $sOut & " OUT "
				collectUsers(1, -1)
			EndIf
			If StringInStr(StringRight(StringLeft($line, 26), 10), "OUT:") Then
				$sOut = $sOut & " IN "
				collectUsers(1, 1)
			EndIf
			$sOut = $sOut & "</td><td>"
			$sOut = $sOut & StringRight($line, StringLen($line) - StringInStr($line, '" ')) ; login
			collectUsers(2, StringRight($line, StringLen($line) - StringInStr($line, '" ')))
			$sOut = $sOut & "</td></tr>"
			$sOut = $sOut & @CRLF
		EndIf
		If StringInStr(StringLeft($line, 3), " 0:") Then ExitLoop
		If StringInStr(StringLeft($line, 3), "23:") Then ExitLoop
	Next
	$sOut = $sOut & "</table><br/>"
	$sOut = $sOut & @CRLF

	$sOut = StringReplace($sOut, "Licensed number of users already reached", "Brak wolnych licnecji")
	Return $sOut
EndFunc   ;==>parseLog



Func collectUsers($arry, $value)
	If ($arry = 1) Then _ArrayAdd($aUserInOut, StringLower($value))
	If ($arry = 2) Then _ArrayAdd($aUserName, StringLower($value))
EndFunc   ;==>collectUsers


Func showArrays($array1, $array2)
	ConsoleWrite(@CRLF)
	For $i = 0 To UBound($array1) - 1
		ConsoleWrite($array1[$i] & " -> " & $array2[$i] & @CRLF)
	Next

EndFunc   ;==>showArrays

Func debugView()
	ConsoleWrite(czyscPolskie(parseLog()) & @CRLF & clearOutUser())
	showArrays($aUserMovement, $aUserMovementScore)
	Exit 0
EndFunc   ;==>debugView

Func clearOutUser()
	Local $sLoginTmp, $iUserScore, $sOut = "<h3>Konsolidując zgrubnie powyższe, aktualnie pracują:</h3>"
	For $i = UBound($aUserName) - 1 To 0 Step -1
		$iUserScore = 0
		$sLoginTmp = $aUserName[$i]
		For $j = UBound($aUserName) - 1 To 0 Step -1
			If (StringLower($sLoginTmp) = StringLower($aUserName[$j]) And _ArraySearch($aUserMovement, $sLoginTmp) = -1) Then
				$iUserScore = $iUserScore + $aUserInOut[$j]
				If ($iUserScore > 0) Then $iUserScore = 1
				If ($iUserScore < 0) Then $iUserScore = 0
			EndIf

		Next
		If (_ArraySearch($aUserMovement, $sLoginTmp) = -1) Then
			_ArrayAdd($aUserMovement, $sLoginTmp)
			_ArrayAdd($aUserMovementScore, $iUserScore)
		EndIf
	Next
	$sOut = $sOut & @CRLF & "<table>" & @CRLF

	For $i = 0 To UBound($aUserMovementScore) - 1
		If ($aUserMovementScore[$i] > 0) Then
			$sOut = $sOut & "<tr><td>" & @CRLF
			$sOut = $sOut & formatDane(StringLeft($aUserMovement[$i], StringInStr($aUserMovement[$i], "@") - 1))
			$sOut = $sOut & " -> " & StringUpper(StringMid($aUserMovement[$i], StringInStr($aUserMovement[$i], "@") + 1))
			$sOut = $sOut & @CRLF & "</tr></td> "
		EndIf
	Next

	$sOut = $sOut & "</table>"
	Return $sOut
EndFunc   ;==>clearOutUser


Func czyscPolskie($napis)

	Local $Literki[18][2] = [["ą", "&#x0105;"], ["ę", "&#x0119;"], ["ó", "&#x00F3;"], ["ł", "&#x0142;"], ["ś", "&#x015B;"], ["ż", "&#x017C;"], ["ź", "&#x017A;"], ["ć", "&#x0107;"], ["ń", "&#x0144;"], ["Ę", "&#x0118;"], ["Ą", "&#x0104;"], ["Ó", "&#x00D3;"], ["Ł", "&#x0141;"], ["Ś", "&#x015A;"], ["Ź", "&#x0179;"], ["Ż", "&#x017B;"], ["Ć", "&#x0106;"], ["Ń", "&#x0143;"]]
	For $licznik = 0 To 17
		$napis = StringReplace($napis, $Literki[$licznik][0], $Literki[$licznik][1], 0, 1)
	Next
	Return $napis
EndFunc   ;==>czyscPolskie


Func formatDane($data)
	Local $aTeksty, $sWynik
	$data = StringStripWS($data, 7)
	$aTeksty = StringSplit($data, " ")
	$data = ""
	For $i = 1 To $aTeksty[0]
		$sWynik = ""
		$sWynik = StringLower($aTeksty[$i])
		$sWynik = StringUpper(StringLeft($sWynik, 2)) & StringRight($sWynik, StringLen($sWynik) - 2)
		$data = $data & " " & $sWynik
	Next
	Return StringStripWS($data, 7)
EndFunc   ;==>formatDane
