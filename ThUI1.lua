local G = getgenv()
G.TK = G.TK or {}
local TK = G.TK

TK.Players = game:GetService("Players")
TK.RunService = game:GetService("RunService")
TK.UIS = game:GetService("UserInputService")
TK.Lighting = game:GetService("Lighting")
TK.Tween = game:GetService("TweenService")
TK.plr = TK.Players.LocalPlayer
TK.cam = workspace.CurrentCamera
TK.mouse = TK.plr:GetMouse()
TK.VERSION = "v1.8"
TK.EXECUTOR = "Unknown"
pcall(function() if identifyexecutor then TK.EXECUTOR = identifyexecutor() end end)

-- STATE
TK.FlyOn=false TK.NoClipOn=false TK.TPOn=false
TK.JumpOn=true TK.JumpValue=55
TK.SpeedOn=false TK.SpeedValue=24
TK.TPKillOn=false TK.TriggerBotOn=false TK.TriggerRange=12
TK.AutoThrowOn=false TK.AntiFlashOn=false TK.EmoteRunOn=false
TK.EspOn=false TK.EspMode=1
TK.KeyListOn=false TK.FreecamOn=false TK.FullbrightOn=false TK.FpsBoostOn=false
TK.SushiVisible=true TK.FlySpeed=60 TK.FreecamSpeed=50 TK.FullbrightBrightness=3
TK.currentTab=1 TK.UNLOADED=false TK.menuOpen=true
TK.Binds={Fly=Enum.KeyCode.F,NoClip=Enum.KeyCode.V,TP=Enum.UserInputType.MouseButton3,Fullbright=Enum.KeyCode.Z,Freecam=Enum.KeyCode.G}
TK.bindButtons={} TK.uiRefs={} TK.listeningBind=nil
TK.espData={} TK.savedCollisions={}
TK.freecamPos=Vector3.zero TK.freecamRotX=0 TK.freecamRotY=0 TK.freecamSavedPosition=nil
TK.fbProps={Ambient=Color3.fromRGB(178,178,178),OutdoorAmbient=Color3.fromRGB(178,178,178),Brightness=3,FogEnd=1e6,FogStart=1e6,GlobalShadows=false,EnvironmentDiffuseScale=1,EnvironmentSpecularScale=1,ClockTime=14}
TK.antiFlashConnections={} TK.triggerLastAttack=0
TK.emoteConn=nil TK.savedEmoteId=nil TK.emoteAnimConn=nil
TK.espModeContainer=nil TK.espModeButtons={}
TK.freecamSliderContainer=nil TK.fullbrightSliderContainer=nil
TK.avatarClickCount=0 TK.avatarLastClick=0 TK.soonOpened=false
TK.baseWalk=nil TK.voidSnapshot=nil TK.flyDesired=nil TK.fpsBoostSaved=nil TK.fbOriginal=nil

