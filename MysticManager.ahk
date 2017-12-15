#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#IfWinActive, Diablo III
#SingleInstance force
CoordMode, Pixel, Client
CoordMode, Mouse, Client
FileEncoding, UTF-8

global D3ScreenResolution
,NativeDiabloHeight := 1440
,NativeDiabloWidth := 2560

;Hotkey, Pause, EarlyTerm ;Exit with Pause Key

; Load Settings
;IniRead, Attribute, MysticManager.ini, Settings, Attribute
;IniRead, CustomStat, MysticManager.ini, Settings, CustomStat
;IniRead, StatRoll, MysticManager.ini, Settings, StatRoll
IniRead, Tries, MysticManager.ini, Settings, Tries, 50
IniRead, SleepSelect, MysticManager.ini, Settings, SleepSelect, 1650
IniRead, SleepClick, MysticManager.ini, Settings, SleepClick, 100

;GUI Section
GUI, New, , %A_Script%
GUI, Add, Text, x10 y10, Choose Attribute and value
GUI, Add, DDL,x10 y30 w120 vAttribute, ||Strength|Dexterity|Intelligence|Vitality|Critical Hit Chance|Critical Hit Damage|`% Area Damage|`% Damage|Damage|Cooldown|Resource|Sockets|Attack Speed|Life per Second|Life per Hit|Life per Kill|Resistance|Armor|Health Globes|Pickup|Thorns|`% Life|Physical|Cold|Fire|Lightning|Poison|Arcane|Holy
GUI, Add, Edit, x150 y45 w80 vStatRoll
GUI, Add, Edit, x10 y60 w120 vCustomStat

;Tries
GUI, Add, Text, x10 y90, Number of Tries:
GUI, Add, Edit, x190 y90 w40 vTries, %Tries%

;Sleeptimers
GUI, Add, Text, x10 y120, Sleep after clicking replace [ms]:
GUI, Add, Edit, x190 y120 w40 vSleepSelect, %SleepSelect%
GUI, Add, Text, x10 y150, Sleep after clicking select [ms]:
GUI, Add, Edit, x190 y150 w40 vSleepClick, %SleepClick%

GUI, Add, Text, x10 y180, Press [ESC] to stop the script at any point!!!
GUI, Add, Button,x10 y210 w220 h30, Start

GUI, Show
return

GuiClose:
ExitApp

ESC::
Reload

ButtonStart:
GUI, Hide
WinActivate, Diablo III
GUIControlGet, Attribute
GUIControlGet, CustomStat
GUIControlGet, Tries
GUIControlGet, StatRoll
GUIControlGet, SleepSelect
GUIControlGet, SleepClick

; Save all the settings
IniWrite, %Attribute%, MysticManager.ini, Settings, Attribute
IniWrite, %CustomStat%, MysticManager.ini, Settings, CustomStat
IniWrite, %StatRoll%, MysticManager.ini, Settings, StatRoll
IniWrite, %Tries%, MysticManager.ini, Settings, Tries
IniWrite, %SleepSelect%, MysticManager.ini, Settings, SleepSelect
IniWrite, %SleepClick%, MysticManager.ini, Settings, SleepClick

If (Attribute == "")
	If (CustomStat != "")
		Attribute := CustomStat
		
If (Tries == "")
	Exit
	
If (StatRoll == "")
	Exit

StatRoll := StrReplace(StatRoll, "," , ".")

IfInString, StatRoll, -		;must be a dmg range
{
	StatRoll := StrReplace(StatRoll, "—" , "-")
	DMGRange := StrSplit(StatRoll , "-")
	DMGRange[1] := ExtractNumbers(DMGRange[1])
	DMGRange[2] := ExtractNumbers(DMGRange[2])
	StatRoll := (DMGRange[1] + DMGRange[2]) / 2	;calculate mean of the lowest and highest dmg numbers
}

GetClientWindowInfo("Diablo III", DiabloWidth, DiabloHeight, DiabloX, DiabloY)

If (D3ScreenResolution != DiabloWidth*DiabloHeight)
{
	global StepWindowTopLeft := [58, 463, 2]
	,StepWindowSize := [580, 36, 4]
	;width and height of OCR rectangle based of 2560x1440
	,Stat1TopLeft := [106, 514, 2]
	,Stat2TopLeft := [106, 572, 2]
	,Stat3TopLeft := [106, 629, 2]
	,StatSize := [518, 28, 4]
	;middle of button based of 2560x1440
	,SelectProperty := [350, 1045, 2]

	;convert coordinates for the used resolution of Diablo III
	ConvertCoordinates(StepWindowTopLeft)
	ConvertCoordinates(StepWindowSize)
	ConvertCoordinates(Stat1TopLeft)
	ConvertCoordinates(Stat2TopLeft)
	ConvertCoordinates(Stat3TopLeft)
	ConvertCoordinates(StatSize)
	ConvertCoordinates(SelectProperty)
}

;Start of the script. You have to be at the enchantress and the item has to be at least once enchanted (else you would have to enter the attribute you wanted to change which would be a waste of time)

; Start new output-*.txt files
BackupLogFile()

Loop %Tries%
{
	MouseClick, Left, SelectProperty[1], SelectProperty[2]
	Sleep, %SleepSelect%
	GoSub RunReaders
	GoSub Choose
	Sleep, %SleepClick%
	MouseClick, Left, SelectProperty[1], SelectProperty[2]
	Sleep, %SleepClick%
	If (SecondRoll >= StatRoll) || (FirstRoll >= StatRoll)
	{	
		FirstStat := FirstRoll := SecondStat := SecondRoll := ThirdStat := ThirdRoll := ""
		Break
	}
	
	FirstStat := FirstRoll := SecondStat := SecondRoll := ThirdStat := ThirdRoll := ""
}
GUI, Show
Return

RunReaders:
	Loop 3
	{
		TopLeftX := Stat%A_Index%TopLeft[1] + DiabloX
		TopLeftY := Stat%A_Index%TopLeft[2] + DiabloY
		ButtomRightX := Stat%A_Index%TopLeft[1] + DiabloX + StatSize[1]
		ButtomRightY := Stat%A_Index%TopLeft[2] + DiabloY + StatSize[2]
		StringRun := A_ScriptDir . "\Capture2Text\Capture2Text_CLI.exe -o output-ocr.txt --output-file-append --screen-rect """ . TopLeftX . " " . TopLeftY . " " . ButtomRightX . " " . ButtomRightY . """"
		RunWait, %StringRun%,%A_ScriptDir%, Hide, ocrPID
		Process, WaitClose, %ocrPID%
		%A_Index%Stat := GetCaptureOutput()
		
		;fix some common ocr missreadings
		%A_Index%Stat := StrReplace(%A_Index%Stat, Chr(150), "-") ; En Dash
		%A_Index%Stat := StrReplace(%A_Index%Stat, Chr(151), "-") ; Em Dash
		%A_Index%Stat := StrReplace(%A_Index%Stat, Chr(176) "/o" , "%") ; Degree /o
		%A_Index%Stat := StrReplace(%A_Index%Stat, "+63%" , "+6%")
		%A_Index%Stat := StrReplace(%A_Index%Stat, "Dam age" , "Damage")	
		
		FileAppend, % %A_Index%Stat "`n", output-sane.txt
		
		IfInString, %A_Index%Stat, -		;must be a dmg range
		{
			DMGRange := StrSplit(%A_Index%Stat , "-")
			DMGRange[1] := ExtractNumbers(DMGRange[1])
			DMGRange[2] := ExtractNumbers(DMGRange[2])
			%A_Index%Roll := (DMGRange[1] + DMGRange[2]) / 2	;calculate mean of the lowest and highest dmg numbers
		}
		Else
			%A_Index%Roll := ExtractNumbers(%A_Index%Stat)
	}
