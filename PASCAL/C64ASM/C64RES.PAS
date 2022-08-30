{************************************************}
{                                                }
{ C64ASM - Commodore 64 (6510) Assembler Package }
{                                                }
{     Copyright (c) 1991,95 by T¢th B†lint       }
{                                                }
{************************************************}

program C64Res; { Resource kÇsz°tì }

uses Objects, Drivers, Views, Menus, Dialogs, App,
  StdDlg, Editors, ColorSel, HelpFile, CVHelp, CVGlob;

var
  R: TRect;

procedure CreateMenuBar;
var
  M: PMenuBar;
begin
  R.Assign(0, 0, 80, 1);
  New(M, Init(R, NewMenu(
    NewSubMenu('~F~ile', hcFile, NewMenu(
      StdFileMenuItems(Nil)),
    NewSubMenu('~E~dit', hcEdit, NewMenu(
      StdEditMenuItems(
      NewLine(
      NewItem('~S~how clipboard', '', kbNoKey, cmShowClip, hcShowClip,
      Nil)))),
    NewSubMenu('~S~earch', hcSearch, NewMenu(
      NewItem('~F~ind...', '', kbNoKey, cmFind, hcFind,
      NewItem('~R~eplace...', '', kbNoKey, cmReplace, hcReplace,
      NewItem('~S~earch again', '', kbNoKey, cmSearchAgain, hcSearchAgain,
      Nil)))),
    NewSubMenu('~R~un', hcRun, NewMenu(
      NewItem('~E~xecute', '', kbNoKey, cmDump, hcNoContext,
      NewItem('~T~race', '', kbNoKey, cmDump, hcNoContext,
      NewItem('~S~tep', '', kbNoKey, cmDump, hcNoContext,
      NewLine(
      NewItem('Start C~6~4S', '', kbNoKey, cmDump, hcNoContext,
      Nil)))))),
    NewSubMenu('~C~ompile', hcCompile, NewMenu(
      NewItem('~A~ssemble', 'F9', kbF9, cmAssemble, hcAssemble,
      NewItem('Make ~P~RG file', 'Alt-F9', kbAltF9, cmMakePRG, hcMakePRG,
      NewItem('Make ~T~64 file', 'Ctrl-F9', kbCtrlF9, cmMakeT64, hcMakeT64,
      Nil)))),
    NewSubMenu('~O~ptions', hcOptions, NewMenu(
      NewItem('~R~eport...', '', kbNoKey, cmReport, hcReport,
      NewItem('~M~ouse...', '', kbNoKey, cmMouse, hcMouse,
      NewItem('~C~olors...', '', kbNoKey, cmColors, hcColors,
      NewItem('~T~oggle video mode', '', kbNoKey, cmToggleVideo, hcToggleVideo,
      NewLine(
      NewItem('~L~oad desktop', '', kbNoKey, cmOpenDesktop, hcLoadDesktop,
      NewItem('~S~ave desktop', '', kbNoKey, cmSaveDesktop, hcSaveDesktop,
      Nil)))))))),
    NewSubMenu('~W~indow', hcWindow, NewMenu(
      StdWindowMenuItems(
      NewLine(
      NewItem('~D~isassembler', '', kbNoKey, cmDisassembler, hcDisAssembler,
      NewItem('~H~ex Dump', '', kbNoKey, cmDump, hcDump,
      NewItem('Ascii ~v~iewer', '', kbNoKey, cmAsciiViewer, hcAsciiViewer,
      NewItem('~R~egisters', '', kbNoKey, cmRegisters, hcRegisters,
      NewItem('~O~utput', 'Alt-F5', kbAltF5, cmOutput, hcOutput,
      Nil)))))))),
    NewSubMenu('~M~emory', hcMemory, NewMenu(
      NewItem('Fi~l~l...', '', kbNoKey, cmMemFill, hcMemFill,
      NewItem('~F~ind...', '', kbNoKey, cmMemFind, hcMemFind,
      NewLine(
      NewItem('~L~oad...', 'Shift-F3', kbShiftF3, cmMemLoad, hcMemLoad,
      NewItem('~S~ave...', 'Shift-F2', kbShiftF2, cmMemSave, hcMemSave,
      Nil)))))),
    NewSubMenu('~H~elp', hcHelp, NewMenu(
      NewItem('~C~ontents', '', kbNoKey, cmContents, hcContents,
      NewItem('~I~ndex', '', kbShiftF1, cmIndex, hcIndex,
      NewItem('Using ~h~elp', '', kbNoKey, cmUsingHelp, hcUsingHelp,
      NewLine(
      NewItem('~A~bout...', '', kbNoKey, cmAbout, hcAbout,
      Nil)))))),
    Nil))))))))))));
  RezFile.Put(M, 'MenuBar');
  Dispose(M, Done);