-- THEMES
TK.THEMES = {
    Black={Bg=Color3.fromRGB(12,12,16),Sidebar=Color3.fromRGB(16,16,21),SidebarBtn=Color3.fromRGB(24,24,31),SidebarBtnHi=Color3.fromRGB(34,34,44),SidebarActive=Color3.fromRGB(45,40,70),Card=Color3.fromRGB(22,22,28),CardBorder=Color3.fromRGB(38,38,48),Row=Color3.fromRGB(30,30,38),RowHover=Color3.fromRGB(38,38,48),ControlBg=Color3.fromRGB(40,40,52),Text=Color3.fromRGB(230,230,240),TextDim=Color3.fromRGB(150,150,165),Accent=Color3.fromRGB(140,120,250),Border=Color3.fromRGB(40,40,50),SwitchOn=Color3.fromRGB(140,120,250),SwitchOff=Color3.fromRGB(60,60,72)},
    White={Bg=Color3.fromRGB(240,240,245),Sidebar=Color3.fromRGB(228,228,235),SidebarBtn=Color3.fromRGB(215,215,225),SidebarBtnHi=Color3.fromRGB(200,200,215),SidebarActive=Color3.fromRGB(180,170,235),Card=Color3.fromRGB(250,250,255),CardBorder=Color3.fromRGB(200,200,215),Row=Color3.fromRGB(235,235,242),RowHover=Color3.fromRGB(225,225,235),ControlBg=Color3.fromRGB(210,210,222),Text=Color3.fromRGB(30,30,40),TextDim=Color3.fromRGB(110,110,125),Accent=Color3.fromRGB(110,90,230),Border=Color3.fromRGB(200,200,215),SwitchOn=Color3.fromRGB(110,90,230),SwitchOff=Color3.fromRGB(170,170,185)},
    Stone={Bg=Color3.fromRGB(38,36,34),Sidebar=Color3.fromRGB(48,46,44),SidebarBtn=Color3.fromRGB(58,55,52),SidebarBtnHi=Color3.fromRGB(70,66,62),SidebarActive=Color3.fromRGB(95,85,70),Card=Color3.fromRGB(56,53,50),CardBorder=Color3.fromRGB(78,74,70),Row=Color3.fromRGB(64,60,57),RowHover=Color3.fromRGB(75,71,67),ControlBg=Color3.fromRGB(80,75,70),Text=Color3.fromRGB(220,215,205),TextDim=Color3.fromRGB(160,152,140),Accent=Color3.fromRGB(210,160,90),Border=Color3.fromRGB(85,80,75),SwitchOn=Color3.fromRGB(210,160,90),SwitchOff=Color3.fromRGB(90,85,80)},
}
TK.THEME = {}
for k,v in pairs(TK.THEMES.Black) do TK.THEME[k]=v end
TK.HUNTER_COLOR = Color3.fromRGB(255,60,60)

-- WATERMARK
local wmGui = Instance.new("ScreenGui")
...
task.spawn(function()
    while not TK.UNLOADED do
        task.wait(1)
        local ok, fps = pcall(function() return math.floor(workspace:GetRealPhysicsFPS()) end)
        if not ok or not fps or fps < 1 then fps = 60 end
        wmText.Text = string.format("Tolkahack | Release | %s | %d FPS | %s", TK.EXECUTOR, fps, os.date("%H:%M:%S"))
    end
end)

-- MAIN GUI
local gui=Instance.new("ScreenGui")
gui.Name="tk_ui_main" gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling gui.DisplayOrder=100
gui.Parent=TK.plr:WaitForChild("PlayerGui")
TK.gui=gui
local main=Instance.new("Frame")
main.Size=UDim2.new(0,780,0,500) main.Position=UDim2.new(0.5,-390,0.5,-250)
main.BackgroundColor3=TK.THEME.Bg main.BorderSizePixel=0 main.Active=true
main.ClipsDescendants=true main.Parent=gui
Instance.new("UICorner",main).CornerRadius=UDim.new(0,12)
TK.main=main
local mainStroke=Instance.new("UIStroke",main) mainStroke.Color=TK.THEME.Border
TK.mainStroke=mainStroke

local sidebar=Instance.new("Frame",main)
sidebar.Size=UDim2.new(0,160,1,0) sidebar.BackgroundColor3=TK.THEME.Sidebar
sidebar.BorderSizePixel=0
TK.sidebar=sidebar
local logo=Instance.new("Frame",sidebar)
logo.Size=UDim2.new(1,-20,0,46) logo.Position=UDim2.new(0,10,0,12) logo.BackgroundTransparency=1
TK.logo=logo
local logoIcon=Instance.new("TextLabel",logo)
logoIcon.Size=UDim2.new(0,32,0,32) logoIcon.Position=UDim2.new(0,0,0.5,-16)
logoIcon.BackgroundColor3=TK.THEME.Accent logoIcon.Text="TH"
logoIcon.TextColor3=Color3.new(1,1,1) logoIcon.Font=Enum.Font.GothamBold
logoIcon.TextSize=12 logoIcon.BorderSizePixel=0
Instance.new("UICorner",logoIcon).CornerRadius=UDim.new(0,8)
TK.logoIcon=logoIcon
local logoTitle=Instance.new("TextLabel",logo)
logoTitle.Size=UDim2.new(1,-40,1,0) logoTitle.Position=UDim2.new(0,40,0,0)
logoTitle.BackgroundTransparency=1 logoTitle.Text="Tolkahack"
logoTitle.TextColor3=TK.THEME.Text logoTitle.Font=Enum.Font.GothamBold
logoTitle.TextSize=13 logoTitle.TextXAlignment=Enum.TextXAlignment.Left
logoTitle.TextYAlignment=Enum.TextYAlignment.Center
TK.logoTitle=logoTitle

