--================================================================
-- TolstiiKolya — v1.1
--================================================================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Lighting   = game:GetService("Lighting")
local Tween      = game:GetService("TweenService")
local plr        = Players.LocalPlayer
local cam        = workspace.CurrentCamera
local mouse      = plr:GetMouse()

local VERSION = "v1.1"
local LOGO_ASSET = "rbxassetid://0" -- ⚠️ ЗАМЕНИ на ID твоей картинки (формат: rbxassetid://НОМЕР)

local FlyOn, NoClipOn, TPOn = false, false, false
local JumpOn, JumpValue = true, 55
local SpeedOn, SpeedValue = false, 24
local TPKillOn = false
local TriggerBotOn, TriggerRange = false, 12
local AutoThrowOn = false
local AntiFlashOn = false
local EspOn = false
local KeyListOn, FreecamOn, FullbrightOn, FpsBoostOn = true, false, false, false
local FlySpeed = 60
local currentTab = 1

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
local baseWalk, voidSafe = nil, nil
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

-- EASTER EGG (5 кликов на аватарку)
local avatarClickCount = 0
local avatarLastClick = 0
local soonOpened = false
local soonFrame = nil
local prevTabBeforeSoon = 1

local THEME = {
    Bg=Color3.fromRGB(12,12,16), Sidebar=Color3.fromRGB(16,16,21),
    SidebarBtn=Color3.fromRGB(24,24,31), SidebarBtnHi=Color3.fromRGB(34,34,44),
    SidebarActive=Color3.fromRGB(45,40,70), Card=Color3.fromRGB(22,22,28),
    CardBorder=Color3.fromRGB(38,38,48), Row=Color3.fromRGB(30,30,38),
    RowHover=Color3.fromRGB(38,38,48), ControlBg=Color3.fromRGB(40,40,52),
    Text=Color3.fromRGB(230,230,240), TextDim=Color3.fromRGB(150,150,165),
    Accent=Color3.fromRGB(140,120,250), Border=Color3.fromRGB(40,40,50),
    SwitchOn=Color3.fromRGB(140,120,250), SwitchOff=Color3.fromRGB(60,60,72),
}

-- MAIN WINDOW
local gui = Instance.new("ScreenGui")
gui.Name = "tk_ui"; gui.ResetOnSpawn = false
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
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = THEME.Border; mainStroke.Thickness = 1

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 160, 1, 0)
sidebar.BackgroundColor3 = THEME.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main
local sbSep = Instance.new("Frame", sidebar)
sbSep.Size = UDim2.new(0, 1, 1, -20)
sbSep.Position = UDim2.new(1, 0, 0, 10)
sbSep.BackgroundColor3 = THEME.Border
sbSep.BorderSizePixel = 0

-- LOGO (теперь картинка вместо "T")
local logo = Instance.new("Frame", sidebar)
logo.Name = "Logo"
logo.Size = UDim2.new(1, -20, 0, 46)
logo.Position = UDim2.new(0, 10, 0, 12)
logo.BackgroundTransparency = 1

local logoIcon = Instance.new("ImageLabel", logo)
logoIcon.Name = "LogoIcon"
logoIcon.Size = UDim2.new(0, 32, 0, 32)
logoIcon.Position = UDim2.new(0, 0, 0.5, -16)
logoIcon.BackgroundColor3 = THEME.Accent
logoIcon.Image = LOGO_ASSET
logoIcon.ImageColor3 = Color3.new(1,1,1)
logoIcon.ScaleType = Enum.ScaleType.Crop
logoIcon.BorderSizePixel = 0
Instance.new("UICorner", logoIcon).CornerRadius = UDim.new(0, 8)
-- если картинки нет — показываем "T"
if LOGO_ASSET == "rbxassetid://0" then
    logoIcon.Image = ""
    local tLbl = Instance.new("TextLabel", logoIcon)
    tLbl.Size = UDim2.new(1, 0, 1, 0)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = "T"; tLbl.TextColor3 = Color3.new(1,1,1)
    tLbl.Font = Enum.Font.GothamBold; tLbl.TextSize = 16
end

local logoTitle = Instance.new("TextLabel", logo)
logoTitle.Size = UDim2.new(1, -40, 0, 16)
logoTitle.Position = UDim2.new(0, 40, 0.5, -16)
logoTitle.BackgroundTransparency = 1
logoTitle.Text = "TolstiiKolya"
logoTitle.TextColor3 = THEME.Text
logoTitle.Font = Enum.Font.GothamBold
logoTitle.TextSize = 13
logoTitle.TextXAlignment = Enum.TextXAlignment.Left

