;{ ==Code Header Comment==============================
;        Name/title: winMain.pb
;   Executable name: Icondesigner.exe
;           Version: 1.0.0
;            Author: Collectordave
;     Collaborators: 
;    Translation by: 
;       Create date: 24\11\2016
; Previous releases: 
; This Release Date: 
;  Operating system: Windows  [X]GUI
;  Compiler version: PureBasic 5.5(x64)
;         Copyright: (C)2016
;           License: 
;         Libraries: 
;     English Forum: 
;      French Forum: 
;      German Forum: 
;  Tested platforms: Windows
;       Description: Programme to use PB vector draw commands to build icons
; ====================================================
;.......10........20........30........40........50........60........70........80
;}
EnableExplicit
UseSQLiteDatabase()
UsePNGImageEncoder()

IncludeFile "AppModule.pbi"

DeclareModule Main
  
  Global CurrentIcon.s
  Global SelectedIconID.i
  Global Dim DrawTips.s(10)
  DrawTips(0) = "Drawing Surface"
  DrawTips(1) = "Select Start Point"  
  DrawTips(2) = "Select End Point"
  
  ;Selected Colour And Font Available to all draw Routines
  Global SelectedColour.i,SelectedFont.s
  
  ;Element Edit gadgets
  ;Global cntElementedit.i,strX1.i,strY1.i,strX2.i,strY2.i,strX3.i,strY3.i,strX4.i,strY4.i,strRadiusX.i,strRadiusY.i,spnAngle1.i,spnAngle2.i,strText.i,btnFont.i,spnSize.i
  ;Global spnSides.i,strRotation.i,optOpen.i,optClosed.i,btnEditPath.i,strFont.i,chkFlip.i
  
  Enumeration 100
    #strX1
    #strY1
    #strX2
    #strY2
    #strX3
    #strY3
    #strX4
    #strY4
    #strRadiusX
    #strRadiusY
    #spnAngle1
    #spnAngle2
    #strText
    #btnFont
    #spnSize
    #spnSides
    #strRotation
    #optOpen
    #optClosed
    #btnEditPath
    #strFont
    #chkFlip
  EndEnumeration  
  
  Declare FinishPath(*Element.AppMain::DrawObject)
  Declare DrawArc(*Element.AppMain::DrawObject)
  Declare DrawBox(*Element.AppMain::DrawObject) 
  Declare DrawCircle(*Element.AppMain::DrawObject)
  Declare DrawCurve(*Element.AppMain::DrawObject)
  Declare DrawEllipse(*Element.AppMain::DrawObject)
  Declare DrawLine(*Element.AppMain::DrawObject)
  Declare DrawPath(*Element.AppMain::DrawObject)
  Declare DrawPolyGon(*Element.AppMain::DrawObject)
  Declare DrawStar(*Element.AppMain::DrawObject)
  Declare DrawMyText(*Element.AppMain::DrawObject)
  Declare DrawShape(*Element.AppMain::DrawObject)
  Declare ShowElement(*Element.AppMain::DrawObject)
  Declare SaveElement(Type.s)
  
EndDeclareModule

IncludeFile "dlgChooseElement.pbi"
IncludeFile "dlgEditPath.pbi"
IncludeFile "dlgLoadIcon.pbi"
IncludeFile "dlgNewGroup.pbi"
IncludeFile "dlgHelpViewer.pbi"
IncludeFile "dlgIconViewer.pbi"
IncludeFile "dlgNewIcon.pbi"
IncludeFile "DrawArc.pbi"
IncludeFile "DrawBox.pbi"
IncludeFile "DrawCircle.pbi"
IncludeFile "DrawCurve.pbi"
IncludeFile "DrawEllipse.pbi"
IncludeFile "DrawLine.pbi"
IncludeFile "DrawPath.pbi"
IncludeFile "DrawPoly.pbi"
IncludeFile "DrawStar.pbi"
IncludeFile "DrawText.pbi"
IncludeFile "DrawShape.pbi"

Module Main
    
  Declare DrawIcon()
  
;Main Window
Global MainWin.i,MainMenu,i,cvsRulerH.i,cvsRulerV.i,cvsDrawingArea.i,btnRedraw.i,btndelete.i

Global HelpWindow.i,ViewIconWindow.i,ShapeDesignerActive.i,ShapesProgramme.i

Structure Shape
  ID.i
  Name.s
  EndStructure
Global Dim ShapesMenuArray.Shape(0)

Global Dim Elements.AppMain::DrawObject(0)
Global NumberOfElements.i,CurrentElement.i

;Colour selection
Global cntColour.i,btnSelectColour.i,cvsColour.i,spnTransp.i

;Element Selection\Display
Global cntElementsel.i, strCurrentIcon.i,txtStatus.i,strType.i,btnNext.i,btnPrevious.i,spnTrans.i

;Element Edit gadgets
Global cntElementedit.i,strX1.i,strY1.i,strX2.i,strY2.i,strX3.i,strY3.i,strX4.i,strY4.i,strRadiusX.i,strRadiusY.i,spnAngle1.i,spnAngle2.i,strText.i,btnFont.i,spnSize.i
Global spnSides.i,strRotation.i,optOpen.i,optClosed.i,btnEditPath.i

;Path Options
Global cntPathOptions.i,chkFilled.i,spnWidth.i,chkRounded.i,optStroke.i,optDash.i,optDot.i,strDashFactor.i,strDotFactor.i 

Global ShapesDB.i

;Font For Rulers
LoadFont(0, "Times New Roman", 8)

Enumeration FormMenu
  #mnuIconNewGroup
  #mnuIconNewIcon
  #mnuIconShapeDesigner
  #mnuIconLoad
  #mnuIconSave
  #mnuIconDelete  
  #mnuIconViewSave
  #mnuIconExit
  #mnuDrawArc
  #mnuDrawBox
  #mnuDrawCircle
  #mnuDrawCurve
  #mnuDrawEllipse
  #mnuDrawLine
  #mnuDrawPath
  #mnuDrawPoly  
  #mnuDrawStar  
  #mnuDrawText
  #mnuHelpShow
