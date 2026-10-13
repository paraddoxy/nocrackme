local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")
local Tween      = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local plr        = Players.LocalPlayer
local cam        = workspace.CurrentCamera
local mouse      = plr:GetMouse()

local VERSION = "v1.6"

-- ============================================================
-- STATE
-- ============================================================
local FlyOn, NoClipOn, TPOn = false, false, false
local JumpOn, JumpValue = true, 55
local SpeedOn, SpeedValue = false, 24
local TPKillOn = false
local TriggerBotOn, TriggerRange = false, 12
local AutoThrowOn = false
local AntiFlashOn = false
local EmoteRunOn = false
local EspOn = false
local EspMode = 1
local KeyListOn, FreecamOn, FullbrightOn, FpsBoostOn = false, false, false, false
local SushiVisible = true
local FlySpeed = 60
local currentTab = 1
local UNLOADED = false
local CurrentTheme = "Black"

local Binds = {
    Fly = Enum.KeyCode.F,
    NoClip = Enum.KeyCode.V,
    TP = Enum.UserInputType.MouseButton3,
    Fullbright = Enum.KeyCode.Z,
}

local bindButtons = {}
local uiRefs = {}
local listeningBind, menuOpen = nil, true
local flyDesired = nil
local espData = {}
local baseWalk = nil
local voidSnapshot = nil
local savedCollisions = {}
local freecamPos = Vector3.zero
local freecamRotX, freecamRotY = 0, 0
local freecamSpeed = 50
local freecamSavedPosition = nil
local fbOriginal = nil
local fbProps = {
    Ambient=Color3.fromRGB(178,178,178), OutdoorAmbient=Color3.fromRGB(178,178,178),
    Brightness=3, FogEnd=1e6, FogStart=1e6, GlobalShadows=false,
    EnvironmentDiffuseScale=1, EnvironmentSpecularScale=1, ClockTime=14,
}
local fpsBoostSaved = nil
local antiFlashConnections = {}
local triggerLastAttack = 0
local emoteConn = nil
local savedEmoteId = nil
local emoteAnimConn = nil

-- Easter egg
local avatarClickCount, avatarLastClick = 0, 0
local soonOpened = false
local soonFrame = nil

-- ============================================================
-- THEMES
-- ============================================================
local THEMES = {
    Black = {
        Bg=Color3.fromRGB(12,12,16), Sidebar=Color3.fromRGB(16,16,21),
        SidebarBtn=Color3.fromRGB(24,24,31), SidebarBtnHi=Color3.fromRGB(34,34,44),
        SidebarActive=Color3.fromRGB(45,40,70), Card=Color3.fromRGB(22,22,28),
        CardBorder=Color3.fromRGB(38,38,48), Row=Color3.fromRGB(30,30,38),
        RowHover=Color3.fromRGB(38,38,48), ControlBg=Color3.fromRGB(40,40,52),
        Text=Color3.fromRGB(230,230,240), TextDim=Color3.fromRGB(150,150,165),
        Accent=Color3.fromRGB(140,120,250), Border=Color3.fromRGB(40,40,50),
        SwitchOn=Color3.fromRGB(140,120,250), SwitchOff=Color3.fromRGB(60,60,72),
    },
    White = {
        Bg=Color3.fromRGB(240,240,245), Sidebar=Color3.fromRGB(228,228,235),
        SidebarBtn=Color3.fromRGB(215,215,225), SidebarBtnHi=Color3.fromRGB(200,200,215),
        SidebarActive=Color3.fromRGB(180,170,235), Card=Color3.fromRGB(250,250,255),
        CardBorder=Color3.fromRGB(200,200,215), Row=Color3.fromRGB(235,235,242),
        RowHover=Color3.fromRGB(225,225,235), ControlBg=Color3.fromRGB(210,210,222),
        Text=Color3.fromRGB(30,30,40), TextDim=Color3.fromRGB(110,110,125),
        Accent=Color3.fromRGB(110,90,230), Border=Color3.fromRGB(200,200,215),
        SwitchOn=Color3.fromRGB(110,90,230), SwitchOff=Color3.fromRGB(170,170,185),
    },
    Stone = {
        Bg=Color3.fromRGB(38,36,34), Sidebar=Color3.fromRGB(48,46,44),
        SidebarBtn=Color3.fromRGB(58,55,52), SidebarBtnHi=Color3.fromRGB(70,66,62),
        SidebarActive=Color3.fromRGB(95,85,70), Card=Color3.fromRGB(56,53,50),
        CardBorder=Color3.fromRGB(78,74,70), Row=Color3.fromRGB(64,60,57),
        RowHover=Color3.fromRGB(75,71,67), ControlBg=Color3.fromRGB(80,75,70),
        Text=Color3.fromRGB(220,215,205), TextDim=Color3.fromRGB(160,152,140),
        Accent=Color3.fromRGB(210,160,90), Border=Color3.fromRGB(85,80,75),
        SwitchOn=Color3.fromRGB(210,160,90), SwitchOff=Color3.fromRGB(90,85,80),
    },
}
local THEME = {}
for k, v in pairs(THEMES.Black) do THEME[k] = v end

local HUNTER_COLOR = Color3.fromRGB(255, 60, 60)

-- ============================================================
-- GUI ROOT
-- ============================================================
local gui = Instance.new("ScreenGui")
gui.Name = "tk_ui_main"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 100
gui.Parent = plr:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 780, 0, 500)
main.Position = UDim2.new(0.5, -390, 0.5, -250)
main.BackgroundColor3 = THEME.Bg
main.BorderSizePixel = 0
main.Active = true
main.ClipsDescendants = true
main.Visible = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = THEME.Border; mainStroke.Thickness = 1

local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 160, 1, 0)
sidebar.BackgroundColor3 = THEME.Sidebar
sidebar.BorderSizePixel = 0

local logo = Instance.new("Frame", sidebar)
logo.Size = UDim2.new(1, -20, 0, 46)
logo.Position = UDim2.new(0, 10, 0, 12)
logo.BackgroundTransparency = 1

local logoIcon = Instance.new("TextLabel", logo)
logoIcon.Size = UDim2.new(0, 32, 0, 32)
logoIcon.Position = UDim2.new(0, 0, 0.5, -16)
logoIcon.BackgroundColor3 = THEME.Accent
logoIcon.Text = "TH"; logoIcon.TextColor3 = Color3.new(1,1,1)
logoIcon.Font = Enum.Font.GothamBold; logoIcon.TextSize = 12
logoIcon.BorderSizePixel = 0
Instance.new("UICorner", logoIcon).CornerRadius = UDim.new(0, 8)

local logoTitle = Instance.new("TextLabel", logo)
logoTitle.Size = UDim2.new(1, -40, 0, 16)
logoTitle.Position = UDim2.new(0, 40, 0.5, -16)
logoTitle.BackgroundTransparency = 1
logoTitle.Text = "Tolkahack"
logoTitle.TextColor3 = THEME.Text
logoTitle.Font = Enum.Font.GothamBold
logoTitle.TextSize = 13
logoTitle.TextXAlignment = Enum.TextXAlignment.Left

local logoSub = Instance.new("TextLabel", logo)
logoSub.Size = UDim2.new(1, -40, 0, 14)
logoSub.Position = UDim2.new(0, 40, 0.5, 0)
logoSub.BackgroundTransparency = 1
logoSub.Text = "reborn " .. VERSION
logoSub.TextColor3 = THEME.Accent
logoSub.Font = Enum.Font.Gotham
logoSub.TextSize = 10
logoSub.TextXAlignment = Enum.TextXAlignment.Left

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -160, 1, 0)
content.Position = UDim2.new(0, 160, 0, 0)
content.BackgroundTransparency = 1

local topBar = Instance.new("Frame", content)
topBar.Size = UDim2.new(1, -30, 0, 46)
topBar.Position = UDim2.new(0, 15, 0, 12)
topBar.BackgroundTransparency = 1

local pageTitle = Instance.new("TextLabel", topBar)
pageTitle.Size = UDim2.new(1, -100, 1, 0)
pageTitle.BackgroundTransparency = 1
pageTitle.Text = "Movement"
pageTitle.TextColor3 = THEME.Text
pageTitle.Font = Enum.Font.GothamBold
pageTitle.TextSize = 16
pageTitle.TextXAlignment = Enum.TextXAlignment.Left

-- Settings icon (красивая - Roblox asset)
local gearBtn = Instance.new("ImageButton", topBar)
gearBtn.Size = UDim2.new(0, 34, 0, 34)
gearBtn.Position = UDim2.new(1, -80, 0.5, -17)
gearBtn.BackgroundColor3 = THEME.Card
gearBtn.Image = "rbxassetid://6031094667"
gearBtn.ImageColor3 = THEME.Text
gearBtn.BorderSizePixel = 0
gearBtn.AutoButtonColor = false
Instance.new("UICorner", gearBtn).CornerRadius = UDim.new(0, 8)
local gearPad = Instance.new("UIPadding", gearBtn)
gearPad.PaddingTop = UDim.new(0, 6)
gearPad.PaddingBottom = UDim.new(0, 6)
gearPad.PaddingLeft = UDim.new(0, 6)
gearPad.PaddingRight = UDim.new(0, 6)

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -38, 0.5, -17)
closeBtn.BackgroundColor3 = THEME.Card
closeBtn.Text = "X"; closeBtn.TextColor3 = THEME.TextDim
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() menuOpen = false; main.Visible = false end)

