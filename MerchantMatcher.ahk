;Basically it OCRs the 2 possibilities and analyzes the strings based on the trim-numbers.
Hotkey, Pause, EarlyTerm ;Exit with Pause Key
CoordMode, Mouse, Screen
;Logfile
LogFile= e:\d3\attributes.txt

;Gui Section
Gui, New, ,OCR Enchantress
Gui, Add, Text,x20 y10, Choose Resolution!
Gui, Add, Text, x250 y10, Own Measurements!
Gui, Add, DDL, x20 y30 w150 vDDL, 2560x1440|1920x1080|1680x1050||1280x720|Custom
Gui, Add, Button, x150 y300 w120 h30, Start
Gui, Add, Text, x250 y30, Enter Values!
Gui, Add, Text, x250 y50, TextLeftPosX
Gui, Add, Edit, x350 y45 vTextLeftPosX
Gui, Add, Text, x250 y80, TextLeftPosY
Gui, Add, Edit, x350 y75 vTextLeftPosY
Gui, Add, Text, x250 y110, OCRwidth
Gui, Add, Edit, x350 y105 vOCRwidth
Gui, Add, Text, x250 y140, OCRheight
Gui, Add, Edit, x350 y135 vOCRheight
Gui, Add, Text, x250 y170, ButtonX
Gui, Add, Edit, x350 y165 vButtonX
Gui, Add, Text, x250 y200, ButtonY
Gui, Add, Edit, x350 y195 vButtonY
Gui, Add, Text, x20 y70, Choose Attribute and value
Gui, Add, DDL,x20 y90 w150 vAttribute, Area Damage|Cooldown||Thorns|CHD||CHC|Custom
Gui, Add, Edit, x180 y90 w40 vwishNum

;Custom values attributes
Gui, Add, Text, x20 y120, Enter custom values for attribute
Gui, Add, Text, x20 y150, Left Trim
Gui, Add, Edit, x90 y145 w40 vtrimNumL
Gui, Add, Text, x20 y180, Right Trim
Gui, Add, Edit, x90 y175 w40 vtrimNumR
Gui, Add, Text, x20 y210, OCR word
Gui, Add, Edit, x90 y205 w40 vwish

;Tries
Gui, Add, Text, x20 y250, Tries?
Gui, Add, Edit, x60 y245 w40 vtries, 5

Gui, Show
return

ButtonStart:
	GuiControlGet, DDL
	if (DDL = "2560x1440")
	{
	resX=2560
	}
		
	if (DDL = "1920x1080")
	{
	resX=1920
	}
	
	if (DDL = "1680x1050")
	{
	resX=1680
	}	
	if (DDL = "1280x720")
	{
	resX=1280
	}
	
	if (DDL = "Custom")
	{	
	GuiControlGet, OCRheight
	GuiControlGet, OCRwidth
	GuiControlGet, TextLeftPosX
	GuiControlGet, TextLeftPosY
	GuiControlGet, ButtonX
	GuiControlGet, ButtonY
	resX= 12345
	}

GuiControlGet, Attribute
	if (Attribute = "Area Damage")
	{
	trimNumL=17
	trimNumR=2
	wish=Area Damage
	}
	if (Attribute = "Cooldown")
	{
	trimNumL=36
	trimNumR=2
	wish=cooldown
	}
	if (Attribute = "Thorns")
	{
	trimNumL=5
	trimNumR=4
	wish=Thorns
	}
	if (Attribute = "CHD")
	{
	trimNumL=36
	trimNumR=3
	wish=Critical Hit Damage
	}
	if (Attribute = "CHC")
	{
	trimNumL=36
	trimNumR=3
	wish=Critical Hit Chance
	}
	if (Attribute = "Custom")
	{
	GuiControlGet, trimNumL
	GuiControlGet, trimNumR
	GuiControlGet, wish
	}

GuiControlGet, tries
If (tries = "")
	{
	tries = 1
	}

GuiControlGet, wishNum
If (wishNum = "")
	{
	Exit
	}
	
	
If resX=2560
{
;x & y position of second possibility 
TextLeftPosX=100 
TextLeftPosY=554
;width and height of OCR rectangle
OCRwidth=530
OCRheight=58
;middle of button
ButtonX=333
ButtonY=1040
}

If resX=1920 
{
;x & y position of second possibility 
TextLeftPosX=78 
TextLeftPosY=418
;width and height of OCR rectangle
OCRwidth=400
OCRheight=44
;middle of button
ButtonX=262
ButtonY=781
}

If resX=1680 
{
;x & y position of second possibility 
TextLeftPosX=75 
TextLeftPosY=410
;width and height of OCR rectangle
OCRwidth=380
OCRheight=34
;middle of button
ButtonX=247
ButtonY=763
}




