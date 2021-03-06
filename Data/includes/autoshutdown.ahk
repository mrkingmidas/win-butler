/**
 * Display a timer, and shutdown computer
 */

; Bug: Esc On Abort
; Todo: Shutdown Now

AutoShutdown:
	InputBox, MinuteInput, Shutdown in..., This computer will Shutdown in...... (minutes), ,250, 150, , , , , 20

	If (MinuteInput == "") or (ErrorLevel = 1)
		Return

	; Convert string to number
	Minutes := ("0" . MinuteInput), Minutes += 0
	Gdip_Startup()
	Gosub, GdipSetup
	StartCount := A_TickCount
	SetTimer, ShutdownTimer, % 1000

	Hotkey, Esc, Abort, On
Return

ShutdownTimer:
	SecondsLeft := Minutes*60 - ((A_TickCount - StartCount)//1000)

	If (SecondsLeft <= 0)
	{
		SetTimer, ShutdownTimer, Off
		Shutdown, 5
	}
	Else
	{
		Gdip_GraphicsClear(G)
		Gdip_FillRectangle(G, pBrush, 0, 0, Width, Height)

		Gdip_TextToGraphics(G, FormatSeconds(SecondsLeft), "x" mX " y" mY " cff000000 s200", Font)
		Gdip_TextToGraphics(G, "Press Esc to Abort", "x" mX+175 " y" mY+240 " cff000000 s50", Font)

		UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)
	}
Return

; Convert the specified number of seconds to hh:mm:ss format.
FormatSeconds(NumberOfSeconds)
{
	; *Midnight* of an arbitrary date.
	time = 19990101
	time += %NumberOfSeconds%, seconds
	FormatTime, mmss, %time%, mm:ss
	return NumberOfSeconds//3600 ":" mmss
}

GdipSetup:
	Width := A_ScreenWidth, Height := A_ScreenHeight
	mX := (Width - 800)//2, mY := (Height - 280)//2

	Gui, 99: -Caption +E0x80000 +LastFound +OwnDialogs +Owner +AlwaysOnTop
	Gui, 99: Show, NA
	hwnd1 := WinExist()

	hbm := CreateDIBSection(Width, Height), hdc := CreateCompatibleDC()
	obm := SelectObject(hdc, hbm), G := Gdip_GraphicsFromHDC(hdc)
	Gdip_SetInterpolationMode(G, 7)

	pBrush := Gdip_BrushCreateSolid(0xDD606986)

	Font = Tahoma
	Gdip_FontFamilyCreate(Font), Gdip_DeleteFontFamily(hFamily)

	Gdip_FillRectangle(G, pBrush, 0, 0, Width, Height)

	Gdip_TextToGraphics(G, FormatSeconds(Minutes*60), "x" mX " y" mY " cff000000 s200", Font)
	Gdip_TextToGraphics(G, "Press Esc to Abort", "x" mX+175 " y" mY+240 " cff000000 s50", Font)

	UpdateLayeredWindow(hwnd1, hdc, 0, 0, Width, Height)
Return

Abort:
	SelectObject(hdc, obm), DeleteObject(hbm)
	DeleteDC(hdc), Gdip_DeleteGraphics(G)
	Gdip_DeleteBrush(pBrush)

	SetTimer, ShutdownTimer, Off
	Hotkey, Esc, Abort, Off
	Gui, 99:Destroy
Return
