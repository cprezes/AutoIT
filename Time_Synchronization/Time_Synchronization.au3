#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\..\ico\Avosoft-Warm-Toolbar-User.ico
#AutoIt3Wrapper_Outfile=Loginy_aktualizacja.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=Time Synchonizator
#AutoIt3Wrapper_Res_Description=Time Synchonizator
#AutoIt3Wrapper_Res_Fileversion=2.1.1.18
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Res_LegalCopyright=Cezar z IT
#AutoIt3Wrapper_Res_Field=Cezar z IT|Cezar z IT
#AutoIt3Wrapper_Res_Comment=Cezar z IT
#AutoIt3Wrapper_Res_Description=Cezar z IT
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Date.au3>

$ntpServer = "de.pool.ntp.org"
$socket = False
OnAutoItExitRegister("Cleanup")
Func Cleanup()
	UDPCloseSocket($socket)
	UDPShutdown()
EndFunc   ;==>Cleanup

While Sleep(1000)
	UDPStartup()
	$socket = UDPOpen(TCPNameToIP($ntpServer), 123)
	If @error Then
		UDPShutdown()
		ContinueLoop
	EndIf
	$timer = TimerInit()
	UDPSend($socket, MakePacket("1b0e01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"))
	If @error Then
		UDPCloseSocket($socket)
		UDPShutdown()
		ContinueLoop
	EndIf
	$data = ""
	While $data = ""
		$data = UDPRecv($socket, 100)
		Sleep(100)
	WEnd
	$diff = TimerDiff($timer)
	UDPCloseSocket($socket)
	UDPShutdown()
	ExitLoop
WEnd

$unsignedHexValue = StringMid($data, 83, 8) ; Extract time from packet. Disregards the fractional second.

$value = UnsignedHexToDec($unsignedHexValue)
$TZinfo = _Date_Time_GetTimeZoneInformation()

$UTC = _DateAdd("s", $value, "1900/01/01 00:00:00")

If $TZinfo[0] <> 2 Then ; 0 = Daylight Savings not used in current time zone / 1 = Standard Time
	$TZoffset = ($TZinfo[1]) * -1
Else ; 2 = Daylight Savings Time
	$TZoffset = ($TZinfo[1] + $TZinfo[7]) * -1
EndIf

;~ Extracts the data & time into vars
;~ Date format & offsets
;~ 2009/12/31 19:26:05
;~ 1234567890123456789  [1 is start of string]

$m = StringMid($UTC, 6, 2)
$d = StringMid($UTC, 9, 2)
$y = StringMid($UTC, 1, 4)
$h = StringMid($UTC, 12, 2)
$mi = StringMid($UTC, 15, 2)
$s = StringMid($UTC, 18, 2)

$tCurr = _Date_Time_EncodeSystemTime($m, $d, $y, $h, $mi, $s)
_Date_Time_SetSystemTime(DllStructGetPtr($tCurr))
MsgBox(262144, "", @LF & $m & "/" & $d & "/" & $y & " " & $h & ":" & $mi & ":" & $s & " Time synchronization done" & @LF, 5)


Func MakePacket($d)
	Local $p = ""
	While $d
		$p &= Chr(Dec(StringLeft($d, 2)))
		$d = StringTrimLeft($d, 2)
	WEnd
	Return $p
EndFunc   ;==>MakePacket

Func UnsignedHexToDec($n)
	$ones = StringRight($n, 1)
	$n = StringTrimRight($n, 1)
	Return Dec($n) * 16 + Dec($ones)
EndFunc   ;==>UnsignedHexToDec

