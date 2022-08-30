{******************************************}
{                                          }
{        S T E F I   - gr fprogram         }
{                                          }
{   Copyright (c) 1995,96 by T¢th B lint   }
{   Borland Pascal 7.0, Turbo Vision 2.0   }
{                                          }
{******************************************}

{ Turbo Vision valtozat }

{ Eroforras keszito }
program StefiRes;

uses Objects, Drivers, Views, Menus, Dialogs, App, StdDlg, ColorSel, HelpFile,
  StefiHC, StTVGlob;

var
  R: TRect;

{ ========================================================================== }

procedure CreateMenuBar;
var
  MB: PMenuBar;
begin
  R.Assign(0, 0, 80, 1);
  New(MB, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcFile, NewMenu(
      NewItem('~O~pen Textfile...', '', kbNoKey, cmOpenText, hcOpenText,
      NewItem('~P~rint', '', kbNoKey, cmPrint, hcPrint,
      NewLine(
      NewItem('~C~hange dir...', '', kbNoKey, cmChangeDir, hcChangeDir,
      NewItem('~D~os shell', '', kbNoKey, cmDosShell, hcDosShell,
      NewItem('E~x~it', 'Alt+X', kbAltX, cmQuit, hcExit,
      Nil))))))),
    NewSubMenu('~G~raph', hcGraph, NewMenu(
      NewItem('~N~ew', '', kbNoKey, cmNew, hcNew,
      NewItem('~O~pen...', 'F3', kbF3, cmOpen, hcOpen,
      NewItem('~S~ave', 'F2', kbF2, cmSave, hcSave,
      NewItem('Save ~a~s...', '', kbNoKey, cmSaveAs, hcSaveAs,
      NewLine(
      NewItem('~V~iew', 'F7', kbF7, cmView, hcView,
      NewItem('~E~dit', 'F4', kbF4, cmEdit, hcEdit,
      NewLine(
      NewItem('~R~eport...', 'F9', kbF9, cmReport, hcReport,
      NewItem('S~h~ow...', 'F8', kbF8, cmShow, hcShow,
      Nil))))))))))),
    NewSubMenu('~O~ptions', hcOptions, NewMenu(
      NewItem('~M~ouse...', '', kbNoKey, cmMouse, hcMouse,
      NewItem('~C~olors...', '', kbNoKey, cmColors, hcColors,
      Nil))),
    NewSubMenu('~W~indow', hcWindow, NewMenu(
      StdWindowMenuItems(
      Nil)),
    NewSubMenu('~H~elp', hcHelp, NewMenu(
      NewItem('~C~ontents', '', kbNoKey, cmContents, hcContents,
      NewItem('Using ~h~elp', '', kbNoKey, cmUsingHelp, hcUsingHelp,
      NewLine(
      NewItem('~A~bout...', '', kbNoKey, cmAbout, hcAbout,
      Nil))))),
    Nil))))))));
  RezFile.Put(MB, 'MenuBar');
  Dispose(MB, Done);
end; { CreateMenuBar }

{ ========================================================================== }

procedure CreateStatusLine;
var
  SL: PHCStatusLine;
begin
  R.Assign(0, 24, 80, 25);
  New(SL, Init(R,
    NewStatusDef(0, 100,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      NewStatusKey('~F2~ Save', kbF2, cmSave,
      NewStatusKey('~F3~ Open', kbF3, cmOpen,
      NewStatusKey('~F4~ Edit', kbF4, cmEdit,
      NewStatusKey('~F7~ View', kbF7, cmView,
      NewStatusKey('~F8~ Show', kbF8, cmShow,
      NewStatusKey('~F9~ Report', kbF9, cmReport,
      StdStatusKeys(Nil)))))))),
    NewStatusDef(hcPleaseWait, hcPleaseWait,
      NewStatusKey('Please wait...', kbNoKey, cmNoCommand,
      Nil),
    NewStatusDef(1000, $FFFF,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      Nil),
    Nil)))));
  RezFile.Put(SL, 'StatusLine');
  Dispose(SL, Done);