local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(1, -30, 1, -110)
scroll.Position = UDim2.new(0, 15, 0, 68)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = THEME.Accent
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local columnsHolder = Instance.new("Frame", scroll)
columnsHolder.Size = UDim2.new(1, -6, 0, 0)
columnsHolder.AutomaticSize = Enum.AutomaticSize.Y
columnsHolder.BackgroundTransparency = 1

local leftCol = Instance.new("Frame", columnsHolder)
leftCol.Size = UDim2.new(0.5, -6, 0, 0)
leftCol.AutomaticSize = Enum.AutomaticSize.Y
leftCol.BackgroundTransparency = 1
Instance.new("UIListLayout", leftCol).Padding = UDim.new(0, 10)

local rightCol = Instance.new("Frame", columnsHolder)
rightCol.Size = UDim2.new(0.5, -6, 0, 0)
rightCol.Position = UDim2.new(0.5, 6, 0, 0)
rightCol.AutomaticSize = Enum.AutomaticSize.Y
rightCol.BackgroundTransparency = 1
Instance.new("UIListLayout", rightCol).Padding = UDim.new(0, 10)

local footer = Instance.new("Frame", content)
footer.Size = UDim2.new(1, -30, 0, 40)
footer.Position = UDim2.new(0, 15, 1, -46)
footer.BackgroundColor3 = THEME.Card
footer.BorderSizePixel = 0
Instance.new("UICorner", footer).CornerRadius = UDim.new(0, 10)
local footerStroke = Instance.new("UIStroke", footer)
footerStroke.Color = THEME.CardBorder; footerStroke.Thickness = 1

local avatar = Instance.new("ImageButton", footer)
avatar.Size = UDim2.new(0, 32, 0, 32)
avatar.Position = UDim2.new(0, 4, 0.5, -16)
avatar.BackgroundColor3 = THEME.ControlBg
avatar.BorderSizePixel = 0
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=0&w=150&h=150"
avatar.AutoButtonColor = false
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", avatar).Color = THEME.Accent

task.spawn(function()
    local ok, url = pcall(function()
        return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok and url then avatar.Image = url end
end)

local nickLbl = Instance.new("TextLabel", footer)
nickLbl.Size = UDim2.new(1, -180, 0, 16)
nickLbl.Position = UDim2.new(0, 44, 0.5, -16)
nickLbl.BackgroundTransparency = 1
nickLbl.Text = plr.Name
nickLbl.TextColor3 = THEME.Text
nickLbl.Font = Enum.Font.GothamBold
nickLbl.TextSize = 12
nickLbl.TextXAlignment = Enum.TextXAlignment.Left

local tagLbl = Instance.new("TextLabel", footer)
tagLbl.Size = UDim2.new(1, -180, 0, 14)
tagLbl.Position = UDim2.new(0, 44, 0.5, 0)
tagLbl.BackgroundTransparency = 1
tagLbl.Text = "Nightly build"
tagLbl.TextColor3 = THEME.Accent
tagLbl.Font = Enum.Font.Gotham; tagLbl.TextSize = 10
tagLbl.TextXAlignment = Enum.TextXAlignment.Left

local versionLbl = Instance.new("TextLabel", footer)
versionLbl.Size = UDim2.new(0, 120, 1, 0)
versionLbl.Position = UDim2.new(1, -130, 0, 0)
versionLbl.BackgroundTransparency = 1
versionLbl.Text = VERSION
versionLbl.TextColor3 = THEME.Accent
versionLbl.Font = Enum.Font.GothamBold
versionLbl.TextSize = 14
versionLbl.TextXAlignment = Enum.TextXAlignment.Right

-- ============================================================
-- EASTER EGG OVERLAY (SOON... Upd 2.0 DOLBAEB)
-- ============================================================
soonFrame = Instance.new("Frame", main)
soonFrame.Size = UDim2.new(1, 0, 1, 0)
soonFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
soonFrame.BackgroundTransparency = 0.15
soonFrame.BorderSizePixel = 0
soonFrame.ZIndex = 999
soonFrame.Visible = false

local soonTitle = Instance.new("TextLabel", soonFrame)
soonTitle.Size = UDim2.new(1, -20, 1, -20)
soonTitle.Position = UDim2.new(0, 10, 0, 10)
soonTitle.BackgroundTransparency = 1
soonTitle.Text = "SOON... Upd 2.0 DOLBAEB"
soonTitle.TextColor3 = Color3.new(1,1,1)
soonTitle.Font = Enum.Font.GothamBlack
soonTitle.TextScaled = true
soonTitle.TextStrokeTransparency = 0
soonTitle.TextStrokeColor3 = Color3.fromRGB(140,120,250)
soonTitle.ZIndex = 1000
local soonScale = Instance.new("UITextSizeConstraint", soonTitle)
soonScale.MaxTextSize = 140
soonScale.MinTextSize = 20

task.spawn(function()
    while not UNLOADED do
        if soonFrame.Visible then
            soonTitle.TextColor3 = Color3.fromRGB(
                200 + math.random(0, 55),
                200 + math.random(0, 55),
                200 + math.random(0, 55)
            )
        end
        task.wait(0.1)
    end
end)

avatar.MouseButton1Click:Connect(function()
    local now = tick()
    if now - avatarLastClick > 1.5 then avatarClickCount = 0 end
    avatarLastClick = now
    avatarClickCount = avatarClickCount + 1
    if avatarClickCount >= 5 then
        avatarClickCount = 0
        soonOpened = not soonOpened
        soonFrame.Visible = soonOpened
    end
end)

-- ============================================================
-- SETTINGS PANEL
-- ============================================================
local settingsPanel = Instance.new("Frame", main)
settingsPanel.Size = UDim2.new(0, 360, 0, 440)
settingsPanel.Position = UDim2.new(0.5, -180, 0.5, -220)
settingsPanel.BackgroundColor3 = THEME.Bg
settingsPanel.BorderSizePixel = 0
settingsPanel.ZIndex = 500
settingsPanel.Visible = false
settingsPanel.Active = true
Instance.new("UICorner", settingsPanel).CornerRadius = UDim.new(0, 12)
local setStroke = Instance.new("UIStroke", settingsPanel)
setStroke.Color = THEME.Border; setStroke.Thickness = 1

local setHeader = Instance.new("Frame", settingsPanel)
setHeader.Size = UDim2.new(1, 0, 0, 90)
setHeader.BackgroundColor3 = THEME.Card
setHeader.BorderSizePixel = 0
setHeader.ZIndex = 502
Instance.new("UICorner", setHeader).CornerRadius = UDim.new(0, 12)
local headFix = Instance.new("Frame", setHeader)
headFix.Size = UDim2.new(1, 0, 0, 12)
headFix.Position = UDim2.new(0, 0, 1, -12)
headFix.BackgroundColor3 = THEME.Card
headFix.BorderSizePixel = 0
headFix.ZIndex = 502

local bigTitle = Instance.new("TextLabel", setHeader)
bigTitle.Size = UDim2.new(1, -40, 0, 34)
bigTitle.Position = UDim2.new(0, 20, 0, 12)
bigTitle.BackgroundTransparency = 1
bigTitle.Text = "Tolkahack"
bigTitle.TextColor3 = THEME.Accent
bigTitle.Font = Enum.Font.GothamBlack
bigTitle.TextSize = 26
bigTitle.TextXAlignment = Enum.TextXAlignment.Left
bigTitle.ZIndex = 503

local creditsLabel = Instance.new("TextLabel", setHeader)
creditsLabel.Size = UDim2.new(1, -40, 0, 14)
creditsLabel.Position = UDim2.new(0, 20, 0, 48)
creditsLabel.BackgroundTransparency = 1
creditsLabel.Text = "Кодер: Prddox"
creditsLabel.TextColor3 = THEME.Text
creditsLabel.Font = Enum.Font.Gotham; creditsLabel.TextSize = 11
creditsLabel.TextXAlignment = Enum.TextXAlignment.Left
creditsLabel.ZIndex = 503

local creditsLabel2 = Instance.new("TextLabel", setHeader)
creditsLabel2.Size = UDim2.new(1, -40, 0, 14)
creditsLabel2.Position = UDim2.new(0, 20, 0, 62)
creditsLabel2.BackgroundTransparency = 1
creditsLabel2.Text = "Соавтор: makaroni"
creditsLabel2.TextColor3 = THEME.TextDim
creditsLabel2.Font = Enum.Font.Gotham; creditsLabel2.TextSize = 11
creditsLabel2.TextXAlignment = Enum.TextXAlignment.Left
creditsLabel2.ZIndex = 503

local setDrag, setDragStart, setStartPos = false, nil, nil
setHeader.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        setDrag = true; setDragStart = i.Position; setStartPos = settingsPanel.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if setDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
        settingsPanel.Position = UDim2.new(
            setStartPos.X.Scale, setStartPos.X.Offset + (i.Position - setDragStart).X,
            setStartPos.Y.Scale, setStartPos.Y.Offset + (i.Position - setDragStart).Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then setDrag = false end
end)

local scaleLabel = Instance.new("TextLabel", settingsPanel)
scaleLabel.Size = UDim2.new(1, -40, 0, 20)
scaleLabel.Position = UDim2.new(0, 20, 0, 110)
scaleLabel.BackgroundTransparency = 1
scaleLabel.Text = "Menu Scale"
scaleLabel.TextColor3 = THEME.Text
scaleLabel.Font = Enum.Font.GothamBold; scaleLabel.TextSize = 12
scaleLabel.TextXAlignment = Enum.TextXAlignment.Left
scaleLabel.ZIndex = 502

local scaleOptions = {75, 100, 125}
local scaleButtons = {}
for i, opt in ipairs(scaleOptions) do
    local b = Instance.new("TextButton", settingsPanel)
    b.Size = UDim2.new(0, 90, 0, 34)
    b.Position = UDim2.new(0, 20 + (i-1)*105, 0, 138)
    b.BackgroundColor3 = (opt == 100) and THEME.SidebarActive or THEME.Card
    b.Text = opt .. "%"
    b.TextColor3 = (opt == 100) and THEME.Text or THEME.TextDim
    b.Font = Enum.Font.GothamBold; b.TextSize = 12
    b.BorderSizePixel = 0
    b.ZIndex = 502
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        local s = opt / 100
        main.Size = UDim2.new(0, 780 * s, 0, 500 * s)
        main.Position = UDim2.new(0.5, -390 * s, 0.5, -250 * s)
        for _, other in ipairs(scaleButtons) do
            other.BackgroundColor3 = THEME.Card
            other.TextColor3 = THEME.TextDim
        end
        b.BackgroundColor3 = THEME.SidebarActive
        b.TextColor3 = THEME.Text
    end)
    table.insert(scaleButtons, b)
