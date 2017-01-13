;{ ==Code Header Comment==============================
;        Name/title: DrawEllipse.pbi
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
;       Description: Module to handle drawing of ellipses on main form canvas
; ====================================================
;.......10........20........30........40........50........60........70........80
;}
DeclareModule DrawEllipse
  
  Declare NewEllipse()
  Declare Defaults()
  
EndDeclareModule

Module DrawEllipse

  Global strStartX.i, strStartY.i, strXRadius.i, strYRadius.i, spnAngle1.i, spnAngle2.i, btnDone.i

    
  Global Thickness.i, Filled.i
    
  Global DrawAction.i = -1    
    
  Procedure Process(x.i,y.i)
    
    Define TempVar.i

    AppMain::NewObject\Colour = Main::SelectedColour
    
    If StartVectorDrawing(CanvasVectorOutput(AppMain::drgCanvas))
    
      ;Clearcanvas
      DrawVectorImage(ImageID(AppMain::DrawnImg), 255)
    
      VectorSourceColor(AppMain::NewObject\Colour)
    
      Select DrawAction
            
        Case 0  ;Centre Point
            
          AppMain::NewObject\X1 = X/5
          AppMain::NewObject\Y1 = Y/5
            
        Case 1 ;Radii
           
          TempVar = AppMain::NewObject\X1 * 5
          If X < TempVar
            Swap X , TempVar
            AppMain::NewObject\RadiusX = (X - TempVar)/5
          Else
            AppMain::NewObject\RadiusX = (X - TempVar)/5          
          EndIf
          If AppMain::NewObject\RadiusX * 5 < 10
            AppMain::NewObject\RadiusX = 2
          EndIf
            
          TempVar = AppMain::NewObject\Y1 * 5
          If Y < TempVar
            Swap Y , TempVar
            AppMain::NewObject\RadiusY = (Y - TempVar)/5
          Else
            AppMain::NewObject\RadiusY = (Y - TempVar) /5        
          EndIf           
          If AppMain::NewObject\RadiusY * 5 < 10
            AppMain::NewObject\RadiusY = 2
          EndIf
          Main::DrawEllipse(AppMain::NewObject)
          SetGadgetText(Main::#strRadiusX,Str(AppMain::NewObject\RadiusX))            
          SetGadgetText(Main::#strRadiusY,Str(AppMain::NewObject\RadiusY)) 
          
        Case 2 ;Rotation
          
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
          Main::DrawEllipse(AppMain::NewObject)        
          
          Case 3 
            Main::DrawEllipse(AppMain::NewObject) 
            
      EndSelect ;DrawAction

      StopVectorDrawing()

    EndIf
    
  EndProcedure
  
  Procedure GrabDrawnImage()
       
    ;Create Drawn Image 
    AppMain::DrawnImg = CreateImage(#PB_Any, 640,640, 32)
    If StartDrawing(ImageOutput(AppMain::DrawnImg))
      DrawImage(GetGadgetAttribute(AppMain::drgCanvas, #PB_Canvas_Image), 0, 0)
      StopDrawing()
    EndIf

  EndProcedure
  
  Procedure DrawEllipse()
        
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
                    
                    Case 0  ;Set Centre Point
                    
                      AppMain::NewObject\X1 = X/5
                      AppMain::NewObject\Y1 = Y/5
                      SetGadgetText(Main::#strX1,Str(AppMain::NewObject\X1))      
                      SetGadgetText(Main::#strY1,Str(AppMain::NewObject\Y1))                   
                      Drawaction = Drawaction + 1 
                  
                      
                    Case 1 ;Set Radii
                      
                      SetGadgetText(Main::#strRadiusX,Str(AppMain::NewObject\RadiusX))            
                      SetGadgetText(Main::#strRadiusY,Str(AppMain::NewObject\RadiusY)) 
                      Drawaction = Drawaction + 1 
                      
                    Case 2 ;Rotation
                      
                      SetGadgetText(Main::#strRotation,Str(AppMain::NewObject\Rotation))   
                      Drawaction = Drawaction + 1 
                      Process(x,y) 
                      Appmain::Drawmode = "Idle"                    
                      Main::SaveElement("Ellipse")
                      Done = #True 
                      
                  EndSelect
              
                Case #PB_EventType_MouseMove
              
                  Select Drawaction
                      
                    Case 0
                      
                      SetGadgetText(Main::#strX1,Str(X/5))      
                      SetGadgetText(Main::#strY1,Str(Y/5)) 
                      
                    Case 1 
                      
                      SetGadgetText(Main::#strRadiusX,Str(AppMain::NewObject\RadiusX))            
                      SetGadgetText(Main::#strRadiusY,Str(AppMain::NewObject\RadiusY))                      
                      Process(x,y) 
                      
                    Case 2
                      
                      AppMain::NewObject\Rotation = Sqr(Pow((AppMain::NewObject\X1-X),2) + Pow((AppMain::NewObject\Y1-Y),2))           
                      Process(x,y) 
                      SetGadgetText(Main::#strRotation,Str(AppMain::NewObject\Rotation))                        
   
                  EndSelect
              
              EndSelect ;EventType()   
              
          EndSelect
      
      EndSelect
         
    Until Done = #True 
    
  EndProcedure
  
  Procedure NewEllipse()

  ;Start the drawing operation
  ;Get the image drawn so far
  GrabDrawnImage() 
  Drawaction = 0
  DrawEllipse()

  AppMain::Drawmode = "Idle"

  EndProcedure
     
Procedure Defaults()
  
  ;Set Ellipse Defaults
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
  AppMain::NewObject\Pathtype = "Ellipse"  
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
; CursorPosition = 84
; FirstLine = 107
; Folding = v-
; EnableXP
; EnableUnicode