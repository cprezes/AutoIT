#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\ico\footer_logo.jpg.ico
#AutoIt3Wrapper_Outfile=komputery.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=Inwentaryzator Monitorów IT
#AutoIt3Wrapper_Res_Description=Inwentaryzator Monitorów IT
#AutoIt3Wrapper_Res_Fileversion=1.9.1.3
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Cezar z IT
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Res_Field=Cezar z IT|Cezar z IT
#AutoIt3Wrapper_Run_Tidy=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


$sServerAddress ="http://10.1.1.106/komputery/"

#include <AutoItConstants.au3>
#include <Array.au3>

$oMyError = ObjEvent("AutoIt.Error", "MyErrFunc") ;Error func wrapper


Global Const $HTTP_STATUS_OK = 200


Func Administratorzy()

	Local $wyjscie = "", $WskaznikA, $aNazwa, $alicz

	$aNazwa = Polecenia("net localgroup")

	For $alicz = 0 To UBound($aNazwa) - 1
		If StringInStr($aNazwa[$alicz], "Admini") <> 0 Then
			$aNazwa = Polecenia("net localgroup " & $aNazwa[$alicz])
			ExitLoop
		EndIf
	Next
	For $alicz = 0 To UBound($aNazwa) - 1
		If (StringInStr($aNazwa[$alicz], "command") <> 0) Or (StringInStr($aNazwa[$alicz], "Polecenie zosta") <> 0) Then $WskaznikA = 0 ; Works only PL windows
		If $WskaznikA = 1 Then $wyjscie = $wyjscie & " " & $aNazwa[$alicz] & " |"
		If StringInStr($aNazwa[$alicz], "----------") <> 0 Then $WskaznikA = 1
	Next

	Return $wyjscie
EndFunc   ;==>Administratorzy


Func Polecenia($command)
	Local $sFilePath = "c:\" ; Search the current script directory.

	; Remove trailing backslashes and append a single trailing backslash.
	$sFilePath = StringRegExpReplace($sFilePath, "[\\/]+\z", "") & "\"
	$command = StringReplace($command, "*", "")

	Local $iPID = Run(@ComSpec & " /C " & $command, $sFilePath, @SW_HIDE, $STDOUT_CHILD)
	; If you want to search with files that contains unicode characters, then use the /U commandline parameter.

	; Wait until the process has closed using the PID returned by Run.
	ProcessWaitClose($iPID)

	; Read the Stdout stream of the PID returned by Run. This can also be done in a while loop. Look at the example for StderrRead.
	Local $sOutput = StdoutRead($iPID)

	; Use StringSplit to split the output of StdoutRead to an array. All carriage returns (@CRLF) are stripped and @CRLF (line feed) is used as the delimiter.
	Local $aArray = StringSplit(StringTrimRight(StringStripCR($sOutput), StringLen(@CRLF)), @CRLF)

	ProcessClose($iPID)
	Sleep(300)
	Return $aArray

EndFunc   ;==>Polecenia

Func HttpPost($sURL, $sData = "")
	Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1", "MyErrFunc")

	$oHTTP.Open("POST", $sURL, False)
	If (@error) Then wyjdz(1, 0, 0)

	$oHTTP.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")

	$oHTTP.Send($sData)
	If (@error) Then Exit

	If ($oHTTP.Status <> $HTTP_STATUS_OK) Then wyjdz(3, 0, 0)

EndFunc   ;==>HttpPost

Func MyErrFunc()
	$HexNumber = Hex($oMyError.number, 8)
	Return wyjdz() ; something to check for when this function returns
EndFunc   ;==>MyErrFunc


Func HttpGet($sURL, $sData = "")
	Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")

	$oHTTP.Open("GET", $sURL & "?" & $sData, False)
	If (@error) Then wyjdz(1, 0, 0)

	$oHTTP.Send()
	If (@error) Then wyjdz(2, 0, 0)

	If ($oHTTP.Status <> $HTTP_STATUS_OK) Then wyjdz(3, 0, 0)

