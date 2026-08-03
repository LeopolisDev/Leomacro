;Made by darksen. 
;
;

#Requires AutoHotkey v2.0
#SingleInstance Force

SetWorkingDir(A_ScriptDir)
CoordMode("Mouse", "Client")
CoordMode("Pixel", "Client")

ListLines(False)
KeyHistory(0)
SetTitleMatchMode(1)

if (RegExMatch(A_ScriptDir, "i)\.(zip|rar)")) {
    MsgBox("You are attempting to run the script from a ZIP file.`n`nPlease Extract/Unzip the file first, then run the script in the extracted folder.","Running From ZIP", 0x10)
    ExitApp()
}

if WinExist("leomacro") {
    WinClose("leomacro")
}

if (A_PtrSize == 4) {
    MsgBox("You are running 32-bit AutoHotkey, the macro will not work properly, sadly.")
}

#Include "*i %A_ScriptDir%\lib\Gdip_All.ahk"
#Include "*i %A_ScriptDir%\lib\OCR.ahk"
#Include "*i %A_ScriptDir%\lib\Gdip_ImageSearch.ahk"
#Include "*i %A_ScriptDir%\lib\Roblox.ahk"
#Include "*i %A_ScriptDir%\lib\ImageSearch\ImageSearch.ahk"
#Include "*i %A_ScriptDir%\submacros\updater.ahk"

EnableHighDpiSupport()

ver := "1.3.1"

A_MaxHotkeysPerInterval := 9999

pToken := Gdip_Startup()
OnExit(CleanupGdip)
OnExit(HandleExit)

global AppDataOpt := A_AppData "\leomacro\Options"
global SettingsFile := AppDataOpt "\Settings.tds"
global RecordingsDir := A_AppData "\leomacro\Recordings"
global StateFile := A_AppData "\leomacro\state.ini"

global StratsDir := A_WorkingDir "\Resources\Strats"

global ShowIndicators := true

global WebhookQueue := []
global WebhookTimerActive := false
global WebhookInstantQueue := []
global WebhookInstantTimerActive := false
global WebhookEnabled := false

if !DirExist(AppDataOpt)
    DirCreate(AppDataOpt)
if !DirExist(RecordingsDir)
    DirCreate(RecordingsDir)

global VipLink := IniRead(SettingsFile, "Options", "VipLink", "") 
global UseVipServer := IniRead(SettingsFile, "Options", "UseVipServer", "0")
global AlwaysOnTop := IniRead(SettingsFile, "Options", "AlwaysOnTop", 0)
global WebhookLink := IniRead(SettingsFile, "Webhook", "Link", "")
global WebhookLink2 := IniRead(SettingsFile, "Webhook", "Link2", "")
global WebhookEnabled := IniRead(SettingsFile, "Webhook", "Enabled", "0")
global PotatoMode := IniRead(SettingsFile, "Options", "PotatoMode", 0)
global SendCurrenciesEnabled := IniRead(SettingsFile, "Webhook", "SendCurrencies", "1")
global WebhookDebugLogs := IniRead(SettingsFile, "Webhook", "WebhookDebugLogs", "1")
global WebhookScreenshots := IniRead(SettingsFile, "Webhook", "WebhookScreenshots", "1")
global WebhookTriumphScreenshots := IniRead(SettingsFile, "Webhook", "WebhookTriumphScreenshots", 1)
global WebhookSepatateTriumphScreenshots := IniRead(SettingsFile, "Webhook", "WebhookSepatateTriumphScreenshots", 0)
global UseRestartBtn := IniRead(SettingsFile, "Options", "UseRestartBtn", "1")
global UsePlayAgainBtn := IniRead(SettingsFile, "Options", "UsePlayAgainBtn", "1")
global RotateStrategies := IniRead(SettingsFile, "Options", "RotateStrategies", 0)
global AutoEquip := IniRead(SettingsFile, "Options", "AutoEquip", 0)
global CheckTheMap := IniRead(SettingsFile, "Options", "CheckTheMap", 1)
global UseHForUpgrade := IniRead(SettingsFile, "Options", "UseHotkeyForUpgrade", 1)
global CollectPlaytimeRewards:= IniRead(SettingsFile, "Options", "CollectPlaytimeRewards", "1")
global Strategy1Path := IniRead(SettingsFile, "Options", "Strategy1", "")
global Strategy2Path := IniRead(SettingsFile, "Options", "Strategy2", "")

global DefaultMouseSpeed := IniRead(SettingsFile, "Options", "DefaultMouseSpeed", "2")
global MouseDelay := IniRead(SettingsFile, "Options", "MouseDelay", "10")
global KeyDelay := IniRead(SettingsFile, "Options", "KeyDelay", "20")

global PlaceTowerKey := IniRead(SettingsFile, "RecordingHotkeys", "PlaceTowerKey", "f")
global UpgradeTowerKey := IniRead(SettingsFile, "RecordingHotkeys", "UpgradeTowerKey", "^u")
global AlignCameraKey := IniRead(SettingsFile, "RecordingHotkeys", "AlignCameraKey", "^t")
global ChangeDJTrackKey := IniRead(SettingsFile, "RecordingHotkeys", "ChangeDJTrackKey", "^d")
global SellTowerKey := IniRead(SettingsFile, "RecordingHotkeys", "SellTowerKey", "^x")
global DeleteTowerRecordingKey := IniRead(SettingsFile, "RecordingHotkeys", "DeleteTowerRecordingKey", "^b")
global RecordInputsKey := IniRead(SettingsFile, "RecordingHotkeys", "RecordInputsKey", "^+e")
global HoloKey := IniRead(SettingsFile, "RecordingHotkeys", "HoloKey", "^!h")
global UseRaiseDeadKey := IniRead(SettingsFile, "RecordingHotkeys", "RaiseDeadKey", "^vkC0")

global CurrentStratStartTime := Integer(IniRead(StateFile, "State", "CurrentStratStartTime", "0"))
global CurrentRotationIndex := Integer(IniRead(StateFile, "State", "CurrentRotationIndex", "1"))

global g_IsFirstLaunch := Integer(IniRead(StateFile, "State", "IsFirstLaunch", 1))

global SwapAmount := IniRead(SettingsFile, "Options", "SwapAmount", "4")
global SwapUnit := IniRead(SettingsFile, "Options", "SwapUnit", "Runs")
global CurrentRunCount := Integer(IniRead(StateFile, "State", "CurrentRunCount", "0"))

SendMode("Event")
SetDefaultMouseSpeed(DefaultMouseSpeed)
SetMouseDelay(MouseDelay)
SetKeyDelay(KeyDelay)

global LogLines := []
global OverlayHWND := 0
global OverlayBitmap := 0
global OverlayGraphics := 0
global OverlayPicHWND := 0
global OverlayWidth := 500
global OverlayHeight := 200
global OverlayX := 1400
global OverlayY := 820

global StrategyWidth := 1920
global StrategyHeight := 1090

global Slots := [
    ScaleX(800) " " ScaleY(960), 
    ScaleX(880) " " ScaleY(960), 
    ScaleX(960) " " ScaleY(960), 
    ScaleX(1040) " " ScaleY(960), 
    ScaleX(1120) " " ScaleY(960)
]

global ChainKey, BeatKey, CaravanKey, CancelPlacementKey, TimeScaleMode, UseTimeScale, TimeScaleMultiplier
ChainKey := IniRead(SettingsFile, "Hotkeys", "Chain", "C")
BeatKey := IniRead(SettingsFile, "Hotkeys", "Beat", "B")
CaravanKey := IniRead(SettingsFile, "Hotkeys", "Caravan", "J")
global RaiseDeadKey := IniRead(SettingsFile, "Hotkeys", "RaiseTheDead", "V")
global HologramKey := IniRead(SettingsFile, "Hotkeys", "Hologram", "K")
CancelPlacementKey := IniRead(SettingsFile, "Hotkeys", "CancelPlacement", "Q")
global UpgradeTowerGKey := IniRead(SettingsFile, "Hotkeys", "UpgradeTower", "E")
global UpgradeTowerGBKey := IniRead(SettingsFile, "Hotkeys", "UpgradeBottom", "Z")
TimeScaleMode := IniRead(SettingsFile, "Options", "TimeScaleMode", "OFF")
global DebugConsole := IniRead(SettingsFile, "Options", "DebugConsole", "1")

if (TimeScaleMode = "1.5x") {
    UseTimeScale := true,  TimeScaleMultiplier := 1.5
} else if (TimeScaleMode = "2x") {
    UseTimeScale := true,  TimeScaleMultiplier := 2
} else {
    UseTimeScale := false, TimeScaleMultiplier := 1
}

global gamemap := "", difficulty := "", requiredTowers := ""
global autoChain := "OFF", autoCaravan := "OFF", autoDropTheBeat := "OFF"
global Commander := false, AutoSkip := "ON", AbilitySpam := "ON"

global SpecialMaps := ["Simplicity", "Cataclysm"]

global MoveEnabled := false, MoveDirection := "W", MoveDuration := 750
global unfocusX := 150, unfocusY := 200
global Towers := Map(), RecordedSteps := [], Recording := false, RunningStrategy := false
global modifiers := ""
global LastDisconnectCheck := 0
global LastOpenedTowerID := ""
global IsRestarting := false
global SafeExitFlag := false
global RestartLock := false

global isUiPositionSaved := false
global isUpgradeAuthorized := false
global activeUpgradeRegions := [0, 0, 0, 0]
global CachedMenuUI := {x: 0, y: 0}

global canUseAbility := true

global KeyDownTimes := Map()

global MacroRecording := false
global MacroSteps := []
global MacroStartTime := 0
global InputHookObj := ""

global LastSkipCheck := 0
global SKIP_CHECK_INTERVAL := 1000
global AutorunStartTime := 0
global watchdogPID := ""

global SC_L:="sc026"
global SC_R:="sc013" 
global SC_Esc:="sc001"
global SC_Enter:="sc01c" 
SC_E:="sc012" ; e

if (DebugConsole = "1")
    ShowDebugConsole()

IconPath := A_WorkingDir "\icon.ico"
if FileExist(IconPath)
    TraySetIcon(IconPath)

WM_LBUTTONDOWN_Drag(wParam, lParam, msg, hwnd) {
    global MainGui
    if (StartCommunityScrollDrag())
        return

    If (MainGui) {
        if (hwnd != MainGui.Hwnd) {
            return
        }
    }
    mouseY := lParam >> 16
    if (mouseY >= 42)
        return

    PostMessage(0xA1, 2, , , "ahk_id " MainGui.Hwnd)
}

IsRecordingActive(*) {
    global Recording
    return (Recording != false)
}

HotIf(IsRecordingActive)

if (PlaceTowerKey = "") {
    IniWrite("f", SettingsFile, "RecordingHotkeys", "PlaceTowerKey")
    global PlaceTowerKey := IniRead(SettingsFile, "RecordingHotkeys", "PlaceTowerKey", "f")
}
if (PlaceTowerKey = "") {
    IniWrite("f", SettingsFile, "RecordingHotkeys", "PlaceTowerKey")
    global PlaceTowerKey := IniRead(SettingsFile, "RecordingHotkeys", "PlaceTowerKey", "f")
}
if (UpgradeTowerKey = "") {
    IniWrite("^u", SettingsFile, "RecordingHotkeys", "UpgradeTowerKey")
    global UpgradeTowerKey := IniRead(SettingsFile, "RecordingHotkeys", "UpgradeTowerKey", "^u")
}
if (AlignCameraKey = "") {
    IniWrite("^t", SettingsFile, "RecordingHotkeys", "AlignCameraKey")
    global AlignCameraKey := IniRead(SettingsFile, "RecordingHotkeys", "AlignCameraKey", "^t")
}
if (ChangeDJTrackKey = "") {
    IniWrite("^d", SettingsFile, "RecordingHotkeys", "ChangeDJTrackKey")
    global ChangeDJTrackKey := IniRead(SettingsFile, "RecordingHotkeys", "ChangeDJTrackKey", "^d")
}
if (SellTowerKey = "") {
    IniWrite("^x", SettingsFile, "RecordingHotkeys", "SellTowerKey")
    global SellTowerKey := IniRead(SettingsFile, "RecordingHotkeys", "SellTowerKey", "^x")
}
if (DeleteTowerRecordingKey = "") {
    IniWrite("^b", SettingsFile, "RecordingHotkeys", "DeleteTowerRecordingKey")
    global DeleteTowerRecordingKey := IniRead(SettingsFile, "RecordingHotkeys", "DeleteTowerRecordingKey", "^b")
}
if (RecordInputsKey = "") {
    IniWrite("^+e", SettingsFile, "RecordingHotkeys", "RecordInputsKey")
    global RecordInputsKey := IniRead(SettingsFile, "RecordingHotkeys", "RecordInputsKey", "^+e")
}
if (HoloKey = "") {
    IniWrite("^!h", SettingsFile, "RecordingHotkeys", "HoloKey")
    global HoloKey := IniRead(SettingsFile, "RecordingHotkeys", "HoloKey", "^!h")
}
if (UseRaiseDeadKey = "") {
    IniWrite("^vkC0", SettingsFile, "RecordingHotkeys", "RaiseDeadKey")
    global UseRaiseDeadKey := IniRead(SettingsFile, "RecordingHotkeys", "RaiseDeadKey", "^vkC0")
}

Hotkey(PlaceTowerKey, PlaceTowerHK)
Hotkey(UpgradeTowerKey, UpgradeTowerHK)
Hotkey(ChangeDJTrackKey, ChangeDJTrackHK)
Hotkey(DeleteTowerRecordingKey, DeleteTowerRecordingHK)
Hotkey(SellTowerKey, SellTowerHK)
Hotkey(AlignCameraKey, AlignCameraHK)
Hotkey(RecordInputsKey, RecordInputsHK)
Hotkey(HoloKey, CloneTowerHK)
Hotkey(UseRaiseDeadKey, ActivateRaiseTheDeadHK)
HotIf()

ScaleX(baseX, Width := 1920) {
    getRobloxPos(&pX, &pY, &currentWidth, &currentHeight)
    return Round(baseX * (currentWidth / Width))
}

ScaleY(baseY, Height := 1009) {
    getRobloxPos(&pX, &pY, &currentWidth, &currentHeight)
    return Round(baseY * (currentHeight / Height))
}

sX(baseX, Width := 1920) {
    global StrategyHeight
    hwnd := GetRobloxHWND()
    if !hwnd
        return

    getRobloxPos(&pX, &pY, &currentWidth, &currentHeight, hwnd)
    if (Width == 0) 
        return baseX

    if (Width == 1920 && StrategyHeight == 1090) {
        WinGetClientPos(&cX, , , , "ahk_id " hwnd)
        WinGetPos(&wX, , , , "ahk_id " hwnd)
        currentBorderX := cX - wX
        baseX := baseX - currentBorderX 
        Width := 1920 
    }
    
    return Round(baseX * (currentWidth / Width))
}

sY(baseY, Height := 1090) {
    hwnd := GetRobloxHWND()
    if !hwnd
        return
    getRobloxPos(&pX, &pY, &currentWidth, &currentHeight, hwnd)
    if (Height == 0) 
        return baseY
    
    if (Height == 1090) {
        WinGetClientPos(, &cY, , , "ahk_id " hwnd)
        WinGetPos(, &wY, , , "ahk_id " hwnd)
        currentBorderY := cY - wY
        baseY := baseY - currentBorderY 
        Height := 1009 
    }
    
    return Round(baseY * (currentHeight / Height))
}

autoRun := IniRead(StateFile, "State", "Running",   0)
autoStrat := IniRead(StateFile, "State", "Strategy",  "")
savedStartTime := IniRead(StateFile, "State", "StartTime", 0)
if (savedStartTime != 0)
    AutorunStartTime := Integer(savedStartTime)

if (autoRun = 1 && autoStrat != "" && FileExist(autoStrat)) {
    LoadStrategyFile(autoStrat)
    RunningStrategy := true
    ActivateRoblox()
    RunStrategy()
    RunningStrategy := false
    IniWrite(0, StateFile, "State", "Running")
} else {
    updateResult := CheckForUpdate(ver)
    if (updateResult = 2) {
        SafeReload()
    }

    MultiInstanceTools := "RobloxAccountManager.exe,Roblox Account Manager.exe,RAM.exe,RobloxMulti.exe,MultiRoblox.exe,MultipleRoblox.exe,Multiple Roblox.exe"
    Loop Parse, MultiInstanceTools, "," {
        if ProcessExist(A_LoopField) {
            MsgBox("Conflicting program detected:`n" A_LoopField "`n`nFor this script to work properly, please close all Roblox multi-client utilities.`nPlease close them and try again.", "Error", 48)
            ExitApp()
        }
    }
}

global MainGui := Gui("-Caption +Border +LastFound -DPIScale")
MainGui.BackColor := "121212"

global SystemHwnds := Map()

sysBar1 := MainGui.Add("Progress", "x0 y3 w700 h39 Disabled Background0A0A0A", 0)
SystemHwnds[sysBar1.Hwnd] := true

MainGui.SetFont("s11 w300 cFFFFFF", "Segoe UI")
if FileExist(IconPath) {
    sysIcon := MainGui.Add("Picture", "BackgroundTrans x20 y12 w20 h20", IconPath)
    SystemHwnds[sysIcon.Hwnd] := true
}

global GuiTitleCtrl := MainGui.Add("Text", "x50 y12 w150 h25 BackgroundTrans", "leomacro | TDS")
GuiTitleCtrl.OnEvent("Click", MoveWindow)
SystemHwnds[GuiTitleCtrl.Hwnd] := true

MainGui.SetFont("s11 w400 cFFFFFF", "Marlett")
global BtnMin   := MainGui.Add("Text", "x600 y12 w30 h25 Center BackgroundTrans", "0")
BtnMin.OnEvent("Click", MinimizeWindow)
SystemHwnds[BtnMin.Hwnd] := true

MainGui.SetFont("s11 w400 c888888", "Marlett")
sysDot := MainGui.Add("Text", "x630 y12 w30 h25 Center BackgroundTrans", "1")
SystemHwnds[sysDot.Hwnd] := true

MainGui.SetFont("s11 w400 cFFFFFF", "Marlett")
global BtnClose := MainGui.Add("Text", "x660 y12 w30 h25 Center BackgroundTrans", "r")
BtnClose.OnEvent("Click", CloseWindow)
SystemHwnds[BtnClose.Hwnd] := true

sysLine1 := MainGui.Add("Progress", "x0 y42 w700 h1 Background222222", 0)
SystemHwnds[sysLine1.Hwnd] := true


MainGui.SetFont("s10 w400 c888888", "Segoe UI")
global HoverTab := []
global TabCtrl  := []
global HoverEffect_btns := []
global GradientButtons := []
tabNames := ["Main", "Record", "Editor", "Webhook", "Settings", "Tools", "Credits"]

Loop 7 {
    i   := A_Index
    xTab := 20 + (i-1) * 90
    
    hBg := MainGui.Add("Progress", "x" xTab " y43 w80 h34 Hidden Background222222 Disabled")
    HoverTab.Push(hBg)
    SystemHwnds[hBg.Hwnd] := true 
    
    t := MainGui.Add("Text", "x" xTab " y52 w80 h22 Center BackgroundTrans", tabNames[i])
    t.OnEvent("Click", SelectTab)
    TabCtrl.Push(t)
    SystemHwnds[t.Hwnd] := true 
}

global TabLine := MainGui.Add("Progress", "x20 y75 w80 h2 BackgroundFFFFFF", 0)
SystemHwnds[TabLine.Hwnd] := true 

sysLine2 := MainGui.Add("Progress", "x0 y77 w700 h1 Background222222", 0)
SystemHwnds[sysLine2.Hwnd] := true


MainGui.SetFont("s10 w400 c3A86FF", "Segoe UI")
global Tab1_Section1 := MainGui.Add("Text", "x30 y95  w200 h22",  "Custom Strategies")
global Tab1_Line1 := MainGui.Add("Progress", "x30 y118 w640 h1  Background333333", 0)

MainGui.SetFont("s9 w400 cAAAAAA", "Segoe UI")
global Tab1_Lbl1 := MainGui.Add("Text", "x30 y130 w100 h20", "Strategy:")
MainGui.SetFont("s9 w400 c000000")
global Strategy1Ctrl := MainGui.Add("Edit", "x110 y127 w400 h22 vStrategy1", Strategy1Path)
Strategy1Ctrl.OnEvent("Change", SaveStrat1)
MainGui.SetFont("s9 w400 cFFFFFF")
global Tab1_Btn1 := MainGui.Add("Text", "x515 y126 w70 h22 +Border 0x200 Center", "Browse")
Tab1_Btn1.OnEvent("Click", SelectStrat1)
global Tab1_Btn2 := MainGui.Add("Text", "x590 y126 w70 h22 +Border 0x200 Center", "Clear")
Tab1_Btn2.OnEvent("Click", ClearStrat1)

HoverEffect_btns.Push(Tab1_Btn1) 
HoverEffect_btns.Push(Tab1_Btn2) 

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab1_Lbl2 := MainGui.Add("Text", "x30 y160 w100 h20", "Strategy 2:")
MainGui.SetFont("s9 w400 c000000")
global Strategy2Ctrl := MainGui.Add("Edit", "x110 y157 w400 h22 vStrategy2", Strategy2Path)
Strategy2Ctrl.OnEvent("Change", SaveStrat2)
MainGui.SetFont("s9 w400 cFFFFFF")
global Tab1_Btn3 := MainGui.Add("Text", "x515 y156 w70 h22 +Border 0x200 Center", "Browse")
Tab1_Btn3.OnEvent("Click", SelectStrat2)
global Tab1_Btn4 := MainGui.Add("Text", "x590 y156 w70 h22 +Border 0x200 Center", "Clear")
Tab1_Btn4.OnEvent("Click", ClearStrat2)

HoverEffect_btns.Push(Tab1_Btn3) 
HoverEffect_btns.Push(Tab1_Btn4) 

MainGui.SetFont("s9 w400 cFFFFFF")
global RotateStrategiesCtrl := MainGui.Add("Checkbox", "x30 y190 vRotateStrategies 0x200 Checked" RotateStrategies, "Strategy Rotation")
RotateStrategiesCtrl.OnEvent("Click", EnableStratRotation)

MainGui.SetFont("s9 w400 cAAAAAA")
global SwapAfterLbl := MainGui.Add("Text", "x148 y188 w70 h20 0x200 BackgroundTrans", "Swap after:")

MainGui.SetFont("s9 w400 c000000") 
global SwapAmountCtrl := MainGui.Add("Edit", "x217 y186 w40 h22 +Border Number Center vSwapAmount", SwapAmount)

SwapAmountCtrl.OnEvent("Change", (*) => (
    IniWrite(SwapAmountCtrl.Text, SettingsFile, "Options", "SwapAmount"),
    SwapAmount := SwapAmountCtrl.Text
))

MainGui.SetFont("s9 w400 c000000")
global SwapUnitCtrl := MainGui.Add("DropDownList", "x267 y186 w80 Choose" (SwapUnit = "Minutes" ? 2 : 1) " vSwapUnit", ["Runs", "Minutes"])

SwapUnitCtrl.OnEvent("Change", (*) => (
    IniWrite(SwapUnitCtrl.Text, SettingsFile, "Options", "SwapUnit"),
    SwapUnit := SwapUnitCtrl.Text
    IniWrite(SwapAmountCtrl.Text, SettingsFile, "Options", "SwapAmount")
))

MainGui.SetFont("s9 w400 cFFFFFF")
global AutoEquipCtrl := MainGui.Add("Checkbox", "x357 y190 vAutoEquip 0x200 Checked" AutoEquip, "Auto Equip Towers")
AutoEquipCtrl.OnEvent("Click", EnableAutoEquip)

if !DirExist(StratsDir)
    DirCreate(StratsDir)

LoadedStrats := []
needUpdate := true
lastUpdate := IniRead(StateFile, "Cache", "LastUpdateTime", "0")

if (lastUpdate != "0") {
    timeDiff := DateDiff(A_Now, lastUpdate, "Hours")
    if (timeDiff < 6) {
        needUpdate := false 
    }
}