EndEnumeration

  Procedure OpenShapesDB()
  
    Define DataBaseFile.s = "C:\PB Projects\Vector Icons (New)\Database\Shapes.spb"
    
    DatabaseFile = GetCurrentDirectory() +"Database\Shapes.spb"

    AppMain::ShapesDB = OpenDatabase(#PB_Any, DatabaseFile, "", ";")

  EndProcedure  

  Procedure LoadShapesMenu()
  
    iLoop = 0
  
    ReDim ShapesMenuArray(iLoop)
  
    If DatabaseQuery(AppMain::ShapesDB, "SELECT * FROM Shapes ORDER BY Name ASC;")
        
      While NextDatabaseRow(AppMain::ShapesDB)
        ShapesMenuArray(iLoop)\ID = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "ShapeID"))       
        ShapesMenuArray(iLoop)\Name = GetDatabaseString(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Name")) 
        iLoop = iLoop + 1
        ReDim ShapesMenuArray(iLoop)   
      Wend
    
    EndIf
  
  EndProcedure

  Procedure CreateWinMenu()
  
    If IsMenu(MainMenu)
      FreeMenu(MainMenu)
    EndIf
    MainMenu = CreateMenu(#PB_Any, WindowID(MainWin))
    MenuTitle("Icon")
    OpenSubMenu("New")
      MenuItem(#mnuIconNewGroup, "Group")
      MenuItem(#mnuIconNewIcon, "Icon")
    CloseSubMenu()
    MenuItem(#mnuIconLoad, "Load")
    MenuItem(#mnuIconSave, "Save")
    MenuItem(#mnuIconDelete, "Delete") 
    MenuBar()
    MenuItem(#mnuIconShapeDesigner, "Shape Designer")  
    MenuItem(#mnuIconViewSave, "View\Save Icons")
    MenuBar()
    MenuItem(#mnuIconExit, "Exit")
    DisableMenuItem(MainMenu, #mnuIconSave, #True) 
    MenuTitle("Draw")
    OpenSubMenu("Elements")
      MenuItem(#mnuDrawArc, "Arc") 
      MenuItem(#mnuDrawBox, "Box") 
      MenuItem(#mnuDrawCircle, "Circle")  
      MenuItem(#mnuDrawCurve, "Curve")    
      MenuItem(#mnuDrawEllipse, "Ellipse")  
      MenuItem(#mnuDrawLine, "Line")
      MenuItem(#mnuDrawPath, "Path")  
      MenuItem(#mnuDrawPoly, "Polygon")      
      MenuItem(#mnuDrawStar, "Star")     
      MenuItem(#mnuDrawText, "Text")   
    CloseSubMenu()
    OpenSubMenu("Shapes")
      For  iLoop = 0 To ArraySize(ShapesMenuArray())
        MenuItem(iLoop + 20, ShapesMenuArray(iLoop)\Name)
      Next iLoop
    CloseSubMenu()
    MenuTitle("Help")
    MenuItem(#mnuHelpShow, "Show Help")
  
  EndProcedure

  Procedure.i ConvertToGrey(Colour.i)
    
    #DefaultGrey = 100
  
    Define cRed.d,cGreen.d,cBlue.d,cAlpha.d
  
    ;Greyscale
    cRed = Red(Colour) * 0.3
    cGreen = Green(Colour) * 0.6
    cBlue = Blue(Colour) * 0.1
    cAlpha = Alpha(Colour) 
    cConvert = (cRed + cGreen + cBlue)
    If cConvert = 0
      cConvert = #DefaultGrey
    EndIf 

    ;Show greyscale
    rColour = RGBA(cConvert,cConvert,cConvert,cAlpha)

    ProcedureReturn rColour
  
  EndProcedure

  Procedure DrawRulers()
  
    If StartVectorDrawing(CanvasVectorOutput(cvsRulerH))
      VectorFont(FontID(0), 10)
      MovePathCursor(0, 25)
      AddPathLine(GadgetWidth(cvsRulerH),25)
      For i = 0 To VectorOutputWidth()
     
        If  Mod(i, 50) = 0
          MovePathCursor(i, 25)       
          AddPathLine(i,5)       
          MovePathCursor(i + 2,0)
          AddPathText(Str(i/5))
        ElseIf Mod(i, 5) = 0
          MovePathCursor(i, 25)
          AddPathLine(i,14)
        EndIf
     
      Next i
    EndIf
    VectorSourceColor(RGBA(100,100,100, 255))
    StrokePath(0.1)
    StopVectorDrawing()
  
    If StartVectorDrawing(CanvasVectorOutput(cvsRulerV))
      VectorFont(FontID(0), 10)
      MovePathCursor(25, 0)
      AddPathLine(25,GadgetHeight(cvsRulerV))   
      For i = 0 To VectorOutputHeight()
     
        If  Mod(i, 50) = 0
          MovePathCursor(25,i)       
          AddPathLine(5,i)       
          MovePathCursor(2,i)
          AddPathText(Str(i/5))
        ElseIf Mod(i, 5) = 0
          MovePathCursor(25,i)
          AddPathLine(20,i)
        EndIf
     
      Next i
    EndIf
    VectorSourceColor(RGBA(100,100,100, 255))
    StrokePath(0.1)
    StopVectorDrawing() 
  EndProcedure

  Procedure NewGroup()
    
    Define Criteria.s
    
    Criteria = "Select * FROM Groups WHERE Name = '" + NewGroup::Name + "';"
    If DatabaseQuery(AppMain::ShapesDB, Criteria)
      If FirstDatabaseRow(AppMain::ShapesDB) = 0
        Criteria = "INSERT INTO Groups (Name)" +
                   " VALUES('" + NewGroup::Name + "');"
        DatabaseUpdate(AppMain::ShapesDB,Criteria)
      Else
        MessageRequester("Groups","Group Exists",#PB_MessageRequester_Ok)
      EndIf
    EndIf
      
  EndProcedure
  
  Procedure.i NewIcon()
    
    Define Criteria.s,IconID.i
    Debug NewIcon::Group_ID
    
    Criteria = "SELECT * FROM Icons WHERE Title = '" + NewIcon::Name + "' AND Group_ID = " + Str(NewIcon::Group_ID)
    If DatabaseQuery(AppMain::ShapesDB, Criteria)
      If FirstDatabaseRow(AppMain::ShapesDB) = 0
        ;icon Does Not exist
        Criteria = "INSERT INTO Icons (Title,Group_ID)" +
                   " VALUES('" + NewIcon::Name + "'," + Str(NewIcon::Group_ID) + ");"

        DatabaseUpdate(AppMain::ShapesDB,Criteria)
        
        Criteria = "SELECT * FROM Icons WHERE Title = '" + NewIcon::Name + "' AND Group_ID = " + Str(NewIcon::Group_ID)
        If DatabaseQuery(AppMain::ShapesDB, Criteria)
          FirstDatabaseRow(AppMain::ShapesDB)
          IconID = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Shape_ID"))
        EndIf      
      Else
        MessageRequester("Icons","Shape Exists",#PB_MessageRequester_Ok)
        ProcedureReturn -1
      EndIf
    EndIf    
    
    ProcedureReturn IconID
    
  EndProcedure
  
  Procedure DeleteIcon()
    
    Define Criteria.s
    
    ;Delete Icon 
    Criteria = "DELETE FROM Icons WHERE Shape_ID = " + Str(SelectedIconID) + " ;"
    If Not DatabaseUpdate(AppMain::ShapesDB, Criteria)
      MessageRequester("Error", "Can't execute the query: " + DatabaseError())
    EndIf
    
    ;Delete The Icons Elements
    Criteria = "DELETE FROM IconElements WHERE Shape_ID = " + Str(SelectedIconID) + " ;"
    If  Not DatabaseUpdate(AppMain::ShapesDB,Criteria)
      MessageRequester("Error", "Can't execute the query: " + DatabaseError())
    EndIf
    
  EndProcedure
  
  Procedure WhereToDraw(Destination.s)
    
    Define iLoop.i = 0
    Define Path.i = #False
    Define k.i

    If Destination = "Icon"
      StartVectorDrawing(ImageVectorOutput(AppMain::IconImg))  
      DrawIcon()
      AppMain::GreyScale = #True
      StartVectorDrawing(ImageVectorOutput(AppMain::IconGreyImg))  
      DrawIcon()       
      AppMain::GreyScale = #False      
    Else
      StartVectorDrawing(CanvasVectorOutput(AppMain::drgCanvas))
      ;Clearcanvas
      DrawVectorImage(ImageID(AppMain::EmptyImg), 255)  
      DrawIcon()       
    EndIf

  EndProcedure
  
  Procedure ShowIcons()
    
    If IsWindow(ViewIconWindow)  
      If IsImage(AppMain::IconImg)
        FreeImage(AppMain::IconImg) 
      EndIf 
      If IsImage(AppMain::IconGreyImg)
        FreeImage(AppMain::IconGreyImg) 
      EndIf      
      AppMain::IconImg = CreateImage(#PB_Any, 640,640, 32,#PB_Image_Transparent)
      StartDrawing(ImageOutput(AppMain::IconImg))
      DrawingMode(#PB_2DDrawing_Transparent)
      Box(0, 0, 640, 640, RGBA(255, 255, 255, 0))
      StopDrawing()
      
      AppMain::IconGreyImg = CreateImage(#PB_Any, 640,640, 32,#PB_Image_Transparent) 
      StartDrawing(ImageOutput(AppMain::IconGreyImg))
      DrawingMode(#PB_2DDrawing_Transparent)
      Box(0, 0, 640, 640, RGBA(255, 255, 255, 0))
      StopDrawing()    
      
      WhereToDraw("Icon")
     IconView::Show()
    EndIf
  
  EndProcedure
  
  Procedure SetColour(Colour.i)
    
    StartVectorDrawing(CanvasVectorOutput(cvsColour))
    ;Clear Canvas
    VectorSourceColor(RGBA(255,255,255,255))
    AddPathBox(0,0,25,25) 
    FillPath()
    ;Show selected colour
    VectorSourceColor(Colour)
    AddPathBox(0,0,25,25) 
    FillPath()
    StopVectorDrawing()
    
  EndProcedure
  
  Procedure Save()
    
    Define Criteria.s

    If SelectedIconID > 0
      
      Criteria = "DELETE FROM IconElements WHERE Shape_ID = " + Str(SelectedIconID) + " ;"
      DatabaseUpdate(AppMain::ShapesDB,Criteria)

      For iLoop = 0 To ArraySize(Elements())
      Criteria = "INSERT INTO IconElements (Shape_ID,PathType,Colour,Trans,text,DrawOrder,X1,Y1,X2,Y2,X3,Y3,X4,Y4,RadiusX,RadiusY,Angle1,Angle2,Points,Rotation,Closed,Width,Filled,Rounded,Stroke,Dash,DashFactor,Dot,DotFactor,Font,LeftRight)"
      Criteria = Criteria + " VALUES(" +
                 Str(SelectedIconID) +
                 ",'" + Elements(iLoop)\Pathtype +
                 "'," + Str(Elements(iLoop)\Colour)  +
                 "," + Str(Elements(iLoop)\Trans) +
                 ",'" + Elements(iLoop)\Text + "'" +
                 "," + Str(iLoop) +
                 "," + Str(Elements(iLoop)\X1) +
                 "," + Str(Elements(iLoop)\Y1) +      
                 "," + Str(Elements(iLoop)\X2) +      
                 "," + Str(Elements(iLoop)\Y2) +      
                 "," + Str(Elements(iLoop)\X3) +
                 "," + Str(Elements(iLoop)\Y3) +      
                 "," + Str(Elements(iLoop)\X4) +      
                 "," + Str(Elements(iLoop)\Y4) +       
                 "," + Str(Elements(iLoop)\RadiusX) +      
                 "," + Str(Elements(iLoop)\RadiusY) +  
                 "," + Str(Elements(iLoop)\Angle1) +       
                 "," + Str(Elements(iLoop)\Angle2) +      
                 "," + Str(Elements(iLoop)\Points) +  
                 "," + Str(Elements(iLoop)\Rotation) +                
                 "," + Str(Elements(iLoop)\Closed) +  
                 "," + Str(Elements(iLoop)\Width) +                    
                 "," + Str(Elements(iLoop)\Filled) +                
                 "," + Str(Elements(iLoop)\Rounded) +  
                 "," + Str(Elements(iLoop)\Stroke) +       
                 "," + Str(Elements(iLoop)\Dash) +  
                 "," + Str(Elements(iLoop)\DashFactor) +       
                 "," + Str(Elements(iLoop)\Dot) +  
                 "," + Str(Elements(iLoop)\DotFactor) +         
                 ",'" + Elements(iLoop)\Font + "'" +
                 "," + Elements(iLoop)\LeftRight +    
                 ");"
      
      If DatabaseUpdate(AppMain::ShapesDB,Criteria) = 0

        MessageRequester("Error", "Can't execute the query: " + DatabaseError())

      EndIf  
        
      Next iLoop
    
    Else
      
      MessageRequester("Save Error","No Icon Selected",#PB_MessageRequester_Ok  )
      
    EndIf
    
  EndProcedure
  
  Procedure SaveElement(Type.s)

  ReDim Elements(NumberOfElements)

  ;Element being saved becomes current element for display in edit area
  CurrentElement = NumberOfElements
  
  Elements(NumberOfElements)\Angle1 = AppMain::NewObject\Angle1
  Elements(NumberOfElements)\Angle2 = AppMain::NewObject\Angle2
  Elements(NumberOfElements)\Closed = AppMain::NewObject\Closed
  Elements(NumberOfElements)\Colour = AppMain::NewObject\Colour 
  Elements(NumberOfElements)\Dash = AppMain::NewObject\Dash
  Elements(NumberOfElements)\DashFactor = AppMain::NewObject\DashFactor
  Elements(NumberOfElements)\Dot = AppMain::NewObject\Dot
  Elements(NumberOfElements)\DotFactor = AppMain::NewObject\DotFactor
  Elements(NumberOfElements)\Filled = AppMain::NewObject\Filled
  Elements(NumberOfElements)\Font = AppMain::NewObject\Font
  Elements(NumberOfElements)\LeftRight = AppMain::NewObject\LeftRight
  Elements(NumberOfElements)\Pathtype = AppMain::NewObject\Pathtype
  Elements(NumberOfElements)\Points = AppMain::NewObject\Points  
  Elements(NumberOfElements)\RadiusX = AppMain::NewObject\RadiusX
  Elements(NumberOfElements)\RadiusY = AppMain::NewObject\RadiusY  
  Elements(NumberOfElements)\Rotation = AppMain::NewObject\Rotation  
  Elements(NumberOfElements)\Rounded = AppMain::NewObject\Rounded
  Elements(NumberOfElements)\Stroke = AppMain::NewObject\Stroke
  Elements(NumberOfElements)\Text = AppMain::NewObject\Text
  Elements(NumberOfElements)\Trans = AppMain::NewObject\Trans
  Elements(NumberOfElements)\Width = AppMain::NewObject\Width
  Elements(NumberOfElements)\X1 = AppMain::NewObject\X1
  Elements(NumberOfElements)\Y1 = AppMain::NewObject\Y1
  Elements(NumberOfElements)\X2 = AppMain::NewObject\X2
  Elements(NumberOfElements)\Y2 = AppMain::NewObject\Y2
  Elements(NumberOfElements)\X3 = AppMain::NewObject\X3
  Elements(NumberOfElements)\Y3 = AppMain::NewObject\Y3  
  Elements(NumberOfElements)\X4 = AppMain::NewObject\X4
  Elements(NumberOfElements)\Y4 = AppMain::NewObject\Y4 
  
  NumberOfElements = NumberOfElements + 1  
  
  ShowElement(Elements(CurrentElement))
  
EndProcedure
  
  Procedure LoadElements()

    NumberOfElements = 0   
    CurrentElement = 0  
    If DatabaseQuery(AppMain::ShapesDB, "SELECT * FROM IconElements WHERE Shape_ID = " + StrU(SelectedIconID) + " ORDER BY Draworder ASC;")
        
      While NextDatabaseRow(AppMain::ShapesDB)
        ReDim Elements(NumberOfElements)
        Elements(NumberOfElements)\Pathtype = GetDatabaseString(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "PathType")) 
        Elements(NumberOfElements)\Colour = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Colour"))
        Elements(NumberOfElements)\Trans = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Trans"))
        Elements(NumberOfElements)\Text = GetDatabaseString(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Text"))          
        Elements(NumberOfElements)\X1 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "X1"))
        Elements(NumberOfElements)\Y1 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Y1"))
        Elements(NumberOfElements)\X2 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "X2"))
        Elements(NumberOfElements)\Y2 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Y2"))      
        Elements(NumberOfElements)\X3 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "X3"))
        Elements(NumberOfElements)\Y3 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Y3"))     
        Elements(NumberOfElements)\X4 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "X4"))
        Elements(NumberOfElements)\Y4 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Y4"))
        Elements(NumberOfElements)\RadiusX = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "RadiusX"))
        Elements(NumberOfElements)\RadiusY = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "RadiusY"))
        Elements(NumberOfElements)\Angle1 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Angle1"))
        Elements(NumberOfElements)\Angle2 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Angle2"))     
        Elements(NumberOfElements)\Points = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Points"))     
        Elements(NumberOfElements)\Rotation = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Rotation"))     
        Elements(NumberOfElements)\Closed = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Closed"))          
        Elements(NumberOfElements)\Width = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Width"))
        Elements(NumberOfElements)\Filled = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Filled"))     
        Elements(NumberOfElements)\Rounded = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Rounded"))
        Elements(NumberOfElements)\Stroke = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Stroke"))          
        Elements(NumberOfElements)\Dash = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Dash"))
        Elements(NumberOfElements)\DashFactor = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "DashFactor"))     
        Elements(NumberOfElements)\Dot = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Dot"))
        Elements(NumberOfElements)\DotFactor = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "DotFactor"))
        Elements(NumberOfElements)\LeftRight = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "LeftRight"))
        Elements(NumberOfElements)\Font = GetDatabaseString(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Font"))     
      
        NumberOfElements = NumberOfElements + 1 

      Wend
      
      FinishDatabaseQuery(AppMain::ShapesDB) 
  EndIf
      
EndProcedure

  Procedure ShowEditGadgets(Type.s)
    
    ;Clear The Edit Container
    If IsGadget(cntElementedit)
      FreeGadget(cntElementedit)
    EndIf
    
    ;Recreate the edit container
    UseGadgetList(WindowID(MainWin))
    cntElementedit = ContainerGadget(#PB_Any, 670, 235, 155, 200, #PB_Container_Single)  

    
    ;Add The Element Edit Gadgets
    Select Type ;GetGadgetText(strType)

      Case "Arc"
        
        TextGadget(#PB_Any, 60, 10, 20, 20, "X", #PB_Text_Center)    
        TextGadget(#PB_Any, 100, 10, 20, 20, "Y", #PB_Text_Center)   
        TextGadget(#PB_Any, 15, 30, 35, 20, "Centre", #PB_Text_Right)
        StringGadget(#strX1, 55, 25, 35, 20, "")
        StringGadget(#strY1, 95, 25, 35, 20, "")
        TextGadget(#PB_Any, 15, 55, 35, 20, "Radius", #PB_Text_Right)
        StringGadget(#strRadiusX, 55, 50, 30, 20, "")
        TextGadget(#PB_Any, 10, 80, 40, 20, "Angle 1", #PB_Text_Right)   
        SpinGadget(#spnAngle1, 55,75, 50, 20, 0, 360, #PB_Spin_Numeric)   
        TextGadget(#PB_Any, 10, 105, 40, 20, "Angle 2", #PB_Text_Right)      
        SpinGadget(#spnAngle2, 55, 100, 50, 20, 0, 360, #PB_Spin_Numeric)  
        OptionGadget(#optOpen, 10, 130, 45, 20, "Open")
        OptionGadget(#optClosed, 55, 130, 70, 20, "Closed")
                 
      Case "Box"
        
        TextGadget(#PB_Any, 60, 5, 20, 20, "X", #PB_Text_Center)    
        TextGadget(#PB_Any, 100, 5, 20, 20, "Y", #PB_Text_Center)   
        TextGadget(#PB_Any, 10, 25, 35, 20, "Start", #PB_Text_Right)
        strX1 = StringGadget(#strX1, 55, 20, 35, 20, "")
        strY1 = StringGadget(#strY1, 95, 20, 35, 20, "")
        TextGadget(#PB_Any, 10,55, 35, 20, "End", #PB_Text_Right)
        strX2 = StringGadget(#strX2, 55, 50, 35, 20, "")
        strY2 = StringGadget(#strY2, 95, 50, 35, 20, "")      
        
       Case "Circle"
        
        TextGadget(#PB_Any, 60, 10, 20, 20, "X", #PB_Text_Center)    
        TextGadget(#PB_Any, 100, 10, 20, 20, "Y", #PB_Text_Center)   
        TextGadget(#PB_Any, 15, 30, 35, 20, "Centre", #PB_Text_Right)
        strX1 = StringGadget(#strX1, 55, 25, 35, 20, "")
        strY1 = StringGadget(#strY1, 95, 25, 35, 20, "")
        TextGadget(#PB_Any, 15, 55, 35, 20, "Radius", #PB_Text_Right)
        strRadiusX = StringGadget(#strRadiusX, 55, 50, 30, 20, "")
        
      Case "Curve"
        
         TextGadget(#PB_Any, 60, 10, 20, 20, "X", #PB_Text_Center)    
         TextGadget(#PB_Any, 100, 10, 20, 20, "Y", #PB_Text_Center)   
         TextGadget(#PB_Any, 15, 35, 35, 20, "Start", #PB_Text_Right)
         strX1 = StringGadget(#strX1, 55, 30, 35, 20, "")
         strY1 = StringGadget(#strY1, 95, 30, 35, 20, "")
         TextGadget(#PB_Any, 15, 60, 30, 20, "End", #PB_Text_Right)
         strX4 = StringGadget(#strX4, 55, 55, 35, 20, "")
         strY4 = StringGadget(#strY4, 95, 55, 35, 20, "")      
         TextGadget(#PB_Any, 15, 85, 30, 20, "Pull 1", #PB_Text_Right)
         strX2 = StringGadget(#strX2, 55, 80, 35, 20, "")
         strY2 = StringGadget(#strY2, 95, 80, 35, 20, "")    
         TextGadget(#PB_Any, 15, 110, 30, 20, "Pull 2", #PB_Text_Right)
         strX3 = StringGadget(#strX3, 55, 105, 35, 20, "")
         strY3 = StringGadget(#strY3, 95, 105, 35, 20, "")
        
       Case "Ellipse"
         
         TextGadget(#PB_Any, 60, 10, 20, 20, "X", #PB_Text_Center)    
         TextGadget(#PB_Any, 100, 10, 20, 20, "Y", #PB_Text_Center)   
         TextGadget(#PB_Any, 15, 30, 35, 20, "Centre", #PB_Text_Right)
         strX1 = StringGadget(#strX1, 55, 25, 35, 20, "")
         strY1 = StringGadget(#strY1, 95, 25, 35, 20, "")
         TextGadget(#PB_Any, 15, 60, 45, 20, "X Radius", #PB_Text_Right)
         strRadiusX = StringGadget(#strRadiusX, 95, 55, 35, 20, "")
         TextGadget(#PB_Any, 15, 90, 45, 20, "Y Radius", #PB_Text_Right)     
         strRadiusY = StringGadget(#strRadiusY, 95, 85, 35, 20, "")     
         TextGadget(#PB_Any, 15, 120, 45, 20, "Rotation", #PB_Text_Right)
         strRotation = StringGadget(#strRotation, 95, 115, 30, 20, "") 
          
      Case "Line"
        
        TextGadget(#PB_Any, 60, 5, 20, 20, "X", #PB_Text_Center)    
        TextGadget(#PB_Any, 100, 5, 20, 20, "Y", #PB_Text_Center)   
        TextGadget(#PB_Any, 10, 25, 35, 20, "Start", #PB_Text_Right)
        strX1 = StringGadget(#strX1, 55, 20, 35, 20, "")
        strY1 = StringGadget(#strY1, 95, 20, 35, 20, "")
        TextGadget(#PB_Any, 10,55, 35, 20, "End", #PB_Text_Right)
        strX2 = StringGadget(#strX2, 55, 50, 35, 20, "")
        strY2 = StringGadget(#strY2, 95, 50, 35, 20, "")      
  
      Case "Path"
      
        optOpen = OptionGadget(#optOpen, 10, 5, 45, 20, "Open")
        optClosed = OptionGadget(#optClosed, 55, 5, 70, 20, "Closed")   
        btnEditPath = ButtonGadget(#btnEditPath, 15, 30, 120, 25, "Edit Path")  
        If AppMain::Drawmode <> "Idle"
          DisableGadget(#btnEditPath,#True)
        Else
         DisableGadget(#btnEditPath,#False)       
       EndIf
       
      Case "Poly"
  
        TextGadget(#PB_Any, 5, 10,50, 20, "Sides", #PB_Text_Right)   
        spnSides = SpinGadget(#spnSides, 80, 10, 50, 20, 3, 10, #PB_Spin_Numeric)    
        TextGadget(#PB_Any, 60, 40, 20, 20, "X", #PB_Text_Center)    
        TextGadget(#PB_Any, 100, 40, 20, 20, "Y", #PB_Text_Center)    
        TextGadget(#PB_Any, 15, 60, 35, 20, "Centre", #PB_Text_Right)
        strX1 = StringGadget(#strX1, 55, 55, 35, 20, "")
        strY1 = StringGadget(#strY1, 95, 55, 35, 20, "")       
        TextGadget(#PB_Any, 15, 85, 35, 20, "Radius", #PB_Text_Right)
        strRadiusX = StringGadget(#strRadiusX, 55, 80, 30, 20, "")
        TextGadget(#PB_Any, 5, 110, 45, 20, "Rotation", #PB_Text_Right)
        strRotation = StringGadget(#strRotation, 55, 105, 30, 20, "") 
        
       Case "Shape"

        TextGadget(#PB_Any, 60, 10, 20, 20, "X", #PB_Text_Center)    
        TextGadget(#PB_Any, 100, 10, 20, 20, "Y", #PB_Text_Center)    
        TextGadget(#PB_Any, 15, 30, 35, 20, "Centre", #PB_Text_Right)
        strX1 = StringGadget(#strX1, 55, 25, 35, 20, "")
        strY1 = StringGadget(#strY1, 95, 25, 35, 20, "")       
        TextGadget(#PB_Any, 15, 55, 35, 20, "Size", #PB_Text_Right)
        strRadiusX = StringGadget(#strRadiusX, 55, 50, 30, 20, "")
        TextGadget(#PB_Any, 5, 80, 45, 20, "Rotation", #PB_Text_Right)
        strRotation = StringGadget(#strRotation, 55, 75, 30, 20, "")        
        chkFlip = CheckBoxGadget(#chkFlip, 100, 75, 50, 20, "Flip")
        
      Case "Star"
        
        TextGadget(#PB_Any, 5, 10,50, 20, "Points", #PB_Text_Right)   
        spnSides = SpinGadget(#spnSides, 80, 10, 50, 20, 3, 10, #PB_Spin_Numeric)    
        TextGadget(#PB_Any, 60, 40, 20, 20, "X", #PB_Text_Center)    
        TextGadget(#PB_Any, 100, 40, 20, 20, "Y", #PB_Text_Center)    
        TextGadget(#PB_Any, 15, 65, 35, 20, "Centre", #PB_Text_Right)
        strX1 = StringGadget(#strX1, 55, 60, 35, 20, "")
        strY1 = StringGadget(#strY1, 95, 60, 35, 20, "")       
        TextGadget(#PB_Any, 5, 95, 75, 20, "Outer Radius", #PB_Text_Right)
        strRadiusX = StringGadget(#strRadiusX, 95, 90, 35, 20, "")
        TextGadget(#PB_Any, 5, 125, 75, 20, "Inner Radius", #PB_Text_Right)
        strRadiusY = StringGadget(#strRadiusY, 95, 120, 35, 20, "")    
        TextGadget(#PB_Any, 5, 155, 75, 20, "Rotation", #PB_Text_Right)
        strRotation = StringGadget(#strRotation, 95, 150, 35, 20, "")       
        
      Case "Text"
        
        TextGadget(#PB_Any, 10, 10, 40, 20, "Text", #PB_Text_Right)
        strText = StringGadget(#strText, 70, 10, 70, 20, "")
        btnFont = ButtonGadget(#btnFont, 10, 40, 50, 20, "Font")
        TextGadget(#PB_Any, 75, 40, 30, 20, "Size", #PB_Text_Right)
        spnSize = SpinGadget(#spnSize, 110, 40, 40, 20, 5, 50,#PB_Spin_Numeric)        
        strFont = StringGadget(#strFont, 10, 70, 140, 20, "")        
        TextGadget(#PB_Any, 65, 100, 20, 20, "X")
        TextGadget(#PB_Any, 105, 100, 20, 20, "Y")
        TextGadget(#PB_Any, 10, 125, 40, 20, "Centre")
        strX1 = StringGadget(#strX1, 60, 120, 30, 20, "")
        strY1 = StringGadget(#strY1, 100, 120, 30, 20, "")     
        TextGadget(#PB_Any, 10, 155, 45, 20, "Rotation", #PB_Text_Right)
        strRotation = StringGadget(#strRotation, 60, 150, 30, 20, "") 
         
    EndSelect
    CloseGadgetList()
    
  EndProcedure

  Procedure ShowElement(*Element.AppMain::DrawObject)
  
    Define lblStatus.s
    Define Process.i = #True
    
    If AppMain::Drawmode = "Idle"
      
      DisableGadget(cntElementsel,#False)     
      DisableGadget(btnNext,#False)
      DisableGadget(btnPrevious,#False)    
    
      If NumberOfElements = 0
        lblStatus = "0 Of 0"
        DisableGadget(btnNext,#True)
        DisableGadget(btnPrevious,#True) 
        SetGadgetText(txtStatus,lblStatus) 
        SetGadgetText(strType,"")     
        Process = #False
      ElseIf CurrentElement = 0 
        lblStatus = "1 Of " + Str(NumberOfElements)      
        DisableGadget(btnPrevious,#True) 
      ElseIf CurrentElement + 1 = NumberOfElements  
        lblStatus = Str(CurrentElement + 1) + " Of " + Str(NumberOfElements)       
        DisableGadget(btnNext,#True)
      Else
        DisableGadget(btnNext,#False)
        DisableGadget(btnPrevious,#False)       
        lblStatus = Str(CurrentElement + 1) + " Of " + Str(NumberOfElements)  
      EndIf
    Else
      DisableGadget(cntElementsel,#True)
    EndIf
    
    If Process = #True
      
      ;Which Icon is loaded?
      SetGadgetText(strCurrentIcon,CurrentIcon)
      SetGadgetText(txtStatus,lblStatus)

      If *Element\Pathtype = "Shape"
        SetGadgetText(strType,*Element\Pathtype + " : " + *Element\Text)
      Else
        SetGadgetText(strType,*Element\Pathtype)
      EndIf
      
      ShowEditGadgets(*Element\Pathtype)

      Select *Element\Pathtype
        
        Case "Arc"

          DisableGadget(cntPathOptions,#False)
          DisableGadget(chkFilled,#False)          
          DisableGadget(spnWidth,#False)    
          DisableGadget(optStroke,#False)          
          DisableGadget(optDash,#False) 
          DisableGadget(optDot,#False)           
          DisableGadget(strDashFactor,#False) 
          DisableGadget(strDotFactor,#False)      
          DisableGadget(chkRounded,#False)         
          SelectedColour = *Element\Colour
          SetColour(*Element\Colour)
          SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
          SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          
          If *Element\Filled = #True
            SetGadgetState(chkFilled,#True)
          Else
            SetGadgetState(chkFilled,#False)       
          EndIf 
          If *Element\Rounded = #True
            SetGadgetState(chkRounded,#True)
          Else
            SetGadgetState(chkRounded,#False)       
          EndIf          
          If *Element\Stroke = #True
            SetGadgetState(optStroke,#True)
            DisableGadget(strDashFactor,#True)
            DisableGadget(strDotFactor,#True)     
          EndIf    
          If *Element\Dash = #True
            SetGadgetState(optDash,#True)
            SetGadgetState(strDashFactor,*Element\DashFactor)
            SetGadgetText(strDashFactor,StrD(*Element\DashFactor,1))
            SetGadgetText(strDotFactor,"")      
            DisableGadget(strDotFactor,#True)     
          EndIf     
          If *Element\Dot = #True
            SetGadgetState(optDot,#True)
            SetGadgetState(strDotFactor,*Element\DotFactor)
            SetGadgetText(strDotFactor,StrD(*Element\DotFactor,1))
            SetGadgetText(strDashFactor,"")     
            DisableGadget(strDashFactor,#True)     
          EndIf  
           If *Element\Closed = #True
            SetGadgetState(#optClosed,#True)
          Else
             SetGadgetState(#optOpen,#True)           
          EndIf         
          SetGadgetState(spnWidth,*Element\Width)
          SetGadgetText(spnWidth,Str(*Element\Width))      
      
          SetGadgetText(#strX1,Str(*Element\X1))
          SetGadgetText(#strY1,Str(*Element\Y1))
          SetGadgetText(#strRadiusX,Str(*Element\RadiusX))
          SetGadgetText(#spnAngle1,Str(*Element\Angle1))
          SetGadgetText(#spnAngle2,Str(*Element\Angle2))       
        
        Case "Box"
          
          DisableGadget(cntPathOptions,#False)
          DisableGadget(chkFilled,#False)          
          DisableGadget(spnWidth,#False)    
          DisableGadget(optStroke,#False)          
          DisableGadget(optDash,#False) 
          DisableGadget(optDot,#False)           
          DisableGadget(strDashFactor,#False) 
          DisableGadget(strDotFactor,#False)      
          DisableGadget(chkRounded,#False)           
          SelectedColour = *Element\Colour
          SetColour(*Element\Colour)
          SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
          SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          
          If *Element\Filled = #True
            SetGadgetState(chkFilled,#True)
          Else
            SetGadgetState(chkFilled,#False)       
          EndIf 
          If *Element\Rounded = #True
            SetGadgetState(chkRounded,#True)
          Else
            SetGadgetState(chkRounded,#False)       
          EndIf          
          If *Element\Stroke = #True
            SetGadgetState(optStroke,#True)
            DisableGadget(strDashFactor,#True)
            DisableGadget(strDotFactor,#True)     
          EndIf    
          If *Element\Dash = #True
            SetGadgetState(optDash,#True)
            SetGadgetState(strDashFactor,*Element\DashFactor)
            SetGadgetText(strDashFactor,StrD(*Element\DashFactor,1))
            SetGadgetText(strDotFactor,"")      
            DisableGadget(strDotFactor,#True)     
          EndIf     
          If *Element\Dot = #True
            SetGadgetState(optDot,#True)
            SetGadgetState(strDotFactor,*Element\DotFactor)
            SetGadgetText(strDotFactor,StrD(*Element\DotFactor,1))
            SetGadgetText(strDashFactor,"")     
            DisableGadget(strDashFactor,#True)     
          EndIf   
          SetGadgetState(spnWidth,*Element\Width)
          SetGadgetText(spnWidth,Str(*Element\Width)) 
                    
          SetGadgetText(#strX1,Str(*Element\X1))
          SetGadgetText(#strY1,Str(*Element\Y1))
          SetGadgetText(#strX2,Str(*Element\X2))
          SetGadgetText(#strY2,Str(*Element\Y2))
        
        Case "Circle"
          
          DisableGadget(cntPathOptions,#False)
          DisableGadget(chkFilled,#False)          
          DisableGadget(spnWidth,#False)    
          DisableGadget(optStroke,#False)          
          DisableGadget(optDash,#False) 
          DisableGadget(optDot,#False)           
          DisableGadget(strDashFactor,#False) 
          DisableGadget(strDotFactor,#False)      
          DisableGadget(chkRounded,#False)         
          SelectedColour = *Element\Colour
          SetColour(*Element\Colour)
          SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
          SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          
          If *Element\Filled = #True
            SetGadgetState(chkFilled,#True)
          Else
            SetGadgetState(chkFilled,#False)       
          EndIf 
          If *Element\Rounded = #True
            SetGadgetState(chkRounded,#True)
          Else
            SetGadgetState(chkRounded,#False)       
          EndIf          
          If *Element\Stroke = #True
            SetGadgetState(optStroke,#True)
            DisableGadget(strDashFactor,#True)
            DisableGadget(strDotFactor,#True)     
          EndIf    
          If *Element\Dash = #True
            SetGadgetState(optDash,#True)
            SetGadgetState(strDashFactor,*Element\DashFactor)
            SetGadgetText(strDashFactor,StrD(*Element\DashFactor,1))
            SetGadgetText(strDotFactor,"")      
            DisableGadget(strDotFactor,#True)     
          EndIf     
          If *Element\Dot = #True
            SetGadgetState(optDot,#True)
            SetGadgetState(strDotFactor,*Element\DotFactor)
            SetGadgetText(strDotFactor,StrD(*Element\DotFactor,1))
            SetGadgetText(strDashFactor,"")     
            DisableGadget(strDashFactor,#True)     
          EndIf   
          SetGadgetState(spnWidth,*Element\Width)
          SetGadgetText(spnWidth,Str(*Element\Width))      
                    
          SetGadgetText(#strX1,Str(*Element\X1))
          SetGadgetText(#strY1,Str(*Element\Y1))
          SetGadgetText(#strRadiusX,Str(*Element\RadiusX))       
        
        Case "Curve"
          
          DisableGadget(cntPathOptions,#False)
          DisableGadget(chkFilled,#False)          
          DisableGadget(spnWidth,#False)    
          DisableGadget(optStroke,#False)          
          DisableGadget(optDash,#False) 
          DisableGadget(optDot,#False)           
          DisableGadget(strDashFactor,#False) 
          DisableGadget(strDotFactor,#False)      
          DisableGadget(chkRounded,#False)         
          SelectedColour = *Element\Colour
          SetColour(*Element\Colour)
          SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
          SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          
          If *Element\Filled = #True
            SetGadgetState(chkFilled,#True)
          Else
            SetGadgetState(chkFilled,#False)       
          EndIf 
          If *Element\Rounded = #True
            SetGadgetState(chkRounded,#True)
          Else
            SetGadgetState(chkRounded,#False)       
          EndIf          
          If *Element\Stroke = #True
            SetGadgetState(optStroke,#True)
            DisableGadget(strDashFactor,#True)
            DisableGadget(strDotFactor,#True)     
          EndIf    
          If *Element\Dash = #True
            SetGadgetState(optDash,#True)
            SetGadgetState(strDashFactor,*Element\DashFactor)
            SetGadgetText(strDashFactor,StrD(*Element\DashFactor,1))
            SetGadgetText(strDotFactor,"")      
            DisableGadget(strDotFactor,#True)     
          EndIf     
          If *Element\Dot = #True
            SetGadgetState(optDot,#True)
            SetGadgetState(strDotFactor,*Element\DotFactor)
            SetGadgetText(strDotFactor,StrD(*Element\DotFactor,1))
            SetGadgetText(strDashFactor,"")     
            DisableGadget(strDashFactor,#True)     
          EndIf   
          SetGadgetState(spnWidth,*Element\Width)
          SetGadgetText(spnWidth,Str(*Element\Width))       
          SetGadgetText(#strX1,Str(*Element\X1))
          SetGadgetText(#strY1,Str(*Element\Y1))
          SetGadgetText(#strX2,Str(*Element\X2))
          SetGadgetText(#strY2,Str(*Element\Y2))
          SetGadgetText(#strX3,Str(*Element\X3))
          SetGadgetText(#strY3,Str(*Element\Y3))
          SetGadgetText(#strX4,Str(*Element\X4))
          SetGadgetText(#strY4,Str(*Element\Y4))    
        
        Case "Ellipse"
        
          DisableGadget(cntPathOptions,#False)
          DisableGadget(chkFilled,#False)          
          DisableGadget(spnWidth,#False)    
          DisableGadget(optStroke,#False)          
          DisableGadget(optDash,#False) 
          DisableGadget(optDot,#False)           
          DisableGadget(strDashFactor,#False) 
          DisableGadget(strDotFactor,#False)      
          DisableGadget(chkRounded,#False)          
          
          SelectedColour = *Element\Colour
          SetColour(*Element\Colour)
          SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
          SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          
          If *Element\Filled = #True
            SetGadgetState(chkFilled,#True)
          Else
            SetGadgetState(chkFilled,#False)       
          EndIf 
          If *Element\Rounded = #True
            SetGadgetState(chkRounded,#True)
          Else
            SetGadgetState(chkRounded,#False)       
          EndIf          
          If *Element\Stroke = #True
            SetGadgetState(optStroke,#True)
            DisableGadget(strDashFactor,#True)
            DisableGadget(strDotFactor,#True)     
          EndIf    
          If *Element\Dash = #True
            SetGadgetState(optDash,#True)
            SetGadgetState(strDashFactor,*Element\DashFactor)
            SetGadgetText(strDashFactor,StrD(*Element\DashFactor,1))
            SetGadgetText(strDotFactor,"")      
            DisableGadget(strDotFactor,#True)     
          EndIf     
          If *Element\Dot = #True
            SetGadgetState(optDot,#True)
            SetGadgetState(strDotFactor,*Element\DotFactor)
            SetGadgetText(strDotFactor,StrD(*Element\DotFactor,1))
            SetGadgetText(strDashFactor,"")     
            DisableGadget(strDashFactor,#True)     
          EndIf
          SetGadgetText(#strX1,Str(*Element\X1))
          SetGadgetText(#strY1,Str(*Element\Y1))
          SetGadgetText(#strRadiusX,Str(*Element\RadiusX))          
          SetGadgetText(#strRadiusY,Str(*Element\RadiusY)) 
          SetGadgetText(#strRotation,Str(*Element\Rotation)) 
          
        Case "Line"
          
          DisableGadget(cntPathOptions,#False)
          DisableGadget(chkFilled,#True)          
          DisableGadget(spnWidth,#False)    
          DisableGadget(optStroke,#False)          
          DisableGadget(optDash,#False) 
          DisableGadget(optDot,#False)           
          DisableGadget(strDashFactor,#False) 
          DisableGadget(strDotFactor,#False)      
          DisableGadget(chkRounded,#False) 
          
          SelectedColour = *Element\Colour
          SetColour(*Element\Colour)
          SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
          SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          
          If *Element\Filled = #True
            SetGadgetState(chkFilled,#True)
          Else
            SetGadgetState(chkFilled,#False)       
          EndIf 
          If *Element\Rounded = #True
            SetGadgetState(chkRounded,#True)
          Else
            SetGadgetState(chkRounded,#False)       
          EndIf          
          If *Element\Stroke = #True
            SetGadgetState(optStroke,#True)
            DisableGadget(strDashFactor,#True)
            DisableGadget(strDotFactor,#True)     
          EndIf    
          If *Element\Dash = #True
            SetGadgetState(optDash,#True)
            SetGadgetState(strDashFactor,*Element\DashFactor)
            SetGadgetText(strDashFactor,StrD(*Element\DashFactor,1))
            SetGadgetText(strDotFactor,"")      
            DisableGadget(strDotFactor,#True)     
          EndIf     
          If *Element\Dot = #True
            SetGadgetState(optDot,#True)
            SetGadgetState(strDotFactor,*Element\DotFactor)
            SetGadgetText(strDotFactor,StrD(*Element\DotFactor,1))
            SetGadgetText(strDashFactor,"")     
            DisableGadget(strDashFactor,#True)     
          EndIf   
          SetGadgetState(spnWidth,*Element\Width)
          SetGadgetText(spnWidth,Str(*Element\Width)) 
                    
          SetGadgetText(#strX1,Str(*Element\X1))
          SetGadgetText(#strY1,Str(*Element\Y1))
          SetGadgetText(#strX2,Str(*Element\X2))
          SetGadgetText(#strY2,Str(*Element\Y2))
                    
        Case "Path"
          
          DisableGadget(cntPathOptions,#False)
          DisableGadget(chkFilled,#False)          
          DisableGadget(spnWidth,#False)    
          DisableGadget(optStroke,#False)          
          DisableGadget(optDash,#False) 
          DisableGadget(optDot,#False)           
          DisableGadget(strDashFactor,#False) 
          DisableGadget(strDotFactor,#False)      
          DisableGadget(chkRounded,#False) 
          
          SelectedColour = *Element\Colour
          SetColour(*Element\Colour)
          SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
          SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          

          If *Element\Filled = #True
            SetGadgetState(chkFilled,#True)
          Else
            SetGadgetState(chkFilled,#False)       
          EndIf 
          If *Element\Rounded = #True
            SetGadgetState(chkRounded,#True)
          Else
            SetGadgetState(chkRounded,#False)       
          EndIf           
          If *Element\Closed = #True
            SetGadgetState(#optClosed,#True)
          Else
            SetGadgetState(#optOpen,#True)            
          EndIf
           If *Element\Stroke = #True
            SetGadgetState(optStroke,#True)
            DisableGadget(strDashFactor,#True)
            DisableGadget(strDotFactor,#True)     
          EndIf    
          If *Element\Dash = #True
            SetGadgetState(optDash,#True)
            SetGadgetState(strDashFactor,*Element\DashFactor)
            SetGadgetText(strDashFactor,StrD(*Element\DashFactor,1))
            SetGadgetText(strDotFactor,"")      
            DisableGadget(strDotFactor,#True)     
          EndIf     
          If *Element\Dot = #True
            SetGadgetState(optDot,#True)
            SetGadgetState(strDotFactor,*Element\DotFactor)
            SetGadgetText(strDotFactor,StrD(*Element\DotFactor,1))
            SetGadgetText(strDashFactor,"")     
            DisableGadget(strDashFactor,#True)     
          EndIf         
          SetGadgetState(spnWidth,*Element\Width)
          SetGadgetText(spnWidth,Str(*Element\Width)) 
          
        Case "Poly"  
          
          DisableGadget(cntPathOptions,#False)
          DisableGadget(chkFilled,#False)          
          DisableGadget(spnWidth,#False)    
          DisableGadget(optStroke,#False)          
          DisableGadget(optDash,#False) 
          DisableGadget(optDot,#False)           
          DisableGadget(strDashFactor,#False) 
          DisableGadget(strDotFactor,#False)      
          DisableGadget(chkRounded,#False)           
          
          SelectedColour = *Element\Colour
          SetColour(*Element\Colour)
          SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
          SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          
          If *Element\Filled = #True
            SetGadgetState(chkFilled,#True)
          Else
            SetGadgetState(chkFilled,#False)       
          EndIf 
          If *Element\Rounded = #True
            SetGadgetState(chkRounded,#True)
          Else
            SetGadgetState(chkRounded,#False)       
          EndIf          
          If *Element\Stroke = #True
            SetGadgetState(optStroke,#True)
            DisableGadget(strDashFactor,#True)
            DisableGadget(strDotFactor,#True)     
          EndIf    
          If *Element\Dash = #True
            SetGadgetState(optDash,#True)
            SetGadgetState(strDashFactor,*Element\DashFactor)
            SetGadgetText(strDashFactor,StrD(*Element\DashFactor,1))
            SetGadgetText(strDotFactor,"")      
            DisableGadget(strDotFactor,#True)     
          EndIf     
          If *Element\Dot = #True
            SetGadgetState(optDot,#True)
            SetGadgetState(strDotFactor,*Element\DotFactor)
            SetGadgetText(strDotFactor,StrD(*Element\DotFactor,1))
            SetGadgetText(strDashFactor,"")     
            DisableGadget(strDashFactor,#True)     
          EndIf   
          SetGadgetState(spnWidth,*Element\Width)
          SetGadgetText(spnWidth,Str(*Element\Width)) 
          
          SetGadgetState(#spnSides,*Element\Points)        
          SetGadgetText(#strX1,Str(*Element\X1))
          SetGadgetText(#strY1,Str(*Element\Y1))
          SetGadgetText(#strRadiusX,Str(*Element\RadiusX)) 
          SetGadgetText(#strRotation,Str(*Element\Rotation))         
          
        Case "Shape"
          
          DisableGadget(cntPathOptions,#True)
          If *Element\Colour <> 0
            SelectedColour = *Element\Colour
            SetColour(*Element\Colour)
            SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
            SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          
          EndIf
          SetGadgetText(#strX1,Str(*Element\X1))
          SetGadgetText(#strY1,Str(*Element\Y1))
          SetGadgetText(#strRadiusX,Str(*Element\RadiusX)) 
          SetGadgetText(#strRotation,Str(*Element\Rotation))            
          If *Element\LeftRight = #True
            SetGadgetState(#chkFlip,#True)
          Else
            SetGadgetState(#chkFlip,#False)
          EndIf
          
        Case "Star" 
          
          DisableGadget(cntPathOptions,#False)
          DisableGadget(chkFilled,#False)          
          DisableGadget(spnWidth,#False)    
          DisableGadget(optStroke,#False)          
          DisableGadget(optDash,#False) 
          DisableGadget(optDot,#False)           
          DisableGadget(strDashFactor,#False) 
          DisableGadget(strDotFactor,#False)      
          DisableGadget(chkRounded,#False)         
          
          SelectedColour = *Element\Colour
          SetColour(*Element\Colour)
          SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
          SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          
          If *Element\Filled = #True
            SetGadgetState(chkFilled,#True)
          Else
            SetGadgetState(chkFilled,#False)       
          EndIf 
          If *Element\Rounded = #True
            SetGadgetState(chkRounded,#True)
          Else
            SetGadgetState(chkRounded,#False)       
          EndIf          
          If *Element\Stroke = #True
            SetGadgetState(optStroke,#True)
            DisableGadget(strDashFactor,#True)
            DisableGadget(strDotFactor,#True)     
          EndIf    
          If *Element\Dash = #True
            SetGadgetState(optDash,#True)
            SetGadgetState(strDashFactor,*Element\DashFactor)
            SetGadgetText(strDashFactor,StrD(*Element\DashFactor,1))
            SetGadgetText(strDotFactor,"")      
            DisableGadget(strDotFactor,#True)     
          EndIf     
          If *Element\Dot = #True
            SetGadgetState(optDot,#True)
            SetGadgetState(strDotFactor,*Element\DotFactor)
            SetGadgetText(strDotFactor,StrD(*Element\DotFactor,1))
            SetGadgetText(strDashFactor,"")     
            DisableGadget(strDashFactor,#True)     
          EndIf   
          SetGadgetState(spnWidth,*Element\Width)
          SetGadgetText(spnWidth,Str(*Element\Width)) 
          
          SetGadgetState(#spnSides,*Element\Points)   
          SetGadgetText(#strX1,Str(*Element\X1))
          SetGadgetText(#strY1,Str(*Element\Y1))
          SetGadgetText(#strRadiusX,Str(*Element\RadiusX)) 
          SetGadgetText(#strRadiusY,Str(*Element\RadiusY))           
          SetGadgetText(#strRotation,Str(*Element\Rotation))          
          
        Case "Text"
          
          DisableGadget(cntPathOptions,#False)
          DisableGadget(chkFilled,#False)          
          DisableGadget(spnWidth,#True)    
          DisableGadget(optStroke,#True)          
          DisableGadget(optDash,#True) 
          DisableGadget(optDot,#True)           
          DisableGadget(strDashFactor,#True) 
          DisableGadget(strDotFactor,#True)      
          DisableGadget(chkRounded,#True)          
          
          SelectedColour = *Element\Colour
          SetColour(*Element\Colour)
          SetGadgetState(spnTransp,Alpha(*Element\Colour)) 
          SetGadgetText(spnTransp,Str(Alpha(*Element\Colour)))          
          If *Element\Filled = #True
            SetGadgetState(chkFilled,#True)
          Else
            SetGadgetState(chkFilled,#False)       
          EndIf 
          If *Element\Rounded = #True
            SetGadgetState(chkRounded,#True)
          Else
            SetGadgetState(chkRounded,#False)       
          EndIf          
          If *Element\Stroke = #True
            SetGadgetState(optStroke,#True)
            DisableGadget(strDashFactor,#True)
            DisableGadget(strDotFactor,#True)     
          EndIf    
          If *Element\Dash = #True
            SetGadgetState(optDash,#True)
            SetGadgetState(strDashFactor,*Element\DashFactor)
            SetGadgetText(strDashFactor,StrD(*Element\DashFactor,1))
            SetGadgetText(strDotFactor,"")      
            DisableGadget(strDotFactor,#True)     
          EndIf     
          If *Element\Dot = #True
            SetGadgetState(optDot,#True)
            SetGadgetState(strDotFactor,*Element\DotFactor)
            SetGadgetText(strDotFactor,StrD(*Element\DotFactor,1))
            SetGadgetText(strDashFactor,"")     
            DisableGadget(strDashFactor,#True)     
          EndIf 
          SetGadgetText(#strFont,*Element\Font)          
          SetGadgetState(#spnSize,*Element\Width)
          SetGadgetText(#spnSize,Str(*Element\Width)) 
          SetGadgetText(#strX1,Str(*Element\X1))
          SetGadgetText(#strY1,Str(*Element\Y1))
          SetGadgetText(#strText,*Element\Text) 
          SetGadgetText(#strRotation,Str(*Element\Rotation))   
          
      EndSelect
      
    EndIf
  
  EndProcedure

  Procedure FinishPath(*Element.AppMain::DrawObject)
  
    If *Element\Filled = #True
      If *Element\Rounded = #True
        FillPath(#PB_Path_Preserve )
        StrokePath(*Element\Width * 5, #PB_Path_RoundEnd|#PB_Path_RoundCorner)
      Else
        FillPath(#PB_Path_Preserve )
        StrokePath(*Element\Width * 5)      
      EndIf
    Else
      If *Element\Rounded  = #True
        If *Element\Dash = #True
          DashPath(*Element\Width * 5,*Element\Width * 5 * *Element\DashFactor,#PB_Path_RoundEnd|#PB_Path_RoundCorner)
        ElseIf *Element\Dot = #True
          DotPath(*Element\width * 5,*Element\width * 5 * *Element\DotFactor,#PB_Path_RoundEnd|#PB_Path_RoundCorner)
        ElseIf *Element\Dash = #True
          DashPath(*Element\Width* 5,*Element\Width * 5 * *Element\DashFactor,#PB_Path_RoundEnd|#PB_Path_RoundCorner)
        Else
          StrokePath(*Element\Width * 5, #PB_Path_RoundEnd|#PB_Path_RoundCorner) 
        EndIf
      Else
        If *Element\Dash = #True
          DashPath(*Element\Width * 5,*Element\Width * 5 * *Element\DashFactor)
        ElseIf *Element\Dot = #True
          DotPath(*Element\width * 5,*Element\width * 5 * *Element\DotFactor)
        Else
          StrokePath(*Element\Width * 5) 
        EndIf
      EndIf     
    EndIf 
    
  EndProcedure
  
  Procedure DrawArc(*Element.AppMain::DrawObject)
     
    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf 
    DrawTrans = Alpha(*Element\Colour)
    VectorSourceColor(DrawColour)
    
    BeginVectorLayer(DrawTrans)
    
    If *Element\Closed = #True   
      MovePathCursor(*Element\X1 * 5, *Element\Y1 * 5)
      AddPathCircle(*Element\X1 * 5, *Element\Y1 * 5, *Element\RadiusX * 5, *Element\Angle1, *Element\Angle2, #PB_Path_Connected) 
      ClosePath()
    Else
      AddPathCircle(*Element\X1 * 5, *Element\Y1 * 5, *Element\RadiusX * 5, *Element\Angle1, *Element\Angle2) 
    EndIf
    
    FinishPath(*Element.AppMain::DrawObject)
 
    EndVectorLayer()
    
  EndProcedure 
   
  Procedure DrawBox(*Element.AppMain::DrawObject)  
     
    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf 
    DrawTrans = Alpha(*Element\Colour)
    
    Define BoxWidth.i = (*Element\X2-*Element\X1)  * 5
    Define BoxHeight.i = (*Element\Y2-*Element\Y1) * 5    
    VectorSourceColor(DrawColour)
    
    BeginVectorLayer(DrawTrans)
    
    AddPathBox(*Element\X1 * 5, *Element\Y1 * 5, BoxWidth, BoxHeight)

    FinishPath(*Element.AppMain::DrawObject)
 
    EndVectorLayer()
    
  EndProcedure  
   
  Procedure DrawCircle(*Element.AppMain::DrawObject)
        
    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf 
    DrawTrans = Alpha(*Element\Colour)
    
    VectorSourceColor(DrawColour)
    
    BeginVectorLayer(DrawTrans)

    AddPathCircle(*Element\X1 * 5, *Element\Y1 * 5, *Element\RadiusX * 5) 
    
    FinishPath(*Element.AppMain::DrawObject)
    
    EndVectorLayer()

  EndProcedure

  Procedure DrawCurve(*Element.AppMain::DrawObject)
           
    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf 
    DrawTrans = Alpha(*Element\Colour)
    
    VectorSourceColor(DrawColour)
    
    BeginVectorLayer(DrawTrans)
    
    MovePathCursor(*Element\X1 * 5, *Element\Y1 * 5)
    AddPathCurve(*Element\X2 * 5, *Element\Y2 * 5, *Element\X3 * 5, *Element\Y3 * 5, *Element\X4 * 5, *Element\Y4 * 5)

    FinishPath(*Element.AppMain::DrawObject)
    
    EndVectorLayer()
     
  EndProcedure

  Procedure DrawEllipse(*Element.AppMain::DrawObject)
             
    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf 
    DrawTrans = Alpha(*Element\Colour)
    
    VectorSourceColor(DrawColour)
    
    BeginVectorLayer(DrawTrans)
    
    ;Element\Rotation
    RotateCoordinates(*Element\X1 * 5, *Element\Y1 * 5,*Element\Rotation)    
    
    AddPathEllipse(*Element\X1 * 5, *Element\Y1 * 5, *Element\RadiusX * 5, *Element\RadiusY * 5)

    FinishPath(*Element.AppMain::DrawObject)
    
    EndVectorLayer()
    
  EndProcedure  
     
  Procedure DrawLine(*Element.AppMain::DrawObject)

    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf 
    DrawTrans = Alpha(*Element\Colour)
    
    VectorSourceColor(DrawColour)
    BeginVectorLayer(DrawTrans)    

      MovePathCursor(*Element\X1 * 5,*Element\Y1 * 5)
      AddPathLine(*Element\X2 * 5,*Element\Y2 * 5)
      
      FinishPath(*Element.AppMain::DrawObject)
      
    EndVectorLayer()
      
  EndProcedure
  
  Procedure DrawPath(*Element.AppMain::DrawObject)
    
    Dim Args.i(20)
    Define NumArgs.i
    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf 
    
    DrawTrans = Alpha(*Element\Colour)

    VectorSourceColor(DrawColour) 
    
    BeginVectorLayer(DrawTrans)    
    
    For i = 1 To CountString(*Element\Text, ",") + 1
        
      Select StringField(*Element\Text, i, ",")
          
        Case "M"
          
          NumArgs = 0
          i = i + 1
          Args(NumArgs) = Val(StringField(*Element\Text, i, ","))
          i = i + 1
          NumArgs = NumArgs + 1
          Args(NumArgs) = Val(StringField(*Element\Text, i, ","))       
          MovePathCursor(Args(0),Args(1))
          
        Case "L"
          
          NumArgs = 0       
          i = i + 1
          Args.i(NumArgs) = Val(StringField(*Element\Text, i, ","))
          i = i + 1
          NumArgs = NumArgs + 1
          Args.i(NumArgs) = Val(StringField(*Element\Text, i, ","))         
          AddPathLine(Args(0),Args(1)) 
          
        Case "A"
          
          NumArgs = 0       
          i = i + 1
          Args.i(NumArgs) = Val(StringField(*Element\Text, i, ","))
          i = i + 1
          NumArgs = NumArgs + 1        
          Args.i(NumArgs) = Val(StringField(*Element\Text, i, ","))
          i = i + 1
          NumArgs = NumArgs + 1         
          Args.i(NumArgs) = Val(StringField(*Element\Text, i, ","))
          i = i + 1
          NumArgs = NumArgs + 1 
          Args.i(NumArgs) = Val(StringField(*Element\Text, i, ","))
          i = i + 1
          NumArgs = NumArgs + 1 
          Args.i(NumArgs) = Val(StringField(*Element\Text, i, ","))
          AddPathArc (Args(0),Args(1),Args(2),Args(3),Args(4))
          
        Case "Z"
          
          ClosePath()
      EndSelect 
    
    Next i
  
    FinishPath(*Element.AppMain::DrawObject) 
    EndVectorLayer()
  
  EndProcedure  
  
  Procedure DrawPolyGon(*Element.AppMain::DrawObject)
    
    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf 
    DrawTrans = Alpha(*Element\Colour)
    
    Define Rotate = 360/*Element\Points
    
    VectorSourceColor(DrawColour)
    
    BeginVectorLayer(DrawTrans)
    
    ;Element\Rotation
    RotateCoordinates(*Element\X1 * 5, *Element\Y1 * 5,*Element\Rotation)
    
    MovePathCursor(*Element\X1 * 5,(*Element\Y1-*Element\RadiusX) * 5)
    For k = 1 To *Element\Points - 1
      RotateCoordinates(*Element\X1 * 5, *Element\Y1 * 5, Rotate)
      AddPathLine(*Element\X1 * 5, (*Element\Y1-*Element\RadiusX) * 5)
    Next
    ClosePath()
       
    FinishPath(*Element.AppMain::DrawObject)
     
    EndVectorLayer()
    
  EndProcedure  
  
  Procedure DrawShape(*Element.AppMain::DrawObject)
    
    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf    

    DrawTrans = Alpha(*Element\Colour)
    Scale = (*Element\RadiusX) /100
    
    Define ShapeImg = CreateImage(#PB_Any, 100,100, 32,#PB_Image_Transparent)
    
    VectorSourceColor(DrawColour)
    
    BeginVectorLayer(DrawTrans)
    
    ;X1,Y1 from Element
    TranslateCoordinates(*Element\X1 * 5,*Element\Y1 * 5)
    
    ;Element\Rotation
    RotateCoordinates(0,0,*Element\Rotation)  

    If *Element\LeftRight = #True
      FlipCoordinatesX(0)
    EndIf    

    ;Calculated scale from RadiusX
    ScaleCoordinates(Scale,Scale)    
    
    If DatabaseQuery(AppMain::ShapesDB, "SELECT * FROM ShapeElements WHERE ShapeID = " + Str(*Element\RadiusY) + ";")
      Define ShapeElement.AppMain::DrawObject
      While NextDatabaseRow(AppMain::ShapesDB)
        ShapeElement\Pathtype = GetDatabaseString(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "PathType")) 
        ShapeElement\Colour = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Colour"))
        ShapeElement\Trans = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Trans"))
        ShapeElement\Text = GetDatabaseString(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Text"))          
        ShapeElement\X1 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "X1"))
        ShapeElement\Y1 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Y1"))
        ShapeElement\X2 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "X2"))
        ShapeElement\Y2 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Y2"))      
        ShapeElement\X3 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "X3"))
        ShapeElement\Y3 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Y3"))     
        ShapeElement\X4 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "X4"))
        ShapeElement\Y4 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Y4"))
        ShapeElement\RadiusX = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "RadiusX"))
        ShapeElement\RadiusY = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "RadiusY"))     
        ShapeElement\Angle1 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Angle1"))
        ShapeElement\Angle2 = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Angle2"))
        ShapeElement\Points = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Points"))
        ShapeElement\Rotation = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Rotation"))     
        ShapeElement\Closed = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Closed"))     
        ShapeElement\Width = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Width"))     
        ShapeElement\Filled = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Filled"))
        ShapeElement\Rounded = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Rounded"))
        ShapeElement\Stroke = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Stroke"))
        ShapeElement\Dash = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Dash"))     
        ShapeElement\DashFactor = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "DashFactor"))     
        ShapeElement\Dot = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Dot"))     
        ShapeElement\DotFactor = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "DotFactor"))
        
        If ShapeElement\Colour <> 0
          If AppMain::GreyScale = #True
            NewColour = ConvertToGrey(ShapeElement\Colour)
            VectorSourceColor(NewColour)
          Else
            VectorSourceColor(ShapeElement\Colour)
          EndIf         
        Else
          VectorSourceColor(DrawColour) 
        EndIf
        
        SaveVectorState()
        
        ;Element\Rotation
        RotateCoordinates((ShapeElement\X1-50) * 5, (ShapeElement\Y1-50) * 5,ShapeElement\Rotation)
        
        Select ShapeElement\Pathtype
            
          Case "Arc"
            ;Done
            If ShapeElement\Closed = #True   
              MovePathCursor((ShapeElement\X1-50) * 5, (ShapeElement\Y1-50) * 5)
              AddPathCircle((ShapeElement\X1-50) * 5, (ShapeElement\Y1-50) * 5, ShapeElement\RadiusX * 5, ShapeElement\Angle1, ShapeElement\Angle2, #PB_Path_Connected) 
              ClosePath()
            Else
              AddPathCircle((ShapeElement\X1-50) * 5, (ShapeElement\Y1-50) * 5, ShapeElement\RadiusX * 5, ShapeElement\Angle1, ShapeElement\Angle2) 
            EndIf
            FinishPath(@ShapeElement.AppMain::DrawObject)           
            
          Case "Box"

            Define BoxWidth.i = (ShapeElement\X2 - ShapeElement\X1) * 5
            Define BoxHeight.i = (ShapeElement\Y2 - ShapeElement\Y1) * 5
            AddPathBox((ShapeElement\X1 - 50) * 5, (ShapeElement\Y1 - 50) *  5, BoxWidth, BoxHeight)
            FinishPath(@ShapeElement.AppMain::DrawObject)
            
          Case "Circle"
            ;Done
            AddPathCircle((ShapeElement\X1 - 50) * 5, (ShapeElement\Y1-50) * 5, ShapeElement\RadiusX * 5) 
            FinishPath(@ShapeElement.AppMain::DrawObject)
            
          Case "Curve"

            MovePathCursor(ShapeElement\X1, ShapeElement\Y1)
            AddPathCurve(ShapeElement\X2, ShapeElement\Y2, ShapeElement\X3, ShapeElement\Y3, ShapeElement\X4, ShapeElement\Y4)
            FinishPath(@ShapeElement.AppMain::DrawObject)               
            
          Case "Ellipse"

            AddPathEllipse((ShapeElement\X1 - 50) * 5, (ShapeElement\Y1 - 50) * 5, ShapeElement\RadiusX * 5, ShapeElement\RadiusY * 5)            
            FinishPath(@ShapeElement.AppMain::DrawObject)
            
          Case "Line"
            ;Done
            MovePathCursor((ShapeElement\X1 - 50) * 5 ,(ShapeElement\Y1 - 50) * 5 )
            AddPathLine((ShapeElement\X2 - 50) * 5,(ShapeElement\Y2 - 50) * 5)
            FinishPath(@ShapeElement.AppMain::DrawObject) 

          Case "Path"
            ;Done
            Dim Args.i(20)
            Define NumArgs.i
            
            For i = 1 To CountString(ShapeElement\Text, ",") + 1
              
              Select StringField(ShapeElement\Text, i, ",")
                Case "M"
                  NumArgs = 0
                  i = i + 1
                  Args(NumArgs) = Val(StringField(ShapeElement\Text, i, ","))
                  i = i + 1
                  NumArgs = NumArgs + 1
                  Args(NumArgs) = Val(StringField(ShapeElement\Text, i, ","))       
                  MovePathCursor((Args(0) - 50) * 5,(Args(1)-50) * 5)
                Case "L"
                  NumArgs = 0       
                  i = i + 1
                  Args.i(NumArgs) = Val(StringField(ShapeElement\Text, i, ","))
                  i = i + 1
                  NumArgs = NumArgs + 1
                  Args.i(NumArgs) = Val(StringField(ShapeElement\Text, i, ","))         
                  AddPathLine((Args(0) - 50) * 5,(Args(1)-50) * 5) 
                Case "A"
                  NumArgs = 0       
                  i = i + 1
                  Args.i(NumArgs) = Val(StringField(ShapeElement\Text, i, ","))
                  i = i + 1
                  NumArgs = NumArgs + 1        
                  Args.i(NumArgs) = Val(StringField(ShapeElement\Text, i, ","))
                  i = i + 1
                  NumArgs = NumArgs + 1         
                  Args.i(NumArgs) = Val(StringField(ShapeElement\Text, i, ","))
                  i = i + 1
                  NumArgs = NumArgs + 1 
                  Args.i(NumArgs) = Val(StringField(ShapeElement\Text, i, ","))
                  i = i + 1
                  NumArgs = NumArgs + 1 
                 Args.i(NumArgs) = Val(StringField(ShapeElement\Text, i, ","))
                 AddPathArc ((Args(0) - 50) * 5,(Args(1) - 50) * 5,(Args(2) - 50) * 5,(Args(3) - 50) * 5,Args(4)* 5)

               Case "Z"
                ClosePath()
            EndSelect 
    
          Next i
          FinishPath(@ShapeElement.AppMain::DrawObject)     
            
      EndSelect ;ShapeElement\Pathtype
      
      RestoreVectorState()
      
    Wend
      
  EndIf

  EndVectorLayer()
       
  EndProcedure 
  
  Procedure DrawStar(*Element.AppMain::DrawObject)
      
    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf 
    DrawTrans = Alpha(*Element\Colour)
    Define Rotate.d = 360/(*Element\Points * 2)
    
    VectorSourceColor(DrawColour)
    
    BeginVectorLayer(DrawTrans)
    
    RotateCoordinates(*Element\X1 * 5, *Element\Y1 * 5, *Element\Rotation)
    
    MovePathCursor(*Element\X1 * 5,(*Element\Y1-*Element\RadiusY) * 5)
    For k = 1 To *Element\Points * 2
      RotateCoordinates(*Element\X1 * 5, *Element\Y1 * 5, Rotate)
      If k & 1 = 1
        AddPathLine(*Element\X1 * 5, (*Element\Y1 - *Element\RadiusX) * 5)
      Else
        AddPathLine(*Element\X1 * 5, (*Element\Y1 - *Element\RadiusY) * 5)
      EndIf
    Next
    ClosePath() 
    
    FinishPath(*Element.AppMain::DrawObject)  
    
    EndVectorLayer()
    
  EndProcedure
  
  Procedure DrawMyText(*Element.AppMain::DrawObject)
    
    Define DrawColour.i,DrawTrans.i,Scale.d
    
    If AppMain::GreyScale = #True
      DrawColour = ConvertToGrey(*Element\Colour)
    Else
      DrawColour = RGBA(Red(*Element\Colour),Green(*Element\Colour),Blue(*Element\Colour),255)     
    EndIf 
    DrawTrans = Alpha(*Element\Colour)

    Define VFont.i = LoadFont(#PB_Any, *Element\Font, 8)
    VectorFont(FontID(VFont), *Element\Width * 5)
    
    Define CentreOffSetX.i = VectorTextWidth(*Element\Text)/2
    Define CentreOffSetY.i = VectorTextHeight(*Element\Text)/2    

    VectorSourceColor(DrawColour)
    
    BeginVectorLayer(DrawTrans)
    RotateCoordinates(*Element\X1 * 5, *Element\Y1 * 5, *Element\Rotation)
    
      MovePathCursor( (*Element\X1 * 5) - CentreOffSetX, (*Element\Y1 * 5) - CentreOffSetY)
      If *Element\Filled = #True
        DrawVectorText(*Element\Text)
      Else
        AddPathText(*Element\Text)
        StrokePath(1)
      EndIf
     
    EndVectorLayer()

  EndProcedure
  
  Procedure DrawIcon()
 
    If NumberOfElements > 0
    
      For iLoop = 0 To NumberOfElements - 1
        
        If AppMain::GreyScale = #True
          NewColour = ConvertToGrey(Elements(iLoop)\Colour)
          VectorSourceColor(NewColour)
        Else
          VectorSourceColor(Elements(iLoop)\Colour)
        EndIf

        Select Elements(iLoop)\PathType
 
          Case "Arc"
             DrawArc(@Elements(iLoop))         
            
          Case "Box"
            DrawBox(@Elements(iLoop))
          
          Case "Circle"
            DrawCircle(@Elements(iLoop))
            
          Case "Curve"
            DrawCurve(@Elements(iLoop))
            
          Case "Ellipse"
             DrawEllipse(@Elements(iLoop))         
          
          Case "Line"
            Drawline(@Elements(iLoop))
            
         Case "Path"
            
            DrawPath(@Elements(iLoop)) 
 
         Case "Poly"
            DrawPolyGon(@Elements(iLoop)) 

         Case "Shape"
           DrawShape(@Elements(iLoop)) 

         Case "Star"
           DrawStar(@Elements(iLoop))          
    
         Case "Text"
           DrawMyText(@Elements(iLoop)) 

      EndSelect
    Next  
  EndIf

  StopVectorDrawing()  
 
EndProcedure

  Procedure SetPathGadgets(*Element.AppMain::DrawObject,EventGadget.i)
            
    Select EventGadget
          
      Case  chkFilled

        If GetGadgetState(chkFilled) = #True
          *Element\Filled = #True
        Else
          *Element\Filled = #False
        EndIf
        
      Case spnWidth
        
        *Element\Width = GetGadgetState(spnWidth)
        
      Case chkRounded
        If GetGadgetState(chkRounded) = #True
          *Element\Rounded = #True
        Else
          *Element\Rounded = #False
        EndIf    
        
      Case optStroke
        DisableGadget(strDashFactor,#True)        
        DisableGadget(strDotFactor,#True)        
        If GetGadgetState(optStroke) = #True
          *Element\Stroke = #True
          *Element\Dash = #False
          *Element\Dot = #False
        EndIf       
        
      Case optDash
        DisableGadget(strDashFactor,#False)        
        DisableGadget(strDotFactor,#True)       
        If GetGadgetState(optDash) = #True
          *Element\Stroke = #False
          *Element\Dash = #True
          *Element\Dot = #False
          *Element\DashFactor = ValD(GetGadgetText(strDashFactor))
        EndIf  
        
      Case optDot
        DisableGadget(strDashFactor,#True)        
        DisableGadget(strDotFactor,#False)          
        If GetGadgetState(optDot) = #True
          *Element\Stroke = #False
          *Element\Dash = #False
          *Element\Dot = #True
          *Element\DotFactor = ValD(GetGadgetText(strDotFactor))         
        EndIf  
                 
       Case strDashFactor
         *Element\DashFactor = ValD(GetGadgetText(strDashFactor)) 
         
       Case strDotFactor
         *Element\DotFactor = ValD(GetGadgetText(strDotFactor))  
         
    EndSelect
    
  EndProcedure

  Procedure Redraw()
  
    Elements(CurrentElement)\Colour = SelectedColour
    
    Select Elements(CurrentElement)\PathType
      
      Case "Arc"
      
        Elements(CurrentElement)\X1 = Val(GetGadgetText(#strX1))
        Elements(CurrentElement)\Y1 = Val(GetGadgetText(#strY1))
        Elements(CurrentElement)\RadiusX = Val(GetGadgetText(#strRadiusX))
        Elements(CurrentElement)\Angle1 = Val(GetGadgetText(#spnAngle1))      
        Elements(CurrentElement)\Angle2 = Val(GetGadgetText(#spnAngle2))   
        If GetGadgetState(#optClosed) = #True
          Elements(CurrentElement)\Closed = #True
        Else
          Elements(CurrentElement)\Closed = #False
        EndIf
            
      Case "Box","Line"
      
        Elements(CurrentElement)\X1 = Val(GetGadgetText(#strX1))
        Elements(CurrentElement)\Y1 = Val(GetGadgetText(#strY1))
        Elements(CurrentElement)\X2 = Val(GetGadgetText(#strX2))
        Elements(CurrentElement)\Y2 = Val(GetGadgetText(#strY2))       
      
      Case "Circle"

        Elements(CurrentElement)\X1 = Val(GetGadgetText(#strX1))
        Elements(CurrentElement)\Y1 = Val(GetGadgetText(#strY1))
        Elements(CurrentElement)\RadiusX = Val(GetGadgetText(#strRadiusX))   
      
      Case "Curve"
      
        Elements(CurrentElement)\X1 = Val(GetGadgetText(#strX1))
        Elements(CurrentElement)\Y1 = Val(GetGadgetText(#strY1))
        Elements(CurrentElement)\X2 = Val(GetGadgetText(#strX2))
        Elements(CurrentElement)\Y2 = Val(GetGadgetText(#strY2))
        Elements(CurrentElement)\X3 = Val(GetGadgetText(#strX3))
        Elements(CurrentElement)\Y3 = Val(GetGadgetText(#strY3))
        Elements(CurrentElement)\X4 = Val(GetGadgetText(#strX4))
        Elements(CurrentElement)\Y4 = Val(GetGadgetText(#strY4))      
      
      Case "Ellipse"
      
        Elements(CurrentElement)\X1 = Val(GetGadgetText(#strX1))
        Elements(CurrentElement)\Y1 = Val(GetGadgetText(#strY1))
        Elements(CurrentElement)\RadiusX = Val(GetGadgetText(#strRadiusX))
        Elements(CurrentElement)\RadiusY = Val(GetGadgetText(#strRadiusY))
        Elements(CurrentElement)\Rotation = Val(GetGadgetText(#strRotation))
      
      Case "Path"
     
        ;Closed\Open
        If GetGadgetState(#optClosed) = #True
                  
          Elements(CurrentElement)\LeftRight = #True
                  
          If Right(Elements(CurrentElement)\Text,1) <>"Z"

            Elements(CurrentElement)\Text = Elements(CurrentElement)\Text + ",Z"
                    
          EndIf
                  
        ElseIf Right(Elements(CurrentElement)\Text,1) = "Z"
                  
          Elements(CurrentElement)\Text = Left(Elements(CurrentElement)\Text,Len(Elements(CurrentElement)\Text)-2)
          
        Else
                 
          Elements(CurrentElement)\LeftRight = #False
                  
        EndIf     
      
       Case "Poly"
      
        Elements(CurrentElement)\X1 = Val(GetGadgetText(#strX1))
        Elements(CurrentElement)\Y1 = Val(GetGadgetText(#strY1))
        Elements(CurrentElement)\RadiusX = Val(GetGadgetText(#strRadiusX))
        Elements(CurrentElement)\Points = Val(GetGadgetText(#spnSides))  
        Elements(CurrentElement)\Rotation = Val(GetGadgetText(#strRotation))     
      
       Case "Shape" 
      
        Elements(CurrentElement)\X1 = Val(GetGadgetText(#strX1))
        Elements(CurrentElement)\Y1 = Val(GetGadgetText(#strY1))
        Elements(CurrentElement)\RadiusX = Val(GetGadgetText(#strRadiusX))
        Elements(CurrentElement)\Rotation = Val(GetGadgetText(#strRotation))      
        If GetGadgetState(#chkFlip) = #True
          Elements(CurrentElement)\LeftRight = #True
        Else
          Elements(CurrentElement)\LeftRight = #False
        EndIf
            
      Case "Star"
      
        Elements(CurrentElement)\X1 = Val(GetGadgetText(#strX1))
        Elements(CurrentElement)\Y1 = Val(GetGadgetText(#strY1))
        Elements(CurrentElement)\RadiusX = Val(GetGadgetText(#strRadiusX))
        Elements(CurrentElement)\RadiusY = Val(GetGadgetText(#strRadiusY))      
        Elements(CurrentElement)\Points = Val(GetGadgetText(#spnSides))  
        Elements(CurrentElement)\Rotation = Val(GetGadgetText(#strRotation)) 
      
      Case "Text"
      
        Elements(CurrentElement)\X1 = Val(GetGadgetText(#strX1))
        Elements(CurrentElement)\Y1 = Val(GetGadgetText(#strY1))
        Elements(CurrentElement)\Text = GetGadgetText(#strText)  
        Elements(CurrentElement)\Width = GetGadgetState(#spnSize) 
        Elements(CurrentElement)\Rotation = Val(GetGadgetText(#strRotation))  
      
    EndSelect
 
    WhereToDraw("Canvas")
  
  EndProcedure

  Procedure EventHandler(Event.i)
    
    If ShapeDesignerActive = #True
      If Not ProgramRunning(ShapesProgramme)
        ShapeDesignerActive= #False       
        LoadShapesMenu()
        CreateWinMenu()
      EndIf
    EndIf
       
    Select Event
      
      Case #PB_Event_CloseWindow 
        
        End      
        
      Case #PB_Event_Menu
        
        Select EventMenu()
            
        Case #mnuIconNewGroup
            
          NewGroup::Open()
          If NewGroup::OkPressed = #True
            NewGroup()
          EndIf            
            
        Case #mnuIconNewIcon
             
          NewIcon::Open()
          If NewIcon::OkPressed = #True
            SelectedIconID =  NewIcon()
            CurrentIcon = NewIcon::Name
            LoadElements()             
            CurrentElement = 0
            ShowElement(@Elements(CurrentElement))
            WhereToDraw("Canvas")
            ShowIcons() 
            AppMain::ShapeLoaded = #True 
            DisableMenuItem(MainMenu, #mnuIconSave, #False)            
          EndIf
            
        Case #mnuIconLoad
            
          LoadIcon::Open()
          If LoadIcon::OkPressed = #True
            SelectedIconID = LoadIcon::SelectedIconID
            LoadElements()
            CurrentElement = 0
            ShowElement(@Elements(CurrentElement))
            WhereToDraw("Canvas")
            ShowIcons() 
            AppMain::ShapeLoaded = #True
            DisableMenuItem(MainMenu, #mnuIconSave, #False) 
          EndIf           
          
        Case #mnuIconSave
          
          Save()
          
        Case #mnuIconDelete
          
          If AppMain::ShapeLoaded = #True
            DeleteIcon()
            AppMain::ShapeLoaded = #False
            If StartVectorDrawing(CanvasVectorOutput(AppMain::drgCanvas))
              DrawVectorImage(ImageID(AppMain::EmptyImg), 255)  
              StopVectorDrawing()
            EndIf
          Else
            MessageRequester("Icon Designer","No Icon Selected",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf       
          
        Case #mnuIconShapeDesigner
          
           If ShapeDesignerActive = #False
            ShapeDesignerActive = #True
            ShapesProgramme = RunProgram(GetCurrentDirectory() + "/Shape Designer.exe", "", "",#PB_Program_Open )
          EndIf
          
        Case #mnuIconViewSave
          ViewIconWindow = IconView::Open() 
          ShowIcons()            
            
        Case #mnuIconExit  
            
          End
            
        Case #mnuDrawArc
          
          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Arc"
            ShowEditGadgets("Arc")
            DrawArc::Defaults()       
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf 
            
        Case #mnuDrawBox
            
          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Box"
            ShowEditGadgets("Box")
            DrawBox::Defaults()         
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf          
                    
        Case #mnuDrawCircle
          
          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Circle"
            ShowEditGadgets("Circle")
            DrawCircle::Defaults()        
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf            
          
        Case #mnuDrawCurve
          
          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Curve"
            ShowEditGadgets("Curve")
            DrawCurve::Defaults()         
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf 
            
        Case #mnuDrawEllipse
            
          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Ellipse"
            ShowEditGadgets("Ellipse")
            DrawEllipse::Defaults()         
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf                     
            
        Case #mnuDrawLine

          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Line"
            ShowEditGadgets("Line")
            DrawLine::Defaults()       
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf          
          
        Case #mnuDrawPath
          
          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Path"
            ShowEditGadgets("Path")
            DrawPath::Defaults()      
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf          
          
        Case #mnuDrawPoly  
          
          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Polygon"
            ShowEditGadgets("Poly")
            DrawPoly::Defaults()      
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf  
            
        Case #mnuDrawStar 
          
          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Star"
            ShowEditGadgets("Star")
            DrawStar::Defaults()       
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf  
            
        Case #mnuDrawText  
           
          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Text"
            ShowEditGadgets("Text")
            DrawText::Defaults()       
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf 
          
        Case #mnuHelpShow
         
          HelpWindow = HelpViewer::Open("Topic") 
          
        Default
          
          ;Only Shapes Left
          If AppMain::ShapeLoaded = #True
            AppMain::Drawmode = "Add Shape"
            ShowEditGadgets("Shape")
            DrawShape::Defaults()
            AppMain::NewObject\RadiusY = ShapesMenuArray(EventMenu() - 20)\ID 
            AppMain::NewObject\Text = ShapesMenuArray(EventMenu() - 20)\Name             
            SetGadgetText(btnRedraw,"Start")
            SetGadgetText(btndelete,"Cancel")
          Else
            MessageRequester("Icon Designer","No Icon Loaded",#PB_MessageRequester_Ok|#PB_MessageRequester_Error)
          EndIf         
          
          
      EndSelect  ;EventMenu()

    Case #PB_Event_Gadget
      
      Select EventGadget()
          
        Case  chkFilled,spnWidth,chkRounded,optStroke,optDash,optDot,strDashFactor,strDotFactor
          
          If AppMain::Drawmode = "Idle"
            SetPathGadgets(Elements(CurrentElement),EventGadget())          
          Else
            SetPathGadgets(AppMain::NewObject,EventGadget()) 
          EndIf 
          
        Case btnNext
            
          If CurrentElement < ArraySize(Elements())
            CurrentElement = CurrentElement + 1
          EndIf
          ShowElement(@Elements(CurrentElement))
 
        Case btnPrevious
          
          If CurrentElement > 0
            CurrentElement = CurrentElement - 1
          EndIf
          ShowElement(@Elements(CurrentElement))
            
        Case btnRedraw
          
          Select AppMain::Drawmode
              
            Case "Idle"

              Redraw()
              ShowIcons() 
              
            Case "Add Arc"

              DrawArc::NewArc()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete")  
              
            Case "Add Box"

              DrawBox::NewBox()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete")              
              
            Case "Add Circle"

              DrawCircle::NewCircle()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete")             
              
            Case "Add Curve"

              DrawCurve::NewCurve()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete")              
              
            Case "Add Ellipse"

              DrawEllipse::NewEllipse()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete")              
                            
            Case "Add Line"

              DrawLine::NewLine()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete") 
               
            Case "Add Path"

              DrawPath::NewPath()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete")    
              
            Case "Add Polygon"

              DrawPoly::NewPoly()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete")              
              
            Case "Add Star"

              DrawStar::NewStar()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete") 
              
            Case "Add Text"

              DrawText::NewText()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete")   
              
            Case "Add Shape"

              DrawShape::NewShape()
              SetGadgetText(btnRedraw,"ReDraw")
              SetGadgetText(btndelete,"Delete") 
              
          EndSelect         
            
        Case btnSelectColour
          
          ;Call ColourRequester with current colour
          Colour = ColorRequester(RGB(Red(SelectedColour),Green(SelectedColour),Blue(SelectedColour)))
          If Colour > -1
            SelectedColour = RGBA(Red(Colour),Green(Colour),Blue(Colour),GetGadgetState(spnTransp))  
            SetColour(SelectedColour)
          EndIf           
            
        Case spnTransp
          
          ;Show selected transparency in colour display if it exists
          SelectedColour = RGBA(Red(SelectedColour),Green(SelectedColour),Blue(SelectedColour),GetGadgetState(spnTransp)) 
          If IsGadget(cnvColour)
            SetColour(SelectedColour)
          EndIf 
            
        Case #btnFont
             
          FontRequester("Arial",0,0)
          SetGadgetText(#strFont,SelectedFontName())
          If AppMain::Drawmode = "Idle"
            Elements(CurrentElement)\Font = SelectedFontName()
          Else
            AppMain::NewObject\Font = SelectedFontName()
          EndIf
                      
        Case #btnEditPath
            
          Elements(CurrentElement)\Text =  EditPath::Open(Elements(CurrentElement)\Text)            
            
        Case btnDelete
          
          If AppMain::Drawmode = "Idle"

            If CurrentElement > -1
              For a=CurrentElement To ArraySize(Elements())-1
                Elements(a) = Elements(a+1)
              Next 
              If ArraySize(Elements()) > 0
                ReDim Elements(ArraySize(Elements())-1)
              EndIf           
            EndIf
            NumberOfElements = NumberOfElements - 1        
            If CurrentElement > 0
              CurrentElement = CurrentElement - 1
            EndIf
            ShowElement(@Elements(CurrentElement))
            WhereToDraw("Canvas")
            ShowIcons()           
          Else
            
            AppMain::Drawmode = "Idle"
            SetGadgetText(btnRedraw,"ReDraw")
            SetGadgetText(btndelete,"Delete") 
            ShowElement(@Elements(CurrentElement))
            SetGadgetText(txtToolTip,AppMain::Drawmode) 
            
          EndIf

        EndSelect  ;EventGadget()
      
    EndSelect  ;Event  
 
  EndProcedure

;Main Programme Start

AppMain::BlankImg = CreateImage(#PB_Any, 640,640, 32,#PB_Image_Transparent)
AppMain::EmptyImg = CreateImage(#PB_Any, 640,640, 32,RGB(255,255,255))
AppMain::IconGreyImg = CreateImage(#PB_Any, 640,640, 32,#PB_Image_Transparent)
AppMain::Drawmode = "Idle"

OpenShapesDB()
LoadShapesMenu()

MainWin = OpenWindow(#PB_Any, 0, 0, 830, 690, "Vector Icon designer", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
;Move window to top of screen horizontally centered
ResizeWindow(MainWin,#PB_Ignore,0,#PB_Ignore,#PB_Ignore)
;Add Menu
CreateWinMenu()
  
;Add The Gadgets
cvsRulerH = CanvasGadget(#PB_Any, 25, 0, 640,25)  ;Horizontal Ruler
cvsRulerV = CanvasGadget(#PB_Any, 0, 25, 25,640)  ;Vertical Ruler
DrawRulers()  ;Draw Rulers
AppMain::drgCanvas = CanvasGadget(#PB_Any, 25, 25, 640, 640)

;Icon Element Selection
cntElementsel = ContainerGadget(#PB_Any, 670, 5, 155, 135, #PB_Container_Single)
txtCurrentIcon = TextGadget(#PB_Any, 10, 10, 140, 20, "Current Icon")
strCurrentIcon = StringGadget(#PB_Any,10, 30, 140, 20, "")  
TextGadget(#PB_Any, 10, 60, 60, 20, "Element")
txtStatus = TextGadget(#PB_Any, 40, 80, 70, 20, " 0 Of 0 ", #PB_Text_Center)    
btnPrevious = ButtonGadget(#PB_Any, 10, 75, 25, 25, "<")
DisableGadget(btnPrevious,#True)
btnNext = ButtonGadget(#PB_Any, 115, 75, 25, 25, ">")
DisableGadget(btnNext,#True)
strType = StringGadget(#PB_Any, 10, 105, 140, 20, "")
CloseGadgetList()

;Colour selection
cntColour = ContainerGadget(#PB_Any, 670, 145, 155, 85, #PB_Container_Single)
  btnSelectColour = ButtonGadget(#PB_Any, 10, 10, 90, 25, "Select Colour")
  cvsColour = CanvasGadget(#PB_Any, 110, 10, 25, 25, #PB_Canvas_Border)
  TextGadget(#PB_Any, 10, 55, 70, 20, "Transparency", #PB_Text_Right)
  spnTransp = SpinGadget(#PB_Any, 90, 50, 45, 20, 100, 255, #PB_Spin_ReadOnly | #PB_Spin_Numeric) 
CloseGadgetList()
  
;Element Edits
cntElementedit = ContainerGadget(#PB_Any, 670, 235, 155, 200, #PB_Container_Single)
CloseGadgetList()

;Path Options
cntPathOptions = ContainerGadget(#PB_Any, 670, 440, 155, 130, #PB_Container_Single)
  chkFilled = CheckBoxGadget(#PB_Any, 10, 10, 50, 20, "Filled") 
  TextGadget(#PB_Any,70,13,30,20,"Width")
  spnWidth = SpinGadget(#PB_Any, 100, 10, 40, 20, 1, 50, #PB_Spin_Numeric)
  chkRounded = CheckBoxGadget(#PB_Any, 90, 40, 70, 20, "Rounded") 
  optStroke = OptionGadget(#PB_Any, 10, 40, 50, 20, "Solid")
  optDash = OptionGadget(#PB_Any, 10, 70, 55, 20, "Dashed")
  optDot = OptionGadget(#PB_Any, 10, 100, 55, 20, "Dotted")
  TextGadget(#PB_Any,70,73,30,20,"Factor")
  strDashFactor = StringGadget(#PB_Any, 105, 70, 40, 20,"1.5")
  TextGadget(#PB_Any,70,103,30,20,"Factor")
  strDotFactor = StringGadget(#PB_Any, 105, 100, 40, 20,"1.5")
CloseGadgetList()
btnRedraw = ButtonGadget(#PB_Any, 690, 580, 50, 25, "Redraw")
btndelete = ButtonGadget(#PB_Any, 760, 580, 50, 25, "Delete")

SelectedColour = RGBA(0,0,0,255)
SetColour(SelectedColour)
SetGadgetState(spnTransp,255)

Repeat
  
  Event = WaitWindowEvent()
  
  Select EventWindow() 
      
    Case MainWin

      EventHandler(Event)
      
    Case ViewIconWindow

      IconView::EventHandler(Event)
      If Not IsWindow(ViewIconWindow)
        ViewIconWindow = #Null
      EndIf
      
    Case HelpWindow

      HelpViewer::EventHandler(Event)
      
  EndSelect ;EventWindow() 

ForEver

EndModule
; IDE Options = PureBasic 5.51 (Windows - x64)
; CursorPosition = 416
; FirstLine = 248
; Folding = H5FAAy
; EnableXP