end

local themeLabel = Instance.new("TextLabel", settingsPanel)
themeLabel.Size = UDim2.new(1, -40, 0, 20)
themeLabel.Position = UDim2.new(0, 20, 0, 190)
themeLabel.BackgroundTransparency = 1
themeLabel.Text = "Theme"
themeLabel.TextColor3 = THEME.Text
themeLabel.Font = Enum.Font.GothamBold; themeLabel.TextSize = 12
themeLabel.TextXAlignment = Enum.TextXAlignment.Left
themeLabel.ZIndex = 502

local themeOptions = {"Black", "White", "Stone"}
local themeRuNames = {Black="Черная", White="Белая", Stone="Каменная"}
local themeButtons = {}
for i, opt in ipairs(themeOptions) do
    local b = Instance.new("TextButton", settingsPanel)
    b.Size = UDim2.new(0, 100, 0, 34)
    b.Position = UDim2.new(0, 20 + (i-1)*105, 0, 218)
    b.BackgroundColor3 = THEME.Card
    b.Text = themeRuNames[opt]
    b.TextColor3 = THEME.TextDim
    b.Font = Enum.Font.GothamBold; b.TextSize = 11
    b.BorderSizePixel = 0
    b.ZIndex = 502
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        applyTheme(opt)
    end)
    table.insert(themeButtons, b)
end

local unloadBtn = Instance.new("TextButton", settingsPanel)
unloadBtn.Size = UDim2.new(1, -40, 0, 38)
unloadBtn.Position = UDim2.new(0, 20, 0, 270)
unloadBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 50)
unloadBtn.Text = "Полная выгрузка скрипта"
unloadBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
unloadBtn.Font = Enum.Font.GothamBold; unloadBtn.TextSize = 12
unloadBtn.BorderSizePixel = 0
unloadBtn.ZIndex = 502
Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0, 8)

local closeSettings = Instance.new("TextButton", settingsPanel)
closeSettings.Size = UDim2.new(1, -40, 0, 34)
closeSettings.Position = UDim2.new(0, 20, 1, -50)
closeSettings.BackgroundColor3 = THEME.Card
closeSettings.Text = "Закрыть"
closeSettings.TextColor3 = THEME.Text
closeSettings.Font = Enum.Font.GothamBold; closeSettings.TextSize = 12
closeSettings.BorderSizePixel = 0
closeSettings.ZIndex = 502
Instance.new("UICorner", closeSettings).CornerRadius = UDim.new(0, 8)
closeSettings.MouseButton1Click:Connect(function() settingsPanel.Visible = false end)

gearBtn.MouseButton1Click:Connect(function() settingsPanel.Visible = not settingsPanel.Visible end)

-- ============================================================
-- SUSHI BUTTON
-- ============================================================
local sushiGui = Instance.new("ScreenGui")
sushiGui.Name = "tk_sushi"; sushiGui.ResetOnSpawn = false
sushiGui.DisplayOrder = 6; sushiGui.Parent = plr.PlayerGui

local sushi = Instance.new("TextButton")
sushi.Size = UDim2.new(0, 52, 0, 52)
sushi.Position = UDim2.new(1, -76, 0.5, -26)
sushi.BackgroundColor3 = THEME.Bg
sushi.Text = "TH"; sushi.TextColor3 = THEME.Accent
sushi.Font = Enum.Font.GothamBlack; sushi.TextSize = 16
sushi.BorderSizePixel = 0; sushi.Parent = sushiGui
Instance.new("UICorner", sushi).CornerRadius = UDim.new(1, 0)
local sushiStroke = Instance.new("UIStroke", sushi)
sushiStroke.Color = THEME.Accent; sushiStroke.Thickness = 2

-- ============================================================
-- KEYBIND LIST
-- ============================================================
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "tk_keys"; keyGui.ResetOnSpawn = false
keyGui.DisplayOrder = 5; keyGui.Parent = plr.PlayerGui

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 200, 0, 150)
keyFrame.Position = UDim2.new(0, 20, 0.5, -75)
keyFrame.BackgroundColor3 = THEME.Bg
keyFrame.BorderSizePixel = 0
keyFrame.Active = true; keyFrame.Visible = false
keyFrame.Parent = keyGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 10)
local keyStroke = Instance.new("UIStroke", keyFrame)
keyStroke.Color = THEME.Border; keyStroke.Thickness = 1

local keyTitle = Instance.new("Frame", keyFrame)
keyTitle.Size = UDim2.new(1, 0, 0, 26)
keyTitle.BackgroundColor3 = THEME.Sidebar
keyTitle.BorderSizePixel = 0

local keyTitleTxt = Instance.new("TextLabel", keyTitle)
keyTitleTxt.Size = UDim2.new(1, -16, 1, 0)
keyTitleTxt.Position = UDim2.new(0, 12, 0, 0)
keyTitleTxt.BackgroundTransparency = 1
keyTitleTxt.Text = "Binds"
keyTitleTxt.TextColor3 = THEME.TextDim
keyTitleTxt.Font = Enum.Font.GothamBold
keyTitleTxt.TextSize = 11
keyTitleTxt.TextXAlignment = Enum.TextXAlignment.Left

local keyRows = Instance.new("Frame", keyFrame)
keyRows.Size = UDim2.new(1, -12, 1, -34)
keyRows.Position = UDim2.new(0, 6, 0, 30)
keyRows.BackgroundTransparency = 1
Instance.new("UIListLayout", keyRows).Padding = UDim.new(0, 4)

local kDrag, kDragStart, kStartPos = false, nil, nil
keyTitle.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        kDrag = true; kDragStart = i.Position; kStartPos = keyFrame.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if kDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
        keyFrame.Position = UDim2.new(
            kStartPos.X.Scale, kStartPos.X.Offset + (i.Position - kDragStart).X,
            kStartPos.Y.Scale, kStartPos.Y.Offset + (i.Position - kDragStart).Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then kDrag = false end
end)

local keyListData = {}
local function addKeyRow(name, bindGetter, stateGetter)
    local row = Instance.new("Frame", keyRows)
    row.Size = UDim2.new(1, 0, 0, 22)
    row.BackgroundColor3 = THEME.Row
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
    local nl = Instance.new("TextLabel", row)
    nl.Size = UDim2.new(0.5, 0, 1, 0); nl.Position = UDim2.new(0, 10, 0, 0)
    nl.BackgroundTransparency = 1
    nl.Text = name; nl.TextColor3 = THEME.TextDim
    nl.Font = Enum.Font.Gotham; nl.TextSize = 11
    nl.TextXAlignment = Enum.TextXAlignment.Left
    local kl = Instance.new("TextLabel", row)
    kl.Size = UDim2.new(0.5, -10, 1, 0); kl.Position = UDim2.new(0.5, 0, 0, 0)
    kl.BackgroundTransparency = 1
    kl.Text = ""; kl.TextColor3 = THEME.TextDim
    kl.Font = Enum.Font.Gotham; kl.TextSize = 11
    kl.TextXAlignment = Enum.TextXAlignment.Right
    table.insert(keyListData, {row=row, nl=nl, kl=kl, bind=bindGetter, state=stateGetter})
end

addKeyRow("Menu", function() return Enum.KeyCode.RightShift end, function() return menuOpen end)
addKeyRow("Fly", function() return Binds.Fly end, function() return FlyOn end)
addKeyRow("NoClip", function() return Binds.NoClip end, function() return NoClipOn end)
addKeyRow("TP", function() return Binds.TP end, function() return TPOn end)
addKeyRow("Fullbright", function() return Binds.Fullbright end, function() return FullbrightOn end)