local logoSub = Instance.new("TextLabel", logo)
logoSub.Size = UDim2.new(1, -40, 0, 14)
logoSub.Position = UDim2.new(0, 40, 0.5, 0)
logoSub.BackgroundTransparency = 1
logoSub.Text = "reborn • " .. VERSION
logoSub.TextColor3 = THEME.Accent
logoSub.Font = Enum.Font.Gotham
logoSub.TextSize = 10
logoSub.TextXAlignment = Enum.TextXAlignment.Left

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -160, 1, 0)
content.Position = UDim2.new(0, 160, 0, 0)
content.BackgroundTransparency = 1
content.Parent = main

local topBar = Instance.new("Frame", content)
topBar.Size = UDim2.new(1, -30, 0, 46)
topBar.Position = UDim2.new(0, 15, 0, 12)
topBar.BackgroundTransparency = 1

local pageTitle = Instance.new("TextLabel", topBar)
pageTitle.Size = UDim2.new(0, 300, 1, 0)
pageTitle.BackgroundTransparency = 1
pageTitle.Text = "Movement"
pageTitle.TextColor3 = THEME.Text
pageTitle.Font = Enum.Font.GothamBold
pageTitle.TextSize = 16
pageTitle.TextXAlignment = Enum.TextXAlignment.Left

local searchBox = Instance.new("TextBox", topBar)
searchBox.Size = UDim2.new(0, 180, 0, 34)
searchBox.Position = UDim2.new(1, -220, 0.5, -17)
searchBox.BackgroundColor3 = THEME.Card
searchBox.Text = ""
searchBox.PlaceholderText = "Search..."
searchBox.PlaceholderColor3 = THEME.TextDim
searchBox.TextColor3 = THEME.Text
searchBox.Font = Enum.Font.Gotham; searchBox.TextSize = 12
searchBox.BorderSizePixel = 0
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)
local searchPad = Instance.new("UIPadding", searchBox)
searchPad.PaddingLeft = UDim.new(0, 12)

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 34, 0, 34)
closeBtn.Position = UDim2.new(1, -38, 0.5, -17)
closeBtn.BackgroundColor3 = THEME.Card
closeBtn.Text = "×"; closeBtn.TextColor3 = THEME.TextDim
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 18
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
local leftList = Instance.new("UIListLayout", leftCol)
leftList.Padding = UDim.new(0, 10)

local rightCol = Instance.new("Frame", columnsHolder)
rightCol.Size = UDim2.new(0.5, -6, 0, 0)
rightCol.Position = UDim2.new(0.5, 6, 0, 0)
rightCol.AutomaticSize = Enum.AutomaticSize.Y
rightCol.BackgroundTransparency = 1
local rightList = Instance.new("UIListLayout", rightCol)
rightList.Padding = UDim.new(0, 10)

-- FOOTER
local footer = Instance.new("Frame", content)
footer.Size = UDim2.new(1, -30, 0, 40)
footer.Position = UDim2.new(0, 15, 1, -46)
footer.BackgroundColor3 = THEME.Card
footer.BorderSizePixel = 0
Instance.new("UICorner", footer).CornerRadius = UDim.new(0, 10)
local footerStroke = Instance.new("UIStroke", footer)
footerStroke.Color = THEME.CardBorder; footerStroke.Thickness = 1

local avatar = Instance.new("ImageLabel", footer)
avatar.Size = UDim2.new(0, 32, 0, 32)
avatar.Position = UDim2.new(0, 4, 0.5, -16)
avatar.BackgroundColor3 = THEME.ControlBg
avatar.BorderSizePixel = 0
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=0&w=150&h=150"
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
local avatarStroke = Instance.new("UIStroke", avatar)
avatarStroke.Color = THEME.Accent; avatarStroke.Thickness = 1

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
tagLbl.Text = "Версия Nightly"
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

--================================================================
-- SOON OVERLAY (пасхалка)
--================================================================
soonFrame = Instance.new("Frame", main)
soonFrame.Name = "SoonOverlay"
soonFrame.Size = UDim2.new(1, 0, 1, 0)
soonFrame.Position = UDim2.new(0, 0, 0, 0)
soonFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
soonFrame.BackgroundTransparency = 0.15
soonFrame.BorderSizePixel = 0
soonFrame.ZIndex = 999
soonFrame.Visible = false

