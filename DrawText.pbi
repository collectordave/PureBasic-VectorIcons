;{ ==Code Header Comment==============================
;        Name/title: DrawText.pbi
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
;       Description: Module to handle drawing of text on main form canvas
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

DeclareModule DrawText
  
  Declare NewText()
  Declare Defaults()
  
EndDeclareModule

Module DrawText
  
  Global VFont.i
  
  Global DrawAction.i = -1
    
  Procedure GrabDrawnImage()
    ;{ ==Procedure Header Comment=========================
    ;        Name/title: GrabDrawnImage()
    ;       Description: Procedure to grab the existing canvas image
    ; ====================================================
    ;}   
    AppMain::DrawnImg = CreateImage(#PB_Any, 640,640, 32)
    If StartDrawing(ImageOutput(AppMain::DrawnImg))
      DrawImage(GetGadgetAttribute(AppMain::drgCanvas, #PB_Canvas_Image), 0, 0)
      StopDrawing()
    EndIf

  EndProcedure   
      
  Procedure Process(x.i,y.i)
    ;{ ==Procedure Header Comment=========================
    ;        Name/title: Process(x.i,y.i)
    ;       Description: Procedure to draw selected text on the canvas
    ; ====================================================
    ;}   
    If StartVectorDrawing(CanvasVectorOutput(AppMain::drgCanvas))
      
    Define TempFont.i = LoadFont(#PB_Any, AppMain::NewObject\Font, 8)
    VectorFont(FontID(TempFont), AppMain::NewObject\Width * 5)
    Define TempWidth.i = (VectorTextWidth(Appmain::NewObject\Text,#PB_VectorText_Visible) /2) + 10
    Define tempHeight.i = (VectorTextHeight(Appmain::NewObject\Text,#PB_VectorText_Visible) /2) + 10    
    FreeFont(TempFont)
    Define TempX.i,TempY.i
    
      ;Clearcanvas
      DrawVectorImage(ImageID(AppMain::DrawnImg), 255)
      
      Select DrawAction
        
        Case 0  ;Set Position
          
          Main::DrawMytext(AppMain::NewObject)
            
        Case 1 ;Rotation
          
          VectorSourceColor(RGBA($00,$FF,$00,$FF))
          AddPathCircle((AppMain::NewObject\X1 * 5),AppMain::NewObject\Y1 * 5, TempWidth , 0,360)     
          
          StrokePath(1)   
            
          ;Show Chose angle line           
          VectorSourceColor(RGBA($FF,$00,$00,$FF))
          MovePathCursor((AppMain::NewObject\X1 * 5),AppMain::NewObject\Y1 * 5)
          AddPathLine(x,y)
          DashPath(1, 5)
          
          TempX = (AppMain::NewObject\X1 * 5)
          TempY = (AppMain::NewObject\Y1 * 5)
          If x => TempX And Y => TempY
            If X - TempX = 0
              Angle1 = 90
            Else
              Angle1 = Degree(ATan((Y - TempY)/(X - TempX)))
            EndIf
          ElseIf  x =< TempX And Y => TempY
            If Y-TempY = 0
              Angle1 = 180
            Else
              Angle1 = 90 + Degree(ATan((TempX - X)/(Y - TempY)))
            EndIf
          ElseIf  x =< TempX And Y =< TempY
            If X - TempX = 0
              Angle1 = 270
            Else
              Angle1 = 180 + Degree(ATan((Y - TempY)/(X - TempX)))
            EndIf
          ElseIf  x => TempX And Y =< TempY
            Angle1 = 270 + Degree(ATan((X - TempX)/(TempY - Y)))
          EndIf
          AppMain::NewObject\Rotation = Angle1
          ;Reset Vector colour
          VectorSourceColor(AppMain::NewObject\Colour)         
          Main::DrawMytext(AppMain::NewObject) 
          
        Case 2 ;Rotation
          Main::DrawMytext(AppMain::NewObject) 
          
      EndSelect
      
      StopVectorDrawing()
       
    EndIf
    
  EndProcedure
  
  Procedure AddText()
    
    Static OldX.i,OldY.i
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
                    
                  Case 0  ;Set Position
                    
                    AppMain::NewObject\X1 = X/5
                    AppMain::NewObject\Y1 = Y/5
                    SetGadgetText(Main::#strX1,Str(AppMain::NewObject\X1))      
                    SetGadgetText(Main::#strY1,Str(AppMain::NewObject\Y1))                   
                    Drawaction = Drawaction + 1  
                    
                  Case 1 ;Rotation
                    
 
                    Drawaction = Drawaction + 1 
                    Process(x,y) 
                    SetGadgetText(Main::#strRotation,Str(AppMain::NewObject\Rotation))         
                    Appmain::Drawmode = "Idle"                    
                    Main::SaveElement("Text")
                    Done = #True                    
                    
                EndSelect
                
                Case #PB_EventType_MouseMove
                  
                  ;Only on significant move
                  If (x <> OldX) Or (y <> OldY) 
                    OldX = x
                    OldY = y
                    
                    Select Drawaction
                      
                    Case 0
                      
                      AppMain::NewObject\X1 = X/5
                      AppMain::NewObject\Y1 = Y/5              
                      SetGadgetText(Main::#strX1,Str(X/5))      
                      SetGadgetText(Main::#strY1,Str(Y/5))  
                      Process(X,Y)
                      
                    Case 1
                      
                      SetGadgetText(Main::#strRotation,Str(AppMain::NewObject\Rotation))                        
                      Process(X,Y)         
                   
                 EndSelect  ;Drawaction
                 
               EndIf
                  
              EndSelect ;EventType()   
              
          EndSelect ;EventGadget()
      
      EndSelect ;Event
        
    Until Done = #True

  EndProcedure
 
  Procedure NewText()
    
    
  AppMain::NewObject\Text = GetGadgetText(Main::#strText)  
  AppMain::NewObject\Width = GetGadgetState(Main::#spnSize)     
  ;Start the drawing operation
  ;Get the image drawn so far
  GrabDrawnImage() 
  Drawaction = 0
  AddText()

  AppMain::Drawmode = "Idle"
 
  EndProcedure

Procedure Defaults()
  
  ;Set Text Defaults
  AppMain::NewObject\Angle1 = 0
  AppMain::NewObject\Angle2 = 0  
  AppMain::NewObject\Closed = #False 
  AppMain::NewObject\Colour = RGBA(0,0,0,255)  
  AppMain::NewObject\Dash = #False
  AppMain::NewObject\DashFactor = 1.1 
  AppMain::NewObject\Dot = #False
  AppMain::NewObject\DotFactor = 1.1  
  AppMain::NewObject\Filled = #False
  AppMain::NewObject\Font = "Arial"
  AppMain::NewObject\LeftRight = #False
  AppMain::NewObject\Pathtype = "Text"  
  AppMain::NewObject\Points = 0
  AppMain::NewObject\RadiusX = 0
  AppMain::NewObject\RadiusY = 0
  AppMain::NewObject\Rotation = 0
  AppMain::NewObject\Rounded = #False  
  AppMain::NewObject\Stroke = #True  
  AppMain::NewObject\Text = "AB"
  AppMain::NewObject\Trans = 255
  AppMain::NewObject\Width = 15
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
; CursorPosition = 176
; FirstLine = 152
; Folding = 4-
; EnableXP
; EnableUnicode