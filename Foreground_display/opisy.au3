#include <GDIPlus.au3>
#NoTrayIcon
#include <GUIConstants.au3>

#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Res_Comment=Foreground image
#AutoIt3Wrapper_Res_Description=Foreground image
#AutoIt3Wrapper_Res_Fileversion=1.0.0.7
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Res_LegalCopyright=Cezar z IT
#AutoIt3Wrapper_Res_Field=Cezar z IT|Cezar z IT
#AutoIt3Wrapper_Res_Comment=Cezar z IT
#AutoIt3Wrapper_Res_Description=Cezar z IT



HotKeySet("{ESC}", "Terminate")

MsgBox(64,"Info ","Plik z opisami musi się nazywać-> opisy.png.  " & @CRLF & "W razie problemów z programem dzwoń do IT Support ",5)

start()

Func start()
;~ Background Image
_GDIPlus_Startup()
$Image_BK = @ScriptDir & "/opisy.png"
$BKF = _GDIPlus_ImageLoadFromFile($Image_BK)
$iW_One = _GDIPlus_ImageGetWidth($BKF)
$iH_One = _GDIPlus_ImageGetHeight($BKF)
$hBitmap_BK = _GDIPlus_BitmapCloneArea($BKF, 0, 0, $iW_One, $iH_One, $GDIP_PXF32ARGB)
$hBmp_BK = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap_BK)
_GDIPlus_BitmapDispose($hBitmap_BK)
_GDIPlus_ImageDispose($BKF)
_GDIPlus_Shutdown()

$Gui = GUICreate("My Trasparent",$iW_One, $iH_One, Default, Default, BitOr($WS_BORDER, $WS_POPUP), BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW));Style: $WS_POPUP
GUISetBkColor(0x000000); BackGround color Black
WinSetTrans($Gui,"",0); Trasparent GUI
GUISetState(@SW_SHOW,$Gui); Show Gui
$Img = GUICtrlCreatePic("",0,0,$iW_One, $iH_One) ;Create pic
 GUICtrlSendMsg($Img, 0x0172, 0, $hBmp_BK) ;insert img

While 1
	Switch GUIGetMsg()
		case -3 ;$Gui_event_close
			Exit
		EndSwitch
	 WEnd

EndFunc

Func Terminate()
    Exit
EndFunc   ;==>Terminate