local function bindName(b)
    if typeof(b) ~= "EnumItem" then return "NONE" end
    if b == Enum.KeyCode.Unknown then return "NONE" end
    return b.Name
end
local function isPressed(b)
    if typeof(b) ~= "EnumItem" or b == Enum.KeyCode.Unknown then return false end
    if b.EnumType == Enum.KeyCode then return UIS:IsKeyDown(b) end
    if b.EnumType == Enum.UserInputType then return UIS:IsMouseButtonPressed(b) end
    return false
end
local function refreshKeyList()
    for _, d in ipairs(keyListData) do
        local key = d.bind()
        d.kl.Text = bindName(key)
        local active = d.state() or isPressed(key)
        if active then
            d.row.BackgroundColor3 = THEME.SidebarActive
            d.nl.TextColor3 = THEME.Accent
            d.kl.TextColor3 = THEME.Text
        else
            d.row.BackgroundColor3 = THEME.Row
            d.nl.TextColor3 = THEME.TextDim
            d.kl.TextColor3 = THEME.TextDim
        end
    end
end

-- ============================================================
-- UI BUILDERS
-- ============================================================
local currentCardSide = "Left"
local function newCard(title)
    local side = currentCardSide == "Left" and leftCol or rightCol
    currentCardSide = currentCardSide == "Left" and "Right" or "Left"
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = THEME.Card
    card.BorderSizePixel = 0
    card.Parent = side
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = THEME.CardBorder; stroke.Thickness = 1
    local pad = Instance.new("UIPadding", card)
    pad.PaddingTop = UDim.new(0, 10)
    pad.PaddingBottom = UDim.new(0, 10)
    pad.PaddingLeft = UDim.new(0, 10)
    pad.PaddingRight = UDim.new(0, 10)
    local list = Instance.new("UIListLayout", card)
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    if title and title ~= "" then
        local titleLbl = Instance.new("TextLabel", card)
        titleLbl.Size = UDim2.new(1, 0, 0, 22)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Text = title
        titleLbl.TextColor3 = THEME.Text
        titleLbl.Font = Enum.Font.GothamBold
        titleLbl.TextSize = 12
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.LayoutOrder = -1
    end
    return card
end

local function newRow(card, height)
    local row = Instance.new("TextButton", card)
    row.Size = UDim2.new(1, 0, 0, height or 34)
    row.BackgroundColor3 = THEME.Row
    row.Text = ""; row.AutoButtonColor = false
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
    row.MouseEnter:Connect(function() row.BackgroundColor3 = THEME.RowHover end)
    row.MouseLeave:Connect(function() row.BackgroundColor3 = THEME.Row end)
    return row
end

local function makeSwitch(row, default, cb)
    local sw = Instance.new("Frame", row)
    sw.Size = UDim2.new(0, 34, 0, 18)
    sw.Position = UDim2.new(1, -44, 0.5, -9)
    sw.BackgroundColor3 = default and THEME.SwitchOn or THEME.SwitchOff
    sw.BorderSizePixel = 0
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.new(1,1,1)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local state = default
    local function update(v, fire)
        state = v
        Tween:Create(sw, TweenInfo.new(0.12), {BackgroundColor3 = v and THEME.SwitchOn or THEME.SwitchOff}):Play()
        Tween:Create(knob, TweenInfo.new(0.12), {Position = v and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        if fire then pcall(cb, v) end
    end
    row.MouseButton1Click:Connect(function() update(not state, true) end)
    return { Set = function(v) update(v, false) end, Get = function() return state end }
end

local function makeSlider(parent, pos, size, min, max, default, cb)
    local holder = Instance.new("Frame", parent)
    holder.Size = size; holder.Position = pos; holder.BackgroundTransparency = 1
    local track = Instance.new("Frame", holder)
    track.Size = UDim2.new(1, -44, 0, 4)
    track.Position = UDim2.new(0, 0, 0.5, -2)
    track.BackgroundColor3 = THEME.ControlBg
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = THEME.Accent
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    local valueLbl = Instance.new("TextLabel", holder)
    valueLbl.Size = UDim2.new(0, 38, 1, 0)
    valueLbl.Position = UDim2.new(1, -38, 0, 0)
    valueLbl.BackgroundTransparency = 1
    valueLbl.Text = tostring(default)
    valueLbl.TextColor3 = THEME.Accent
    valueLbl.Font = Enum.Font.GothamBold; valueLbl.TextSize = 11
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    local val, dragging = default, false
    local function apply(input)
        local r = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(r, 0, 1, 0)
        val = math.floor(min + r * (max - min))
        valueLbl.Text = tostring(val)
        if cb then cb(val) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; apply(i) end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then apply(i) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    return {Get = function() return val end}
end

local function refreshBindButton(name)
    local btn = bindButtons[name]
    if btn then btn.Text = bindName(Binds[name]); btn.TextColor3 = THEME.TextDim end
end
local function assignBind(name, newKey)
    for other, kv in pairs(Binds) do
        if other ~= name and kv == newKey and newKey ~= Enum.KeyCode.Unknown then
            Binds[other] = Enum.KeyCode.Unknown
            refreshBindButton(other)
        end
    end
    Binds[name] = newKey
    refreshBindButton(name)
    refreshKeyList()
end

local function addToggle(card, label, default, cb, keyName)
    local row = newRow(card, 34)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -70, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextColor3 = THEME.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local sw = makeSwitch(row, default, cb)
    if keyName then uiRefs[keyName] = sw end
    return sw
end

local function addToggleBind(card, label, default, cb, bindKey)
    local row = newRow(card, 34)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -170, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextColor3 = THEME.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local sw = makeSwitch(row, default, cb)
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 70, 0, 22)
    btn.Position = UDim2.new(1, -118, 0.5, -11)
    btn.BackgroundColor3 = THEME.ControlBg
    btn.Text = bindName(Binds[bindKey])
    btn.TextColor3 = THEME.TextDim
    btn.Font = Enum.Font.Gotham; btn.TextSize = 10
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    bindButtons[bindKey] = btn
    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."; btn.TextColor3 = THEME.Accent
        listeningBind = bindKey
    end)
    uiRefs[bindKey] = sw
    return sw
end

local function addSlider(card, label, min, max, default, cb)
    local row = newRow(card, 34)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.4, 0, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label; lbl.TextColor3 = THEME.Text
    lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    makeSlider(row, UDim2.new(1, -150, 0.5, -8), UDim2.new(0, 140, 0, 16), min, max, default, cb)
    return row
end

local function addButton(card, label, cb)
    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = THEME.Row
    btn.Text = label; btn.TextColor3 = THEME.Text
    btn.Font = Enum.Font.Gotham; btn.TextSize = 12
    btn.BorderSizePixel = 0; btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = THEME.RowHover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = THEME.Row end)
    btn.MouseButton1Click:Connect(function() pcall(cb) end)
    return btn
end

-- ESP MODE SELECTOR CONTAINER (для анимации выезда)
local espModeContainer = nil
local espModeButtons = {}

local function buildEspModeButtons(parent)
    espModeContainer = Instance.new("Frame", parent)
    espModeContainer.Size = UDim2.new(1, 0, 0, EspOn and 30 or 0)
    espModeContainer.BackgroundTransparency = 1
    espModeContainer.ClipsDescendants = true
    espModeContainer.Visible = EspOn

    local layout = Instance.new("UIListLayout", espModeContainer)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 6)

    local labels = {"Mode 1", "Mode 2", "Mode 3"}
    for i, name in ipairs(labels) do
        local b = Instance.new("TextButton", espModeContainer)
        b.Size = UDim2.new(0, 84, 1, 0)
        b.BackgroundColor3 = (i == EspMode) and THEME.SidebarActive or THEME.Card
        b.Text = name
        b.TextColor3 = (i == EspMode) and THEME.Text or THEME.TextDim
        b.Font = Enum.Font.GothamBold; b.TextSize = 11
        b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function()
            EspMode = i
            for j, other in ipairs(espModeButtons) do
                other.BackgroundColor3 = (j == i) and THEME.SidebarActive or THEME.Card
                other.TextColor3 = (j == i) and THEME.Text or THEME.TextDim
            end
            -- очистить всё и заново
            for _, d in pairs(espData) do
                pcall(function()
                    if d.hl then d.hl:Destroy() end
                    if d.bb then d.bb:Destroy() end
                    if d.box then d.box:Destroy() end
                    if d.hpBar then d.hpBar:Destroy() end
                end)
            end
            espData = {}
        end)
        espModeButtons[i] = b
    end
end

local function animateEspModes(show)
    if not espModeContainer then return end
    if show then
        espModeContainer.Visible = true
        Tween:Create(espModeContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(1, 0, 0, 30)}):Play()
    else
        Tween:Create(espModeContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Size = UDim2.new(1, 0, 0, 0)}):Play()
        task.delay(0.25, function()
            if espModeContainer and not EspOn then espModeContainer.Visible = false end
        end)
    end
end

-- ============================================================
-- CATEGORIES
-- ============================================================
local categories = {
    {name="Movement", icon="M"},
    {name="Combat",   icon="C"},
    {name="Visuals",  icon="V"},
    {name="Misc",     icon="X"},
    {name="Client",   icon="S"},
}