local soonTitle = Instance.new("TextLabel", soonFrame)
soonTitle.Size = UDim2.new(1, 0, 1, 0)
soonTitle.BackgroundTransparency = 1
soonTitle.Text = "SOON... DOLBAEB"
soonTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
soonTitle.Font = Enum.Font.GothamBlack
soonTitle.TextScaled = true
soonTitle.TextStrokeTransparency = 0
soonTitle.TextStrokeColor3 = THEME.Accent
soonTitle.ZIndex = 1000
local soonScale = Instance.new("UITextSizeConstraint", soonTitle)
soonScale.MaxTextSize = 200
soonScale.MinTextSize = 30

-- лёгкое мерцание чтобы было "живо"
task.spawn(function()
    while true do
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

--================================================================
-- EASTER EGG LOGIC (5 кликов на аватарку)
--================================================================
local function openSoon()
    soonOpened = true
    prevTabBeforeSoon = currentTab
    soonFrame.Visible = true
end

local function closeSoon()
    soonOpened = false
    soonFrame.Visible = false
    setTab(prevTabBeforeSoon)
end

avatar.InputBegan:Connect(function(i)
    if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    local now = tick()
    -- если прошло >1.5 сек с прошлого клика — сбрасываем
    if now - avatarLastClick > 1.5 then
        avatarClickCount = 0
    end
    avatarLastClick = now
    avatarClickCount = avatarClickCount + 1

    if avatarClickCount >= 5 then
        avatarClickCount = 0
        if soonOpened then
            closeSoon()
        else
            openSoon()
        end
    end
end)

-- SUSHI BUTTON
local sushiGui = Instance.new("ScreenGui")
sushiGui.Name = "sushi_btn"; sushiGui.ResetOnSpawn = false
sushiGui.DisplayOrder = 6; sushiGui.Parent = plr.PlayerGui

local sushi = Instance.new("TextButton")
sushi.Size = UDim2.new(0, 52, 0, 52)
sushi.Position = UDim2.new(1, -76, 0.5, -26)
sushi.BackgroundColor3 = THEME.Bg
sushi.Text = ""; sushi.TextColor3 = THEME.Accent
sushi.Font = Enum.Font.GothamBlack; sushi.TextSize = 18
sushi.BorderSizePixel = 0; sushi.Parent = sushiGui
Instance.new("UICorner", sushi).CornerRadius = UDim.new(1, 0)
local sushiStroke = Instance.new("UIStroke", sushi)
sushiStroke.Color = THEME.Accent; sushiStroke.Thickness = 2

-- иконка суши тоже картинка
local sushiImg = Instance.new("ImageLabel", sushi)
sushiImg.Size = UDim2.new(1, -8, 1, -8)
sushiImg.Position = UDim2.new(0, 4, 0, 4)
sushiImg.BackgroundTransparency = 1
sushiImg.Image = LOGO_ASSET
sushiImg.ScaleType = Enum.ScaleType.Crop
sushiImg.BorderSizePixel = 0
Instance.new("UICorner", sushiImg).CornerRadius = UDim.new(1, 0)
if LOGO_ASSET == "rbxassetid://0" then
    sushiImg.Image = ""
    sushi.Text = "T"
end

-- KEYBIND LIST
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "kb_list"; keyGui.ResetOnSpawn = false
keyGui.DisplayOrder = 5; keyGui.Parent = plr.PlayerGui

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0, 200, 0, 150)
keyFrame.Position = UDim2.new(0, 20, 0.5, -75)
keyFrame.BackgroundColor3 = THEME.Bg
keyFrame.BorderSizePixel = 0
keyFrame.Active = true; keyFrame.Visible = true
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
local keyRowsLayout = Instance.new("UIListLayout", keyRows)
keyRowsLayout.Padding = UDim.new(0, 4)

local keyListData = {}
local function addKeyRow(name, bindGetter, stateGetter)
    local row = Instance.new("Frame", keyRows)
    row.Size = UDim2.new(1, 0, 0, 22)
    row.BackgroundColor3 = THEME.Row
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local nl = Instance.new("TextLabel", row)
    nl.Size = UDim2.new(0.5, 0, 1, 0)
    nl.Position = UDim2.new(0, 10, 0, 0)
    nl.BackgroundTransparency = 1
    nl.Text = name; nl.TextColor3 = THEME.TextDim
    nl.Font = Enum.Font.Gotham; nl.TextSize = 11
    nl.TextXAlignment = Enum.TextXAlignment.Left

    local kl = Instance.new("TextLabel", row)
    kl.Size = UDim2.new(0.5, -10, 1, 0)
    kl.Position = UDim2.new(0.5, 0, 0, 0)
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

