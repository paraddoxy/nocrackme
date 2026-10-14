local G = getgenv()
local TK = G.TK
if not TK then warn("[TK] PART 1/2 не загружены!") return end

local RunService = TK.RunService
local UIS = TK.UIS
local Lighting = TK.Lighting
local Tween = TK.Tween
local THEME = TK.THEME

-- NOCLIP
function TK.setNoClip(on)
    TK.NoClipOn = on
    local char = TK.getChar(); if not char then return end
    if on then
        TK.savedCollisions = {}
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                TK.savedCollisions[p] = {p.CanCollide, p.CanTouch, p.CanQuery}
                p.CanCollide=false p.CanTouch=false p.CanQuery=false
            end
        end
    else
        for p, s in pairs(TK.savedCollisions) do
            if p.Parent then p.CanCollide=s[1] p.CanTouch=s[2] p.CanQuery=s[3] end
        end
        TK.savedCollisions = {}
    end
end
function TK.updateNoClipActive()
    if not TK.NoClipOn then return end
    local char = TK.getChar(); if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if p.CanCollide then
                if not TK.savedCollisions[p] then TK.savedCollisions[p]={true,p.CanTouch,p.CanQuery} end
                p.CanCollide=false
            end
            if p.CanTouch then p.CanTouch=false end
            if p.CanQuery then p.CanQuery=false end
        end
    end
end

function TK.teleportToMouse()
    local hrp = TK.getHRP(); if not hrp then return end
    local hit = TK.mouse.Hit; if not hit then return end
    local target = hit.Position + Vector3.new(0,3,0)
    local wasNoclip = TK.NoClipOn
    if not wasNoclip then TK.setNoClip(true) end
    local startT = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if tick()-startT>0.25 then
            conn:Disconnect()
            if not wasNoclip then TK.setNoClip(false) end
            return
        end
        hrp.CFrame = CFrame.new(target)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end)
    if TK.FlyOn then TK.flyDesired = target end
end

function TK.setJumpEnabled(on)
    TK.JumpOn = on
    local hum = TK.getHumanoid(); if not hum then return end
    if on then
        pcall(function()
            hum.JumpPower=TK.JumpValue hum.JumpHeight=TK.JumpValue/7
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,true)
        end)
    else
        pcall(function()
            hum.JumpPower=0 hum.JumpHeight=0
            hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
        end)
    end
end
function TK.updateJumpState()
    local hum = TK.getHumanoid(); if not hum then return end
    if not TK.JumpOn then
        if hum.JumpPower ~= 0 then pcall(function() hum.JumpPower=0 end) end
        if hum.JumpHeight ~= 0 then pcall(function() hum.JumpHeight=0 end) end
        pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,false) end)
    else
        if hum.JumpPower ~= TK.JumpValue then pcall(function() hum.JumpPower=TK.JumpValue end) end
    end
end
function TK.doJump()
    if not TK.JumpOn then return end
    local hum, hrp = TK.getHumanoid(), TK.getHRP()
    if not hum or not hrp then return end
    if hum.FloorMaterial ~= Enum.Material.Air then
        pcall(function() hum.JumpPower=TK.JumpValue hum.JumpHeight=TK.JumpValue/7 end)
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, TK.JumpValue, hrp.AssemblyLinearVelocity.Z)
    end
end

function TK.setFly(on)
    TK.FlyOn = on
    local hrp = TK.getHRP()
    if on and hrp then TK.flyDesired = hrp.Position else TK.flyDesired = nil end
end
function TK.updateFly(dt)
    if not TK.FlyOn or not TK.flyDesired then return end
    local hrp = TK.getHRP(); if not hrp then return end
    if (hrp.Position - TK.flyDesired).Magnitude > 30 then TK.flyDesired = hrp.Position end
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + TK.cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - TK.cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - TK.cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + TK.cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end
    if dir.Magnitude > 0 then TK.flyDesired = TK.flyDesired + dir.Unit * TK.FlySpeed * dt end
    hrp.CFrame = CFrame.new(TK.flyDesired) * (hrp.CFrame - hrp.CFrame.Position)
    hrp.AssemblyLinearVelocity = Vector3.zero
end