local catButtons = {}
local catHolder = Instance.new("Frame", sidebar)
catHolder.Size = UDim2.new(1, -16, 1, -84)
catHolder.Position = UDim2.new(0, 8, 0, 72)
catHolder.BackgroundTransparency = 1
Instance.new("UIListLayout", catHolder).Padding = UDim.new(0, 4)

for i, cat in ipairs(categories) do
    local btn = Instance.new("TextButton", catHolder)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = THEME.SidebarBtn
    btn.Text = ""; btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local iconLbl = Instance.new("TextLabel", btn)
    iconLbl.Name = "Icon"
    iconLbl.Size = UDim2.new(0, 26, 1, 0); iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = cat.icon; iconLbl.TextColor3 = THEME.TextDim
    iconLbl.Font = Enum.Font.GothamBold; iconLbl.TextSize = 13
    local nameLbl = Instance.new("TextLabel", btn)
    nameLbl.Name = "Label"
    nameLbl.Size = UDim2.new(1, -40, 1, 0); nameLbl.Position = UDim2.new(0, 36, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = cat.name; nameLbl.TextColor3 = THEME.TextDim
    nameLbl.Font = Enum.Font.Gotham; nameLbl.TextSize = 12
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    btn.MouseButton1Click:Connect(function() setTab(i) end)
    btn.MouseEnter:Connect(function()
        if currentTab ~= i then btn.BackgroundColor3 = THEME.SidebarBtnHi end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= i then btn.BackgroundColor3 = THEME.SidebarBtn end
    end)
    catButtons[i] = btn
end

local loaders = {}
function setTab(idx)
    currentTab = idx
    for i, b in ipairs(catButtons) do
        local iconLbl = b:FindFirstChild("Icon")
        local nameLbl = b:FindFirstChild("Label")
        if i == idx then
            b.BackgroundColor3 = THEME.SidebarActive
            if iconLbl then iconLbl.TextColor3 = THEME.Accent end
            if nameLbl then nameLbl.TextColor3 = THEME.Text end
        else
            b.BackgroundColor3 = THEME.SidebarBtn
            if iconLbl then iconLbl.TextColor3 = THEME.TextDim end
            if nameLbl then nameLbl.TextColor3 = THEME.TextDim end
        end
    end
    pageTitle.Text = categories[idx].name
    if loaders[idx] then pcall(loaders[idx]) end
end

-- ============================================================
-- THEME APPLIER
-- ============================================================
function applyTheme(name)
    if not THEMES[name] then return end
    CurrentTheme = name
    for k, v in pairs(THEMES[name]) do THEME[k] = v end

    main.BackgroundColor3 = THEME.Bg
    mainStroke.Color = THEME.Border
    sidebar.BackgroundColor3 = THEME.Sidebar
    logoIcon.BackgroundColor3 = THEME.Accent
    logoTitle.TextColor3 = THEME.Text
    logoSub.TextColor3 = THEME.Accent
    pageTitle.TextColor3 = THEME.Text
    gearBtn.BackgroundColor3 = THEME.Card
    gearBtn.ImageColor3 = THEME.Text
    closeBtn.BackgroundColor3 = THEME.Card
    closeBtn.TextColor3 = THEME.TextDim
    scroll.ScrollBarImageColor3 = THEME.Accent
    footer.BackgroundColor3 = THEME.Card
    footerStroke.Color = THEME.CardBorder
    avatar.BackgroundColor3 = THEME.ControlBg
    nickLbl.TextColor3 = THEME.Text
    tagLbl.TextColor3 = THEME.Accent
    versionLbl.TextColor3 = THEME.Accent
    sushi.BackgroundColor3 = THEME.Bg
    sushi.TextColor3 = THEME.Accent
    sushiStroke.Color = THEME.Accent
    keyFrame.BackgroundColor3 = THEME.Bg
    keyStroke.Color = THEME.Border
    keyTitle.BackgroundColor3 = THEME.Sidebar
    keyTitleTxt.TextColor3 = THEME.TextDim
    settingsPanel.BackgroundColor3 = THEME.Bg
    setStroke.Color = THEME.Border
    setHeader.BackgroundColor3 = THEME.Card
    headFix.BackgroundColor3 = THEME.Card
    bigTitle.TextColor3 = THEME.Accent
    creditsLabel.TextColor3 = THEME.Text
    creditsLabel2.TextColor3 = THEME.TextDim
    scaleLabel.TextColor3 = THEME.Text
    themeLabel.TextColor3 = THEME.Text
    closeSettings.BackgroundColor3 = THEME.Card
    closeSettings.TextColor3 = THEME.Text

    -- Theme buttons
    for i, b in ipairs(themeButtons) do
        local optName = themeOptions[i]
        if optName == name then
            b.BackgroundColor3 = THEME.SidebarActive
            b.TextColor3 = THEME.Text
        else
            b.BackgroundColor3 = THEME.Card
            b.TextColor3 = THEME.TextDim
        end
    end

    -- Scale buttons
    for _, b in ipairs(scaleButtons) do
        if b.BackgroundColor3 ~= THEME.SidebarActive then
            b.BackgroundColor3 = THEME.Card
            b.TextColor3 = THEME.TextDim
        end
    end

    -- Reload current tab to refresh colors of all cards
    setTab(currentTab)
    refreshKeyList()
end

-- ============================================================
-- HELPERS
-- ============================================================
local function getChar() return plr.Character end
local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart") or nil
end
local function getHumanoid()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end
local function bindMatches(bind, input)
    if typeof(bind) ~= "EnumItem" or bind == Enum.KeyCode.Unknown then return false end
    if bind.EnumType == Enum.KeyCode then return input.KeyCode == bind end
    if bind.EnumType == Enum.UserInputType then return input.UserInputType == bind end
    return false
end

-- ============================================================
-- NOCLIP / TP / JUMP / FLY / SPEED / FREECAM / FULLBRIGHT / FPS
-- ============================================================
local function setNoClip(on)
    NoClipOn = on
    local char = getChar(); if not char then return end
    if on then
        savedCollisions = {}
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                savedCollisions[p] = {p.CanCollide, p.CanTouch, p.CanQuery}
                p.CanCollide = false; p.CanTouch = false; p.CanQuery = false
            end
        end
    else
        for p, s in pairs(savedCollisions) do
            if p.Parent then
                p.CanCollide = s[1]; p.CanTouch = s[2]; p.CanQuery = s[3]
            end
        end
        savedCollisions = {}
    end
end
local function updateNoClipActive()
    if not NoClipOn then return end
    local char = getChar(); if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if p.CanCollide then
                if not savedCollisions[p] then
                    savedCollisions[p] = {true, p.CanTouch, p.CanQuery}
                end
                p.CanCollide = false
            end
            if p.CanTouch then p.CanTouch = false end
            if p.CanQuery then p.CanQuery = false end
        end
    end
end

local function teleportToMouse()
    local hrp = getHRP(); if not hrp then return end
    local hit = mouse.Hit; if not hit then return end
    local target = hit.Position + Vector3.new(0, 3, 0)
    local wasNoclip = NoClipOn
    if not wasNoclip then setNoClip(true) end
    local startT = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick() - startT > 0.25 then
            conn:Disconnect()
            if not wasNoclip then setNoClip(false) end
            return
        end
        hrp.CFrame = CFrame.new(target)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end)
    if FlyOn then flyDesired = target end
end

local function doJump()
    local hum, hrp = getHumanoid(), getHRP()
    if not hum or not hrp then return end
    if hum.FloorMaterial ~= Enum.Material.Air then
        pcall(function() hum.JumpPower = JumpValue; hum.JumpHeight = JumpValue/7 end)
        hrp.AssemblyLinearVelocity = Vector3.new(
            hrp.AssemblyLinearVelocity.X, JumpValue, hrp.AssemblyLinearVelocity.Z)
    end
end
local function setFly(on)
    FlyOn = on
    local hrp = getHRP()
    if on and hrp then flyDesired = hrp.Position else flyDesired = nil end
end
local function updateFly(dt)
    if not FlyOn or not flyDesired then return end
    local hrp = getHRP(); if not hrp then return end
    if (hrp.Position - flyDesired).Magnitude > 30 then flyDesired = hrp.Position end
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end
    if dir.Magnitude > 0 then flyDesired = flyDesired + dir.Unit * FlySpeed * dt end
    hrp.CFrame = CFrame.new(flyDesired) * (hrp.CFrame - hrp.CFrame.Position)
    hrp.AssemblyLinearVelocity = Vector3.zero
end
local function setSpeed(on)
    SpeedOn = on
    local hum = getHumanoid(); if not hum then return end
    if on then
        if baseWalk == nil then baseWalk = 16 end
        hum.WalkSpeed = SpeedValue
    else
        pcall(function() hum.WalkSpeed = baseWalk or 16 end)
        baseWalk = nil
    end
end
local function keepSpeed()
    if not SpeedOn and not EmoteRunOn then return end
    local hum = getHumanoid(); if not hum then return end
    if SpeedOn and hum.WalkSpeed ~= SpeedValue then hum.WalkSpeed = SpeedValue end
    if EmoteRunOn and hum.WalkSpeed < 16 and hum.WalkSpeed > 0 then hum.WalkSpeed = 16 end
