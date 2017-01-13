;{ ==Code Header Comment==============================
;        Name/title: dlgNewGroup.pbi
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
;       Description: Module to handle adding new icon group
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

DeclareModule NewGroup
  
  Global OkPressed.i = #False
  
  Global Name.s
  
  Declare Open()
  
EndDeclareModule

EnableExplicit

Module NewGroup
  
  Global dlgNewGroup.i, strName.i, btnOk.i, btnCancel.i
    
  Procedure Open()
    
    dlgNewGroup = OpenWindow(#PB_Any, x, y, 190, 70, "Enter Group Name", #PB_Window_TitleBar | #PB_Window_Tool | #PB_Window_WindowCentered| #PB_Window_NoGadgets)
    OldGadgetList = UseGadgetList(WindowID(dlgNewGroup))    
    strName = StringGadget(#PB_Any, 10, 10, 170, 20, "")
    btnOk = ButtonGadget(#PB_Any, 10, 40, 60, 20, "Ok")
    btnCancel = ButtonGadget(#PB_Any, 120, 40, 60, 20, "Cancel")
    UseGadgetList(OldGadgetList)  
    StickyWindow(dlgNewGroup,#True)
    
    Repeat
  
      Event = WaitWindowEvent()
    
      If Event = #PB_Event_Gadget
        Select EventGadget()
            
          Case btnOk
            Name = GetGadgetText(strName)
            OkPressed = #True
            CloseWindow(dlgNewGroup)
            Break
            
          Case btnCancel
            OkPressed = #False
            CloseWindow(dlgNewGroup)            
            Break
            
        EndSelect
      EndIf
      
    ForEver
    
  EndProcedure
  
EndModule   
    
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 34
; FirstLine = 17
; Folding = 4
; EnableXP
; EnableUnicode