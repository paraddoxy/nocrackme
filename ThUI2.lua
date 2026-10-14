local G = getgenv()
local TK = G.TK
if not TK then warn("[TK] Запусти PART 1 сначала!") return end

local Tween = TK.Tween
local UIS = TK.UIS
local THEME = TK.THEME

-- KEYBIND LIST
local keyGui=Instance.new("ScreenGui")
keyGui.Name="tk_keys" keyGui.ResetOnSpawn=false
keyGui.DisplayOrder=5 keyGui.Parent=TK.plr.PlayerGui
TK.keyGui=keyGui
local keyFrame=Instance.new("Frame")
keyFrame.Size=UDim2.new(0,200,0,30) keyFrame.AutomaticSize=Enum.AutomaticSize.Y
keyFrame.Position=UDim2.new(0,20,0.5,-85) keyFrame.BackgroundColor3=THEME.Bg
keyFrame.BorderSizePixel=0 keyFrame.Active=true keyFrame.Visible=false
keyFrame.Parent=keyGui
Instance.new("UICorner",keyFrame).CornerRadius=UDim.new(0,10)
Instance.new("UIStroke",keyFrame).Color=THEME.Border
local keyPad=Instance.new("UIPadding",keyFrame) keyPad.PaddingBottom=UDim.new(0,6)
TK.keyFrame=keyFrame
local keyTitle=Instance.new("Frame",keyFrame)
keyTitle.Size=UDim2.new(1,0,0,26) keyTitle.BackgroundColor3=THEME.Sidebar
keyTitle.BorderSizePixel=0 keyTitle.ZIndex=2
local keyTitleTxt=Instance.new("TextLabel",keyTitle)
keyTitleTxt.Size=UDim2.new(1,-16,1,0) keyTitleTxt.Position=UDim2.new(0,12,0,0)
keyTitleTxt.BackgroundTransparency=1 keyTitleTxt.Text="Binds"
keyTitleTxt.TextColor3=THEME.TextDim keyTitleTxt.Font=Enum.Font.GothamBold
keyTitleTxt.TextSize=11 keyTitleTxt.TextXAlignment=Enum.TextXAlignment.Left
TK.keyTitleTxt=keyTitleTxt
local keyRows=Instance.new("Frame",keyFrame)
keyRows.Size=UDim2.new(1,-12,0,0) keyRows.Position=UDim2.new(0,6,0,30)
keyRows.BackgroundTransparency=1 keyRows.AutomaticSize=Enum.AutomaticSize.Y
Instance.new("UIListLayout",keyRows).Padding=UDim.new(0,4)
TK.keyRows=keyRows
local kDrag,kDragStart,kStartPos=false,nil,nil
keyTitle.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then kDrag=true kDragStart=i.Position kStartPos=keyFrame.Position end
end)
UIS.InputChanged:Connect(function(i)
    if kDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
        keyFrame.Position=UDim2.new(kStartPos.X.Scale,kStartPos.X.Offset+(i.Position-kDragStart).X,kStartPos.Y.Scale,kStartPos.Y.Offset+(i.Position-kDragStart).Y)
    end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then kDrag=false end end)

TK.keyListData={}
function TK.addKeyRow(name,bindGetter,stateGetter)
    local row=Instance.new("Frame",keyRows)
    row.Size=UDim2.new(1,0,0,22) row.BackgroundColor3=THEME.Row row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,5)
    local nl=Instance.new("TextLabel",row)
    nl.Size=UDim2.new(0.5,0,1,0) nl.Position=UDim2.new(0,10,0,0)
    nl.BackgroundTransparency=1 nl.Text=name nl.TextColor3=THEME.TextDim
    nl.Font=Enum.Font.Gotham nl.TextSize=11 nl.TextXAlignment=Enum.TextXAlignment.Left
    local kl=Instance.new("TextLabel",row)
    kl.Size=UDim2.new(0.5,-10,1,0) kl.Position=UDim2.new(0.5,0,0,0)
    kl.BackgroundTransparency=1 kl.Text="" kl.TextColor3=THEME.TextDim
    kl.Font=Enum.Font.Gotham kl.TextSize=11 kl.TextXAlignment=Enum.TextXAlignment.Right
    table.insert(TK.keyListData,{row=row,nl=nl,kl=kl,bind=bindGetter,state=stateGetter,name=name})