function TK.setSpeed(on)
    TK.SpeedOn = on
    local hum = TK.getHumanoid(); if not hum then return end
    if on then
        if TK.baseWalk == nil then TK.baseWalk = 16 end
        hum.WalkSpeed = TK.SpeedValue
    else
        pcall(function() hum.WalkSpeed = TK.baseWalk or 16 end)
        TK.baseWalk = nil
    end
end
function TK.keepSpeed()
    if not TK.SpeedOn and not TK.EmoteRunOn then return end
    local hum = TK.getHumanoid(); if not hum then return end
    if TK.SpeedOn and hum.WalkSpeed ~= TK.SpeedValue then hum.WalkSpeed = TK.SpeedValue end
    if TK.EmoteRunOn and hum.WalkSpeed < 16 and hum.WalkSpeed > 0 then hum.WalkSpeed = 16 end
end

function TK.setFreecam(on)
    TK.FreecamOn = on
    if on then
        local hrp = TK.getHRP()
        if hrp then
            TK.freecamPos = hrp.Position + Vector3.new(0,5,0)
            local cf = TK.cam.CFrame
            TK.freecamRotY = math.atan2(cf.LookVector.X, cf.LookVector.Z)
            TK.freecamRotX = math.asin(math.clamp(cf.LookVector.Y,-1,1))
            TK.freecamSavedPosition = hrp.CFrame
        end
        TK.cam.CameraType = Enum.CameraType.Scriptable
        TK.cam.CameraSubject = nil
    else
        TK.cam.CameraType = Enum.CameraType.Custom
        local hum = TK.getHumanoid(); if hum then TK.cam.CameraSubject = hum end
        UIS.MouseBehavior = Enum.MouseBehavior.Default
        TK.freecamSavedPosition = nil
    end
end
function TK.updateFreecam(dt)
    if not TK.FreecamOn then return end
    if TK.cam.CameraType ~= Enum.CameraType.Scriptable then
        TK.cam.CameraType = Enum.CameraType.Scriptable
        TK.cam.CameraSubject = nil
    end
    UIS.MouseBehavior = TK.menuOpen and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
    local hrp = TK.getHRP()
    if hrp and TK.freecamSavedPosition then
        hrp.CFrame = TK.freecamSavedPosition
        hrp.AssemblyLinearVelocity = Vector3.zero
    end
    local mv = Vector3.zero
    local lv, rv = TK.cam.CFrame.LookVector, TK.cam.CFrame.RightVector
    if UIS:IsKeyDown(Enum.KeyCode.W) then mv = mv + lv end
    if UIS:IsKeyDown(Enum.KeyCode.S) then mv = mv - lv end
    if UIS:IsKeyDown(Enum.KeyCode.A) then mv = mv - rv end
    if UIS:IsKeyDown(Enum.KeyCode.D) then mv = mv + rv end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv - Vector3.yAxis end
    if mv.Magnitude > 0 then TK.freecamPos = TK.freecamPos + mv.Unit * TK.FreecamSpeed * dt end
    if not TK.menuOpen then
        local d = UIS:GetMouseDelta()
        TK.freecamRotY = TK.freecamRotY + d.X * 0.004
        TK.freecamRotX = math.clamp(TK.freecamRotX - d.Y * 0.004, -math.rad(89), math.rad(89))
    end
    TK.cam.CFrame = CFrame.new(TK.freecamPos) * CFrame.Angles(TK.freecamRotX, TK.freecamRotY, 0)
end

function TK.setFullbright(on)
    TK.FullbrightOn = on
    if on then
        TK.fbOriginal = {}
        for p in pairs(TK.fbProps) do TK.fbOriginal[p] = Lighting[p] end
        for p, v in pairs(TK.fbProps) do pcall(function() Lighting[p] = v end) end
        pcall(function() Lighting.Brightness = TK.FullbrightBrightness end)
    else
        if TK.fbOriginal then
            for p, v in pairs(TK.fbOriginal) do pcall(function() Lighting[p] = v end) end
            TK.fbOriginal = nil
        end
    end