end; { CreateStatusLine }

{ ========================================================================== }

procedure CreateStrings;
var
  StrList: PStrListMaker;
begin
  New(StrList, Init(16384,100));
  with StrList^ do
  begin

    { Menupont segedletek }
    Put(hcFile, 'File management commands');
    Put(hcOpenText, 'Locate and open a textfile in a View window');
    Put(hcPrint, 'Print the contents of the active View window');
    Put(hcChangeDir, 'Choose a new default directory');
    Put(hcDosShell, 'Temporarily exit to DOS');
    Put(hcExit, 'Exit this program');

    Put(hcGraph, 'Graph management commands');
    Put(hcNew, 'Create a new, empty graph');
    Put(hcOpen, 'Locate and open an existing graph');
    Put(hcSave, 'Save the current graph');
    Put(hcSaveAs, 'Save the current graph under a different name, directory or drive');
    Put(hcView, 'View the current graph');
    Put(hcEdit, 'Edit the current graph');
    Put(hcReport, 'Analyse current graph and create a reportfile');
    Put(hcShow, 'Show analysis results on the graph');

    Put(hcOptions, 'Set defaults for environment');
    Put(hcMouse, 'Specify mouse settings');
    Put(hcColors, 'Customize colors for windows, menus, etc.');

    Put(hcWindow, 'Window manipulation commands');
    Put(hcTile, 'Arrange all windows on desktop without overlap');
    Put(hcCascade, 'Arrange all windows on desktop by overlapping');
    Put(hcCloseAll, 'Close all windows on the desktop');
    Put(hcResize, 'Change the size or position of the active window');
    Put(hcZoom, 'Enlarge or restore the size of the active window');
    Put(hcNext, 'Make the next window active');
    Put(hcPrev, 'Make the previous window active');
    Put(hcClose, 'Close the active window');

    Put(hcHelp, 'Get online help');
    Put(hcContents, 'Show table of contents for online Help');
    Put(hcUsingHelp, 'How to use online Help');
    Put(hcAbout, 'Show version and copyright information');

    Put(hcDAbout, 'Welcome to STEFI. Press Enter to close this dialog box');

    Put(hcOkBtn, 'Accept the settings in this dialog box');
    Put(hcCancelBtn, 'Close the dialog box without making any changes');

{    Put(hc, '');}

   { Dialog box uzenetek }
    Put(sNoMem, 'Not enough free memory to complete operation.');
    Put(sErrorReading, 'Error reading file.');
    Put(sErrorWriting, 'Error writing file.');
    Put(sErrorPrinting, 'Error during printing.');
    Put(sErrorHelp, 'Could not open help file.');
    Put(sNoGraphics, 'Could not init VGA graphics.');
    Put(sErrorShow, 'Cannot show requested info.');
    Put(sSaveGraf, 'Save current graph?');
    Put(sGrfNameHeader, '³ Graph: ');
    Put(sUntitledGraf, '<untitled>');

  end;
  RezFile.Put(StrList, 'Strings');
  Dispose(StrList, Done);
end; { CreateStrings }

{ ========================================================================== }

procedure CreateOpenDialog;
var
  P: PView;
begin
  P := New(PFileDialog, Init('*.*', 'Open a File',
    '~N~ame', fdOpenButton + fdHelpButton + fdNoLoadDir, 100));
  P^.HelpCtx := hcOpenDBox;
  RezFile.Put(P, 'OpenDialog');
  Dispose(P, Done);
end;

{ ========================================================================== }

procedure CreateChDirDialog;
var
  D: PDialog;
begin
  D := New(PChDirDialog, Init(cdNormal + cdHelpButton + cdNoLoadDir, 101));
  D^.HelpCtx := hcChDirDBox;
  RezFile.Put(D, 'ChDirDialog');
  Dispose(D, Done);