Return

Choose:
	Loop 3
	{
		IfInString, %A_Index%Stat, %Attribute%
		{
			IF (SecondRoll == "") && (FirstRoll != "")		;only if the SecondRoll is still Zero
			{
				SecondStat := A_Index
				SecondRoll := %A_Index%Roll
			}
			If (FirstRoll == "")					;only if the FirstRoll is still Zero
			{
				FirstStat := A_Index
				FirstRoll := %A_Index%Roll
			}
			Else
			{
				ThirdStat := A_Index
				ThirdRoll := %A_Index%Roll
			}
		}
	}
	If (FirstRoll == "")			;this would mean no Stat met the search pattern, keeping the first stat in this case
		MouseClick, Left, Stat1TopLeft[1]+StatSize[1]/2, Stat1TopLeft[2]+StatSize[2]/2
	
	If (SecondRoll == "") && (ThirdRoll == "") || (FirstRoll >= SecondRoll) && (ThirdRoll == "") || (FirstRoll >= SecondRoll) && (FirstRoll >= ThirdRoll)		;check if the first stat was the highest roll
		MouseClick, Left, Stat%FirstStat%TopLeft[1]+StatSize[1]/2, Stat%FirstStat%TopLeft[2]+StatSize[2]/2

	If (SecondRoll >= FirstRoll) && (ThirdRoll == "") || (SecondRoll >= FirstRoll) && (SecondRoll >= ThirdRoll)		;check if the second stat was the highest roll
		MouseClick, Left, Stat%SecondStat%TopLeft[1]+StatSize[1]/2, Stat%SecondStat%TopLeft[2]+StatSize[2]/2
	
	If (ThirdRoll >= FirstRoll) && (ThirdRoll >= SecondRoll)		;check if the third stat was the highest roll
		MouseClick, Left, Stat%ThirdStat%TopLeft[1]+StatSize[1]/2, Stat%ThirdStat%TopLeft[2]+StatSize[2]/2