local content=Instance.new("Frame",main)
content.Size=UDim2.new(1,-160,1,0) content.Position=UDim2.new(0,160,0,0)
content.BackgroundTransparency=1
TK.content=content
local topBar=Instance.new("Frame",content)
topBar.Size=UDim2.new(1,-30,0,46) topBar.Position=UDim2.new(0,15,0,12)
topBar.BackgroundTransparency=1
local pageTitle=Instance.new("TextLabel",topBar)
pageTitle.Size=UDim2.new(1,-100,1,0) pageTitle.BackgroundTransparency=1
pageTitle.Text="Movement" pageTitle.TextColor3=TK.THEME.Text
pageTitle.Font=Enum.Font.GothamBold pageTitle.TextSize=16
pageTitle.TextXAlignment=Enum.TextXAlignment.Left
TK.pageTitle=pageTitle
local gearBtn=Instance.new("ImageButton",topBar)
gearBtn.Size=UDim2.new(0,34,0,34) gearBtn.Position=UDim2.new(1,-80,0.5,-17)
gearBtn.BackgroundColor3=TK.THEME.Card
gearBtn.Image="rbxassetid://6031094667" gearBtn.ImageColor3=TK.THEME.Text
gearBtn.BorderSizePixel=0
Instance.new("UICorner",gearBtn).CornerRadius=UDim.new(0,8)
local gearPad=Instance.new("UIPadding",gearBtn)
gearPad.PaddingTop=UDim.new(0,6) gearPad.PaddingBottom=UDim.new(0,6)
gearPad.PaddingLeft=UDim.new(0,6) gearPad.PaddingRight=UDim.new(0,6)
TK.gearBtn=gearBtn
local closeBtn=Instance.new("TextButton",topBar)
closeBtn.Size=UDim2.new(0,34,0,34) closeBtn.Position=UDim2.new(1,-38,0.5,-17)
closeBtn.BackgroundColor3=TK.THEME.Card closeBtn.Text="X"
closeBtn.TextColor3=TK.THEME.TextDim closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=16 closeBtn.BorderSizePixel=0
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,8)
TK.closeBtn=closeBtn
closeBtn.MouseButton1Click:Connect(function() TK.menuOpen=false main.Visible=false end)

local scroll=Instance.new("ScrollingFrame",content)
scroll.Size=UDim2.new(1,-30,1,-110) scroll.Position=UDim2.new(0,15,0,68)
scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0
scroll.ScrollBarThickness=3 scroll.ScrollBarImageColor3=TK.THEME.Accent
scroll.CanvasSize=UDim2.new(0,0,0,0) scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
TK.scroll=scroll
local columnsHolder=Instance.new("Frame",scroll)
columnsHolder.Size=UDim2.new(1,-6,0,0) columnsHolder.AutomaticSize=Enum.AutomaticSize.Y
columnsHolder.BackgroundTransparency=1
local leftCol=Instance.new("Frame",columnsHolder)
leftCol.Size=UDim2.new(0.5,-6,0,0) leftCol.AutomaticSize=Enum.AutomaticSize.Y
leftCol.BackgroundTransparency=1
Instance.new("UIListLayout",leftCol).Padding=UDim.new(0,10)
TK.leftCol=leftCol
local rightCol=Instance.new("Frame",columnsHolder)
rightCol.Size=UDim2.new(0.5,-6,0,0) rightCol.Position=UDim2.new(0.5,6,0,0)
rightCol.AutomaticSize=Enum.AutomaticSize.Y rightCol.BackgroundTransparency=1
Instance.new("UIListLayout",rightCol).Padding=UDim.new(0,10)
TK.rightCol=rightCol