end;

{ ========================================================================== }

procedure CreateSaveAsDialog;
var
  D: PDialog;
begin
  D := New(PFileDialog, Init('*.*', 'Save File As', '~N~ame',
    fdOkButton + fdHelpButton + fdNoLoadDir, 101));
  D^.HelpCtx := hcSaveAsDBox;
  RezFile.Put(D, 'SaveAsDialog');
  Dispose(D, Done);
end;

{ ========================================================================== }

procedure CreateReportDialog;
var
  D: PDialog;
  Control: PView;
begin
  R.Assign(0, 0, 72, 21);
  D := New(PDialog, Init(R, 'Create Report'));
  with D^ do
  begin
    HelpCtx := hcReportDBox;
    Options := Options or ofCentered;

    R.Assign(3, 3, 31, 6);
    Control := New(PCheckBoxes, Init(R,
      NewSItem('Node weights',
      NewSItem('Edge weights',
      NewSItem('Adjacence matrix',
      Nil)))));
    Insert(Control);
    R.Assign(3, 2, 20, 3);
    Insert(New(PLabel, Init(R, 'Graph input data', Control)));
    R.Assign(34, 3, 69, 19);
    Control := New(PCheckBoxes, Init(R,
      NewSItem('Incidence matrix',
      NewSItem('Components',
{      NewSItem('Members, articulations',}
      NewSItem('Node degrees',
      NewSItem('Circles',
{      NewSItem('Euler line/circle',}
      NewSItem('Prufer code',
      NewSItem('Minimal cost paths',
      NewSItem('Excentricities, center',
      NewSItem('Min. cost spanning tree',
      NewSItem('Topologic order',
      NewSItem('Strong components',
      Nil))))))))))));
    Insert(Control);
    R.Assign(34, 2, 51, 3);
    Insert(New(PLabel, Init(R, 'Analysis results', Control)));

    R.Assign(3, 9, 31, 12);
    Control := New(PRadioButtons, Init(R,
      NewSItem('~8~0 characters',
      NewSItem('~1~28 characters',
      NewSItem('~2~50 characters',
      Nil)))));
    Insert(Control);
    R.Assign(3, 8, 31, 9);
    Insert(New(PLabel, Init(R, 'Max. width in report', Control)));

    R.Assign(3, 14, 31, 16);
    Control := New(PRadioButtons, Init(R,
      NewSItem('~E~nglish',
      NewSItem('~H~ungarian',
      Nil))));
    Insert(Control);
    R.Assign(3, 13, 19, 14);
    Insert(New(PLabel, Init(R, 'Report language', Control)));

    R.Assign(5, 18, 15, 20);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12);
    Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;
  RezFile.Put(D, 'ReportDialog');
  Dispose(D, Done);
end; { CreateReportDialog }

{ ========================================================================== }

procedure CreateShowDialog;
var
  D: PDialog;
  Control: PView;
begin
  R.Assign(0, 0, 35, 13);
  D := New(PDialog, Init(R, 'Show'));
  with D^ do
  begin
    HelpCtx := hcShowDBox;
    Options := Options or ofCentered;

    R.Assign(14, 2, 18, 3);
    Control := New(PInputLine, Init(R, 1));
    Insert(Control);
    R.Assign(3, 2, 14, 3);
    Insert(New(PLabel, Init(R, 'From node  ', Control)));
    R.Assign(14, 4, 18, 5);
    Control := New(PInputLine, Init(R, 1));
    Insert(Control);
    R.Assign(3, 4, 14, 5);
    Insert(New(PLabel, Init(R, 'To node    ', Control)));

    R.Assign(3, 7, 32, 9);
    Control := New(PRadioButtons, Init(R,
      NewSItem('Min. cost path',
      NewSItem('Min. cost spanning tree',
      Nil))));
    Insert(Control);
    R.Assign(3, 6, 30, 7);
    Insert(New(PLabel, Init(R, 'Show', Control)));

    R.Assign(5, 10, 15, 12);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12);
    Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;
  RezFile.Put(D, 'ShowDialog');
  Dispose(D, Done);