end
TK.addKeyRow("Menu",function() return Enum.KeyCode.RightShift end,function() return TK.menuOpen end)
TK.addKeyRow("Fly",function() return TK.Binds.Fly end,function() return TK.FlyOn end)
TK.addKeyRow("NoClip",function() return TK.Binds.NoClip end,function() return TK.NoClipOn end)
TK.addKeyRow("TP",function() return TK.Binds.TP end,function() return TK.TPOn end)
TK.addKeyRow("Freecam",function() return TK.Binds.Freecam end,function() return TK.FreecamOn end)
TK.addKeyRow("Fullbright",function() return TK.Binds.Fullbright end,function() return TK.FullbrightOn end)

function TK.bindName(b)
    if typeof(b)~="EnumItem" then return "NONE" end
    if b==Enum.KeyCode.Unknown then return "NONE" end
    return b.Name
end
function TK.isPressed(b)
    if typeof(b)~="EnumItem" or b==Enum.KeyCode.Unknown then return false end
    if b.EnumType==Enum.KeyCode then return UIS:IsKeyDown(b) end
    if b.EnumType==Enum.UserInputType then return UIS:IsMouseButtonPressed(b) end
    return false
end
function TK.refreshKeyList()
    for _,d in ipairs(TK.keyListData) do
        local key=d.bind()
        d.kl.Text=TK.bindName(key)
        if d.name~="Menu" and key==Enum.KeyCode.Unknown then
            d.row.Visible=false
        else
            d.row.Visible=true
            local active=d.state() or TK.isPressed(key)
            if active then
                d.row.BackgroundColor3=THEME.SidebarActive
                d.nl.TextColor3=THEME.Accent d.kl.TextColor3=THEME.Text
            else
                d.row.BackgroundColor3=THEME.Row
                d.nl.TextColor3=THEME.TextDim d.kl.TextColor3=THEME.TextDim
            end
        end
    end
end

-- UI BUILDERS
function TK.newCard(title,forcedSide)
    local side
    if forcedSide=="Left" then side=TK.leftCol
    elseif forcedSide=="Right" then side=TK.rightCol
    else
        if not TK._side or TK._side=="Right" then TK._side="Left" side=TK.leftCol
        else TK._side="Right" side=TK.rightCol end
    end
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,0) card.AutomaticSize=Enum.AutomaticSize.Y
    card.BackgroundColor3=THEME.Card card.BorderSizePixel=0 card.Parent=side
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
    Instance.new("UIStroke",card).Color=THEME.CardBorder
    local pad=Instance.new("UIPadding",card)
    pad.PaddingTop=UDim.new(0,10) pad.PaddingBottom=UDim.new(0,10)
    pad.PaddingLeft=UDim.new(0,10) pad.PaddingRight=UDim.new(0,10)
    local list=Instance.new("UIListLayout",card)
    list.Padding=UDim.new(0,6) list.SortOrder=Enum.SortOrder.LayoutOrder
    if title and title~="" then
        local t=Instance.new("TextLabel",card)
        t.Size=UDim2.new(1,0,0,22) t.BackgroundTransparency=1
        t.Text=title t.TextColor3=THEME.Text t.Font=Enum.Font.GothamBold
        t.TextSize=12 t.TextXAlignment=Enum.TextXAlignment.Left t.LayoutOrder=-1
    end
    return card
end

function TK.newRow(card,height)
    local row=Instance.new("TextButton",card)
    row.Size=UDim2.new(1,0,0,height or 34) row.BackgroundColor3=THEME.Row
    row.Text="" row.AutoButtonColor=false row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    row.MouseEnter:Connect(function() row.BackgroundColor3=THEME.RowHover end)
    row.MouseLeave:Connect(function() row.BackgroundColor3=THEME.Row end)
    return row
end

