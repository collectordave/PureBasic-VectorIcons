;{ ==Code Header Comment==============================
;        Name/title: dlgLoadIcon.pbi
;   Executable name: Part of Icondesigner.exe
;           Version: 1.0.0
;            Author: Collectordave
;     Collaborators: 
;    Translation by: 
;       Create date: 16\11\2016
; Previous releases: 
; This Release Date: 
;  Operating system: Windows  [X]GUI
;  Compiler version: PureBasic 5.5(x64)
;         Copyright: (C)2016
;           License: 
;         Libraries: 
;     English Forum: 
;  Tested platforms: Windows 7.0
;       Description: Module to Select which Icon to load
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

EnableExplicit

DeclareModule LoadIcon
  
  Global OkPressed.i
  Global SelectedIconID.i
  Declare.i Open() 
  
EndDeclareModule

Module LoadIcon

  Global dlgLoadIcon

  Global txtSelectGroup, cmbGroup, txtSelectIcon, cmbShape, btnOk, btnCancel,Group_ID.i
  
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
    
  Procedure LoadIconscmb(Group.s)
    
    If DatabaseQuery(AppMain::ShapesDB, "SELECT * FROM Groups WHERE Name = '" + Group.s + "';")
      
      FirstDatabaseRow(AppMain::ShapesDB)
      Group_ID = GetDatabaseLong(AppMain::ShapesDB, 0)
      FinishDatabaseQuery(AppMain::ShapesDB)
      
      ;Get the icons defined in this group
      If DatabaseQuery(AppMain::ShapesDB, "SELECT * FROM Icons WHERE Group_ID = " + Str(Group_ID) + " ORDER BY Title ASC;")
        ClearGadgetItems(cmbShape)  

        While NextDatabaseRow(AppMain::ShapesDB)
          AddGadgetItem(cmbShape, -1, GetDatabaseString(AppMain::ShapesDB, 1))
        Wend
        FinishDatabaseQuery(AppMain::ShapesDB)
      EndIf
     
    EndIf
     
  EndProcedure

  Procedure.i GetIconID()
  
    Define ShapeID.i = -1
  
    If GetGadgetText(cmbShape) > ""
      If DatabaseQuery(AppMain::ShapesDB, "SELECT * FROM Icons WHERE Title = '" + GetGadgetText(cmbShape) + "' AND Group_ID = " + Str(Group_ID) + ";") 
        FirstDatabaseRow(AppMain::ShapesDB)
        ShapeID = GetDatabaseLong(AppMain::ShapesDB, DatabaseColumnIndex(AppMain::ShapesDB, "Shape_ID"))
      EndIf
    EndIf    
  
    ProcedureReturn ShapeID

  EndProcedure

  Procedure.i Open()

    dlgLoadIcon = OpenWindow(#PB_Any, 0, 0, 270, 110, "Load Icon", #PB_Window_WindowCentered)

    txtSelectGroup = TextGadget(#PB_Any, 10, 10, 90, 20, "Select Group", #PB_Text_Right)
    cmbGroup = ComboBoxGadget(#PB_Any, 110, 10, 150, 20)
    txtSelectIcon = TextGadget(#PB_Any, 10, 40, 90, 20, "Select Icon", #PB_Text_Right)
    cmbShape = ComboBoxGadget(#PB_Any, 110, 40, 150, 20)
    DisableGadget(cmbShape, 1)
    btnOk = ButtonGadget(#PB_Any, 110, 70, 50, 30, "Ok")
    DisableGadget(btnOk, #True)
    btnCancel = ButtonGadget(#PB_Any, 210, 70, 50, 30, "Cancel")
    StickyWindow(dlgLoadIcon,#True)
  
    LoadGroupscmb()
  
    Repeat
     
      Event = WaitWindowEvent()
    
      Select Event
       
      Case #PB_Event_Gadget
      
        Select EventGadget()
          
          Case cmbGroup
          
            Group.s = GetGadgetText(cmbGroup)
    
            If GetGadgetText(cmbGroup) = ""
              ;No Group Selected Disable Icon Selection and Ok Button
              DisableGadget(cmbShape, #True)   
              DisableGadget(btnOk, #True)             
            Else
              LoadIconscmb(GetGadgetText(cmbGroup))
              DisableGadget(cmbShape, #False)
            EndIf
          
          Case cmbShape
          
            If GetGadgetText(cmbShape) = ""
              ;No Group Selected Disable Icon Selection and Ok Button
              DisableGadget(cmbShape, 1)   
              DisableGadget(btnOk, 1)              
            Else
              ;Get ShapeID
              DisableGadget(btnOk, 0)
            EndIf
          
          Case btnOk
            
            OkPressed = #True
            Main::CurrentIcon = GetGadgetText(cmbShape)
            SelectedIconID = GetIconID()
            CloseWindow(dlgLoadIcon)        
            Break
            
          Case btnCancel
            
            Main::CurrentIcon = ""
            CloseWindow(dlgLoadIcon)
            Break
            
        EndSelect ;EventGadget()
      
      EndSelect ;Event
  
    ForEver

  EndProcedure

EndModule
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 23
; Folding = A+
; EnableXP