end

local function setFreecam(on)
    FreecamOn = on
    if on then
        local hrp = getHRP()
        if hrp then
            freecamPos = hrp.Position + Vector3.new(0, 5, 0)
            local cf = cam.CFrame
            freecamRotY = math.atan2(cf.LookVector.X, cf.LookVector.Z)
            freecamRotX = math.asin(math.clamp(cf.LookVector.Y, -1, 1))
            freecamSavedPosition = hrp.CFrame
        end
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CameraSubject = nil
    else
        cam.CameraType = Enum.CameraType.Custom
        local hum = getHumanoid(); if hum then cam.CameraSubject = hum end
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        freecamSavedPosition = nil
    end
end
local function updateFreecam(dt)
    if not FreecamOn then return end
    if cam.CameraType ~= Enum.CameraType.Scriptable then
        cam.CameraType = Enum.CameraType.Scriptable
        cam.CameraSubject = nil
    end
    UIS.MouseBehavior = menuOpen and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
    local hrp = getHRP()
    if hrp and freecamSavedPosition then
        hrp.CFrame = freecamSavedPosition
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
    local mv = Vector3.zero
    local lv, rv = cam.CFrame.LookVector, cam.CFrame.RightVector
    if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + lv end
    if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - lv end
    if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - rv end
    if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + rv end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.yAxis end
    if mv.Magnitude > 0 then freecamPos = freecamPos + mv.Unit * freecamSpeed * dt end
    if not menuOpen then
        local d = UIS:GetMouseDelta()
        freecamRotY = freecamRotY - d.X * 0.003
        freecamRotX = math.clamp(freecamRotX - d.Y * 0.003, -math.rad(89), math.rad(89))
    end
    cam.CFrame = CFrame.new(freecamPos) * CFrame.Angles(freecamRotX, freecamRotY, 0)
end

local function setFullbright(on)
    FullbrightOn = on
    if on then
        fbOriginal = {}
        for p in pairs(fbProps) do fbOriginal[p] = Lighting[p] end
        for p, v in pairs(fbProps) do pcall(function() Lighting[p] = v end) end
    else
        if fbOriginal then
            for p, v in pairs(fbOriginal) do pcall(function() Lighting[p] = v end) end
            fbOriginal = nil
        end
    end
end

local function setFpsBoost(on)
    FpsBoostOn = on
    if on then
        fpsBoostSaved = {materials = {}, globalShadows = Lighting.GlobalShadows, fogEnd = Lighting.FogEnd}
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Material ~= Enum.Material.SmoothPlastic then
                fpsBoostSaved.materials[v] = v.Material
                v.Material = Enum.Material.SmoothPlastic
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
    else
        if fpsBoostSaved then
            for part, mat in pairs(fpsBoostSaved.materials) do
                if part.Parent then pcall(function() part.Material = mat end) end
            end
            pcall(function() Lighting.GlobalShadows = fpsBoostSaved.globalShadows end)
            pcall(function() Lighting.FogEnd = fpsBoostSaved.fogEnd end)
            fpsBoostSaved = nil
        end
    end
end

-- ============================================================
-- HUNTER DETECTION
-- ============================================================
local HUNTER_KEYWORDS = {"hunter","killer","murderer","monster","slasher","chaser","jason","michael","ghost","demon"}
local WEAPON_KEYWORDS = {"knife","axe","machete","sword","sickle","scythe","weapon","blade","cleaver","hammer"}
local function hasWeapon(container)
    if not container then return false end
    for _, t in ipairs(container:GetChildren()) do
        if t:IsA("Tool") then
            local tn = t.Name:lower()
            for _, kw in ipairs(WEAPON_KEYWORDS) do if tn:find(kw) then return true end end
        end
    end
    return false
end
local function isHunter(p)
    if p.Team then
        local tn = p.Team.Name:lower()
        for _, kw in ipairs(HUNTER_KEYWORDS) do if tn:find(kw) then return true end end
    end
    for _, attr in ipairs({"Role","role","Hunter","Killer","IsKiller","IsHunter"}) do
        local v = p:GetAttribute(attr)
        if type(v) == "string" then
            local lv = v:lower()
            for _, kw in ipairs(HUNTER_KEYWORDS) do if lv:find(kw) then return true end end
        elseif type(v) == "boolean" and v then
            local la = attr:lower()
            if la:find("hunter") or la:find("killer") then return true end
        end
    end
    local char = p.Character
    if char then
        for _, attr in ipairs({"Role","role","Hunter","Killer"}) do
            local v = char:GetAttribute(attr)
            if type(v) == "string" then
                local lv = v:lower()
                for _, kw in ipairs(HUNTER_KEYWORDS) do if lv:find(kw) then return true end end
            end
        end
        if hasWeapon(char) then return true end
    end
    if hasWeapon(p:FindFirstChild("Backpack")) then return true end
    return false
end

local function getNearestKiller(maxRange)
    local hrp = getHRP(); if not hrp then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and p.Character and isHunter(p) then
            local phrp = p.Character:FindFirstChild("HumanoidRootPart")
            local phum = p.Character:FindFirstChildOfClass("Humanoid")
            if phrp and phum and phum.Health > 0 then
                local d = (phrp.Position - hrp.Position).Magnitude
                if d < nearestDist and d <= maxRange then
                    nearestDist = d; nearest = p
                end
            end
        end
    end
    return nearest
end

local function updateTriggerBot()
    if not TriggerBotOn then return end
    local char = getChar(); if not char then return end
    local killer = getNearestKiller(TriggerRange)
    if not killer then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local now = tick()
    if now - triggerLastAttack < 0.08 then return end
    triggerLastAttack = now
    pcall(function() tool:Activate() end)
end

local BOMB_KEYWORDS = {"water","bomb","bottle","grenade","flash","smoke"}
local function findBombTool()
    local char = getChar(); if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            for _, kw in ipairs(BOMB_KEYWORDS) do if n:find(kw) then return t end end
        end
    end
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                for _, kw in ipairs(BOMB_KEYWORDS) do if n:find(kw) then return t end end
            end
        end
    end
    return nil
end
local lastBombThrow = 0
local function updateAutoThrow()
    if not AutoThrowOn then return end
    local char = getChar(); if not char then return end
    local killer = getNearestKiller(TriggerRange + 8)
    if not killer then return end
    local bomb = findBombTool()
    if not bomb then return end
    local now = tick()
    if now - lastBombThrow < 0.5 then return end
    lastBombThrow = now
    if bomb.Parent ~= char then pcall(function() bomb.Parent = char end) end
    task.wait(0.05)
    pcall(function() bomb:Activate() end)
end

-- ============================================================
-- ANTI FLASH
-- ============================================================
local FLASH_KEYWORDS = {"flash","blind","stun","white","fade","shake"}
local function cleanFlashObject(obj)
    if not obj or not AntiFlashOn then return end
    local n = (obj.Name or ""):lower()
    for _, kw in ipairs(FLASH_KEYWORDS) do
        if n:find(kw) then
            pcall(function()
                if obj:IsA("Frame") then obj.BackgroundTransparency = 1 end
                if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then obj.ImageTransparency = 1 end
                if obj:IsA("TextLabel") then obj.TextTransparency = 1 end
            end)
            return
        end
    end
    if obj:IsA("Frame") then
        local c = obj.BackgroundColor3
        if obj.Size.X.Scale >= 0.95 and obj.Size.Y.Scale >= 0.95
           and c.R > 0.9 and c.G > 0.9 and c.B > 0.9 then
            pcall(function() obj.BackgroundTransparency = 1 end)
        end
    end
end
local function setupAntiFlash()
    for _, conn in ipairs(antiFlashConnections) do
        pcall(function() conn:Disconnect() end)
    end
    antiFlashConnections = {}
    local pg = plr:FindFirstChild("PlayerGui")
    if pg then
        local c = pg.ChildAdded:Connect(function(child)
            if not AntiFlashOn then return end
            task.defer(function() cleanFlashObject(child) end)
        end)
        table.insert(antiFlashConnections, c)
        for _, d in ipairs(pg:GetChildren()) do cleanFlashObject(d) end
    end
end
local function setAntiFlash(on)
    AntiFlashOn = on
    if on then setupAntiFlash()
    else
        for _, conn in ipairs(antiFlashConnections) do
            pcall(function() conn:Disconnect() end)
        end
        antiFlashConnections = {}
    end
end

-- ============================================================
-- EMOTE
-- ============================================================
local function setEmoteRun(on)
    EmoteRunOn = on
    if emoteAnimConn then emoteAnimConn:Disconnect(); emoteAnimConn = nil end
    if emoteConn then emoteConn:Disconnect(); emoteConn = nil end
    if on then
        local char = getChar()
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    emoteAnimConn = animator.AnimationPlayed:Connect(function(track)
                        if not EmoteRunOn then return end
                        local aid = track.Animation and track.Animation.AnimationId
                        if aid then savedEmoteId = aid end
                        pcall(function() track.Priority = Enum.AnimationPriority.Action4 end)
                    end)
                end
            end
        end
        emoteConn = RunService.Heartbeat:Connect(function()
            if not EmoteRunOn then return end
            local c = getChar(); if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid"); if not h then return end
            if h.WalkSpeed < 16 and h.WalkSpeed > 0 then h.WalkSpeed = 16 end
        end)
    end
