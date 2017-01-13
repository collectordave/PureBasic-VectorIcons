;{ ==Code Header Comment==============================
;        Name/title: DrawPoly.pbi
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
;       Description: Module to handle drawing of polygons on main form canvas
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

DeclareModule DrawPoly
  
 Declare NewPoly()
 Declare Defaults()
  
EndDeclareModule

Module DrawPoly

  Global strStartX, strStartY, OptFill, OptOutline, strAngle.i, btnOk, btnDone, chkRound
   
  Global DrawAction.i = -1 
        
  Procedure Process(x.i,y.i)
    
    Static Angle1.i
    
    If StartVectorDrawing(CanvasVectorOutput(AppMain::drgCanvas))
      
      ;Clear canvas To Existing Drawing
      DrawVectorImage(ImageID(AppMain::DrawnImg), 255)
       
      VectorSourceColor(AppMain::NewObject\Colour)
      
      Select DrawAction
          
        Case 0  ;Set Centre Point

            
        Case 1 ;Set Outer Radius

          AppMain::NewObject\RadiusX = (Sqr(Pow(((AppMain::NewObject\X1 * 5) - X ),2) + Pow(((AppMain::NewObject\Y1 * 5) - Y),2)))/5           
          SetGadgetText(Main::#strRadiusX,Str(AppMain::NewObject\RadiusX/5))
          Main::DrawPolygon(AppMain::NewObject)
        
        Case 2
            
          ;Set rotation angle
          VectorSourceColor(RGBA($00,$FF,$00,$FF))
          AddPathCircle(AppMain::NewObject\X1 * 5,AppMain::NewObject\Y1 * 5, AppMain::NewObject\RadiusX * 5 , 0,360)     
          StrokePath(1)   
            
          ;Show Chose angle line           
          VectorSourceColor(RGBA($FF,$00,$00,$FF))
          MovePathCursor(AppMain::NewObject\X1 * 5,AppMain::NewObject\Y1 * 5)
          AddPathLine(x,y)
          DashPath(1, 5)
            
          If x => AppMain::NewObject\X1 * 5 And Y => AppMain::NewObject\Y1 * 5
            If X - AppMain::NewObject\X1 * 5 = 0
              Angle1 = 90
            Else
              Angle1 = Degree(ATan((Y - AppMain::NewObject\Y1 * 5)/(X - AppMain::NewObject\X1 * 5)))
            EndIf
          ElseIf  x =< AppMain::NewObject\X1 * 5 And Y => AppMain::NewObject\Y1 * 5
            If Y-AppMain::NewObject\Y1 * 5 = 0
              Angle1 = 180
            Else
              Angle1 = 90 + Degree(ATan((AppMain::NewObject\X1 * 5 - X)/(Y - AppMain::NewObject\Y1 * 5)))
            EndIf
          ElseIf  x =< AppMain::NewObject\X1 * 5 And Y =< AppMain::NewObject\Y1 * 5
            If X - AppMain::NewObject\X1 * 5 = 0
              Angle1 = 270
            Else
              Angle1 = 180 + Degree(ATan((Y - AppMain::NewObject\Y1 * 5)/(X - AppMain::NewObject\X1 * 5)))
            EndIf
          ElseIf  x => AppMain::NewObject\X1 * 5 And Y =< AppMain::NewObject\Y1 * 5
            Angle1 = 270 + Degree(ATan((X - AppMain::NewObject\X1 * 5)/(AppMain::NewObject\Y1 * 5 - Y)))
          EndIf
          AppMain::NewObject\Rotation = Angle1
            ;Reset Vector colour
            VectorSourceColor(AppMain::NewObject\Colour)
            Main::DrawPolygon(AppMain::NewObject)
  
          Case  3
           Main::DrawPolygon(AppMain::NewObject)
          
             
       EndSelect 

    ;VectorSourceColor(AppMain::NewObject\Colour)
    ;StrokePath(AppMain::NewObject\Thickness * 5)
    StopVectorDrawing()
    
  EndIf
    
  EndProcedure   
    
  Procedure DrawPoly()

  Done = #False
  Static OldX.i,OldY.i
  
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
                    ;First Mouse Click Set Centre Point
                    AppMain::NewObject\X1 = X/5
                    AppMain::NewObject\Y1 = Y/5
                    SetGadgetText(Main::#strX1,Str(AppMain::NewObject\X1))      
                    SetGadgetText(Main::#strY1,Str(AppMain::NewObject\Y1))                   
                    Drawaction = Drawaction + 1
              
                  Case 1
                    ;Second Click Set Radius
                    AppMain::NewObject\RadiusX = (Sqr(Pow(((AppMain::NewObject\X1 * 5) - X ),2) + Pow(((AppMain::NewObject\Y1 * 5) - Y),2)))/5           
                    SetGadgetText(Main::#strRadiusX,Str(AppMain::NewObject\RadiusX/5)) 
                    Drawaction = Drawaction + 1
 
                  Case 2
                    
                    ;Third Click Set Rotation
                    SetGadgetText(Main::#strRotation,Str(AppMain::NewObject\Rotation))   
                    Drawaction = Drawaction + 1 
                    Process(x,y) 
                    Appmain::Drawmode = "Idle"                    
                    Main::SaveElement("Poly")
                    Done = #True
                    
                    Drawaction = Drawaction + 1 
                    
                EndSelect
                
              Case #PB_EventType_MouseMove
                
                ;Only on significant move
                If (x <> OldX) Or (y <> OldY) 
                  OldX = x
                  OldY = y
                  
                  Select Drawaction
                      
                    Case 0
                      
                      ;Show Centre Point 
                      SetGadgetText(Main::#strX1,Str(X/5))      
                      SetGadgetText(Main::#strY1,Str(Y/5))  
                      
                    Case 1 
                      
                      ;Show Radius 
                      AppMain::NewObject\RadiusX = (Sqr(Pow(((AppMain::NewObject\X1 * 5) - X ),2) + Pow(((AppMain::NewObject\Y1 * 5) - Y),2)))/5           
                      SetGadgetText(Main::#strRadiusX,Str(AppMain::NewObject\RadiusX/5))       
                      Process(x,y) 

                   Case 2 
                     
                     ;Third Show Rotation Angle
                     AppMain::NewObject\Rotation = Sqr(Pow((AppMain::NewObject\X1-X),2) + Pow((AppMain::NewObject\Y1-Y),2))           
                     Process(x,y) 
                     SetGadgetText(Main::#strRotation,Str(AppMain::NewObject\Rotation))

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

  Procedure NewPoly()

    ;Start the drawing operation
    GrabDrawnImage() 
    Drawaction = 0
    AppMain::NewObject\Points = GetGadgetState(Main::#spnSides)   
    DrawPoly()

    AppMain::Drawmode = "Idle"

EndProcedure

Procedure Defaults()
  
  ;Set PolyGon Defaults
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
  AppMain::NewObject\Pathtype = "Poly"  
  AppMain::NewObject\Points = 3
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
; CursorPosition = 163
; FirstLine = 190
; Folding = f-
; EnableXP
; EnableUnicode