end
function TK.setFpsBoost(on)
    TK.FpsBoostOn = on
    if on then
        TK.fpsBoostSaved = {materials={}, globalShadows=Lighting.GlobalShadows, fogEnd=Lighting.FogEnd}
        for _, v in ipairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v.Material ~= Enum.Material.SmoothPlastic then
                TK.fpsBoostSaved.materials[v] = v.Material
                v.Material = Enum.Material.SmoothPlastic
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
    else
        if TK.fpsBoostSaved then
            for part, mat in pairs(TK.fpsBoostSaved.materials) do
                if part.Parent then pcall(function() part.Material = mat end) end
            end
            pcall(function() Lighting.GlobalShadows = TK.fpsBoostSaved.globalShadows end)
            pcall(function() Lighting.FogEnd = TK.fpsBoostSaved.fogEnd end)
            TK.fpsBoostSaved = nil
        end
    end
end

-- HUNTER
TK.HUNTER_KEYWORDS = {"hunter","killer","murderer","monster","slasher","chaser","jason","michael","ghost","demon"}
TK.WEAPON_KEYWORDS = {"knife","axe","machete","sword","sickle","scythe","weapon","blade","cleaver","hammer"}
function TK.hasWeapon(container)
    if not container then return false end
    for _, t in ipairs(container:GetChildren()) do
        if t:IsA("Tool") then
            local tn = t.Name:lower()
            for _, kw in ipairs(TK.WEAPON_KEYWORDS) do if tn:find(kw) then return true end end
        end
    end
    return false
end
function TK.isHunter(p)
    if p.Team then
        local tn = p.Team.Name:lower()
        for _, kw in ipairs(TK.HUNTER_KEYWORDS) do if tn:find(kw) then return true end end
    end
    for _, attr in ipairs({"Role","role","Hunter","Killer","IsKiller","IsHunter"}) do
        local v = p:GetAttribute(attr)
        if type(v) == "string" then
            local lv = v:lower()
            for _, kw in ipairs(TK.HUNTER_KEYWORDS) do if lv:find(kw) then return true end end
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
                for _, kw in ipairs(TK.HUNTER_KEYWORDS) do if lv:find(kw) then return true end end
            end
        end
        if TK.hasWeapon(char) then return true end
    end
    if TK.hasWeapon(p:FindFirstChild("Backpack")) then return true end
    return false
end
function TK.getNearestKiller(maxRange)
    local hrp = TK.getHRP(); if not hrp then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, p in ipairs(TK.Players:GetPlayers()) do
        if p ~= TK.plr and p.Character and TK.isHunter(p) then
            local phrp = p.Character:FindFirstChild("HumanoidRootPart")
            local phum = p.Character:FindFirstChildOfClass("Humanoid")
            if phrp and phum and phum.Health > 0 then
                local d = (phrp.Position - hrp.Position).Magnitude
                if d < nearestDist and d <= maxRange then nearestDist = d nearest = p end
            end
        end
    end
    return nearest
end

function TK.updateTriggerBot()
    if not TK.TriggerBotOn then return end
    local char = TK.getChar(); if not char then return end
    local killer = TK.getNearestKiller(TK.TriggerRange); if not killer then return end
    local tool = char:FindFirstChildOfClass("Tool"); if not tool then return end
    local now = tick()
    if now - TK.triggerLastAttack < 0.08 then return end
    TK.triggerLastAttack = now
    pcall(function() tool:Activate() end)
end

TK.BOMB_KEYWORDS = {"water","bomb","bottle","grenade","flash","smoke"}
function TK.findBombTool()
    local char = TK.getChar(); if not char then return nil end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local n = t.Name:lower()
            for _, kw in ipairs(TK.BOMB_KEYWORDS) do if n:find(kw) then return t end end
        end
    end
    local bp = TK.plr:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                for _, kw in ipairs(TK.BOMB_KEYWORDS) do if n:find(kw) then return t end end
            end
        end
    end
    return nil
end
TK.lastBombThrow = 0
function TK.updateAutoThrow()
    if not TK.AutoThrowOn then return end
    local char = TK.getChar(); if not char then return end
    local killer = TK.getNearestKiller(TK.TriggerRange + 8); if not killer then return end
    local bomb = TK.findBombTool(); if not bomb then return end
    local now = tick()
    if now - TK.lastBombThrow < 0.5 then return end
    TK.lastBombThrow = now
    if bomb.Parent ~= char then pcall(function() bomb.Parent = char end) end
    task.wait(0.05)
    pcall(function() bomb:Activate() end)
end