end;

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
      NewStatusKey('~F9~ Assemble', kbF9, cmAssemble,
      StdStatusKeys(nil))))),
    NewStatusDef(hcPleaseWait, hcPleaseWait,
      NewStatusKey('Please wait...', kbNoKey, cmNoCommand,
      nil),
    NewStatusDef(1000, $FFFF,
      NewStatusKey('~F1~ Help', kbF1, cmHelp,
      nil),
    nil)))));
  RezFile.Put(SL, 'StatusLine');
  Dispose(SL, Done);
end;

procedure CreateStrings;
var
  StrList: PStrListMaker;
begin
  New(StrList, Init(16384,100));
  with StrList^ do
  begin

    { MenÅpont segÇdletek }
    Put(hcFile, 'File management commands');
    Put(hcNew, 'Open a new file window');
    Put(hcOpen, 'Open an existing file');
    Put(hcSave, 'Save the current file');
    Put(hcSaveAs, 'Save the current file under a different name, directory or drive');
    Put(hcSaveAll, 'Save all modified file');
    Put(hcChangeDir, 'Choose a new default directory');
    Put(hcDosShell, 'Temporarily exit to DOS');
    Put(hcExit, 'Exit this program');

    Put(hcEdit, 'Cut-and-paste editing commands');
    Put(hcUndo, 'Undo the previous editor operation');
    Put(hcCut, 'Remove the selected text and put it in the Clipboard');
    Put(hcCopy, 'Copy the selected text in the Clipboard');
    Put(hcPaste, 'Insert selected text from the Clipboard at the cursor position');
    Put(hcClear, 'Delete the selected text');
    Put(hcShowClip, 'Open the Clipboard window');

    Put(hcSearch, 'Text search commands');
    Put(hcFind, 'Search for text');
    Put(hcReplace, 'Search for text and replace it with new text');
    Put(hcSearchAgain, 'Repeat the last Find or Replace command');

    Put(hcRun, '');

    Put(hcCompile, 'Compile to disk or memory');
    Put(hcAssemble, 'Compile source file in memory');
    Put(hcMakePRG, 'Compile source file in PRG file');
    Put(hcMakeT64, 'Compile source file in T64 file');

    Put(hcOptions, 'Set defaults for environment');
    Put(hcReport, '');
    Put(hcToggleVideo, 'Toggle between 25 and 43/50 line mode (EGA or better)');
    Put(hcMouse, 'Specify mouse settings');
    Put(hcColors, 'Customize colors for environment');
    Put(hcLoadDesktop, 'Load working environment from a file');
    Put(hcSaveDesktop, 'Save working environment, window positions etc.');

    Put(hcWindow, 'Window manipulation commands');
    Put(hcTile, 'Arrange all windows on desktop without overlap');
    Put(hcCascade, 'Arrange all windows on desktop by overlapping');
    Put(hcCloseAll, 'Close all windows on the desktop');
    Put(hcResize, 'Change the size or position of the active window');
    Put(hcZoom, 'Enlarge or restore the size of the active window');
    Put(hcNext, 'Make the next window active');
    Put(hcPrev, 'Make the previous window active');
    Put(hcClose, 'Close the active window');

    Put(hcDisAssembler, 'Open the Disassembler window');
    Put(hcDump, 'Open the Hex Dump window');
    Put(hcAsciiViewer, 'Open the Ascii Dump window');
    Put(hcRegisters, 'Open the Registers window');
    Put(hcOutput, '');

    Put(hcMemory, 'Memory management commands');
    Put(hcMemFill, 'Fill a memory region with a byte');
    Put(hcMemFind, 'Find string or byte-sequence in memory');
    Put(hcMemLoad, 'Load a MEM file to memory');
    Put(hcMemSave, 'Save a memory region to PRG file');

    Put(hcHelp, 'Get online help');
    Put(hcContents, 'Show table of contents for online Help');
    Put(hcIndex, 'Show index for online Help');
    Put(hcUsingHelp, 'How to use online Help');
    Put(hcAbout, 'Show version and copyright information');

    Put(hcDAbout, 'Welcome to C64IDE. Press Enter to close this dialog box');

    Put(hcOkBtn, 'Accept the settings in this dialog box');
    Put(hcCancelBtn, 'Close the dialog box without making any changes');

    Put(hcFOName, 'Enter directory path and filemask');
    Put(hcFOFiles, 'Type for incremental search; lower for files, upper for directories');
    Put(hcFOOpenBtn, 'Open the specified file into a new editor window');
    Put(hcFCDirName, 'Enter drive and/or directory path');
    Put(hcFCDirTree, 'Use cursor keys to navigate through directory tree');
    Put(hcFCChDirBtn, 'Change to the specified directory');
    Put(hcFCRevertBtn, 'Return to the original directory');
    Put(hcFSName, 'Enter directory path and filemask');
    Put(hcFSFiles, 'Type for incremental search; lower for files, upper for directories');

