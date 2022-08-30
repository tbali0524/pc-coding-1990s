/*========================================================================
2. Irja meg azon WINDOWS program esem‚nykezel“ rutinj t, amely az eg‚r bal
gombj nak a lenyom s ra egy szakaszt h£z az ablak k”z‚ppontj b¢l a cursor 
hely‚re ‚s a gomb lenyomott  llapota melletti mozgat sa sor n a szakasz
ezen v‚gpontja k”veti cursort (gumivonal).
15 PONT =================================================================*/


#include <windows.h>

/*
* Window message handler prototype
*/
long FAR PASCAL WndProc( HWND, WORD, WORD, LONG);


/*--------------------------------------------------------------------------*/
/*  Entry point of the WINDOWS program					    */
/*--------------------------------------------------------------------------*/
int PASCAL WinMain(HANDLE hInstance, 		// Instance handler
		   HANDLE hPrevInstance,	// Handler of previouse Instance
		   LPSTR lpCmdLine, 		// Command line arguments
		   int nCmdShow)		// Initial style
{
    MSG msg;			                // message
    HWND hWnd;					// window handle
    WNDCLASS WndClass;				// window class struct
    static char szAppName[] = "API";		// Application name
    static char szAppCapt[] = "API Demo";	// Capture bar name


    if (!hPrevInstance) {       // Are there other instance running
				// if not -> Create window class and register

	WndClass.style = CS_HREDRAW | CS_VREDRAW;   // window style
	WndClass.lpfnWndProc = WndProc;		    // Message handler
	WndClass.cbClsExtra = 0;		    // Extra info
	WndClass.cbWndExtra = 0;
	WndClass.hInstance = hInstance;		    // Instance handler
	WndClass.hIcon = LoadIcon( NULL, IDI_APPLICATION);      // Icon
	WndClass.hCursor = LoadCursor( NULL, IDC_ARROW);	// Cursor
	WndClass.hbrBackground = GetStockObject(WHITE_BRUSH); // Background
	WndClass.lpszMenuName =  NULL;		      // Menu
	WndClass.lpszClassName = szAppName;	    // Application name

	if ( ! RegisterClass( &WndClass ) )   exit( -1 );     // Register class
    }



    hWnd = CreateWindow(
		 szAppName,                // Application name
		 szAppCapt,                // Capture bar name
		 WS_OVERLAPPEDWINDOW,      // Window style
		 CW_USEDEFAULT,            // x pos
		 CW_USEDEFAULT,            // y pos
		 CW_USEDEFAULT,            // x size
		 CW_USEDEFAULT,            // y size
		 NULL,                     // parent window
		 NULL,                     // menu handle -> use registered
		 hInstance,                // instance handle
		 NULL );                   // additional creation params

    if ( ! hWnd ) exit( -1 );

    ShowWindow(hWnd, nCmdShow);    	   // Show window
    UpdateWindow(hWnd);            	   // Call back WM_PAINT message

/*
*   MESSAGE LOOP
*/
    while ( GetMessage( &msg, NULL, 0, 0) )  {
	    TranslateMessage(&msg);        // Transformation of virtual key codes
	    DispatchMessage(&msg);         // Call back WINDOWS
    }

    return (msg.wParam);           	   // ret val of PostQuitMessage
}





/*--------------------------------------------------------------------------*/
/*  Message handler called by WINDOWS 					    */
/*--------------------------------------------------------------------------*/
long FAR PASCAL WndProc(HWND hWnd, 	// window handle
			WORD message, 	// message id
			WORD wParam, 	// WORD message params
			LONG lParam)	// LONG message params
{
    HDC	        hdc;
    PAINTSTRUCT ps;
    RECT rect;
    static int  xs, ys,	xe, ye;
    static HPEN hactPen;


    switch (message) {                  // Separate messages

    case WM_CREATE:
	  hactPen = CreatePen( PS_SOLID, 1, RGB(255,255,255));
	  return 0;

    case WM_PAINT:			// REPAINT WINDOW
	  hdc = BeginPaint(hWnd, &ps);
	  EndPaint( hWnd, &ps );
	  return 0;

    case WM_LBUTTONDOWN:			// MOUSE LEFT BUTTON DOWN
	  GetClientRect( hWnd, &rect );
	  xs = (rect.right - rect.left) / 2;
          ys = (rect.bottom - rect.top) / 2;

	  hdc = GetDC( hWnd );
	  SetROP2( hdc, R2_NOT );
	  SelectObject(hdc, hactPen);

	  xe = LOWORD(lParam);
	  ye = HIWORD(lParam);
	  MoveTo(hdc, xs, ys);
	  LineTo(hdc, xe, ye);
	  ReleaseDC( hWnd, hdc );

	  return 0;

    case WM_LBUTTONUP:				// MOUSE LEFT BUTTON DOWN
	  hdc = GetDC( hWnd );
	  SelectObject(hdc, hactPen);
	  SetROP2( hdc, R2_NOT );
	  MoveTo(hdc, xs, ys);
	  LineTo(hdc, xe, ye);

	  xe = LOWORD(lParam);
	  ye = HIWORD(lParam);
	  SetROP2( hdc, R2_COPYPEN );
	  MoveTo(hdc, xs, ys);
	  LineTo(hdc, xe, ye);
	  ReleaseDC( hWnd, hdc );
	  return 0;

    case WM_MOUSEMOVE:
	  if (wParam & MK_LBUTTON) {
		  hdc = GetDC( hWnd );
		  SetROP2( hdc, R2_NOT );
		  SelectObject(hdc, hactPen);
		  MoveTo(hdc, xs, ys);
		  LineTo(hdc, xe, ye);

		  xe = LOWORD(lParam);
		  ye = HIWORD(lParam);
		  MoveTo(hdc, xs, ys);
		  LineTo(hdc, xe, ye);
		  ReleaseDC( hWnd, hdc );
	  }
	  return 0;

    case WM_DESTROY:		        // EXIT PROGRAM
	  DeleteObject(hactPen);
	  PostQuitMessage(0);
	  return 0;

    default:
	  return DefWindowProc(hWnd, message, wParam, lParam);
    }
}