end

-- ============================================================
-- ESP (3 MODES)
-- ============================================================
local function clearEspPlayer(p)
    local d = espData[p]; if not d then return end
    pcall(function()
        if d.hl then d.hl:Destroy() end
        if d.bb then d.bb:Destroy() end
        if d.box then d.box:Destroy() end
        if d.hpBar then d.hpBar:Destroy() end
        if d.nameLbl then d.nameLbl:Destroy() end
    end)
    espData[p] = nil
end

local function clearEsp()
    for p, _ in pairs(espData) do clearEspPlayer(p) end
    espData = {}
end

local function makeBoxLine(parent)
    local l = Instance.new("Frame", parent)
    l.BackgroundColor3 = Color3.new(1,1,1)
    l.BorderSizePixel = 0
    return l
end

local function updateEsp()
    if not EspOn then return end
    local myHRP = getHRP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and p.Character then
            local char = p.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hrp then
                local d = espData[p]
                if not d then
                    d = {
                        char = char,
                        hl=nil, bb=nil, tl=nil,
                        box=nil, corners=nil, hpBar=nil, hpFill=nil,
                        modeBuilt = EspMode,
                    }
                    espData[p] = d
                end

                -- если режим сменился — пересоздаём
                if d.modeBuilt ~= EspMode then
                    clearEspPlayer(p)
                    d = {char = char, modeBuilt = EspMode}
                    espData[p] = d
                end

                local hunter = isHunter(p)
                local col = hunter and HUNTER_COLOR or Color3.fromRGB(255,255,255)

                -- Mode 1: Highlight + Name
                if EspMode == 1 then
                    if not d.hl then
                        d.hl = Instance.new("Highlight")
                        d.hl.FillTransparency = 0.55
                        d.hl.OutlineTransparency = 0
                        d.hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        d.hl.Parent = char
                    end
                    d.hl.Adornee = char
                    d.hl.FillColor = col
                    d.hl.OutlineColor = col

                    if not d.bb then
                        d.bb = Instance.new("BillboardGui")
                        d.bb.Size = UDim2.new(0, 140, 0, 24)
                        d.bb.StudsOffset = Vector3.new(0, 3, 0)
                        d.bb.AlwaysOnTop = true
                        d.bb.Adornee = hrp
                        d.bb.Parent = char
                        d.tl = Instance.new("TextLabel", d.bb)
                        d.tl.Size = UDim2.new(1, 0, 1, 0)
                        d.tl.BackgroundTransparency = 1
                        d.tl.Font = Enum.Font.Gotham
                        d.tl.TextSize = 12
                        d.tl.TextStrokeTransparency = 0.2
                    end
                    d.bb.Adornee = hrp
                    d.tl.TextColor3 = col
                    local distText = myHRP and (" [" .. math.floor((myHRP.Position - hrp.Position).Magnitude) .. "m]") or ""
                    d.tl.Text = p.Name .. distText .. (hunter and " [HUNTER]" or "")

                -- Mode 2: Corner Box + HP bar + Name
                elseif EspMode == 2 then
                    if not d.box then
                        d.box = Instance.new("Frame", gui)
                        d.box.BackgroundTransparency = 1
                        d.box.BorderSizePixel = 0
                        d.box.ZIndex = 5
                        d.corners = {}
                        for i=1,4 do d.corners[i] = makeBoxLine(d.box) end
                        d.hpBar = Instance.new("Frame", gui)
                        d.hpBar.BorderSizePixel = 0
                        d.hpBar.BackgroundColor3 = Color3.fromRGB(20,20,20)
                        d.hpBar.ZIndex = 5
                        d.hpFill = Instance.new("Frame", d.hpBar)
                        d.hpFill.BorderSizePixel = 0
                        d.hpFill.ZIndex = 6
                        d.bb = Instance.new("BillboardGui")
                        d.bb.Size = UDim2.new(0, 140, 0, 20)
                        d.bb.StudsOffset = Vector3.new(0, 3.2, 0)
                        d.bb.AlwaysOnTop = true
                        d.bb.Adornee = hrp
                        d.bb.Parent = char
                        d.tl = Instance.new("TextLabel", d.bb)
                        d.tl.Size = UDim2.new(1, 0, 1, 0)
                        d.tl.BackgroundTransparency = 1
                        d.tl.Font = Enum.Font.GothamBold
                        d.tl.TextSize = 11
                        d.tl.TextStrokeTransparency = 0.2
                    end
                    local top = hrp.Position + Vector3.new(0, 3, 0)
                    local bottom = hrp.Position - Vector3.new(0, 3, 0)
                    local topV, topVis = cam:WorldToViewportPoint(top)
                    local botV, botVis = cam:WorldToViewportPoint(bottom)
                    if topVis and botVis and topV.Z > 0 then
                        local x = topV.X
                        local y1, y2 = topV.Y, botV.Y
                        local h = math.abs(y2 - y1)
                        local w = h * 0.55
                        local cx = x - w/2
                        local cy = math.min(y1, y2)

                        d.box.Visible = true
                        d.box.Position = UDim2.fromOffset(cx, cy)
                        d.box.Size = UDim2.fromOffset(w, h)

                        local th = 1
                        local cl = math.min(w, h) * 0.28
                        -- 4 corner segments
                        d.corners[1].Position = UDim2.fromOffset(0, 0)
                        d.corners[1].Size = UDim2.fromOffset(cl, th)
                        d.corners[2].Position = UDim2.fromOffset(w - cl, 0)
                        d.corners[2].Size = UDim2.fromOffset(cl, th)
                        d.corners[3].Position = UDim2.fromOffset(0, 0)
                        d.corners[3].Size = UDim2.fromOffset(th, cl)
                        d.corners[4].Position = UDim2.fromOffset(w - th, 0)
                        d.corners[4].Size = UDim2.fromOffset(th, cl)
                        -- доп. нижние углы
                        local c5 = d.corners[5] or makeBoxLine(d.box)
                        local c6 = d.corners[6] or makeBoxLine(d.box)
                        local c7 = d.corners[7] or makeBoxLine(d.box)
                        local c8 = d.corners[8] or makeBoxLine(d.box)
                        d.corners[5], d.corners[6], d.corners[7], d.corners[8] = c5, c6, c7, c8

                        c5.Position = UDim2.fromOffset(0, h - th)
                        c5.Size = UDim2.fromOffset(cl, th)
                        c6.Position = UDim2.fromOffset(w - cl, h - th)
                        c6.Size = UDim2.fromOffset(cl, th)
                        c7.Position = UDim2.fromOffset(0, h - cl)
                        c7.Size = UDim2.fromOffset(th, cl)
                        c8.Position = UDim2.fromOffset(w - th, h - cl)
                        c8.Size = UDim2.fromOffset(th, cl)

                        for _, line in ipairs(d.corners) do
                            line.Visible = true
                            line.BackgroundColor3 = col
                        end

                        d.hpBar.Visible = true
                        d.hpBar.Position = UDim2.fromOffset(cx - 5, cy)
                        d.hpBar.Size = UDim2.fromOffset(3, h)
                        local hp = hum.Health / hum.MaxHealth
                        d.hpFill.Size = UDim2.new(1, 0, hp, 0)
                        d.hpFill.Position = UDim2.new(0, 0, 1 - hp, 0)
                        d.hpFill.BackgroundColor3 = Color3.fromRGB(75, 255, 125):Lerp(Color3.fromRGB(255,65,65), 1 - hp)

                        d.bb.Adornee = hrp
                        d.tl.TextColor3 = col
                        local distText = myHRP and (" [" .. math.floor((myHRP.Position - hrp.Position).Magnitude) .. "m]") or ""
                        d.tl.Text = p.Name .. distText .. (hunter and " [HUNTER]" or "")
                    else
                        d.box.Visible = false
                        d.hpBar.Visible = false
                        if d.bb then d.bb.Enabled = false end
                    end
                    if d.bb then d.bb.Enabled = true end

                -- Mode 3: Chams (яркий силуэт сквозь стены, без текста)
                elseif EspMode == 3 then
                    if not d.hl then
                        d.hl = Instance.new("Highlight")
                        d.hl.FillTransparency = 0.35
                        d.hl.OutlineTransparency = 0
                        d.hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        d.hl.Parent = char
                    end
                    d.hl.Adornee = char
                    d.hl.FillColor = col
                    d.hl.OutlineColor = col
                end
            else
                if espData[p] then clearEspPlayer(p) end
            end
        end
    end
end

-- ============================================================
-- ANTI VOID
-- ============================================================
local function updateAntiVoid()
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp then return end
    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        voidSnapshot = hrp.Position
        return
    end
    if voidSnapshot and hrp.AssemblyLinearVelocity.Y < -40 then
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {plr.Character}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -200, 0), rp)
        if not hit then
            hrp.CFrame = CFrame.new(voidSnapshot + Vector3.new(0, 3, 0))
            hrp.AssemblyLinearVelocity = Vector3.zero
            if FlyOn then flyDesired = hrp.Position end
        end
    end