local footer=Instance.new("Frame",content)
footer.Size=UDim2.new(1,-30,0,40) footer.Position=UDim2.new(0,15,1,-46)
footer.BackgroundColor3=TK.THEME.Card footer.BorderSizePixel=0
Instance.new("UICorner",footer).CornerRadius=UDim.new(0,10)
local footerStroke=Instance.new("UIStroke",footer) footerStroke.Color=TK.THEME.CardBorder
TK.footer=footer TK.footerStroke=footerStroke
local avatar=Instance.new("ImageButton",footer)
avatar.Size=UDim2.new(0,32,0,32) avatar.Position=UDim2.new(0,4,0.5,-16)
avatar.BackgroundColor3=TK.THEME.ControlBg avatar.BorderSizePixel=0
avatar.Image="rbxthumb://type=AvatarHeadShot&id=0&w=150&h=150"
Instance.new("UICorner",avatar).CornerRadius=UDim.new(1,0)
Instance.new("UIStroke",avatar).Color=TK.THEME.Accent
TK.avatar=avatar
task.spawn(function()
    local ok,url=pcall(function() return TK.Players:GetUserThumbnailAsync(TK.plr.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
    if ok and url then avatar.Image=url end
end)
local nickLbl=Instance.new("TextLabel",footer)
nickLbl.Size=UDim2.new(1,-180,0,16) nickLbl.Position=UDim2.new(0,44,0.5,-16)
nickLbl.BackgroundTransparency=1 nickLbl.Text=TK.plr.Name
nickLbl.TextColor3=TK.THEME.Text nickLbl.Font=Enum.Font.GothamBold
nickLbl.TextSize=12 nickLbl.TextXAlignment=Enum.TextXAlignment.Left
TK.nickLbl=nickLbl
local buildLbl=Instance.new("TextLabel",footer)
buildLbl.Size=UDim2.new(1,-180,0,14) buildLbl.Position=UDim2.new(0,44,0.5,0)
buildLbl.BackgroundTransparency=1 buildLbl.Text="Build: Nightly"
buildLbl.TextColor3=TK.THEME.Accent buildLbl.Font=Enum.Font.Gotham
buildLbl.TextSize=10 buildLbl.TextXAlignment=Enum.TextXAlignment.Left
TK.buildLbl=buildLbl
local versionLbl=Instance.new("TextLabel",footer)
versionLbl.Size=UDim2.new(0,180,1,0) versionLbl.Position=UDim2.new(1,-190,0,0)
versionLbl.BackgroundTransparency=1 versionLbl.Text=TK.VERSION
versionLbl.TextColor3=TK.THEME.Accent versionLbl.Font=Enum.Font.GothamBold
versionLbl.TextSize=14 versionLbl.TextXAlignment=Enum.TextXAlignment.Right
TK.versionLbl=versionLbl

-- SOON
local soonFrame=Instance.new("Frame",main)
soonFrame.Size=UDim2.new(1,0,1,0) soonFrame.BackgroundColor3=Color3.fromRGB(0,0,0)
soonFrame.BackgroundTransparency=0.15 soonFrame.BorderSizePixel=0
soonFrame.ZIndex=999 soonFrame.Visible=false
TK.soonFrame=soonFrame
local soonTitle=Instance.new("TextLabel",soonFrame)
soonTitle.Size=UDim2.new(1,-20,1,-20) soonTitle.Position=UDim2.new(0,10,0,10)
soonTitle.BackgroundTransparency=1 soonTitle.Text="SOON... Upd 2.0 DOLBAEB"
soonTitle.TextColor3=Color3.new(1,1,1) soonTitle.Font=Enum.Font.GothamBlack
soonTitle.TextScaled=true soonTitle.TextStrokeTransparency=0
soonTitle.TextStrokeColor3=Color3.fromRGB(140,120,250) soonTitle.ZIndex=1000
TK.soonTitle=soonTitle
task.spawn(function()
    while not TK.UNLOADED do
        if soonFrame.Visible then
            soonTitle.TextColor3=Color3.fromRGB(200+math.random(0,55),200+math.random(0,55),200+math.random(0,55))
        end
        task.wait(0.1)
    end
end)
avatar.MouseButton1Click:Connect(function()
    local now=tick()
    if now-TK.avatarLastClick>1.5 then TK.avatarClickCount=0 end
    TK.avatarLastClick=now TK.avatarClickCount=TK.avatarClickCount+1
    if TK.avatarClickCount>=5 then
        TK.avatarClickCount=0 TK.soonOpened=not TK.soonOpened
        soonFrame.Visible=TK.soonOpened
    end
end)

-- SETTINGS PANEL
local settingsPanel=Instance.new("Frame",main)
settingsPanel.Size=UDim2.new(0,360,0,340) settingsPanel.Position=UDim2.new(0.5,-180,0.5,-170)
settingsPanel.BackgroundColor3=TK.THEME.Bg settingsPanel.BorderSizePixel=0
settingsPanel.ZIndex=500 settingsPanel.Visible=false settingsPanel.Active=true
Instance.new("UICorner",settingsPanel).CornerRadius=UDim.new(0,12)
local setStroke=Instance.new("UIStroke",settingsPanel) setStroke.Color=TK.THEME.Border
TK.settingsPanel=settingsPanel TK.setStroke=setStroke
local setHeader=Instance.new("Frame",settingsPanel)
setHeader.Size=UDim2.new(1,0,0,90) setHeader.BackgroundColor3=TK.THEME.Card
setHeader.BorderSizePixel=0 setHeader.ZIndex=502
Instance.new("UICorner",setHeader).CornerRadius=UDim.new(0,12)
TK.setHeader=setHeader
local bigTitle=Instance.new("TextLabel",setHeader)
bigTitle.Size=UDim2.new(1,-40,0,34) bigTitle.Position=UDim2.new(0,20,0,12)
bigTitle.BackgroundTransparency=1 bigTitle.Text="Tolkahack"
bigTitle.TextColor3=TK.THEME.Accent bigTitle.Font=Enum.Font.GothamBlack
bigTitle.TextSize=26 bigTitle.TextXAlignment=Enum.TextXAlignment.Left bigTitle.ZIndex=503
TK.bigTitle=bigTitle
local creditsLabel=Instance.new("TextLabel",setHeader)
creditsLabel.Size=UDim2.new(1,-40,0,14) creditsLabel.Position=UDim2.new(0,20,0,48)
creditsLabel.BackgroundTransparency=1 creditsLabel.Text="Кодер: Prddox"
creditsLabel.TextColor3=TK.THEME.Text creditsLabel.Font=Enum.Font.Gotham
creditsLabel.TextSize=11 creditsLabel.TextXAlignment=Enum.TextXAlignment.Left creditsLabel.ZIndex=503
TK.creditsLabel=creditsLabel
local creditsLabel2=Instance.new("TextLabel",setHeader)
creditsLabel2.Size=UDim2.new(1,-40,0,14) creditsLabel2.Position=UDim2.new(0,20,0,62)
creditsLabel2.BackgroundTransparency=1 creditsLabel2.Text="Соавтор: makaroni"
creditsLabel2.TextColor3=TK.THEME.TextDim creditsLabel2.Font=Enum.Font.Gotham
creditsLabel2.TextSize=11 creditsLabel2.TextXAlignment=Enum.TextXAlignment.Left creditsLabel2.ZIndex=503
TK.creditsLabel2=creditsLabel2
local setDrag,setDragStart,setStartPos=false,nil,nil
setHeader.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then setDrag=true setDragStart=i.Position setStartPos=settingsPanel.Position end
end)
TK.UIS.InputChanged:Connect(function(i)
    if setDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
        settingsPanel.Position=UDim2.new(setStartPos.X.Scale,setStartPos.X.Offset+(i.Position-setDragStart).X,setStartPos.Y.Scale,setStartPos.Y.Offset+(i.Position-setDragStart).Y)
    end
end)
TK.UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then setDrag=false end end)