{    Put(hc, '');}

   { Dialog box Åzenetek }
    Put(sNoMem, 'Not enough memory available to complete operation.');
    Put(sErrorReading, 'Error reading file %s.');
    Put(sErrorWriting, 'Error writing file %s.');
    Put(sErrorCreating, 'Error creating file %s.');
    Put(sModified, '%s has been modified. Save?');
    Put(sSaveUntitled, 'Save untitled file?');
    Put(sStrNotFound, 'Search string not found.');
    Put(sReplace, 'Replace this occurence?');
    Put(sErrorHelp, 'Could not open help file.');
    Put(sErrorOpenDesk, 'Could not open desktop file.');
    Put(sErrorReadingDesk, 'Error reading desktop file.');
    Put(sDeskInvalid, 'Error: Invalid desktop file.');
    Put(sErrorDeskCreate, 'Could not create desktop file.');
    Put(sErrorAssemble, 'Error in line %d : %s');
    Put(sErrorOpenSource, 'Could not open source file.');
    Put(sAssembleOk, 'Assembling completed.');
    Put(sErrorMemFill, 'Error in parameters.'#13'Cannot complete fill.');
    Put(sErrorMemFind, 'Error in parameters.'#13'Cannot complete find.');
    Put(sErrorMemSave, 'Error in parameters.'#13'Cannot complete save.');
    Put(sMemSearchNotFound, 'Search sequence not found.');
    Put(sErrorReadROM, 'Cannot read C64 ROM files.');

  end;
  RezFile.Put(StrList, 'Strings');
  Dispose(StrList, Done);
end;

procedure CreateFileOpenDialog;
var
  P: PView;
begin
  P := New(PFileDialog, Init('*.*', 'Open a File',
    '~N~ame', fdOpenButton + fdHelpButton + fdNoLoadDir, 100));
  P^.HelpCtx := hcFOFileOpenDBox;
  RezFile.Put(P, 'FileOpenDialog');
  Dispose(P, Done);
end;

procedure CreateSaveAsDialog;
var
  D: PDialog;
begin
  D := New(PFileDialog, Init('*.*', 'Save file as', '~N~ame',
    fdOkButton + fdHelpButton + fdNoLoadDir, 101));
  D^.HelpCtx := hcFSFileSaveAsDBox;
  RezFile.Put(D, 'SaveAsDialog');
  Dispose(D, Done);
end;

procedure CreateChDirDialog;
var
  D: PDialog;
begin
  D := New(PChDirDialog, Init(cdNormal + cdHelpButton + cdNoLoadDir, 101));
  D^.HelpCtx := hcFCChDirDBox;
  RezFile.Put(D, 'ChDirDialog');
  Dispose(D, Done);
end;

procedure CreateFindDialog;
var
  D: PDialog;
  Control: PView;
begin
  R.Assign(0, 0, 38, 12);
  D := New(PDialog, Init(R, 'Find'));
  with D^ do
  begin
    Options := Options or ofCentered;

    R.Assign(3, 3, 32, 4);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 2, 15, 3);
    Insert(New(PLabel, Init(R, '~T~ext to find', Control)));
    R.Assign(32, 3, 35, 4);
    Insert(New(PHistory, Init(R, PInputLine(Control), 10)));

    R.Assign(3, 5, 35, 7);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('~C~ase sensitive',
      NewSItem('~W~hole words only', nil)))));

    R.Assign(14, 9, 24, 11);
    Control := New(PButton, Init(R, 'O~K~', cmOk, bfDefault));
    Control^.HelpCtx := hcOkBtn;
    Insert(Control);
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Control := New(PButton, Init(R, 'Cancel', cmCancel, bfNormal));
    Control^.HelpCtx := hcCancelBtn;
    Insert(Control);

    SelectNext(False);
  end;

  RezFile.Put(D, 'FindDialog');
  Dispose(D, Done);
