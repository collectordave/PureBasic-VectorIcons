;{ ==Code Header Comment==============================
;        Name/title: App.pbi
;   Executable name: Part of Icondesigner.exe
;           Version: 1.0.0
;            Author: Collectordave
;     Collaborators: 
;    Translation by: 
;       Create date: 16\05\2016
; Previous releases: 
; This Release Date: 
;  Operating system: Windows  [X]GUI
;  Compiler version: PureBasic 5.42LTS(x64)
;         Copyright: (C)2016
;           License: 
;         Libraries: 
;     English Forum: 
;      French Forum: 
;      German Forum: 
;  Tested platforms: Windows
;       Description: Module for inter OS compatibility and application global variable etc
; ====================================================
;.......10........20........30........40........50........60........70........80
;}
UsePNGImageDecoder()


DeclareModule AppMain
  
  Global ShapesDB.i
  Global drgCanvas.i
  Global Colour.i, Thickness.i
  Global Font.s
  Global Drawmode.s = ""
  Global ShapeLoaded.i = #False
  Global CanvasImage.i
  
  ;Add\Edit Containers
  Global cntSubAddEdit.i,cntColour.i
  
  Structure DrawObject
    Pathtype.s
    Colour.i
    Trans.i
    Text.s
    X1.i
    Y1.i
    X2.i
    Y2.i
    X3.i
    Y3.i
    X4.i
    Y4.i
    RadiusX.i
    RadiusY.i
    Angle1.i
    Angle2.i
    Points.i
    Rotation.i
    Closed.i
    Width.i
    Filled.i
    Rounded.i
    Stroke.i
    Dash.i
    DashFactor.d
    Dot.i
    DotFactor.d
    LeftRight.i
    Font.s
  EndStructure
  Global NewObject.DrawObject 
  
  ;Images
  Global EmptyImg.i, IconImg.i, IconGreyImg.i,ColourImg.i, DrawnImg.i,BlankImg.i
  Global GreyScale.i
  
  Declare.s CheckMultiFilename(FileName.s)
  
EndDeclareModule

Module AppMain
  
 Procedure.s CheckMultiFilename(FileName.s)
  
  Define Max.i = 9
  Define Counter.i = 0
  Define Pathpart.s = GetPathPart(FileName)
  Define FilePart.s = GetFilePart(FileName,#PB_FileSystem_NoExtension)
  Define ExtPart.s = GetExtensionPart(FileName)
  Define NewFilePart.s  = FilePart
  Repeat 
    If Counter > 0
      NewFilePart.s = FilePart + " (" + Str(Counter) + ")"
    EndIf
    Counter = Counter + 1
  Until FileSize(Pathpart + NewFilePart + "." + ExtPart) = -1 Or Counter = Max

  ProcedureReturn Pathpart + NewFilePart + "." + ExtPart
  
EndProcedure 
  
EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 77
; FirstLine = 57
; Folding = 4
; EnableXP