local themeLabel=Instance.new("TextLabel",settingsPanel)
themeLabel.Size=UDim2.new(1,-40,0,20) themeLabel.Position=UDim2.new(0,20,0,110)
themeLabel.BackgroundTransparency=1 themeLabel.Text="Theme"
themeLabel.TextColor3=TK.THEME.Text themeLabel.Font=Enum.Font.GothamBold
themeLabel.TextSize=12 themeLabel.TextXAlignment=Enum.TextXAlignment.Left themeLabel.ZIndex=502
TK.themeLabel=themeLabel
TK.themeOptions={"Black","White","Stone"}
TK.themeRuNames={Black="Черная",White="Белая",Stone="Каменная"}
TK.themeButtons={}
for i,opt in ipairs(TK.themeOptions) do
    local b=Instance.new("TextButton",settingsPanel)
    b.Size=UDim2.new(0,100,0,34) b.Position=UDim2.new(0,20+(i-1)*105,0,138)
    b.BackgroundColor3=TK.THEME.Card b.Text=TK.themeRuNames[opt]
    b.TextColor3=TK.THEME.TextDim b.Font=Enum.Font.GothamBold
    b.TextSize=11 b.BorderSizePixel=0 b.ZIndex=502
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
    b.MouseButton1Click:Connect(function() TK.applyTheme(opt) end)
    table.insert(TK.themeButtons,b)