TK.FLASH_KEYWORDS = {"flash","blind","stun","white","fade","shake"}
function TK.cleanFlashObject(obj)
    if not obj or not TK.AntiFlashOn then return end
    local n = (obj.Name or ""):lower()
    for _, kw in ipairs(TK.FLASH_KEYWORDS) do
        if n:find(kw) then
            pcall(function()
                if obj:IsA("Frame") then obj.BackgroundTransparency=1 end
                if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then obj.ImageTransparency=1 end
                if obj:IsA("TextLabel") then obj.TextTransparency=1 end
            end)
            return
        end
    end
end
function TK.setAntiFlash(on)
    TK.AntiFlashOn = on
    if on then
        for _, conn in ipairs(TK.antiFlashConnections) do pcall(function() conn:Disconnect() end) end
        TK.antiFlashConnections = {}
        local pg = TK.plr:FindFirstChild("PlayerGui")
        if pg then
            local c = pg.ChildAdded:Connect(function(child)
                if not TK.AntiFlashOn then return end
                task.defer(function() TK.cleanFlashObject(child) end)
            end)
            table.insert(TK.antiFlashConnections, c)
            for _, d in ipairs(pg:GetChildren()) do TK.cleanFlashObject(d) end
        end
    else
        for _, conn in ipairs(TK.antiFlashConnections) do pcall(function() conn:Disconnect() end) end
        TK.antiFlashConnections = {}
    end
end

function TK.setEmoteRun(on)
    TK.EmoteRunOn = on
    if TK.emoteAnimConn then TK.emoteAnimConn:Disconnect() TK.emoteAnimConn=nil end
    if TK.emoteConn then TK.emoteConn:Disconnect() TK.emoteConn=nil end
    if on then
        local char = TK.getChar()
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    TK.emoteAnimConn = animator.AnimationPlayed:Connect(function(track)
                        if not TK.EmoteRunOn then return end
                        local aid = track.Animation and track.Animation.AnimationId
                        if aid then TK.savedEmoteId = aid end
                        pcall(function() track.Priority = Enum.AnimationPriority.Action4 end)
                    end)
                end
            end
        end
        TK.emoteConn = RunService.Heartbeat:Connect(function()
            if not TK.EmoteRunOn then return end
            local c = TK.getChar(); if not c then return end
            local h = c:FindFirstChildOfClass("Humanoid"); if not h then return end
            if h.WalkSpeed < 16 and h.WalkSpeed > 0 then h.WalkSpeed = 16 end
        end)
    end
end

-- ESP
function TK.clearEspPlayer(p)
    local d = TK.espData[p]; if not d then return end
    pcall(function()
        if d.hl then d.hl:Destroy() end
        if d.bb then d.bb:Destroy() end
    end)
    TK.espData[p] = nil
end
function TK.clearEsp()
    for p, _ in pairs(TK.espData) do TK.clearEspPlayer(p) end
    TK.espData = {}
end
function TK.updateEspMode1()
    local myHRP = TK.getHRP()
    for _, p in ipairs(TK.Players:GetPlayers()) do
        if p ~= TK.plr and p.Character then
            local char = p.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and hrp then
                local d = TK.espData[p]
                if not d then d = {char=char} TK.espData[p] = d end
                local col = TK.isHunter(p) and TK.HUNTER_COLOR or Color3.fromRGB(255,255,255)
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
                    d.bb.Size = UDim2.new(0,140,0,24)
                    d.bb.StudsOffset = Vector3.new(0,3,0)
                    d.bb.AlwaysOnTop = true
                    d.bb.Adornee = hrp
                    d.bb.Parent = char
                    d.tl = Instance.new("TextLabel", d.bb)
                    d.tl.Size = UDim2.new(1,0,1,0)
                    d.tl.BackgroundTransparency = 1
                    d.tl.Font = Enum.Font.Gotham
                    d.tl.TextSize = 12
                    d.tl.TextStrokeTransparency = 0.2
                end
                d.bb.Adornee = hrp
                d.tl.TextColor3 = col
                local distText = myHRP and (" ["..math.floor((myHRP.Position-hrp.Position).Magnitude).."m]") or ""
                d.tl.Text = p.Name .. distText .. (TK.isHunter(p) and " [HUNTER]" or "")
            elseif TK.espData[p] then
                TK.clearEspPlayer(p)
            end
        end
    end
end
function TK.updateEsp()
    if not TK.EspOn then return end
    TK.updateEspMode1()
end