-- UI BUILDERS
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
    return {
        Set = function(v) update(v, false) end,
        SetWithCallback = function(v) update(v, true) end,
        Get = function() return state end,
    }
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
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; apply(i)
        end
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

-- CATEGORIES
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
local catList = Instance.new("UIListLayout", catHolder)
catList.Padding = UDim.new(0, 4)

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
    if loaders[idx] then
        local ok, err = pcall(loaders[idx])
        if not ok then
            warn("[Loader Error] " .. tostring(err))
            pageTitle.Text = "ERR: " .. tostring(err):sub(1, 60)
        end
    end
end

-- HELPERS
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

-- NOCLIP
local function setNoClip(on)
    NoClipOn = on
    local char = getChar()
    if not char then return end
    if on then
        savedCollisions = {}
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                savedCollisions[p] = {p.CanCollide, p.CanTouch, p.CanQuery}
                p.CanCollide = false
                p.CanTouch = false
                p.CanQuery = false
            end
        end
    else
        for p, s in pairs(savedCollisions) do
            if p.Parent then
                p.CanCollide = s[1]
                p.CanTouch = s[2]
                p.CanQuery = s[3]
            end
        end
        savedCollisions = {}
    end
end

local function updateNoClipActive()
    if not NoClipOn then return end
    local char = getChar()
    if not char then return end
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

-- CLICK TP
local function teleportToMouse()
    local hrp = getHRP()
    if not hrp then return end
    local hit = mouse.Hit
    if not hit then return end
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
        hrp.AssemblyAngularVelocity = Vector3.zero
    end)
    voidSafe = target
    if FlyOn then flyDesired = target end
end

-- JUMP / FLY / SPEED
local function doJump()
    local hum, hrp = getHumanoid(), getHRP()
    if not hum or not hrp then return end
    if hum.FloorMaterial ~= Enum.Material.Air then
        pcall(function() hum.JumpPower = JumpValue; hum.JumpHeight = JumpValue/7 end)
        hrp.AssemblyLinearVelocity = Vector3.new(
            hrp.AssemblyLinearVelocity.X,
            JumpValue,
            hrp.AssemblyLinearVelocity.Z)
    end
end
local function setFly(on)
    FlyOn = on
    local hrp = getHRP()
    if on and hrp then flyDesired = hrp.Position else flyDesired = nil end
end
local function updateFly(dt)
    if not FlyOn or not flyDesired then return end
    local hrp = getHRP()
    if not hrp then return end
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
    local hum = getHumanoid()
    if not hum then return end
    if on then
        if baseWalk == nil then baseWalk = 16 end
        hum.WalkSpeed = SpeedValue
    else
        pcall(function() hum.WalkSpeed = baseWalk or 16 end)
        baseWalk = nil
    end
end
local function keepSpeed()
    if not SpeedOn then return end
    local hum = getHumanoid()
    if not hum then return end
    if hum.WalkSpeed ~= SpeedValue then hum.WalkSpeed = SpeedValue end
end

-- FREECAM
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
        local hum = getHumanoid()
        if hum then cam.CameraSubject = hum end
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        freecamSavedPosition = nil
        task.defer(function()
            if not FreecamOn then
                cam.CameraType = Enum.CameraType.Custom
                local h = getHumanoid()
                if h then cam.CameraSubject = h end
            end
        end)
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
        hrp.AssemblyAngularVelocity = Vector3.zero
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

-- FULLBRIGHT
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

-- FPS BOOST
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

-- HUNTER DETECTION
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

-- TRIGGER BOT
local function getNearestKiller(maxRange)
    local hrp = getHRP()
    if not hrp then return nil, math.huge end
    local nearest, nearestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and p.Character and isHunter(p) then
            local phrp = p.Character:FindFirstChild("HumanoidRootPart")
            local phum = p.Character:FindFirstChildOfClass("Humanoid")
            if phrp and phum and phum.Health > 0 then
                local d = (phrp.Position - hrp.Position).Magnitude
                if d < nearestDist and d <= maxRange then
                    nearestDist = d
                    nearest = p
                end
            end
        end
    end
    return nearest, nearestDist
end

local function activateToolOnce(tool)
    if not tool then return end
    pcall(function() tool:Activate() end)
end

