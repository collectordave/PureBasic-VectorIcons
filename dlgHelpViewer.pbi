DeclareModule HelpViewer
  
  Global Active.i = #False
  
  Declare.i Open(Topic.s)
  Declare EventHandler(Event.i)
  
EndDeclareModule

Module HelpViewer
  
  Global wndHelp.i, WebBrowser.i
  
  Procedure.i Open(Topic.s)
    
    Active = #True
    
    wndHelp = OpenWindow(#PB_Any, 0, 0, 1000, 600, "Help Viewer",#PB_Window_MinimizeGadget)
    WebBrowser =  WebGadget(#PB_Any, 5, 5, 990, 590,GetCurrentDirectory() + "Help\index.html") 
    
    ProcedureReturn wndHelp
    
  EndProcedure
  
  Procedure EventHandler(Event)
    
    If Event = #PB_Event_CloseWindow 
      Active = #False
      CloseWindow(wndHelp)
    EndIf
    
  EndProcedure
  
EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 12
; Folding = -
; EnableXP
; EnableUnicode