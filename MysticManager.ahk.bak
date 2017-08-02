#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#IfWinActive, Diablo III
#SingleInstance force
CoordMode, Mouse, Client
global D3ScreenResolution
,ScreenMode
,DiabloX
,DiabloY
,Status := ""

;Hotkey, Pause, EarlyTerm ;Exit with Pause Key

;GUI Section
GUI, New, ,OCR Enchantress
GUI, Add, Text, x20 y10, Choose Attribute and value
GUI, Add, DDL,x20 y30 w80 vAttribute, CHC|CHD|AD|DMG|CDR|RCR|CHC|IAS|ASI
GUI, Add, Edit, x110 y30 w40 vwishNum
GUI, Add, Button, x20 y80 w130 h30, Start

;Tries
GUI, Add, Text, x20 y60, Number of Tries:
GUI, Add, Edit, x110 y55 w40 vtries, 50

GUI, Show
return

ButtonStart:
GUI, Hide
WinActivate, Diablo III
GUIControlGet, Attribute

If (Attribute == "CHC")
	wish := "Critical Hit Chance Increased by \d{1,2}+\.\d{1}%"

If (Attribute == "CHD")
	wish := "Critical Hit Damage Increased by \d{2}+\.\d{1}%"

If (Attribute == "AD")
	wish := "Chance to Deal \d{2}% Area Damage on Hit"

If (Attribute == "DMG")
	wish := "\d{1,2}% Damage"

If (Attribute == "CDR")
	wish := "Reduces cooldown of all skills by \d{1,2}+\.\d{1}%"

If (Attribute == "RCR")
	wish := "Reduces all resource costs by \d{1,2}+\.\d{1}%"

If (Attribute == "IAS")
	wish := "Increases Attack Speed by \d{1,2}+\.\d{1}%"

If (Attribute == "ASI")
	wish := "Attack Speed Increased by \d{1}+\.\d{1}%"

GUIControlGet, tries
If (tries == "")
	Exit

GUIControlGet, wishNum
If (wishNum == "")
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
	ConvertCoordinates(Stat2TopLeft)
	ConvertCoordinates(StatSize)
	ConvertCoordinates(SelectProperty)
}

;Start of the script. You have to be at the enchantress and the item has to be at least once enchanted (else you would have to enter the attribute you wanted to change which would be a waste of time)

Loop %tries%
{
	If (ScreenMode == false)
 	{
		WindowBorderX := 8
		WindowBorderY := 31

		StepWindowTopLeft[1] := StepWindowTopLeft[1] + DiabloX + WindowBorderX
		StepWindowTopLeft[2] := StepWindowTopLeft[2] + DiabloY + WindowBorderY

		Loop, 3
		{
			Stat%A_Index%TopLeft[1] := Stat%A_Index%TopLeft[1] + DiabloX + WindowBorderX
			Stat%A_Index%TopLeft[2] := Stat%A_Index%TopLeft[2] + DiabloY + WindowBorderY
		}
	}
	;check if one stat was already rerolled on the item else this script wont do anything
	OCROuput := OCR(StepWindowTopLeft[1], StepWindowTopLeft[2], StepWindowTopLeft[1]+StepWindowSize[1], StepWindowTopLeft[2]+StepWindowSize[2])
	If (RegExMatch(OCROuput, "Replace a Previously Enchanted Property"))
	{
 		WinActivate, Diablo III
		MouseClick, Left, SelectProperty[1], SelectProperty[2]
		;simple while loop to wait till enchanting is finished.
		While (RegExMatch(OCROuput, "Select Replacement Property") == 0)
			OCROuput := OCR(StepWindowTopLeft[1], StepWindowTopLeft[2], StepWindowTopLeft[1]+StepWindowSize[1], StepWindowTopLeft[2]+StepWindowSize[2])

		Loop 3
		{
			OCROuput := OCR(Stat%A_Index%TopLeft[1], Stat%A_Index%TopLeft[2], Stat%A_Index%TopLeft[1]+StatSize[1], Stat%A_Index%TopLeft[2]+StatSize[2])
			If (RegExMatch(OCROuput, "im)" wish))
			{
				Status := A_Index
				MouseClick, Left, Stat%A_Index%TopLeft[1]+StatSize[1]/2, Stat%A_Index%TopLeft[2]+StatSize[2]/2
				Sleep, 50
			}
		}
		If (Status == "")
		{
			MouseClick, Left, Stat1TopLeft[1]+StatSize[1]/2, Stat1TopLeft[2]+StatSize[2]/2
			Sleep, 50
		}
		Status := ""
		MouseClick, Left, SelectProperty[1], SelectProperty[2]
		Sleep, 100
	}

}
Return

;EarlyTerm:     ;;;STEP TO END THE HOTKEY FROM RUNNING
;ExitApp         ;;;ENDS HOTKEY APPLICATION FROM RUNNING, ITS REMOVED FROM TOOL TRAY
;Return ; just in case

OCR(X1, Y1, X2, Y2)
{
	clipboard :=
	Run, %A_ScriptDir%\Capture2Text\Capture2Text_CLI.exe --screen-rect "%X1% %Y1% %X2% %Y2%" --clipboard, , Hide
	ClipWait, 3
	Sleep, 100

	Return clipboard
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
