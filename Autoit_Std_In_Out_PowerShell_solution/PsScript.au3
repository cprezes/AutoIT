#NoTrayIcon
#RequireAdmin
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Outfile=sprawdz_acl.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UPX_Parameters=--ultra-brute
#AutoIt3Wrapper_Change2CUI=y
#AutoIt3Wrapper_Res_Comment=Cezar z IT
#AutoIt3Wrapper_Res_Description=Cezar z IT
#AutoIt3Wrapper_Res_Fileversion=1.2.1.45
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Cezar z IT
#AutoIt3Wrapper_Res_Language=1045
#AutoIt3Wrapper_Res_Field=Cezar z IT|Cezar z IT
#AutoIt3Wrapper_Run_Tidy=y
#pragma compile(Console, True)
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


#include <Constants.au3>
#include <GUIConstants.au3>
#include <Array.au3>
#include <File.au3>


;~ To Download SAPIEN.ActiveXPoSH file name is ActiveXPoshV2.zip
;~ https://info.sapien.com/index.php/scripting/scripting-tips-tricks/jazz-up-your-vbscripts-with-powershell-and-windows-forms



;~ To run Java
;~ run(@comspec & " /C Java -jar app.jar", "C:\myApp")
;~ ShellExecute('java', '-jar "App.jar', 'C:\myApp')






Dim $ActiveXPosh

Const $OUTPUT_CONSOLE = 0
Const $OUTPUT_WINDOW = 1
Const $OUTPUT_BUFFER = 2

CreateActiveXPosh()
Global $File = FileOpen('log.txt',10)

	    $sPSCmd = 'import-module ActiveDirectory'
     execAndLog($sPSCmd)


	    $sPSCmd = 'get-aduser -filter {SamAccountName -like "user" } '
        execAndLog($sPSCmd)


Func execAndLog($sExec)
Local	$val = ExecuteCMD($sExec)
Filewrite($File,$sExec&'    ' & $val & @CRLF)

EndFunc



Func CreateActiveXPosh()
 Local $success
 ; Create the PowerShell connector object
 $ActiveXPosh = ObjCreate("SAPIEN.ActiveXPoSH")
 $success = $ActiveXPosh.Init(False) ;Do not load profiles
 If $success <> 0 then
  Consolewrite( "Init failed, palse check install SAPIEN.ActiveXPoSH" & @CR)
  Exit 0
 endif
 If $ActiveXPosh.IsPowerShellInstalled Then
  Consolewrite( "Ready to run PowerShell commands" & @CR & @CR)
 Else
  Consolewrite( "PowerShell not installed" & @CR & @CR)
  Exit 0
 EndIf
 ; Set the output mode
 $ActiveXPosh.OutputMode = $OUTPUT_CONSOLE
 $ActiveXPosh.OutputWidth = 250
EndFunc

Func ExecuteCMD($sPSCmd)
 Local $outtext = ''
 ; Set the $OUTPUT mode to $BUFFER
 $ActiveXPosh.OutputMode = $OUTPUT_BUFFER
 $ActiveXPosh.Execute($sPSCmd)
 $outtext = $ActiveXPosh.OutputString
 $ActiveXPosh.ClearOutput()
 Return $outtext
EndFunc