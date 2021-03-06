#include "modclbk3.hsp"
//#include "hsp3utf.as"
#ifndef newclbk3
	dialog "このモジュールはmodclbk3.hspのインクルードが必須です。\n呼び出し元のメインスクリプトでインクルードして下さい。", 1, "SelectWindowMod.hsp"
	end
#endif

#if 0
#ifndef __hsp3utf__
	dialog "このモジュールはhsp3utf.asのインクルードが必須です。\n呼び出し元のメインスクリプトでインクルードして下さい。", 1, "SelectWindowMod.hsp"
	end
#endif
#endif

#module

#uselib "gdi32.dll"
#func CreateSolidBrush "CreateSolidBrush" wptr
#func GetStockObject "GetStockObject" wptr
#func DeleteObject "DeleteObject" wptr

#uselib "user32.dll"
#func FillRect "FillRect" wptr, wptr, wptr
#func RegisterClassEx "RegisterClassExW" wptr
#func UnregisterClass "UnregisterClassW" wptr, wptr
#func CreateWindowEx "CreateWindowExW" wptr, wptr, wptr, wptr, wptr, wptr, wptr, wptr, wptr, wptr, wptr, wptr
#func DestroyWindow "DestroyWindow" wptr
#func UpdateWindow "UpdateWindow" wptr
#func IsWindow "IsWindow" wptr
#func DefWindowProc "DefWindowProcW" wptr, wptr, wptr, wptr
#func SetLayeredWindowAttributes "SetLayeredWindowAttributes" wptr, wptr, wptr, wptr
#func GetWindowLong "GetWindowLongW" wptr, wptr
#func SetWindowLong "SetWindowLongW" wptr, wptr, wptr
#func GetDC "GetDC" wptr
#func ReleaseDC "ReleaseDC" wptr, wptr
#func GetClientRect "GetClientRect" wptr, wptr
#func PostMessage "PostMessageW" wptr, wptr, wptr, wptr
#func LoadIcon "LoadIconW" wptr, wptr
#func LoadCursor "LoadCursorW" wptr, wptr
#func BeginPaint "BeginPaint" wptr, wptr
#func EndPaint "EndPaint" wptr, wptr

#define WM_DESTROY		0x0002
#define WM_CLOSE		0x0010
#define WM_QUIT			0x0012
#define WM_PAINT		0x000F
#define WM_MOUSEMOVE	0x0200
#define WM_LBUTTONDOWN 	0x0201
#define WM_APP			0x8000
#define global WM_SELWINDOW	0x8001

#define GWL_WNDPROC		-4
#define LWA_ALPHA		0x0002

#define SWP_NOSIZE		0x0001
#define SWP_NOMOVE		0x0002
#define SWP_SHOWWINDOW	0x0040

#define WS_EX_TOPMOST	$00000008

#define HWND_NOTOPMOST	-2
#define HWND_TOPMOST	-1

#deffunc ShowSelectWindow array sscap, int hTopWindow_

	hTopWindow = hTopWindow_

	dim windowNum
	windowNum = length2(sscap)
	logmes "windowNum :"+windowNum

	dim hWnds, windowNum
	dim rect
	dim PAINTSTRUCT, 12

	defaultWindowProc = GetWindowLong(hwnd, GWL_WNDPROC)
	newclbk3 pWindowProc, 4, *WindowProc
	logmes "pWindowProc "+pWindowProc

	className = "kwnd_2"
	sdim classNameWide
	cnvstow classNameWide, className
	dim WNDCLASSEX, 12
	WNDCLASSEX( 0) = 48
	WNDCLASSEX( 2) = pWindowProc
	WNDCLASSEX( 6) = LoadIcon(0, 32512)
	WNDCLASSEX( 7) = LoadCursor(0, 32512)
	WNDCLASSEX( 8) = GetStockObject(0)
	WNDCLASSEX(10) = varptr(classNameWide)
	WNDCLASSEX(11) = LoadIcon(0, 32512)
	RegisterClassEx varptr(WNDCLASSEX)
	logmes "RegisterClassEx Stat :"+stat

	hBrush = CreateSolidBrush(0x0000FF00)
	logmes "hBrush :"+hBrush

	repeat windowNum
		logmes ""+sscap(0, cnt)+","+sscap(1, cnt)+" "+(sscap(2, cnt)-sscap(0, cnt))+"x"+(sscap(3, cnt)-sscap(1, cnt))
		CreateWindowEx WS_EX_TOPMOST, className, "", 0x96000000, sscap(0, cnt), sscap(1, cnt), sscap(2, cnt)-sscap(0, cnt), sscap(3, cnt)-sscap(1, cnt), hTopWindow, 0, 0, 0
		hWnds(cnt) = stat
		logmes strf("hWnds(%d) :%d", cnt, hWnds(cnt))
		if hWnds(cnt) == 0: break
		UpdateWindow hWnds(cnt)
		SetWindowLong hWnds(cnt), -20, 0x00080000
		SetLayeredWindowAttributes hWnds(cnt), 0x00000000, 128, LWA_ALPHA

		dc = GetDC(hWnds(cnt))
		GetClientRect hWindow, varptr(rect)
		FillRect dc, varptr(rect), hBrush
		ReleaseDC hWnds(cnt), dc
	loop

return

*WindowProc
	clbkargprotect args
	hWindow = args(0)
	Message = args(1)
	wp      = args(2)
	lp      = args(3)
///*
	switch Message
		case WM_PAINT
			dc = BeginPaint(hWindow, varptr(PAINTSTRUCT))
			GetClientRect hWindow, varptr(rect)
			FillRect dc, varptr(rect), hBrush
			EndPaint hWindow, varptr(PAINTSTRUCT)
			return
			swbreak
		case WM_LBUTTONDOWN
			repeat windowNum
				WindowID = cnt
				if (hWindow == hWnds(WindowID)){
					logmes "WindowID "+WindowID
					PostMessage hTopWindow, WM_SELWINDOW, WindowID, 0
					break
				}
			loop
			return
			swbreak
	swend
//*/
return DefWindowProc(hWindow, Message, wp, lp)

#deffunc HideSelectWindow
	modWish
return


#deffunc modWish onexit

	repeat windowNum
		if IsWindow(hWnds(cnt)): DestroyWindow hWnds(cnt)
	loop
	UnregisterClass className, hinstance
	DeleteObject hBrush
	modclbk_term
	windowNum = 0
	hTopWindow = 0
return


#global

#if 0

	screen 0
	oncmd gosub *WM_SELWINDOW_, WM_SELWINDOW
	dim sscap, 4, 1
	sscap(0, 0) = 100, 100, 900, 580
	sscap(0, 1) = 600, 600, 1400, 1080
	ShowSelectWindow sscap, hwnd

	stop

*WM_SELWINDOW_

	mes wparam
	HideSelectWindow

return

#endif
