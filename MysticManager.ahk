#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#IfWinActive, Diablo III
#SingleInstance force
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

global D3ScreenResolution
,ScreenMode
,DiabloX
,DiabloY
,SelectField := 0
,Compare1
,Compare2
,AIndexSave
,Stat1Roll
,Stat2Roll
,Stat3Roll
,SleepSelect := 1650
,SleepClick := 100

;Hotkey, Pause, EarlyTerm ;Exit with Pause Key

;GUI Section
GUI, New, ,OCR Enchantress
GUI, Add, Text, x10 y10, Choose Attribute and value
GUI, Add, DDL,x10 y30 w120 vAttribute, Strength|Dexterity|Intelligence|Vitality|Critical Hit Chance|Critical Hit Damage|Area Damage|Damage|Cooldown|Resource|Attack Speed|Life per Second|Life per Hit|Life per Kill|Resistance|Armor|Health Globes|Pickup|Thorns|Life|Physical|Cold|Fire|Lightning|Poison|Arcane|Holy
GUI, Add, Edit, x150 y30 w40 vStatRoll
GUI, Add, Edit, x10 y60 w180 vCustomStat

;Tries
GUI, Add, Text, x10 y90, Number of Tries:
GUI, Add, Edit, x150 y85 w40 vTries, 50

GUI, Add, Button,x10 y110 w180 h30, Start

GUI, Show
return

ESC::
GuiClose:
ExitApp

ButtonStart:
GUI, Hide
WinActivate, Diablo III
GUIControlGet, Attribute
GUIControlGet, CustomStat
If (Attribute == "")
	If (CustomStat != "")
		Attribute := CustomStat

GUIControlGet, Tries
If (Tries == "")
	Exit

GUIControlGet, StatRoll
If (StatRoll == "")
	Exit

WinGetPos, DiabloX, DiabloY, DiabloWidth, DiabloHeight, Diablo III
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
	ScreenMode := isWindowFullScreen("Diablo III")
	ConvertCoordinates(StepWindowTopLeft)
	ConvertCoordinates(StepWindowSize)
	ConvertCoordinates(Stat1TopLeft)
	ConvertCoordinates(Stat2TopLeft)
	ConvertCoordinates(Stat3TopLeft)
	ConvertCoordinates(StatSize)
	ConvertCoordinates(SelectProperty)
}

;Start of the script. You have to be at the enchantress and the item has to be at least once enchanted (else you would have to enter the attribute you wanted to change which would be a waste of time)

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
		FirstStat := FirstRoll := SecondStat := SecondRoll := ""
		Break
	}
	
	FirstStat := FirstRoll := SecondStat := SecondRoll := ""
}
GUI, Show
Return


RunReaders:
	Loop 3
	{
		Stat%A_Index%ButtomRight := Object()
		Stat%A_Index%ButtomRight[1] := Stat%A_Index%TopLeft[1] + StatSize[1]
		Stat%A_Index%ButtomRight[2] := Stat%A_Index%TopLeft[2] + StatSize[2]
		StringRun := A_ScriptDir . "\Capture2Text\Capture2Text_CLI.exe --clipboard -o lastread.txt --output-file-append --screen-rect """ . Stat%A_Index%TopLeft[1] . " " . Stat%A_Index%TopLeft[2] . " " . Stat%A_Index%ButtomRight[1] . " " . Stat%A_Index%ButtomRight[2] . """"
		RunWait, %StringRun%,%A_ScriptDir%, Hide, ocrPID
		Process, WaitClose, %ocrPID%
		%A_Index%Stat := clipboard
		%A_Index%Roll := ExtractNumbers(%A_Index%Stat)
	}
Return

Choose:
	Loop 3
	{
		IfInString, %A_Index%Stat, %Attribute%
		{
			If (FirstRoll == "")		;only if the FirstRoll is still Zero, using the fact that the max possible occurences of the right StatRoll can't be higher than 2
			{
				FirstStat := A_Index
				FirstRoll := %A_Index%Roll
			}
			Else
			{
				SecondStat := A_Index
				SecondRoll := %A_Index%Roll
			}
		}
	}
	If (FirstRoll == "")			;this would mean no Stat met the search pattern, keeping the first stat in this case
		MouseClick, Left, Stat1TopLeft[1]+StatSize[1]/2, Stat1TopLeft[2]+StatSize[2]/2
	
	If (SecondRoll == "") || (FirstRoll >= SecondRoll)		;this would mean only 1 Stat met the search pattern or the first roll was at least the same roll as the second roll, therefore choosing the first roll
		MouseClick, Left, Stat%FirstStat%TopLeft[1]+StatSize[1]/2, Stat%FirstStat%TopLeft[2]+StatSize[2]/2

	If (SecondRoll > FirstRoll)	;this would mean the second roll was higher than the first one, therefore choosing that one
		MouseClick, Left, Stat%SecondStat%TopLeft[1]+StatSize[1]/2, Stat%SecondStat%TopLeft[2]+StatSize[2]/2
Return

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
	checklastdigit := SubStr(NewVar, 0) ;;removes a last dot
		IfInString, checklastdigit , . 
			StringTrimRight, NewVar, NewVar, 1
	StringReplace, NewVar, NewVar,`,,., ;;replaces commas with dots
	FoundPos := InStr(NewVar, "-")
	if (FoundPos = 1){
		StringTrimLeft,NewVar,NewVar,1
	}
	Return NewVar
}
	
ConvertCoordinates(ByRef Array)
{
	WinGetPos, , , DiabloWidth, DiabloHeight, Diablo III
	D3ScreenResolution := DiabloWidth*DiabloHeight

	NativeDiabloHeight := 1440
	NativeDiabloWidth := 2560

 	If (ScreenMode == false)
 	{
		DiabloWidth := DiabloWidth-16
		DiabloHeight := DiabloHeight-39
	}

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

isWindowFullScreen(WinID)
{
   ;checks If the specIfied window is full screen
	winID := WinExist("Diablo III")
	If ( !winID )
		Return false

	WinGet style, Style, ahk_id %WinID%
	WinGetPos ,,,winW,winH, %winTitle%
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return ((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}