end

-- ============================================================
-- UNLOAD
-- ============================================================
local function unloadScript()
    UNLOADED = true
    pcall(function() if FlyOn then setFly(false) end end)
    pcall(function() if NoClipOn then setNoClip(false) end end)
    pcall(function() if SpeedOn then setSpeed(false) end end)
    pcall(function() if FreecamOn then setFreecam(false) end end)
    pcall(function() if FullbrightOn then setFullbright(false) end end)
    pcall(function() if FpsBoostOn then setFpsBoost(false) end end)
    pcall(function() if AntiFlashOn then setAntiFlash(false) end end)
    pcall(function() clearEsp() end)
    pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.Default end)
    pcall(function() gui:Destroy() end)
    pcall(function() keyGui:Destroy() end)
    pcall(function() sushiGui:Destroy() end)
end
unloadBtn.MouseButton1Click:Connect(unloadScript)

-- ============================================================
-- LOADERS
-- ============================================================
local function clearAll()
    for _, c in ipairs(leftCol:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for _, c in ipairs(rightCol:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    currentCardSide = "Left"
    espModeButtons = {}
    espModeContainer = nil
end

local function loadMovement()
    clearAll()
    local fly = newCard("Fly")
    addToggleBind(fly, "Fly", FlyOn, function(s)
        setFly(s)
        if uiRefs.Fly then uiRefs.Fly.Set(s) end
    end, "Fly")
    addSlider(fly, "Fly Speed", 10, 200, FlySpeed, function(v) FlySpeed = v end)

    local move = newCard("Movement")
    addToggle(move, "Jump Enabled", JumpOn, function(s) JumpOn = s end, "Jump")
    addSlider(move, "Jump Power", 20, 150, JumpValue, function(v)
        JumpValue = v
        local hum = getHumanoid()
        if hum then hum.JumpPower = v; hum.JumpHeight = v/7 end
    end)
    addSlider(move, "Walk Speed", 16, 60, SpeedValue, function(v)
        SpeedValue = v
        if SpeedOn then
            local hum = getHumanoid(); if hum then hum.WalkSpeed = v end
        end
    end)
    addToggle(move, "Speed Enabled", SpeedOn, function(s) setSpeed(s) end, "Speed")

    local nc = newCard("Noclip")
    addToggleBind(nc, "Noclip", NoClipOn, function(s)
        setNoClip(s)
        if uiRefs.NoClip then uiRefs.NoClip.Set(s) end
    end, "NoClip")

    local tp = newCard("Teleport")
    addToggleBind(tp, "Click TP", TPOn, function(s)
        TPOn = s
        if uiRefs.TP then uiRefs.TP.Set(s) end
    end, "TP")
    addButton(tp, "TP to Mouse", function() teleportToMouse() end)
end

local function loadCombat()
    clearAll()
    local tb = newCard("Trigger Bot")
    addToggle(tb, "Trigger Bot", TriggerBotOn, function(s) TriggerBotOn = s end, "TriggerBot")
    addSlider(tb, "Range", 5, 30, TriggerRange, function(v) TriggerRange = v end)

    local tb2 = newCard("Auto Throw")
    addToggle(tb2, "Auto Throw Bomb", AutoThrowOn, function(s) AutoThrowOn = s end, "AutoThrow")

    local af = newCard("Anti Flash")
    addToggle(af, "Anti Flash", AntiFlashOn, function(s) setAntiFlash(s) end, "AntiFlash")

    local w = newCard("Weapon")
    addToggle(w, "TP Kill", TPKillOn, function(s) TPKillOn = s end)
end

local function loadVisuals()
    clearAll()
    local esp = newCard("ESP")
    addToggle(esp, "Player ESP", EspOn, function(s)
        EspOn = s
        if not s then clearEsp() end
        animateEspModes(s)
    end, "Esp")
    buildEspModeButtons(esp)

    local camCard = newCard("Camera")
    addToggle(camCard, "Freecam", FreecamOn, function(s) setFreecam(s) end, "Freecam")
    addSlider(camCard, "Freecam Speed", 10, 200, freecamSpeed, function(v) freecamSpeed = v end)

    local fb = newCard("Lighting")
    addToggleBind(fb, "Fullbright", FullbrightOn, function(s)
        setFullbright(s)
        if uiRefs.Fullbright then uiRefs.Fullbright.Set(s) end
    end, "Fullbright")
end

local function loadMisc()
    clearAll()
    local em = newCard("Emote")
    addToggle(em, "Emote While Running", EmoteRunOn, function(s) setEmoteRun(s) end, "EmoteRun")

    local ui = newCard("UI")
    addToggle(ui, "Show Round Button", SushiVisible, function(s)
        SushiVisible = s
        sushi.Visible = s
    end, "SushiBtn")

    local kbCard = newCard("Keybind List")
    addToggle(kbCard, "Show Binds", KeyListOn, function(s)
        KeyListOn = s
        keyFrame.Visible = s
    end, "KeyList")
end

local function loadClient()
    clearAll()
    local c = newCard("Client")
    addButton(c, "Rejoin", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, plr)
    end)
    addToggle(c, "FPS Boost", FpsBoostOn, function(s)
        setFpsBoost(s)
        if uiRefs.FpsBoost then uiRefs.FpsBoost.Set(s) end
    end, "FpsBoost")
end

loaders = {loadMovement, loadCombat, loadVisuals, loadMisc, loadClient}

-- ============================================================
-- DRAG
-- ============================================================
local dragging, dragStart, startPos = false, nil, nil
logo.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + (i.Position - dragStart).X,
            startPos.Y.Scale, startPos.Y.Offset + (i.Position - dragStart).Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

local sDrag, sMoved, sStart, sPos = false, 0, nil, nil
sushi.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        sDrag = true; sMoved = 0
        sStart = i.Position; sPos = sushi.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if sDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - sStart
        sMoved = sMoved + math.abs(d.X) + math.abs(d.Y)
        sushi.Position = UDim2.new(
            sPos.X.Scale, sPos.X.Offset + d.X,
            sPos.Y.Scale, sPos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 and sDrag then
        sDrag = false
        if sMoved < 6 then
            menuOpen = not menuOpen
            main.Visible = menuOpen
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if JumpOn and not FlyOn and not FreecamOn then doJump() end
end)

UIS.InputBegan:Connect(function(input, gp)
    if UNLOADED then return end
    if listeningBind then
        if input.KeyCode == Enum.KeyCode.Escape then
            assignBind(listeningBind, Enum.KeyCode.Unknown)
            listeningBind = nil
            return
        end
        local nb
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            nb = input.KeyCode
        elseif input.UserInputType.Name:match("MouseButton") then
            nb = input.UserInputType
        end
        if nb then assignBind(listeningBind, nb); listeningBind = nil end
        return
    end
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        menuOpen = not menuOpen
        main.Visible = menuOpen
        return
    end
    if bindMatches(Binds.Fly, input) then
        FlyOn = not FlyOn; setFly(FlyOn)
        if uiRefs.Fly then uiRefs.Fly.Set(FlyOn) end
    elseif bindMatches(Binds.NoClip, input) then
        NoClipOn = not NoClipOn; setNoClip(NoClipOn)
        if uiRefs.NoClip then uiRefs.NoClip.Set(NoClipOn) end
    elseif bindMatches(Binds.TP, input) then
        if TPOn then teleportToMouse() end
    elseif bindMatches(Binds.Fullbright, input) then
        FullbrightOn = not FullbrightOn; setFullbright(FullbrightOn)
        if uiRefs.Fullbright then uiRefs.Fullbright.Set(FullbrightOn) end
    end
end)

plr.CharacterAdded:Connect(function(char)
    if UNLOADED then return end
    task.wait(0.5)
    flyDesired = nil
    baseWalk = nil
    voidSnapshot = nil
    savedCollisions = {}
    freecamSavedPosition = nil
    savedEmoteId = nil
    clearEsp()
    task.wait(0.3)
    if NoClipOn then
        NoClipOn = false
        if uiRefs.NoClip then uiRefs.NoClip.Set(false) end
    end
    if FreecamOn then
        FreecamOn = false
        setFreecam(false)
        if uiRefs.Freecam then uiRefs.Freecam.Set(false) end
    end
end)

-- ============================================================
-- MAIN LOOP
-- ============================================================
local heartbeatAcc = 0
RunService.Heartbeat:Connect(function(dt)
    if UNLOADED then return end
    if FreecamOn then updateFreecam(dt) else updateFly(dt) end
    if NoClipOn then updateNoClipActive() end
    if SpeedOn or EmoteRunOn then keepSpeed() end
    if not FreecamOn then updateAntiVoid() end
    if TriggerBotOn then updateTriggerBot() end
    if AutoThrowOn then updateAutoThrow() end

    heartbeatAcc = heartbeatAcc + dt
    if heartbeatAcc >= 0.1 then
        heartbeatAcc = 0
        if KeyListOn then refreshKeyList() end
        if EspOn then updateEsp() end
    end
end)

setTab(1)
refreshKeyList()

StarterGui:SetCore("SendNotification", {
    Title = "Tolkahack " .. VERSION,
    Text = "Загружено! RightShift = меню",
    Duration = 5,
})