function TK.makeSwitch(row,default,cb)
    local sw=Instance.new("Frame",row)
    sw.Size=UDim2.new(0,34,0,18) sw.Position=UDim2.new(1,-44,0.5,-9)
    sw.BackgroundColor3=default and THEME.SwitchOn or THEME.SwitchOff
    sw.BorderSizePixel=0
    Instance.new("UICorner",sw).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",sw)
    knob.Size=UDim2.new(0,14,0,14) knob.Position=default and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    knob.BackgroundColor3=Color3.new(1,1,1) knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local state=default
    local function update(v,fire)
        state=v
        Tween:Create(sw,TweenInfo.new(0.12),{BackgroundColor3=v and THEME.SwitchOn or THEME.SwitchOff}):Play()
        Tween:Create(knob,TweenInfo.new(0.12),{Position=v and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)}):Play()
        if fire then pcall(cb,v) end
    end
    row.MouseButton1Click:Connect(function() update(not state,true) end)
    return {Set=function(v) update(v,false) end,Get=function() return state end}
end

function TK.makeSlider(parent,pos,size,min,max,default,cb)
    local holder=Instance.new("Frame",parent)
    holder.Size=size holder.Position=pos holder.BackgroundTransparency=1
    local track=Instance.new("Frame",holder)
    track.Size=UDim2.new(1,-44,0,4) track.Position=UDim2.new(0,0,0.5,-2)
    track.BackgroundColor3=THEME.ControlBg track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new((default-min)/(max-min),0,1,0) fill.BackgroundColor3=THEME.Accent
    fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local valueLbl=Instance.new("TextLabel",holder)
    valueLbl.Size=UDim2.new(0,38,1,0) valueLbl.Position=UDim2.new(1,-38,0,0)
    valueLbl.BackgroundTransparency=1 valueLbl.Text=tostring(default)
    valueLbl.TextColor3=THEME.Accent valueLbl.Font=Enum.Font.GothamBold
    valueLbl.TextSize=11 valueLbl.TextXAlignment=Enum.TextXAlignment.Right
    local val,dragging=default,false
    local function apply(input)
        local r=math.clamp((input.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        fill.Size=UDim2.new(r,0,1,0) val=math.floor(min+r*(max-min))
        valueLbl.Text=tostring(val)
        if cb then cb(val) end
    end
    track.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true apply(i) end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then apply(i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    return {Get=function() return val end}
end

function TK.refreshBindButton(name)
    local btn=TK.bindButtons[name]
    if btn then btn.Text=TK.bindName(TK.Binds[name]) btn.TextColor3=THEME.TextDim end
end
function TK.assignBind(name,newKey)
    for other,kv in pairs(TK.Binds) do
        if other~=name and kv==newKey and newKey~=Enum.KeyCode.Unknown then
            TK.Binds[other]=Enum.KeyCode.Unknown TK.refreshBindButton(other)
        end
    end
    TK.Binds[name]=newKey TK.refreshBindButton(name) TK.refreshKeyList()
end

function TK.addToggle(card,label,default,cb,keyName)
    local row=TK.newRow(card,34)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-70,1,0) lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=label lbl.TextColor3=THEME.Text
    lbl.Font=Enum.Font.Gotham lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local sw=TK.makeSwitch(row,default,cb)
    if keyName then TK.uiRefs[keyName]=sw end
    return sw
end

function TK.addToggleBind(card,label,default,cb,bindKey)
    local row=TK.newRow(card,34)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-170,1,0) lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=label lbl.TextColor3=THEME.Text
    lbl.Font=Enum.Font.Gotham lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
    local sw=TK.makeSwitch(row,default,cb)
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(0,70,0,22) btn.Position=UDim2.new(1,-118,0.5,-11)
    btn.BackgroundColor3=THEME.ControlBg btn.Text=TK.bindName(TK.Binds[bindKey])
    btn.TextColor3=THEME.TextDim btn.Font=Enum.Font.Gotham btn.TextSize=10
    btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    TK.bindButtons[bindKey]=btn
    btn.MouseButton1Click:Connect(function()
        btn.Text="..." btn.TextColor3=THEME.Accent
        TK.listeningBind=bindKey
    end)
    TK.uiRefs[bindKey]=sw
    return sw
end

function TK.addSlider(card,label,min,max,default,cb)
    local row=TK.newRow(card,34)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(0.4,0,1,0) lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=label lbl.TextColor3=THEME.Text
    lbl.Font=Enum.Font.Gotham lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
    TK.makeSlider(row,UDim2.new(1,-150,0.5,-8),UDim2.new(0,140,0,16),min,max,default,cb)
    return row
end

function TK.addButton(card,label,cb)
    local btn=Instance.new("TextButton",card)
    btn.Size=UDim2.new(1,0,0,32) btn.BackgroundColor3=THEME.Row
    btn.Text=label btn.TextColor3=THEME.Text btn.Font=Enum.Font.Gotham
    btn.TextSize=12 btn.BorderSizePixel=0 btn.AutoButtonColor=false
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,7)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3=THEME.RowHover end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3=THEME.Row end)
    btn.MouseButton1Click:Connect(function() pcall(cb) end)
    return btn