if (needUpdate) {
    try {
        apiURL := "https://api.github.com/repos/DarksenDev/tds-macro/contents/Strategies"
        
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", apiURL, true)
        whr.SetRequestHeader("User-Agent", "Strategy-Updater")
        whr.Send()
        
        while (!whr.WaitForResponse(1)) {
            Sleep(50)
        }
        
        if (whr.Status != 200) {
            throw Error("API request failed with status: " whr.Status)
        }
            
        responseText := whr.ResponseText
        
        tempDir := StratsDir "\.download_temp"
        if DirExist(tempDir)
            DirDelete(tempDir, true)
        DirCreate(tempDir)

        pos := 1
        fileCount := 0
        successCount := 0
        
        while (pos := RegExMatch(responseText, '\{[^}]*"name":"([^"]+\.strat)"[^}]*"download_url":"([^"]+)"[^}]*\}', &match, pos)) {
            fileName := match[1]
            downloadURL := match[2]
            fileCount++
            
            try {
                fileWhr := ComObject("WinHttp.WinHttpRequest.5.1")
                fileWhr.SetTimeouts(3000, 3000, 3000, 5000)
                fileWhr.Open("GET", downloadURL, false)
                fileWhr.SetRequestHeader("User-Agent", "Strategy-Updater")
                fileWhr.Send()
                
                if (fileWhr.Status == 200) {
                    ado := ComObject("ADODB.Stream")
                    ado.Type := 1
                    ado.Open()
                    ado.Write(fileWhr.ResponseBody)
                    ado.SaveToFile(tempDir "\" fileName, 2)
                    ado.Close()
                    successCount++
                } else {
                    MsgBox("Failed to download file '" fileName "'. Status: " fileWhr.Status, (AlwaysOnTop = 1) ? 0x1000 : 0)
                }
            } catch Error as fileErr {
                MsgBox("Network error downloading file '" fileName "': " fileErr.Message, (AlwaysOnTop = 1) ? 0x1000 : 0)
            }
            
            pos += match.Len
            Sleep(30)
        }

        if (fileCount > 0 && successCount == 0) {
            DirDelete(tempDir, true)
            throw Error("All strategy downloads failed. Aborting update to protect existing files.")
        }

        if !DirExist(StratsDir)
            DirCreate(StratsDir)

        Loop Files, StratsDir "\*.strat" {
            try FileDelete(A_LoopFileFullPath)
        }

        Loop Files, tempDir "\*.strat" {
            FileMove(A_LoopFileFullPath, StratsDir "\" A_LoopFileName, 1)
        }
        
        DirDelete(tempDir, true)
        IniWrite(A_Now, StateFile, "Cache", "LastUpdateTime")
        
    } catch Error as err {
        MsgBox("Error while downloading strats: " err.Message, (AlwaysOnTop = 1) ? 0x1000 : 0)
    }
}

global FrameX := 30
global FrameY := 260
global FrameW := 640
global FrameH := 220
global ContentH := 400
global CurrentScrollPos := 0
global SliderH := 30
global ChildHwnd := 0
global ScrollThumbDragging := false
global ScrollThumbGrabOffset := 0

ChildGui := Gui("-Caption +E0x20 +Border +Parent" MainGui.Hwnd " -DPIScale")
ChildGui.BackColor := "181818"
ChildGui.SetFont("s10 cWhite", "Segoe UI")

ChildGui.SetFont("s10 w400 c3A86FF", "Segoe UI")
global Tab1_Section2 := ChildGui.Add("Text", "x10 y0 h22", "Community Strategies")
global Tab1_Line2 := ChildGui.Add("Progress", "x10 y23 w600 h1 Background333333", 0)

width := FrameW - 6

Loop Files, StratsDir "\*.strat" {
    localPath := A_LoopFileFullPath
    
    sMap := IniRead(localPath, "Settings", "map", "")
    sDifficulty := IniRead(localPath, "Settings", "difficulty", "")
    sTowers := IniRead(localPath, "Settings", "requiredTowers", "")
    sDesc := IniRead(localPath, "Info", "desc", "")
    sAuthor := IniRead(localPath, "Info", "author", "")
    sTitle := IniRead(localPath, "Info", "title", "")
    sTime := IniRead(localPath, "Info", "time", "")
    sIncome := IniRead(localPath, "Info", "income", "")
    sModifiers := IniRead(localPath, "Settings", "modifiers", "")
    
    LoadedStrats.Push({
        fileName: A_LoopFileName,
        map: sMap,
        difficulty: sDifficulty,
        towers: sTowers,
        desc: sDesc,
        author: sAuthor,
        title: sTitle,
        time: sTime,
        income: sIncome,
        modifiers: sModifiers
    })
}

StartY := 40
CardH  := 115
CardW  := 600
Gap    := 15

ContentH := StartY

for index, strat in LoadedStrats {
    CurrentY := StartY + ((index - 1) * (CardH + Gap))
    ContentH := CurrentY + CardH + Gap 

    C1X := 10
    C1Y := CurrentY

    hFrameBg := CreateFrame(CardW, CardH, 10, "0xff161616", "0xff1d1d1d", "0x62302d2d")
    ChildGui.Add("Picture", "x" C1X " y" C1Y " w" CardW " h" CardH " +BackgroundTrans", "HBITMAP:*" hFrameBg)

    hIconBg := CreateGradientButton(56, 56, 8, "0xff2f353f", "0xff15171b", "0xff000000", "0x232c3a50", "", "Segoe UI", 10, 1)
    ChildGui.Add("Picture", "x" (C1X + 10) " y" (C1Y + 30) " w76 h76 +BackgroundTrans", "HBITMAP:*" hIconBg)
    
    diffImg := "Resources/Strats/" strat.difficulty ".png"
    if !FileExist(diffImg) {
        MsgBox("Missing resource file: " diffImg, "Error", 0x1010)
    } else {
        ChildGui.Add("Picture", "x" (C1X + 20) " y" (C1Y + 40) " h56 w56 +BackgroundTrans", diffImg)
    }

    ChildGui.Add("Picture", "x" (C1X + 75) " y" (C1Y + 30) " w76 h76 +BackgroundTrans", "HBITMAP:*" hIconBg)
    rewardIcon := (strat.difficulty = "Hardcore" || strat.difficulty = "Voidcore") ? "Resources/Strats/GemsMediumPile.png" : "Resources/Strats/CoinsMediumPile.png"
    if !FileExist(rewardIcon) {
        MsgBox("Missing resource file: " rewardIcon, "Error", 0x1010)
    } else {
        ChildGui.Add("Picture", "x" (C1X + 85) " y" (C1Y + 40) " h56 w56 +BackgroundTrans", rewardIcon)
    }

    ChildGui.SetFont("s11 Bold cWhite", "Segoe UI")
    ChildGui.Add("Text", "x" (C1X + 15) " y" (C1Y + 12) " +BackgroundTrans", strat.title != "" ? strat.title : "Unknown Strat")
 
    ChildGui.SetFont("s9 w500 c7E848E", "Segoe UI")
    helpDl1 := ChildGui.Add("Text", "x" (C1X + 580) " y" (C1Y + 10) " +BackgroundTrans", "?") 
    helpDl1.OnEvent("Click", ((t, a, r, m, d) => (*) => StratInfo(t, a, r, m, d))(
        strat.title, 
        strat.author, 
        strat.towers, 
        (strat.modifiers != "" ? strat.modifiers : "none"), 
        strat.desc
    ))

    ChildGui.SetFont("s9 w400 cE2E4E7", "Segoe UI")
    ChildGui.Add("Text", "x" (C1X + 260) " y" (C1Y + 15) " w340 +BackgroundTrans", (strat.towers != "" ? strat.towers : "None"))

    ChildGui.SetFont("s9 w400 c7E848E", "Segoe UI")
    ChildGui.Add("Text", "x" (C1X + 260) " y" (C1Y + 36) " w320 +BackgroundTrans", strat.desc)

    if (strat.difficulty = "Hardcore") {
        badgeColor1 := "0xFFAB457B", badgeColor2 := "0xFF5C2040"
    } else if (strat.difficulty = "Molten") {
        badgeColor1 := "0xFFE09334", badgeColor2 := "0xFF8F5413"
    } else if (strat.difficulty = "Frost") {
        badgeColor1 := "0xff34a9e0", badgeColor2 := "0xff17559c"
    } else if (strat.difficulty = "Fallen") {
        badgeColor1 := "0xff17559c", badgeColor2 := "0xff351570"
    } else {
        badgeColor1 := "0xb900ff2a", badgeColor2 := "0xff1a5f39"
    }

    hgmMode := CreateGradientButton(102, 28, 3, badgeColor1, badgeColor2, "0x40000000", "0x7effffff", strat.difficulty != "" ? strat.difficulty : "Easy", "Segoe UI", 11, 1)
    ChildGui.Add("Picture", "x" (C1X + 145) " y" (C1Y + 35) " w102 h28 +BackgroundTrans", "HBITMAP:*" hgmMode)

    ChildGui.SetFont("s9 w500 c9CA4B0", "Segoe UI")
    ChildGui.Add("Text", "x" (C1X + 155) " y" (C1Y + 65) " +BackgroundTrans", "🕒 " (strat.time != "" ? strat.time : "Unknown"))
    ChildGui.Add("Text", "x" (C1X + 155) " y" (C1Y + 83) " +BackgroundTrans", "⛃ " (strat.income != "" ? strat.income : "Unknown"))

    if ((strat.difficulty = "Hardcore" || strat.difficulty = "Voidcore")) {
        hBtnNormal := CreateGradientButton(220, 38, 8, "0xff961ea1", "0xff5f237a", "0x40000000", "0x5dffffff", "Load", "Segoe UI", 14, 1)
        hBtnHover := CreateGradientButton(220, 38, 8, "0xffea00ff", "0xff8d32b7", "0x60000000", "0x5dffffff", "Load", "Segoe UI", 14, 1)
    } else {
        hBtnNormal := CreateGradientButton(220, 38, 8, "0xFF147A6E", "0xFF214B75", "0x40000000", "0x5dffffff", "Load", "Segoe UI", 14, 1)
        hBtnHover := CreateGradientButton(220, 38, 8, "0xFF1CB5A2", "0xFF3272B7", "0x60000000", "0x5dffffff", "Load", "Segoe UI", 14, 1)
    }

    picLoadBtn := ChildGui.Add("Picture", "x" (C1X + 365) " y" (C1Y + 68) " w220 h38 +BackgroundTrans", "HBITMAP:*" hBtnNormal)

    dl1 := ChildGui.Add("Text", "x" (C1X + 365) " y" (C1Y + 68) " w220 h38 +BackgroundTrans +0x200 Center", "")
    dl1.SetFont("cFFFFFF s10 Bold", "Segoe UI")
    
    dl1.StratFile := strat.fileName
    dl1.OnEvent("Click", DownloadStrat)

    dl1.PicControl := picLoadBtn  
    dl1.ImgNormal := hBtnNormal   
    dl1.ImgHover := hBtnHover    
    GradientButtons.Push(dl1) 
}

if (LoadedStrats.Length == 0) {
    ChildGui.SetFont("s12 c7E848E", "Segoe UI")
    ChildGui.Add("Text", "x0 y0 w" FrameW " h" FrameH " +BackgroundTrans Center +0x200", "No strategies found.")
    ContentH := 220
}

SliderX := FrameW - 10 
SliderW := 6 

if (ContentH > 0) {
    SliderH := Round(FrameH * (FrameH / ContentH))
    
    if (ContentH <= FrameH) {
        SliderH := FrameH
    } else {
        SliderH := Max(30, SliderH)
    }
    
    if (ContentH > FrameH && CurrentScrollPos > 0) {
        maxScroll := ContentH - FrameH
        scrollPercent := CurrentScrollPos / maxScroll
        sliderPos := Round(scrollPercent * (FrameH - SliderH))
        sliderPos := Max(0, Min(sliderPos, FrameH - SliderH))
    } else {
        sliderPos := 0
    }
    
    hSlider := CreateScrollThumb(SliderW, SliderH, 3, "0xFF6EA7FF", "0xff4076ce", "0xd4d4d4")
    hSliderBG := CreateScrollThumb(SliderW, FrameH, 3, "0xff000000", "0xff000000", "0x000000")
    
    global SliderBG := ChildGui.Add("Picture", "x" SliderX " y0 w" SliderW " h" FrameH+ContentH " +BackgroundTrans", "HBITMAP:*" hSliderBG)
    global CustomSlider := ChildGui.Add("Picture", "x" SliderX " y" sliderPos " w" SliderW " h" SliderH " +BackgroundTrans", "HBITMAP:*" hSlider)
    
    SliderBG.Visible := true
    CustomSlider.Visible := true
}

OnMessage(0x0115, OnScroll)
OnMessage(0x020A, OnMouseWheel)


MainGui.SetFont("s11 w400 cFFFFFF", "Segoe UI")
global Tab1_Start := MainGui.Add("Text", "x30 y500 w300 h40 Center Background0e0e0f +Border 0x200", "Start (F1)")
Tab1_Start.OnEvent("Click", StartStrategy)
global Tab1_Stop := MainGui.Add("Text",  "x340 y500 w330 h40 Center Background0e0e0f +Border 0x200", "Stop (F2)")
Tab1_Stop.OnEvent("Click", StopStrategy)

HoverEffect_btns.Push(Tab1_Start) 
HoverEffect_btns.Push(Tab1_Stop) 

MainGui.SetFont("s10 w400 c3A86FF", "Segoe UI")
global Tab2_Title := MainGui.Add("Text", "x30 y95  w200 h22 Hidden", "Configuration")
global Tab2_Line1 := MainGui.Add("Progress", "x30 y118 w640 h1  Hidden Background333333", 0)

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab2_Lbl1 := MainGui.Add("Text", "x30 y145 w80 h20 Hidden", "Map:")
MainGui.SetFont("s9 w400 cFFFFFF")
global RecMapCtrl := MainGui.Add("DropDownList", "x80 y142 w220 Hidden vRecMap", [
    "Abandoned City", "Area 52", "Autumn Falling", 
    "Badlands II", "Black Spot Exchange", "Candy Valley", "Cataclysm", "Chess Board", 
    "Construction Crazy", "Coral Deep", "Crossroads", "Crystal Cave", 
    "Cyber City", "Dead Ahead", "Derelict Outpost", "Deserted Village", "Dusty Bridges", 
    "Enchanted Forest", "Farm Lands", "Forest Camp", "Forgetten Docks", "Four Seasons", 
    "Fungi Island", "Grass Isle", "Happy Home of Robloxia", "Harbor", "Honey Valley", 
    "Hot Spot", "Iceville", "Infernal Abyss", "Lay By", "Lighthaos", "Marshlands", "Mason Arch", "Medieval Times", "Meltdown", 
    "Midnight Issue", "Moon Base", "Musaceae Kingdom", "Necropolis", "Nether", "Night Station", 
    "Northern Lights", "Outskirts Commune", "Pier Pressure", "Pizza Party", "Polluted Wasteland II", 
    "Portland", "Retro Crossroads", "Retro Lighthouse", "Retro Rocket Arena", "Retro Stained Temple", 
    "Retro The Heights", "Retro Zone", "Rocket Arena", "Ruby Escort", "Sacred Mountains", 
    "Sky Islands", "Simplicity", "Space City", "Spring Fever", "Stained Temple", "Sugar Rush", 
    "The Heavens", "The Heights", "Toyboard", "Tropical Industries", "Tropical Isles", "U-Turn", 
    "Unknown Garden", "Winter Abyss", "Winter Bridges", "Winter Stronghold", "Wrecked Battlefield", 
    "Wrecked Battlefield II", "Wretched Front"
])

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab2_Lbl2 := MainGui.Add("Text", "x320 y145 w80 h20 Hidden", "Mode:")
MainGui.SetFont("s9 w400 cFFFFFF")
global RecDiffCtrl := MainGui.Add("DropDownList", "x380 y142 w220 Hidden vRecDifficulty", [
    "Easy", "Casual", "Intermediate", "Molten", "Fallen", "Frost", 
    "Hardcore", "Voidcore", "Pizza Party", "Badlands II", "Polluted Wasteland II"
])

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab2_Lbl3 := MainGui.Add("Text", "x30 y235 w80 h20 Hidden", "Modifiers:")
MainGui.SetFont("s9 w400 c000000")

global RecModifiersCtrl := MainGui.Add("ListBox", "x110 y232 w220 h200 Multi Hidden vRecModifiers", [
    "Broke", "Exploding", "Flying", "Fog", "Glass", 
    "Healthy", "Hidden", "Inflation", "Jailed", "Limitation", 
    "Committed", "Quarantine", "Speedy"
])

MainGui.SetFont("s9 w400 cAAAAAA", "Segoe UI")
global Tab2_Info2 := MainGui.Add("Text", "x20 w60 y275 BackgroundTrans Hidden", "Hold CTRL to deselect/select multiple modifiers.")

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab2_Lbl4 := MainGui.Add("Text", "x30 y185 w80 h20 Hidden", "Towers:")
MainGui.SetFont("s9 w400 c000000")
global RecTowersCtrl := MainGui.Add("Edit", "x80 y182 w220 h22 Hidden vRecRequiredTowers", requiredTowers)

MainGui.SetFont("s9 w400 cAAAAAA", "Segoe UI")
global Tab2_Info1 := MainGui.Add("Text", "x320 y173 BackgroundTrans Hidden", "Enter towers for your strategy using comma after every tower.`nMinigunner, Ranger, Commander, DJ, Military Base for example.`nType G Whatever if the tower you using NEEDS to be golden.")

MainGui.Add("Progress", "x360 y232 w320 h1 Hidden Background333333 vTab2_Line2", 0)
global Tab2_Line2 := MainGui["Tab2_Line2"]

MainGui.SetFont("s9 w400 cFFFFFF", "Segoe UI")
global RecAutoChainCtrl := MainGui.Add("Checkbox", "x360 y255 Hidden vRecAutoChain Checked" (autoChain="ON"?1:0), "Use Call of Arms")
global RecAutoCaravanCtrl := MainGui.Add("Checkbox", "x490 y255 Hidden vRecAutoCaravan Checked" (autoCaravan="ON"?1:0), "Use Support Caravan")
global RecAutoDropCtrl := MainGui.Add("Checkbox", "x360 y275 Hidden vRecAutoDropTheBeat Checked" (autoDropTheBeat="ON"?1:0), "Use Drop the Beat")

MainGui.Add("Progress", "x360 y300 w320 h1 Hidden Background333333 vTab2_Line3", 0)
global Tab2_Line3 := MainGui["Tab2_Line3"]
global RecAutoSkipCtrl := MainGui.Add("Checkbox", "x360 y315 h20 Hidden vRecAutoSkip", "Auto Skip Waves")
global RecAbilitySpamCtrl := MainGui.Add("Checkbox", "x490 y315 h20 Hidden vRecAbilitySpam", "Abilities Spam")
global Tab2_Info := MainGui.Add("Link", "x360 y360 w320 h100 Hidden", "
(
There you can create your own strategy and save it into a file. Watch the tutorial here: <a href="https://www.youtube.com/watch?v=j8Y5qHBaYOs&feature=youtu.be">https://www.youtube.com/watch?v=j8Y5qHBaYOs&feature=youtu.be</a>. I recommend using the timescale ticket when recording complex strategies.
)")

global RecMoveCtrl := MainGui.Add("Checkbox", "x30 y452 w60 h20 Hidden vRecMoveEnabled Checked" (MoveEnabled?1:0), "Move")
MainGui.SetFont("s9 w400 cAAAAAA")
global DIRECTIONTEXTCtrl := MainGui.Add("Text", "x100 y452 w45 Hidden", "Direction")
MainGui.SetFont("s9 w400 cFFFFFF")
global RecMoveDirCtrl := MainGui.Add("DropDownList", "x160 y450 w45 Hidden Choose1 vRecMoveDirection", ["W", "A", "S", "D"])
MainGui.SetFont("s9 w400 cAAAAAA")
global Tab2_Txt4 := MainGui.Add("Text", "x220 y452 Hidden", "Duration (ms):")
MainGui.SetFont("s9 w400 c000000")
global RecMoveDurCtrl := MainGui.Add("Edit", "x310 y450 w50 h22 Hidden vRecMoveDuration", "5000")

MainGui.SetFont("s11 w400 cFFFFFF", "Segoe UI")
global Tab2_Btn1 := MainGui.Add("Text", "x30  y500 w300 h40 Center Background0e0e0f +Border 0x200 Hidden", "Start Recording")
Tab2_Btn1.OnEvent("Click", StartRecording)
MainGui.SetFont("s11 w400 c808080", "Segoe UI")
global Tab2_Btn2 := MainGui.Add("Text", "x340 y500 w330 h40 Center Background0e0e0f +Border 0x200 Hidden", "Stop")
Tab2_Btn2.OnEvent("Click", StopRecord)

HoverEffect_btns.Push(Tab2_Btn1) 

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab3_Content := MainGui.Add("Text", "x30 y100 w640 h40 Center Hidden", "Coming soon... Suggest your ideas on what to put here in Discord!`nI'm tired :<")


MainGui.SetFont("s10 w400 c3A86FF", "Segoe UI")
global Tab4_Title := MainGui.Add("Text", "x30 y95  w200 h22 Hidden", "Discord Webhook")
global Tab4_Line1 := MainGui.Add("Progress", "x30 y118 w640 h1  Hidden Background333333", 0)
MainGui.SetFont("s9 w400 cAAAAAA")
MainGui.Add("Text", "x30 y135 w200 h20 Hidden vTab4_Lbl1", "Webhook URL:")
global Tab4_Lbl1 := MainGui["Tab4_Lbl1"]
MainGui.SetFont("s9 w400 c000000")
global WebhookLinkCtrl := MainGui.Add("Edit", "x30 y155 w640 h24 Hidden vWebhookLink", WebhookLink)
WebhookLinkCtrl.OnEvent("Change", CheckWebhookLink)
MainGui.SetFont("s9 w400 cFFFFFF")
global WebhookEnabledCtrl := MainGui.Add("Checkbox", "x30 y195 Hidden vWebhookEnabled Checked" WebhookEnabled, "Enable Webhook")
global Tab4_Line2 := MainGui.Add("Progress", "x30 y243 w640 h1 Hidden Background333333", 0)
global SendCurrCtrl := MainGui.Add("Checkbox", "x30 y253 Hidden vSendCurrenciesEnabled Checked" SendCurrenciesEnabled, "Send Statistics")
SendCurrCtrl.OnEvent("Click", (CtrlObj, *) => CtrlObj.Value ? CheckOcrLanguage() : "")
global DebugLogsCtrl := MainGui.Add("Checkbox", "x140 y253 Hidden vWebhookDebugLogs Checked" WebhookDebugLogs, "Debug Logs")
global WebhookScreenshotsCtrl := MainGui.Add("Checkbox", "x235 y253 Hidden vWebhookScreenshots Checked" WebhookScreenshots, "Automatic screenshots")
global WebhookTriumphScreenshotsCtrl := MainGui.Add("Checkbox", "x385 y253 Hidden vWebhookTriumphScreenshots Checked" WebhookTriumphScreenshots, "Triumph and Loss screenshots")
global WebhookSepatateTriumphScreenshotsCtrl := MainGui.Add("Checkbox", "x30 y283 Hidden vWebhookSepatateTriumphScreenshots Checked" WebhookSepatateTriumphScreenshots, "Send Triumph/Loss to a separate channel")
MainGui.SetFont("s9 w400 c000000")
global WebhookLinkCtrl2 := MainGui.Add("Edit", "x285 y283 w360 h24 Hidden vWebhookLink2", WebhookLink2)
MainGui.SetFont("s9 w400 cFFFFFF")
WebhookLinkCtrl2.OnEvent("Change", CheckWebhookLink2)
EnableWebhookLink2()
WebhookSepatateTriumphScreenshotsCtrl.OnEvent("Click", EnableWebhookLink2)
global Tab4_Info := MainGui.Add("Text", "x30 y400 w640 h100 Hidden", "Webhook sends real-time logs, screenshots, and currency stats to your Discord server.`nUseful to check if your macro is working while being outside.`nHow to get a webhook URL: Create your own Discord Server > Open any channel's settings > Integrations > Create Webhook > Copy Webhook URL.")
MainGui.SetFont("s12 w400 cFFFFFF")
global Tab4_Btn1 := MainGui.Add("Text", "x30  y500 w300 h40 Center Background0e0e0f +Border 0x200 Hidden", "Test Webhook")
Tab4_Btn1.OnEvent("Click", TestWebhook)
global Tab4_Btn2 := MainGui.Add("Text", "x340 y500 w330 h40 Center Background0e0e0f +Border 0x200 Hidden", "Save webhook settings")
Tab4_Btn2.OnEvent("Click", SaveWebhookSettings)

HoverEffect_btns.Push(Tab4_Btn1) 
HoverEffect_btns.Push(Tab4_Btn2) 

;TAB 5 - SETTINGS ==========================

MainGui.SetFont("s10 w400 c3A86FF", "Segoe UI")
global Tab5_Section1 := MainGui.Add("Text", "x30 y95  w200 h22 Hidden", "TDS Keybinds")
global Tab5_Line1    := MainGui.Add("Progress", "x30 y118 w250 h1  Hidden Background333333", 0)

MainGui.SetFont("s8 w400 cAAAAAA", "Segoe UI")
global Tab5_Lbl1 := MainGui.Add("Text", "x30 y135 w70 h16 Hidden", "Call of Arms:")
MainGui.SetFont("s8 w400 c000000")
global ChainKeyCtrl := MainGui.Add("Edit", "x105 y132 w40 h18 Center Limit1 Hidden", ChainKey)

MainGui.SetFont("s8 w400 cAAAAAA")
global Tab5_Lbl2 := MainGui.Add("Text", "x152 y135 w80 h16 Hidden", "Drop The Beat:")
MainGui.SetFont("s8 w400 c000000")
global BeatKeyCtrl := MainGui.Add("Edit", "x238 y132 w40 h18 Center Limit1 Hidden", BeatKey)

MainGui.SetFont("s8 w400 cAAAAAA")
global Tab5_Lbl3 := MainGui.Add("Text", "x30 y160 h16 Hidden", "S. Caravan:")
MainGui.SetFont("s8 w400 c000000")
global CaravanKeyCtrl := MainGui.Add("Edit", "x105 y157 w40 h18 Center Limit1 Hidden", CaravanKey)

MainGui.SetFont("s8 w400 cAAAAAA")
global Tab5_Lbl44 := MainGui.Add("Text", "x152 y160 w80 h16 Hidden", "Raise the Dead:")
MainGui.SetFont("s8 w400 c000000")
global RaiseDeadKeyCtrl := MainGui.Add("Edit", "x238 y157 w40 h18 Center Limit1 Hidden", RaiseDeadKey)

MainGui.SetFont("s8 w400 cAAAAAA")
global Tab5_Lbl55 := MainGui.Add("Text", "x30 y185 h16 Hidden", "Hologram:")
MainGui.SetFont("s8 w400 c000000")
global HologramKeyCtrl := MainGui.Add("Edit", "x105 y182 w40 h18 Center Limit1 Hidden", HologramKey)

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab5_Lbl99 := MainGui.Add("Text", "x30 y225 BackgroundTrans Hidden", "Cancel:")
MainGui.SetFont("s9 w400 c000000")
global CancelPlacementKeyCtrl := MainGui.Add("Edit", "x78 y222 w22 h22 Center Limit1 Hidden", CancelPlacementKey)

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab5_LblUPG := MainGui.Add("Text", "x113 y225 BackgroundTrans Hidden", "Upgrade:")
MainGui.SetFont("s8 w400 c000000")
global UpgradeTowerGCtrl := MainGui.Add("Edit", "x168 y222 w16 h16 Center Limit1 Hidden", UpgradeTowerGKey)

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab5_LblUPGBTM := MainGui.Add("Text", "x118 y248 BackgroundTrans Hidden", "bottom:")
MainGui.SetFont("s8 w400 c000000")
global UpgradeTowerGBCtrl := MainGui.Add("Edit", "x168 y245 W16 h16 Center Limit1 Hidden", UpgradeTowerGBKey)

MainGui.SetFont("s9 w400 cFFFFFF")

MainGui.SetFont("s10 w400 c3A86FF", "Segoe UI")
global Tab5_Section2 := MainGui.Add("Text", "x310 y95  w200 h22 Hidden BackgroundTrans", "Macro Settings")
global Tab5_Line2    := MainGui.Add("Progress", "x310 y118 w360 h1  Hidden Background333333", 0)

MainGui.SetFont("s9 w400 cFFFFFF", "Segoe UI")
global UseUpgradeHCtrl := MainGui.Add("Checkbox", "x310 y135 Hidden", "Use Hotkeys for Upgrading")
UseUpgradeHCtrl.Value := (UseHForUpgrade = 1)
global Tab5_Help6 := MainGui.Add("Text", "x475 y135 w18 h18 0x200 Center Hidden", "?")
Tab5_Help6.OnEvent("Click", HelpAutoCameraCorrection)

global UseRestartBtnCtrl := MainGui.Add("Checkbox", "x310 y160 Hidden", "Click Restart button")
UseRestartBtnCtrl.Value := (UseRestartBtn = "1" || UseRestartBtn = 1)
global Tab5_Help4 := MainGui.Add("Text", "x475 y158 w18 h18 0x200 Center Hidden", "?")
Tab5_Help4.OnEvent("Click", HelpRestartBtn)

global UsePlayAgainBtnCtrl := MainGui.Add("Checkbox", "x310 y185 Hidden", "Click Play Again button")
UsePlayAgainBtnCtrl.Value := (UsePlayAgainBtn = "1" || UsePlayAgainBtn = 1)
global Tab5_Help5 := MainGui.Add("Text", "x475 y183 w18 h18 0x200 Center Hidden", "?")
Tab5_Help5.OnEvent("Click", HelpPlayAgainBtn)

global CheckTheMapCtrl := MainGui.Add("Checkbox", "x310 y210 Hidden", "Check the map")
CheckTheMapCtrl.Value := (CheckTheMap = "1" || CheckTheMap = 1)
global Tab5_Help7 := MainGui.Add("Text", "x475 y207 w18 h18 0x200 Center Hidden", "?")
Tab5_Help7.OnEvent("Click", HelpCheckTheMap)

global CollectPlaytimeRewardsCtrl := MainGui.Add("Checkbox", "x510 y185 Hidden", "Collect playtime rewards")
CollectPlaytimeRewardsCtrl.Value := (CollectPlaytimeRewards = "1" || CollectPlaytimeRewards = 1)

global DebugConsoleCtrl := MainGui.Add("Checkbox", "x570 y135 Hidden", "Debug Logs")
DebugConsoleCtrl.Value := (DebugConsole = "1" || DebugConsole = 1)

global PotatoModeCtrl := MainGui.Add("Checkbox", "x570 y160 Hidden", "Potato Mode")
PotatoModeCtrl.Value := (PotatoMode = 1)

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab1_Lbl3 := MainGui.Add("Text", "x505 y220 w100 h20 Hidden BackgroundTrans", "Use Timescale:")
MainGui.SetFont("s9 w400 cFFFFFF")
global TimeScaleModeCtrl := MainGui.Add("DropDownList", "x595 y216 w80 Hidden", ["OFF","1.5x","2x"])
TimeScaleModeCtrl.Text := TimeScaleMode

MainGui.SetFont("s9 w400 cFFFFFF")
global MouseSpeedLbl := MainGui.Add("Text", "x310 y260 w110 h20 Hidden BackgroundTrans", "Mouse Speed:")
global MouseSpeedTxt := MainGui.Add("Text", "x389 y260 w26 Hidden", DefaultMouseSpeed)
global MouseSpeedUpDown := MainGui.Add("UpDown", "Range1-3 Hidden", DefaultMouseSpeed)
MouseSpeedUpDown.OnEvent("Change", (ctrl, *) => MouseSpeedTxt.Value := ctrl.Value)

global MouseDelayLbl := MainGui.Add("Text", "x435 y260 w90 h20 Hidden BackgroundTrans", "Mouse Delay:")
global MouseDelayTxt := MainGui.Add("Text", "x509 y260 w32 Hidden", MouseDelay)
global MouseDelayUpDown := MainGui.Add("UpDown", "Range3-75 Hidden", MouseDelay)
MouseDelayUpDown.OnEvent("Change", (ctrl, *) => MouseDelayTxt.Value := ctrl.Value)

global KeyDelayLbl := MainGui.Add("Text", "x565 y260 w90 h20 Hidden BackgroundTrans", "Key Delay:")
global KeyDelayTxt := MainGui.Add("Text", "x625 y260 w32 Hidden", KeyDelay)
global KeyDelayUpDown := MainGui.Add("UpDown", "Range5-100 Hidden", KeyDelay)
KeyDelayUpDown.OnEvent("Change", (ctrl, *) => KeyDelayTxt.Value := ctrl.Value)

MainGui.SetFont("s10 w400 c3A86FF", "Segoe UI")
global Tab5_Section3 := MainGui.Add("Text",     " BackgroundTrans x30 y272 w200 h22 Hidden", "Recording Hotkeys")
global Tab5_Line3    := MainGui.Add("Progress", "x30 y295 w640 h1  Hidden Background333333", 0)

MainGui.SetFont("s9 w400 cAAAAAA")
global PlcTowerTEXT := MainGui.Add("Text", "x30 y304 w95 h20 Hidden", "Place Tower:")
global PlaceTowerKeyCtrl := MainGui.Add("Hotkey", "x130 y304 w110 h20 Center Hidden", PlaceTowerKey)

global UpgTowerTEXT := MainGui.Add("Text", "x30 y334 w95 h20 Hidden", "Upgrade Tower:")
global UpgradeTowerKeyCtrl := MainGui.Add("Hotkey", "x130 y334 w110 h20 Center Hidden", UpgradeTowerKey)

global AlignCamTEXT := MainGui.Add("Text", "x30 y366 w95 h20 Hidden", "Align Camera:")
global AlignCameraKeyCtrl := MainGui.Add("Hotkey", "x130 y366 w110 h20 Center Hidden", AlignCameraKey)

global DjTrackTEXT := MainGui.Add("Text", "x255 y304 w95 h20 Hidden", "Change DJ Track:")
global ChangeDJTrackKeyCtrl := MainGui.Add("Hotkey", "x355 y304 w110 h20 Center Hidden", ChangeDJTrackKey)

global SellTowTEXT := MainGui.Add("Text", "x255 y334 w95 h20 Hidden", "Sell Tower:")
global SellTowerKeyCtrl := MainGui.Add("Hotkey", "x355 y334 w110 h20 Center Hidden", SellTowerKey)

global DelRecTEXT := MainGui.Add("Text", "x255 y366 w95 h20 Hidden", "Delete Record:")
global DeleteTowerRecordingKeyCtrl := MainGui.Add("Hotkey", "x355 y366 w110 h20 Center Hidden", DeleteTowerRecordingKey)

global RecInputsTEXT := MainGui.Add("Text", "x480 y304 w95 h20 Hidden", "Record Inputs:")
global RecordInputsKeyCtrl := MainGui.Add("Hotkey", "x580 y304 w90 h20 Center Hidden", RecordInputsKey)

global HoloTEXT := MainGui.Add("Text", "x480 y334 w95 h20 Hidden", "Hologram Tower:")
global HoloKeyCtrl := MainGui.Add("Hotkey", "x580 y334 w90 h20 Center Hidden", HoloKey)

global RaiseDeadTEXT := MainGui.Add("Text", "x480 y366 w95 h20 Hidden", "Raise the Dead:")
global UseRaiseDeadKeyCtrl := MainGui.Add("Hotkey", "x580 y366 w90 h20 Center Hidden", UseRaiseDeadKey)

global Tab5_Line4 := MainGui.Add("Progress", "x30 y393 w640 h1 Hidden Background333333", 0)

MainGui.SetFont("s9 w400 cAAAAAA")
global Tab5_Lbl4 := MainGui.Add("Text", "x30 y405 w100 h20 Hidden", "VIP Server Link:")
MainGui.SetFont("s9 w400 c000000")
global VipLinkCtrl := MainGui.Add("Edit", "x30 y430 w640 h24 Hidden", VipLink)
MainGui.SetFont("s11 w400 cFFFFFF")
VipLinkCtrl.OnEvent("Change", CheckVipLink)

global UseVipServerCtrl := MainGui.Add("Checkbox", "x30 y465 Hidden", "Use VIP Server")
UseVipServerCtrl.Value := (UseVipServer = "1" || UseVipServer = 1)

global AlwaysOnTopCtrl := MainGui.Add("Checkbox", "x160 y465 Hidden", "Always On Top")
AlwaysOnTopCtrl.Value := (AlwaysOnTop = "1" || AlwaysOnTop = 1)

MainGui.SetFont("s11 w400 cFFFFFF")
global Tab5_Btn1 := MainGui.Add("Text", "x30 y500 w645 h40 Center Background0e0e0f +Border 0x200 Hidden", "Save all settings")
Tab5_Btn1.OnEvent("Click", SaveAllSettings)

HoverEffect_btns.Push(Tab5_Btn1)

; tab 6 - tools ===========================

MainGui.SetFont("s10 w400 c3A86FF", "Segoe UI")
global Tools_Section := MainGui.Add("Text", "x30 y95 w200 h22 Hidden", "Tools")
global Tools_Section_Line := MainGui.Add("Progress", "x30 y118 w640 h1 Hidden  Background333333", 0)

MainGui.SetFont("s9 w400 cffffff")
global Tools_Info:= MainGui.Add("Text", "x30 y490 w640 h100 Hidden", "Additional utilities for optimizing and simplifying the gameplay and automating repetitive actions. It reduces your suffering.")

global Auto_COA := MainGui.Add("Picture", "x30 y125 w197 h176 Hidden", "Resources/Gui/auto_coa_preview.png")

Auto_COA.OnEvent("Click", RunAutoAbTool)

global Auto_Spin := MainGui.Add("Picture", "x240 y125 w197 h139 Hidden", "Resources/Gui/auto_spin_preview.png")

Auto_Spin.OnEvent("Click", RunAutoSpinTool)

global Auto_Consum := MainGui.Add("Picture", "x450 y125 w200 h140 Hidden", "Resources/Gui/auto_open_consumable_preview.png")

Auto_Consum.OnEvent("Click", RunAutoConsumableTool)


; tab 7 - credits ===========================

MainGui.SetFont("s16 w450 cFFFFFF", "Segoe UI Variable")
global Credit_TITLE := MainGui.Add("Text", "x30 y95 w640 Hidden Center", "leomacro - the best macro for TDS")

MainGui.SetFont("s12 w400 cFFFFFF", "Segoe UI")
global Credit_Content := MainGui.Add("Link", "x30 y140 w640 Hidden", "
(
Started on March 30, 2026. 
My friend bet me that I wouldn't make a macro for TDS, but I did. 

Join my discord server for help, update leaks and more!

Created by Darksen (darksenn_).
SPECIAL THANKS TO MY DISCORD COMMUNITY!

You can support my work <a href="https://www.donationalerts.com/r/darksen1">here</a>, do it if you're really enjoying the macro.
I've been doing this all for free :sob: and I truly appreciate any support!
)")

global Divider := MainGui.Add("Progress", "x0 y500 w700 h1 Hidden Background222222", 0)
global FooterBg := MainGui.Add("Progress", "x0 y501 w700 h64 Disabled Hidden Background0f0f0f", 0)

global version_text := MainGui.Add("Text", "x30 y520 BackgroundTrans Hidden", ver)

global githubImg := MainGui.Add("Picture", "x580 y520 w24 h-1 Hidden BackgroundTrans", "Resources\github.png")
githubImg.OnEvent("Click", githubLink)
global DiscordImg := MainGui.Add("Picture", "x611 y520 w24 h-1 Hidden BackgroundTrans", "Resources\discord.png")
DiscordImg.OnEvent("Click", DiscordLink)
global YoutubeImg := MainGui.Add("Picture", "x642 y520 w24 h-1 Hidden BackgroundTrans", "Resources\youtube.png")
YoutubeImg.OnEvent("Click", YouTubeLink)

MainGui.Title := "leomacro"
MainGui.Show("w700 h565")

if (AlwaysOnTop = 1) {
    MainGui.Opt("+AlwaysOnTop")
} else {
    MainGui.Opt("-AlwaysOnTop")
}

SetTimer(() => RemoveInitialFocus(), -50)

global CurrentTab := "Tab1"
TabCtrl[1].SetFont("cFFFFFF")
ShowTabContent("Tab1")
ShowChildGui()
EnableStratRotation()

SetTimer(Hoverwatchdog, 10)

OnMessage(0x0201, WM_LBUTTONDOWN_Drag)

RemoveInitialFocus() {
    if !WinActive("ahk_id " MainGui.Hwnd)
        return
    ControlFocus(GuiTitleCtrl, "ahk_id " MainGui.Hwnd)
}

~F1:: StartStrategy(0, 0)
~F2:: StopStrategy(0, 0)

SelectTab(ctrl, *) {
    global CurrentTab, TabCtrl, TabLine, HoverTab
    idx := 0
    Loop HoverTab.Length {
        if (TabCtrl[A_Index] = ctrl) {
            idx := A_Index
            break
        }
    }
    if (!idx)
        return
    newTab := "Tab" idx
    if (newTab = CurrentTab)
        return
    
    oldIdx := Integer(SubStr(CurrentTab, 4))
    TabCtrl[oldIdx].SetFont("c888888")
    HideAllTabContent()
    
    CurrentTab := newTab
    TabCtrl[idx].SetFont("cFFFFFF")
    
    
    newX := 20 + (idx - 1) * 90
    TabLine.Move(newX, , 80)
    
    ShowTabContent(newTab)
}

Hoverwatchdog(*) {
    static hClose := 0, hMin := 0, hMain := 0, hChild := 0
    static hoverClose := false, hoverMin := false, hoverTabs := []
    loop HoverTab.Length {
        hoverTabs.Push(false)
    }
    static activeHoverHwnd := 0
    static activeGradHwnd := 0 
    
    if (!hMain)
        hMain := MainGui.Hwnd
        
    if (!hChild && IsSet(ChildGui))
        hChild := ChildGui.Hwnd
    
    oldMode := A_CoordModeMouse
    CoordMode("Mouse", "Screen")
    MouseGetPos(&screenX, &screenY, &mouseWin, &mouseCtrl, 2)
    CoordMode("Mouse", oldMode)
    
    try {
        WinGetPos(&mX, &mY,,, "ahk_id " hMain)
        mouseX := screenX - mX
        mouseY := screenY - mY
    } catch {
        mouseX := 0
        mouseY := 0
    }
    
    if (mouseWin != hMain && mouseWin != hChild) {
        Loop HoverTab.Length {
            if (hoverTabs[A_Index]) {
                HoverTab[A_Index].Visible := false
                if (CurrentTab != "Tab" A_Index)
                    TabCtrl[A_Index].SetFont("c888888")
                hoverTabs[A_Index] := false
            }
        }
        if (hoverClose) { 
            BtnClose.SetFont("cFFFFFF")
            hoverClose := false 
        }
        if (hoverMin) { 
            BtnMin.SetFont("cFFFFFF")
            hoverMin := false 
        }
        
        if (activeHoverHwnd != 0 && IsSet(HoverEffect_btns)) {
            for ctrl in HoverEffect_btns {
                if (ctrl.Hwnd = activeHoverHwnd) {
                    ctrl.Opt("Background0E0E0F")
                    ctrl.SetFont("cFFFFFF Norm")
                    ctrl.Redraw()
                    break
                }
            }
            activeHoverHwnd := 0
        }
        
        if (activeGradHwnd != 0 && IsSet(GradientButtons)) {
            for ctrl in GradientButtons {
                if (ctrl.Hwnd = activeGradHwnd) {
                    if (HasProp(ctrl, "PicControl"))
                        ctrl.PicControl.Value := "HBITMAP:*" ctrl.ImgNormal
                    ctrl.Redraw()
                    break
                }
            }
            activeGradHwnd := 0
        }
        return
    }
    
    if (!hClose) {
        hClose := BtnClose.Hwnd
        hMin := BtnMin.Hwnd
    }
    
    if (mouseCtrl = hClose) {
        if (!hoverClose) { 
            BtnClose.SetFont("cFF4D4D")
            hoverClose := true 
        }
    } else if (hoverClose) { 
        BtnClose.SetFont("cFFFFFF")
        hoverClose := false 
    }

    if (mouseCtrl = hMin) {
        if (!hoverMin) { 
            BtnMin.SetFont("c3A86FF")
            hoverMin := true 
        }
    } else if (hoverMin) { 
        BtnMin.SetFont("cFFFFFF")
        hoverMin := false 
    }
    
    Loop HoverTab.Length {
        hTab := TabCtrl[A_Index].Hwnd
        if (mouseCtrl = hTab) {
            if (!hoverTabs[A_Index]) {
                HoverTab[A_Index].Visible := true
                TabCtrl[A_Index].SetFont("cFFFFFF")
                hoverTabs[A_Index] := true
            }
        } else if (hoverTabs[A_Index]) {
            if (CurrentTab != "Tab" A_Index) {
                HoverTab[A_Index].Visible := false
                TabCtrl[A_Index].SetFont("c888888")
            } else {
                HoverTab[A_Index].Visible := false
            }
            hoverTabs[A_Index] := false
        }
    }

    if (IsSet(HoverEffect_btns)) {
        matchedAny := false
        for ctrl in HoverEffect_btns {
            if (!ctrl.Visible)
                continue
            ctrl.GetPos(&cX, &cY, &cW, &cH)
            if (mouseX >= cX && mouseX <= cX + cW && mouseY >= cY && mouseY <= cY + cH) {
                matchedAny := true
                if (activeHoverHwnd != ctrl.Hwnd) {
                    if (activeHoverHwnd != 0) {
                        for oldCtrl in HoverEffect_btns {
                            if (oldCtrl.Hwnd = activeHoverHwnd) {
                                oldCtrl.Opt("Background0E0E0F")
                                oldCtrl.SetFont("cFFFFFF Norm")
                                oldCtrl.Redraw()
                                break
                            }
                        }
                    }
                    ctrl.Opt("Background222222")
                    ctrl.SetFont("c3A86FF Bold")
                    ctrl.Redraw()
                    activeHoverHwnd := ctrl.Hwnd
                }
                break
            }
        }
        if (!matchedAny && activeHoverHwnd != 0) {
            for ctrl in HoverEffect_btns {
                if (ctrl.Hwnd = activeHoverHwnd) {
                    ctrl.Opt("Background0E0E0F")
                    ctrl.SetFont("cFFFFFF Norm")
                    ctrl.Redraw()
                    break
                }
            }
            activeHoverHwnd := 0
        }
    }

    
    if (IsSet(GradientButtons) && hChild) {
        matchedGrad := false
        
        try {
            WinGetPos(&chX, &chY,,, "ahk_id " hChild)
            childMouseX := screenX - chX
            childMouseY := screenY - chY
        } catch {
            childMouseX := 0
            childMouseY := 0
        }
        
        for ctrl in GradientButtons {
            if (!ctrl.Visible)
                continue

            ctrl.GetPos(&cX, &cY, &cW, &cH)
            
            if (childMouseX >= cX && childMouseX <= cX + cW && childMouseY >= cY && childMouseY <= cY + cH) {
                matchedGrad := true
                if (activeGradHwnd != ctrl.Hwnd) {
                    
                    if (activeGradHwnd != 0) {
                        for oldCtrl in GradientButtons {
                            if (oldCtrl.Hwnd = activeGradHwnd) {
                                if (HasProp(oldCtrl, "PicControl"))
                                    oldCtrl.PicControl.Value := "HBITMAP:*" oldCtrl.ImgNormal
                                oldCtrl.Redraw()
                                break
                            }
                        }
                    }
                    
                    if (HasProp(ctrl, "PicControl")) {
                        ctrl.PicControl.Value := "HBITMAP:*" ctrl.ImgHover
                    }
                    ctrl.Redraw()
                    activeGradHwnd := ctrl.Hwnd
                }
                break
            }
        }
         
        if (!matchedGrad && activeGradHwnd != 0) {
            for ctrl in GradientButtons {
                if (ctrl.Hwnd = activeGradHwnd) {
                    if (HasProp(ctrl, "PicControl"))
                        ctrl.PicControl.Value := "HBITMAP:*" ctrl.ImgNormal
                    ctrl.Redraw()
                    break
                }
            }
            activeGradHwnd := 0
        }
    }
}

HideAllTabContent() {
    global ChildGui, MainGui, SystemHwnds
    for hwnd, ctrl in MainGui {
        if (SystemHwnds.Has(hwnd))
            continue

        try {
            ctrl.Visible := false
        }
    }
    ChildGui.Hide()
}

ShowTabContent(tab) {
    global ChildGui
    if (tab = "Tab1") {
        for ctrl in [Tab1_Section1, Tab1_Line1, Tab1_Lbl1, Strategy1Ctrl, Tab1_Btn1, Tab1_Btn2,
                     Tab1_Lbl2, Strategy2Ctrl, Tab1_Btn3, Tab1_Btn4, RotateStrategiesCtrl, AutoEquipCtrl, Tab1_Section2, Tab1_Line2,
                     Tab1_Start, Tab1_Stop]
            ctrl.Visible := true
        EnableStratRotation()
        ShowChildGui()
    } else if (tab = "Tab2") {
        for ctrl in [Tab2_Title, Tab2_Line1, Tab2_Lbl1, RecMapCtrl, Tab2_Lbl2, RecDiffCtrl,
                     Tab2_Lbl3, RecModifiersCtrl, Tab2_Info2, Tab2_Lbl4, RecTowersCtrl, Tab2_Info1,
                     Tab2_Line2, Tab2_Line3, RecAutoChainCtrl, RecAutoCaravanCtrl, RecAutoDropCtrl,
                     RecAutoSkipCtrl, RecAbilitySpamCtrl, Tab2_Info, RecMoveCtrl, DIRECTIONTEXTCtrl, RecMoveDirCtrl,
                     Tab2_Txt4, RecMoveDurCtrl, Tab2_Btn1, Tab2_Btn2]
            ctrl.Visible := true
    } else if (tab = "Tab3") {
        Tab3_Content.Visible := true
    } else if (tab = "Tab4") {
        for ctrl in [Tab4_Title, Tab4_Line1, Tab4_Lbl1, WebhookLinkCtrl, WebhookEnabledCtrl,
                     Tab4_Line2, SendCurrCtrl, Tab4_Info, Tab4_Btn1, Tab4_Btn2, DebugLogsCtrl, WebhookScreenshotsCtrl, WebhookTriumphScreenshotsCtrl, WebhookSepatateTriumphScreenshotsCtrl]
            ctrl.Visible := true
        EnableWebhookLink2()
} else if (tab = "Tab5") {
        for ctrl in [Tab5_Section1, Tab5_Line1, Tab5_Lbl1, ChainKeyCtrl,
                     Tab5_Lbl2, BeatKeyCtrl, Tab5_Lbl3, CaravanKeyCtrl,
                     Tab5_Lbl44, RaiseDeadKeyCtrl, Tab5_Lbl55, HologramKeyCtrl,
                     Tab5_Lbl99, Tab5_LblUPG, Tab5_LblUPGBTM, CancelPlacementKeyCtrl, UpgradeTowerGCtrl, UpgradeTowerGBCtrl, Tab1_Lbl3, TimeScaleModeCtrl,
                     Tab5_Section2, Tab5_Line2, Tab5_Help6,
                     UseRestartBtnCtrl, Tab5_Help4, UsePlayAgainBtnCtrl, Tab5_Help5,
                     CheckTheMapCtrl, UseUpgradeHCtrl, Tab5_Help7, PotatoModeCtrl, DebugConsoleCtrl,
                     Tab5_Section3, Tab5_Line3, PlcTowerTEXT, UpgTowerTEXT, AlignCamTEXT,
                     DjTrackTEXT, SellTowTEXT, DelRecTEXT, RecInputsTEXT,
                     HoloTEXT, RaiseDeadTEXT,
                     PlaceTowerKeyCtrl, UpgradeTowerKeyCtrl, AlignCameraKeyCtrl,
                     ChangeDJTrackKeyCtrl, SellTowerKeyCtrl, DeleteTowerRecordingKeyCtrl,
                     RecordInputsKeyCtrl, HoloKeyCtrl, UseRaiseDeadKeyCtrl,
                     CollectPlaytimeRewardsCtrl,
                     Tab5_Line4, Tab5_Lbl4, VipLinkCtrl, UseVipServerCtrl, AlwaysOnTopCtrl, Tab5_Btn1,
                     MouseSpeedLbl, MouseSpeedTxt, MouseSpeedUpDown,
                     MouseDelayLbl, MouseDelayTxt, MouseDelayUpDown, KeyDelayLbl, KeyDelayTxt, KeyDelayUpDown]
            ctrl.Visible := true

        
        ChainKeyCtrl.Value := ChainKey
        BeatKeyCtrl.Value := BeatKey
        CaravanKeyCtrl.Value := CaravanKey
        RaiseDeadKeyCtrl.Value := RaiseDeadKey     
        HologramKeyCtrl.Value := HologramKey       
        CancelPlacementKeyCtrl.Value := CancelPlacementKey
        AlignCameraKeyCtrl.Value := AlignCameraKey
        PlaceTowerKeyCtrl.Value := PlaceTowerKey
        UpgradeTowerKeyCtrl.Value := UpgradeTowerKey
        SellTowerKeyCtrl.Value := SellTowerKey
        DeleteTowerRecordingKeyCtrl.Value := DeleteTowerRecordingKey
        ChangeDJTrackKeyCtrl.Value := ChangeDJTrackKey
        RecordInputsKeyCtrl.Value := RecordInputsKey
        HoloKeyCtrl.Value := HoloKey
        UseRaiseDeadKeyCtrl.Value := UseRaiseDeadKey
        TimeScaleModeCtrl.Text := TimeScaleMode
        
        MouseSpeedUpDown.Value := DefaultMouseSpeed
        MouseSpeedTxt.Value := DefaultMouseSpeed
        MouseDelayUpDown.Value := MouseDelay
        MouseDelayTxt.Value := MouseDelay
        KeyDelayUpDown.Value := KeyDelay
        KeyDelayTxt.Value := KeyDelay

    } else if (tab = "Tab6") {
        for ctrl in [Tools_Section, Tools_Section_Line, Tools_Info, Auto_COA, Auto_Spin, Auto_Consum]
            ctrl.Visible := true
    } else if (tab = "Tab7") {
        Credit_Content.Visible := true
        version_text.Visible := true
        Divider.Visible := true
        FooterBg.Visible := true
        Credit_TITLE.Visible := true
        DiscordImg.Visible := true
        YoutubeImg.Visible := true
        githubImg.Visible := true
    }
}

ShowChildGui() {
    global ChildGui, FrameX, FrameY, FrameW, FrameH, MainGui
    ChildGui.Show("x" FrameX " y" FrameY " w" FrameW " h" FrameH)
}


MoveWindow(ctrl, *) {
    PostMessage(0xA1, 2, , , MainGui)
}
MinimizeWindow(ctrl, *) {
    MainGui.Minimize()
}
CloseWindow(ctrl, *) {
    ExitApp()
}
DiscordLink(ctrl, *) {
    Run("https://discord.gg/DQnc2JDJtr")
}
githubLink(ctrl, *) {
    Run("https://github.com/DarksenDev/tds-macro")
}
YouTubeLink(ctrl, *) {
    Run("https://www.youtube.com/@darksenn")
}

DownloadStrat(ctrl, *) {
    nm := ctrl.StratFile 
    
    downloadedStrat := A_WorkingDir "\Resources\Strats" (SubStr(nm, 1, 1) = "\" ? nm : "\" nm)

    if (Strategy1Ctrl.Value = "") {
    Strategy1Ctrl.Value := downloadedStrat
    Strategy1Path := downloadedStrat
    IniWrite(downloadedStrat, SettingsFile, "Options", "Strategy1")
    } else if (Strategy2Ctrl.Value = "" && Strategy2Ctrl.Visible) {
        Strategy2Ctrl.Value := downloadedStrat
        Strategy2Path := downloadedStrat
        IniWrite(downloadedStrat, SettingsFile, "Options", "Strategy2")
    } else {
        Strategy1Ctrl.Value := downloadedStrat
        Strategy1Path := downloadedStrat
        IniWrite(downloadedStrat, SettingsFile, "Options", "Strategy1")
    }
    
    LoadStrategyFile(downloadedStrat)
}


OnMouseWheel(wp, lp, msg, hwnd) {
    global ChildGui, FrameX, FrameY, FrameW, FrameH
    MouseGetPos(&mx, &my, &winUnderCursor, &ctrlUnderCursor, 2)

    ch := ChildGui.Hwnd
    parentH := (ctrlUnderCursor != "") ? DllCall("GetParent", "Ptr", ctrlUnderCursor, "Ptr") : 0

    ; Keep the community strategy panel anchored unless the wheel is used directly over it.
    if (mx < FrameX || mx > FrameX + FrameW || my < FrameY || my > FrameY + FrameH)
        return

    if (winUnderCursor = ch || ctrlUnderCursor = ch || parentH = ch) {
        dir := ((wp >> 16) & 0xFFFF) > 0x7FFF ? 1 : 0
        Loop 3
            SendMessage(0x0115, dir, 0, , "ahk_id " ch)
    }
}


GetCommunitySliderY(scrollPos) {
    global ContentH, FrameH, SliderH
    maxScroll := ContentH - FrameH
    availableTrackSpace := FrameH - SliderH

    if (maxScroll <= 0 || availableTrackSpace <= 0)
        return 0

    return Round((scrollPos / maxScroll) * availableTrackSpace)
}


UpdateCommunityScroll(newPos) {
    global ChildGui, CurrentScrollPos, ContentH, FrameH, SliderH, CustomSlider

    ch := ChildGui.Hwnd
    maxScroll := ContentH - FrameH
    if (maxScroll <= 0)
        return false

    newPos := Max(0, Min(newPos, maxScroll))
    if (newPos = CurrentScrollPos)
        return false

    DllCall("ScrollWindow", "Ptr", ch, "Int", 0, "Int", CurrentScrollPos - newPos, "Ptr", 0, "Ptr", 0)
    CurrentScrollPos := newPos

    sliderVisualY := GetCommunitySliderY(newPos)
    CustomSlider.Move(, sliderVisualY)

    DllCall("UpdateWindow", "Ptr", ch)
    return true
}


StartCommunityScrollDrag() {
    global FrameX, FrameY, FrameW, FrameH, SliderX, SliderW, SliderH
    global CurrentScrollPos, ContentH, ScrollThumbDragging, ScrollThumbGrabOffset, ChildGui, CurrentTab

    if (CurrentTab != "Tab1" || !DllCall("IsWindowVisible", "Ptr", ChildGui.Hwnd, "Int") || ContentH <= FrameH)
        return false

    MouseGetPos(&mx, &my)

    absSliderX := FrameX + SliderX
    absSliderY := FrameY + GetCommunitySliderY(CurrentScrollPos)

    if (mx < absSliderX || mx > absSliderX + SliderW || my < FrameY || my > FrameY + FrameH)
        return false

    if (my >= absSliderY && my <= absSliderY + SliderH) {
        ScrollThumbGrabOffset := my - absSliderY
    } else {
        ScrollThumbGrabOffset := Round(SliderH / 2)
    }

    ScrollThumbDragging := true
    SetTimer(TrackCommunityScrollDrag, 10)
    TrackCommunityScrollDrag()
    return true
}


TrackCommunityScrollDrag(*) {
    global FrameY, FrameH, SliderH, ContentH, ScrollThumbDragging, ScrollThumbGrabOffset, ChildGui, CurrentTab

    if (!ScrollThumbDragging || CurrentTab != "Tab1" || !DllCall("IsWindowVisible", "Ptr", ChildGui.Hwnd, "Int"))
        return

    if !GetKeyState("LButton", "P") {
        ScrollThumbDragging := false
        SetTimer(TrackCommunityScrollDrag, 0)
        return
    }

    maxScroll := ContentH - FrameH
    availableTrackSpace := FrameH - SliderH
    if (maxScroll <= 0 || availableTrackSpace <= 0) {
        ScrollThumbDragging := false
        SetTimer(TrackCommunityScrollDrag, 0)
        return
    }

    MouseGetPos(&mx, &my)
    newSliderY := my - FrameY - ScrollThumbGrabOffset
    newSliderY := Max(0, Min(newSliderY, availableTrackSpace))

    newPos := Round((newSliderY / availableTrackSpace) * maxScroll)
    UpdateCommunityScroll(newPos)
}


OnScroll(wp, lp, msg, hwnd) {
    global ChildGui
    ch := ChildGui.Hwnd
    if (hwnd != ch)
        return
    action := wp & 0xFFFF
    if (action = 0) {
        newPos := CurrentScrollPos - 3
    } else if (action = 1) {
        newPos := CurrentScrollPos + 3
    } else {
        return
    }
    UpdateCommunityScroll(newPos)
}

EnableStratRotation(*) {
    global RotateStrategies, SwapAmount, SwapUnit
    
    v := MainGui.Submit(false)
    RotateStrategies := v.RotateStrategies
    IniWrite(RotateStrategies, SettingsFile, "Options", "RotateStrategies")
    
    show := (RotateStrategies = 1)

    Tab1_Lbl2.Visible := show
    Strategy2Ctrl.Visible := show
    Tab1_Btn3.Visible := show
    Tab1_Btn4.Visible := show

    SwapAfterLbl.Visible := show
    SwapAmountCtrl.Visible := show
    SwapUnitCtrl.Visible := show

    AutoEquipCtrl.Enabled := !show

    if (show) {
        AutoEquipCtrl.Value := 1
        v := MainGui.Submit(false)
        AutoEquip := v.AutoEquip
        IniWrite(AutoEquip, SettingsFile, "Options", "AutoEquip")
        SwapAmount := SwapAmountCtrl.Text
        SwapUnit := SwapUnitCtrl.Text
        AutoEquipCtrl.Move(357, 190)
        IniWrite(SwapAmount, SettingsFile, "Options", "SwapAmount")
        IniWrite(SwapUnit, SettingsFile, "Options", "SwapUnit")
    } else {
        AutoEquipCtrl.Move(155, 190)
    }
}

EnableAutoEquip(*) {
    global AutoEquip
    
    v := MainGui.Submit(false)
    AutoEquip := v.AutoEquip
    IniWrite(AutoEquip, SettingsFile, "Options", "AutoEquip")
}

SelectStrat1(ctrl, *) {
    global Strategy1Path
    targDir := RecordingsDir
    if (Strategy1Ctrl.Value) {
        SplitPath(Strategy1Ctrl.Value, , &parentDir) 
        targDir := parentDir
    }
    f := FileSelect("3", targDir, "Select strategy file 1", "Strategy (*.strat)")
    if (f != "") {
        Strategy1Ctrl.Value := f
        Strategy1Path := f
        IniWrite(f, SettingsFile, "Options", "Strategy1")
        LoadStrategyFile(f)
    }
}
SelectStrat2(ctrl, *) {
    global Strategy2Path
    targDir := RecordingsDir
    if (Strategy2Ctrl.Value) {
        SplitPath(Strategy2Ctrl.Value, , &parentDir) 
        targDir := parentDir
    }
    f := FileSelect("3", targDir, "Select strategy file 2", "Strategy (*.strat)")
    if (f != "") {
        Strategy2Ctrl.Value := f
        Strategy2Path := f
        IniWrite(f, SettingsFile, "Options", "Strategy2")
    }
}
ClearStrat1(ctrl, *) {
    global Strategy1Path
    Strategy1Ctrl.Value := ""
    Strategy1Path := ""
    IniWrite(" ", SettingsFile, "Options", "Strategy1")
}
ClearStrat2(ctrl, *) {
    global Strategy2Path
    Strategy2Ctrl.Value := ""
    Strategy2Path := ""
    IniWrite(" ", SettingsFile, "Options", "Strategy2")
}
SaveStrat1(ctrl, *) {
    global Strategy1Path, Strategy1Ctrl
    Strategy1Path := Strategy1Ctrl.Text
    IniWrite(Strategy1Ctrl.Text, SettingsFile, "Options", "Strategy1")
}

SaveStrat2(ctrl, *) {
    global Strategy2Path, Strategy2Ctrl
    Strategy2Path := Strategy2Ctrl.Text
    IniWrite(Strategy2Ctrl.Text, SettingsFile, "Options", "Strategy2")
}


StartStrategy(ctrl, *) {
    if (RunningStrategy or Recording) {
        return
    }
    g_IsFirstLaunch := Integer(IniRead(StateFile, "State", "IsFirstLaunch", 1))

    global RunningStrategy, CurrentRotationIndex, gamemap, difficulty, requiredTowers, modifiers
    global autoChain, autoCaravan, autoDropTheBeat, AutoSkip, AbilitySpam, MoveEnabled, MoveDirection, MoveDuration
    global AutorunStartTime, CurrentStratStartTime

    v := MainGui.Submit(false)
    IniWrite(v.Strategy1, SettingsFile, "Options", "Strategy1")
    IniWrite(v.Strategy2, SettingsFile, "Options", "Strategy2")

    if (v.RotateStrategies = 1) {
        s1 := Trim(v.Strategy1)
        s2 := Trim(v.Strategy2)

        for num, s in [s1, s2] {
            if (s == "" || !FileExist(s)) {
                ModernMsgBox("Warning", "Rotation mode is enabled but strategy " num " is empty or file doesn't exist!`nPlease select a valid file for Strategy " num "!", "OK", "WARNING")
                return
            }
        }
    }

    stratFile := ""
    s1 := v.Strategy1, s2 := v.Strategy2

    if (v.RotateStrategies = 1 && s2 != "") {
        if (s1 != "" && FileExist(s1)) {
            stratFile := s1
            CurrentRotationIndex := 1
        }
    } else {
        if (s1 != "" && FileExist(s1))
            stratFile := s1
        else if (s2 != "" && FileExist(s2))
            stratFile := s2
    }

    if (stratFile = "") {
        ModernMsgBox("Warning", "No valid strategy file selected!", "OK", "WARNING")
        return
    }

    if (g_IsFirstLaunch = 1) {
        IniWrite(0, StateFile, "State", "IsFirstLaunch")
        MsgBox("Since you are starting the macro for the first time... Read this so your macro can work properly:`n`n1. Go to the TDS Settings and ENABLE 'Prefer Vertical Upgrades`n2. Go to the TDS Settings and set UI Scale to 'LARGE'`n3. Set your Roblox Camera Mode to Classic`n4. If your Roblox graphics are automatic, set them to manual.`n5. Turn off camera shake in TDS.`n6. Disable Dialog in TDS`n7. Enable UI Navigation toggle in the Roblox settings.`n`nRecommended screen resolution for this macro is 1920x1080. This macro requires a good CPU. You can use it though if your device is bad, enable potato mode and make the delays bigger.`nYou can join my Discord server to get help and check the FAQ.","READ THIS!!", 0x1030)
    }

    IniDelete(StateFile, "State", "Coins")
    IniDelete(StateFile, "State", "Gems")
    IniDelete(StateFile, "State", "EXP")
    IniDelete(StateFile, "State", "TotalTriumphs")
    IniDelete(StateFile, "State", "TotalLosses")
    IniDelete(StateFile, "State", "TotalTimeSeconds")
    IniDelete(StateFile, "State", "Timescale")
    IniDelete(StateFile, "State", "CurrentStratStartTime")
    IniDelete(StateFile, "State", "CurrentRotationIndex")
    IniDelete(StateFile, "State", "CurrentRunCount")
    IniDelete(StateFile, "State", "StartTime")
    AutorunStartTime := 0

    LoadStrategyFile(stratFile)

    if (requiredTowers != "")
        ModernMsgBox("Required Towers", requiredTowers, "OK")

    IniWrite(1, StateFile, "State", "Running")
    IniWrite(stratFile, StateFile, "State", "Strategy")

    MainGui.Hide()
    RunningStrategy := true

    time := FormatTime(, "HH:mm:ss")
    SplitPath(stratFile, &fileName)
    startInfo := "[" time "] Started strategy: " fileName "`n"
    startInfo .= "Map = " gamemap "`nMode = " difficulty "`nTimescale = " TimeScaleMode "`nRequired Towers: " requiredTowers
    if (modifiers != "")
        startInfo .= "`nModifiers: " modifiers
    SendToWebhookInstant(startInfo,, flush := false)

    CheckOcrLanguage()

    MultiInstanceTools := "RobloxAccountManager.exe,Roblox Account Manager.exe,RAM.exe,RobloxMulti.exe,MultiRoblox.exe,MultipleRoblox.exe,Multiple Roblox.exe"
    Loop Parse, MultiInstanceTools, "," {
        if ProcessExist(A_LoopField) {
            MsgBox("Conflicting program detected:`n" A_LoopField "`n`nFor this script to work properly, please close all Roblox multi-client utilities.`nPlease close them and try again.", "Error", 0x1030)
            ExitApp()
        }
    }

    CurrentStratStartTime := A_TickCount
    IniWrite(A_TickCount, StateFile, "State", "CurrentStratStartTime")
    CurrentRunCount := 0
    IniWrite(0, StateFile, "State", "CurrentRunCount")

    RunStrategy("", true, AutoEquip)
}

StopStrategy(ctrl, *) {
    global RunningStrategy, AutorunStartTime, Recording, MacroRecording, InputHookObj

    KillSubmacros()

    if (RunningStrategy) {
        if (AutorunStartTime > 0) {
            runtime := FormatRuntime(AutorunStartTime)
            Coins := IniRead(StateFile, "State", "Coins", "0")
            Gems  := IniRead(StateFile, "State", "Gems",  "0")
            Timescales  := IniRead(StateFile, "State", "Timescale",  "0")
            LogToConsole("Strategy stopped. Runtime: " runtime)
            time := FormatTime(, "HH:mm:ss")
            SendToWebhookInstant("[" time "] Strategy stopped. Runtime: " runtime)
            IniDelete(StateFile, "State", "StartTime")
            AutorunStartTime := 0
        }
        DeleteAllIndicators()
        IniWrite(0, StateFile, "State", "Running")
        IniWrite(0, StateFile, "State", "Strategy")
        IniDelete(StateFile, "State", "Coins")
        IniDelete(StateFile, "State", "Gems")
        IniDelete(StateFile, "State", "EXP")
        IniDelete(StateFile, "State", "TotalTriumphs")
        IniDelete(StateFile, "State", "TotalLosses")
        IniDelete(StateFile, "State", "TotalTimeSeconds")
        IniDelete(StateFile, "State", "Timescale")
        IniDelete(StateFile, "State", "CurrentStratStartTime")
        IniDelete(StateFile, "State", "CurrentRotationIndex")
        IniDelete(StateFile, "State", "CurrentRunCount")
        RunningStrategy := false
        SafeReload()
    }

    if (Recording) {
        StopRecord(0)
    }
}

StartRecording(ctrl, *) {
    global Recording, gamemap, difficulty, requiredTowers, modifiers, autoChain, autoCaravan
    global autoDropTheBeat, AutoSkip, AbilitySpam, MoveEnabled, MoveDirection, MoveDuration
    global Commander, RecordedSteps, Towers, MacroRecording, GuiTitleCtrl
    global Tab2_Btn1, Tab2_Btn2, HoverEffect_btns

    if (Recording)
        return

    v := MainGui.Submit(false)

    if (!v.RecMap or !v.RecDifficulty or !v.RecRequiredTowers) {
        MsgBox("Failed to start recording!`nMake sure you have entered the towers, the map, and the difficulty, then try again.", "Error", 0x1010)
        return
    }

    if (A_ScreenWidth != 1920 || A_ScreenHeight != 1080) {
        if (MsgBox("Your screen resolution is not 1920x1080.`nThe recording system is highly recommended for 1920x1080. Do you want to continue?", "Warning", 0x1034) = "No") {
            return
        }
    }

    if (IsSet(GuiTitleCtrl) && GuiTitleCtrl) {
        GuiTitleCtrl.SetFont("cff6b6b")
    }

    if (IsSet(Tab2_Btn1) && Tab2_Btn1) {
        Tab2_Btn1.SetFont("c808080 norm")
        Tab2_Btn1.Opt("Background0e0e0f")
        if (IsSet(HoverEffect_btns) && IsObject(HoverEffect_btns)) {
            for index, element in HoverEffect_btns {
                if (element = Tab2_Btn1) {
                    HoverEffect_btns.RemoveAt(index)
                    break
                }
            }
        }
    }

    if (IsSet(Tab2_Btn2) && Tab2_Btn2) {
        Tab2_Btn2.SetFont("cWhite norm")
        if (IsSet(HoverEffect_btns) && IsObject(HoverEffect_btns)) {
            hasElement := false
            for element in HoverEffect_btns {
                if (element = Tab2_Btn2) {
                    hasElement := true
                    break
                }
            }
            if (!hasElement) {
                HoverEffect_btns.Push(Tab2_Btn2)
            }
        }
    }

    gamemap := v.RecMap
    difficulty := v.RecDifficulty
    requiredTowers := v.RecRequiredTowers
    modifiers := v.RecModifiers
    autoChain := v.RecAutoChain ? "ON" : "OFF"
    autoCaravan := v.RecAutoCaravan ? "ON" : "OFF"
    autoDropTheBeat := v.RecAutoDropTheBeat ? "ON" : "OFF"
    AutoSkip := v.RecAutoSkip ? "ON" : "OFF"
    AbilitySpam := v.RecAbilitySpam ? "ON" : "OFF"
    MoveEnabled := v.RecMoveEnabled ? true : false
    MoveDirection := v.RecMoveDirection
    MoveDuration := IsNumber(v.RecMoveDuration) ? Integer(v.RecMoveDuration) : 750

    Commander := false
    Recording := true
    RecordedSteps := []
    Towers := Map()
    DeleteAllIndicators()

    LogToConsole("Recording started.")
    
    ActivateRoblox()
}

StopRecord(ctrl, *) {
    global Recording, MacroRecording, InputHookObj, MacroSteps, RecordedSteps
    global gamemap, difficulty, requiredTowers, modifiers
    global autoChain, autoCaravan, autoDropTheBeat, AutoSkip, AbilitySpam, MoveEnabled, MoveDirection, MoveDuration
    global GuiTitleCtrl, Strategy1Ctrl, RecordingsDir
    global Tab2_Btn1, Tab2_Btn2, HoverEffect_btns

    if (MacroRecording) {
        MacroRecording := false
        if (InputHookObj != "")
            InputHookObj.Stop()
        LogToConsole("Macro recording auto-stopped")
        if (ModernMsgBox("Add to Strategy?", "Add recorded actions to current strategy?", "YES|NO") = "YES") {
            for i, step in MacroSteps
                RecordedSteps.Push(step)
            LogToConsole("Added " MacroSteps.Length " macro steps to strategy")
        }
    }

    if (!Recording)
        return
    Recording := false
    DeleteAllIndicators()

    if (IsSet(GuiTitleCtrl) && GuiTitleCtrl) {
        GuiTitleCtrl.SetFont("cWhite")
    }

    if (IsSet(Tab2_Btn1) && Tab2_Btn1) {
        Tab2_Btn1.SetFont("cWhite norm")
        if (IsSet(HoverEffect_btns) && IsObject(HoverEffect_btns)) {
            hasElement := false
            for element in HoverEffect_btns {
                if (element = Tab2_Btn1) {
                    hasElement := true
                    break
                }
            }
            if (!hasElement) {
                HoverEffect_btns.Push(Tab2_Btn1)
            }
        }
    }

    if (IsSet(Tab2_Btn2) && Tab2_Btn2) {
        Tab2_Btn2.SetFont("c808080 norm")
        Tab2_Btn2.Opt("Background0e0e0f")
        if (IsSet(HoverEffect_btns) && IsObject(HoverEffect_btns)) {
            for index, element in HoverEffect_btns {
                if (element = Tab2_Btn2) {
                    HoverEffect_btns.RemoveAt(index)
                    break
                }
            }
        }
    }

    if (ModernMsgBox("Save", "Save the recorded strategy?", "YES|NO") = "YES") {
        box := InputBox("File name (without .strat):", "Save", "w300 h130", "MyStrategy")
        if (box.Result = "Cancel")
            return
        filePath := RecordingsDir "\" box.Value ".strat"
        if FileExist(filePath)
            FileDelete(filePath)
        getRobloxPos(&pX, &pY, &currentWidth, &currentHeight)

        Join(arr, delim := ", ") {
            if !IsObject(arr)
                return String(arr)

            str := ""
            for index, value in arr
                str .= (index = 1 ? "" : delim) . value
            return str
        }

        FileAppend("[Settings]`nmap=" gamemap "`ndifficulty=" difficulty "`nrequiredTowers=" requiredTowers
            . "`nmodifiers=" Join(modifiers)
            . "`nautoChain=" autoChain "`nautoCaravan=" autoCaravan "`nautoDropTheBeat=" autoDropTheBeat
            . "`nautoSkip=" AutoSkip "`nabilitySpam=" AbilitySpam "`nmoveEnabled=" MoveEnabled "`nmoveDirection=" MoveDirection
            . "`nmoveDuration=" MoveDuration "`n`n[DO NOT EDIT]`nwidth=" currentWidth "`nheight=" currentHeight "`n`n[Steps]`n", filePath)
        for i, step in RecordedSteps
            FileAppend(step "`n", filePath)
        LogToConsole("Strategy saved: " filePath)
        Strategy1Ctrl.Value := filePath
    } else {
        LogToConsole("Recording cancelled, strategy not saved")
    }
}

PlaceTowerHK(*) {
    global Recording, Towers, RecordedSteps, ActiveUpgradeTowerID, CachedMenuUI, isUiPositionSaved

    if (!Recording) {
        pureKey := RegExReplace(PlaceTowerKey, "[\^+!#]") 
        SEND_modifiers := RegExMatch(PlaceTowerKey, "^([\^+!#]+)", &match) ? match[1] : ""
        
        SendEvent("{Blind}" SEND_modifiers "{" pureKey "}")
        return
    }
    
    towersStringBackup := Towers 

    MouseGetPos(&mx, &my)
    loop {
        slotBox := InputBox("Enter the tower slot number (1-5):", "Slot (1-5)", "w300 h130", "1")

        if (slotBox.Result = "Cancel")
            return

        try {
            sllot := Integer(slotBox.Value)
            
            if (sllot >= 1 && sllot <= 5) {
                break
            } else {
                continue
            }
        } 
        catch Error {
            continue
        }
    }
    slot := slotBox.Value
    
    suggestedID := GetNextTowerID(slot)
    
    idBox := InputBox("Enter a specific tower id:", "Tower ID", "w300 h130", suggestedID)
    if (idBox.Result = "Cancel")
        return
    towerID := idBox.Value
    ActivateRoblox()

    LogToConsole("Recording: placing tower " towerID " (slot " slot ") at x:" mx " y:" my "...")


    getRobloxPos(,,&w,&h)

    ActivateRoblox()
    
    Send("{" slot "}")
    Sleep(30)
    

    MouseMove(mx, my, A_DefaultMouseSpeed)
    Sleep((PotatoMode = 1) ? 100 : 40)
    Click()
    Sleep(100)
    SendEvent("{" CancelPlacementKey "}")

    Towers[towerID] := {x: mx, y: my, slot: slot, level: 0, path: 0, pathLevel: 0}
    UpdateTowerIndicator(towerID)
    LogToConsole("Recorded tower " towerID " (slot " slot ")")

    RecordedSteps.Push("SpawnTower(" mx ", " my ", " slot ", " towerID ")")

    LogToConsole(towerID)

    if (towerID = "" || RegExMatch(towerID, "i)(Juggernaut|Hacker|Pursuit|Kingpin)")) {
        ShowTowerPathDialog(towerID)
    }

    ActiveUpgradeTowerID := towerID
    
    openedSuccessfully := false
    Loop 10 {
        getRobloxPos(,,&w,&h)
        resV2 := AdvImageSearch("Resources\TowerUI\Variant2.png", 0, Round(h / 2), Round(w * 0.3), Round(h * 0.9) - Round(h / 2), 0.5, 1.5)
        
        if (resV2.status == "success" && resV2.score > 0.6) {
            
            if (!isUiPositionSaved) {
                Sleep(300) 
                
                getRobloxPos(,,&w,&h)
                resV2Final := AdvImageSearch("Resources\TowerUI\Variant2.png", 0, Round(h / 2), Round(w * 0.3), Round(h * 0.9) - Round(h / 2), 0.5, 1.5)
                
                if (resV2Final.status == "success") {
                    CachedMenuUI := {x: resV2Final.x, y: resV2Final.y}
                    isUiPositionSaved := true 
                    openedSuccessfully := true
                } else {
                    CachedMenuUI := {x: resV2.x, y: resV2.y}
                    isUiPositionSaved := true
                    openedSuccessfully := true
                }
            } 
            else {
                openedSuccessfully := true
            }
            break
        }
        Sleep(150)
    }
    
    if (!openedSuccessfully) {
        ActiveUpgradeTowerID := ""
    }
}


UpgradeTowerHK(*) {
    global Recording, Towers, RecordedSteps, Commander
    if (!Recording) {
        pureKey := RegExReplace(UpgradeTowerKey, "[\^+!#]") 
        SEND_modifiers := RegExMatch(UpgradeTowerKey, "^([\^+!#]+)", &match) ? match[1] : ""
        
        SendEvent("{Blind}" SEND_modifiers "{" pureKey "}")
        return
    }

    MouseGetPos(&mx, &my)

    closestID := ""
    for id, t in Towers {
        ix1 := t.x - 12
        iy1 := t.y - 12
        ix2 := ix1 + 24
        iy2 := iy1 + 24
        
        if (mx >= ix1 && mx <= ix2 && my >= iy1 && my <= iy2) {
            closestID := id
            break
        }
    }

    if (closestID != "") {
        Towers[closestID].level += 1
        UpdateTowerIndicator(closestID)
        if (Towers[closestID].path != 0 && Towers[closestID].path != "") {
            RecordedSteps.Push("UpgradeTower(" closestID ", false, 1, " Towers[closestID].path ", " Towers[closestID].pathLevel ")")
        } else {
            RecordedSteps.Push("UpgradeTower(" closestID ")")
        }
        if (Towers[closestID].level >= 2 && RegExMatch(closestID, "i)^Commander\d*$") && !Commander) {
            Commander := true
            if (!HasStep("Commander := true"))
                RecordedSteps.Push("Commander := true")
        }
    }
}

ChangeDJTrackHK(*) {
    global Recording, RecordedSteps
    if (!Recording) {
        pureKey := RegExReplace(ChangeDJTrackKey, "[\^+!#]") 
        SEND_modifiers := RegExMatch(ChangeDJTrackKey, "^([\^+!#]+)", &match) ? match[1] : ""
        
        SendEvent("{Blind}" SEND_modifiers "{" pureKey "}")
        return
    }
    box := InputBox("Enter Track Color (Purple/Red/Green):", "DJ Track", "w300 h130", "Green")
    if (box.Result != "Cancel") {
        RecordedSteps.Push('SetDJTrack("' box.Value '")')
        LogToConsole("Recorded DJ-track " box.Value)
    }
}

DeleteTowerRecordingHK(*) {
    global Recording, Towers, RecordedSteps
    if (!Recording) {
        pureKey := RegExReplace(DeleteTowerRecordingKey, "[\^+!#]") 
        SEND_modifiers := RegExMatch(DeleteTowerRecordingKey, "^([\^+!#]+)", &match) ? match[1] : ""
        
        SendEvent("{Blind}" SEND_modifiers "{" pureKey "}")
        return
    }

    MouseGetPos(&mx, &my)

    closestID := ""
    for id, t in Towers {
        if (!HasProp(t, "x") || !HasProp(t, "y"))
            continue

        ix1 := t.x - 12
        iy1 := t.y - 12
        ix2 := ix1 + 24
        iy2 := iy1 + 24
        
        if (mx >= ix1 && mx <= ix2 && my >= iy1 && my <= iy2) {
            closestID := id
            break
        }
    }

    if (closestID != "") {
        if (HasProp(Towers[closestID], "hwnd") && Towers[closestID].hwnd) {
            try WinClose("ahk_id " Towers[closestID].hwnd)
        }

        newSteps := []
        
        escapedID := RegExReplace(closestID, "([\.\ \+\*\?\^\$\(\)\[\]\{\}\|])", "\$1")

        for i, step in RecordedSteps {
            if (RegExMatch(step, "i)^SpawnTower\s*\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*" escapedID "\s*\)$"))
                continue
            if (RegExMatch(step, "i)^UpgradeTower\s*\(\s*" escapedID "\s*(?:,.*)?\s*\)$"))
                continue
            if (RegExMatch(step, "i)^SellTower\s*\(\s*" escapedID "\s*\)$"))
                continue
            newSteps.Push(step)
        }
        RecordedSteps := newSteps

        try {
            if Towers.Has(closestID) {
                Towers.Delete(closestID)
            }
        } catch {
        }

        LogToConsole("Recorded sell tower " closestID)
    }
}


SellTowerHK(*) {
    global Recording, Towers, RecordedSteps
    if (!Recording) {
        pureKey := RegExReplace(SellTowerKey, "[\^+!#]") 
        SEND_modifiers := RegExMatch(SellTowerKey, "^([\^+!#]+)", &match) ? match[1] : ""
        
        SendEvent("{Blind}" SEND_modifiers "{" pureKey "}")
        return
    }

    MouseGetPos(&mx, &my)

    closestID := ""
    for id, t in Towers {
        ix1 := t.x - 12
        iy1 := t.y - 12
        ix2 := ix1 + 24
        iy2 := iy1 + 24
        
        if (mx >= ix1 && mx <= ix2 && my >= iy1 && my <= iy2) {
            closestID := id
            break
        }
    }
    if (closestID != "") {
        if (Towers[closestID].hwnd) {
            WinClose("ahk_id " Towers[closestID].hwnd)
            Towers[closestID].hwnd := ""
        }
        RecordedSteps.Push("SellTower(" closestID ")")
        SellTower(closestID)
        newSteps := []
        for i, step in RecordedSteps {
            if (RegExMatch(step, "i)^SpawnTower\s*\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*" closestID "\s*\)$"))
                continue
            if (RegExMatch(step, "i)^UpgradeTower\s*\(\s*" closestID "\s*\)$"))
                continue
            newSteps.Push(step)
        }
        RecordedSteps := newSteps
        Towers.Delete(closestID)
        LogToConsole("Recorded sell tower " closestID)
    }
}

AlignCameraHK(*) {
    if (!Recording) {
        pureKey := RegExReplace(AlignCameraKey, "[\^+!#]") 
        SEND_modifiers := RegExMatch(AlignCameraKey, "^([\^+!#]+)", &match) ? match[1] : ""
        
        SendEvent("{Blind}" SEND_modifiers "{" pureKey "}")
        return
    }

    if (InArray(SpecialMaps, gamemap)) {
        functionName := gamemap . "Path"

        %functionName%() 
    } else {
        AlignCamera()
    }
}

RecordInputsHK(*) {
    global MacroRecording, InputHookObj, MacroSteps, MacroStartTime, RecordedSteps, Recording, KeyDownTimes
    if (!Recording) {
        pureKey := RegExReplace(RecordInputsKey, "[\^+!#]") 
        SEND_modifiers := RegExMatch(RecordInputsKey, "^([\^+!#]+)", &match) ? match[1] : ""
        
        SendEvent("{Blind}" SEND_modifiers "{" pureKey "}")
        return
    }
    if (MacroRecording) {
        MacroRecording := false
        if (InputHookObj != "")
            InputHookObj.Stop()
        LogToConsole("Recording ALL clicks and keys STOPPED. Steps: " MacroSteps.Length)
        if (ModernMsgBox("Add to Strategy?", "Add recorded actions to current strategy?", "YES|NO") = "YES") {
            for i, step in MacroSteps
                RecordedSteps.Push(step)
            LogToConsole("Added " MacroSteps.Length " steps to strategy")
        }
    } else {
        LogToConsole("Recording ALL clicks and keys...!")
        MacroRecording := true
        MacroSteps     := []
        KeyDownTimes   := Map() 
        MacroStartTime := A_TickCount
        InputHookObj := InputHook("V")
        InputHookObj.KeyOpt("{All}", "N")
        InputHookObj.OnKeyDown := OnKeyDown
        InputHookObj.OnKeyUp := OnKeyUp 
        InputHookObj.Start()
    }
}

CloneTowerHK(*) {
    global Recording, RecordedSteps
    static LastCallTime := 0

    if (!Recording) {
        pureKey := RegExReplace(HoloKey, "[\^+!#]") 
        SEND_modifiers := RegExMatch(HoloKey, "^([\^+!#]+)", &match) ? match : ""
        
        SendEvent("{Blind}" SEND_modifiers "{" pureKey "}")
        return
    }

    CoordMode("Mouse", "Client")
    ActivateRoblox()
    MouseGetPos(&mx, &my)

    idBox := InputBox("Enter the tower ID to clone:", "Clone Tower", "w300 h130", "")
    if (idBox.Result = "Cancel")
        return

    towerID := Trim(idBox.Value)
    if (towerID = "") {
        return
    }

    waitTime := 0
    currentTime := A_TickCount

    if (RecordedSteps.Length > 0) {
        lastStep := RecordedSteps[RecordedSteps.Length]

        if (InStr(lastStep, "CloneTower") && LastCallTime > 0) {
            waitTime := currentTime - LastCallTime
        } 
    }

    LastCallTime := currentTime

    CloneTower(towerID, mx, my, waitTime)

    RecordedSteps.Push("CloneTower(" towerID ", " mx ", " my ", " waitTime ")")
}


ActivateRaiseTheDeadHK(*) {
    global Recording, RecordedSteps
    static LastCallTime := 0

    if (!Recording) {
        pureKey := RegExReplace(UseRaiseDeadKey, "[\^+!#]") 
        SEND_modifiers := RegExMatch(UseRaiseDeadKey, "^([\^+!#]+)", &match) ? match : ""
        
        SendEvent("{Blind}" SEND_modifiers "{" pureKey "}")
        return
    }

    waitTime := 0
    currentTime := A_TickCount

    if (RecordedSteps.Length > 0) {
        lastStep := RecordedSteps[RecordedSteps.Length]
        
        if (InStr(lastStep, "ActivateRaiseTheDead") && LastCallTime > 0) {
            waitTime := currentTime - LastCallTime
        }
    }

    LastCallTime := currentTime
    ActivateRaiseTheDead(waitTime)

    RecordedSteps.Push("ActivateRaiseTheDead(" waitTime ")")
}

CataclysmPath() {
    AlignCamera(true, false)
    Sleep(200)
    SendEvent("{i down}")
    Sleep(100)
    SendEvent("{i up}")
}


SimplicityPath() {
    attempts := 0
    Loop {
        AlignCamera(false, false)
        SendEvent("{sc01f Down}") 
        Sleep(2500)
        SendEvent("{sc01f Up}")
        Sleep(300)
        SendEvent("{sc01f Down}")
        SendEvent("{sc020 Down}")
        Sleep(4000)
        SendEvent("{sc01f Up}")
        SendEvent("{sc020 Up}")
        Sleep(300)
        Send("{sc011 Down}")
        Sleep(1300)
        Send("{sc011 Up}")
        
        Join(arr, delim := ", ") {
            if !IsObject(arr)
                return String(arr)

            str := ""
            for index, value in arr
                str .= (index = 1 ? "" : delim) . value
            return str
        }

        modifiers_str := (modifiers is Array) ? Join(modifiers) : String(modifiers)

        if (FileExist("Resources\Maps\Simplicity.png") && CheckTheMap = 1 && !RegExMatch(modifiers_str, "i)fog"))
        {
            getRobloxPos(,,&w,&h)
            FoundMap := false
            Loop 5 {
                res := AdvImageSearch("Resources\Maps\Simplicity.png", 0, 0, w, h, 0.5, 2)
                
                if (res.score > 0.65) {
                    FoundMap := true
                    LogToConsole("break " res.score )
                    break
                }
                
                Sleep(300)
            }

            if (!FoundMap) {
                if (attempts > 3)
                    SafeReload()
                LogToConsole("Can't detect the correct position! Resetting..", true)
                resetCharacter()
                Sleep(7500)
                attempts++
                continue
            }
        }
        break
    }
}


CloneTower(towerId, x, y, wait := 0) {
    global Towers, unfocusX, unfocusY, LastOpenedTowerID, CancelPlacementKey, HologramKey, Recording

    if (wait > 0 && !Recording) {
        Sleep(wait)
    }

    SendEvent("{" CancelPlacementKey "}")
    Sleep 50
    if (LastOpenedTowerID != "" || Recording) {
        Click(ScaleX(unfocusX), ScaleY(unfocusY))
        Sleep(500)
    }

    loop {
        SendEvent("{" HologramKey "}")
        Sleep 150

        getRobloxPos(,,,&h)
        Ys := Towers[towerId].y
        if (Ys < h * 0.55) {
            TowerY := Ys - ScaleY(3)
        }
        if (Ys > h * 0.45) {
            TowerY := Ys + ScaleY(3)
        }
        
        oldMode := A_SendMode
        SendMode("Input")
        offset := -7
        while (offset <= 7) {
            TowerYCurrentY := TowerY + offset
            
            MouseMove(Towers[towerId].x, TowerYCurrentY)
            Sleep 10
            MouseClick()
            offset++
            Sleep 10
        }
        SendMode(oldMode)

        MouseMove(x,y)
        Sleep 100
        MouseClick()

        Sleep 50
        SendEvent("{" CancelPlacementKey "}")

        if (ReadMessage(["don't", "have", "enough", "cash", "clone", "this", "tower", "hologram", "ability"])) {
            Sleep 1000
            continue
        } else {
            break
        }
    }
}

ActivateRaiseTheDead(wait := 0) {
    global CancelPlacementKey, LastOpenedTowerID, unfocusX, unfocusY, RaiseDeadKey, Recording

    if (wait > 0 && !Recording) {
        Sleep(wait)
    }

    SendEvent("{" CancelPlacementKey "}")
    if (LastOpenedTowerID != "") {
        Click(ScaleX(unfocusX), ScaleY(unfocusY))
        Sleep(450)
    }

    SendEvent("{" RaiseDeadKey "}")
    LogToConsole("Successfully raised the dead.")
}


OnKeyDown(ih, vk, sc) {
    global MacroSteps, MacroStartTime, MacroRecording, KeyDownTimes
    if (!MacroRecording)
        return
        
    if (vk = 0xA0 || vk = 0xA1 || vk = 0xA2 || vk = 0xA3
        || vk = 0xA4 || vk = 0xA5 || vk = 0x5B || vk = 0x5C
        || vk = 0x11 || vk = 0x12 || vk = 0x41)
        return
        
    keyId := vk "-" sc
    
    if (KeyDownTimes.Has(keyId))
        return
        
    currentTime := A_TickCount
    elapsed := currentTime - MacroStartTime
    MacroStartTime := currentTime
    
    KeyDownTimes[keyId] := currentTime
    MacroSteps.Push("Sleep(" elapsed ")")
}

OnKeyUp(ih, vk, sc) {
    global MacroSteps, MacroStartTime, MacroRecording, KeyDownTimes
    if (!MacroRecording)
        return
        
    if (vk = 0xA0 || vk = 0xA1 || vk = 0xA2 || vk = 0xA3
        || vk = 0xA4 || vk = 0xA5 || vk = 0x5B || vk = 0x5C
        || vk = 0x11 || vk = 0x12 || vk = 0x41)
        return
        
    currentTime := A_TickCount
    keyId := vk "-" sc
    
    holdDuration := 50
    if (KeyDownTimes.Has(keyId)) {
        holdDuration := currentTime - KeyDownTimes[keyId]
        KeyDownTimes.Delete(keyId) 
    }

    elapsed := currentTime - MacroStartTime
    MacroStartTime := currentTime
    
    keyName := GetKeyName(Format("vk{:02X}sc{:03X}", vk, sc))
    if (keyName = "")
        keyName := "VK" Format("{:02X}", vk)
        
    MacroSteps.Push('Send("' keyName '", hold:=' holdDuration ')')
    
    if (elapsed > 0) {
        MacroSteps.Push("Sleep(" elapsed ")")
    }
}


KeyWaitAny() {
    ih := InputHook("V L0") 
    ih.KeyOpt("{All}", "E") 
    
    while (true) {
        ih.Start()
        ih.Wait() 
        
        if (ih.EndReason = "EndKey")
            break
        Sleep 10
    }
}

~LButton:: {
    global MacroRecording, MacroSteps, MacroStartTime, Recording, Towers, RecordedSteps, Commander, ActiveUpgradeTowerID, CachedMenuUI, isUiPositionSaved, isUpgradeAuthorized, activeUpgradeRegions

    if (IsSet(MacroRecording) && MacroRecording) {
        MouseGetPos(&mx, &my)
        elapsed := A_TickCount - MacroStartTime
        MacroStartTime := A_TickCount
        MacroSteps.Push("Sleep(" elapsed ")")
        MacroSteps.Push("Click(" mx ", " my ")")
        LogToConsole("Recorded Click")
        return
    }

    if (!Recording)
        return

    MouseGetPos(&mx, &my)

    currentTowerID := ""
    for id, t in Towers {
        ix1 := t.x - 16
        iy1 := t.y - 16
        ix2 := ix1 + 32
        iy2 := iy1 + 32
        
        if (mx >= ix1 && mx <= ix2 && my >= iy1 && my <= iy2) {
            currentTowerID := id
            break
        }
    }

    if (currentTowerID != "") {
        ActiveUpgradeTowerID := currentTowerID
        
        openedSuccessfully := false
        Loop 20 {
            getRobloxPos(,,&w,&h)
            resV2 := AdvImageSearch("Resources\TowerUI\Variant2.png", 0, Round(h / 2), Round(w * 0.3), Round(h * 0.9) - Round(h / 2), 0.5, 1.5)
            
            if (resV2.status == "success" && resV2.score > 0.6) {
                if (!isUiPositionSaved) {
                    Sleep(120)
                    
                    getRobloxPos(,,&w,&h)
                    resV2Final := AdvImageSearch("Resources\TowerUI\Variant2.png", 0, Round(h / 2), Round(w * 0.3), Round(h * 0.9) - Round(h / 2), 0.5, 1.5)
                    
                    if (resV2Final.status == "success") {
                        CachedMenuUI := {x: resV2Final.x, y: resV2Final.y}
                        isUiPositionSaved := true 
                        openedSuccessfully := true
                    } else {
                        CachedMenuUI := {x: resV2.x, y: resV2.y}
                        isUiPositionSaved := true
                        openedSuccessfully := true
                    }
                } 
                else {
                    openedSuccessfully := true
                    CachedMenuUI := {x: resV2.x, y: resV2.y}
                }
                break
            }
            Sleep(60)
        }
        
        if (!openedSuccessfully) {
            ActiveUpgradeTowerID := ""
        }
        return
    }

    isUpgradeAuthorized := false
    if (IsSet(ActiveUpgradeTowerID) && ActiveUpgradeTowerID != "") {

        if (CachedMenuUI.x == 0 && CachedMenuUI.y == 0) {
            return
        }

        towerID := ActiveUpgradeTowerID
        if (!Towers.Has(towerID))
            return

        path := Towers[towerID].path
        pathLevel := Towers[towerID].pathLevel
        nextLevel := Towers[towerID].level + 1

        region := [CachedMenuUI.x - ScaleX(100), CachedMenuUI.y - ScaleY(260), ScaleX(300), ScaleY(110)]
        if (path != 0 && nextLevel > pathLevel && pathLevel != 0) {
            if (path = 2) { 
                region := [CachedMenuUI.x - ScaleX(100), CachedMenuUI.y - ScaleY(120), ScaleX(300), ScaleY(110)]
            }
        }

        x1 := region[1]
        y1 := region[2]
        x2 := region[1] + region[3]
        y2 := region[2] + region[4]

        activeUpgradeRegions := [x1, y1, x2, y2]

        if (mx >= x1 && mx <= x2 && my >= y1 && my <= y2) {
            if PixelSearch(&gx, &gy, x1, y1, x2, y2, 0x206435, 7) {
                isUpgradeAuthorized := true
            }
        }
    }
}

~LButton Up:: {
    global Recording, ActiveUpgradeTowerID, Towers, RecordedSteps, Commander, isUpgradeAuthorized, activeUpgradeRegions, CachedMenuUI
    
    if (!Recording || !IsSet(ActiveUpgradeTowerID) || ActiveUpgradeTowerID == "" || !IsSet(isUpgradeAuthorized) || !isUpgradeAuthorized) {
        isUpgradeAuthorized := false
        return
    }

    if (!IsSet(activeUpgradeRegions) || !activeUpgradeRegions || activeUpgradeRegions.Length < 4) {
        isUpgradeAuthorized := false
        return
    }

    towerID := ActiveUpgradeTowerID
    if (!Towers.Has(towerID)) {
        isUpgradeAuthorized := false
        return
    }

    MouseGetPos(&cx, &cy)
    
    x1 := activeUpgradeRegions[1]
    y1 := activeUpgradeRegions[2]
    x2 := activeUpgradeRegions[3]
    y2 := activeUpgradeRegions[4]

    getRobloxPos(,,&w,&h)
    checkV2 := AdvImageSearch("Resources\TowerUI\Variant2.png", 0, Round(h / 2), Round(w * 0.3), Round(h * 0.9) - Round(h / 2), 0.5, 1.5)
    if (checkV2.status != "success" || checkV2.score <= 0.6) {
        ActiveUpgradeTowerID := ""
        isUpgradeAuthorized := false
        return
    }

    if (cx >= x1 && cx <= x2 && cy >= y1 && cy <= y2) {
        
        ocrW := x2 - x1
        ocrH := y2 - y1

        langCode := "en-US"
        for availableLang in StrSplit(OCR.GetAvailableLanguages(), "`n", "`r") {
            if (availableLang != "" && SubStr(availableLang, 1, 2) = "en") {
                langCode := availableLang
                break
            }
        }

        ocrResult := OCR.FromRect(x1, y1, ocrW, ocrH, {lang: langCode, monochrome: 128, scale: 2})
        
        if (InStr(ocrResult.Text, "fully upgraded")) {
            ActiveUpgradeTowerID := ""
            isUpgradeAuthorized := false
            return
        }

        Towers[towerID].level += 1
        UpdateTowerIndicator(towerID)
        
        if (Towers[towerID].path != 0 && Towers[towerID].path != "") {
            RecordedSteps.Push("UpgradeTower(" towerID ", false, 1, " Towers[towerID].path ", " Towers[towerID].pathLevel ")")
        } else {
            RecordedSteps.Push("UpgradeTower(" towerID ")")
        }
        
        if (Towers[towerID].level >= 2 && RegExMatch(towerID, "i)^Commander\d*$") && !Commander) {
            Commander := true
            if (!HasStep("Commander := true"))
                RecordedSteps.Push("Commander := true")
        }
        LogToConsole("Upgraded " towerID " to level " Towers[towerID].level ".")
    } 

    isUpgradeAuthorized := false
}

^SC02C:: {
    global RecordedSteps, Towers, Recording, Commander
    
    if (!Recording) {
        Send("^{SC02C}")
        return
    }
    if (RecordedSteps.Length == 0) {
        return
    }

    lastStep := RecordedSteps.Pop()
    LogToConsole("Undo: Reverting step -> " lastStep)

    if RegExMatch(lastStep, "i)UpgradeTower\s*\(\s*([^, \)]+)", &matchUpgrade) {
        towerID := matchUpgrade[1]
        
        if (Towers.Has(towerID)) {
            Towers[towerID].level := Max(0, Towers[towerID].level - 1)
            UpdateTowerIndicator(towerID)
        }
        return
    }

    if RegExMatch(lastStep, "i)SpawnTower\s*\(\s*[^,]+\s*,\s*[^,]+\s*,\s*[^,]+\s*,\s*(.*?)\s*\)", &matchPlace)
    {
        towerID := matchPlace[1] 
        
        if (Towers.Has(towerID)) {
            if (Towers[towerID].HasProp("hwnd") && Towers[towerID].hwnd && WinExist("ahk_id " Towers[towerID].hwnd)) {
                WinClose("ahk_id " Towers[towerID].hwnd)
            }
            Towers.Delete(towerID)

        }
        return
    }

    if (lastStep = "Commander := true") {
        Commander := false
        return
    }
}

~RButton:: {
    global MacroRecording, MacroSteps, MacroStartTime, Towers
    if (!Recording) {
        return
    }

    if (MacroRecording) {
        MouseGetPos(&mx, &my)
        elapsed := A_TickCount - MacroStartTime
        MacroStartTime := A_TickCount
        MacroSteps.Push("Sleep(" elapsed ")")
        MacroSteps.Push("Click(" mx ", " my ", Right)")
        return
    }

    MouseGetPos(&mx, &my)

    towerID := ""

    for id, t in Towers {
        ix1 := t.x - 16
        iy1 := t.y - 16
        ix2 := ix1 + 32
        iy2 := iy1 + 32
        
        if (mx >= ix1 && mx <= ix2 && my >= iy1 && my <= iy2) {
            towerID := id
            break
        }
    }

    if (towerID != "")
        ShowTowerPathDialog(towerID)
}

global ActivePathSelectTowerID := ""

ShowTowerPathDialog(towerID) {
    global Towers, ActivePathSelectTowerID
    if (!Towers.Has(towerID) || Towers[towerID].path = 0 || Towers[towerID].path = "") {
        ActivePathSelectTowerID := towerID
        PathGui := Gui("+AlwaysOnTop +Border -DPIScale", "Path Selection")
        PathGui.SetFont("s12 Bold c000000", "Segoe UI")
        PathGui.Add("Text", "x25 y20 w350", "Tower " towerID)
        PathGui.SetFont("s11 w400 c000000", "Segoe UI")
        PathGui.Add("Text", "x25 y+10 w350", "Choose an upgrade path")
        PathGui.Add("Text", "x25 y+10 w350", "Rigth click on the tower indicator to make this appear.`nNote: enter 3 for Pursuit, Juggernaut, and Kingpin, 4 for Hacker")
        PathGui.SetFont("s10 w600 c000000")
        b1 := PathGui.Add("Button", "x25 y+25 w165 h40", "Path 1 (Top)")
        b1.OnEvent("Click", (*) => SelectPath(PathGui, 1))
        b2 := PathGui.Add("Button", "x+10 w165 h40", "Path 2 (Bottom)")
        b2.OnEvent("Click", (*) => SelectPath(PathGui, 2))
        bc := PathGui.Add("Button", "x25 y+10 w340 h35", "Cancel")
        bc.OnEvent("Click", (*) => PathGui.Destroy())
        PathGui.Show("w390 h280")
        WinWaitClose("ahk_id " PathGui.Hwnd)
    }
}

SelectPath(pathGui, pathNum) {
    global Towers, ActivePathSelectTowerID
    pathGui.Destroy()
    towerID := ActivePathSelectTowerID
    if (towerID = "")
        return
    box := InputBox("Enter the level where the paths appear:", "Level", "w300 h130", "")
    if (box.Result = "Cancel" || !IsInteger(box.Value))
        return
    Towers[towerID].path      := pathNum
    Towers[towerID].pathLevel := Integer(box.Value)
    UpdateTowerIndicator(towerID)
    LogToConsole("Tower " towerID " set to path " pathNum " from level " box.Value)
}

TestWebhook(ctrl, *) {
    global WebhookLink
    v := MainGui.Submit(false)
    if (v.WebhookLink = "") {
        ModernMsgBox("Error", "Enter a webhook URL first!", "OK", "WARNING")
        return
    }
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", v.WebhookLink, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send('{"content": "✅ Webhook test successful! leomacro TDS is connected."}')
        if (whr.Status = 200 || whr.Status = 204)
            ModernMsgBox("Success", "Webhook test successful!", "OK")
        else
            ModernMsgBox("Error", "Webhook test failed! Status: " whr.Status, "OK", "WARNING")
    } catch {
        ModernMsgBox("Error", "Failed to send test message. Check your internet and webhook URL.", "OK", "WARNING")
    }
}

SaveWebhookSettings(ctrl, *) {
    global WebhookLink, WebhookLink2, WebhookEnabled, SendCurrenciesEnabled, WebhookDebugLogs, WebhookScreenshots, WebhookTriumphScreenshots, WebhookSepatateTriumphScreenshots
    v := MainGui.Submit(false)
    WebhookLink := v.WebhookLink
    WebhookLink2 := v.WebhookLink2
    WebhookEnabled := v.WebhookEnabled
    SendCurrenciesEnabled := v.SendCurrenciesEnabled
    WebhookDebugLogs := v.WebhookDebugLogs
    WebhookScreenshots := v.WebhookScreenshots
    WebhookTriumphScreenshots := v.WebhookTriumphScreenshots
    WebhookSepatateTriumphScreenshots := v.WebhookSepatateTriumphScreenshots
    IniWrite(WebhookLink, SettingsFile, "Webhook", "Link")
    IniWrite(WebhookLink2, SettingsFile, "Webhook", "Link2")
    IniWrite(WebhookEnabled, SettingsFile, "Webhook", "Enabled")
    IniWrite(SendCurrenciesEnabled, SettingsFile, "Webhook", "SendCurrencies")
    IniWrite(WebhookDebugLogs, SettingsFile, "Webhook", "WebhookDebugLogs")
    IniWrite(WebhookScreenshots, SettingsFile, "Webhook", "WebhookScreenshots")
    IniWrite(WebhookTriumphScreenshots, SettingsFile, "Webhook", "WebhookTriumphScreenshots")
    IniWrite(WebhookSepatateTriumphScreenshots, SettingsFile, "Webhook", "WebhookSepatateTriumphScreenshots")

    MsgBox("All webhook settings have been successfully saved!", "leomacro", 0x40)
}


NormalizeKey(keyName) {
    if (keyName = "")
        return ""

    if !RegExMatch(keyName, "^([~!#^+<>*]*)(.*)$", &Match)
        return keyName
        
    modifiers := Match[1]
    pureKey   := Match[2]

    if (StrLen(pureKey) > 1)
        return keyName
    
    res := DllCall("User32.dll\VkKeyScanW", "UShort", Ord(pureKey), "Short")
    vk := res & 0xFF
    
    if (vk = 0xFF || vk = 0)
        return keyName
    
    sc := DllCall("User32.dll\MapVirtualKeyW", "UInt", vk, "UInt", 0, "UInt")
    
    if (!sc)
        return keyName
    
    return modifiers . Format("sc{:03X}", sc)
}


SaveAllSettings(ctrl, *) {
    global ChainKey, BeatKey, CaravanKey, CancelPlacementKey, TimeScaleMode, UseTimeScale
    global TimeScaleMultiplier, VipLink, UseVipServer, AlwaysOnTop, DebugConsole
    global PotatoMode, UseRestartBtn, UsePlayAgainBtn, CheckTheMap
    global PlaceTowerKey, UpgradeTowerKey, AlignCameraKey, ChangeDJTrackKey
    global SellTowerKey, DeleteTowerRecordingKey, RecordInputsKey
    global SettingsFile
    global DefaultMouseSpeed, MouseDelay, KeyDelay
    global HoloKey, RaiseDeadKey, UseRaiseDeadKey, HologramKey, CollectPlaytimeRewards, UpgradeTowerGKey, UpgradeTowerGBKey, UseHForUpgrade

    tempChainKey := SubStr(RegExReplace(ChainKeyCtrl.Value, "\s", ""), 1, 1)
    tempBeatKey := SubStr(RegExReplace(BeatKeyCtrl.Value, "\s", ""), 1, 1)
    tempCaravanKey := SubStr(RegExReplace(CaravanKeyCtrl.Value, "\s", ""), 1, 1)
    tempCancelPlacementKey := SubStr(RegExReplace(CancelPlacementKeyCtrl.Value, "\s", ""), 1, 1)
    tempUpgradeTowerGKey := SubStr(RegExReplace(UpgradeTowerGCtrl.Value, "\s", ""), 1, 1)
    tempUpgradeTowerGBKey := SubStr(RegExReplace(UpgradeTowerGBCtrl.Value, "\s", ""), 1, 1)
    
    if (tempChainKey = "")           
        tempChainKey := "C"
    if (tempBeatKey = "")            
        tempBeatKey  := "B"
    if (tempCaravanKey = "")         
        tempCaravanKey := "J"
    if (tempCancelPlacementKey = "") 
        tempCancelPlacementKey := "Q"
    if (tempUpgradeTowerGKey = "")
        tempUpgradeTowerGKey := "E"
    if (tempUpgradeTowerGBKey = "")
        tempUpgradeTowerGKey := "Z"

    tempPlaceTowerKey := NormalizeKey(PlaceTowerKeyCtrl.Value)
    tempUpgradeTowerKey := NormalizeKey(UpgradeTowerKeyCtrl.Value)
    tempAlignCameraKey := NormalizeKey(AlignCameraKeyCtrl.Value)
    tempChangeDJTrackKey := NormalizeKey(ChangeDJTrackKeyCtrl.Value)
    tempSellTowerKey := NormalizeKey(SellTowerKeyCtrl.Value)
    tempDeleteTowerRecordingKey := NormalizeKey(DeleteTowerRecordingKeyCtrl.Value)
    tempRecordInputsKey := NormalizeKey(RecordInputsKeyCtrl.Value)
    tempHoloKey := NormalizeKey(HoloKeyCtrl.Value)
    tempUseRaiseDeadKey := NormalizeKey(UseRaiseDeadKeyCtrl.Value)

    UsedKeys := Map()
    
    KeysToCheck := [
        {val: NormalizeKey(tempChainKey), name: "Chain Ability"},
        {val: NormalizeKey(tempBeatKey), name: "Beat Ability"},
        {val: NormalizeKey(tempCaravanKey), name: "Caravan Ability"},
        {val: NormalizeKey(tempCancelPlacementKey), name: "Cancel Placement"},
        {val: NormalizeKey(tempUpgradeTowerGKey), name: "Upgrade Tower (TDS keybind)"},
        {val: NormalizeKey(tempUpgradeTowerGBKey), name: "Upgrade Bottom Path (TDS keybind)"},
        {val: tempPlaceTowerKey, name: "Place Tower"},
        {val: tempUpgradeTowerKey, name: "Upgrade Tower"},
        {val: tempAlignCameraKey, name: "Align Camera"},
        {val: tempChangeDJTrackKey, name: "Change DJ Track"},
        {val: tempSellTowerKey, name: "Sell Tower"},
        {val: tempDeleteTowerRecordingKey, name: "Delete Tower Recording"},
        {val: tempRecordInputsKey, name: "Record Inputs"},
        {val: tempHoloKey, name: "Hologram Tower"},
        {val: tempUseRaiseDeadKey, name: "Raise the Dead"}
    ]

    for item in KeysToCheck {
        if (item.val = "") {
            MsgBox("Error: Empty hotkey detected!`n`n" 
            . "The hotkey is assigned to: `"" item.name "`"`n"
            . "Please change it before saving.", "Empty Hotkey", 0x10)
            return
        }
        if UsedKeys.Has(item.val) {
            MsgBox("Error: Duplicate hotkey detected!`n`n" 
                 . "The hotkey is assigned to: `"" UsedKeys[item.val] "`"`n"
                 . "And also that hotkey is assigned to: `"" item.name "`"`n`n"
                 . "Please change it before saving.", "Duplicate Hotkey", 0x10)
            return 
        }
        UsedKeys[item.val] := item.name
    }

    ChainKey := tempChainKey
    BeatKey := tempBeatKey
    CaravanKey := tempCaravanKey
    CancelPlacementKey := tempCancelPlacementKey
    UpgradeTowerGKey := tempUpgradeTowerGKey
    UpgradeTowerGBKey := tempUpgradeTowerGBKey
    
    PlaceTowerKey := tempPlaceTowerKey
    UpgradeTowerKey := tempUpgradeTowerKey
    AlignCameraKey := tempAlignCameraKey
    ChangeDJTrackKey := tempChangeDJTrackKey
    SellTowerKey := tempSellTowerKey
    DeleteTowerRecordingKey := tempDeleteTowerRecordingKey
    RecordInputsKey := tempRecordInputsKey
    HoloKey := tempHoloKey
    UseRaiseDeadKey := tempUseRaiseDeadKey
    RaiseDeadKey := RaiseDeadKeyCtrl.Value
    HologramKey := HologramKeyCtrl.Value

    TimeScaleMode := (TimeScaleModeCtrl.Text = "") ? "OFF" : TimeScaleModeCtrl.Text
    VipLink := VipLinkCtrl.Value
    UseVipServer := UseVipServerCtrl.Value
    AlwaysOnTop := AlwaysOnTopCtrl.Value
    DebugConsole := DebugConsoleCtrl.Value
    PotatoMode := PotatoModeCtrl.Value
    UseRestartBtn := UseRestartBtnCtrl.Value
    UsePlayAgainBtn := UsePlayAgainBtnCtrl.Value
    CheckTheMap := CheckTheMapCtrl.Value
    CollectPlaytimeRewards := CollectPlaytimeRewardsCtrl.Value
    UseHForUpgrade := UseUpgradeHCtrl.Value
    
    DefaultMouseSpeed := MouseSpeedUpDown.Value
    MouseDelay := MouseDelayUpDown.Value
    KeyDelay := KeyDelayUpDown.Value
    
    IniWrite(ChainKey, SettingsFile, "Hotkeys", "Chain")
    IniWrite(BeatKey, SettingsFile, "Hotkeys", "Beat")
    IniWrite(CaravanKey, SettingsFile, "Hotkeys", "Caravan")
    IniWrite(CancelPlacementKey, SettingsFile, "Hotkeys", "CancelPlacement")
    IniWrite(UpgradeTowerGKey, SettingsFile, "Hotkeys", "UpgradeTower")
    IniWrite(UpgradeTowerGBKey, SettingsFile, "Hotkeys", "UpgradeBottom")
    IniWrite(RaiseDeadKey, SettingsFile, "Hotkeys", "RaiseTheDead")
    IniWrite(HologramKey, SettingsFile, "Hotkeys", "Hologram")
    IniWrite(TimeScaleMode, SettingsFile, "Options", "TimeScaleMode")
    IniWrite(VipLink, SettingsFile, "Options", "VipLink")
    IniWrite(UseVipServer, SettingsFile, "Options", "UseVipServer")
    IniWrite(DebugConsole, SettingsFile, "Options", "DebugConsole")
    IniWrite(PotatoMode, SettingsFile, "Options", "PotatoMode")
    IniWrite(AlwaysOnTop, SettingsFile, "Options", "AlwaysOnTop")
    IniWrite(UseRestartBtn, SettingsFile, "Options", "UseRestartBtn")
    IniWrite(UsePlayAgainBtn, SettingsFile, "Options", "UsePlayAgainBtn")
    IniWrite(CheckTheMap, SettingsFile, "Options", "CheckTheMap")
    IniWrite(CollectPlaytimeRewards, SettingsFile, "Options", "CollectPlaytimeRewards")
    IniWrite(UseHForUpgrade, SettingsFile, "Options", "UseHotkeyForUpgrade")
    IniWrite(DefaultMouseSpeed, SettingsFile, "Options", "DefaultMouseSpeed")
    IniWrite(MouseDelay, SettingsFile, "Options", "MouseDelay")
    IniWrite(KeyDelay, SettingsFile, "Options", "KeyDelay")

    IniWrite(PlaceTowerKey, SettingsFile, "RecordingHotkeys", "PlaceTowerKey")
    IniWrite(UpgradeTowerKey, SettingsFile, "RecordingHotkeys", "UpgradeTowerKey")
    IniWrite(AlignCameraKey, SettingsFile, "RecordingHotkeys", "AlignCameraKey")
    IniWrite(ChangeDJTrackKey, SettingsFile, "RecordingHotkeys", "ChangeDJTrackKey")
    IniWrite(SellTowerKey, SettingsFile, "RecordingHotkeys", "SellTowerKey")
    IniWrite(DeleteTowerRecordingKey, SettingsFile, "RecordingHotkeys", "DeleteTowerRecordingKey")
    IniWrite(RecordInputsKey, SettingsFile, "RecordingHotkeys", "RecordInputsKey")
    IniWrite(UseRaiseDeadKey, SettingsFile, "RecordingHotkeys", "RaiseDeadKey")
    IniWrite(HoloKey, SettingsFile, "RecordingHotkeys", "HoloKey")

    if (TimeScaleMode = "1.5x") {
        UseTimeScale := true
        TimeScaleMultiplier := 1.5
    } else if (TimeScaleMode = "2x") {
        UseTimeScale := true
        TimeScaleMultiplier := 2
    } else {
        UseTimeScale := false
        TimeScaleMultiplier := 1
    }

    if (DebugConsole = "1" || DebugConsole = 1) {
        ShowDebugConsole()
    } else {
        HideDebugConsole()
    }

    if (AlwaysOnTop = 1) {
        MainGui.Opt("+AlwaysOnTop")
    } else {
        MainGui.Opt("-AlwaysOnTop")
    }
    
    SetDefaultMouseSpeed(DefaultMouseSpeed)
    SetMouseDelay(MouseDelay)
    SetKeyDelay(KeyDelay)

    MsgBox("All settings have been successfully saved!", "leomacro", 0x1040)
}


CheckVipLink(ctrl, *) {
    
    str := Trim(VipLinkCtrl.Value)
    
    if (RegExMatch(str, "i)roblox\.com\/(?:[a-z]{2}\/)?games\/3260590327\/[^\/]*\?privateServerLinkCode=(?<code>[a-z0-9]{32})", &m)) {
        UseVipServerCtrl.Value := 1
        return
    }
    if (RegExMatch(str, "i)roblox\.com\/share\?code=(?<code>[a-f0-9]{32})", &m)) {
        try {
            wr := ComObject("WinHttp.WinHttpRequest.5.1")
            wr.Open("GET", "https://www.roblox.com/share?code=" m["code"] "&type=Server", true)
            wr.Send()
            if (wr.WaitForResponse(3) && wr.Status = 200 && InStr(wr.ResponseText, "3260590327")) {
                return
            }
        } catch Error {
            
        }
    }
    UseVipServerCtrl.Value := 0
}


CheckWebhookLink(ctrl, *) {
    v := MainGui.Submit(false)
    link := v.WebhookLink
    if (link = "" || (!InStr(link, "discord.com/api/webhooks/") && !InStr(link, "discordapp.com/api/webhooks/"))) {
        WebhookEnabledCtrl.Value   := 0
        return
    }
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", link, false)
        whr.Send()
        WebhookEnabledCtrl.Enabled := (whr.Status = 200)
        if (whr.Status != 200)
            WebhookEnabledCtrl.Value := 0
    } catch {
        WebhookEnabledCtrl.Value := 0
    }
}

EnableWebhookLink2(*) {
    v := MainGui.Submit(false)
    toggle := v.WebhookSepatateTriumphScreenshots
    if toggle = 1 {
        WebhookLinkCtrl2.Visible := true
    } else {
        WebhookLinkCtrl2.Visible := false
    }
}

CheckWebhookLink2(ctrl, *) {
    v := MainGui.Submit(false)
    link := v.WebhookLink2
    if (link = "" || (!InStr(link, "discord.com/api/webhooks/") && !InStr(link, "discordapp.com/api/webhooks/"))) {
        WebhookSepatateTriumphScreenshotsCtrl.Value := 0
        return
    }
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", link, false)
        whr.Send()
        WebhookSepatateTriumphScreenshotsCtrl.Enabled := (whr.Status = 200)
        if (whr.Status != 200)
            WebhookSepatateTriumphScreenshotsCtrl.Value := 0
    } catch {
        WebhookSepatateTriumphScreenshotsCtrl.Value := 0
    }
}


ShowFAQ(*) {
    ModernMsgBox("FAQ",
        "[SCREEN AND SYSTEM SETTINGS]`n" .
        "- Screen Resolution: Works strictly in 1920x1080.`n" .
        "- Windows Scale: 100% or 125% is supported.`n" .
        "- Taskbar: Must be visible.`n`n" .
        "[ROBLOX AND GAME SETTINGS]`n" .
        "- UI Scale: Set to Large.`n" .
        "- Screen Shake: Must be DISABLED.`n" .
        "- Roblox Chat: Close the chat before starting the macro.`n" .
        "- Set 'Prefer Vertical Upgrades' to Disabled.`n" .
        "- Fonts: Do not use custom fonts.`n`n" .
        "[COMMANDER ISSUES]`n" .
        "- Auto Chain: Enter 'Commander1', 'Commander2', etc., when placing them.", "OK")
}
HelpChain(*) {
    ModernMsgBox("Info", "Configure hotkey for Commander's 'Call of Arms'.", "OK")
}
HelpBeat(*) {
    ModernMsgBox("Info", "Configure hotkey for DJ's 'Drop The Beat'.", "OK")
}
HelpCaravan(*) {
    ModernMsgBox("Info", "Configure hotkey for the 'Support Caravan'.", "OK")
}
HelpCancelPlacement(*) {
    ModernMsgBox("Info", "Configure hotkey for the 'Cancel Placement'.", "OK")
}
HelpTimeScale(*) {
    ModernMsgBox("Timescale Info", "1.5x — more stable and recommended for most cases.`n2x — requires special strategies but is much more effective.`n`nThis will automatically turn off if you run out of timescale tickets.", "OK")
}
HelpPotatoMode(*) {
    ModernMsgBox("Info", "Turn this on if your macro acts inconsistently or if you have lags.", "OK")
}
HelpSendCurrencies(*) {
    ModernMsgBox("Info", "If you enable the 'Send currencies' toggle, the macro will send you information about your coins, gems, total matches, triumphs, and losses.`n`nMay be buggy.", "OK")
}
HelpRestartBtn(*) {
    ModernMsgBox("Info", "If this setting is ON, the macro will use the restart button when you lose.`n`nIt's recommended to turn it OFF if you are using a win strategy and your macro sometimes appears on the wrong map.", "OK")
}
HelpPlayAgainBtn(*) {
    ModernMsgBox("Info", "If this setting is ON, the macro will use the play again button when you win.", "OK")
}
HelpAutoCameraCorrection(*) {
    ModernMsgBox("Info", "The macro will use tds keybind when upgrading the tower.`n`nIt's recommended to turn it ON.", "OK")
}
HelpCheckTheMap(*) {
    ModernMsgBox("Info", "When you join the map, the macro will check is it in the correct map or not. If no, it reloads.`n`nIt's recommended to turn it ON.", "OK")
}



LoadStrategyFile(file) {
    global Towers, RecordedSteps, gamemap, difficulty, requiredTowers, autoChain, autoCaravan
    global autoDropTheBeat, AutoSkip, AbilitySpam, MoveEnabled, MoveDirection, MoveDuration
    global modifiers, Commander, StrategyWidth, StrategyHeight

    Towers := Map()
    RecordedSteps := []
    DeleteAllIndicators()

    gamemap := IniRead(file, "Settings", "map", "")
    difficulty := IniRead(file, "Settings", "difficulty", "")
    requiredTowers  := IniRead(file, "Settings", "requiredTowers",  "")
    autoChain := IniRead(file, "Settings", "autoChain", "OFF")
    autoCaravan := IniRead(file, "Settings", "autoCaravan", "OFF")
    autoDropTheBeat := IniRead(file, "Settings", "autoDropTheBeat", "OFF")
    AutoSkip := IniRead(file, "Settings", "autoSkip", "ON")
    AbilitySpam := IniRead(file, "Settings", "abilitySpam", "ON")
    modifiers := IniRead(file, "Settings", "modifiers", "")

    moveDown := IniRead(file, "Settings", "moveDown",      "false")
    tempEnabled := IniRead(file, "Settings", "moveEnabled",   "")
    tempDir := IniRead(file, "Settings", "moveDirection", "")
    tempDur := IniRead(file, "Settings", "moveDuration",  "")

    if (tempEnabled != "") {
        MoveEnabled := (tempEnabled = "true" || tempEnabled = "1") ? true : false
        MoveDirection := (tempDir != "" && (tempDir = "W" || tempDir = "A" || tempDir = "S" || tempDir = "D")) ? tempDir : "W"
        MoveDuration := IsNumber(tempDur) ? Integer(tempDur) : 750
    } else {
        if (moveDown = "true") {
            MoveEnabled := true, MoveDirection := "S", MoveDuration := 750
        } else {
            MoveEnabled := false, MoveDirection := "W", MoveDuration := 750
        }
    }

    Commander := false

    StrategyWidth  := Integer(IniRead(file, "DO NOT EDIT", "width",  "1920"))
    StrategyHeight := Integer(IniRead(file, "DO NOT EDIT", "height", "1090"))

    inSteps := false
    Loop Read, file {
        line := Trim(A_LoopReadLine)
        if (line ~= "i)^\[Settings\]") { 
            inSteps := false
        }
        if (line ~= "i)^\[Steps\]")    { 
            inSteps := true
        }
        if (inSteps && line != "") {
            RecordedSteps.Push(line)
        }
    }

    
    for i, step in RecordedSteps {
        if RegExMatch(step, "i)SpawnTower\s*\(\s*\d+\s*,\s*\d+\s*,\s*\d+\s*,\s*(.*?)\s*\)", &m) {
            towerID := Trim(m[1])
            Towers[towerID] := {x: 0, y: 0, slot: 0, level: 0, path: 0, pathLevel: 0}
        }
        if RegExMatch(step, "i)UpgradeTower\s*\(\s*([^,]+?)\s*(?:,\s*(?:false|true)\s*)?(?:,\s*\d+\s*)?(?:,\s*(\d+)\s*)?(?:,\s*(\d+)\s*)?\s*\)", &m) {
            tid := Trim(m[1])
            if (Towers.Has(tid) && m[2] != "") {
                Towers[tid].path      := m[2]
                Towers[tid].pathLevel := (m[3] != "") ? m[3] : 4
            }
        }
    }
}

RunStrategy(stratFile := "", skipRestart := false, equip := false) {
    global RunningStrategy, difficulty, MoveEnabled, MoveDirection, MoveDuration
    global unfocusX, unfocusY, UseTimeScale, TimeScaleMultiplier, TimeScaleMode
    global SettingsFile, requiredTowers, modifiers, LastOpenedTowerID
    global LastSkipCheck, SKIP_CHECK_INTERVAL, AutorunStartTime, StateFile
    global WebhookEnabled, CurrentStratStartTime, CurrentRunCount, gamemap

    if (RunningStrategy != true)
        return

    SetTimer(CheckPopups, 10000)
    If (!skiprestart)
    	isDisconnected()

    switched := false
    if (RotateStrategies) {
        SwapAmount := Integer(IniRead(SettingsFile, "Options", "SwapAmount", 4))
        SwapUnit := IniRead(SettingsFile, "Options", "SwapUnit", "Runs")
        
        timeToSwitch := false
        if (SwapUnit = "Minutes") {
            if (A_TickCount - CurrentStratStartTime > SwapAmount * 60000)
                timeToSwitch := true
        } else {
            if (CurrentRunCount >= SwapAmount)
                timeToSwitch := true
        }
        
        if (timeToSwitch) {
            SwitchToNextStrategy(&stratName)
            switched := true

            Sleep(100)
        }
    }

    CurrentRunCount++
    IniWrite(CurrentRunCount, StateFile, "State", "CurrentRunCount")

    KillSubmacros()
    startWatchdog()

    LastOpenedTowerID := ""

    LogToConsole("Starting strategy... Press F2 to STOP!!!")
    LogToConsole("Map = " gamemap)
    LogToConsole("Mode = " difficulty)
    LogToConsole("Timescale = " TimeScaleMode)
    LogToConsole("Required Towers: " requiredTowers)
    if (modifiers != "")
        LogToConsole("Modifiers: " modifiers)

    if (switched) {
        time := FormatTime(, "HH:mm:ss")
        SplitPath(stratName, &fileName)
        startInfo := "[" time "] Switched strategy to: " fileName "`n"
        startInfo .= "Map = " gamemap "`nMode = " difficulty "`nTimescale = " TimeScaleMode "`nRequired Towers: " requiredTowers
        if (modifiers != "")
            startInfo .= "`nModifiers: " modifiers
        SendToWebhookInstant(startInfo,, flush := false)
    }

    checkStart := IniRead(StateFile, "State", "StartTime", 0)
    if (checkStart = 0) {
        IniWrite(A_TickCount, StateFile, "State", "StartTime")
        AutorunStartTime := A_TickCount
    } else {
        AutorunStartTime := checkStart
    }

    if (!switched) {
        if (!skipRestart) {
            CheckRestart()
        } else {
            CloseRoblox()
            RunRoblox()
            if (equip) {
                EquipTowers(RequiredTowers)
            }
            JoinGame()
        }
    } else {
        CloseRoblox()
        RunRoblox()
        EquipTowers(RequiredTowers)

        JoinGame()
    }

    waitReady(&fx, &fy)
    activateTimescale()

    if (!InArray(SpecialMaps, gamemap)) {
        AlignCamera()
    }

    ClickReady(fx, fy)
    
    PlayStrategy()
}

PlayStrategy() {
    global canUseAbility
    SetTimer(UseAbilities, 750)

    i := 1
    while (i <= RecordedSteps.Length) {
        step := RecordedSteps[i]
        isMacroStep := RegExMatch(step, "i)^(Click|Send|Sleep)\s*\(")

        if RegExMatch(step, "i)UpgradeTower\s*\(\s*([^,]+?)\s*(?:,\s*(false|true)\s*)?(?:,\s*(\d+)\s*)?(?:,\s*(\d+)\s*)?(?:,\s*(\d+)\s*)?\s*\)", &m) {
            currentID    := Trim(m[1])
            countUpgrades := (m[3] != "") ? Integer(m[3]) : 1
            currentPath   := (m[4] != "") ? Integer(m[4]) : 0
            currentpathLevel := (m[5] != "") ? Integer(m[5]) : 4

            lookAhead := i + 1
            while (lookAhead <= RecordedSteps.Length) {
                nextStep := RecordedSteps[lookAhead]
                if RegExMatch(nextStep, "i)UpgradeTower\s*\(\s*" currentID "\s*(?:,\s*(?:false|true)\s*)?(?:,\s*(\d+)\s*)?(?:,\s*(\d+)\s*)?(?:,\s*(\d+)\s*)?\s*\)", &mN) {
                    countUpgrades += (mN[1] != "") ? Integer(mN[1]) : 1
                    lookAhead++
                } else {
                    break
                }
            }

            success := UpgradeTower(currentID, false, countUpgrades, currentPath, currentpathLevel)
            i := success ? lookAhead : i + 1
        } else if RegExMatch(step, "i)SetDJTrack\s*\(\s*([^\s,)]+)\s*\)", &t) {
            SetDJTrack(t[1])
            i++
        } else if RegExMatch(step, "i)SpawnTower\s*\(.*\)") {
            ExecuteStep(step)
            i++
        } else {
            try {
                ExecuteStep(step)
            } catch Error as e { 
                LogToConsole("ERROR executing step " i ": " step)
            }
            i++
        }
    }

    Click(ScaleX(unfocusX), ScaleY(unfocusY))
    LogToConsole("All strategy steps completed, entering maintenance loop...")
    Loop {
        canUseAbility := true
        Sleep 2000
    }
}

ExecuteStep(step) {
    global Commander, unfocusX, unfocusY
    step := RegExReplace(step, "\s*;.*$", "")
    step := Trim(step)
    if (step = "")
        return
    if RegExMatch(step, "i)SpawnTower\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d)\s*,\s*(.*?)\s*\)", &m) {
        SpawnTower(m[1], m[2], m[3], Trim(m[4]))
        return
    }
    if RegExMatch(step, "i)UpgradeTower\s*\(\s*([^,]+?)\s*(?:,\s*(false|true)\s*)?(?:,\s*(\d+)\s*)?(?:,\s*(\d+)\s*)?(?:,\s*(\d+)\s*)?\s*\)", &m) {
        UpgradeTower(Trim(m[1]), (m[2]="true"), (m[3]!="") ? Integer(m[3]) : 1, (m[4]!="") ? Integer(m[4]) : 0, (m[5]!="") ? Integer(m[5]) : 4)
        return
    }
    
    if RegExMatch(step, "i)CloneTower\s*\(\s*([^,]+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)", &m) {
        CloneTower(Trim(m[1]), Integer(m[2]), Integer(m[3]), Integer(m[4]))
        return
    }

    if RegExMatch(step, "i)CloneTower\s*\(\s*([^,]+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)", &m) {
        CloneTower(Trim(m[1]), Integer(m[2]), Integer(m[3]), 0)
        return
    }
    if RegExMatch(step, "i)ActivateRaiseTheDead\s*\(\s*(\d+)\s*\)", &m) {
        ActivateRaiseTheDead(Integer(m[1]))
        return
    }
    if RegExMatch(step, "i)ActivateRaiseTheDead\s*\(\s*\)", &m) {
        ActivateRaiseTheDead(0)
        return
    }

    if RegExMatch(step, "i)SetDJTrack\s*\(\s*(.+?)\s*\)", &m) {
        track := Trim(m[1], ' "')
        if (track != "")
            SetDJTrack(track)
        return
    }
    if RegExMatch(step, "i)^Click\s*\(\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*(.+?))?\s*\)$", &m) {
        button := InStr(m[3], "Right") ? "Right" : "Left"
        Click(ScaleX(m[1]) " " ScaleY(m[2]) " " button)
        return
    }
    if RegExMatch(step, 'i)^Send\s*\(\s*"([^"]+)"\s*,\s*hold:=(\d+)\s*\)$', &m) {
        SendEvent("{" m[1] " down}")
        Sleep(Integer(m[2]))
        SendEvent("{" m[1] " up}")
        return
    }
    if RegExMatch(step, "i)^Sleep\s*\(\s*(\d+)\s*\)$", &m) {
        Sleep(Integer(m[1]))
        return
    }
    if RegExMatch(step, "i)Commander\s*:=\s*true") {
        Commander := true
        return
    }
    if RegExMatch(step, "i)SellTower\s*\(\s*([^)]+?)\s*\)", &m) {
        SellTower(Trim(m[1]))
        return
    }
}

LowerGraphics() {
    ActivateRoblox()
    SendEvent("{SC02A down}")
    Loop 10 {
        SendEvent("{SC044}")
        Sleep(20)
    }
    SendEvent("{SC02A up}")
}

EquipTowers(towers) {
    getRobloxPos(,,&rw,&rh)

    fx := ScaleX(142)
    fy := ScaleY(509)

    savedCloseX := 0
    savedCloseY := 0

    closeChat()
    Sleep(600)

    StartTime := A_TickCount
    Loop {
        W := Round(rw * 0.3)
        H := rh - 0

        resItems := AdvImageSearch("Resources\items.png", 0, 0, W, H, 0.5, 2.0)
        if (resItems.status == "success" && resItems.score > 0.56) {
            fx := resItems.x
            fy := resItems.y
            MouseMove(fx, fy+ScaleY(7), A_DefaultMouseSpeed+1)
            Sleep(100)
            MouseClick()
            break
        } 
        if (A_TickCount - StartTime > 4000) {
            break
        }
        Sleep(500)
    }

    Sleep(800)

    openedMenu := false
    StartTime := A_TickCount
    Loop {
        X1 := Round(rw * 0.2)
        Y1 := 0
        W := Round(rw * 1) - X1
        H := Round(rh * 0.4) - Y1
        resclose := AdvImageSearch("Resources\close.png", X1, Y1, W, H)

        If (resclose.status = "success" && resclose.score >= 0.86) {
            openedMenu := true
            savedCloseX := resclose.x
            savedCloseY := resclose.y
            break
        } 
        if (A_TickCount - StartTime > 5000)
            break
        Sleep(500)
    }

    if (!openedMenu) {
        MouseMove(fx, fy, A_DefaultMouseSpeed+1)
        Sleep(100)
        MouseClick()

        openedMenu := false
        StartTime := A_TickCount
        Loop {
            X1 := Round(rw * 0.2)
            Y1 := 0
            W := Round(rw * 1) - X1
            H := Round(rh * 0.4) - Y1
            resclose := AdvImageSearch("Resources\close.png", X1, Y1, W, H)

            If (resclose.status = "success" && resclose.score >= 0.86) {
                openedMenu := true
                savedCloseX := resclose.x
                savedCloseY := resclose.y
                break
            } 

            res := AdvImageSearch("Resources/Claim.png", Round(w * 0.25), Round(h * 0.4), Round(w * 0.75), Round(h * 0.4))
            if (res.status = "success" && res.score >= 0.65) {
                Click(res.x, res.y)
                Sleep(400)
            }

            if (A_TickCount - StartTime > 10000)
                break
            Sleep(500)
        }

        if (!openedMenu) {
            LogToConsole("Failed to equip towers! The macro can't see the towers menu! Retrying...", true, false)
            Sleep 400
            EquipTowers(towers)
            return
        }
    }

    sX := ScaleX(484)
    sY := ScaleY(229)

    StartTime := A_TickCount
    Loop {
        resBar := AdvImageSearch("Resources\searchbar_items.png", 0,0,rw,Round(rh*0.55), 0.5, 1.5, 0.02)
        if (resBar.status == "success" && resBar.score > 0.6) {
            sX := resBar.x+30
            sY := resBar.y
            break
        }
        if (A_TickCount - StartTime > 4000)
            break
        Sleep(400)
    }

    Click(sX, sY)
    Sleep(150)

    SendText("Sniper")
    Sleep(400)
    Click(sX+10, ScaleY(409))
    Sleep(500)

    X := Round(rw * 0.61)
    Y := ScaleY(830)
    X1 := Round(rw * 0.4)
    Y1 := Round(rh * 0.4)
    W := Round(rw * 0.9) - X1
    H := rh - Y1

    StartTime := A_TickCount
    Loop {
        resAlign := AdvImageSearch("Resources\equip.png", X1, Y1, W, H)

        if (resAlign.status == "success" && resAlign.score > 0.4) {
            Y := resAlign.y+ScaleY(110)
        }

        offset := -30
        baseY := Y

        MouseMove(X, Y+ ScaleY(offset))

        oldMode := A_SendMode
        oldDelay := A_MouseDelay
        SendMode("Input")
        SetMouseDelay(0)

        while (offset <= 30) {
            cY := baseY + ScaleY(offset)

            MouseClick("Left", X, cY)

            offset += 5
            Sleep 5
        }
        SendMode(oldMode)
        SetMouseDelay(oldDelay)

        Sleep(600)
        failCount := 0
        
        InnerStart := A_TickCount
        Loop {
            X1 := Round(rw * 0.4)
            Y1 := Round(rh * 0.4)
            W := Round(rw * 0.9) - X1
            H := rh - Y1

            resUnequip := AdvImageSearch("Resources\unequip.png", X1, Y1, W, H, 0.4, 2)
            if (resUnequip.status == "success" && resUnequip.score > 0.4) {
                if (PixelSearch(&uX, &uY, resUnequip.x-ScaleX(40), resUnequip.y-ScaleY(25), resUnequip.x+ScaleX(40), resUnequip.y+ScaleY(25), 0x7A797A, 5)) {
                    Click(resUnequip.x, resUnequip.y)
		    MouseMove(resUnequip.x, resUnequip.y-ScaleY(80))
                    failCount := 0
                    break
                } else {
                    failCount++
                    if (failCount >= 5) {
                        break 2
                    }
                    Sleep(200)
                    continue
                }
            } else {
                failCount++
                if (failCount >= 3) {
                    break 2
                }
            }
            if (A_TickCount - InnerStart > 3000)
                break
            Sleep(200)
        }
        Sleep(400)
    }
    
    Loop Parse, towers, ","
    {
        ActivateRoblox()
        tower := Trim(A_LoopField)

        goldtower := RegExMatch(tower, "i)\b(Golden|G\.|G)\b") ? true : false
        regulartower := RegExMatch(tower, "i)\b(Regular|R\.|R)\b") ? true : false

        towerToEnter := RegExReplace(tower, "i)\b(Golden|G\.|G|Regular|R\.|R)\b\s*")
        towerToEnter := Trim(towerToEnter) 

        Click(sX, sY)
        Sleep(150)

        SendText(towerToEnter)
        Sleep(500)
        Click(sX+10, ScaleY(409))
        Sleep(500)

        X1 := Round(rw * 0.4)
        Y1 := Round(rh * 0.5)
        W := Round(rw * 0.9) - X1
        H := rh - Y1

        TowerStart := A_TickCount
        Loop {
            resEquip := AdvImageSearch("Resources\equip.png", X1, Y1, W, H, 0.4, 2)

            if (resEquip.status == "success" && resEquip.score > 0.4) {
                If (PixelSearch(&eX, &eY, resEquip.x-40, resEquip.y-25, resEquip.x+40, resEquip.y+25, 0x45DC4A, 7)) {
                    Click(resEquip.x, resEquip.y)
                    
                    if (goldtower) {
                        GoldStart := A_TickCount
                        Loop {
                            resGolden := AdvImageSearch("Resources\notgolden.png", X1, Y1, W, H, 0.4, 2) 
                            if (resGolden.status == "success" && resGolden.score > 0.55) {
                                If (PixelSearch(&eX, &eY, resGolden.x-40, resGolden.y-25, resGolden.x+40, resGolden.y+25, 0x1E1E1E, 4)) {
                                    Click(resGolden.x, resGolden.y)
                                    Sleep(300)
                                    break
                                }
                            }
                            if (A_TickCount - GoldStart > 1000)
                                break
                            Sleep(400)
                        }
                    }
                    
                    if (regulartower) {
                        RegStart := A_TickCount
                        Loop {
                            resGolden := AdvImageSearch("Resources\golden.png", X1, Y1, W, H, 0.4, 2) 
                            if (resGolden.status == "success" && resGolden.score > 0.55) {
                                If (PixelSearch(&eX, &eY, resGolden.x-40, resGolden.y-25, resGolden.x+40, resGolden.y+25, 0xFFC11F, 8)) {
                                    Click(resGolden.x, resGolden.y)
                                    Sleep(300)
                                    break
                                }
                            }
                            if (A_TickCount - RegStart > 1000)
                                break
                            Sleep(400)
                        }
                    }
                    break
                }
                Sleep(100)
            }
            if (A_TickCount - TowerStart > 5000)
                break
            Sleep(400)
        }
        Sleep(400)
    }
    X1 := Round(rw * 0.2)
    Y1 := 0
    W := Round(rw * 1) - X1
    H := Round(rh * 0.4) - Y1
    resclose := AdvImageSearch("Resources\close.png", X1, Y1, W, H)

    If (resclose.status = "success" && resclose.score >= 0.86) {
        Click(resclose.x, resclose.y)
    } else if (savedCloseX != 0 && savedCloseY != 0) {
        Click(savedCloseX, savedCloseY)
    }
    
    LogToConsole("Successfully equipped towers: " towers, true, false)
}

CheckRestart() {
    global IsRestarting, difficulty, UseRestartBtn, UsePlayAgainBtn, CollectPlaytimeRewards

    shouldCollectRewards := (CollectPlaytimeRewards = "1" || CollectPlaytimeRewards = 1) && CheckDailyRewardTime() && (AutorunStartTime = 0 || (A_TickCount - AutorunStartTime) > 300000)
    
    if (shouldCollectRewards) {
        LogToConsole("Navigating to lobby to check playtime rewards", true, false)
        IsRestarting := false
        CloseRoblox()
        RunRoblox()
        JoinGame()
        return
    }

    if WinExist("ahk_exe RobloxPlayerBeta.exe") {
        ActivateRoblox()
        Sleep(1500)
        ActivateRoblox()
        getRobloxPos(,, &w, &h)
        
        resRevive := AdvImageSearch("Resources\use_revive_ticket.png", Integer(w * 0.2), Integer(h * 0.2), Integer(w * 0.6), Integer(h * 0.7))

        if (resRevive.status == "success" && resRevive.score > 0.7) {
            resCancel := AdvImageSearch("Resources\cancel.png", Integer(w * 0.2), Integer(h * 0.2), Integer(w * 0.6), Integer(h * 0.7))
            
            if (resCancel.status == "success" && resCancel.score > 0.7) {
                WinActivate("ahk_exe RobloxPlayerBeta.exe")
                WinWaitActive("ahk_exe RobloxPlayerBeta.exe", , 1)
                Click(resCancel.x, resCancel.y)
                Sleep 250
            }
        }

        if (UseRestartBtn = "1" || UseRestartBtn = 1) {
            resRestart := AdvImageSearch("Resources\Restart.png", 0, Integer(h * 0.5), w, Integer(h * 0.6), 0.5, 1.5)
            resRestart2 := AdvImageSearch("Resources\Restart2.png", 0, Integer(h * 0.5), w, Integer(h * 0.6), 0.5, 1.5)

            if ((resRestart.status == "success" && resRestart.score > 0.64) || (resRestart2.status == "success" && resRestart2.score > 0.64)) {
                res := resRestart.score > 0.64 ? resRestart : resRestart2
                IsRestarting := true
                LogToConsole("Restarting the match")
                Click(res.x, res.y)
                Sleep(150)
                return
            }
        }

        if (UsePlayAgainBtn = "1" || UsePlayAgainBtn = 1) {
            resReplay := AdvImageSearch("Resources\PlayAgain.png", 0, Integer(h * 0.5), w, Round(h*0.6), 0.5, 1.5, 0.02)
            
            if (resReplay.status == "success" && resReplay.score > 0.64) {
                Click(resReplay.x, resReplay.y)
                Sleep(150)
                WaitForLobbyLoad()
                return
            }
        }
    }

    IsRestarting := false
    CloseRoblox()
    RunRoblox()
    JoinGame()
}

RunRoblox(doReload := true) {
    global VipLink, UseVipServer
    PlaceID := "3260590327"

    Loop {
        if ((UseVipServer = "1" || UseVipServer = 1) && VipLink != "") {
            if InStr(VipLink, "privateServerLinkCode=") {
                RegExMatch(VipLink, "privateServerLinkCode=([a-fA-F0-9]+)", &f)
                DeepLink := "roblox://placeID=" PlaceID "&linkcode=" f[1]
            } else if InStr(VipLink, "share?code=") {
                RegExMatch(VipLink, "code=([a-fA-F0-9]+)", &f)
                DeepLink := "roblox://navigation/share_links?code=" f[1] "&type=Server"
            } else {
                DeepLink := "roblox://placeID=" PlaceID
            }
        } else {
            DeepLink := "roblox://placeID=" PlaceID
        }

        Run(DeepLink)
        if !WinWait("ahk_exe RobloxPlayerBeta.exe", , 60) {
            LogToConsole("Roblox not started, retrying again...", true, false)
            continue
        }
        ActivateRoblox()
        ExitFullScreen()
        WinMinimize("ahk_exe RobloxPlayerBeta.exe")
        WinMaximize("ahk_exe RobloxPlayerBeta.exe")
        ActivateRoblox()

        startTime := A_TickCount
        getRobloxPos(,,&w,&h)
        Loop {
            ActivateRoblox()

            if (A_TickCount - startTime > 60000) {
                if (doReload) {
                    SafeReload()
                } else {
                    return false
                }
            }

            res0 := AdvImageSearch("Resources/Play.png", Round(w * 0.25), Round(h * 0.66), Round(w * 0.75), Round(h * 0.34), 0.6, 1.4)
            if (res0.status = "success" && res0.score > 0.65) {
                break
            } 
            Sleep(1500)
        }
        SendEvent("{sc00F}")
        return true 
    }
}

ExitFullScreen() {
    if WinExist("ahk_exe RobloxPlayerBeta.exe") {
        ActivateRoblox()
        style := WinGetStyle("ahk_exe RobloxPlayerBeta.exe")
        if !(style & 0xC00000) {
            SendEvent("{F11}")
            Sleep(500)
        }
        WinRestore("ahk_exe RobloxPlayerBeta.exe")
        ActivateRoblox()
    }
}

CloseRoblox() {
	
	if (hwnd := GetRobloxHWND())
	{
        getRobloxPos(,,,&windowHeight)
		GetRobloxClientPos(hwnd)
		if (windowHeight >= 500) 
		{
			ActivateRoblox()
			PrevKeyDelay := A_KeyDelay
			SetKeyDelay 500
			send "{" SC_Esc "}{" SC_L "}{" SC_Enter "}"
			SetKeyDelay PrevKeyDelay
		}
		try WinClose "Roblox"
		Sleep 500
		try WinClose "Roblox"
		Sleep 4500 
	}
	
	for p in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name LIKE '%Roblox%' OR CommandLine LIKE '%ROBLOXCORPORATION%'")
		ProcessClose p.ProcessID
}

resetCharacter() {
	if (hwnd := GetRobloxHWND())
	{
        getRobloxPos(,,,&windowHeight)
		GetRobloxClientPos(hwnd)
		if (windowHeight >= 500) 
		{
			ActivateRoblox()
			PrevKeyDelay := A_KeyDelay
			SetKeyDelay 500
			send "{" SC_Esc "}{" SC_R "}{" SC_Enter "}"
			SetKeyDelay PrevKeyDelay
		}
	}
}

SwitchToNextStrategy(&stratName) {
    global CurrentRotationIndex, Strategy1Path, Strategy2Path, requiredTowers
    global CurrentStratStartTime, CurrentRunCount, StateFile, RunningStrategy, difficulty

    if (CurrentRotationIndex = 1) {
        LoadStrategyFile(Strategy2Path)
        CurrentRotationIndex := 2
        IniWrite(2, StateFile, "State", "CurrentRotationIndex")
        stratName := Strategy2Path 
    } else {
        LoadStrategyFile(Strategy1Path)
        CurrentRotationIndex := 1
        IniWrite(1, StateFile, "State", "CurrentRotationIndex")
        stratName := Strategy1Path
    }

    CurrentStratStartTime := A_TickCount
    CurrentRunCount := 0
    IniWrite(A_TickCount, StateFile, "State", "CurrentStratStartTime")
    IniWrite(0, StateFile, "State", "CurrentRunCount")

    IniWrite(1, StateFile, "State", "Running")
    IniWrite(stratName, StateFile, "State", "Strategy")

    return true
}

WaitForLobbyLoad() {
    global difficulty

    SetTimer(CheckPopups, 0)

    startTime := A_TickCount
    if (difficulty != "Pizza Party" && difficulty != "Badlands II" && difficulty != "Polluted Wasteland II") {
        Sleep(6000)
        Loop {
            if (A_TickCount - startTime > 60000) {
                SafeReload()
            }
            getRobloxPos(,,&w,&h)
            res := AdvImageSearch("Resources/Ready.png", Round(w * 0.25), Round(h * 0.66), Round(w * 0.5), Round(h * 0.34), 0.6, 1.7)
            if (res.status = "success" && res.score >= 0.65) {
                break
            }
            Sleep(100)
        }
        SelectMap(res.x, res.y)
    }
}

JoinGame() {
    global SendCurrenciesEnabled, WebhookEnabled, difficulty, CollectPlaytimeRewards
    getRobloxPos(,, &w, &h)

    isHardcore := (difficulty = "Hardcore" || difficulty = "Voidcore")
    
    startTime := A_TickCount
    Loop {
        if (A_TickCount - startTime > 80000) { 
            SafeReload()
            break
        }

        x1 := Round(w * 0.25)
        y1 := Round(h * 0.66)
        x2 := Round(w * 0.75)
        y2 := Round(h * 0.34)
        
        res := AdvImageSearch("Resources\Play.png", x1, y1, x2, y2, 0.6, 1.4)
        if (res.status == "success" && res.score > 0.65) {
            if (!isHardcore) {
                ActivateRoblox()
            }
            if (CollectPlaytimeRewards = "1" || CollectPlaytimeRewards = 1) {
                claimPlaytimeRewards()
            }
            
            LowerGraphics()
            Sleep(50)
            LogToConsole("Joining " difficulty "...", true, false)
            
            Click(res.x, res.y)
            break
        }
        Sleep(500)
    }
    Sleep(300)

    startTime := A_TickCount
    modeImg := ""

    if (difficulty = "Pizza Party" || difficulty = "Badlands II" || difficulty = "Polluted Wasteland II") {
        modeImg := "SpecialMode.png"
    }

    if modeImg != "" {
        Loop {
            if (A_TickCount - startTime > 20000) {
                newStartTime := A_TickCount
                res := AdvImageSearch("Resources\Play.png", x1, y1, x2, y2, 0.6, 1.4)
                if (res.status == "success" && res.score > 0.65) {   
                    Click(res.x, res.y)
                    startTime := A_TickCount
                } else {
                    if (A_TickCount - newStartTime > 40000) {
                        SafeReload()
                        break
                    }
                }
            }

            res := AdvImageSearch("Resources/" modeImg, 0, 0, w, h, 0.5, 1.5)
            if (res.status = "success" && res.score >= 0.67) {
                Click(res.x, res.y)
                break 
            }
            Sleep(500)
        }
        Sleep(300)
    }

    startTime := A_TickCount
    Loop {
        if (A_TickCount - startTime > 20000) {
            newStartTime := A_TickCount
            res := AdvImageSearch("Resources\Play.png", x1, y1, x2, y2, 0.6, 1.4)
            if (res.status == "success" && res.score > 0.7) {   
                Click(res.x, res.y)
                startTime := A_TickCount
            } else {
                if (A_TickCount - newStartTime > 40000) {
                    SafeReload()
                    break
                }
            }
        }
        res := AdvImageSearch("Resources/" difficulty ".png", 0, 0, w, h,0.5,1.5)
        if (res.status = "success" && res.score >= 0.7) {
            Click(res.x, res.y)
            break 
        }
        Sleep(500)
    }
    Sleep(500)

    startTime := A_TickCount
    Loop {
        if (A_TickCount - startTime > 40000) { 
            SafeReload()
            break
        }
        res := AdvImageSearch("Resources/Solo.png", 0, Round(h * 0.2), Round(w * 0.7), Round(h * 0.55),0.5,1.5)
        if (res.status = "success" && res.score >= 0.7) {
            Click(res.x, res.y)
            break 
        }
        Sleep(500)
    }
    WaitForLobbyLoad()
}

SelectMap(readyX := ScaleX(963), readyY := ScaleY(838)) {
    global gamemap, difficulty, modifiers, CheckTheMap

    getRobloxPos(,,&w,&h)
    readyX := Round(w*0.5)

    LogToConsole("Selecting map: " gamemap, true, false)
    Sleep(100)
    closeChat()

    if (difficulty = "Hardcore" || difficulty = "Voidcore") {
        image := A_WorkingDir "/Resources/map_selection.png"

        foundObject := false

        Loop 3 {
            getRobloxPos(&x, &y, &w, &h)
            res := AdvImageSearch(image, 0,0,Round(w/2),h)
            if (res.status == "success" && res.score >= 0.51) { 
                foundObject := true
                break 
            }
            Sleep(500)
        }

        if (!foundObject) {
            LogToConsole("Wrong camera position!")
            SendEvent("{Left down}")
            Sleep(1500) 
            SendEvent("{Left up}")
            Sleep(50)
        }
    } else {
        ActivateRoblox()
        resetCharacter()
        Sleep(7500)
        AlignCamera(false, false)
    }
    
    if (difficulty = "Hardcore" || difficulty = "Voidcore") {
        attempts := 0

        SendEvent("{o down}")
        Sleep(100)
        SendEvent("{o up}")

        Loop {
            Sleep(200)
            ActivateRoblox()
            Sleep(600)
            SendEvent("{sc011 down}")  
            Sleep(3390)
            SendEvent("{sc011 up}")
            Sleep(300)

            LogToConsole("Trying to find: " gamemap ". Please wait..")

            getRobloxPos(,,&w,&h)
            FoundSlot := 0
            regions := [[0, 0, Floor(w * 0.3307), Floor(h * 0.6)],
            [Floor(w * 0.3307), 0, Floor(w * 0.1729), Floor(h * 0.6)],
            [Floor(w * 0.5036), 0, Floor(w * 0.1729), Floor(h * 0.6)],
            [Floor(w * 0.6765), 0, w - Floor(w * 0.6765), Floor(h * 0.6)]]

            langCode := "en-US"
            for availableLang in StrSplit(OCR.GetAvailableLanguages(), "`n", "`r") {
                if (availableLang != "" && SubStr(availableLang, 1, 2) = "en") {
                    langCode := availableLang
                    break
                }
            }

            Loop 4 {
                r := regions[A_Index]
                pBmp := Gdip_BitmapFromScreen(r[1] "|" r[2] "|" r[3] "|" r[4])
                result := OCR.FromBitmap(pBmp, {lang:langCode, scale:1.5}).Text
                Gdip_DisposeImage(pBmp)
                if RegExMatch(result, "i)\b" . gamemap . "\b") {
                    FoundSlot := A_Index
                    break
                }
            }
            
            if (attempts >= 5) {
                LogToConsole("Map is not found after 5 attempts! Reloading...", true)
                SafeReload()
            }

            if (FoundSlot = 0) {
                LogToConsole("Map is not found! Resetting...", true, false)
                resetCharacter()
                Sleep(8000)
                attempts++
                SendEvent("{Left down}")
                Sleep(1500) 
                SendEvent("{Left up}")
                Sleep(50)
                continue
            } else {
                LogToConsole(gamemap " found in slot " FoundSlot,true,false)
                break
            }
        }

        Sleep(300)
        ActivateRoblox()
        Sleep(100)

        SendEvent("{sc011 down}")  
        Sleep(500)
        SendEvent("{sc011 up}")
        Sleep(200)

        if (FoundSlot = 1) { 
            SendEvent("{sc01e down}")
            Sleep(1400)
            SendEvent("{sc01e up}")
            Sleep(600) 
        } else if (FoundSlot = 2) { 
            SendEvent("{sc01e down}")
            Sleep(500)
            SendEvent("{sc01e up}")
            Sleep(600) 
        } else if (FoundSlot = 3) { 
            SendEvent("{sc020 down}")
            Sleep(500)
            SendEvent("{sc020 up}")
            Sleep(600) 
        } else if (FoundSlot = 4) { 
            SendEvent("{sc020 down}")
            Sleep(1400)
            SendEvent("{sc020 up}")
            Sleep(600) 
        }

        if (modifiers != "")
            ApplyModifiers()

        SendEvent("{sc012 down}")  
        Sleep(1000)
        SendEvent("{sc012 up}")
        Sleep(100)
    } else {
        ActivateRoblox()
        Sleep(150)
        SendEvent("{sc01f down}") 
        Sleep(1900)
        SendEvent("{sc01f up}")
        Sleep(700)
        SendEvent("{sc01e down}") 
        Sleep(1800)
        SendEvent("{sc01e up}")
        Sleep(700)

        Loop 3 {
            e_pr := AdvImageSearch("Resources\e_prompt.png", 0, 0, w, h,1,1)

            if (e_pr.score >= 0.75) {
                break
            } else {
                Sleep(150)
            }
        }

        if !(e_pr.score >= 0.75) {
            LogToConsole("The macro can't see the E prompt (" e_pr.score "), retrying again... ", true) 
            SelectMap(readyX, readyY)
            return
        }

        SendEvent("{sc012 down}") 
        Sleep(1000)
        SendEvent("{sc012 up}")
        Sleep(500)

        foundsearchbar := false
        getRobloxPos(&x, &y, &w, &h)
        Loop 2 {
            res := AdvImageSearch("Resources/searchbar.png", Round(w*0.1),0,Round(w*0.6),h,0.5,1.5)
            
            if (res.status = "success" && res.score >= 0.6)  { 
                Click(res.x, res.y)
                foundsearchbar := true 
                break
            } 
            Sleep(500)
        }

        if (!foundsearchbar) {
            LogToConsole("Can not found the search bar in the override map menu! Retrying..", true)
            SelectMap(readyX, readyY, )
            return 
        }        

        Sleep(100)
        SendText(gamemap)
        Loop {
            Sleep(300)
            if (InArray(SpecialMaps, gamemap)) {
                SelectionICON := AdvImageSearch("Resources/Maps/" gamemap "_Selection.png", Round(w*0.1),0,Round(w*0.7),h,0.5,1.5)
            
                if (SelectionICON.score >= 0.65)  { 
                    Click(SelectionICON.x, SelectionICON.y)
                } else {
                    Click(res.x - ScaleX(90), res.y + 80)
                }
            } else {
                Click(res.x - ScaleX(90), res.y + 80)
            }
            Sleep(400)

            changedMap := false
            alrinRotation := false
            Loop 2 {
                if PixelSearch(&gx, &gy, Round(w*0.2), Round(h*0.24), Round(w*0.7), Round(h*0.3), 0x00EC00, 3) {
                    LogToConsole("Successfully changed the map to " gamemap,true,false)
                    changedMap := true
                    break
                }

                Sleep(200)
            }

            if (changedMap) {
                break
            }

            if (ReadMessage(["already", "current", "rotation"])) {
                LogToConsole(gamemap " is already in the current rotation. Clicking veto..", true)
                resVeto := AdvImageSearch("Resources\Veto.png", 0, 0, w, h,0.5,1.5)
                if (resVeto.status == "success" && resVeto.score > 0.65) {
                    MouseMove(resVeto.x, resVeto.y)
                    Sleep(30)
                    MouseClick
                } else {
                    MouseMove(ScaleX(1152), ScaleY(834))
                    Sleep(30)
                    MouseClick
                }
                Sleep(300)
                Send("{" SC_E " down}")
                Sleep(760)
                Send("{" SC_E " up}")

                alrinRotation := false
                Sleep(400)
                continue
            }

            if (!changedMap) {
                LogToConsole("Failed to change the map to " gamemap, true)
                SafeReload()
            } else {
                break
            }
        }

        if (modifiers != "")
            ApplyModifiers()

        Sleep(200)
        ActivateRoblox()
        Sleep(100)
        SendEvent("{sc020 down}") 
        Sleep(1800)
        SendEvent("{sc020 up}")
        Sleep(200)
        SendEvent("{sc01f down}") 
        Sleep(1680)
        SendEvent("{sc01f up}")
        Sleep(300)
        SendEvent("{sc020 down}") 
        Sleep(1100)
        SendEvent("{sc020 up}")
        Sleep(600)
        Loop 3 {
            e_pr := AdvImageSearch("Resources\e_prompt.png", 0, 0, w, h,0.6,1.5)

            if (e_pr.score >= 0.65) {
                break
            } else {
                Sleep(150)
            }
        }

        if !(e_pr.score >= 0.7) {
            LogToConsole("The macro can't see the E prompt (" e_pr.score "), retrying again... ", true) 
            SafeReload()
        }

        SendEvent("{sc012 down}") 
        Sleep(800)
        SendEvent("{sc012 up}")
    }
    Sleep(100)

    Click(readyX, readyY)
    Sleep(10000)

    if (FileExist("Resources\Maps\" . gamemap . ".png") && CheckTheMap = 1 && !InArray(SpecialMaps, gamemap) && !RegExMatch(modifiers, "i)fog"))
    {
        AlignCamera(false, true, false)
        getRobloxPos(,,&w,&h)
        FoundMap := false
        Loop 2 {
            res := AdvImageSearch("Resources\Maps\" gamemap ".png", 0, 0, w, h, 0.5, 2)

            if (res.score > 0.7) {
                FoundMap := true
                break
            }
            
            Sleep(1250)
        }

        if (!FoundMap) {
            LogToConsole("Can't detect the map! Reloading script...", true)
            SafeReload()
        }
    }

    if (InArray(SpecialMaps, gamemap)) {
        functionName := gamemap . "Path"

        %functionName%() 
    }

}

ApplyModifiers() {
    global modifiers
    LogToConsole("Setting up modifiers: " modifiers)
    Click(56, ScaleY(930))

    Sleep(300)

    searchX := ScaleX(951)
    searchY := ScaleY(262)

    foundsearchbar := false
    getRobloxPos(&x, &y, &w, &h)
    Loop 2 {
        res := AdvImageSearch("Resources/searchbar_modifiers.png", Round(w*0.1),0,Round(w*0.7),Round(h*0.6), 0.5, 1.5)
        
        if (res.status = "success" && res.score >= 0.7)  { 
            searchX := res.x
            searchY := res.y
            foundsearchbar := true 
            break
          } 
        Sleep(500)
    }

    Loop Parse, modifiers, "," {
        modifier := Trim(A_LoopField)
        if (modifier = "") {
            continue
        }
        Click(searchX, searchY)
        Sleep(100)
        SendText(modifier)
        Sleep(100)
        Click(Round(w/2), searchY+ScaleY(80))
        Sleep(50)
        LogToConsole("Modifier added: " modifier)
    }
    Sleep(100)
    Click(ScaleX(1122), ScaleY(853))
    LogToConsole("All modifiers configured")
}

ClickReady(x,y) {
    MouseMove(x, y)
    Sleep 50
    LogToConsole("Pressed the ready button")
    Loop 3 { ;loop acts as a failsafe
    MouseClick()
    }
    Click(x, y)
}

waitReady(&fx,&fy) {
    getRobloxPos(&x, &y, &w, &h)
    Loop {
        if PixelSearch(&fx, &fy, Round(w*0.4),Round(h*0.05), Round(w*0.7), Round(h*0.35), 0x2BEB00, 4) {
            break
        } else {
            Sleep(50)
        }
    }
}


activateTimescale() {
    global UseTimeScale, TimeScaleMode, TimeScaleMultiplier, difficulty, SettingsFile, AutorunStartTime
    getRobloxPos(&x, &y, &w, &h)
    if (UseTimeScale && difficulty != "Pizza Party" && difficulty != "Badlands II" && difficulty != "Polluted Wasteland II") { 
        LogToConsole("Applying timescale: " TimeScaleMode ". Please, enable UI Navigation Toggle.")
        Click(Round(w*0.5), Round(h*0.5))

        Send("{sc02B}")
        Sleep 50
        Loop 10 {
            Send("{Down}")
            Sleep 10
        }
        Loop 20 {
            Send("{Left}")
            Sleep 10
        }
        Send("{Right}")
        Sleep 10
        Send("{Enter}")

        Sleep(100)

        res := AdvImageSearch("Resources/GetMore.png", Round(w * 0.25), Round(h * 0.45), Round(w * 0.50), Round(h * 0.55), 0.75, 1)
        if (res.status = "success" && res.score >= 0.67) {
            Click(res.x, res.y+55)
            LogToConsole("Failed to activate timescale! You are out of tickets.", true, false)
        } else {
            res := AdvImageSearch("Resources/confirm.png", Round(w * 0.25), Round(h * 0.45), Round(w * 0.50), Round(h * 0.55), 0.75, 1)
            if (res.status = "success" && res.score >= 0.67) {
                Click(res.x, res.y)
            } else {
                LogToConsole("failed to activate timescale. the macro can't see the confirm button...", true)
                SafeReload()
            }

            timescales := IniRead(StateFile, "State", "Timescale", 0)
            timescales := timescales+1
            LogToConsole("-1 Timescale ticket. Total Timescale Tickets Used: " timescales)
            SendToWebhookInstant("[" runtime := FormatRuntime(AutorunStartTime) "] -1 Timescale ticket. `n-# Total Timescale Tickets Used: " . timescales, 12370112, false)
            IniWrite(timescales, StateFile, "State", "Timescale")

            Sleep(250)
            if (TimeScaleMode = "2x") {
                Loop 2 {
                    Sleep(20)
                    Send("{Enter}")
                }
            } else if (TimeScaleMode = "1.5x") {
                Sleep(20)
                Send("{Enter}")
            }
        }

        Send("{sc02B}")
    }
}

AlignCamera(move := true, skipZoom := false, log := true) {
    global MoveEnabled, MoveDirection, MoveDuration, IsRestarting
    if (IsRestarting)
        return
    if (log) {
        LogToConsole("Aligning camera")
    }
    closeChat()
    Sleep(200)
    MouseMove(ScaleX(1339), ScaleY(236))
    Sleep(150)
    Click("Right Down")
    MouseMove(0, ScaleY(1200), 1 + A_DefaultMouseSpeed, "R")
    Sleep(250)
    Click("Right Up")
    If (!skipZoom) {
        Sleep(200)
        SendEvent("{o down}")
        Sleep(500)
        SendEvent("{o up}")
        Sleep(200)
        SendEvent("{o down}")
        Sleep(500)
        SendEvent("{o up}")
    }
    Sleep(200)
    if (MoveEnabled && !IsRestarting && move) {
        SendEvent("{" MoveDirection " down}")
        Sleep(MoveDuration)
        SendEvent("{" MoveDirection " up}")
    }
}

getSlots() {
    static cachedSlotsState := ""
    
    if (cachedSlotsState != "") {
        return cachedSlotsState
    }
    
    numbers := Map(
        1, A_WorkingDir "\Resources\1.png",
        2, A_WorkingDir "\Resources\2.png",
        3, A_WorkingDir "\Resources\3.png",
        4, A_WorkingDir "\Resources\4.png",
        5, A_WorkingDir "\Resources\5.png"
    )
    
    Ys := ScaleY(960)
    x1 := ScaleX(800)
    x2 := ScaleX(880)
    x3 := ScaleX(960)
    x4 := ScaleX(1040)
    x5 := ScaleX(1120)

    currentSlotsState := Map(
        1, [x1, Ys], 
        2, [x2, Ys], 
        3, [x3, Ys], 
        4, [x4, Ys], 
        5, [x5, Ys]
    )

    getRobloxPos(&x, &y, &w, &h)
    offsetY := Integer(h * 0.8)
    endY := Integer(h * 0.17)
    endX := Integer(w* 0.75)

    startX := Integer(w*0.15)
    
    for digit, Image in numbers {
        if (!Image)
            continue
            
        Variation := 10 

        Result := AdvImageSearch(Image, startX, offsetY, endX, endY, 0.75, 2)
        
        if (Result.status == "success" && Result.score >= 0.84) {
            startX := Result.x+ScaleX(70)
            endY := Result.y+ScaleY(40)-offsetY
            endX := Integer(w* 0.1)

            currentSlotsState[digit] := [Result.x+ScaleX(15), Result.y+ScaleY(20)]
        }
    }

    cachedSlotsState := currentSlotsState
    return cachedSlotsState
}


SpawnTower(X, Y, slotNumber, towerID) {
    global Towers, LastOpenedTowerID, CancelPlacementKey, canUseAbility
    LogToConsole("Placing tower " towerID " (slot " slotNumber ") at x:" X " y:" Y "...")

    X := sX(X, StrategyWidth)
    Y := sY(Y, StrategyHeight)
    
    TowerY := Y+40
    getRobloxPos(,,,&h)
    if (Y < h * 0.55) {
        TowerY := Y - ScaleY(3)
    }
    if (Y > h * 0.45) {
        TowerY := Y + ScaleY(3)
    }

    attemptMultiplier := 1
    startTime := A_TickCount
    canUseAbility := false

    Loop {
        if (A_TickCount - startTime > 300000) {
            LogToConsole("Tower placement timed out (5+ minutes). Reloading the macro...")
            SafeReload()
            return
        }

        ActivateRoblox()
        
        Send("{" slotNumber "}")
        Sleep(30)
        
        MouseMove(X, Y, A_DefaultMouseSpeed)
        Sleep((PotatoMode = 1) ? 100 : 40)
        MouseClick()
        Sleep(100)
        SendEvent("{" CancelPlacementKey "}")

        placedSuccessfully := waitForTowerUI(&resV2)

        if (placedSuccessfully) {
            Towers[towerID] := {x: X, y: TowerY, slot: Integer(slotNumber), level: 0, path: 0, pathLevel: 0}
            LogToConsole("Tower " towerID " placed successfully")
            LastOpenedTowerID := towerID
            break
        } else {
            LogToConsole("Tower " towerID " placement failed, retrying...")
            if (ReadMessage(["cannot", "here", "hereg", "herd", "her"],,["need", "more", "to"],"\$|\d")) {
                MouseClick()

                placedSuccessfully := waitForTowerUI(&resV2)
                if (placedSuccessfully) {
                    Towers[towerID] := {x: X, y: TowerY, slot: Integer(slotNumber), level: 0, path: 0, pathLevel: 0}
                    LogToConsole("Tower " towerID " placed successfully")
                    LastOpenedTowerID := towerID
                    break
                }

                offsets := [[0, -5 * attemptMultiplier], [5 * attemptMultiplier, 0], [0, 5 * attemptMultiplier], [-5 * attemptMultiplier, 0]]
                placedSuccessfully := false

                ActivateRoblox()
        
                Send("{" slotNumber "}")
                Sleep(30)
                
                for index, offset in offsets {
                    if (A_TickCount - startTime > 300000) {
                        LogToConsole("Tower placement timed out during offset retry. Executing safereload()...")
                        safeReload()
                        return
                    }

                    newX := X + offset[1]
                    newY := Y + offset[2]
                    
                    MouseMove(newX, newY, A_DefaultMouseSpeed)
                    Sleep((PotatoMode = 1) ? 100 : 40)
                    MouseClick()
                    Sleep(100)

                    placedSuccessfully := waitForTowerUI(&resV2)
                    if (placedSuccessfully) {
                        Towers[towerID] := {x: newX, y: newY, slot: Integer(slotNumber), level: 0, path: 0, pathLevel: 0}
                        LogToConsole("Tower " towerID " placed successfully")
                        LastOpenedTowerID := towerID
                        break 2
                    }
                }
                
                if (!placedSuccessfully) {
                    SendEvent("{" CancelPlacementKey "}")
                    attemptMultiplier := attemptMultiplier * 2
                }
            } 
        }
    }
    canUseAbility := true
}

SellTower(towerID) {
    global Towers, unfocusX, unfocusY

    if (!Towers.Has(towerID)) {
        LogToConsole("Tower " towerID " not found for selling!")
        return false
    }

    LogToConsole("Selling tower " towerID "...")
    targetX := Towers[towerID].x
    targetY := Towers[towerID].y
    Click(targetX, targetY)
    Sleep(400)

    attempts := 0
    Loop {
        menuFound := false
        Loop 30 {
            if PixelSearch(&mx, &my, 1257, 513, 1340, 574, 0x275C7E, 5) { 
                Sleep(20)
                continue 
            }
            menuFound := true
            break
        }
        if (!menuFound) {
            attempts++
            if (attempts > 15) {
                LogToConsole("Tower " towerID " menu not found for selling")
                return false
            }
            variation := Random(-10, 10)
            Click(Towers[towerID].x, Towers[towerID].y + variation)
            Sleep(400)
            continue
        }
        Click(796, 871)
        LogToConsole("Tower " towerID " sold successfully")
        if (Towers[towerID].hwnd) {
            WinClose("ahk_id " Towers[towerID].hwnd)
        }
        Towers.Delete(towerID)
        return true
    }
    return false
}

UpgradeTower(towerID, skipOpen := false, totalUpgrades := 1, path := 0, pathLevel := 0) {
    global Towers, unfocusX, unfocusY, LastOpenedTowerID
    global PotatoMode, Recording, RecordedSteps, Commander, canUseAbility

    if (!Towers.Has(towerID)) {
        LogToConsole("Tower " towerID " not found!")
        return false
    }

    targetX := Towers[towerID].x
    targetY := Towers[towerID].y

    if (!skipOpen && LastOpenedTowerID != towerID) {
        canUseAbility := false
        MouseMove(targetX, targetY)
        Sleep(20)
        MouseClick()
        Sleep((PotatoMode = 1) ? 400 : 250)
        canUseAbility := true
    }

    LastOpenedTowerID := towerID
    upgradesDone := 0
    attempts := 0

    Sleep(20)

    Loop {
        openedSuccessfully := false
        StartTime := A_TickCount
        
        openedSuccessfully := waitForTowerUI(&resV2, &resV1)

        if (!openedSuccessfully) {
            attempts++
            if (attempts > 30) {
                LogToConsole("Tower " towerID " menu not found after 30 attempts, reloading...", true)
                SafeReload()
            }
            variation := Random(-8, 8)
            Click(targetX, targetY + ScaleY(variation))
            Sleep(100)
            continue
        } else {
            attempts := 0
        }

        doResV2 := (IsObject(resV2) && resV2.HasProp("score") && resV2.score > 0.55)

        if (doResV2) {
            UpgradeX := resV2.x+ScaleX(50)
            UpgradeY := resV2.y-ScaleY(220)

            upgAX := resV2.x + ScaleX(20)
            upgAY := resV2.y - ScaleY(240)
            upgAW := ScaleX(80)
            upgAH := ScaleY(70)
        } else {
            UpgradeX := resV1.x-ScaleX(164)
            UpgradeY := resV1.y+ScaleY(383)

            upgAX := resV1.x - ScaleX(194)
            upgAY := resV1.y + ScaleY(363)
            upgAW := ScaleX(80)
            upgAH := ScaleY(70)
        }
        
        nextLevel := Towers[towerID].level + 1

        region := [upgAX, upgAY, upgAW, upgAH]

        if (path != 0 && nextLevel > pathLevel && pathLevel != 0) {
            if (path = 2) { 
                if (doResV2) {
                    region := [resV2.x+ScaleX(20), resV2.y-ScaleY(95), ScaleX(80), ScaleY(70)]
                    UpgradeY := resV2.y-ScaleY(120)
                } else {
                    region := [resV1.x - ScaleX(194), resV1.y + ScaleY(508), ScaleX(80), ScaleY(70)]
                    UpgradeY := resV1.y + ScaleY(483)
                }
            }
        } 

        XA := region[1]
        YA := region[2]
        WA := region[3]
        HA := region[4]

        X2 := XA + WA
        Y2 := YA + HA

        searchArea := XA "|" YA "|" X2 "|" Y2

        try {
            isGreen := PixelSearch(&gx, &gy, XA, YA, X2, Y2, 0x206235, 12)
        } catch Error {
            isGreen := false
        }
        if (isGreen) {
            canUseAbility := false
            if (UseHForUpgrade) {
                if (path != 0 && nextLevel > pathLevel && pathLevel != 0) {
                    if (path = 1) { 
                        SendEvent("{" UpgradeTowerGKey "}")
                    } else if (path = 2) {
                    SendEvent("{" UpgradeTowerGBKey "}")
                    } 
                } else {
                    SendEvent("{" UpgradeTowerGKey "}")
                }
            } else {
                Click(UpgradeX, UpgradeY)
            }

            Sleep((PotatoMode = 1) ? 200 : 110)

            Towers[towerID].level += 1
            upgradesDone++
            LogToConsole("Tower " towerID " upgraded to level " Towers[towerID].level " (" upgradesDone "/" totalUpgrades ")")
            UpdateTowerIndicator(towerID)

            if (Towers[towerID].level >= 2 && RegExMatch(towerID, "i)^Commander\d*$") && !Commander) {
                Commander := true
                if (Recording && !HasStep("Commander := true"))
                    RecordedSteps.Push("Commander := true")
            }

            if (upgradesDone >= totalUpgrades) 
                return true

            canUseAbility := true
            continue
        }
    }
}

isDisconnected() {
    w := A_ScreenWidth
    h := A_ScreenHeight
    
    getRobloxPos(,, &w, &h)
    ActivateRoblox()

    if (!w || !h || w <= 0 || h <= 0) {
        w := A_ScreenWidth
        h := A_ScreenHeight
    }

    oldMode := A_CoordModePixel
    CoordMode("Pixel", "Screen")
    
    try {
        if ImageSearch(&FoundX, &FoundY, 0, 0, w, h, "*26 " "Resources\Disconnected.png") {
            CoordMode("Pixel", oldMode)
            TryReconnect()
        } else if ImageSearch(&FoundX, &FoundY, 0, 0, w, h, "*26 " "Resources\disconnected2.png") {
            CoordMode("Pixel", oldMode)
            TryReconnect()
        }
    } catch Error as err {
        CoordMode("Pixel", oldMode)
    }
    
    CoordMode("Pixel", oldMode)
}


TryReconnect() {
    attempts := 0
    Loop {
        attempts++
        LogToConsole("Reconnecting... Attempt " attempts ".", true, false)
        KillSubmacros()
        CloseRoblox()
        if (RunRoblox(false) == false) {
            continue
        } else {
            LogToConsole("Reconnect successful after " attempts " attempts!", true, false)
            startWatchdog()
            break
        }
    }
}

CheckPopups(*) {
    getRobloxPos(,,&w,&h)

    res := AdvImageSearch("Resources/Claim.png", Round(w * 0.25), Round(h * 0.4), Round(w * 0.5), Round(h * 0.5), 0.5, 2)
    if (res.status = "success" && res.score >= 0.65) {
        LogToConsole("Claimed daily reward.")
        Click(res.x, res.y)
    }

    Sleep(2300)

    res2 := AdvImageSearch("Resources/notnow.png", Round(w * 0.25), Round(h * 0.4), Round(w * 0.5), Round(h * 0.5), 0.5, 2)
    if (res2.status = "success" && res2.score >= 0.65) {
        Click(res2.x, res2.y)
    }
}

UseAbilities(*) {
    global ChainKey, BeatKey, CaravanKey, CancelPlacementKey, TimeScaleMultiplier, AutoSkip, AbilitySpam
    global autoChain, autoCaravan, autoDropTheBeat, Commander, unfocusX, unfocusY, canUseAbility
    global LastOpenedTowerID, Towers
    static LastChainTime := 0, LastDropTime := 0, LastCaravanTime := 0

    if (!canUseAbility) {
        return
    }

    caravanInterval := 26
    chainInterval := 14

    if (AbilitySpam = "ON") {
        caravanInterval := 20
        chainInterval := 10
    }

    if (AutoSkip = "ON") {
        res := AdvImageSearch("Resources/Skip.png", Round(A_ScreenWidth * 0.3), 0, Round(A_ScreenWidth * 0.7), Round(A_ScreenHeight * 0.35), 0.5, 1.5)
        if (res.status = "success" && res.score >= 0.65) {
            Sleep(200)
            res := AdvImageSearch("Resources/Skip.png", Round(A_ScreenWidth * 0.3), 0, Round(A_ScreenWidth * 0.7), Round(A_ScreenHeight * 0.35), 0.5, 1.5)
            if (res.status = "success" && res.score >= 0.65) {
                SendEvent("{" CancelPlacementKey "}")
                MouseGetPos(&cx, &cy)
                Click(res.x, res.y)
                Sleep(30)
                MouseMove(cx, cy)
                Sleep(20)
                LogToConsole("Skipped the wave")
            }
        }
    }

    if (autoChain = "ON" && Commander && (A_TickCount - LastChainTime > chainInterval * 1000 / TimeScaleMultiplier)) {
        canUseAbility := false
        if (LastOpenedTowerID != "") {
            Click(ScaleX(unfocusX), ScaleY(unfocusY))
            Sleep(300)
        }
        LastChainTime := A_TickCount
        SendEvent("{" ChainKey "}")
        LogToConsole("Activated Call of Arms")
        canUseAbility := true
        if (LastOpenedTowerID != "") {
            Click(Towers[LastOpenedTowerID].x, Towers[LastOpenedTowerID].y)
        }
    }

    if (autoCaravan = "ON" && Commander && (A_TickCount - LastCaravanTime > caravanInterval * 1000 / TimeScaleMultiplier)) {
        canUseAbility := false
        SendEvent("{" CancelPlacementKey "}")
        if (LastOpenedTowerID != "") {
            Click(ScaleX(unfocusX), ScaleY(unfocusY))
            Sleep(300)
        }
        LastCaravanTime := A_TickCount
        SendEvent("{" CaravanKey "}")
        LogToConsole("Activated Support Caravan")
        if (LastOpenedTowerID != "") {
            Click(Towers[LastOpenedTowerID].x, Towers[LastOpenedTowerID].y)
        }
        canUseAbility := true
    }

    if (autoDropTheBeat = "ON" && Towers.Has("DJ") && Towers["DJ"].level >= 3 && (A_TickCount - LastDropTime > 26000 / TimeScaleMultiplier)) {
        SendEvent("{" CancelPlacementKey "}")
        if (LastOpenedTowerID != "DJ" && LastOpenedTowerID != "") {
            Click(ScaleX(unfocusX), ScaleY(unfocusY))
            Sleep(300)
        }

        LastDropTime := A_TickCount
        SendEvent("{" BeatKey "}")
        LogToConsole("Activated Drop the Beat")
        if (LastOpenedTowerID != "") {
            Click(Towers[LastOpenedTowerID].x, Towers[LastOpenedTowerID].y)
        }
        canUseAbility := true
    }
}

SetDJTrack(track) {
    global Towers, unfocusX, unfocusY, LastOpenedTowerID
    if (!Towers.Has("DJ")) {
        LogToConsole("DJ tower not found!")
        return
    }
    LogToConsole("Setting DJ track to " track "...")
    canUseAbility := false
    
    cleanTrack := StrReplace(track, '"', '')
    cleanTrack := StrReplace(cleanTrack, "'", "")
    trackName  := Format("{:L}", cleanTrack)

    if (LastOpenedTowerID != "DJ")
        Click(Towers["DJ"].x, Towers["DJ"].y)

    Sleep(200)

    Loop {
        getRobloxPos(&rx, &ry, &w, &h)
        startTime := A_TickCount

        openedSuccessfully := waitForTowerUI(&resv2, &resv1)

        if (!openedSuccessfully) {
            variation := Random(-10, 10)
            Click(Towers["DJ"].x, Towers["DJ"].y + ScaleY(variation))
            Sleep(400)
            continue
        }

        Sleep(250)

        DJTrack := resV2 := AdvImageSearch("Resources\" trackName ".png", 0, 0, w, h, 0.5, 1.5, 0.03)
        if (DJTrack.score > 0.6) {
            MouseMove(DJTrack.x, DJTrack.y)
            Sleep(20)
            MouseClick
        }
        break
    }
    canUseAbility := true
}

UpdateTowerIndicator(towerID) {
    global Towers, Recording, ShowIndicators
    if (!Recording || !ShowIndicators || !Towers.Has(towerID))
        return
    level := Towers[towerID].level
    MultiplePaths := (Towers[towerID].path != 0 && Towers[towerID].path != "")

    If (Towers[towerID].HasProp("hwnd") && Towers[towerID].hwnd)
        WinClose("ahk_id " Towers[towerID].hwnd)

    clientLeft := 0
    clientTop := 0
    
    getRobloxPos(,, &clientLeft, &clientTop)
    
    hwnd := GetRobloxHWND()
    pt := Buffer(8, 0)
    DllCall("ClientToScreen", "UPtr", hwnd, "Ptr", pt)
    
    x := NumGet(pt, 0, "Int") + Towers[towerID].x - 16
    y := NumGet(pt, 4, "Int") + Towers[towerID].y - 16

    styleStr := "+ToolWindow +AlwaysOnTop -Caption +Disabled +Border +E0x20 +E0x08000000"

    tg := Gui(styleStr " -DPIScale")
    tg.BackColor := MultiplePaths ? "1A1A1A" : "FFFFFF"
    
    if (MultiplePaths)
        tg.SetFont("s12 w600 cFFFFFF", "Bahnschrift")
    else
        tg.SetFont("s10 c000000", "Arial")
    
    idLen := StrLen(towerID)

    if (idLen <= 3) {
        fontSize := "s12"
    } else if (idLen <= 5) {
        fontSize := "s8"
    } else if (idLen <= 8) {
        fontSize := "s6"
    } else if (idLen <= 11) {
        fontSize := "s4"
    } else {
        fontSize := "s3"
    }

    tg.SetFont("Bold " fontSize)

    tg.Add("Text", "x0 y0 w32 h24 Center BackgroundTrans 0x200", towerID)

    tg.SetFont("s8 norm")
    tg.Add("Text", "x0 y22 w32 h8 Center BackgroundTrans 0x200", level)
    
    tg.Show("x" x " y" y " w32 h32 NoActivate")
    
    WinSetTransparent(128, "ahk_id " tg.Hwnd)
    
    Towers[towerID].hwnd := tg.Hwnd
}


DeleteAllIndicators() {
    global Towers
    Critical("On")
    SetWinDelay(-1) 
    for id, t in Towers {
        if (t.HasProp("hwnd") && t.hwnd) {
            WinClose("ahk_id " t.hwnd)
            t.hwnd := ""
        }
    }
    SetWinDelay(10) 
    Critical("Off")
}



FindClosestTower(mx, my) {
    global Towers
    closestID := "", minDist := 20
    for id, t in Towers {
        dist := Sqrt((t.x - mx)**2 + (t.y - my)**2)
        if (dist < minDist) {
            minDist := dist
            closestID := id
        }
    }
    return closestID
}

HasStep(searchStep) {
    global RecordedSteps
    for i, s in RecordedSteps {
        if (s = searchStep) {
            return true
        }
    }
    return false
}


GetNextTowerID(slot) {
    global requiredTowers, Towers

    slotArray := StrSplit(requiredTowers, ",")
    for index, name in slotArray {
        slotArray[index] := Trim(name)
    }

    targetSlot := Integer(slot)
    if (targetSlot > slotArray.Length || targetSlot < 1) {
        baseName := ""
    } else {
        baseName := slotArray[targetSlot]
    }
    
    if (InStr(baseName, "DJ") || InStr(baseName, "DJ Booth")) {
        baseName := "DJ"
    }
    
    count := 0

    if (IsObject(Towers)) {
        for id, t in Towers {
            if (RegExMatch(id, "i)^" baseName "(\d+)$", &match)) {
                num := Integer(match[1])
                if (num > count) {
                    count := num
                }
            }
        }
    }

    if (InStr(baseName, "DJ")) {
        return baseName
    } else {
        return baseName (count + 1)
    }
}

ModernMsgBox(Title, Text, Buttons := "OK", type := "") { ; ahhh func
    boxType := (Buttons = "OK") ? 0 : 4
    If (type = "WARNING") {
        boxType += 48
    } Else {
        boxType += 64
    }
    if (AlwaysOnTop = 1) {
        boxType += 4096
    }
    result := MsgBox(Text, Title, boxType)
    return (result = "OK" || result = "Yes") ? "YES" : "NO"
}

MapToString(inputMap) {
    result := ""
    for k, v in inputMap
        result .= k " => " v "`n"
    return RTrim(result, "`n")
}


ShowDebugConsole() {
    global DebugConsole, OverlayHWND, OverlayBitmap, OverlayGraphics, OverlayPicHWND
    global OverlayX, OverlayY, OverlayWidth, OverlayHeight
    
    if (DebugConsole != "1" && DebugConsole != 1) {
        return
    }
    if (OverlayHWND && WinExist("ahk_id " OverlayHWND)) {
        return
    }

    OverlayWidth  := Round(A_ScreenWidth  * 0.26)
    OverlayHeight := Round(A_ScreenHeight * 0.185)
    OverlayX      := Round(A_ScreenWidth  * 0.73)
    OverlayY      := Round(A_ScreenHeight * 0.76)

    og := Gui("+AlwaysOnTop +ToolWindow -Caption +E0x20 +E0x08000000 +E0x00000008 +LastFound -DPIScale")
    og.BackColor := "000000"
    og.Title     := "DebugOverlay"
    
    global OverlayPicCtrl := og.Add("Picture", "x0 y0 w" OverlayWidth " h" OverlayHeight " +0xE")
    OverlayPicHWND := OverlayPicCtrl.Hwnd
    OverlayHWND    := og.Hwnd
    
    og.Show("x" OverlayX " y" OverlayY " w" OverlayWidth " h" OverlayHeight " NA")
    
    WinSetTransColor("0x000000", "ahk_id " OverlayHWND)

    OverlayBitmap   := Gdip_CreateBitmap(OverlayWidth, OverlayHeight)
    OverlayGraphics := Gdip_GraphicsFromImage(OverlayBitmap)
    Gdip_SetSmoothingMode(OverlayGraphics, 4)
    
}

HideDebugConsole() {
    global OverlayHWND, OverlayBitmap, OverlayGraphics, OverlayPicHWND
    
    if (OverlayBitmap) { 
        Gdip_DisposeImage(OverlayBitmap)
        OverlayBitmap := 0 
    }
    if (OverlayGraphics) { 
        Gdip_DeleteGraphics(OverlayGraphics)
        OverlayGraphics := 0 
    }
    if (OverlayHWND) {
        WinClose("ahk_id " OverlayHWND)
    }
    OverlayHWND    := 0
    OverlayPicHWND := 0
}

UpdateOverlay() {
    global OverlayBitmap, OverlayGraphics, OverlayPicHWND, LogLines, OverlayWidth, OverlayHeight
    if (!OverlayGraphics) {
        return
    }

    if (IsSet(OverlayGraphics) && OverlayGraphics) {
        if (OverlayGraphics != 0 && OverlayGraphics != "") {
            try {
                Gdip_GraphicsClear(OverlayGraphics, 0x00000000)
            } catch Error as err {
                OverlayGraphics := 0 
                return
            }
        }
    }
    
    fontSize := 12
    fontName := "Consolas", style := 1
    textColor := 0xFFFFFFFF

    hFamilyOverlay := Gdip_FontFamilyCreate(fontName)
    hFontOverlay   := Gdip_FontCreate(hFamilyOverlay, fontSize, style)
    hFormatOverlay := Gdip_StringFormatCreate(0x0000)

    if (!hFormatOverlay || hFormatOverlay == 0 || !hFontOverlay || hFontOverlay == 0) {
        if (hFormatOverlay) => Gdip_DeleteStringFormat(hFormatOverlay)
        if (hFontOverlay) => Gdip_DeleteFont(hFontOverlay)
        if (hFamilyOverlay) => Gdip_DeleteFontFamily(hFamilyOverlay)
        return
    }

    try {
        Gdip_SetStringFormatAlign(hFormatOverlay, 0)
    } catch {
        Gdip_DeleteStringFormat(hFormatOverlay)
        Gdip_DeleteFont(hFontOverlay)
        Gdip_DeleteFontFamily(hFamilyOverlay)
        return
    }

    pBrushTextOverlay := Gdip_BrushCreateSolid(textColor)
    pBrushBgOverlay  := Gdip_BrushCreateSolid(0xAA000000)

    if (!pBrushTextOverlay || !pBrushBgOverlay) {
        if (pBrushTextOverlay) => Gdip_DeleteBrush(pBrushTextOverlay)
        if (pBrushBgOverlay) => Gdip_DeleteBrush(pBrushBgOverlay)
        Gdip_DeleteStringFormat(hFormatOverlay)
        Gdip_DeleteFont(hFontOverlay)
        Gdip_DeleteFontFamily(hFamilyOverlay)
        return
    }

    maxLines   := Floor(OverlayHeight / (fontSize * 1.4))
    startIndex := Max(1, LogLines.Length - maxLines + 1)
    yPos := 5, maxWidth := OverlayWidth - 20

    wrappedLines := []
    Loop maxLines {
        idx := startIndex + A_Index - 1
        if (idx > LogLines.Length)
            break
        line := LogLines[idx]
        while (StrLen(line) > 0) {
            if (StrLen(line) * fontSize * 0.6 <= maxWidth) { 
                wrappedLines.Push(line)
                break 
            }
            cutPos := Floor(maxWidth / (fontSize * 0.6))
            wrappedLines.Push(SubStr(line, 1, cutPos))
            line := SubStr(line, cutPos + 1)
        }
    }
    while (wrappedLines.Length > maxLines)
        wrappedLines.RemoveAt(1)

    for i, line in wrappedLines {
        Gdip_FillRectangle(OverlayGraphics, pBrushBgOverlay, 5, yPos, OverlayWidth-10, fontSize * 1.4)
        CreateRectF(&RC, 5, yPos, OverlayWidth-5, fontSize * 1.4)
        try {
            Gdip_DrawString(OverlayGraphics, line, hFontOverlay, hFormatOverlay, pBrushTextOverlay, &RC)
        }
        yPos += fontSize * 1.4
    }

    Gdip_DeleteBrush(pBrushTextOverlay)
    Gdip_DeleteBrush(pBrushBgOverlay)
    Gdip_DeleteStringFormat(hFormatOverlay)
    Gdip_DeleteFont(hFontOverlay)
    Gdip_DeleteFontFamily(hFamilyOverlay)

    if (IsSet(OverlayBitmap) && OverlayBitmap) {
        try {
            hBitmap := Gdip_CreateHBITMAPFromBitmap(OverlayBitmap)
            SetImage(OverlayPicHWND, hBitmap)
            DeleteObject(hBitmap)
        }
    }
}

LogToConsole(text, SendWebhookInstantly := false, flush := true) {
    global DebugConsole, LogLines, OverlayHWND, WebhookEnabled, WebhookLink, RunningStrategy, AutorunStartTime
    if ((DebugConsole != "1" && DebugConsole != 1) && !WebhookEnabled)
        return

    time := FormatTime(, "HH:mm:ss")
    formattedText := "[" time "] " text
    LogLines.Push(formattedText)
    while (LogLines.Length > 500)
        LogLines.RemoveAt(1)

    if (OverlayHWND && WinExist("ahk_id " OverlayHWND))
        UpdateOverlay()

    if (WebhookEnabled && WebhookLink != "" && RunningStrategy) {
        runtime := (AutorunStartTime > 0) ? FormatRuntime(AutorunStartTime) : "00:00"
        wText := "[" runtime "] " text
        if (!SendWebhookInstantly && WebhookDebugLogs)
            SendToWebhook(wText)
        else
            SendToWebhookInstant(wText,,flush)
    }
}

FormatRuntime(StartTicks) {
    if (StartTicks = 0) {
        return "00:00"
    }
    elapsed := Floor((A_TickCount - StartTicks) / 1000)
    h := Floor(elapsed / 3600)
    m := Floor(Mod(elapsed, 3600) / 60)
    s := Mod(elapsed, 60)
    return (h > 0) ? Format("{:d}:{:02d}:{:02d}", h, m, s) : Format("{:d}:{:02d}", m, s)
}

claimPlaytimeRewards() { 
    global CollectPlaytimeRewards, NextCheckInterval
    
    if (CollectPlaytimeRewards != "1" && CollectPlaytimeRewards != 1) {
        return
    }
    Sleep(2000) ; load
    
    getRobloxPos(&pX, &pY, &w, &h)
    popupColor := PixelGetColor(w - 268, pY + 5, "RGB")
    r1 := (popupColor >> 16) & 0xFF, g1 := (popupColor >> 8) & 0xFF, b1 := popupColor & 0xFF
    r2 := 0xEE, g2 := 0x18, b2 := 0x18
    diff := Sqrt((r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2)

    
    if (diff < 3) {
        LogToConsole("Claiming playtime rewards..")
        Click(w - 290, pY + 32)
        
        Sleep(1000)

        openedMenu := false
        Loop 15 {
            getRobloxPos(&pX, &pY, &w, &h)
            X1 := Round(w * 0.2)
            Y1 := Round(h * 0.15)
            W := Round(w * 1) - X1
            H := Round(h * 0.4) - Y1
            resclose := AdvImageSearch("Resources\close_freerewards.png", X1, Y1, W, H)

            If (resclose.status = "success" && resclose.score >= 0.86) {
                openedMenu := true
                break
            } 
            Sleep(300)
        }

        if (!openedMenu) {
            getRobloxPos(&pX, &pY, &w, &h)
            MouseMove(w - 290, pY + 32, A_DefaultMouseSpeed+1)
            Sleep(50)
            MouseClick()

            openedMenu := false
            Loop 25 {
                getRobloxPos(&pX, &pY, &w, &h)
                X1 := Round(w * 0.2)
                Y1 := Round(h * 0.15)
                W := Round(w * 1) - X1
                H := Round(h * 0.4) - Y1
                resclose := AdvImageSearch("Resources\close_freerewards.png", X1, Y1, W, H)

                If (resclose.status = "success" && resclose.score >= 0.86) {
                    openedMenu := true
                    break
                } 

                res := AdvImageSearch("Resources/Claim.png", Round(w * 0.25), Round(h * 0.4), Round(w * 0.5), Round(h * 0.5), 0.5, 2)
                if (res.status = "success" && res.score >= 0.65) {
                    Click(res.x, res.y)
                }

                Sleep(300)
            }

            if (!openedMenu) {
                LogToConsole("Failed to claim rewards!", true, false)
                return
            }
        }

        rewardsCollected := false
        
        Loop {
            getRobloxPos(&pX, &pY, &w, &h)
            
            Loop 10 {
                if (PixelSearch(&cx, &cy, Round(w*0.25), Round(h*0.2), Round(w*0.55), Round(h*0.76), 0x64F711, 5)) 
                    break
                else 
                    Sleep(100)
            }

            if (!PixelSearch(&cx, &cy, Round(w*0.25), Round(h*0.2), Round(w*0.55), Round(h*0.76), 0x64F711, 5)) {
                break
            }
            
            Click(cx, cy)
            rewardsCollected := true
            Sleep(500)

            Loop {
                resConfirm := AdvImageSearch("Resources/claimreward.png", Round(w*0.25), Round(h*0.5), Round(w*0.5), Round(h*0.5),,1.5)
                
                if (resConfirm.status == "success" && resConfirm.score > 0.65) {
                    Click(resConfirm.x, resConfirm.y)
                    MouseMove(ScaleX(unfocusX), ScaleY(unfocusY))
                    Sleep(800)
                } else {
                    Sleep(300)
                    resConfirm := AdvImageSearch("Resources/claimreward.png", Round(w*0.25), Round(h*0.5), Round(w*0.5), Round(h*0.5),,1.5)
                    if (resConfirm.status == "success" && resConfirm.score > 0.65) {
                        continue
                    }
                    break
                }
            }
        }

        Sleep(800) 
 
        getRobloxPos(&pX, &pY, &w, &h)
    
        x1 := Round(w*0.39)
        y1 := Round(h*0.36)
        x2 := Round(w*0.22)
        y2 := Round(h*0.4)
        
        ocrResult := OCR.FromRect(x1, y1, x2, y2, {lang: "en-US", invertcolors: 1, scale: 2})
        textOnScreen := ocrResult.Text

        claimedCount := 0
        StrReplace(textOnScreen, "CLAIMED", , , &claimedCount)
        
        if (claimedCount != 0) {
            LogToConsole("Claimed free rewards (" . claimedCount . "/6)")   
        }

        if (claimedCount >= 6) {
            LogToConsole("All rewards collected! Next check in 24 hours.")
            NextCheckInterval := 86400000 
        } else {
            LogToConsole("Not all rewards collected. Next check in 2 hours.")
            NextCheckInterval := 7200000  
        }

        X1 := Round(w * 0.2)
        Y1 := Round(h * 0.15)
        W := Round(w * 1) - X1
        H := Round(h * 0.4) - Y1
        resclose := AdvImageSearch("Resources\close_freerewards.png", X1, Y1, W, H)

        If (resclose.status = "success" && resclose.score >= 0.86) {
            Click(resclose.x, resclose.y)
        } else {
            Click(ScaleX(1126), ScaleY(307))
        }
    }
    UpdateDailyRewardTime()
}

UpdateDailyRewardTime() {
    global StateFile, NextCheckInterval
    
    
    if (!HasGlobal("NextCheckInterval") || NextCheckInterval == "") {
        NextCheckInterval := 7200000
    }
    
    
    IniWrite(A_Now, StateFile, "State", "LastDailyCheck")
    IniWrite(NextCheckInterval, StateFile, "State", "NextCheckInterval")
}

CheckDailyRewardTime() {
    global StateFile
    
    lastCheckTime := IniRead(StateFile, "State", "LastDailyCheck", "")
    
    currentIntervalMs := Integer(IniRead(StateFile, "State", "NextCheckInterval", "7200000"))
    
    
    if (lastCheckTime == "") {
        return true
    }

    
    intervalSeconds := currentIntervalMs / 1000
    
    try {
        
        timeDiffSeconds := DateDiff(A_Now, lastCheckTime, "Seconds")
        
        
        if (timeDiffSeconds >= intervalSeconds) {
            return true
        }
    } catch {
        
        return true
    }
    
    return false
}



HasGlobal(varName) {
    try {
        return %varName% !== ""
    } catch {
        return false
    }
}

closeChat() {
    getRobloxPos(&pX, &pY, &w, &h)
    chatColor := PixelGetColor(pX + 140, pY + 29, "RGB")
    r1 := (chatColor >> 16) & 0xFF, g1 := (chatColor >> 8) & 0xFF, b1 := chatColor & 0xFF
    r2 := 0xF4, g2 := 0xF5, b2 := 0xF8
    diff := Sqrt((r1-r2)**2 + (g1-g2)**2 + (b1-b2)**2)
    if (diff < 12) {
        MouseGetPos(&cx, &cy)
        MouseMove(pX + 140, pY + 35, 2)
        Sleep(100)
        Click()
        Sleep(100)
        MouseMove(cx, cy)
        LogToConsole("Closed chat")
    }
}


SendToWebhook(message) {
    global WebhookQueue, WebhookTimerActive
    if (message = "" || Trim(message) = "") {
        return
    }
    WebhookQueue.Push(message)
    if (!WebhookTimerActive) {
        WebhookTimerActive := true
        SetTimer(ProcessWebhookQueue, -100)
    }
}

SendToWebhookInstant(message, embedColor := 3447003, flush := true) {
    global WebhookInstantQueue, WebhookInstantTimerActive, WebhookEnabled
    if (!WebhookEnabled || message = "" || Trim(message) = "") { 
        return
    }
    if (flush) {
        FlushWebhookQueue()
    }

    WebhookInstantQueue.Push({msg: message, color: embedColor})
    
    if (!WebhookInstantTimerActive) {
        WebhookInstantTimerActive := true
        SetTimer(ProcessWebhookInstantQueue, -100)
    }
}

ProcessWebhookInstantQueue() {
    global WebhookInstantQueue, WebhookInstantTimerActive, WebhookLink
    
    if (WebhookInstantQueue.Length = 0) { 
        WebhookInstantTimerActive := false 
        return 
    }
    
    allMessages := ""
    finalColor := 3447003
    hasCustomColor := false
    
    while (WebhookInstantQueue.Length > 0) {
        item := WebhookInstantQueue.RemoveAt(1)
        if (Trim(item.msg) = "") 
            continue
            
        allMessages .= (allMessages != "") ? "`n" item.msg : item.msg
        
        if (item.color != 3447003) {
            finalColor := item.color
            hasCustomColor := true
        }
    }
    
    WebhookInstantTimerActive := false
    if (allMessages = "") 
        return
        
    if (!hasCustomColor) {
        lower := Format("{:L}", allMessages)
        if (InStr(lower, "error") || InStr(lower, "failed") || InStr(lower, "reloading")) {
            finalColor := 15158332
        } else if (InStr(lower, "success") || InStr(lower, "completed")) {
            finalColor := 3066993
        } else if (InStr(lower, "warning")) {
            finalColor := 16776960
        }
    }
    
    escaped := StrReplace(StrReplace(StrReplace(allMessages, "\", "\\"), '"', '\"'), "`n", "\n")
    payload := '{"embeds":[{"description":"' escaped '","color":' finalColor '}]}'
    
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", WebhookLink, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(payload)
    } catch Error {
    }
}



ProcessWebhookQueue() {
    global WebhookQueue, WebhookTimerActive, WebhookLink
    static whr := ComObject("WinHttp.WinHttpRequest.5.1")
    
    if (WebhookQueue.Length = 0) { 
        WebhookTimerActive := false 
        return 
    }
    if (WebhookQueue.Length < 20) { 
        SetTimer(ProcessWebhookQueue, -2000) 
        return 
    }
    
    allMessages := ""
    Loop 20 {
        if (WebhookQueue.Length = 0) 
            break
        
        msg := WebhookQueue.RemoveAt(1)
        if (Trim(msg) = "") 
            continue
            
        escaped := StrReplace(msg, "\", "\\")
        escaped := StrReplace(escaped, '"', '\"')
        escaped := StrReplace(escaped, "`n", "\n")
        escaped := StrReplace(escaped, "`r", "")
        
        if (Trim(escaped) = "") 
            continue
            
        allMessages .= escaped "\n"
    }
    
    if (allMessages = "") { 
        WebhookTimerActive := false 
        return 
    }
    
    allMessages := RTrim(allMessages, "\n")
    
    embedColor := 9868950
    payload := '{"embeds":[{"description":"``````\n' allMessages '\n``````","color":' embedColor '}]}'
    
    try {
        whr.Open("POST", WebhookLink, true)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(payload)
    } catch Error {
    }
    
    if (WebhookQueue.Length > 0)
        SetTimer(ProcessWebhookQueue, -1000)
    else
        WebhookTimerActive := false
}


FlushWebhookQueue() {
    global WebhookQueue, WebhookTimerActive, WebhookLink
    
    if (WebhookQueue.Length = 0) 
        return
        
    WebhookTimerActive := false
    SetTimer(ProcessWebhookQueue, 0)
    
    allMessages := ""
    while (WebhookQueue.Length > 0) {
        msg := WebhookQueue.RemoveAt(1)
        if (Trim(msg) = "") 
            continue

        escaped := StrReplace(msg, "\", "\\")
        escaped := StrReplace(escaped, '"', '\"')
        escaped := StrReplace(escaped, "`n", "\n")
        escaped := StrReplace(escaped, "`r", "")
        
        if (Trim(escaped) = "") 
            continue
            
        allMessages .= escaped "\n"
    }
    
    if (allMessages = "") 
        return
        
    allMessages := RTrim(allMessages, "\n")
    
    embedColor := 9868950
    payload := '{"embeds":[{"description":"``````\n' allMessages '\n``````","color":' embedColor '}]}'
    
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", WebhookLink, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(payload)
    } catch Error {
    }
}



SafeReload() {
    global RestartLock, StateFile, RunningStrategy, OverlayHWND, MainGui
    if (RestartLock) {
        return
    }
    RestartLock := true
    KillSubmacros()
    if (OverlayHWND) {
        WinClose("ahk_id " OverlayHWND)
    }
    
    if (IsSet(MainGui) && MainGui) {
        MainGui.Destroy()
    }
    
    DeleteAllIndicators()
    if (RunningStrategy) {
        currentStrat := IniRead(StateFile, "State", "Strategy", "")
        if (currentStrat != "") {
            IniWrite(1, StateFile, "State", "Running")
        }
    } 

    FlushWebhookQueue()

    Reload()
}

startWatchdog() {
    currentPID := DllCall("GetCurrentProcessId")
    if (A_PtrSize == 4) {
    Run('"' A_ScriptDir '\submacros\AutoHotkey32.exe" "' A_ScriptDir '\submacros\watchdog.ahk" ' currentPID, , , &watchdogPID)
    } else {
    Run('"' A_ScriptDir '\submacros\AutoHotkey64.exe" "' A_ScriptDir '\submacros\watchdog.ahk" ' currentPID, , , &watchdogPID)
    }
}

KillSubmacros() {
    global watchdogPID
    
    if (watchdogPID != "") {
        try {
            RunWait(A_ComSpec " /c taskkill /PID " watchdogPID " /F /T", , "Hide")
        } catch Error {
        }
        watchdogPID := ""
    }
    
    try {
        for process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name = 'AutoHotkey64.exe' OR Name = 'AutoHotkey.exe' OR Name = 'AutoHotkey32.exe'") {
            try {
                cmd := process.CommandLine
                if (InStr(cmd, "watchdog.ahk")) {
                    try {
                        process.Terminate()
                    } catch Error {
                        continue
                    }
                }
            } catch Error {
                continue
            }
        }
    } catch Error {
        return
    }
}

HandleExit(ExitReason, ExitCode) {
    global StateFile, SettingsFile

    if (RunningStrategy) {
        KillSubmacros()
        if (ExitReason = "Close" || ExitReason = "Menu" || ExitReason = "Shutdown" || ExitReason = "Logoff") {
            IniWrite(0, StateFile, "State", "Running")
            IniDelete(StateFile, "State", "Strategy")
            IniDelete(StateFile, "State", "StartTime")
            IniDelete(StateFile, "State", "CurrentStratStartTime")
            IniDelete(StateFile, "State", "CurrentRotationIndex")
            IniDelete(StateFile, "State", "CurrentRunCount")
            IniDelete(StateFile, "State", "Coins")
            IniDelete(StateFile, "State", "Gems")
            IniDelete(StateFile, "State", "EXP")
            IniDelete(StateFile, "State", "TotalTriumphs")
            IniDelete(StateFile, "State", "TotalLosses")
            IniDelete(StateFile, "State", "TotalTimeSeconds")
            IniDelete(StateFile, "State", "Timescale")
        }
    }
}

CleanupGdip(exitReason, exitCode) {
    global pToken
    Gdip_Shutdown(pToken)
}

MainGui.OnEvent("Close", (*) => ExitApp())

CheckOcrLanguage() {
    try {
        rawLangs := OCR.GetAvailableLanguages()
        hasEnglish := false
        
        availableLangs := StrSplit(rawLangs, ["`n", "`r", ",", " "])
        
        for lang in availableLangs {
            if (lang = "")
                continue
                
            if InStr(lang, "en") {
                hasEnglish := true
                break
            }
        }
        
        if (!hasEnglish) {
            msgText := "English language pack for OCR (text detection) is not installed on your system!`n`n"
                    . "Without it, the script cannot read text from the screen properly.`n`n"
                    . "Would you like to open Windows Settings to download the Language Pack?"
            
            result := MsgBox(msgText, "Missing OCR Language Pack", 48 + 4)
            
            if (result = "Yes") {
                Run("ms-settings:regionlanguage")
            }
            
            ExitApp()
        }
    }
}

SendScreenshot(pBitmap := Gdip_BitmapFromScreen(), description := "", color := 12434877, screenshot := WebhookScreenshots) {
    global WebhookLink

    escapedDescription := StrReplace(description, "\", "\\")
    escapedDescription := StrReplace(escapedDescription, '"', '\"')
    escapedDescription := StrReplace(escapedDescription, "`n", "\n")

    fields := []

    if (screenshot == "0" || screenshot == 0) {
        payload_json := '{"embeds": [{"description": "' escapedDescription '", "color": ' color '}]}'
        fields.Push(Map("name", "payload_json", "content-type", "application/json", "content", payload_json))
    } 
    else {
        payload_json := '{"embeds": [{"description": "' escapedDescription '", "color": ' color ', "image": {"url": "attachment://screenshot.png"}}]}'
        fields.Push(Map("name", "payload_json", "content-type", "application/json", "content", payload_json))
        fields.Push(Map("name", "files[0]", "filename", "screenshot.png", "content-type", "image/png", "pBitmap", pBitmap))
    }
    
    CreateFormData(&postdata, &contentType, fields)
    
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", WebhookLink "?wait=true", false)
        whr.SetRequestHeader("Content-Type", contentType)
        whr.SetTimeouts(0, 60000, 120000, 30000)
        whr.Send(postdata)
    }
}


CreateFormData(&retData, &contentType, fields) {
    chars := "0123456789abcdefghijklmnopqrstuvwxyz"
    boundary := ""
    Loop 12 {
        boundary .= SubStr(chars, Random(1, StrLen(chars)), 1)
    }

    hData := DllCall("GlobalAlloc", "UInt", 0x2, "UPtr", 0, "Ptr")
    DllCall("ole32\CreateStreamOnHGlobal", "Ptr", hData, "Int", 0, "PtrP", &pStream)

    for index, field in fields {
        str := "`r`n------------------------------" boundary "`r`n"
        str .= 'Content-Disposition: form-data; name="' field["name"] '"'
        if (field.Has("filename"))
            str .= '; filename="' field["filename"] '"'
        str .= "`r`nContent-Type: " field["content-type"] "`r`n`r`n"
        if (field.Has("content"))
            str .= field["content"] "`r`n"

        length := StrPut(str, "UTF-8") - 1
        utf8 := Buffer(length)
        StrPut(str, utf8, length, "UTF-8")
        DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8, "UInt", length, "UInt")

        if (field.Has("pBitmap")) {
            try {
                pFileStream := Gdip_SaveBitmapToStream(field["pBitmap"])
                DllCall("shlwapi\IStream_Size",  "Ptr", pFileStream, "UInt64*", &size := 0, "UInt")
                DllCall("shlwapi\IStream_Reset", "Ptr", pFileStream, "UInt")
                DllCall("shlwapi\IStream_Copy",  "Ptr", pFileStream, "Ptr", pStream, "UInt", size, "UInt")
                ObjRelease(pFileStream)
            }
        }
    }

    str := "`r`n------------------------------" boundary "--`r`n"
    length := StrPut(str, "UTF-8") - 1
    utf8 := Buffer(length)
    StrPut(str, utf8, length, "UTF-8")
    DllCall("shlwapi\IStream_Write", "Ptr", pStream, "Ptr", utf8, "UInt", length, "UInt")
    ObjRelease(pStream)

    pData := DllCall("GlobalLock", "Ptr", hData, "Ptr")
    size  := DllCall("GlobalSize", "Ptr", pData, "UPtr")
    retData := ComObjArray(0x11, size)
    pvData  := NumGet(ComObjValue(retData), 8 + A_PtrSize, "Ptr")
    DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", pData, "Ptr", size)
    DllCall("GlobalUnlock", "Ptr", hData)
    DllCall("GlobalFree",   "Ptr", hData, "Ptr")
    contentType := "multipart/form-data; boundary=----------------------------" boundary
}

InArray(arr, value) {
    for item in arr
        if (item = value)
            return true
    return false
}

CreateGradientButton(w, h, r, colorStart, colorEnd, shadowColor, strokeColor, btnText := "...", textFont := "Segoe UI", textSize := 12, gradientDirection := 0) {
    hdc := GetDC(0)
    hbm := CreateDIBSection(w, h)
    hdcMem := CreateCompatibleDC()
    obm := SelectObject(hdcMem, hbm)
    G := Gdip_GraphicsFromHDC(hdcMem)
    
    DllCall("gdiplus\GdipSetInterpolationMode", "ptr", G, "int", 7)
    
    pad := 6
    bx := pad, by := pad, bw := w - (pad * 2), bh := h - (pad * 2)

    Gdip_SetSmoothingMode(G, 4)
    Gdip_SetTextRenderingHint(G, 4) 

    Loop 6 {
        alpha := Format("{:02X}", Integer(25 / A_Index))
        currentShadow := "0x" alpha SubStr(shadowColor, -6)
        pBrushShadow := Gdip_BrushCreateSolid(currentShadow)
        
        offset := A_Index * 0.7
        pPathShadow := Gdip_CreateRoundRectanglePath(bx - (offset*0.5), by + offset, bw + offset, bh, r)
        Gdip_FillPath(G, pBrushShadow, pPathShadow)
        Gdip_DeletePath(pPathShadow)
        Gdip_DeleteBrush(pBrushShadow)
    }

    pBrushGrad := Gdip_CreateLineBrushFromRect(bx, by, bw, bh, colorStart, colorEnd, gradientDirection, 1)
    pPathMain := Gdip_CreateRoundRectanglePath(bx, by, bw, bh, r)
    Gdip_FillPath(G, pBrushGrad, pPathMain)

    pPathStroke := Gdip_CreateRoundRectanglePath(bx + 0.5, by + 0.5, bw - 1, bh - 1, r)
    pPenStroke := Gdip_CreatePen(strokeColor, 1)
    Gdip_DrawPath(G, pPenStroke, pPathStroke)
    Gdip_DeletePath(pPathStroke)
    Gdip_DeletePen(pPenStroke)
    
    hFormat := Gdip_StringFormatCreate(0x4000) 
    Gdip_SetStringFormatAlign(hFormat, 1)     
    DllCall("gdiplus\GdipSetStringFormatLineAlign", "ptr", hFormat, "int", 1) 
    
    Gdip_SetSmoothingMode(G, 0)
    Gdip_SetTextRenderingHint(G, 0) 

    hFontfamily := Gdip_FontFamilyCreate(textFont)
    hFont := Gdip_FontCreate(hFontfamily, textSize, 1) 
    RC := Buffer(16, 0)
    
    NumPut("float", bx, "float", by + 1, "float", bw, "float", bh, RC)
    pBrushTxtShadow := Gdip_BrushCreateSolid("0x99000000")
    
    Gdip_DrawString(G, btnText, hFont, hFormat, pBrushTxtShadow, &RC)
    Gdip_DeleteBrush(pBrushTxtShadow)
    
    NumPut("float", bx, "float", by, "float", bw, "float", bh, RC)
    pBrushTxtMain := Gdip_BrushCreateSolid("0xFFFFFFFF")
    
    Gdip_DrawString(G, btnText, hFont, hFormat, pBrushTxtMain, &RC)
    Gdip_DeleteBrush(pBrushTxtMain)

    Gdip_DeleteFont(hFont)
    Gdip_DeleteFontFamily(hFontfamily)
    Gdip_DeleteStringFormat(hFormat)
    Gdip_DeletePath(pPathMain)
    Gdip_DeleteBrush(pBrushGrad)
    
    SelectObject(hdcMem, obm)
    DeleteDC(hdcMem)
    ReleaseDC(0, hdc)
    Gdip_DeleteGraphics(G)
    
    return hbm
}

CreateFrame(w, h, r, bgColor, strokeOuter, strokeInner) {
    hbm := CreateDIBSection(w, h), hdcMem := CreateCompatibleDC()
    obm := SelectObject(hdcMem, hbm), G := Gdip_GraphicsFromHDC(hdcMem)
    Gdip_SetSmoothingMode(G, 4)

    pBrushBg := Gdip_BrushCreateSolid(bgColor)
    pPathMain := Gdip_CreateRoundRectanglePath(0, 0, w, h, r)
    Gdip_FillPath(G, pBrushBg, pPathMain)

    pPathOuter := Gdip_CreateRoundRectanglePath(0.5, 0.5, w - 1, h - 1, r)
    pPenOuter := Gdip_CreatePen(strokeOuter, 1)
    Gdip_DrawPath(G, pPenOuter, pPathOuter)

    pPathInner := Gdip_CreateRoundRectanglePath(1.5, 1.5, w - 3, h - 3, r - 1)
    pPenInner := Gdip_CreatePen(strokeInner, 1)
    Gdip_DrawPath(G, pPenInner, pPathInner)

    Gdip_DeletePen(pPenInner), Gdip_DeletePath(pPathInner)
    Gdip_DeletePen(pPenOuter), Gdip_DeletePath(pPathOuter)
    Gdip_DeletePath(pPathMain), Gdip_DeleteBrush(pBrushBg)
    SelectObject(hdcMem, obm), DeleteDC(hdcMem), Gdip_DeleteGraphics(G)
    return hbm
}


CreateScrollThumb(w, h, r, colorStart, colorEnd, glowColor) {
    hbm := CreateDIBSection(w, h), hdcMem := CreateCompatibleDC()
    obm := SelectObject(hdcMem, hbm), G := Gdip_GraphicsFromHDC(hdcMem)
    Gdip_SetSmoothingMode(G, 4)

    Loop 3 {
        alpha := Format("{:02X}", Integer(30 / A_Index))
        pBrush := Gdip_BrushCreateSolid("0x" alpha SubStr(glowColor, -6))
        pPath := Gdip_CreateRoundRectanglePath(0, A_Index*0.5, w, h, r)
        Gdip_FillPath(G, pBrush, pPath), Gdip_DeletePath(pPath), Gdip_DeleteBrush(pBrush)
    }
    
    pBrushGrad := Gdip_CreateLineBrushFromRect(0, 0, w, h, colorStart, colorEnd, 1, 1)
    pPathMain := Gdip_CreateRoundRectanglePath(0, 0, w, h, r)
    Gdip_FillPath(G, pBrushGrad, pPathMain)
    
    Gdip_DeletePath(pPathMain), Gdip_DeleteBrush(pBrushGrad)
    SelectObject(hdcMem, obm), DeleteDC(hdcMem), Gdip_DeleteGraphics(G)
    return hbm
}


CreateGlowButton(w, h, r, colorStart, colorEnd, glowColor) {
    hdc := GetDC(0)
    hbm := CreateDIBSection(w, h)
    hdcMem := CreateCompatibleDC()
    obm := SelectObject(hdcMem, hbm)
    G := Gdip_GraphicsFromHDC(hdcMem)
    Gdip_SetSmoothingMode(G, 4)

    pad := 5
    bx := pad, by := pad, bw := w - (pad * 2), bh := h - (pad * 2)

    Loop 5 {
        alpha := Format("{:02X}", Integer(15 - (A_Index * 2)))
        currentGlow := SubStr(glowColor, 1, 4) . alpha . SubStr(glowColor, 7)
        
        pBrushGlow := Gdip_BrushCreateSolid(currentGlow)
        pPathGlow := Gdip_CreateRoundRectanglePath(bx - A_Index, by - A_Index, bw + (A_Index * 2), bh + (A_Index * 2), r)
        Gdip_FillPath(G, pBrushGlow, pPathGlow)
        Gdip_DeletePath(pPathGlow)
        Gdip_DeleteBrush(pBrushGlow)
    }

    pBrushGrad := Gdip_CreateLineBrushFromRect(bx, by, bw, bh, colorStart, colorEnd, 1, 1)
    pPathMain := Gdip_CreateRoundRectanglePath(bx, by, bw, bh, r)
    Gdip_FillPath(G, pBrushGrad, pPathMain)

    pPenStroke := Gdip_CreatePen("0x60FFFFFF", 1)
    Gdip_DrawPath(G, pPenStroke, pPathMain)

    Gdip_DeletePen(pPenStroke)
    Gdip_DeletePath(pPathMain)
    Gdip_DeleteBrush(pBrushGrad)
    SelectObject(hdcMem, obm)
    DeleteDC(hdcMem)
    ReleaseDC(0, hdc)
    Gdip_DeleteGraphics(G)
    
    return hbm
}

Gdip_CreateRoundRectanglePath(x, y, w, h, r) {
    DllCall("gdiplus\GdipCreatePath", "int", 0, "ptr*", &pPath := 0)
    DllCall("gdiplus\GdipAddPathArc", "ptr", pPath, "float", x, "float", y, "float", r*2, "float", r*2, "float", 180, "float", 90)
    DllCall("gdiplus\GdipAddPathArc", "ptr", pPath, "float", x+w-r*2, "float", y, "float", r*2, "float", r*2, "float", 270, "float", 90)
    DllCall("gdiplus\GdipAddPathArc", "ptr", pPath, "float", x+w-r*2, "float", y+h-r*2, "float", r*2, "float", r*2, "float", 0, "float", 90)
    DllCall("gdiplus\GdipAddPathArc", "ptr", pPath, "float", x, "float", y+h-r*2, "float", r*2, "float", r*2, "float", 90, "float", 90)
    DllCall("gdiplus\GdipClosePathFigure", "ptr", pPath)
    return pPath
}

StratInfo(title := "unknown strat", author := "darksen", RequiredTowrs := "error", modifs := "none", desc := "") {
    text := title " by " author "`n"
    text .= "-----------------------------------------`n`n"
    text .= "Required towers:`t" RequiredTowrs "`n"
    text .= "Modifiers:`t" modifs "`n`n"
    
    if (desc != "")
        text .= desc "`n`n"
        
    text .= "-----------------------------------------`n"
    text .= "* To edit the strategy, go to the 'Editor' tab or`n"
    text .= "  open the .strat file in Notepad.`n"

    MsgBox(text, "Strategy Info | " title, 0x1040)
}

; reads tds message (e.g., "You cannot place here")
; returns 1 if the given text is found, 0 if not
; ReadMessage(["already", "current", "rotation"]), for example
; works only with red color
ReadMessage(includeStr := "", includeRx := "", excludeStr := "", excludeRx := "") {
    langCode := "en-US"
    for availableLang in StrSplit(OCR.GetAvailableLanguages(), "`n", "`r") {
        if (availableLang != "" && SubStr(availableLang, 1, 2) = "en") {
            langCode := availableLang
            break
        }
    }

    getRobloxPos(,,&w,&h)
    x := Round(w * 0.2)
    y := Round(h * 0.18)
    width := Round(w * 0.7) - x
    height := Round(h * 0.3) - y

    if (width <= 0 || height <= 0)
        return false

    pBitmap := Gdip_BitmapFromScreen(x "|" y "|" width "|" height)

    pGraphics := Gdip_GraphicsFromImage(pBitmap)
    Matrix := "
    (
    5.0|0.0|0.0|0.0|0.0|
    0.0|-5.0|0.0|0.0|0.0|
    0.0|0.0|-5.0|0.0|0.0|
    0.0|0.0|0.0|1.0|0.0|
    -2.5|1.0|1.0|0.0|1.0
    )"

    pBitmapFiltered := Gdip_CreateBitmap(width, height)
    pGraphicsFiltered := Gdip_GraphicsFromImage(pBitmapFiltered)
    Gdip_DrawImage(pGraphicsFiltered, pBitmap, 0, 0, width, height, 0, 0, width, height, Matrix)

    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmapFiltered)

    ocrResult := OCR.FromBitmap(hBitmap, {lang: langCode, scale: 3, grayscale: 1})

    DeleteObject(hBitmap)
    Gdip_DisposeImage(pBitmapFiltered)
    Gdip_DeleteGraphics(pGraphicsFiltered)
    Gdip_DeleteGraphics(pGraphics)
    Gdip_DisposeImage(pBitmap)

    ocrText := ocrResult.Text

    if (HasMethod(excludeStr, "__Enum")) {
        for s in excludeStr {
            if (s != "" && InStr(ocrText, s))
                return false
        }
    } else if (excludeStr != "" && InStr(ocrText, excludeStr)) {
        return false
    }

    if (HasMethod(excludeRx, "__Enum")) {
        for rx in excludeRx {
            if (rx != "" && RegExMatch(ocrText, "i)" . rx))
                return false
        }
    } else if (excludeRx != "" && RegExMatch(ocrText, "i)" . excludeRx)) {
        return false
    }

    matchStr := false
    if (includeStr = "") {
        matchStr := true 
    } else if (HasMethod(includeStr, "__Enum")) {
        for s in includeStr {
            if (s != "" && InStr(ocrText, s)) {
                matchStr := true
                break
            }
        }
    } else if (includeStr != "" && InStr(ocrText, includeStr)) {
        matchStr := true
    }

    matchRx := false
    if (includeRx = "") {
        matchRx := true 
    } else if (HasMethod(includeRx, "__Enum")) {
        for rx in includeRx {
            if (rx != "" && RegExMatch(ocrText, "i)" . rx)) {
                matchRx := true
                break
            }
        }
    } else if (includeRx != "" && RegExMatch(ocrText, "i)" . includeRx)) {
        matchRx := true
    }

    return matchStr && matchRx
}

waitForTowerUI(&resV2 := "", &resV1 := "") {
    global PotatoMode
    StartTime := A_TickCount
    Loop {
        getRobloxPos(&rx, &ry, &w, &h)
        X1_v2 := 0
        Y1_v2 := Round(h/2)
        W_v2 := Round(w * 0.3) - X1_v2
        H_v2 := Round(h) - Y1_v2

        resV2 := AdvImageSearch("Resources\TowerUI\Variant2.png", X1_v2, Y1_v2, W_v2, H_v2, ,,0.05)

        if (resV2.status == "success" && resV2.score > 0.55) {
            return true
        }

        Sleep(30)

        X1_v1 := 0
        Y1_v1 := 0
        W_v1  := Round(w * 0.3) - X1_v1
        H_v1 := Round(h * 0.4) - Y1_v1
        resV1 := AdvImageSearch("Resources\TowerUI\Variant1.png", X1_v1, Y1_v1, W_v1, H_v1, ,,0.05)

        if (resV1.status == "success" && resV1.score > 0.68) {
            return true
        }
        Sleep(30)


        if (A_TickCount - StartTime > (PotatoMode == 1 ? 3500 : 2700)) {
            return false
        }

    }
}

RunAutoAbTool(*) {
    if (A_PtrSize == 4) {
    Run('"' A_ScriptDir '\submacros\AutoHotkey32.exe" "' A_ScriptDir '\submacros\auto_coa.ahk" ')
    } else {
        Run('"' A_ScriptDir '\submacros\AutoHotkey64.exe" "' A_ScriptDir '\submacros\auto_coa.ahk" ')
    }
}

RunAutoSpinTool(*) {
    if (A_PtrSize == 4) {
    Run('"' A_ScriptDir '\submacros\AutoHotkey32.exe" "' A_ScriptDir '\submacros\auto_spin.ahk" ')
    } else {
        Run('"' A_ScriptDir '\submacros\AutoHotkey64.exe" "' A_ScriptDir '\submacros\auto_spin.ahk" ')
    }
}


RunAutoConsumableTool(*) {
    if (A_PtrSize == 4) {
    Run('"' A_ScriptDir '\submacros\AutoHotkey32.exe" "' A_ScriptDir '\submacros\auto_open_consumable.ahk" ')
    } else {
        Run('"' A_ScriptDir '\submacros\AutoHotkey64.exe" "' A_ScriptDir '\submacros\auto_open_consumable.ahk" ')
    }
}
