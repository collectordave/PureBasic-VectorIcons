;{ ==Code Header Comment==============================
;        Name/title: dlgChooseElement.pbi
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
;       Description: Module to alloow a choice of path element
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

EnableExplicit
DeclareModule ChooseElement
  
  Global Type.s
  Global Radius.i, EndPath.i
  Declare.i Open() 
  
EndDeclareModule

Module ChooseElement

  Global dlgChooseElement.i
  Global btnOk, btnEnd, optLine, optArc, spnRadius

Procedure.i Open()

  dlgChooseElement = OpenWindow(#PB_Any, x, y, 110, 110, "Select Element", #PB_Window_TitleBar | #PB_Window_Tool | #PB_Window_WindowCentered)
  btnOk = ButtonGadget(#PB_Any, 10, 80, 40, 20, "Ok")
  btnEnd = ButtonGadget(#PB_Any, 60, 80, 40, 20, "End") 
  optLine = OptionGadget(#PB_Any, 10, 10, 50, 20, "Line")
  SetGadgetState(optLine, 1)
  optArc = OptionGadget(#PB_Any, 60, 10, 60, 20, "Arc")
  spnRadius = SpinGadget(#PB_Any, 60, 55, 45, 20, 1, 100, #PB_Spin_ReadOnly | #PB_Spin_Numeric)
  SetGadgetState(spnRadius,10)
  SetGadgetText(spnRadius,"10")
  DisableGadget(spnRadius, 1)
  Text_0 = TextGadget(#PB_Any, 60, 35, 50, 20, "Radius")
  StickyWindow(dlgChooseElement,#True)
  EndPath = #False
  
  Repeat
  
    Event = WaitWindowEvent()
    Select Event
      
      Case #PB_Event_Gadget
        Select EventGadget()
          Case  optArc
            If GetGadgetState(optArc)
            DisableGadget(spnRadius, 0)
          Else
             DisableGadget(spnRadius, 1) 
           EndIf 
          Case  optline
            If GetGadgetState(optline)
            DisableGadget(spnRadius, 1)
          Else
             DisableGadget(spnRadius, 0) 
           EndIf 
         Case btnOk
           
           If GetGadgetState(optLine)
             ChooseElement::Type = "L"
           Else
             ChooseElement::Type = "A"
             ChooseElement::Radius = GetGadgetState(spnRadius)
           EndIf
           
           CloseWindow(dlgChooseElement)
           Break
           
         Case btnEnd
           
           EndPath = #True          
           CloseWindow(dlgChooseElement)
           Break
           
       EndSelect
      
    EndSelect ;Event
  
  ForEver

EndProcedure

EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 44
; FirstLine = 37
; Folding = -
; EnableXP