function TK.updateAntiVoid()
    local hrp, hum = TK.getHRP(), TK.getHumanoid()
    if not hrp then return end
    if hum and hum.FloorMaterial ~= Enum.Material.Air then
        TK.voidSnapshot = hrp.Position
        return
    end
    if TK.voidSnapshot and hrp.AssemblyLinearVelocity.Y < -40 then
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {TK.plr.Character}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local hit = workspace:Raycast(hrp.Position, Vector3.new(0,-200,0), rp)
        if not hit then
            hrp.CFrame = CFrame.new(TK.voidSnapshot + Vector3.new(0,3,0))
            hrp.AssemblyLinearVelocity = Vector3.zero
            if TK.FlyOn then TK.flyDesired = hrp.Position end
        end
    end
end

function TK.unloadScript()
    TK.UNLOADED = true
    pcall(function() if TK.FlyOn then TK.setFly(false) end end)
    pcall(function() if TK.NoClipOn then TK.setNoClip(false) end end)
    pcall(function() if TK.SpeedOn then TK.setSpeed(false) end end)
    pcall(function() if TK.FreecamOn then TK.setFreecam(false) end end)
    pcall(function() if TK.FullbrightOn then TK.setFullbright(false) end end)
    pcall(function() if TK.FpsBoostOn then TK.setFpsBoost(false) end end)
    pcall(function() if TK.AntiFlashOn then TK.setAntiFlash(false) end end)
    pcall(function() TK.clearEsp() end)
    pcall(function() UIS.MouseBehavior = Enum.MouseBehavior.Default end)
    pcall(function() TK.gui:Destroy() end)
    pcall(function() TK.keyGui:Destroy() end)
    pcall(function() TK.sushiGui:Destroy() end)
    pcall(function() TK.wmGui:Destroy() end)
end
TK.unloadBtn.MouseButton1Click:Connect(TK.unloadScript)

