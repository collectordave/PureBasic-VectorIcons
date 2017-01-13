;{ ==Code Header Comment==============================
;        Name/title: dlgIconViewer.pbi
;   Executable name: Part of Icondesigner.exe
;           Version: 1.0.0
;            Author: Collectordave
;     Collaborators: 
;    Translation by: 
;       Create date: 16\05\2016
; Previous releases: 
; This Release Date: 
;  Operating system: Windows  [X]GUI
;  Compiler version: PureBasic 5.5(x64)
;         Copyright: (C)2016
;           License: 
;         Libraries: 
;     English Forum: 
;      French Forum: 
;      German Forum: 
;  Tested platforms: Windows
;       Description: Module to display and save iconfiles
; ====================================================
;.......10........20........30........40........50........60........70........80
;}

EnableExplicit

DeclareModule IconView
  
  Declare.i Open() 
  Declare Show()
  Declare EventHandler(Event.i)
  
EndDeclareModule

Module IconView
  
  Global dlgIconViewer.i  
  Global btnHide.i,chk128, chk64, chk32, chk48, chk16,btnSave,Image128,Image64,Image48,Image32,Image16
  
  Procedure.i Open()
  
    dlgIconViewer = OpenWindow(#PB_Any, 0, 0, 440, 240, "Icon Viewer\Saver", #PB_Window_SystemMenu)
    Container_0 = ContainerGadget(#PB_Any, 0, 40, 440, 150)
      SetGadgetColor(Container_0, #PB_Gadget_BackColor,RGB(255,255,255)) 
      Image128 = ImageGadget(#PB_Any, 10, 10, 128, 128, 0)
      Image64 = ImageGadget(#PB_Any, 150, 10, 64, 64, 0)  
      Image48 = ImageGadget(#PB_Any, 225, 10, 48, 48, 0)  
      Image32 = ImageGadget(#PB_Any, 285, 10, 32, 32, 0)  
      Image16 = ImageGadget(#PB_Any, 325, 10, 16, 16, 0)  
    CloseGadgetList()
    chk128 = CheckBoxGadget(#PB_Any, 10, 10, 50, 20, "128")
    chk64 = CheckBoxGadget(#PB_Any, 150, 10, 50, 20, "64")
    chk48 = CheckBoxGadget(#PB_Any, 225, 10, 40, 20, "48")
    chk32 = CheckBoxGadget(#PB_Any, 285, 10, 40, 20, "32")
    chk16 = CheckBoxGadget(#PB_Any, 325, 10, 40, 20, "16")
    btnSave = ButtonGadget(#PB_Any, 240, 200, 90, 25, "Save") 
    btnHide = ButtonGadget(#PB_Any, 340, 200, 90, 25, "Hide")  
  
    ProcedureReturn dlgIconViewer

  EndProcedure

  Procedure CheckCreateFolder(Directory.s)

    BackSlashs = CountString(Directory.s, "\")
 
    Path$ = ""
    For i = 1 To BackSlashs + 1
      Temp$ = StringField(Directory.s, i, "\")
    
      If StringField(Directory.s, i+1, "\") > ""
        Path$ + Temp$ + "\"
      Else
        path$ + temp$
      EndIf
      CreateDirectory(Path$)
    Next i
  
  EndProcedure

  Procedure Show()

    Define NewImage.i
  
    NewImage = CopyImage(AppMain::IconImg, #PB_Any)
    NewImage = ResizeImage(NewImage,128,128)
    SetGadgetState(Image128,NewImage)
  
    NewImage = CopyImage(AppMain::IconImg, #PB_Any)
    NewImage = ResizeImage(NewImage,64,64)
    SetGadgetState(Image64,NewImage)
  
    NewImage = CopyImage(AppMain::IconImg, #PB_Any)
    NewImage = ResizeImage(NewImage,48,48)
    SetGadgetState(Image48,NewImage)
  
    NewImage = CopyImage(AppMain::IconImg, #PB_Any)
    NewImage = ResizeImage(NewImage,32,32)
    SetGadgetState(Image32,NewImage)
   
    NewImage = CopyImage(AppMain::IconImg, #PB_Any)
    NewImage = ResizeImage(NewImage,16,16)
    SetGadgetState(Image16,NewImage)
  
    If IsImage(NewImage)
      FreeImage(NewImage) 
    EndIf
  
  EndProcedure
  
  Procedure SaveIconImages()
    
    Define NewImage.i
    Define Folder.s,ImageFileName.s    
          
    If GetGadgetState(chk128) = #True
      Folder = GetCurrentDirectory() + "Images\128 X 128\"
      CheckCreateFolder(Folder)
      NewImage = CopyImage(AppMain::IconImg, #PB_Any)
      ResizeImage(NewImage,128,128,#PB_Image_Raw)
      ImageFileName = AppMain::CheckMultiFilename(Folder + Main::CurrentIcon + ".png")     
      SaveImage(NewImage, ImageFileName,#PB_ImagePlugin_PNG,#PB_Ignore,32)
      NewImage = CopyImage(AppMain::IconGreyImg, #PB_Any)    
      ResizeImage(NewImage,128,128,#PB_Image_Raw)
      ImageFileName = AppMain::CheckMultiFilename(Folder + Main::CurrentIcon + " - Disabled.png")      
      SaveImage(NewImage, ImageFileName,#PB_ImagePlugin_PNG,#PB_Ignore,32)      
      
    EndIf
  
    If GetGadgetState(chk64) = #True         
      Folder = GetCurrentDirectory() + "Images\64 X 64\"
      CheckCreateFolder(Folder)           
      NewImage = CopyImage(AppMain::IconImg, #PB_Any)
      ResizeImage(NewImage,64,64,#PB_Image_Raw)
      ImageFileName = AppMain::CheckMultiFilename(Folder + Main::CurrentIcon + ".png")
      SaveImage(NewImage, ImageFileName,#PB_ImagePlugin_PNG,#PB_Ignore,32)  
      NewImage = CopyImage(AppMain::IconGreyImg, #PB_Any)    
      ResizeImage(NewImage,64,64,#PB_Image_Raw)
      ImageFileName = AppMain::CheckMultiFilename(Folder + Main::CurrentIcon + " - Disabled.png")      
      SaveImage(NewImage,ImageFileName,#PB_ImagePlugin_PNG,#PB_Ignore,32)     
    EndIf
    
    If GetGadgetState(chk48) = #True 
      Folder = GetCurrentDirectory() + "Images\48 X 48\"
      CheckCreateFolder(Folder)             
      NewImage = CopyImage(AppMain::IconImg, #PB_Any)
      ResizeImage(NewImage,48,48,#PB_Image_Raw)
      ImageFileName = AppMain::CheckMultiFilename(Folder + Main::CurrentIcon + ".png")     
      SaveImage(NewImage, ImageFileName,#PB_ImagePlugin_PNG,#PB_Ignore,32) 
      NewImage = CopyImage(AppMain::IconGreyImg, #PB_Any)    
      ResizeImage(NewImage,48,48,#PB_Image_Raw)
      ImageFileName = AppMain::CheckMultiFilename(Folder + Main::CurrentIcon + " - Disabled.png")     
      SaveImage(NewImage, ImageFileName,#PB_ImagePlugin_PNG,#PB_Ignore,32)     
    EndIf
    
    If GetGadgetState(chk32) = #True
      Folder = GetCurrentDirectory() + "Images\32 X 32\"
      CheckCreateFolder(Folder)            
      NewImage = CopyImage(AppMain::IconImg, #PB_Any)
      ResizeImage(NewImage,32,32,#PB_Image_Raw)
      ImageFileName = AppMain::CheckMultiFilename(Folder + Main::CurrentIcon + ".png")      
      SaveImage(NewImage, ImageFileName,#PB_ImagePlugin_PNG,#PB_Ignore,32) 
      NewImage = CopyImage(AppMain::IconGreyImg, #PB_Any)    
      ResizeImage(NewImage,32,32,#PB_Image_Raw)
      ImageFileName = AppMain::CheckMultiFilename(Folder + Main::CurrentIcon + " - Disabled.png")      
      SaveImage(NewImage, ImageFileName,#PB_ImagePlugin_PNG,#PB_Ignore,32)     
    EndIf
    
    If GetGadgetState(chk16) = #True
      Folder = GetCurrentDirectory() + "Images\16 X 16\"
      CheckCreateFolder(Folder)           
      NewImage = CopyImage(AppMain::IconImg, #PB_Any)
      ResizeImage(NewImage,16,16,#PB_Image_Raw)
      ImageFileName = AppMain::CheckMultiFilename(Folder + Main::CurrentIcon + ".png")      
      SaveImage(NewImage, ImageFileName,#PB_ImagePlugin_PNG,#PB_Ignore,32)
      NewImage = CopyImage(AppMain::IconGreyImg, #PB_Any)    
      ResizeImage(NewImage,16,16,#PB_Image_Raw)
      ImageFileName = AppMain::CheckMultiFilename(Folder + Main::CurrentIcon + " - Disabled.png")      
      SaveImage(NewImage, ImageFileName,#PB_ImagePlugin_PNG,#PB_Ignore,32)       
    EndIf
          
  EndProcedure

  Procedure EventHandler(Event)
  
    Select Event
       
      Case #PB_Event_Gadget
      
        Select EventGadget()
          
          Case btnSave
            SaveIconImages()
          
          Case btnHide
            CloseWindow(dlgIconViewer)
          
        EndSelect ;EventGadget()
      
      Case #PB_Event_CloseWindow
        CloseWindow(dlgIconViewer)
      
    EndSelect ;Event
        
  EndProcedure

EndModule        
; IDE Options = PureBasic 5.50 (Windows - x64)
; CursorPosition = 174
; FirstLine = 46
; Folding = H-
; EnableXP
; EnableUnicode