end

function TK.buildEspModeButtons(parent)
    TK.espModeContainer=Instance.new("Frame",parent)
    TK.espModeContainer.Size=UDim2.new(1,0,0,TK.EspOn and 30 or 0)
    TK.espModeContainer.BackgroundTransparency=1
    TK.espModeContainer.ClipsDescendants=true
    TK.espModeContainer.Visible=TK.EspOn
    local layout=Instance.new("UIListLayout",TK.espModeContainer)
    layout.FillDirection=Enum.FillDirection.Horizontal
    layout.Padding=UDim.new(0,6)
    local labels={"Mode 1","Soon 2","Soon 3"}
    for i,name in ipairs(labels) do
        local b=Instance.new("TextButton",TK.espModeContainer)
        b.Size=UDim2.new(0,84,1,0)
        b.BackgroundColor3=(i==TK.EspMode) and THEME.SidebarActive or THEME.Card
        b.Text=name
        b.TextColor3=(i==TK.EspMode) and THEME.Text or THEME.TextDim
        b.Font=Enum.Font.GothamBold b.TextSize=11 b.BorderSizePixel=0
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
        if i==1 then
            b.MouseButton1Click:Connect(function()
                TK.EspMode=1
                for j,other in ipairs(TK.espModeButtons) do
                    other.BackgroundColor3=(j==1) and THEME.SidebarActive or THEME.Card
                    other.TextColor3=(j==1) and THEME.Text or THEME.TextDim
                end
                TK.clearEsp()
            end)
        else
            b.MouseButton1Click:Connect(function()
                local orig=b.BackgroundColor3
                b.BackgroundColor3=Color3.fromRGB(200,60,60)
                task.delay(0.15,function() if b and b.Parent then b.BackgroundColor3=orig end end)
            end)
        end
        TK.espModeButtons[i]=b
    end
end

function TK.animateEspModes(show)
    local c=TK.espModeContainer
    if not c then return end
    if show then
        c.Visible=true
        Tween:Create(c,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,30)}):Play()
    else
        Tween:Create(c,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(1,0,0,0)}):Play()
        task.delay(0.25,function() if c and not TK.EspOn then c.Visible=false end end)
    end
end

function TK.buildFreecamSlider(parent)
    TK.freecamSliderContainer=Instance.new("Frame",parent)
    TK.freecamSliderContainer.Size=UDim2.new(1,0,0,TK.FreecamOn and 34 or 0)
    TK.freecamSliderContainer.BackgroundTransparency=1
    TK.freecamSliderContainer.ClipsDescendants=true
    TK.freecamSliderContainer.Visible=TK.FreecamOn
    local row=Instance.new("TextButton",TK.freecamSliderContainer)
    row.Size=UDim2.new(1,0,0,34) row.BackgroundColor3=THEME.Row
    row.Text="" row.AutoButtonColor=false row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(0.4,0,1,0) lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1 lbl.Text="Camera Speed" lbl.TextColor3=THEME.Text
    lbl.Font=Enum.Font.Gotham lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
    TK.makeSlider(row,UDim2.new(1,-150,0.5,-8),UDim2.new(0,140,0,16),10,200,TK.FreecamSpeed,function(v) TK.FreecamSpeed=v end)
