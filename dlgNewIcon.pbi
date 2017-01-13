;{ ==Code Header Comment==============================
;        Name/title: dlgNewShape.pbi
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
;       Description: Module to handle adding new icon (shape) tyo database
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

EnableExplicit

DeclareModule NewIcon
  
  Global OkPressed.i = #False
  
  Global Group_ID.i, Icon_ID.i,Name.s
  
  Declare Open()
  
EndDeclareModule

Module NewIcon
  
  Global dlgNewShape.i, strName.i, cmbGroup.i, btnOk.i, btnCancel.i
  
  Procedure LoadGroupscmb()
   
   ;Clear Combo
   ClearGadgetItems(cmbGroup)
   
   ;Add Groups
   If DatabaseQuery(AppMain::ShapesDB, "SELECT * FROM Groups ORDER BY Name ASC;")
     While NextDatabaseRow(AppMain::ShapesDB)
       AddGadgetItem(cmbGroup, -1, GetDatabaseString(AppMain::ShapesDB, 1))
     Wend
     FinishDatabaseQuery(AppMain::ShapesDB)
   EndIf

EndProcedure  

  Procedure GetGroupID()
  
    Group.s = GetGadgetText(cmbGroup)
    
    If group.s = ""
      
      ;No Group Selected
      Group_ID = -1
 
    Else
    
      If DatabaseQuery(AppMain::ShapesDB, "SELECT * FROM Groups WHERE Name = '" + Group.s + "';")
      
        If FirstDatabaseRow(AppMain::ShapesDB) > 0
          Group_ID = GetDatabaseLong(AppMain::ShapesDB, 0)
        Else
          ;No Group Selected
          Group_ID = -1
        EndIf
      
        FinishDatabaseQuery(AppMain::ShapesDB)
      
      EndIf 
    EndIf
    
  EndProcedure
  
  Procedure Open()
    
    Group_ID = -1
    dlgNewShape = OpenWindow(#PB_Any, x, y, 190, 130, "Enter Icon Name", #PB_Window_TitleBar | #PB_Window_Tool | #PB_Window_WindowCentered| #PB_Window_NoGadgets)
    OldGadgetList = UseGadgetList(WindowID(dlgNewShape))  
    txtGroup = TextGadget(#PB_Any, 10, 10, 120, 20, "Select Group") 
    cmbGroup = ComboBoxGadget(#PB_Any, 10, 40, 130, 20)
    strName = StringGadget(#PB_Any, 10, 70, 170, 20, "")
    btnOk = ButtonGadget(#PB_Any, 10, 100, 60, 20, "Ok")
    btnCancel = ButtonGadget(#PB_Any, 120, 100, 60, 20, "Cancel")
    UseGadgetList(OldGadgetList)
    LoadGroupscmb()
    StickyWindow(dlgNewShape,#True)
    
    Repeat
  
      Event = WaitWindowEvent()
    
      If Event = #PB_Event_Gadget
        Select EventGadget()
            
          Case btnOk
            If Group_ID > -1
              Name = GetGadgetText(strName)
              OkPressed = #True
              CloseWindow(dlgNewShape)
              Break
            Else
              MessageRequester("New Icon","No Group Selected",#PB_MessageRequester_Ok )
            EndIf
            
          Case btnCancel
            OkPressed = #False
            CloseWindow(dlgNewShape)            
            Break
            
          Case cmbGroup
            GetGroupID()
            
            
        EndSelect
      EndIf
      
    ForEver
    
  EndProcedure
  
EndModule   
    
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 31
; FirstLine = 23
; Folding = H-
; EnableXP
; EnableUnicode