#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\ico\logo.ico
#AutoIt3Wrapper_Outfile=instalaTOR.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=Autor projektu Cezar z IT
#AutoIt3Wrapper_Res_Description=Autor projektu Cezar z IT
#AutoIt3Wrapper_Res_Fileversion=1.0.1.38
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Cezar z IT
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Res_Field=Cezar z IT|Cezar z IT
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so /pe /rm /rsln
#AutoIt3Wrapper_Run_Obfuscator=y
#Obfuscator_Parameters=/om /cn=0 /cs=0 /sf=1 /sv=1
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****



#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <ComboConstants.au3>
#include <Crypt.au3>
#include <GUIConstantsEx.au3>
#include <StringConstants.au3>
#include <Date.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <String.au3>
#include <File.au3>


Global Const $sFolderToCopy = EnvGet("systemdrive") & "\TMP1\"
Global Const $HTTP_STATUS_OK = 200
Global Const $sAdressSite = "http://10.1.1.106/komputery/help-tweak.php"

Global $sFileHash = "", $sUserString, $sFilePath = "", $sFilePathOnDisk = "", $aUData
FileDelete(EnvGet("systemdrive") & "\users\" & @UserName & "\AppData\Local\czyszczono.txt")

$imput = InputBox("Czarek Installer v " & FileGetVersion(@AutoItExe), "Wklej w poniższym polu wartość skrótu instalacji otrzymanego w emailu.")
Global $sImputGobal = $imput
If @error Then Exit 0
If StringLen($imput) < 6 Then BladUcieczka("EMPTY_STRING")
$imput = StringTrimLeft($imput, StringInStr($imput, ">"))
$imput = StringStripWS($imput, 8)

$sReqToken = StringBinaryConvert($imput, "btos")
$sFilePath = _httpSend($sReqToken, 2)
$sFilePath = StringBinaryConvert($sFilePath, "btos")
If Not FileExists($sFilePath) Then
	mBox("Link skrótu instalacji jest już nie aktywny. Skontaktuj się z It w celu wygenerowania nowego linku.")
	Exit 0
EndIf

If _CheckIfSpaceEnough($sFilePath) Then

	_FileCopy($sFilePath)
	$sFilePathOnDisk = $sFolderToCopy & _GetFilename($sFilePath) & _GetExtension($sFilePath)
	$sFileHash = _HashFile($sFilePathOnDisk)
	$sFileHashFromUrl = _httpSend($sReqToken, 1)
	If ($sFileHash = $sFileHashFromUrl) Then
		$sUserString = _httpSend($sReqToken, 13)
		$sUserString = StringBinaryConvert($sUserString, "btos")
		$sFileHash = _httpSend($sReqToken, 11)
		$aUData = EncryptUserData($sUserString)
;~ 		ConsoleWrite($aUData[0] & '  ' & @LogonDNSDomain & '  ' & $aUData[1] & '  ' & 1 & '  ' & $sFilePath & '"')
		RunAsWait($aUData[0], @LogonDNSDomain, $aUData[1], 1, '"' & $sFilePathOnDisk & '"')
		If @error Then BladUcieczka("RUN")
	EndIf
EndIf
BladUcieczka("OK", False)
; #FUNCTIONS# ;===============================================================================



Func _httpSend($sToSend, $id = 4)
	Local $sReturn = ""
	$sReturn = HttpPost($sAdressSite, $sToSend & "&id=" & $id)
	If $id Then
		If StringLen($sReturn) < 3 Then BladUcieczka("LEN_Recive")
	EndIf
	Return $sReturn
EndFunc   ;==>_httpSend

Func ClearDisk()

	FileDelete($sFilePathOnDisk)
	DirRemove($sFolderToCopy, 1)

EndFunc   ;==>ClearDisk

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

Func _FileCopy($fromFile)
	If Not FileExists($sFolderToCopy) Then DirCreate($sFolderToCopy)
	Local $FOF_RESPOND_YES = 16
	Local $FOF_SIMPLEPROGRESS = 256
	$winShell = ObjCreate("shell.application")
	$winShell.namespace($sFolderToCopy).CopyHere($fromFile, $FOF_RESPOND_YES)
EndFunc   ;==>_FileCopy


Func _HashFile($sFileSource)
	Local $sHash
	If StringStripWS($sFileSource, $STR_STRIPALL) <> "" And FileExists($sFileSource) Then
		$sHash = StringTrimLeft(_Crypt_HashFile($sFileSource, $CALG_SHA1), 2)
		_Crypt_Shutdown()
		$sFileHash = $sHash
		Return $sHash
	EndIf
	Return "Error"
EndFunc   ;==>_HashFile

Func _DiskFereeSpace() ; the free disk space in Megabytes as a float number.
	Return DriveSpaceFree(EnvGet("systemdrive")) * 1024 * 1024
EndFunc   ;==>_DiskFereeSpace



Func ByteSuffix($iBytes)
	Local $iIndex = 0, $aArray = [' bytes', ' KB', ' MB', ' GB', ' TB', ' PB', ' EB', ' ZB', ' YB']
	While $iBytes > 1023
		$iIndex += 1
		$iBytes /= 1024
	WEnd
	Return Round($iBytes) & $aArray[$iIndex]
EndFunc   ;==>ByteSuffix



Func _CheckIfSpaceEnough($sFile)
	Local $bReturn = True
	Local $iFileSize = FileGetSize($sFile)
	If $iFileSize > 1048576 Then
		If ($iFileSize * 4 > _DiskFereeSpace()) Then
;~ 			ConsoleWrite($iFileSize * 4 & "      " & _DiskFereeSpace())
			mBox("Masz za mało miejsca na dysku." & @CRLF & "O " & ByteSuffix($iFileSize * 4 - _DiskFereeSpace()) & @CRLF & " zwolnij miejsce na dysku i spróbuj ponownie " & @CRLF)
			$bReturn = False
		EndIf
	EndIf
	Return $bReturn
EndFunc   ;==>_CheckIfSpaceEnough

Func StringBinaryConvert($sString, $to = "stob")
	If Not StringInStr($sString, "Error") Then
		If $to = "btos" Then
			Return String(BinaryToString("0x" & $sString))
		Else
			Return String(StringTrimLeft(StringToBinary($sString), 2))
		EndIf
	EndIf
	Return String($sString)
EndFunc   ;==>StringBinaryConvert

Func EncryptUserData($bEncrypted)
	Local Const $sUserKey = $sFileHash
	Local $aTmp
	$aTmp = _StringExplode(BinaryToString(String(_Crypt_DecryptData($bEncrypted, $sUserKey, $CALG_AES_256))), "<&*()>", 0)
	If @error Then BladUcieczka("Error_Crypt")
	_Crypt_Shutdown()
	Return $aTmp

EndFunc   ;==>EncryptUserData


Func _GetFilename($psFilename)
	Local $szDrive, $szDir, $szFName, $szExt
	_PathSplit($psFilename, $szDrive, $szDir, $szFName, $szExt)
	Return $szFName
EndFunc   ;==>_GetFilename


Func _GetExtension($psFilename)
	Local $szDrive, $szDir, $szFName, $szExt
	_PathSplit($psFilename, $szDrive, $szDir, $szFName, $szExt)
	Return $szExt
EndFunc   ;==>_GetExtension

Func mBox($msg, $tOut = 60)
	MsgBox(262144 + 48, "info", $msg, $tOut)
EndFunc   ;==>mBox


Func BladUcieczka($sInfo = "", $show = True)
	If $show Then
		mBox("Link skrótu instalacji jest uszkodzony. Skontaktuj się z It w celu wygenerowania nowego linku." & @LF & $sInfo)
	EndIf
	ClearDisk()
	If StringLen($sFilePath) < 3 Then $sFilePath = $sImputGobal
	Local $sPathEncoded = _Base64Encode(czyscPolskie($sFilePath))
	_httpSend("ended=tak&dane=1&nazwa=" & StringBinaryConvert(@ComputerName) & "&user=" & StringBinaryConvert(@UserName) & "&status=" & StringBinaryConvert($sInfo) & "&program=" & $sPathEncoded, False)
;~ 	ConsoleWrite("ended=tak&dane=1&nazwa=" & StringBinaryConvert(@ComputerName) & "&user=" & StringBinaryConvert(@UserName) & "&status=" & StringBinaryConvert($sInfo) & "&program=" & $sPathEncoded)
	Exit 0
EndFunc   ;==>BladUcieczka

Func _Base64Encode($sData)
	Local $oXml = ObjCreate("Msxml2.DOMDocument")
	If Not IsObj($oXml) Then
		Exit 0
	EndIf

	Local $oElement = $oXml.createElement("b64")
	If Not IsObj($oElement) Then
		Exit 0
	EndIf

	$oElement.dataType = "bin.base64"
	$oElement.nodeTypedValue = Binary($sData)
	Local $sReturn = $oElement.Text

	If StringLen($sReturn) = 0 Then
		Exit 0
	EndIf
	Return $sReturn
EndFunc   ;==>_Base64Encode


Func czyscPolskie($napis)

	Local $Literki[21][2] = [["ą", "&#x0105;"], ["ę", "&#x0119;"], ["ó", "&#x00F3;"], ["ł", "&#x0142;"], ["ś", "&#x015B;"], ["ż", "&#x017C;"], ["ź", "&#x017A;"], ["ć", "&#x0107;"], ["ń", "&#x0144;"], ["Ę", "&#x0118;"], ["Ą", "&#x0104;"], ["Ó", "&#x00D3;"], ["Ł", "&#x0141;"], ["Ś", "&#x015A;"], ["Ź", "&#x0179;"], ["Ż", "&#x017B;"], ["Ć", "&#x0106;"], ["Ń", "&#x0143;"], ["\", "&#x005C;"], ["<", "&#x003C;"], [">", "&#x003E;"]]
	For $licznik = 0 To UBound($Literki, 1) - 1
		$napis = StringReplace($napis, $Literki[$licznik][0], $Literki[$licznik][1], 0, 1)
	Next
	Return $napis
EndFunc   ;==>czyscPolskie




