;{ ==Code Header Comment==============================
;        Name/title: DrawLine.pbi
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
;       Description: Module to handle drawing of lines on main form canvas
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

DeclareModule DrawLine
  
  Declare NewLine()
  Declare Defaults()
  
EndDeclareModule

Module DrawLine
  
  Global Accept.i = #True
  
  Global strStartX.i, strStartY.i, strEndX.i, strEndY.i, spnThickness.i, btnDone.i
  
  Global DrawAction.i = -1
  
  Global TestRound.i = #True
  
Procedure Process(x.i,y.i)
  
    AppMain::NewObject\Colour = Main::SelectedColour
  
    Select DrawAction
            
      Case 0
        ;No Action 
            
      Case 1
        
       If StartVectorDrawing(CanvasVectorOutput(AppMain::drgCanvas))
         ;Clearcanvas
         DrawVectorImage(ImageID(AppMain::DrawnImg), 255)
         AppMain::NewObject\X2 = X / 5
         AppMain::NewObject\Y2 = Y / 5
         Main::DrawLine(AppMain::NewObject)
         StopVectorDrawing()   
       EndIf  
            
    EndSelect

  EndProcedure
  
Procedure DrawLine()
  
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
                    
                    ;First Mouse Click Set Start Point
                    AppMain::NewObject\X1 = X/5
                    AppMain::NewObject\Y1 = Y/5
                    SetGadgetText(Main::#strX1,Str(AppMain::NewObject\X1))      
                    SetGadgetText(Main::#strY1,Str(AppMain::NewObject\Y1))                   
                    Drawaction = Drawaction + 1
              
                  Case 1
                    
                    ;Second Click Set End Point
                    AppMain::NewObject\X2 = X/5
                    AppMain::NewObject\Y2 = Y/5
                    Drawaction = Drawaction + 1
                    Appmain::Drawmode = "Idle"                    
                    Main::SaveElement("Line")
                    Done = #True 
                    
                EndSelect
                
              Case #PB_EventType_MouseMove
   
                          ;AppMain::CanvasToolTip(AppMain::drgCanvas,#PB_EventType_MouseMove)
                
                ;Only on significant move
                If (x <> OldX) Or (y <> OldY) 
                  
                  OldX = x
                  OldY = y
                  
                  Select Drawaction
                      
                    Case 0
                      
                      ;Show Start Point Dynamic
                      SetGadgetText(Main::#strX1,Str(X/5))      
                      SetGadgetText(Main::#strY1,Str(Y/5))  
                      
                    Case 1 
                      
                      Process(x,y) 
                      SetGadgetText(Main::#strX2,Str(X/5))      
                      SetGadgetText(Main::#strY2,Str(Y/5))  

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

Procedure Defaults()
  
  ;Set Line Defaults
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
  AppMain::NewObject\Pathtype = "Line"  
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

Procedure NewLine()

  GrabDrawnImage()
  Drawaction = 0
  DrawLine()
  AppMain::Drawmode = "Idle"

EndProcedure

EndModule

; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 106
; FirstLine = 101
; Folding = f-
; EnableXP
; EnableUnicode