end;

procedure CreateReplaceDialog;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 40, 16);
  D := New(PDialog, Init(R, 'Replace'));
  with D^ do
  begin
    Options := Options or ofCentered;

    R.Assign(3, 3, 34, 4);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 2, 15, 3);
    Insert(New(PLabel, Init(R, '~T~ext to find', Control)));
    R.Assign(34, 3, 37, 4);
    Insert(New(PHistory, Init(R, PInputLine(Control), 10)));

    R.Assign(3, 6, 34, 7);
    Control := New(PInputLine, Init(R, 80));
    Insert(Control);
    R.Assign(2, 5, 12, 6);
    Insert(New(PLabel, Init(R, '~N~ew text', Control)));
    R.Assign(34, 6, 37, 7);
    Insert(New(PHistory, Init(R, PInputLine(Control), 11)));

    R.Assign(3, 8, 37, 12);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('~C~ase sensitive',
      NewSItem('~W~hole words only',
      NewSItem('~P~rompt on replace',
      NewSItem('~R~eplace all', nil)))))));

    R.Assign(17, 13, 27, 15);
    Control := New(PButton, Init(R, 'O~K~', cmOk, bfDefault));
    Control^.HelpCtx := hcOkBtn;
    Insert(Control);
    R.Assign(28, 13, 38, 15);
    Control := New(PButton, Init(R, 'Cancel', cmCancel, bfNormal));
    Control^.HelpCtx := hcCancelBtn;
    Insert(Control);

    SelectNext(False);
  end;

  RezFile.Put(D, 'ReplaceDialog');
  Dispose(D, Done);
end;

procedure CreateColorSelDialog;
var
  D: PDialog;
begin
  D := New(PColorDialog, Init('',
    ColorGroup('Desktop', DesktopColorItems(nil),
    ColorGroup('Menus', MenuColorItems(nil),
    ColorGroup('Dialogs', DialogColorItems(dpGrayDialog, nil),
    ColorGroup('Editor', WindowColorItems(wpBlueWindow, nil),
  nil))))));
  D^.HelpCtx := hcOCColorsDBox;
  RezFile.Put(D, 'ColorSelectDialog');
  Dispose(D, Done);
end;

procedure CreateMemFillDialog;
var
  D: PDialog;
  Control: PView;
begin
  R.Assign(0, 0, 28, 12);
  D := New(PDialog, Init(R, 'Fill Memory'));
  with D^ do
  begin
    HelpCtx := hcDMemFill;
    Options := Options or ofCentered;

    R.Assign(19, 2, 26, 3);
    Control := New(PInputLine, Init(R, 10));
    Insert(Control);
    R.Assign(2, 2, 18, 3);
    Insert(New(PLabel, Init(R, 'Fill with ~v~alue', Control)));

    R.Assign(19, 4, 26, 5);
    Control := New(PInputLine, Init(R, 5));
    Insert(Control);
    R.Assign(2, 4, 18, 5);
    Insert(New(PLabel, Init(R, '~F~rom address', Control)));

    R.Assign(19, 6, 26, 7);
    Control := New(PInputLine, Init(R, 5));
    Insert(Control);
    R.Assign(2, 6, 18, 7);
    Insert(New(PLabel, Init(R, '~T~o address', Control)));

    R.Assign(4, 9, 14, 11);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;

  RezFile.Put(D, 'MemFillDialog');
  Dispose(D, Done);
end;

procedure CreateMemFindDialog;
var
  D: PDialog;
  Control: PView;