end

function TK.animateFreecamSlider(show)
    local c=TK.freecamSliderContainer
    if not c then return end
    if show then
        c.Visible=true
        Tween:Create(c,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,34)}):Play()
    else
        Tween:Create(c,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(1,0,0,0)}):Play()
        task.delay(0.25,function() if c and not TK.FreecamOn then c.Visible=false end end)
    end
end

function TK.buildFullbrightSlider(parent)
    TK.fullbrightSliderContainer=Instance.new("Frame",parent)
    TK.fullbrightSliderContainer.Size=UDim2.new(1,0,0,TK.FullbrightOn and 34 or 0)
    TK.fullbrightSliderContainer.BackgroundTransparency=1
    TK.fullbrightSliderContainer.ClipsDescendants=true
    TK.fullbrightSliderContainer.Visible=TK.FullbrightOn
    local row=Instance.new("TextButton",TK.fullbrightSliderContainer)
    row.Size=UDim2.new(1,0,0,34) row.BackgroundColor3=THEME.Row
    row.Text="" row.AutoButtonColor=false row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(0.4,0,1,0) lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1 lbl.Text="Brightness" lbl.TextColor3=THEME.Text
    lbl.Font=Enum.Font.Gotham lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left
    TK.makeSlider(row,UDim2.new(1,-150,0.5,-8),UDim2.new(0,140,0,16),1,10,TK.FullbrightBrightness,function(v)
        TK.FullbrightBrightness=v
        if TK.FullbrightOn then pcall(function() TK.Lighting.Brightness=v end) end
    end)
end

function TK.animateFullbrightSlider(show)
    local c=TK.fullbrightSliderContainer
    if not c then return end
    if show then
        c.Visible=true
        Tween:Create(c,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,0,34)}):Play()
    else
        Tween:Create(c,TweenInfo.new(0.25,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(1,0,0,0)}):Play()
        task.delay(0.25,function() if c and not TK.FullbrightOn then c.Visible=false end end)
    end
end

-- CATEGORIES
TK.categories={
    {name="Movement",icon="M"},{name="Combat",icon="C"},
    {name="Visuals",icon="V"},{name="Misc",icon="X"},{name="Client",icon="S"},
}
local catButtons={}
TK.catButtons=catButtons
local catHolder=Instance.new("Frame",TK.sidebar)
catHolder.Size=UDim2.new(1,-16,1,-84) catHolder.Position=UDim2.new(0,8,0,72)
catHolder.BackgroundTransparency=1
Instance.new("UIListLayout",catHolder).Padding=UDim.new(0,4)
for i,cat in ipairs(TK.categories) do
    local btn=Instance.new("TextButton",catHolder)
    btn.Size=UDim2.new(1,0,0,34) btn.BackgroundColor3=THEME.SidebarBtn
    btn.Text="" btn.AutoButtonColor=false btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)
    local iconLbl=Instance.new("TextLabel",btn)
    iconLbl.Name="Icon" iconLbl.Size=UDim2.new(0,26,1,0) iconLbl.Position=UDim2.new(0,8,0,0)
    iconLbl.BackgroundTransparency=1 iconLbl.Text=cat.icon
    iconLbl.TextColor3=THEME.TextDim iconLbl.Font=Enum.Font.GothamBold iconLbl.TextSize=13
    local nameLbl=Instance.new("TextLabel",btn)
    nameLbl.Name="Label" nameLbl.Size=UDim2.new(1,-40,1,0) nameLbl.Position=UDim2.new(0,36,0,0)
    nameLbl.BackgroundTransparency=1 nameLbl.Text=cat.name
    nameLbl.TextColor3=THEME.TextDim nameLbl.Font=Enum.Font.Gotham
    nameLbl.TextSize=12 nameLbl.TextXAlignment=Enum.TextXAlignment.Left
    btn.MouseButton1Click:Connect(function() TK.setTab(i) end)
    btn.MouseEnter:Connect(function() if TK.currentTab~=i then btn.BackgroundColor3=THEME.SidebarBtnHi end end)
    btn.MouseLeave:Connect(function() if TK.currentTab~=i then btn.BackgroundColor3=THEME.SidebarBtn end end)
    catButtons[i]=btn
