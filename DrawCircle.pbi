;{ ==Code Header Comment==============================
;        Name/title: DrawCircle.pbi
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
;       Description: Module to handle drawing of circles on main form canvas
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

EnableExplicit

DeclareModule DrawCircle

  Declare NewCircle()
  Declare Defaults()
  
EndDeclareModule

Module DrawCircle

  Global strStartX.i, strStartY.i, strRadius.i, optFill.i, optOutLine.i, btnDone.i

  Global spnThickness
    
  Global Thickness.i
    
  Global DrawAction.i = -1    
  
  Procedure Process(x.i,y.i)
    
    AppMain::NewObject\Colour = Main::SelectedColour
    
    Select DrawAction
            
      Case 0
        ;No Action 
            
      Case 1
        
  
        If StartVectorDrawing(CanvasVectorOutput(AppMain::drgCanvas))
          ;Clearcanvas
          DrawVectorImage(ImageID(AppMain::DrawnImg), 255)
          Main::DrawCircle(AppMain::NewObject)
          Main::FinishPath(AppMain::NewObject)
          StopVectorDrawing()   
       EndIf  
            
    EndSelect
    
  EndProcedure
  
  Procedure DrawCircle()
    
    Done = #False

    Repeat
  
      Event = WaitWindowEvent()
      Used = #False
      
      Select Event
        Case #PB_Event_Gadget
          Select EventGadget()
              
            Case AppMain::drgCanvas
              Used = #True
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
 
                    ;Second Click Set End Point
                    Drawaction = Drawaction + 1
                    Appmain::Drawmode = "Idle"                    
                    Main::SaveElement("Circle")
                    Done = #True 
                    
                EndSelect
              
                Case #PB_EventType_MouseMove
              
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
                      AppMain::NewObject\RadiusX = (Sqr(Pow(((AppMain::NewObject\X1 * 5) - X ),2) + Pow(((AppMain::NewObject\Y1 * 5) - Y),2)))/5
                      SetGadgetText(Main::#strRadiusX,Str(AppMain::NewObject\RadiusX))                    
                      Process(x,y) 
  

                  EndSelect ;Drawaction
                  
                EndIf
              
              EndSelect ;EventType()   
              
          EndSelect ;EventGadget()
      
      EndSelect ;Event
        
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
  
  Procedure NewCircle()

  ;Start the drawing operation
  ;Get the image drawn so far
  GrabDrawnImage() 
  Drawaction = 0
  DrawCircle()
  AppMain::Drawmode = "Idle"

  EndProcedure
    
Procedure Defaults()
  
  ;Set Circle Defaults
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
  AppMain::NewObject\Pathtype = "Circle"  
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
; CursorPosition = 24
; FirstLine = 1
; Folding = f0
; EnableXP
; EnableUnicode