end; { CreateShowDialog }

{ ========================================================================== }

procedure CreateMouseDialog;
var
  R: TRect;
  D: PMouseDialog;
begin
  R.Assign(0, 0, 34, 12);
  D := New(PMouseDialog, Init(R, 'Mouse options'));
  with D^ do
  begin
    HelpCtx := hcMouseDBox;
    Options := Options or ofCentered;
    R.Assign(3, 4, 30, 5);
    MouseScrollBar := New(PScrollBar, Init(R));
    MouseScrollBar^.SetParams(1, 1, 20, 20, 1);
    MouseScrollBar^.Options := MouseScrollBar^.Options or ofSelectable;
    MouseScrollBar^.SetValue(DoubleDelay);
    Insert(MouseScrollBar);
    R.Assign(2, 2, 21, 3);
    Insert(New(PLabel, Init(R, '~M~ouse double click', MouseScrollBar)));
    R.Assign(3, 3, 30, 4);
    Insert(New(PClickTester, Init(R, 'Fast       Medium      Slow')));
    R.Assign(3, 6, 30, 7);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('~R~everse mouse buttons', Nil))));
    OldDelay := DoubleDelay;
    R.Assign(9, 9, 19, 11);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end; { with }
  RezFile.Put(D, 'MouseDialog');
  Dispose(D, Done);
end; { CreateMouseDialog }

{ ========================================================================== }

procedure CreateColorSelDialog;
var
  D: PDialog;
begin
  D := New(PColorDialog, Init('',
    ColorGroup('Desktop', DesktopColorItems(Nil),
    ColorGroup('Menus', MenuColorItems(Nil),
    ColorGroup('Dialogs', DialogColorItems(dpGrayDialog, Nil),
    ColorGroup('Viewer', WindowColorItems(wpBlueWindow, Nil),
  Nil))))));
  D^.HelpCtx := hcColorsDBox;
  RezFile.Put(D, 'ColorSelectDialog');
  Dispose(D, Done);
end; { CreateColorSelDialog }

{ ========================================================================== }

procedure CreateAboutDialog;
var
  D: PDialog;
begin
  R.Assign(0, 0, 50, 15);
  New(D, Init(R, 'About Stefi'));
  with D^ do
  begin
    HelpCtx := hcDAbout;
    Options := Options or ofCentered;
    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R, #13 +
      #3'S T E F I'#13#13 +
      #3'Graph Editor and Analyser Program'#13#13 +
      #3'Version 1.0c'#13#13 +
      #3'Copyright (c) 1995,1996,2001 by B lint T¢th'#13#13 +
      #3'Turbo Vision Environment by Borland Inc.')));
    R.Assign(20, 12, 30, 14);
    Insert(New(PButton, Init(R, 'O~k~', cmOk, bfDefault)));
  end;
  RezFile.Put(D, 'AboutDialog');
  Dispose(D, Done);
end; { CreateAboutDialog }

{ ========================================================================== }

{ Foprogram }
begin
  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterStdDlg;
  RegisterColorSel;
  RegisterApp;
  RegisterType(RStrListMaker);
  RegisterHelpFile;
  RegisterGlobals;
  RezStream := New(PBufStream, Init(ResFName, stCreate, 4096));
  RezFile.Init(RezStream);
  CreateMenuBar;
  CreateStatusLine;
  CreateStrings;
  CreateOpenDialog;
  CreateChDirDialog;
  CreateSaveAsDialog;
  CreateReportDialog;
  CreateShowDialog;
  CreateMouseDialog;
  CreateColorSelDialog;
  CreateAboutDialog;
  RezFile.Done;
end. { Foprogram }

{ ========================================================================== }
