#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=..\..\ico\rotary_encoder_index_disc.jpg.ico
#AutoIt3Wrapper_Outfile=dysk x.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****


HotKeySet("{ESC}", "Terminate")

Func Terminate()
    Exit
EndFunc   ;==>Terminate

Global $sFileSelectFolder = FileSelectFolder("Select a start index folder", "")
Global $sSqlLitePatch = @ScriptDir & "\"
$listRout = $sFileSelectFolder
$listRoutZamienNa = $sFileSelectFolder


$nazwaPliku="IndexFile"
ToolTip ( "Trwa indeksowanie dysku [ESC zamyka]" & $listRout,0,0 )

 $sFilePath= @ScriptDir & "\" & $nazwaPliku &".txt"
If FileExists ( $sFilePath) Then
	Local $iDelete = FileDelete($sFilePath)

    ; Display a message of whether the file was deleted.
    If not $iDelete Then
             MsgBox(0, "", "Nie moge usunąć pliku => " & $sFilePath)
			 Exit
    EndIf
EndIf

 $file = FileOpen($sFilePath, 2)
 FileWrite($file, @YEAR&"-"&@MON&"-"&@MDAY&" "&@HOUR&":"&@MIN & @crlf)
  _filelist($listRout,$file)
 FileClose($file)

MsgBox(0,"","Skonczono indeksowanie dysku " & $listRout ,20)

Func _filelist($searchdir,$plik)
$search = FileFindFirstFile($searchdir & "\*.*")
If $search = -1 Then return -1
While 1
    $file = FileFindNextFile($search)
    If @error Then

  FileClose($search)
  return
 Elseif  $file = "."  or $file = ".." Then
  ContinueLoop
 ElseIf stringinstr(FileGetAttrib($searchdir & "\" & $file),"D") then
  _filelist($searchdir & "\" & $file,$plik)

 EndIf

FileWrite($plik, StringReplace($searchdir,$listRout,$listRoutZamienNa) & "\" & $file & @crlf)

WEnd
EndFunc




