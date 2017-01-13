;{ ==Code Header Comment==============================
;        Name/title: DrawArc.pbi
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
;       Description: Module to handle drawing of arcs on main form canvas
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

DeclareModule DrawArc
  
 Declare NewArc()
 Declare Defaults()
  
EndDeclareModule

Module DrawArc

  Global Window_0

  Global spnSize, btnColour
    
  Global Thickness.i, Transparency.i
  
  Global DrawAction.i = -1    
 
  Procedure Process(x.i,y.i)

    Static CentreX.i,CentreY.i,Radius.i,Angle1.i,Angle2.i 
    
    AppMain::NewObject\Colour = Main::SelectedColour   
    
    If StartVectorDrawing(CanvasVectorOutput(AppMain::drgCanvas))

      ;Clearcanvas to the drawn image
      DrawVectorImage(ImageID(AppMain::DrawnImg), 255)

      Select DrawAction
        Case 0
            
          CentreX = X
          CentreY = Y 
            
        Case 1 ;Intersect Point Chosen so chose radius and centre point
          
          AppMain::NewObject\RadiusX = (Sqr(Pow((CentreX-X),2) + Pow((CentreY-Y),2)))/5
          VectorSourceColor(RGBA($FF,$00,$00,$FF))
          AddPathCircle(X,Y, AppMain::NewObject\RadiusX * 5 , 0,360)
          DashPath(1, 5)        

        Case 2 ;Start Point And radius now get start Angle
     
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
          AppMain::NewObject\Angle1 = Angle1
            
        Case 3 ;Get End Angle
            
          VectorSourceColor(RGBA($00,$FF,$00,$FF))
          AddPathCircle(AppMain::NewObject\X1 * 5,AppMain::NewObject\Y1 * 5, AppMain::NewObject\RadiusX * 5, 0,360)     
          StrokePath(1) 
            
          ;Show Chose angle line           
          VectorSourceColor(RGBA($FF,$00,$00,$FF))
          MovePathCursor(AppMain::NewObject\X1 * 5,AppMain::NewObject\Y1 * 5)
          AddPathLine(x,y)
          DashPath(1, 5)
            
          If x => AppMain::NewObject\X1 * 5 And Y => AppMain::NewObject\Y1 * 5
            If X - AppMain::NewObject\X1 * 5 = 0
              Angle2 = 90
            Else
              Angle2 = Degree(ATan((Y - AppMain::NewObject\Y1 * 5)/(X - AppMain::NewObject\X1 * 5)))
            EndIf
          ElseIf  x =< AppMain::NewObject\X1 * 5 And Y => AppMain::NewObject\Y1 * 5
            If Y-AppMain::NewObject\Y1 * 5 = 0
              Angle2 = 180
            Else
              Angle2 = 90 + Degree(ATan((AppMain::NewObject\X1 * 5 - X)/(Y - AppMain::NewObject\Y1 * 5)))
            EndIf
          ElseIf  x =< AppMain::NewObject\X1 * 5 And Y =< AppMain::NewObject\Y1 * 5
            If X - AppMain::NewObject\X1 * 5 = 0
              Angle2 = 270
            Else
              Angle2 = 180 + Degree(ATan((Y - AppMain::NewObject\Y1 * 5)/(X - AppMain::NewObject\X1 * 5)))
            EndIf
          ElseIf  x => AppMain::NewObject\X1 * 5 And Y =< AppMain::NewObject\Y1 * 5
            Angle2 = 270 + Degree(ATan((X - AppMain::NewObject\X1 * 5)/(AppMain::NewObject\Y1 * 5 - Y)))
          EndIf
          AppMain::NewObject\Angle2 = Angle2
          Main::DrawArc(AppMain::NewObject)
            
        Case 4 ;Clean Up

          DrawVectorImage(ImageID(AppMain::DrawnImg), 255)
          Main::DrawArc(AppMain::NewObject)        
      
      EndSelect 
  
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
 
  Procedure DrawArc()
 
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
                      
                    Case 0  ;Start Point

                      Process(x,y)
                      
                    Case 1 ;Radius
                      
                      AppMain::NewObject\X1 = X/5
                      AppMain::NewObject\Y1 = Y/5
                      SetGadgetText(Main::#strX1,Str(AppMain::NewObject\X1))      
                      SetGadgetText(Main::#strY1,Str(AppMain::NewObject\Y1))                        
                      Process(x,y)
                      
                    Case 2
                      
                      Process(x,y)
                   
                    Case 3
                      
                      Drawaction = Drawaction + 1
                      Process(x,y)
                      Appmain::Drawmode = "Idle"                    
                      Main::SaveElement("Arc")
                      Done = #True
                      
                  EndSelect
                  
                  Drawaction = Drawaction + 1
                  
                Case #PB_EventType_MouseMove
              
                  Select Drawaction
                    Case 0
                      SetGadgetText(Main::#strX1,Str(X/5))      
                      SetGadgetText(Main::#strY1,Str(Y/5))  
                    Case 1 
                      SetGadgetText(Main::#strRadiusX,Str(AppMain::NewObject\RadiusX))      
                      Process(x,y)  
                    Case 2
                      SetGadgetText(Main::#spnAngle1,Str(AppMain::NewObject\Angle1))   
                      Process(x,y)                     
                    Case 3
                      SetGadgetText(Main::#spnAngle2,Str(AppMain::NewObject\Angle2))   
                      Process(x,y) 
                    Case 4
                      Process(x,y)
                  EndSelect  
              
              EndSelect ;EventType()   
              
          EndSelect
      
      EndSelect
        
    Until Done = #True 

  EndProcedure
 
  Procedure NewArc()

    GrabDrawnImage() 
    Drawaction = 0
    DrawArc()
    AppMain::Drawmode = "Idle"
    
  EndProcedure
    
Procedure Defaults()
  
  ;Set Arc Defaults
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
  AppMain::NewObject\Pathtype = "Arc"  
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
; CursorPosition = 204
; FirstLine = 138
; Folding = u-
; EnableXP
; EnableUnicode