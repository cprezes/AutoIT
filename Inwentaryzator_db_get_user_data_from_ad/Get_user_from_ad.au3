#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\ico\Avosoft-Warm-Toolbar-User.ico
#AutoIt3Wrapper_Outfile=Loginy_aktualizacja.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=cprezes
#AutoIt3Wrapper_Res_Description=cprezes
#AutoIt3Wrapper_Res_Fileversion=2.2.1.31
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=cprezes
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Res_Field=cprezes|cprezes
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;~ EN
;~ Get all MSAD users and send to Iwentaryzator DB
;~ PL
;~ Uzyskaj wszystkich użytkowników MSAD i wpisz do bazy banych Iwentaryzator


#include <AutoItConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <array.au3>
#include <FileConstants.au3>
_WinAPI_Wow64EnableWow64FsRedirection(False)



Global Const $HTTP_STATUS_OK = 200
Global Const $adress = "http://10.1.1.106/komputery/input.php"
Global Const $workDir = EnvGet("systemdrive") & "\TMP"
Global $iMDay = 0

While (1)
	GenPsFile(True) ; Delete file
	If $iMDay <> @MDAY And @HOUR > 8 Then
		Start()
		$iMDay = @MDAY
	EndIf
	Sleep(4680000)
WEnd

Func Start()
	If GenPsFile() Then terminate() ;Check if ps script is written correct in $workDir
;~ InputBox("Login Update", "Program korzysta z skryptów w PowerShell. Jeśli nie działa to musisz uruchomić polecenie w konsolce PS", "Set-ExecutionPolicy Unrestricted", "", "", -1, -1, "", 30)
	Local $wynikInwent = getUsers()
	If Not @error Then
		$wynikInwent = StringReplace($wynikInwent, "<th>SamAccountName</th>", "<th>login</th>")
		$wynikInwent = StringReplace($wynikInwent, "<th>DisplayName</th>", "<th>opis</th>")
		$wynikInwent = czyscPolskie($wynikInwent)


		$wynikInwent = zamienTagi($wynikInwent)

		$wynikInwent = CzyscBiale($wynikInwent)
		Local $Request = ""
		$Request = "uzytkownicy=tak&nazwa=" & _Base64Encode(@ComputerName) & "&dane=" & _Base64Encode($wynikInwent)

		HttpPost($adress, $Request)

		If @error Then terminate()

	EndIf
EndFunc   ;==>Start

Func terminate()
	GenPsFile(True) ; Delete file
	Exit (0)
EndFunc   ;==>terminate





Func HttpPost($sURL, $sData = "")
	Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")

	$oHTTP.Open("POST", $sURL, False)
	If (@error) Then Return SetError(1, 0, 0)

	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")

	$oHTTP.Send($sData)
	If (@error) Then Return SetError(2, 0, 0)

	If ($oHTTP.Status <> $HTTP_STATUS_OK) Then Return SetError(3, 0, 0)

	Return SetError(0, 0, $oHTTP.ResponseText)
EndFunc   ;==>HttpPost

Func HttpGet($sURL, $sData = "")
	Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")

	$oHTTP.Open("GET", $sURL & "?" & $sData, False)
	If (@error) Then Return SetError(1, 0, 0)

	$oHTTP.Send()
	If (@error) Then Return SetError(2, 0, 0)

	If ($oHTTP.Status <> $HTTP_STATUS_OK) Then Return SetError(3, 0, 0)

	Return SetError(0, 0, $oHTTP.ResponseText)
EndFunc   ;==>HttpGet

Func _Base64Encode($sData)

	Local $oXml = ObjCreate("Msxml2.DOMDocument")
	If Not IsObj($oXml) Then
		SetError(1, 1, 0)
	EndIf

	Local $oElement = $oXml.createElement("b64")
	If Not IsObj($oElement) Then
		SetError(2, 2, 0)
	EndIf

	$oElement.dataType = "bin.base64"
	$oElement.nodeTypedValue = Binary($sData)
	Local $sReturn = $oElement.Text

	If StringLen($sReturn) = 0 Then
		SetError(3, 3, 0)
	EndIf

	Return $sReturn
