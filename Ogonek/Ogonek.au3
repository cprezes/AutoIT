#include <Array.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <SendMessage.au3>

Opt("TrayMenuMode", 1)
Global $napis
Global $napis1




#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("Ogonek", 219, 110,  -1, -1, BitOR($WS_POPUP,$DS_MODALFRAME,$DS_CONTEXTHELP),BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW,$GUI_WS_EX_PARENTDRAG))

$Button1 = GUICtrlCreateButton("X", 184, 8, 25, 25, $BS_FLAT)
GUICtrlSetFont(-1, 14, 800, 0, "MS Sans Serif")
$Label1 = GUICtrlCreateLabel("polskie ogonki z schowka zostają obcięte ", 8, 88, 206, 17)
$Label2 = GUICtrlCreateLabel("Podczas działania programu wszystkie ", 8, 72, 183, 17)
$Label3 = GUICtrlCreateLabel("Monitorowanie schowka włączone", 8, 8, 119, 30)
$Label4 = GUICtrlCreateLabel("(^_^)", 64, 24, 84, 38)
GUICtrlSetFont(-1, 22, 800, 0, "Consolas")
GUICtrlSetColor(-1, 0x000000)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
$hTimer = TimerInit()
$infoLabel=True
While 1

	$napis=ClipGet()

for $t=1 to 15
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button1
			Exit
		Case $GUI_EVENT_PRIMARYDOWN
			On_Drag()
	EndSwitch

Sleep(5)
Next

if $napis <> $napis1 Then
GUICtrlSetData( $Label4 , "(^o^)")
$infoLabel=True
$hTimer = TimerInit()
Local $Literki[16][2] =[["ę", "e"],["ó", "o"],["ł", "l"],["ś", "s"],["ą", "a"],["ż", "z"],["ć", "c"],["ń", "n"],["Ę", "E"],["Ó", "O"],["Ł", "L"],["Ś", "S"],["Ą", "A"],["Ż", "Z"],["Ć", "C"],["Ń", "N"]]
for $licznik = 0 to 15
$napis=StringReplace($napis,$Literki[$licznik][0], $Literki[$licznik][1],0,1)
Next
$napis1=$napis
Sleep (200)
ClipPut($napis1)
EndIf
if $infoLabel =True Then
if TimerDiff($hTimer)> 1400 then
	GUICtrlSetData( $Label4 , "(^_^)")
	$infoLabel=False

EndIf
EndIf
WEnd

 Func On_Drag()
     Local $aCurInfo = GUIGetCursorInfo($Form1)
     If $aCurInfo[4] = 0 Then ; Mouse not over a control
         DllCall("user32.dll", "int", "ReleaseCapture")
         _SendMessage($Form1, $WM_NCLBUTTONDOWN, $HTCAPTION, 0)
     EndIf
 EndFunc   ;==>On_Drag