If resX=1280 
{
;x & y position of second possibility 
TextLeftPosX=53 
TextLeftPosY=278
;width and height of OCR rectangle
OCRwidth=264
OCRheight=29
;middle of button
ButtonX=170
ButtonY=519
}

;Just some other variables 
Pause1=200
EnchantmentPause=1500
OCRPause=1200

;Start of the script. You have to be at the enchantress and the item has to be at least once enchanted (else you would have to enter the attribute you wanted to change which would be a waste of time)
 



Loop %tries% 
{
FileAppend, `nStart`n, %LogFile%
FileAppend, `nwish: %wish%`n, %LogFile%

MouseMove, %ButtonX%, %ButtonY% ;Move to the Replace property button.
Sleep, %Pause1% ;wait a little (you have to wait to not lose some clicks)
MouseClick, Left ;Click
Sleep, %EnchantmentPause% ;and wait for the enchantments to come up.

;OCR the second possibility. Mathematical operations not possible with capture2text... So at first some calculations...
TextRightPosX:=TextLeftPosX + OCRwidth
TextRightPosY:=TextLeftPosY + OCRheight

Run, e:\d3\capture2text.exe %TextLeftPosX% %TextLeftPosY% %TextRightPosX% %TextRightPosY%
Sleep, %OCRPause%

FileAppend, `n2nd`n, %LogFile%
FileAppend, `nClipboard %clipboard%`n, %LogFile%
;StringLeft, strLeft, clipboard, %trimNumL%
;FileAppend, Left String %strLeft%`n, %LogFile%
;StringRight, strRight, strLeft, %trimNumR%
;FileAppend, Right String %strRight%`n, %LogFile%

FoundPos := RegExMatch(Clipboard , "[\d]+(\.\d)?", compNum)
;MsgBox , %FoundPos%
;MsgBox , %compNum%

;Check the results
If clipboard contains %wish% ;only if the wish is in the clipboard...
{
If (compNum>wishNum) ;Compare OCR & string manipulation results with wish number
{
;If true, select second possibility, click it and select it. Then Exit Script. Calculate y-position of middle of possibility 2 first.
pos2y:=TextLeftPosY+0.5*OCRheight
MouseMove %ButtonX%,%pos2y%
Sleep, %Pause1%
MouseClick, Left
MouseMove %ButtonX%, %ButtonY%
Sleep, %Pause1%
MouseClick, Left
Exit
}
}


;OCR the third possibility. Mathematical operations not possible with capture2text... So at first some calculations...
TextLeftPosX2:=TextLeftPosY+OCRheight
TextRightPosX:=TextLeftPosX+OCRwidth
TextRightPosY:=TextLeftPosY+2*OCRheight


Run, e:\d3\capture2text.exe %TextLeftPosX% %TextLeftPosX2% %TextRightPosX% %TextRightPosY%
Sleep, %OCRPause%
FileAppend, `n3rdnd`n, %LogFile%
FileAppend, `nClipboard %clipboard%`n, %LogFile%
;StringLeft, strLeft, clipboard, %trimNumL%
;FileAppend, Left String %strLeft%`n, %LogFile%
;StringRight, strRight, strLeft, %trimNumR%
;FileAppend, Right String %strRight%`n, %LogFile%

FoundPos := RegExMatch(Clipboard , "[\d]+(\.\d)?", compNum)
;MsgBox , %FoundPos%
;MsgBox , %compNum%

FileAppend, real compNum %compNum% real wishNum %wishNum%`n , %LogFile%

If clipboard contains %wish% 
{
If (compNum>wishNum)
{
pos3y:=TextLeftPosY+1.5*OCRheight
MouseMove %ButtonX%,%pos3y%
Sleep, %Pause1%
MouseClick, Left
MouseMove %ButtonX%, %ButtonY%
Sleep, %Pause1%
MouseClick, Left
Exit
}
}

If clipboard contains %wish% 
{
If (compNum<=wishNum)
{
pos1y:=TextLeftPosY-0.5*OCRheight
MouseMove %ButtonX%,%pos1y%
Sleep, %Pause1%
MouseClick, Left
MouseMove %ButtonX%, %ButtonY%
Sleep, %Pause1%
MouseClick, Left
}
}

If clipboard not contains %wish% 
{
pos1y:=TextLeftPosY-0.5*OCRheight
MouseMove %ButtonX%,%pos1y%
Sleep, %Pause1%
MouseClick, Left
MouseMove %ButtonX%, %ButtonY%
Sleep, %Pause1%
MouseClick, Left
}

FileAppend, `nEnd Loop`n, %LogFile%
Sleep, %Pause1%


}

EarlyTerm:     ;;;STEP TO END THE HOTKEY FROM RUNNING
FileAppend, `nDone`n, %LogFile%

ExitApp         ;;;ENDS HOTKEY APPLICATION FROM RUNNING, ITS REMOVED FROM TOOL TRAY