function TK.clearAll()
    for _, c in ipairs(TK.leftCol:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _, c in ipairs(TK.rightCol:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    TK._side = nil
    TK.espModeButtons = {}
    TK.espModeContainer = nil
    TK.freecamSliderContainer = nil
    TK.fullbrightSliderContainer = nil
end

-- TAB LOADERS
function TK.loadMovement()
    TK.clearAll()
    local fly = TK.newCard("Fly","Left")
    TK.addToggleBind(fly,"Fly",TK.FlyOn,function(s)
        TK.setFly(s); if TK.uiRefs.Fly then TK.uiRefs.Fly.Set(s) end
    end,"Fly")
    TK.addSlider(fly,"Fly Speed",10,200,TK.FlySpeed,function(v) TK.FlySpeed=v end)

    local move = TK.newCard("Movement","Right")
    TK.addToggle(move,"Jump Enabled",TK.JumpOn,function(s) TK.setJumpEnabled(s) end,"Jump")
    TK.addSlider(move,"Jump Power",20,150,TK.JumpValue,function(v)
        TK.JumpValue=v
        if TK.JumpOn then local hum=TK.getHumanoid() if hum then hum.JumpPower=v hum.JumpHeight=v/7 end end
    end)
    TK.addSlider(move,"Walk Speed",16,60,TK.SpeedValue,function(v)
        TK.SpeedValue=v
        if TK.SpeedOn then local hum=TK.getHumanoid() if hum then hum.WalkSpeed=v end end
    end)
    TK.addToggle(move,"Speed Enabled",TK.SpeedOn,function(s) TK.setSpeed(s) end,"Speed")

    local nc = TK.newCard("Noclip","Left")
    TK.addToggleBind(nc,"Noclip",TK.NoClipOn,function(s)
        TK.setNoClip(s); if TK.uiRefs.NoClip then TK.uiRefs.NoClip.Set(s) end
    end,"NoClip")

    local tp = TK.newCard("Teleport","Right")
    TK.addToggleBind(tp,"Click TP",TK.TPOn,function(s)
        TK.TPOn=s; if TK.uiRefs.TP then TK.uiRefs.TP.Set(s) end
    end,"TP")
end

function TK.loadCombat()
    TK.clearAll()
    local tb = TK.newCard("Trigger Bot","Left")
    TK.addToggle(tb,"Trigger Bot",TK.TriggerBotOn,function(s) TK.TriggerBotOn=s end,"TriggerBot")
    TK.addSlider(tb,"Range",5,30,TK.TriggerRange,function(v) TK.TriggerRange=v end)
    local tb2 = TK.newCard("Auto Throw","Right")
    TK.addToggle(tb2,"Auto Throw Bomb",TK.AutoThrowOn,function(s) TK.AutoThrowOn=s end,"AutoThrow")
    local af = TK.newCard("Anti Flash","Left")
    TK.addToggle(af,"Anti Flash",TK.AntiFlashOn,function(s) TK.setAntiFlash(s) end,"AntiFlash")
    local w = TK.newCard("Weapon","Right")
    TK.addToggle(w,"TP Kill",TK.TPKillOn,function(s) TK.TPKillOn=s end)
end

function TK.loadVisuals()
    TK.clearAll()
    local esp = TK.newCard("ESP","Left")
    TK.addToggle(esp,"Player ESP",TK.EspOn,function(s)
        TK.EspOn=s
        if not s then TK.clearEsp() end
        TK.animateEspModes(s)
    end,"Esp")
    TK.buildEspModeButtons(esp)

    local camCard = TK.newCard("Camera","Right")
    TK.addToggleBind(camCard,"Freecam",TK.FreecamOn,function(s)
        TK.setFreecam(s); TK.animateFreecamSlider(s)
    end,"Freecam")
    task.defer(function()
        TK.buildFreecamSlider(camCard)
        if TK.FreecamOn then TK.animateFreecamSlider(true) end
    end)

    local fb = TK.newCard("Lighting","Left")
    TK.addToggleBind(fb,"Fullbright",TK.FullbrightOn,function(s)
        TK.setFullbright(s); if TK.uiRefs.Fullbright then TK.uiRefs.Fullbright.Set(s) end
        TK.animateFullbrightSlider(s)
    end,"Fullbright")
    task.defer(function()
        TK.buildFullbrightSlider(fb)
        if TK.FullbrightOn then TK.animateFullbrightSlider(true) end
    end)
end

function TK.loadMisc()
    TK.clearAll()
    local em = TK.newCard("Emote","Left")
    TK.addToggle(em,"Emote While Running",TK.EmoteRunOn,function(s) TK.setEmoteRun(s) end,"EmoteRun")
    local mob = TK.newCard("Mobile Button","Right")
    TK.addToggle(mob,"Show Round Button",TK.SushiVisible,function(s)
        TK.SushiVisible=s TK.sushi.Visible=s
    end,"SushiBtn")
    local kbCard = TK.newCard("Keybind List","Right")
    TK.addToggle(kbCard,"Show Binds",TK.KeyListOn,function(s)
        TK.KeyListOn=s TK.keyFrame.Visible=s
    end,"KeyList")
end

function TK.loadClient()
    TK.clearAll()
    local c = TK.newCard("Client","Left")
    TK.addButton(c,"Rejoin",function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, TK.plr)
    end)
    TK.addToggle(c,"FPS Boost",TK.FpsBoostOn,function(s)
        TK.setFpsBoost(s); if TK.uiRefs.FpsBoost then TK.uiRefs.FpsBoost.Set(s) end
    end,"FpsBoost")
end

TK.loaders = {TK.loadMovement, TK.loadCombat, TK.loadVisuals, TK.loadMisc, TK.loadClient}

-- DRAG
local dragging, dragStart, startPos = false, nil, nil
TK.logo.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging=true dragStart=i.Position startPos=TK.main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        TK.main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+(i.Position-dragStart).X, startPos.Y.Scale, startPos.Y.Offset+(i.Position-dragStart).Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
end)

local sDrag, sMoved, sStart, sPos = false, 0, nil, nil
TK.sushi.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        sDrag=true sMoved=0 sStart=i.Position sPos=TK.sushi.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if sDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - sStart
        sMoved = sMoved + math.abs(d.X) + math.abs(d.Y)
        TK.sushi.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset+d.X, sPos.Y.Scale, sPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 and sDrag then
        sDrag = false
        if sMoved < 6 then TK.menuOpen = not TK.menuOpen TK.main.Visible = TK.menuOpen end
    end
end)

-- INPUT
UIS.JumpRequest:Connect(function()
    if TK.JumpOn and not TK.FlyOn and not TK.FreecamOn then TK.doJump() end
end)