Return

GetCaptureOutput()
{
	Loop, read, output-ocr.txt
	{
		LastLine := A_LoopReadLine
	}
	return %LastLine%
}

ExtractNumbers(MyString){
	firstdot := 0
	Loop, Parse, MyString
	{
		If A_LoopField is Number
			NewVar .= A_LoopField
		IfInString,A_LoopField,.
		{
			if (firstdot = 0){
				NewVar .= A_LoopField
				firstdot := 1
			}
		}
		IfInString,A_LoopField,`,
			NewVar .= A_LoopField
		IfInString,A_LoopField,-
			NewVar .= A_LoopField
	}
	StringReplace, NewVar, NewVar,`,,, ;;remove dots
	; Remove Leading dashes dots and commas
	NewVar := RegExReplace(NewVar, "^[\-.,]*")
	; Trailing
	NewVar := RegExReplace(NewVar, "[\-.,]*$")
	Return NewVar
}
	
ConvertCoordinates(ByRef Array)
{
	GetClientWindowInfo("Diablo III", DiabloWidth, DiabloHeight, DiabloX, DiabloY)
	
	D3ScreenResolution := DiabloWidth*DiabloHeight
	
	Position := Array[3]

	;Pixel is always relative to the middle of the Diablo III window
	If (Position == 1)
  	Array[1] := Round(Array[1]*DiabloHeight/NativeDiabloHeight+(DiabloWidth-NativeDiabloWidth*DiabloHeight/NativeDiabloHeight)/2, 0)

	;Pixel is always relative to the left side of the Diablo III window or just relative to the Diablo III windowheight
	If Else (Position == 2 || Position == 4)
		Array[1] := Round(Array[1]*(DiabloHeight/NativeDiabloHeight), 0)

	;Pixel is always relative to the right side of the Diablo III window
	If Else (Position == 3)
		Array[1] := Round(DiabloWidth-(NativeDiabloWidth-Array[1])*DiabloHeight/NativeDiabloHeight, 0)

	Array[2] := Round(Array[2]*(DiabloHeight/NativeDiabloHeight), 0)
}

GetClientWindowInfo(ClientWindow, ByRef ClientWidth, ByRef ClientHeight, ByRef ClientX, ByRef ClientY)
{
	hwnd := WinExist(ClientWindow)
	VarSetCapacity(rc, 16)
	DllCall("GetClientRect", "uint", hwnd, "uint", &rc)
	ClientWidth := NumGet(rc, 8, "int")
	ClientHeight := NumGet(rc, 12, "int")

	WinGetPos, WindowX, WindowY, WindowWidth, WindowHeight, %ClientWindow%
	ClientX := Floor(WindowX + (WindowWidth - ClientWidth) / 2)
	ClientY := Floor(WindowY + (WindowHeight - ClientHeight - (WindowWidth - ClientWidth) / 2))
}

BackupLogFile()
{
	FileDelete, output-ocr.1.txt
	FileMove, output-ocr.txt, output-ocr.1.txt
	FileDelete, output-sane.1.txt
	FileMove, output-sane.txt, output-sane.1.txt
}