end
local unloadBtn=Instance.new("TextButton",settingsPanel)
unloadBtn.Size=UDim2.new(1,-40,0,38) unloadBtn.Position=UDim2.new(0,20,0,190)
unloadBtn.BackgroundColor3=Color3.fromRGB(120,40,50) unloadBtn.Text="Полная выгрузка скрипта"
unloadBtn.TextColor3=Color3.fromRGB(255,200,200) unloadBtn.Font=Enum.Font.GothamBold
unloadBtn.TextSize=12 unloadBtn.BorderSizePixel=0 unloadBtn.ZIndex=502
Instance.new("UICorner",unloadBtn).CornerRadius=UDim.new(0,8)
TK.unloadBtn=unloadBtn
local closeSettings=Instance.new("TextButton",settingsPanel)
closeSettings.Size=UDim2.new(1,-40,0,34) closeSettings.Position=UDim2.new(0,20,1,-50)
closeSettings.BackgroundColor3=TK.THEME.Card closeSettings.Text="Закрыть"
closeSettings.TextColor3=TK.THEME.Text closeSettings.Font=Enum.Font.GothamBold
closeSettings.TextSize=12 closeSettings.BorderSizePixel=0 closeSettings.ZIndex=502
Instance.new("UICorner",closeSettings).CornerRadius=UDim.new(0,8)
closeSettings.MouseButton1Click:Connect(function() settingsPanel.Visible=false end)
gearBtn.MouseButton1Click:Connect(function() settingsPanel.Visible=not settingsPanel.Visible end)

-- SUSHI
local sushiGui=Instance.new("ScreenGui")
sushiGui.Name="tk_sushi" sushiGui.ResetOnSpawn=false
sushiGui.DisplayOrder=6 sushiGui.Parent=TK.plr.PlayerGui
TK.sushiGui=sushiGui
local sushi=Instance.new("TextButton")
sushi.Size=UDim2.new(0,52,0,52) sushi.Position=UDim2.new(1,-76,0.5,-26)
sushi.BackgroundColor3=TK.THEME.Bg sushi.Text="TH"
sushi.TextColor3=TK.THEME.Accent sushi.Font=Enum.Font.GothamBlack
sushi.TextSize=16 sushi.BorderSizePixel=0 sushi.Parent=sushiGui
Instance.new("UICorner",sushi).CornerRadius=UDim.new(1,0)
local sushiStroke=Instance.new("UIStroke",sushi) sushiStroke.Color=TK.THEME.Accent
sushiStroke.Thickness=2
TK.sushi=sushi TK.sushiStroke=sushiStroke

print("[TK] PART 1 loaded")