begin
  R.Assign(0, 0, 31, 12);
  D := New(PDialog, Init(R, 'Find in Memory'));
  with D^ do
  begin
    HelpCtx := hcDMemFind;
    Options := Options or ofCentered;

    R.Assign(9, 2, 29, 3);
    Control := New(PInputLine, Init(R, 19));
    Insert(Control);
    R.Assign(2, 2, 7, 3);
    Insert(New(PLabel, Init(R, 'Find', Control)));

    R.Assign(22, 4, 29, 5);
    Control := New(PInputLine, Init(R, 5));
    Insert(Control);
    R.Assign(2, 4, 21, 5);
    Insert(New(PLabel, Init(R, 'Search ~f~rom address', Control)));

    R.Assign(22, 6, 29, 7);
    Control := New(PInputLine, Init(R, 5));
    Insert(Control);
    R.Assign(2, 6, 21, 7);
    Insert(New(PLabel, Init(R, '       ~T~o address', Control)));


    R.Assign(5, 9, 15, 11);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;

  RezFile.Put(D, 'MemFindDialog');
  Dispose(D, Done);
end;

procedure CreateMemSaveDialog;
var
  D: PDialog;
  Control: PView;
begin
  R.Assign(0, 0, 31, 10);
  D := New(PDialog, Init(R, 'Save Memory'));
  with D^ do
  begin
    HelpCtx := hcDMemSave;
    Options := Options or ofCentered;

    R.Assign(22, 2, 29, 3);
    Control := New(PInputLine, Init(R, 5));
    Insert(Control);
    R.Assign(2, 2, 21, 3);
    Insert(New(PLabel, Init(R, 'Save ~f~rom address', Control)));

    R.Assign(22, 4, 29, 5);
    Control := New(PInputLine, Init(R, 5));
    Insert(Control);
    R.Assign(2, 4, 21, 5);
    Insert(New(PLabel, Init(R, '       ~T~o address', Control)));

    R.Assign(5, 7, 15, 9);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.X, 12); Inc(R.B.X, 12);
    Insert(New(PButton, Init(R, 'Cancel', cmCancel, bfNormal)));

    SelectNext(False);
  end;

  RezFile.Put(D, 'MemSaveDialog');
  Dispose(D, Done);
end;

procedure CreateMemSaveAsDialog;
var
  D: PDialog;
begin
  D := New(PFileDialog, Init('*.PRG', 'Save PRG file as', '~N~ame',
    fdOkButton + fdHelpButton + fdNoLoadDir, 101));
  D^.HelpCtx := hcFSFileSaveAsDBox;
  RezFile.Put(D, 'MemSaveAsDialog');
  Dispose(D, Done);
end;

procedure CreateAboutDialog;
var
  D: PDialog;
begin
  R.Assign(0, 0, 50, 13);
  New(D, Init(R, 'About C64IDE'));
  with D^ do
  begin
    Options := Options or ofCentered;
    HelpCtx := hcDAbout;
    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R, #13 +
      #3'Commodore 64 (6510) Assembler IDE'#13#13 +
      #3'(NOT RELEASED YET)'#13#13 +
      #3'Copyright 1993,95 by B†lint T¢th'#13#13 +
      #3'Turbo Vision Environment by Borland Inc.')));
    R.Assign(20, 10, 30, 12);
    Insert(New(PButton, Init(R, 'O~k~', cmOk, bfDefault)));
  end;
  RezFile.Put(D, 'AboutDialog');
  Dispose(D, Done);
end;


begin { fìprogram }
  RegisterObjects;
  RegisterViews;
  RegisterMenus;
  RegisterDialogs;
  RegisterStdDlg;
  RegisterEditors;
  RegisterColorSel;
  RegisterType(RStrListMaker);
  RegisterHelpFile;
  RegisterGlobals;
  RezStream := New(PBufStream, Init(BaseName + TVRExt, stCreate, 4096));
  RezFile.Init(RezStream);
  CreateMenuBar;
  CreateStatusLine;
  CreateStrings;
  CreateFileOpenDialog;
  CreateSaveAsDialog;
  CreateChDirDialog;
  CreateFindDialog;
  CreateReplaceDialog;
  CreateColorSelDialog;
  CreateMemFillDialog;
  CreateMemFindDialog;
  CreateMemSaveDialog;
  CreateMemSaveAsDialog;
  CreateAboutDialog;
  RezFile.Done;
end.