EndFunc   ;==>_Base64Encode





Func CzyscBiale($string)
	For $x = 0 To 255
		If $x = 32 Or $x = 35 Or $x = 38 Or $x = 59 Or $x = 61 Or $x = 94 Or $x = 92 Or $x = 96 Then ContinueLoop
		If $x > 42 And $x < 58 Then ContinueLoop
		If $x > 63 And $x < 123 Then ContinueLoop
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


Func getUsers()
	Local $iPid, $sOutput
	$iPid = Run('cmd /c  chcp 1250 |  powershell -command "' & $workDir & '\getUsers.ps1"', $workDir, @SW_HIDE, $stdout_child)

	$sOutput = ""

	While 1
		$sOutput &= StdoutRead($iPid)
		If @error Then
			ExitLoop
		EndIf
	WEnd

	$aOut = StringSplit($sOutput, @CRLF, 2)

	_ArrayDelete($aOut, "0-1 ; 7-10")

	Return StringReplace(_ArrayToString($aOut), "|", "")

EndFunc   ;==>getUsers



Func czyscPolskie($napis)

	Local $Literki[18][2] = [["ą", "&#x0105;"], ["ę", "&#x0119;"], ["ó", "&#x00F3;"], ["ł", "&#x0142;"], ["ś", "&#x015B;"], ["ż", "&#x017C;"], ["ź", "&#x017A;"], ["ć", "&#x0107;"], ["ń", "&#x0144;"], ["Ę", "&#x0118;"], ["Ą", "&#x0104;"], ["Ó", "&#x00D3;"], ["Ł", "&#x0141;"], ["Ś", "&#x015A;"], ["Ź", "&#x0179;"], ["Ż", "&#x017B;"], ["Ć", "&#x0106;"], ["Ń", "&#x0143;"]]
	For $licznik = 0 To 17
		$napis = StringReplace($napis, $Literki[$licznik][0], $Literki[$licznik][1], 0, 1)
	Next
	Return $napis
EndFunc   ;==>czyscPolskie



Func GenPsFile($dellFile = False)
	If Not FileExists($workDir) Then DirCreate($workDir)
	Local Const $sFilePath = $workDir & "\getUsers.ps1"

	Local $sInfoPath = @ScriptDir & "\" & @ScriptName & ".txt"

	$sZapytanie = "import-module ActiveDirectory" & @CRLF & "chcp 1250" & @CRLF & "Get-ADUser  -filter *  -Properties SamAccountName, DisplayName, EmailAddress, MobilePhone, OfficePhone , Enabled, Department , Description, Title,StreetAddress, PostalCode, State , Manager , LastLogonDate | select SamAccountName, DisplayName, EmailAddress, MobilePhone ,OfficePhone, Enabled ,Department, Description, Title, StreetAddress ,PostalCode,State, @{N='Manager';E={ (Get-ADUser $_.Manager).SamAccountName }} ,LastLogonDate |  ConvertTo-Html"

	If $dellFile = False Then
		If Not FileExists($sInfoPath) Then FileWrite($sInfoPath, "Program korzysta z skryptów w PowerShell. Jeśli nie działa to uruchom poniższe polecenie w konsolce PS" & @CRLF & "Set-ExecutionPolicy Unrestricted")
		If Not FileWrite($sFilePath, $sZapytanie) Then
			Return False
		EndIf
		; Read little-endian file
		$hFile = FileOpen($sFilePath) ; Open UTF-16 LE file
		$vData = FileRead($hFile) ; Read file
		FileClose($hFile)

		; Overwrite as big-endian
		$hFile = FileOpen($sFilePath, 64 + 2) ; Overwrite UTF-16 BE
		FileWrite($hFile, $vData)
		FileClose($hFile)
	Else
		Sleep(1000)
		If FileExists($sInfoPath) Then FileDelete($sFilePath)
	EndIf
EndFunc   ;==>GenPsFile