EndFunc   ;==>HttpGet


Func _GetMACFromIP($sIP)
	Local $MAC, $MACSize
	Local $i, $s, $r, $iIP

	;Create the struct
	$MAC = DllStructCreate("byte[6]")

	;Create a pointer to an int
	$MACSize = DllStructCreate("int")

	;*MACSize = 6;
	DllStructSetData($MACSize, 1, 6)

	;call inet_addr($sIP)
	$r = DllCall("Ws2_32.dll", "int", "inet_addr", _
			"str", $sIP)
	$iIP = $r[0]

	;Make the DllCall
	$r = DllCall("iphlpapi.dll", "int", "SendARP", _
			"int", $iIP, _
			"int", 0, _
			"ptr", DllStructGetPtr($MAC), _
			"ptr", DllStructGetPtr($MACSize))

	;Format the MAC address into user readble format: 00:00:00:00:00:00
	$s = ""
	For $i = 0 To 5
		If $i Then $s = $s & "-"
		$s = $s & Hex(DllStructGetData($MAC, 1, $i + 1), 2)
	Next

	;Return the user readble MAC address
	Return $s
EndFunc   ;==>_GetMACFromIP

$DriveArray = DriveGetDrive("FIXED")
If Not @error Then
	$DriveInfo = ""
	For $DriveCount = 1 To $DriveArray[0]
		$DriveInfo &= StringUpper($DriveArray[$DriveCount])
		$DriveInfo &= Round((DriveSpaceTotal($DriveArray[$DriveCount])) / 1024, 0) & "GB"
		$DriveInfo &= " [" & Round(DriveSpaceFree($DriveArray[$DriveCount]) / DriveSpaceTotal($DriveArray[$DriveCount]) * 100, 0) & "]"
		$DriveInfo &= " |" & @CRLF
	Next

EndIf

#include "CompInfo.au3"
Dim $SystemProduct

_ComputerGetSystemProduct($SystemProduct)
If @error Then
	$error = @error
	$extended = @extended

EndIf

For $i = 1 To $SystemProduct[0][0] Step 1
	$plyta = ("Model: " & $SystemProduct[$i][0] & @CRLF & _
			"| Serial: " & $SystemProduct[$i][1] & @CRLF & _
			"| UUID: " & $SystemProduct[$i][3] & @CRLF & " |" & $SystemProduct[$i][5])

Next



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


Func wyjdz($wy1 = "", $wy2 = "", $wy3 = "")
	Exit 0
EndFunc   ;==>wyjdz

$MAC = StringLower(StringReplace(_GetMACFromIP("localhost"), "-", ""))
$proc = StringLower(@CPUArch)
$lang = StringLower(@MUILang)
$os = StringLower(@OSArch & " | " & @OSType & " | " & @OSVersion & " | " & @OSBuild)
$komp = StringLower(@ComputerName)
$user = StringLower(_GetUserName("localhost"))
$ip = _Base64Encode(@IPAddress1 & " | " & @IPAddress2 & " | " & @IPAddress3)
$domena = StringLower(@LogonDNSDomain)
$aMem = MemGetStats()
$pamiec = Round(((($aMem[1] / 1024))) / 1000, 2) & " gb"
$plyta = _Base64Encode($plyta)
$DriveInfo = _Base64Encode($DriveInfo)
$aAdministratorzy = _Base64Encode(StringReplace(Administratorzy(), "\", ":"))

$Request = "nazwa=" & $komp & "&login=" & $user & "&domena=" & $domena & "&ip=" & $ip & "&mac=" & $MAC & "&dysk=" & $DriveInfo & "&pamiec=" & $pamiec & "&system=" & $os & "&model=" & $plyta & "&inne=" & $aAdministratorzy & "&koment=..."

HttpPost($sServerAddress, $Request)






