;{ ==Code Header Comment==============================
;        Name/title: DrawPath.pbi
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
;       Description: Module to handle drawing of Paths on main form canvas
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

EnableExplicit

DeclareModule DrawPath
  
  Declare NewPath()
  Declare Defaults()
  
EndDeclareModule

Module DrawPath
  
  ;Structure Array to hold path data  
  Structure Location
    Type.s
    Arg1.i
    Arg2.i
    Arg3.i
    Arg4.i
    Arg5.i
  EndStructure
  Global Dim PathPoints.location(0)   
   
  Global DrawAction.i = -1
  
  Global Accept.i = #True
  
  Global PathString.s
  
  Global strStartX.i, strStartY.i, spnThickness.i, btnDone.i
    
  Global TestRound.i = #True
  
  Procedure SavePath()
    
    Define DrawText.s = ""
    
    For iLoop = 0 To ArraySize(PathPoints())
      Select   PathPoints(iLoop)\Type
         Case "M"
          DrawText = "M," + Str(PathPoints(iLoop)\Arg1) + "," + Str(PathPoints(iLoop)\Arg2)      
        Case "L"
          DrawText = DrawText + ",L," + Str(PathPoints(iLoop)\Arg1) + "," + Str(PathPoints(iLoop)\Arg2)   
        Case "A"  
          DrawText = DrawText + ",A," + Str(PathPoints(iLoop)\Arg1) + "," + Str(PathPoints(iLoop)\Arg2)+ "," + Str(PathPoints(iLoop)\Arg3)+ "," + Str(PathPoints(iLoop)\Arg4)+ "," + Str(PathPoints(iLoop)\Arg5)
      EndSelect    
    Next
    If GetGadgetState(Main::#optClosed)
      DrawText = DrawText + ",Z"
    EndIf

    AppMain::NewObject\Text = DrawText
 
  EndProcedure
   
  Procedure Process(x.i,y.i)
    
   AppMain::NewObject\Colour = Main::SelectedColour
   
    Select DrawAction
            
      Case 0
        ;No Action 
            
      Default
        
       If StartVectorDrawing(CanvasVectorOutput(AppMain::drgCanvas))
         ;Clearcanvas
         DrawVectorImage(ImageID(AppMain::DrawnImg), 255)
        SavePath()
         Main::DrawPath(AppMain::NewObject)

         StopVectorDrawing()   
         
       EndIf  
       
   EndSelect       

  EndProcedure
  
  Procedure DrawPath()
  
    Done = #False
    Static OldX.i,OldY.i
    Protected ThisPath.s
    Protected CurrentAction.i
  
    Repeat
  
    Event = WaitWindowEvent()
    
    Select Event
        
      Case #PB_Event_Gadget
        
        Select EventGadget()
              
          Case AppMain::drgCanvas
            ;Snap To grid
            X = Round((GetGadgetAttribute(AppMain::drgCanvas, #PB_Canvas_MouseX)/5) ,#PB_Round_Nearest) * 5
            Y = Round((GetGadgetAttribute(AppMain::drgCanvas, #PB_Canvas_MouseY)/5),#PB_Round_Nearest) * 5
            If X < 0
              X = 0
            ElseIf X > 640
              X = 640
            EndIf
            If Y < 0
              Y = 0
            ElseIf Y > 640
              Y = 640
            EndIf
            
            Select EventType()
          
              Case #PB_EventType_LeftClick
     
                Select Drawaction
                    
                  Case 0 
                    ;First Mouse Click Set Start Point
                    PathPoints(0)\Type = "M"
                    PathPoints(0)\Arg1 = X
                    PathPoints(0)\Arg2 = Y
                    Drawaction = Drawaction + 1
                    ReDim  PathPoints(Drawaction)
                    ChooseElement::Open()
                    If ChooseElement::EndPath = #True
                      Appmain::Drawmode = "Idle"                    
                      Main::SaveElement("Path")  
                      Done = #True       
                    Else
                      PathPoints(Drawaction)\Type = ChooseElement::Type
                      PathPoints(Drawaction)\Arg5 = ChooseElement::Radius  
                    EndIf                   
                    CurrentAction = 0
                    
                  Default
                    Select PathPoints(Drawaction)\Type
                      Case "L"
                        ;For Line
                        PathPoints(Drawaction)\Arg1 = X
                        PathPoints(Drawaction)\Arg2 = Y
                        Drawaction = Drawaction + 1
                        ReDim  PathPoints(Drawaction) 
                        ;End Of Line So Choose New Element
                        ChooseElement::Open()
                        If ChooseElement::EndPath = #True
                          Appmain::Drawmode = "Idle"                    
                          Main::SaveElement("Path")  
                          Done = #True       
                        Else
                          PathPoints(Drawaction)\Type = ChooseElement::Type
                          PathPoints(Drawaction)\Arg5 = ChooseElement::Radius  
                        EndIf                      
                        CurrentAction = 0
                        
                      Case "A"
                        If CurrentAction = 0
                          PathPoints(Drawaction)\Arg1 = X
                          PathPoints(Drawaction)\Arg2 = Y
                          CurrentAction = 1
                        Else
                          PathPoints(Drawaction)\Arg3 = X
                          PathPoints(Drawaction)\Arg4 = Y                        
                          Drawaction = Drawaction + 1          
                          ReDim  PathPoints(Drawaction) 
                          ChooseElement::Open()
                          If ChooseElement::EndPath = #True
                          Appmain::Drawmode = "Idle"                    
                          Main::SaveElement("Path")  
                          Done = #True       
                          Else
                            PathPoints(Drawaction)\Type = ChooseElement::Type
                            PathPoints(Drawaction)\Arg5 = ChooseElement::Radius  
                          EndIf
                          CurrentAction = 0
                        EndIf  
                    EndSelect ;PathPoints(Drawaction)\Type
  
                EndSelect
           
              Case #PB_EventType_MouseMove
                
                ;Only on significant move
                If (x <> OldX) Or (y <> OldY) 
                  OldX = x
                  OldY = y
                  
                  Select Drawaction
                    Case 0
 
                    Default
                      Select PathPoints(Drawaction)\Type
                        Case "L"
                          PathPoints(Drawaction)\Arg1 = X
                          PathPoints(Drawaction)\Arg2 = Y                      

                        Case "A"
                          If CurrentAction = 0
                            PathPoints(Drawaction)\Arg1 = X
                            PathPoints(Drawaction)\Arg2 = Y 
                          Else
                            PathPoints(Drawaction)\Arg3 = X
                            PathPoints(Drawaction)\Arg4 = Y
                          EndIf
                        
                      EndSelect  ;PathPoints(Drawaction)\Type   
                      Process(X,Y)                          
                          
                  EndSelect ;Drawaction
                  
                EndIf
                
            EndSelect  ;EventType()   
            
        EndSelect  ;EventGadget()
        
    EndSelect  ;Event 
   
  Until Done = #True
  
EndProcedure
  
  Procedure GrabDrawnImage()
       
    ;Create Drawn Image 
    AppMain::DrawnImg = CreateImage(#PB_Any, 640,640, 32)
    If StartDrawing(ImageOutput(AppMain::DrawnImg))
      DrawImage(GetGadgetAttribute(AppMain::drgCanvas, #PB_Canvas_Image), 0, 0)
      StopDrawing()
    EndIf

  EndProcedure

  Procedure NewPath()

    ;Start the drawing operation
    ;Get the image drawn so far
    GrabDrawnImage() 
    Drawaction = 0
    ;ChooseElement::Open()
    DrawPath()
    AppMain::Drawmode = "Idle"
 
  EndProcedure

 Procedure Defaults()
  
  ;Set Path Defaults
  AppMain::NewObject\Angle1 = 0
  AppMain::NewObject\Angle2 = 0  
  AppMain::NewObject\Closed = #False 
  AppMain::NewObject\Colour = RGBA(0,0,0,255)  
  AppMain::NewObject\Dash = #False
  AppMain::NewObject\DashFactor = 1.1 
  AppMain::NewObject\Dot = #False
  AppMain::NewObject\DotFactor = 1.1  
  AppMain::NewObject\Filled = #False
  AppMain::NewObject\Font = ""
  AppMain::NewObject\LeftRight = #False
  AppMain::NewObject\Pathtype = "Path"  
  AppMain::NewObject\Points = 0
  AppMain::NewObject\RadiusX = 0
  AppMain::NewObject\RadiusY = 0
  AppMain::NewObject\Rotation = 0
  AppMain::NewObject\Rounded = #False  
  AppMain::NewObject\Stroke = #True  
  AppMain::NewObject\Text = ""
  AppMain::NewObject\Trans = 255
  AppMain::NewObject\Width = 1
  AppMain::NewObject\X1 = 0
  AppMain::NewObject\Y1 = 0  
  AppMain::NewObject\X2 = 0  
  AppMain::NewObject\Y2 = 0  
  AppMain::NewObject\X3 = 0
  AppMain::NewObject\Y3 = 0  
  AppMain::NewObject\X4 = 0  
  AppMain::NewObject\Y4 = 0   
  
  ;Show Defaults
  Main::ShowElement(AppMain::NewObject)
  
EndProcedure

EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 17
; Folding = n5
; EnableXP