local function updateTriggerBot()
    if not TriggerBotOn then return end
    local char = getChar()
    if not char then return end
    local killer = getNearestKiller(TriggerRange)
    if not killer then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    local now = tick()
    if now - triggerLastAttack < 0.08 then return end
    triggerLastAttack = now
    activateToolOnce(tool)
end

-- AUTO THROW BOMB
local BOMB_KEYWORDS = {"water","bomb","bottle","grenade","flash","smoke"}
local function findBombTool()
    local char = getChar()
    if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            for _, kw in ipairs(BOMB_KEYWORDS) do
                if n:find(kw) then return t end
            end
        end
    end
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                for _, kw in ipairs(BOMB_KEYWORDS) do
                    if n:find(kw) then return t end
                end
            end
        end
    end
    return nil
end

local lastBombThrow = 0
local function updateAutoThrow()
    if not AutoThrowOn then return end
    local char = getChar()
    if not char then return end
    local killer = getNearestKiller(TriggerRange + 8)
    if not killer then return end
    local bomb = findBombTool()
    if not bomb then return end
    local now = tick()
    if now - lastBombThrow < 0.5 then return end
    lastBombThrow = now
    if bomb.Parent ~= char then
        pcall(function() bomb.Parent = char end)
    end
    task.wait(0.05)
    pcall(function() bomb:Activate() end)
end

-- ANTI FLASH
local FLASH_KEYWORDS = {"flash","blind","stun","white","fade","shake"}

local function cleanFlashObject(obj)
    if not obj then return end
    local n = (obj.Name or ""):lower()
    local isFlash = false
    for _, kw in ipairs(FLASH_KEYWORDS) do
        if n:find(kw) then isFlash = true; break end
    end
    if obj:IsA("Frame") then
        local c = obj.BackgroundColor3
        if obj.Size.X.Scale >= 0.95 and obj.Size.Y.Scale >= 0.95
           and c.R > 0.9 and c.G > 0.9 and c.B > 0.9 then
            isFlash = true
        end
    end
    if obj:IsA("ImageLabel") and obj.Size.X.Scale >= 0.95 and obj.Size.Y.Scale >= 0.95 then
        local c = obj.ImageColor3
        if c.R > 0.9 and c.G > 0.9 and c.B > 0.9 then isFlash = true end
    end

    if isFlash then
        pcall(function()
            if obj:IsA("Frame") then obj.BackgroundTransparency = 1 end
            if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then obj.ImageTransparency = 1 end
            if obj:IsA("TextLabel") then obj.TextTransparency = 1 end
            if obj:IsA("BlurEffect") then obj:Destroy() end
            if obj:IsA("ColorCorrectionEffect") then obj:Destroy() end
        end)
    end

    for _, d in ipairs(obj:GetDescendants()) do
        pcall(cleanFlashObject, d)
    end
end

local function setupAntiFlash()
    for _, conn in ipairs(antiFlashConnections) do
        pcall(function() conn:Disconnect() end)
    end
    antiFlashConnections = {}

    local function hook(parent)
        local c = parent.ChildAdded:Connect(function(child)
            if not AntiFlashOn then return end
            task.defer(function()
                if AntiFlashOn then pcall(cleanFlashObject, child) end
            end)
        end)
        table.insert(antiFlashConnections, c)
        for _, d in ipairs(parent:GetDescendants()) do
            if AntiFlashOn then pcall(cleanFlashObject, d) end
        end
    end

    hook(plr:WaitForChild("PlayerGui"))
    pcall(function() hook(game:GetService("CoreGui")) end)

    local lc = Lighting:GetPropertyChangedSignal("Brightness"):Connect(function()
        if AntiFlashOn and Lighting.Brightness > 3 then
            Lighting.Brightness = 3
        end
    end)
    table.insert(antiFlashConnections, lc)
end

local function setAntiFlash(on)
    AntiFlashOn = on
    if on then
        setupAntiFlash()
    else
        for _, conn in ipairs(antiFlashConnections) do
            pcall(function() conn:Disconnect() end)
        end
        antiFlashConnections = {}
    end
end

-- ESP
local function clearEsp()
    for _, d in pairs(espData) do
        pcall(function()
            if d.hl then d.hl:Destroy() end
            if d.bb then d.bb:Destroy() end
        end)
    end
    espData = {}