end
TK.loaders={}

function TK.setTab(idx)
    TK.currentTab=idx
    for i,b in ipairs(catButtons) do
        local iconLbl=b:FindFirstChild("Icon")
        local nameLbl=b:FindFirstChild("Label")
        if i==idx then
            b.BackgroundColor3=THEME.SidebarActive
            if iconLbl then iconLbl.TextColor3=THEME.Accent end
            if nameLbl then nameLbl.TextColor3=THEME.Text end
        else
            b.BackgroundColor3=THEME.SidebarBtn
            if iconLbl then iconLbl.TextColor3=THEME.TextDim end
            if nameLbl then nameLbl.TextColor3=THEME.TextDim end
        end
    end
    TK.pageTitle.Text=TK.categories[idx].name
    if TK.loaders[idx] then pcall(TK.loaders[idx]) end
end

function TK.applyTheme(name)
    if not TK.THEMES[name] then return end
    for k,v in pairs(TK.THEMES[name]) do THEME[k]=v end
    TK.main.BackgroundColor3=THEME.Bg TK.mainStroke.Color=THEME.Border
    TK.sidebar.BackgroundColor3=THEME.Sidebar TK.logoIcon.BackgroundColor3=THEME.Accent
    TK.logoTitle.TextColor3=THEME.Text TK.pageTitle.TextColor3=THEME.Text
    TK.gearBtn.BackgroundColor3=THEME.Card TK.gearBtn.ImageColor3=THEME.Text
    TK.closeBtn.BackgroundColor3=THEME.Card TK.closeBtn.TextColor3=THEME.TextDim
    TK.scroll.ScrollBarImageColor3=THEME.Accent
    TK.footer.BackgroundColor3=THEME.Card TK.footerStroke.Color=THEME.CardBorder
    TK.avatar.BackgroundColor3=THEME.ControlBg TK.nickLbl.TextColor3=THEME.Text
    TK.buildLbl.TextColor3=THEME.Accent TK.versionLbl.TextColor3=THEME.Accent
    TK.sushi.BackgroundColor3=THEME.Bg TK.sushi.TextColor3=THEME.Accent TK.sushiStroke.Color=THEME.Accent
    TK.keyFrame.BackgroundColor3=THEME.Bg
    TK.settingsPanel.BackgroundColor3=THEME.Bg TK.setStroke.Color=THEME.Border
    TK.setHeader.BackgroundColor3=THEME.Card TK.bigTitle.TextColor3=THEME.Accent
    TK.creditsLabel.TextColor3=THEME.Text TK.creditsLabel2.TextColor3=THEME.TextDim
    TK.themeLabel.TextColor3=THEME.Text
    for i,b in ipairs(TK.themeButtons) do
        if TK.themeOptions[i]==name then
            b.BackgroundColor3=THEME.SidebarActive b.TextColor3=THEME.Text
        else
            b.BackgroundColor3=THEME.Card b.TextColor3=THEME.TextDim
        end
    end
    if TK.wmFrame then
        TK.wmFrame.BackgroundColor3=THEME.Bg TK.wmStroke.Color=THEME.Border
        TK.wmAccent.BackgroundColor3=THEME.Accent TK.wmText.TextColor3=THEME.Text
    end
    TK.setTab(TK.currentTab) TK.refreshKeyList()
end

-- HELPERS
function TK.getChar() return TK.plr.Character end
function TK.getHRP() local c=TK.getChar() return c and c:FindFirstChild("HumanoidRootPart") or nil end
function TK.getHumanoid() local c=TK.getChar() return c and c:FindFirstChildOfClass("Humanoid") or nil end
function TK.bindMatches(bind,input)
    if typeof(bind)~="EnumItem" or bind==Enum.KeyCode.Unknown then return false end
    if bind.EnumType==Enum.KeyCode then return input.KeyCode==bind end
    if bind.EnumType==Enum.UserInputType then return input.UserInputType==bind end
    return false
end

print("[TK] PART 2 loaded")