UIS.InputBegan:Connect(function(input, gp)
    if TK.UNLOADED then return end
    if TK.listeningBind then
        if input.KeyCode == Enum.KeyCode.Escape then
            TK.assignBind(TK.listeningBind, Enum.KeyCode.Unknown)
            TK.listeningBind = nil
            return
        end
        local nb
        if input.KeyCode ~= Enum.KeyCode.Unknown then nb = input.KeyCode
        elseif input.UserInputType.Name:match("MouseButton") then nb = input.UserInputType end
        if nb then TK.assignBind(TK.listeningBind, nb) TK.listeningBind = nil end
        return
    end
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        TK.menuOpen = not TK.menuOpen
        TK.main.Visible = TK.menuOpen
        return
    end
    if TK.bindMatches(TK.Binds.Fly, input) then
        TK.FlyOn = not TK.FlyOn TK.setFly(TK.FlyOn)
        if TK.uiRefs.Fly then TK.uiRefs.Fly.Set(TK.FlyOn) end
    elseif TK.bindMatches(TK.Binds.NoClip, input) then
        TK.NoClipOn = not TK.NoClipOn TK.setNoClip(TK.NoClipOn)
        if TK.uiRefs.NoClip then TK.uiRefs.NoClip.Set(TK.NoClipOn) end
    elseif TK.bindMatches(TK.Binds.TP, input) then
        if TK.TPOn then TK.teleportToMouse() end
    elseif TK.bindMatches(TK.Binds.Fullbright, input) then
        TK.FullbrightOn = not TK.FullbrightOn TK.setFullbright(TK.FullbrightOn)
        if TK.uiRefs.Fullbright then TK.uiRefs.Fullbright.Set(TK.FullbrightOn) end
        TK.animateFullbrightSlider(TK.FullbrightOn)
    elseif TK.bindMatches(TK.Binds.Freecam, input) then
        TK.FreecamOn = not TK.FreecamOn TK.setFreecam(TK.FreecamOn)
        TK.animateFreecamSlider(TK.FreecamOn)
        if TK.uiRefs.Freecam then TK.uiRefs.Freecam.Set(TK.FreecamOn) end
    end
end)

TK.plr.CharacterAdded:Connect(function(char)
    if TK.UNLOADED then return end
    task.wait(0.5)
    TK.flyDesired = nil TK.baseWalk = nil TK.voidSnapshot = nil
    TK.savedCollisions = {} TK.freecamSavedPosition = nil TK.savedEmoteId = nil
    TK.clearEsp()
    task.wait(0.3)
    if TK.NoClipOn then TK.NoClipOn = false if TK.uiRefs.NoClip then TK.uiRefs.NoClip.Set(false) end end
    if TK.FreecamOn then
        TK.FreecamOn = false TK.setFreecam(false) TK.animateFreecamSlider(false)
        if TK.uiRefs.Freecam then TK.uiRefs.Freecam.Set(false) end
    end
    if not TK.JumpOn then
        task.wait(0.2)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.JumpPower=0 hum.JumpHeight=0
                hum:SetStateEnabled(Enum.HumanoidStateType.Jumping,false)
            end)
        end
    end
end)

-- MAIN LOOP
local heartbeatAcc = 0
RunService.Heartbeat:Connect(function(dt)
    if TK.UNLOADED then return end
    if TK.FreecamOn then TK.updateFreecam(dt) else TK.updateFly(dt) end
    if TK.NoClipOn then TK.updateNoClipActive() end
    if TK.SpeedOn or TK.EmoteRunOn then TK.keepSpeed() end
    TK.updateJumpState()
    if not TK.FreecamOn then TK.updateAntiVoid() end
    if TK.TriggerBotOn then TK.updateTriggerBot() end
    if TK.AutoThrowOn then TK.updateAutoThrow() end

    heartbeatAcc = heartbeatAcc + dt
    if heartbeatAcc >= 0.1 then
        heartbeatAcc = 0
        if TK.KeyListOn then TK.refreshKeyList() end
        if TK.EspOn then TK.updateEsp() end
    end
end)

TK.setTab(1)
TK.refreshKeyList()

-- INIT NOTIFY
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Tolkahack " .. TK.VERSION,
        Text = "Загружено! RightShift = меню",
        Duration = 5,
    })
end)

print("[TK] PART 3 loaded — все читы активны")