end
local function updateEsp()
    if not EspOn then return end
    local myHRP = getHRP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and p.Character then
            local char = p.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local d = espData[p]
                if not d then
                    local hl = Instance.new("Highlight")
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Adornee = char; hl.Parent = char
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.new(0, 140, 0, 24)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop = true
                    bb.Adornee = hrp or char; bb.Parent = char
                    local tl = Instance.new("TextLabel", bb)
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.Font = Enum.Font.Gotham; tl.TextSize = 12
                    tl.TextStrokeTransparency = 0.2
                    d = {hl=hl, bb=bb, tl=tl}; espData[p] = d
                end
                local hunter = isHunter(p)
                local col = hunter and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(255, 255, 255)
                d.hl.FillColor = col; d.hl.OutlineColor = col; d.tl.TextColor3 = col
                local distText = ""
                if myHRP and hrp then
                    distText = " [" .. math.floor((myHRP.Position - hrp.Position).Magnitude) .. "m]"
                end
                d.tl.Text = p.Name .. distText .. (hunter and " [HUNTER]" or "")
            elseif espData[p] then
                pcall(function()
                    espData[p].hl:Destroy(); espData[p].bb:Destroy()
                end)
                espData[p] = nil
            end
        end
    end
end

-- ANTI VOID
local function updateAntiVoid()
    local hrp, hum = getHRP(), getHumanoid()
    if not hrp then return end
    if hum and hum.FloorMaterial ~= Enum.Material.Air and math.abs(hrp.AssemblyLinearVelocity.Y) < 20 then
        voidSafe = hrp.Position
    end
    if voidSafe and hrp.AssemblyLinearVelocity.Y < -20 then
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {plr.Character}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -150, 0), rp)
        if not hit then
            hrp.CFrame = CFrame.new(voidSafe + Vector3.new(0, 3, 0))
            hrp.AssemblyLinearVelocity = Vector3.zero
            if FlyOn then flyDesired = hrp.Position end
        end
    end
end

-- LOADERS
local function clearAll()
    for _, c in ipairs(leftCol:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for _, c in ipairs(rightCol:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    currentCardSide = "Left"
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
    addSlider(move, "Walk Speed", 16, 60, SpeedValue, function(v)
        SpeedValue = v
        if SpeedOn then
            local hum = getHumanoid()
            if hum then hum.WalkSpeed = v end
        end
    end)
    addToggle(move, "Speed Enabled", SpeedOn, function(s) setSpeed(s) end, "Speed")
    addSlider(move, "Jump Power", 20, 150, JumpValue, function(v)
        JumpValue = v
        local hum = getHumanoid()
        if hum then hum.JumpPower = v; hum.JumpHeight = v/7 end
    end)

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
    addToggle(esp, "Player ESP", EspOn, function(s) EspOn = s; if not s then clearEsp() end end)

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
    local info = newCard("Info")
    local infoLbl = Instance.new("TextLabel", info)
    infoLbl.Size = UDim2.new(1, 0, 0, 60)
    infoLbl.BackgroundTransparency = 1
    infoLbl.Text = "Раздел в разработке.\nСкоро появятся новые функции."
    infoLbl.TextColor3 = THEME.TextDim
    infoLbl.Font = Enum.Font.Gotham
    infoLbl.TextSize = 11
    infoLbl.TextWrapped = true
    infoLbl.TextYAlignment = Enum.TextYAlignment.Top
    infoLbl.TextXAlignment = Enum.TextXAlignment.Left
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

    local kb = newCard("Keybind List")
    addToggle(kb, "Show Binds", KeyListOn, function(s)
        KeyListOn = s
        keyFrame.Visible = s
    end, "KeyList")
end

loaders = {loadMovement, loadCombat, loadVisuals, loadMisc, loadClient}

-- DRAG MAIN
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

-- SUSHI
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

-- INPUT
UIS.JumpRequest:Connect(function()
    if JumpOn and not FlyOn and not FreecamOn then doJump() end
end)

UIS.InputBegan:Connect(function(input, gp)
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
        if nb then
            assignBind(listeningBind, nb)
            listeningBind = nil
        end
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

-- RESPAWN
plr.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    flyDesired = nil
    baseWalk = nil
    voidSafe = nil
    savedCollisions = {}
    freecamSavedPosition = nil
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

-- MAIN LOOP
local heartbeatAcc = 0
RunService.Heartbeat:Connect(function(dt)
    if FreecamOn then
        updateFreecam(dt)
    else
        updateFly(dt)
    end

    if NoClipOn then updateNoClipActive() end
    if SpeedOn then keepSpeed() end
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
