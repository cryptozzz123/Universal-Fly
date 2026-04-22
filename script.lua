-- ═══════════════════════════════════════════════════════════════════════
--  🌸  LUNA ADMIN  V3  "Reimagined"
--  Milk-Style Dashboard UI  ·  Fixed Fling  ·  Drawing ESP  ·  NDS Tools
--  Re-execute safe  ·  Draggable  ·  Loading Screen  ·  Trusted Executor
-- ═══════════════════════════════════════════════════════════════════════

-- ─────────────────────────────── [1] CLEANUP ────────────────────────────
pcall(function()
    for _, p in ipairs({game:GetService("CoreGui"), game:GetService("Players").LocalPlayer.PlayerGui}) do
        for _, v in ipairs(p:GetChildren()) do
            if v.Name == "LunaAdmin" or v.Name == "LunaLoading" then v:Destroy() end
        end
    end
end)

-- ─────────────────────────────── [2] SERVICES ───────────────────────────
local Players  = game:GetService("Players")
local RunSvc   = game:GetService("RunService")
local UIS      = game:GetService("UserInputService")
local TwnSvc   = game:GetService("TweenService")
local CoreGui  = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local TxtSvc   = game:GetService("TextService")
local LP       = Players.LocalPlayer
local Cam      = workspace.CurrentCamera
if not LP.Character then LP.CharacterAdded:Wait() end

-- ─────────────────────────────── [3] CLIPBOARD ──────────────────────────
local function CopyClipboard(txt)
    pcall(function() setclipboard(txt) end)
    pcall(function() Clipboard.set(txt) end)
    pcall(function() game:GetService("GuiService"):SetClipboard(txt) end)
end

-- ─────────────────────────────── [4] DRAWING CHECK ──────────────────────
local DrawOK = false; local DFont = 0
pcall(function() local t = Drawing.new("Text"); t:Remove(); DrawOK = true end)
pcall(function() DFont = Drawing.Fonts.UI end)

-- ─────────────────────────────── [5] NDS CHECK ──────────────────────────
local IS_NDS = (game.PlaceId == 189707)

-- ─────────────────────────────── [6] COLOURS ────────────────────────────
-- Milk-inspired dark theme
local C = {
    win      = Color3.fromRGB(17, 17, 19),
    side     = Color3.fromRGB(20, 20, 23),
    topbar   = Color3.fromRGB(22, 22, 26),
    content  = Color3.fromRGB(17, 17, 19),
    card     = Color3.fromRGB(26, 26, 30),
    cardHov  = Color3.fromRGB(32, 32, 37),
    navAct   = Color3.fromRGB(33, 33, 38),
    border   = Color3.fromRGB(38, 38, 44),
    sep      = Color3.fromRGB(32, 32, 37),
    tPri     = Color3.fromRGB(238, 238, 240),
    tSec     = Color3.fromRGB(155, 155, 162),
    tDim     = Color3.fromRGB(95,  95, 102),
    togOn    = Color3.fromRGB(90, 140, 255),
    togOff   = Color3.fromRGB(50,  50,  57),
    togKnob  = Color3.fromRGB(230, 230, 232),
    discord  = Color3.fromRGB(50,  90, 200),
    discordL = Color3.fromRGB(80, 120, 240),
    ok       = Color3.fromRGB(72, 200, 118),
    err      = Color3.fromRGB(210,  60,  60),
    warn     = Color3.fromRGB(220, 165,  45),
    orange   = Color3.fromRGB(240, 120,  40),
    gold     = Color3.fromRGB(245, 200,  80),
    pink     = Color3.fromRGB(255, 140, 190),
    sky      = Color3.fromRGB(110, 185, 255),
    purple   = Color3.fromRGB(120,  70, 230),
}

-- ─────────────────────────────── [7] STATE ──────────────────────────────
local state = {
    godOn     = false,
    noclipOn  = false,
    flyOn     = false,
    infJump   = false,
    selfSpin  = false,
    invisOn   = false,
    espOn     = false,
    tracerOn  = false,
    chamOn    = false,
    showHP    = false,
    showDist  = false,
    fovOn     = false,
    xhairOn   = false,
    fullbrite = false,
    ndsAuto   = false,
    spdVal    = 16,
    jmpVal    = 50,
}
local flyBV, flyBG, spinBAV = nil, nil, nil
local flingBusy = false
local fps_cur   = 60

-- ─────────────────────────────── [8] HELPERS ────────────────────────────
local function corner(p, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = p; return c end
local function stroke(p, col, t) local s = Instance.new("UIStroke"); s.Color = col or C.border; s.Thickness = t or 1; s.Parent = p; return s end
local function pad(p, t, b, l, r) local x = Instance.new("UIPadding"); x.PaddingTop = UDim.new(0,t or 0); x.PaddingBottom = UDim.new(0,b or 0); x.PaddingLeft = UDim.new(0,l or 0); x.PaddingRight = UDim.new(0,r or 0); x.Parent = p end
local function listL(p, dir, gap) local l = Instance.new("UIListLayout"); l.FillDirection = dir or Enum.FillDirection.Vertical; l.Padding = UDim.new(0, gap or 0); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Parent = p; return l end
local function tw(o, t, props) TwnSvc:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play() end
local function twS(o, t, props) TwnSvc:Create(o, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play() end

local function GetChar(p) return p and p.Character end
local function GetRoot(p) local c = GetChar(p); return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum(p)  local c = GetChar(p); return c and c:FindFirstChildOfClass("Humanoid") end
local function FindPlayer(q)
    if not q or q == "" then return nil end
    local lo = q:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(lo,1,true) or p.DisplayName:lower():find(lo,1,true) then return p end
    end
end
local function GetPing()
    local ok, v = pcall(function() return math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    return ok and (v.."ms") or "N/A"
end
local function GetGreeting()
    local h = tonumber(os.date("%H")) or 12
    return h < 12 and "Good Morning!" or h < 18 and "Good Afternoon!" or "Good Evening!"
end

-- ─────────────────────────────── [9] ESP DATA ───────────────────────────
local ESPData = {}
local ChamData = {}
local function ESPCol(p)
    return Color3.fromHSV(((p.UserId or 1) % 600) / 600, 0.9, 1)
end
local function NewDraw(kind, props)
    if not DrawOK then return {Visible=false, Remove=function() end} end
    local d = Drawing.new(kind)
    for k,v in pairs(props) do pcall(function() d[k] = v end) end
    return d
end
local function InitESP(p)
    if p == LP or ESPData[p] then return end
    local col = ESPCol(p)
    ESPData[p] = {
        box    = NewDraw("Square",{Visible=false, Color=col,   Thickness=1.4, Filled=false}),
        name   = NewDraw("Text",  {Visible=false, Color=col,   Size=13, Font=DFont, Outline=true, Text=p.Name, Center=true}),
        hp     = NewDraw("Text",  {Visible=false, Color=C.ok,  Size=11, Font=DFont, Outline=true, Center=true}),
        hbBg   = NewDraw("Square",{Visible=false, Color=Color3.fromRGB(25,25,25), Thickness=0, Filled=true}),
        hbFill = NewDraw("Square",{Visible=false, Color=C.ok,  Thickness=0, Filled=true}),
        tracer = NewDraw("Line",  {Visible=false, Color=col,   Thickness=1.2, Transparency=0.4}),
    }
end
local function KillESP(p)
    if ESPData[p] then for _,d in pairs(ESPData[p]) do pcall(function() d:Remove() end) end; ESPData[p]=nil end
end
local function HideESP(d) for _,v in pairs(d) do pcall(function() v.Visible=false end) end end
local function KillAllChams() for p,v in pairs(ChamData) do pcall(function() v:Destroy() end); ChamData[p]=nil end end

-- ───────────────────────── [10] FLING (IY STYLE) ────────────────────────
-- Pure angular velocity + proximity loop — NO BodyVelocity on self (prevents self-death)
local function FlingOne(victim)
    if flingBusy then return end
    flingBusy = true
    local myRoot = GetRoot(LP)
    if not myRoot then flingBusy = false; return end
    local savedCF  = myRoot.CFrame
    local savedGod = state.godOn
    -- Force temp god
    state.godOn = true
    local h = GetHum(LP)
    if h then h.MaxHealth = math.huge; h.Health = math.huge end
    -- Spin
    local bav = Instance.new("BodyAngularVelocity")
    bav.MaxTorque       = Vector3.new(0, math.huge, 0)
    bav.AngularVelocity = Vector3.new(0, 999999, 0)
    bav.P               = math.huge
    bav.Parent          = myRoot
    -- Proximity loop: stay beside victim while spinning → collision physics flings them
    for i = 1, 14 do
        local tr = GetRoot(victim)
        if not tr then break end
        pcall(function() myRoot.CFrame = tr.CFrame * CFrame.new(2.5, 0, 0) end)
        task.wait(0.055)
    end
    pcall(function() bav:Destroy() end)
    task.wait(0.05)
    pcall(function() myRoot.CFrame = savedCF end)
    -- Restore god state
    state.godOn = savedGod
    if not savedGod then
        local hh = GetHum(LP)
        if hh then hh.MaxHealth = 100; hh.Health = math.min(100, hh.Health) end
    end
    task.wait(0.5)
    flingBusy = false
end

local function FlingAll()
    local targets = {}
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then table.insert(targets, p) end end
    if #targets == 0 then return end
    for _, p in ipairs(targets) do task.spawn(FlingOne, p); task.wait(0.18) end
end

-- ───────────────────────── [11] NDS DISASTER DETECTION ──────────────────
local function GetDisaster()
    local rs = game:GetService("ReplicatedStorage")
    local ws = workspace
    -- Exact known NDS StringValue paths
    local paths = {
        {rs, "Disaster"}, {rs, "CurrentDisaster"}, {rs, "SelectedDisaster"},
        {ws, "Disaster"}, {ws, "CurrentDisaster"},
    }
    for _, pair in ipairs(paths) do
        pcall(function()
            local v = pair[1]:FindFirstChild(pair[2])
            if v and v:IsA("StringValue") and v.Value ~= "" then
                error(v.Value) -- use error as early return
            end
        end)
    end
    -- Search MapData / GameData containers
    for _, container in ipairs({rs, ws}) do
        pcall(function()
            for _, child in ipairs(container:GetChildren()) do
                if child.Name:lower():find("map") or child.Name:lower():find("game") or child.Name:lower():find("data") then
                    for _, sv in ipairs(child:GetChildren()) do
                        if sv:IsA("StringValue") and (sv.Name:lower():find("disaster") or sv.Name:lower():find("event")) then
                            local NDS_VALID = {"Flood","Fire","Meteor","Earthquake","Tsunami","Tornado","Blizzard","Acid","Sandstorm","Volcanic","Heat","Twister","Lightning"}
                            for _, kw in ipairs(NDS_VALID) do
                                if sv.Value:lower():find(kw:lower()) then error(sv.Value) end
                            end
                        end
                    end
                end
            end
        end)
    end
    -- Check workspace for disaster model folders by exact NDS disaster names
    local knownDisasters = {"Flood","Fire","Meteorite","MeteorShower","Earthquake","Tsunami","Tornado","Blizzard","AcidRain","SandStorm","VolcanicEruption","SuperHeat","ThunderStorm","IceStorm"}
    for _, d in ipairs(knownDisasters) do
        if ws:FindFirstChild(d) then return d:gsub("(%l)(%u)","%1 %2") end
    end
    -- Countdown check
    local cd = ws:FindFirstChild("Countdown") or ws:FindFirstChild("CountDown")
    if cd and (cd:IsA("IntValue") or cd:IsA("NumberValue")) and cd.Value > 0 then
        return "Active — " .. cd.Value .. "s remaining"
    end
    return "None / Waiting"
end

-- ───────────────────────── [12] RUNTIME LOOPS ───────────────────────────
-- FPS counter
RunSvc.RenderStepped:Connect(function(dt) fps_cur = math.floor(1/math.max(dt, 0.001)) end)

-- God mode heartbeat
RunSvc.Heartbeat:Connect(function()
    if state.godOn then
        local h = GetHum(LP)
        if h then
            if h.MaxHealth ~= math.huge then h.MaxHealth = math.huge end
            if h.Health < math.huge     then h.Health = math.huge   end
        end
    end
end)

-- Noclip
RunSvc.Stepped:Connect(function()
    if state.noclipOn and LP.Character then
        for _, p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Flight
local FLY_SPD = 75
RunSvc.RenderStepped:Connect(function()
    if not state.flyOn then
        if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
        if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
        return
    end
    local root = GetRoot(LP); if not root then return end
    if not flyBV then
        flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1e6,1e6,1e6); flyBV.Velocity = Vector3.zero; flyBV.Parent = root
    end
    if not flyBG then
        flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(1e6,1e6,1e6); flyBG.P = 1e4; flyBG.Parent = root
    end
    local dir = Vector3.zero; local c = Cam
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + c.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - c.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - c.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + c.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space)        then dir = dir + Vector3.new(0,1,0) end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl)  then dir = dir - Vector3.new(0,1,0) end
    flyBV.Velocity = (dir.Magnitude > 0 and dir.Unit or Vector3.zero) * FLY_SPD
    flyBG.CFrame   = c.CFrame
end)

-- Infinite Jump
UIS.JumpRequest:Connect(function()
    if state.infJump then
        local h = GetHum(LP)
        if h and h:GetState() == Enum.HumanoidStateType.Freefall then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Self spin fling
RunSvc.Heartbeat:Connect(function()
    local root = GetRoot(LP); if not root then return end
    if state.selfSpin then
        if not spinBAV then
            spinBAV = Instance.new("BodyAngularVelocity")
            spinBAV.AngularVelocity = Vector3.new(0, 9999, 0)
            spinBAV.MaxTorque       = Vector3.new(math.huge, math.huge, math.huge)
            spinBAV.Parent          = root
        end
    else
        if spinBAV then pcall(function() spinBAV:Destroy() end); spinBAV = nil end
    end
end)

-- NDS Auto-Safe — fast heartbeat, teleport UP whenever below threshold
RunSvc.Heartbeat:Connect(function()
    if not state.ndsAuto then return end
    local root = GetRoot(LP); if not root then return end
    local y = root.Position.Y
    if y < 90 then
        pcall(function() root.CFrame = CFrame.new(root.Position.X, 280, root.Position.Z) end)
    end
end)

-- ESP Render
RunSvc.RenderStepped:Connect(function()
    local vp  = Cam.ViewportSize
    local ori = Vector2.new(vp.X/2, vp.Y)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LP then continue end
        if (state.espOn or state.tracerOn) and not ESPData[p] then InitESP(p) end
        local d = ESPData[p]; if not d then continue end
        local ch   = p.Character
        local root = ch and ch:FindFirstChild("HumanoidRootPart")
        local hum  = ch and ch:FindFirstChildOfClass("Humanoid")
        if not root then HideESP(d); continue end
        local sp, vis = Cam:WorldToViewportPoint(root.Position)
        if not vis or sp.Z <= 0 then HideESP(d); continue end
        local spT = Cam:WorldToViewportPoint(root.Position + Vector3.new(0,3.1,0))
        local spB = Cam:WorldToViewportPoint(root.Position - Vector3.new(0,2.7,0))
        local sx,sy = sp.X, sp.Y
        local boxH  = math.abs(spB.Y - spT.Y); local boxW = boxH * 0.5
        local dist  = math.floor((root.Position - Cam.CFrame.Position).Magnitude)
        local col   = ESPCol(p)
        if state.espOn then
            pcall(function()
                d.box.Visible = true; d.box.Color = col
                d.box.Position = Vector2.new(sx - boxW/2, spT.Y)
                d.box.Size     = Vector2.new(boxW, boxH)
                local nm = state.showDist and (p.Name.." ["..dist.."m]") or p.Name
                d.name.Visible = true; d.name.Color = col
                d.name.Position = Vector2.new(sx, spT.Y - 16); d.name.Text = nm
                if state.showHP and hum then
                    local hp = math.max(0, hum.Health); local mp = math.max(1, hum.MaxHealth)
                    local r  = math.clamp(hp/mp,0,1)
                    local hc = Color3.new(1-r, r*0.88, 0.05)
                    d.hp.Visible = true; d.hp.Color = hc
                    d.hp.Position = Vector2.new(sx, spB.Y+3); d.hp.Text = math.floor(hp).." HP"
                    d.hbBg.Visible = true; d.hbBg.Position = Vector2.new(sx - boxW/2 - 7, spT.Y); d.hbBg.Size = Vector2.new(4, boxH)
                    d.hbFill.Visible = true; d.hbFill.Color = hc
                    d.hbFill.Position = Vector2.new(sx - boxW/2 - 7, spT.Y + boxH*(1-r)); d.hbFill.Size = Vector2.new(4, boxH*r)
                else d.hp.Visible=false; d.hbBg.Visible=false; d.hbFill.Visible=false end
            end)
        else d.box.Visible=false; d.name.Visible=false; d.hp.Visible=false; d.hbBg.Visible=false; d.hbFill.Visible=false end
        if state.tracerOn then
            pcall(function() d.tracer.Visible=true; d.tracer.Color=col; d.tracer.From=ori; d.tracer.To=Vector2.new(sx,sy) end)
        else pcall(function() d.tracer.Visible=false end) end
    end
    for p in pairs(ESPData) do if not p or not p.Parent then KillESP(p) end end
end)

-- Character persistence
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    local h = GetHum(LP); if not h then return end
    h.WalkSpeed = state.spdVal; h.JumpPower = state.jmpVal
    if state.godOn then h.MaxHealth = math.huge; h.Health = math.huge end
end)

-- Player leave cleanup
Players.PlayerRemoving:Connect(function(p)
    KillESP(p)
    if ChamData[p] then pcall(function() ChamData[p]:Destroy() end); ChamData[p]=nil end
end)

-- ═══════════════════════════════════════════════════════════════════════
--   GUI CONSTRUCTION  —  Milk-style sidebar layout
-- ═══════════════════════════════════════════════════════════════════════

-- ─────────────────────── [13] LOADING SCREEN ────────────────────────────
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "LunaLoading"; LoadGui.ResetOnSpawn = false
LoadGui.IgnoreGuiInset = true; LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadGui.Parent = CoreGui

local LoadBG = Instance.new("Frame")
LoadBG.BackgroundColor3 = Color3.fromRGB(10,10,12); LoadBG.BorderSizePixel = 0
LoadBG.Size = UDim2.new(1,0,1,0); LoadBG.ZIndex = 100; LoadBG.Parent = LoadGui

local LoadCard = Instance.new("Frame")
LoadCard.AnchorPoint = Vector2.new(0.5,0.5); LoadCard.BackgroundColor3 = Color3.fromRGB(20,20,23)
LoadCard.BorderSizePixel = 0; LoadCard.Position = UDim2.new(0.5,0,0.5,0)
LoadCard.Size = UDim2.new(0,260,0,200); LoadCard.ZIndex = 101; LoadCard.Parent = LoadBG
corner(LoadCard, 18); stroke(LoadCard, Color3.fromRGB(38,38,44), 1)

-- Flower label (large emoji)
local LoadFlower = Instance.new("TextLabel")
LoadFlower.BackgroundTransparency = 1; LoadFlower.AnchorPoint = Vector2.new(0.5,0)
LoadFlower.Position = UDim2.new(0.5,0,0,20); LoadFlower.Size = UDim2.new(0,90,0,80)
LoadFlower.ZIndex = 102; LoadFlower.Font = Enum.Font.GothamBold
LoadFlower.Text = "🌸"; LoadFlower.TextSize = 62; LoadFlower.TextColor3 = Color3.new(1,1,1)
LoadFlower.TextXAlignment = Enum.TextXAlignment.Center; LoadFlower.Parent = LoadCard

local LoadTitle = Instance.new("TextLabel")
LoadTitle.BackgroundTransparency = 1; LoadTitle.AnchorPoint = Vector2.new(0.5,0)
LoadTitle.Position = UDim2.new(0.5,0,0,105); LoadTitle.Size = UDim2.new(1,0,0,28)
LoadTitle.ZIndex = 102; LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.Text = "Luna Admin"; LoadTitle.TextColor3 = C.tPri; LoadTitle.TextSize = 20
LoadTitle.TextXAlignment = Enum.TextXAlignment.Center; LoadTitle.Parent = LoadCard

local LoadSub = Instance.new("TextLabel")
LoadSub.BackgroundTransparency = 1; LoadSub.AnchorPoint = Vector2.new(0.5,0)
LoadSub.Position = UDim2.new(0.5,0,0,136); LoadSub.Size = UDim2.new(1,0,0,18)
LoadSub.ZIndex = 102; LoadSub.Font = Enum.Font.Gotham
LoadSub.Text = "Loading..."; LoadSub.TextColor3 = C.tSec; LoadSub.TextSize = 13
LoadSub.TextXAlignment = Enum.TextXAlignment.Center; LoadSub.Parent = LoadCard

-- Version badge
local VerLbl = Instance.new("TextLabel")
VerLbl.BackgroundTransparency = 1; VerLbl.AnchorPoint = Vector2.new(0.5,1)
VerLbl.Position = UDim2.new(0.5,0,1,-8); VerLbl.Size = UDim2.new(1,0,0,14)
VerLbl.ZIndex = 102; VerLbl.Font = Enum.Font.Gotham
VerLbl.Text = "V3 Reimagined  ·  Trusted Executor"; VerLbl.TextColor3 = C.tDim; VerLbl.TextSize = 10
VerLbl.TextXAlignment = Enum.TextXAlignment.Center; VerLbl.Parent = LoadCard

-- Dots animation
task.spawn(function()
    local dots = 0
    while LoadSub.Parent do
        task.wait(0.38)
        dots = dots % 3 + 1
        LoadSub.Text = "Loading" .. string.rep(".", dots)
    end
end)

-- Entrance anim
LoadCard.Size = UDim2.new(0,0,0,0); LoadCard.BackgroundTransparency = 1
TwnSvc:Create(LoadCard, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0,260,0,200), BackgroundTransparency = 0
}):Play()

-- ─────────────────────── [14] MAIN GUI (built while loading) ─────────────
local Gui = Instance.new("ScreenGui")
Gui.Name = "LunaAdmin"; Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; Gui.IgnoreGuiInset = true
Gui.Enabled = false; Gui.Parent = CoreGui

-- Notifications
local notifN = 0
local function Notify(msg, col)
    col = col or C.togOn; notifN += 1; local slot = notifN
    local F = Instance.new("Frame")
    F.BackgroundColor3 = C.card; F.BorderSizePixel = 0
    F.AnchorPoint = Vector2.new(1,0); F.Position = UDim2.new(1,310,0,14+(slot-1)*56)
    F.Size = UDim2.new(0,275,0,46); F.ZIndex = 200; F.Parent = Gui
    corner(F,8); stroke(F,col,1)
    local bar = Instance.new("Frame"); bar.BackgroundColor3=col; bar.BorderSizePixel=0
    bar.Size=UDim2.new(0,3,1,0); bar.ZIndex=201; bar.Parent=F; corner(bar,4)
    local lbl = Instance.new("TextLabel"); lbl.BackgroundTransparency=1
    lbl.Position=UDim2.new(0,12,0,0); lbl.Size=UDim2.new(1,-16,1,0)
    lbl.ZIndex=201; lbl.Font=Enum.Font.GothamSemibold; lbl.Text=msg
    lbl.TextColor3=C.tPri; lbl.TextSize=11; lbl.TextXAlignment=Enum.TextXAlignment.Left
    lbl.TextWrapped=true; lbl.Parent=F
    tw(F,0.28,{Position=UDim2.new(1,-12,0,14+(slot-1)*56)})
    task.delay(3.8,function() tw(F,0.22,{Position=UDim2.new(1,310,0,14+(slot-1)*56)}); task.wait(0.25); pcall(function() F:Destroy() end); notifN=math.max(0,notifN-1) end)
end

-- ── Window ──
local Win = Instance.new("Frame")
Win.Name="Window"; Win.AnchorPoint=Vector2.new(0.5,0.5)
Win.BackgroundColor3=C.win; Win.BorderSizePixel=0
Win.Position=UDim2.new(0.5,0,0.5,0); Win.Size=UDim2.new(0,720,0,488)
Win.ZIndex=1; Win.ClipsDescendants=true; Win.Parent=Gui
corner(Win,14); stroke(Win,C.border,1)

-- ── Sidebar ──
local Side = Instance.new("Frame")
Side.BackgroundColor3=C.side; Side.BorderSizePixel=0
Side.Size=UDim2.new(0,192,1,0); Side.ZIndex=2; Side.Parent=Win
corner(Side,14)
-- fix right corners
local SideFix = Instance.new("Frame"); SideFix.BackgroundColor3=C.side; SideFix.BorderSizePixel=0
SideFix.Position=UDim2.new(1,-14,0,0); SideFix.Size=UDim2.new(0,14,1,0); SideFix.ZIndex=2; SideFix.Parent=Side

-- Logo area
local LogoArea = Instance.new("Frame")
LogoArea.BackgroundTransparency=1; LogoArea.BorderSizePixel=0
LogoArea.Size=UDim2.new(1,0,0,62); LogoArea.ZIndex=3; LogoArea.Parent=Side
pad(LogoArea,14,0,14,0)

local LogoIcon = Instance.new("TextLabel")
LogoIcon.BackgroundTransparency=1; LogoIcon.Size=UDim2.new(0,28,0,28)
LogoIcon.ZIndex=4; LogoIcon.Font=Enum.Font.GothamBold; LogoIcon.Text="🌸"
LogoIcon.TextSize=20; LogoIcon.TextColor3=Color3.new(1,1,1); LogoIcon.Parent=LogoArea

local LogoName = Instance.new("TextLabel")
LogoName.BackgroundTransparency=1; LogoName.AnchorPoint=Vector2.new(0,0.5)
LogoName.Position=UDim2.new(0,34,0,14); LogoName.Size=UDim2.new(1,-38,0,22)
LogoName.ZIndex=4; LogoName.Font=Enum.Font.GothamBold; LogoName.Text="Luna Admin"
LogoName.TextColor3=C.tPri; LogoName.TextSize=14
LogoName.TextXAlignment=Enum.TextXAlignment.Left; LogoName.Parent=LogoArea

-- Sidebar separator
local SideSep = Instance.new("Frame")
SideSep.BackgroundColor3=C.border; SideSep.BorderSizePixel=0
SideSep.Position=UDim2.new(0,14,0,62); SideSep.Size=UDim2.new(1,-28,0,1); SideSep.ZIndex=3; SideSep.Parent=Side

-- Nav container
local NavList = Instance.new("Frame")
NavList.BackgroundTransparency=1; NavList.BorderSizePixel=0
NavList.Position=UDim2.new(0,0,0,68); NavList.Size=UDim2.new(1,0,1,-112)
NavList.ZIndex=3; NavList.Parent=Side
listL(NavList, Enum.FillDirection.Vertical, 2)
pad(NavList,4,4,8,8)

-- User profile at bottom of sidebar
local UserArea = Instance.new("Frame")
UserArea.BackgroundColor3=Color3.fromRGB(24,24,27); UserArea.BorderSizePixel=0
UserArea.AnchorPoint=Vector2.new(0,1); UserArea.Position=UDim2.new(0,0,1,0)
UserArea.Size=UDim2.new(1,0,0,52); UserArea.ZIndex=3; UserArea.Parent=Side
corner(UserArea,10)
local UAFix=Instance.new("Frame"); UAFix.BackgroundColor3=Color3.fromRGB(24,24,27)
UAFix.BorderSizePixel=0; UAFix.Size=UDim2.new(1,0,0,10); UAFix.ZIndex=3; UAFix.Parent=UserArea

local UAAvatar = Instance.new("Frame")
UAAvatar.BackgroundColor3=C.togOn; UAAvatar.BorderSizePixel=0
UAAvatar.AnchorPoint=Vector2.new(0,0.5); UAAvatar.Position=UDim2.new(0,10,0.5,0)
UAAvatar.Size=UDim2.new(0,30,0,30); UAAvatar.ZIndex=4; UAAvatar.Parent=UserArea; corner(UAAvatar,99)
local UAEmoji=Instance.new("TextLabel"); UAEmoji.BackgroundTransparency=1
UAEmoji.Size=UDim2.new(1,0,1,0); UAEmoji.ZIndex=5; UAEmoji.Font=Enum.Font.Gotham
UAEmoji.Text="👤"; UAEmoji.TextSize=14; UAEmoji.TextColor3=Color3.new(1,1,1); UAEmoji.Parent=UAAvatar
pcall(function()
    local img,_ = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    if img then
        UAEmoji.Text=""
        local imgL=Instance.new("ImageLabel"); imgL.BackgroundTransparency=1
        imgL.Size=UDim2.new(1,0,1,0); imgL.ZIndex=5; imgL.Image=img; imgL.Parent=UAAvatar; corner(imgL,99)
    end
end)

local UAName=Instance.new("TextLabel"); UAName.BackgroundTransparency=1
UAName.AnchorPoint=Vector2.new(0,0); UAName.Position=UDim2.new(0,48,0,8)
UAName.Size=UDim2.new(1,-52,0,16); UAName.ZIndex=4; UAName.Font=Enum.Font.GothamSemibold
UAName.Text=LP.Name; UAName.TextColor3=C.tPri; UAName.TextSize=12
UAName.TextXAlignment=Enum.TextXAlignment.Left; UAName.Parent=UserArea

local UASub=Instance.new("TextLabel"); UASub.BackgroundTransparency=1
UASub.AnchorPoint=Vector2.new(0,0); UASub.Position=UDim2.new(0,48,0,25)
UASub.Size=UDim2.new(1,-52,0,14); UISub=4; UASub.Font=Enum.Font.Gotham
UASub.Text=LP.DisplayName ~= LP.Name and LP.DisplayName or "Luna Admin User"
UASub.TextColor3=C.tDim; UASub.TextSize=10; UASub.ZIndex=4
UASub.TextXAlignment=Enum.TextXAlignment.Left; UASub.Parent=UserArea

-- ── Top bar ──
local TopBar = Instance.new("Frame")
TopBar.BackgroundColor3=C.topbar; TopBar.BorderSizePixel=0
TopBar.Position=UDim2.new(0,192,0,0); TopBar.Size=UDim2.new(1,-192,0,38); TopBar.ZIndex=2; TopBar.Parent=Win

-- Discord link in topbar
local DiscLink=Instance.new("TextButton")
DiscLink.BackgroundTransparency=1; DiscLink.AnchorPoint=Vector2.new(0.5,0.5)
DiscLink.Position=UDim2.new(0.5,0,0.5,0); DiscLink.Size=UDim2.new(0,240,1,0); DiscLink.ZIndex=3
DiscLink.Font=Enum.Font.Gotham; DiscLink.Text="discord.gg/JGeVGv23TQ"
DiscLink.TextColor3=C.tDim; DiscLink.TextSize=11; DiscLink.Parent=TopBar
DiscLink.MouseEnter:Connect(function() tw(DiscLink,0.1,{TextColor3=C.tSec}) end)
DiscLink.MouseLeave:Connect(function() tw(DiscLink,0.1,{TextColor3=C.tDim}) end)
DiscLink.MouseButton1Click:Connect(function()
    CopyClipboard("https://discord.gg/JGeVGv23TQ")
    DiscLink.TextColor3=C.ok; task.delay(1.5,function() tw(DiscLink,0.3,{TextColor3=C.tDim}) end)
    Notify("Discord link copied! ✓", C.togOn)
end)

-- Topbar right icons
local iconRow=Instance.new("Frame"); iconRow.BackgroundTransparency=1; iconRow.BorderSizePixel=0
iconRow.AnchorPoint=Vector2.new(1,0.5); iconRow.Position=UDim2.new(1,-10,0.5,0)
iconRow.Size=UDim2.new(0,90,0,22); iconRow.ZIndex=3; iconRow.Parent=TopBar
listL(iconRow,Enum.FillDirection.Horizontal,6)

for _, ic in ipairs({"🔍","🔔"}) do
    local ib=Instance.new("TextButton"); ib.BackgroundTransparency=1; ib.BorderSizePixel=0
    ib.Size=UDim2.new(0,18,0,18); ib.ZIndex=3; ib.Font=Enum.Font.Gotham
    ib.Text=ic; ib.TextSize=13; ib.TextColor3=C.tDim; ib.Parent=iconRow
    ib.MouseEnter:Connect(function() tw(ib,0.1,{TextColor3=C.tSec}) end)
    ib.MouseLeave:Connect(function() tw(ib,0.1,{TextColor3=C.tDim}) end)
end
-- Colored dots
for _, col in ipairs({Color3.fromRGB(255,95,87),Color3.fromRGB(255,189,46),Color3.fromRGB(40,200,65),Color3.fromRGB(90,140,255)}) do
    local dot=Instance.new("Frame"); dot.BackgroundColor3=col; dot.BorderSizePixel=0
    dot.Size=UDim2.new(0,10,0,10); dot.ZIndex=3; dot.Parent=iconRow; corner(dot,99)
end

-- Topbar separator
local TBSep=Instance.new("Frame"); TBSep.BackgroundColor3=C.border; TBSep.BorderSizePixel=0
TBSep.Position=UDim2.new(0,192,0,38); TBSep.Size=UDim2.new(1,-192,0,1); TBSep.ZIndex=2; TBSep.Parent=Win

-- ── Content Area ──
local ContentArea=Instance.new("Frame")
ContentArea.BackgroundTransparency=1; ContentArea.BorderSizePixel=0
ContentArea.Position=UDim2.new(0,192,0,39); ContentArea.Size=UDim2.new(1,-192,1,-39)
ContentArea.ZIndex=2; ContentArea.ClipsDescendants=true; ContentArea.Parent=Win

-- ══════════════════════════════════════════════════════════════
--   PAGE SYSTEM
-- ══════════════════════════════════════════════════════════════

local Pages = {}
local ActivePage = nil

local function NavItem(label, icon, order)
    local Btn=Instance.new("TextButton"); Btn.BackgroundColor3=Color3.fromRGB(0,0,0)
    Btn.BackgroundTransparency=1; Btn.BorderSizePixel=0
    Btn.Size=UDim2.new(1,0,0,32); Btn.ZIndex=5; Btn.LayoutOrder=order or 0; Btn.Parent=NavList
    corner(Btn,8)

    local Ic=Instance.new("TextLabel"); Ic.BackgroundTransparency=1
    Ic.Position=UDim2.new(0,8,0.5,-8); Ic.Size=UDim2.new(0,16,0,16); Ic.ZIndex=6
    Ic.Font=Enum.Font.Gotham; Ic.Text=icon; Ic.TextSize=13; Ic.TextColor3=C.tDim
    Ic.TextXAlignment=Enum.TextXAlignment.Center; Ic.Parent=Btn

    local Lbl=Instance.new("TextLabel"); Lbl.BackgroundTransparency=1
    Lbl.Position=UDim2.new(0,30,0,0); Lbl.Size=UDim2.new(1,-34,1,0); Lbl.ZIndex=6
    Lbl.Font=Enum.Font.GothamSemibold; Lbl.Text=label; Lbl.TextColor3=C.tDim
    Lbl.TextSize=12; Lbl.TextXAlignment=Enum.TextXAlignment.Left; Lbl.Parent=Btn

    -- Page scroll frame
    local Page=Instance.new("ScrollingFrame")
    Page.BackgroundTransparency=1; Page.BorderSizePixel=0
    Page.Size=UDim2.new(1,0,1,0); Page.CanvasSize=UDim2.new(0,0,0,0)
    Page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    Page.ScrollBarThickness=3; Page.ScrollBarImageColor3=C.togOn
    Page.Visible=false; Page.ZIndex=3; Page.Parent=ContentArea
    listL(Page,Enum.FillDirection.Vertical,0)

    Pages[label]={Btn=Btn, Ic=Ic, Lbl=Lbl, Page=Page}

    Btn.MouseButton1Click:Connect(function()
        for _, t in pairs(Pages) do
            t.Page.Visible=false
            tw(t.Btn,0.12,{BackgroundTransparency=1})
            tw(t.Ic,0.12,{TextColor3=C.tDim}); tw(t.Lbl,0.12,{TextColor3=C.tDim})
        end
        Page.Visible=true; ActivePage=label
        tw(Btn,0.12,{BackgroundTransparency=0, BackgroundColor3=C.navAct})
        tw(Ic,0.12,{TextColor3=C.tPri}); tw(Lbl,0.12,{TextColor3=C.tPri})
    end)

    return Page
end

-- Section header label inside a page (e.g. "Harvest & Sell")
local function SecHeader(parent, txt, order)
    local F=Instance.new("Frame"); F.BackgroundTransparency=1; F.BorderSizePixel=0
    F.Size=UDim2.new(1,0,0,28); F.LayoutOrder=order or 0; F.Parent=parent
    local L=Instance.new("TextLabel"); L.BackgroundTransparency=1
    L.Position=UDim2.new(0,18,0,0); L.Size=UDim2.new(1,-22,1,0); L.ZIndex=4
    L.Font=Enum.Font.GothamMedium; L.Text=txt; L.TextColor3=C.tDim; L.TextSize=11
    L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=F
    return F
end

-- Milk-style toggle row (full-width, label left, toggle right, thin separator)
local function TogRow(parent, label, order, cb)
    local F=Instance.new("Frame"); F.BackgroundColor3=Color3.fromRGB(0,0,0)
    F.BackgroundTransparency=1; F.BorderSizePixel=0
    F.Size=UDim2.new(1,0,0,42); F.LayoutOrder=order or 10; F.Parent=parent
    pad(F,0,0,18,18)

    -- separator bottom
    local sep=Instance.new("Frame"); sep.BackgroundColor3=C.sep; sep.BorderSizePixel=0
    sep.AnchorPoint=Vector2.new(0,1); sep.Position=UDim2.new(0,0,1,0)
    sep.Size=UDim2.new(1,0,0,1); sep.ZIndex=4; sep.Parent=F

    local Lbl=Instance.new("TextLabel"); Lbl.BackgroundTransparency=1
    Lbl.Position=UDim2.new(0,0,0,0); Lbl.Size=UDim2.new(1,-52,1,0); Lbl.ZIndex=5
    Lbl.Font=Enum.Font.GothamMedium; Lbl.Text=label; Lbl.TextColor3=C.tPri
    Lbl.TextSize=13; Lbl.TextXAlignment=Enum.TextXAlignment.Left; Lbl.Parent=F

    local Bg=Instance.new("Frame"); Bg.AnchorPoint=Vector2.new(1,0.5)
    Bg.BackgroundColor3=C.togOff; Bg.BorderSizePixel=0
    Bg.Position=UDim2.new(1,0,0.5,0); Bg.Size=UDim2.new(0,42,0,24); Bg.ZIndex=5; Bg.Parent=F; corner(Bg,99)
    local Knob=Instance.new("Frame"); Knob.AnchorPoint=Vector2.new(0,0.5); Knob.BackgroundColor3=C.togKnob
    Knob.BorderSizePixel=0; Knob.Position=UDim2.new(0,3,0.5,0)
    Knob.Size=UDim2.new(0,18,0,18); Knob.ZIndex=6; Knob.Parent=Bg; corner(Knob,99)

    local Catcher=Instance.new("TextButton"); Catcher.BackgroundTransparency=1; Catcher.BorderSizePixel=0
    Catcher.Size=UDim2.new(1,0,1,0); Catcher.ZIndex=10; Catcher.Text=""; Catcher.Parent=F

    local on=false
    local function Set(s)
        on=s
        if s then tw(Bg,0.16,{BackgroundColor3=C.togOn}); tw(Knob,0.16,{Position=UDim2.new(1,-21,0.5,0)})
        else tw(Bg,0.16,{BackgroundColor3=C.togOff}); tw(Knob,0.16,{Position=UDim2.new(0,3,0.5,0)}) end
        if cb then task.spawn(pcall,cb,s) end
    end
    Catcher.MouseButton1Click:Connect(function() Set(not on) end)
    return {Set=Set, Get=function() return on end}
end

-- Action button (Milk style — subtle, full-width)
local function ActBtn(parent, label, col, order, cb)
    col = col or Color3.fromRGB(40,90,200)
    local F=Instance.new("Frame"); F.BackgroundColor3=Color3.fromRGB(0,0,0)
    F.BackgroundTransparency=1; F.BorderSizePixel=0
    F.Size=UDim2.new(1,0,0,42); F.LayoutOrder=order or 10; F.Parent=parent
    pad(F,5,5,18,18)

    local Btn=Instance.new("TextButton"); Btn.BackgroundColor3=col; Btn.BorderSizePixel=0
    Btn.Size=UDim2.new(1,0,1,0); Btn.ZIndex=5; Btn.Font=Enum.Font.GothamSemibold
    Btn.Text=label; Btn.TextColor3=C.tPri; Btn.TextSize=12; Btn.Parent=F; corner(Btn,8)
    local lit=col:Lerp(Color3.new(1,1,1),0.14); local drk=col:Lerp(Color3.new(0,0,0),0.2)
    Btn.MouseEnter:Connect(function() tw(Btn,0.1,{BackgroundColor3=lit}) end)
    Btn.MouseLeave:Connect(function() tw(Btn,0.1,{BackgroundColor3=col}) end)
    Btn.MouseButton1Down:Connect(function() tw(Btn,0.05,{BackgroundColor3=drk}) end)
    Btn.MouseButton1Up:Connect(function() tw(Btn,0.05,{BackgroundColor3=lit}) end)
    if cb then Btn.MouseButton1Click:Connect(cb) end
    return Btn
end

-- Text input row
local function InputRow(parent, ph, order)
    local F=Instance.new("Frame"); F.BackgroundColor3=Color3.fromRGB(0,0,0)
    F.BackgroundTransparency=1; F.BorderSizePixel=0
    F.Size=UDim2.new(1,0,0,44); F.LayoutOrder=order or 10; F.Parent=parent
    pad(F,6,6,18,18)

    local Box=Instance.new("Frame"); Box.BackgroundColor3=Color3.fromRGB(26,26,30)
    Box.BorderSizePixel=0; Box.Size=UDim2.new(1,0,1,0); Box.ZIndex=5; Box.Parent=F; corner(Box,8)
    local sk=stroke(Box,C.border,1)
    local TB=Instance.new("TextBox"); TB.BackgroundTransparency=1
    TB.Position=UDim2.new(0,12,0,0); TB.Size=UDim2.new(1,-24,1,0); TB.ZIndex=6
    TB.Font=Enum.Font.Gotham; TB.PlaceholderText=ph or "..."
    TB.PlaceholderColor3=C.tDim; TB.Text=""; TB.TextColor3=C.tPri; TB.TextSize=12
    TB.TextXAlignment=Enum.TextXAlignment.Left; TB.ClearTextOnFocus=false; TB.Parent=Box
    TB.Focused:Connect(function() tw(sk,0.14,{Color=C.togOn}) end)
    TB.FocusLost:Connect(function() tw(sk,0.14,{Color=C.border}) end)
    return TB
end

-- Info label row
local function InfoLbl(parent, txt, col, order)
    local F=Instance.new("Frame"); F.BackgroundTransparency=1; F.BorderSizePixel=0
    F.Size=UDim2.new(1,0,0,24); F.LayoutOrder=order or 10; F.Parent=parent
    pad(F,0,0,18,0)
    local L=Instance.new("TextLabel"); L.BackgroundTransparency=1
    L.Size=UDim2.new(1,0,1,0); L.ZIndex=5; L.Font=Enum.Font.Gotham; L.Text=txt
    L.TextColor3=col or C.tSec; L.TextSize=11; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=F
    return L
end

-- ── Section label (heading in nav, just a text spacer) ──
local function NavSectionLabel(txt, order)
    local L=Instance.new("TextLabel"); L.BackgroundTransparency=1
    L.Size=UDim2.new(1,0,0,22); L.LayoutOrder=order or 0; L.ZIndex=4; L.Parent=NavList
    L.Font=Enum.Font.GothamMedium; L.Text=txt; L.TextColor3=C.tDim; L.TextSize=10
    L.TextXAlignment=Enum.TextXAlignment.Left
    pad(L,6,0,10,0)
    return L
end

-- ══════════════════════════════════════════════════════════════
--   NAV ITEMS
-- ══════════════════════════════════════════════════════════════
local DashPage = NavItem("Dashboard", "⊞", 1)
NavSectionLabel("Panels", 2)
local PlayPage = NavItem("Players",   "👥", 3)
local VisuPage = NavItem("Visuals",   "👁", 4)
local NDSPage  = IS_NDS and NavItem("NDS",     "🌋", 5) or nil
local MiscPage = NavItem("Misc",      "⚙", IS_NDS and 6 or 5)

-- ══════════════════════════════════════════════════════════════
--   DASHBOARD PAGE
-- ══════════════════════════════════════════════════════════════
pad(DashPage,12,12,12,12)

-- Welcome banner card
local WelCard=Instance.new("Frame"); WelCard.BackgroundColor3=Color3.fromRGB(28,40,65)
WelCard.BorderSizePixel=0; WelCard.Size=UDim2.new(1,0,0,88); WelCard.ZIndex=4; WelCard.LayoutOrder=1; WelCard.Parent=DashPage
corner(WelCard,12); stroke(WelCard,Color3.fromRGB(45,65,110),1)

-- Avatar on welcome card
local WAv=Instance.new("Frame"); WAv.BackgroundColor3=Color3.fromRGB(40,60,100); WAv.BorderSizePixel=0
WAv.AnchorPoint=Vector2.new(0,0.5); WAv.Position=UDim2.new(0,14,0.5,0); WAv.Size=UDim2.new(0,58,0,58); WAv.ZIndex=5; WAv.Parent=WelCard; corner(WAv,99)
local WAvi=Instance.new("TextLabel"); WAvi.BackgroundTransparency=1; WAvi.Size=UDim2.new(1,0,1,0); WAvi.ZIndex=6; WAvi.Font=Enum.Font.Gotham; WAvi.Text="👤"; WAvi.TextSize=28; WAvi.TextColor3=Color3.new(1,1,1); WAvi.Parent=WAv
pcall(function()
    local img,_ = Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size100x100)
    if img then
        WAvi.Text=""
        local ail=Instance.new("ImageLabel"); ail.BackgroundTransparency=1; ail.Size=UDim2.new(1,0,1,0); ail.ZIndex=6; ail.Image=img; ail.Parent=WAv; corner(ail,99)
    end
end)

local WName=Instance.new("TextLabel"); WName.BackgroundTransparency=1
WName.Position=UDim2.new(0,82,0,16); WName.Size=UDim2.new(0.55,0,0,22); WName.ZIndex=5
WName.Font=Enum.Font.GothamBold; WName.Text="Welcome, "..LP.Name; WName.TextColor3=C.tPri; WName.TextSize=17
WName.TextXAlignment=Enum.TextXAlignment.Left; WName.Parent=WelCard

local WGreet=Instance.new("TextLabel"); WGreet.BackgroundTransparency=1
WGreet.Position=UDim2.new(0,82,0,40); WGreet.Size=UDim2.new(0.58,0,0,16); WGreet.ZIndex=5
WGreet.Font=Enum.Font.Gotham; WGreet.Text=GetGreeting().."  |  Luna Admin V3"; WGreet.TextColor3=C.tSec; WGreet.TextSize=11
WGreet.TextXAlignment=Enum.TextXAlignment.Left; WGreet.Parent=WelCard

-- Time/date top right of welcome card
local WTime=Instance.new("TextLabel"); WTime.BackgroundTransparency=1
WTime.AnchorPoint=Vector2.new(1,0); WTime.Position=UDim2.new(1,-14,0,14); WTime.Size=UDim2.new(0,100,0,18); WTime.ZIndex=5
WTime.Font=Enum.Font.GothamBold; WTime.Text=os.date("%H : %M : %S"); WTime.TextColor3=C.tPri; WTime.TextSize=13
WTime.TextXAlignment=Enum.TextXAlignment.Right; WTime.Parent=WelCard

local WDate=Instance.new("TextLabel"); WDate.BackgroundTransparency=1
WDate.AnchorPoint=Vector2.new(1,0); WDate.Position=UDim2.new(1,-14,0,33); WDate.Size=UDim2.new(0,100,0,16); WDate.ZIndex=5
WDate.Font=Enum.Font.Gotham; WDate.Text=os.date("%d / %m / %y"); WDate.TextColor3=C.tSec; WDate.TextSize=11
WDate.TextXAlignment=Enum.TextXAlignment.Right; WDate.Parent=WelCard

-- Clock loop
task.spawn(function()
    while Gui.Parent do
        task.wait(1)
        pcall(function() WTime.Text=os.date("%H : %M : %S"); WDate.Text=os.date("%d / %m / %y") end)
    end
end)

-- Card grid row 1
local Row1=Instance.new("Frame"); Row1.BackgroundTransparency=1; Row1.BorderSizePixel=0
Row1.Size=UDim2.new(1,0,0,100); Row1.LayoutOrder=2; Row1.Parent=DashPage
listL(Row1,Enum.FillDirection.Horizontal,8)

local function DashCard(parent, w, col, order)
    local C_=Instance.new("Frame"); C_.BackgroundColor3=col or C.card
    C_.BorderSizePixel=0; C_.Size=UDim2.new(0,w,1,0); C_.ZIndex=4; C_.LayoutOrder=order; C_.Parent=parent; corner(C_,10)
    return C_
end

-- Discord card
local DC=DashCard(Row1,145,Color3.fromRGB(42,72,175),1)
local DCGrad=Instance.new("UIGradient"); DCGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(55,95,215)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(35,55,150))
}); DCGrad.Rotation=135; DCGrad.Parent=DC

local DCTitle=Instance.new("TextLabel"); DCTitle.BackgroundTransparency=1
DCTitle.Position=UDim2.new(0,12,0,12); DCTitle.Size=UDim2.new(1,-14,0,20); DCTitle.ZIndex=5
DCTitle.Font=Enum.Font.GothamBold; DCTitle.Text="🎮 Discord"; DCTitle.TextColor3=Color3.new(1,1,1); DCTitle.TextSize=14
DCTitle.TextXAlignment=Enum.TextXAlignment.Left; DCTitle.Parent=DC
local DCSub=Instance.new("TextLabel"); DCSub.BackgroundTransparency=1
DCSub.Position=UDim2.new(0,12,0,34); DCSub.Size=UDim2.new(1,-14,0,48); DCSub.ZIndex=5
DCSub.Font=Enum.Font.Gotham; DCSub.Text="Tap to copy the\nLuna discord link."; DCSub.TextColor3=Color3.fromRGB(200,210,255); DCSub.TextSize=11
DCSub.TextXAlignment=Enum.TextXAlignment.Left; DCSub.TextWrapped=true; DCSub.Parent=DC

local DCBtn=Instance.new("TextButton"); DCBtn.BackgroundTransparency=1; DCBtn.BorderSizePixel=0
DCBtn.Size=UDim2.new(1,0,1,0); DCBtn.ZIndex=6; DCBtn.Text=""; DCBtn.Parent=DC
DCBtn.MouseEnter:Connect(function() tw(DC,0.1,{BackgroundColor3=Color3.fromRGB(52,85,200)}) end)
DCBtn.MouseLeave:Connect(function() tw(DC,0.1,{BackgroundColor3=Color3.fromRGB(42,72,175)}) end)
DCBtn.MouseButton1Click:Connect(function()
    CopyClipboard("https://discord.gg/JGeVGv23TQ")
    Notify("Discord copied! ✓", C.togOn)
end)

-- Changelog card
local CL=DashCard(Row1,145,C.card,2); stroke(CL,C.border,1)
local CLT=Instance.new("TextLabel"); CLT.BackgroundTransparency=1
CLT.Position=UDim2.new(0,12,0,12); CLT.Size=UDim2.new(1,-14,0,18); CLT.ZIndex=5
CLT.Font=Enum.Font.GothamBold; CLT.Text="📄 Changelog"; CLT.TextColor3=C.tPri; CLT.TextSize=13
CLT.TextXAlignment=Enum.TextXAlignment.Left; CLT.Parent=CL
local CLV=Instance.new("TextLabel"); CLV.BackgroundTransparency=1
CLV.Position=UDim2.new(0,12,0,32); CLV.Size=UDim2.new(1,-14,0,16); CLV.ZIndex=5
CLV.Font=Enum.Font.GothamBold; CLV.Text="Version 3.0 'Reimagined'"; CLV.TextColor3=C.togOn; CLV.TextSize=11
CLV.TextXAlignment=Enum.TextXAlignment.Left; CLV.Parent=CL
local CLD=Instance.new("TextLabel"); CLD.BackgroundTransparency=1
CLD.Position=UDim2.new(0,12,0,50); CLD.Size=UDim2.new(1,-14,0,36); CLD.ZIndex=5
CLD.Font=Enum.Font.Gotham; CLD.Text="Fixed ESP, Fling,\nNDS Detection, UI."; CLD.TextColor3=C.tSec; CLD.TextSize=11
CLD.TextXAlignment=Enum.TextXAlignment.Left; CLD.TextWrapped=true; CLD.Parent=CL

-- Account card
local AC=DashCard(Row1,135,C.card,3); stroke(AC,C.border,1)
local ACT=Instance.new("TextLabel"); ACT.BackgroundTransparency=1
ACT.Position=UDim2.new(0,12,0,12); ACT.Size=UDim2.new(1,-14,0,18); ACT.ZIndex=5
ACT.Font=Enum.Font.GothamBold; ACT.Text="👤 Account"; ACT.TextColor3=C.tPri; ACT.TextSize=13
ACT.TextXAlignment=Enum.TextXAlignment.Left; ACT.Parent=AC
local ACS=Instance.new("TextLabel"); ACS.BackgroundTransparency=1
ACS.Position=UDim2.new(0,12,0,34); ACS.Size=UDim2.new(1,-14,0,50); ACS.ZIndex=5
ACS.Font=Enum.Font.Gotham; ACS.Text="ID: "..LP.UserId.."\n"..LP.Name; ACS.TextColor3=C.tSec; ACS.TextSize=11
ACS.TextXAlignment=Enum.TextXAlignment.Left; ACS.TextWrapped=true; ACS.Parent=AC

-- Card grid row 2
local Row2=Instance.new("Frame"); Row2.BackgroundTransparency=1; Row2.BorderSizePixel=0
Row2.Size=UDim2.new(1,0,0,110); Row2.LayoutOrder=3; Row2.Parent=DashPage
listL(Row2,Enum.FillDirection.Horizontal,8)

-- Server info card
local SV=DashCard(Row2,250,C.card,1); stroke(SV,C.border,1)
local SVT=Instance.new("TextLabel"); SVT.BackgroundTransparency=1
SVT.Position=UDim2.new(0,12,0,10); SVT.Size=UDim2.new(1,-14,0,18); SVT.ZIndex=5
SVT.Font=Enum.Font.GothamBold; SVT.Text="📡 Server"; SVT.TextColor3=C.tPri; SVT.TextSize=13
SVT.TextXAlignment=Enum.TextXAlignment.Left; SVT.Parent=SV

local svData={
    {"Players", function() return #Players:GetPlayers().." in server" end, 0,18},
    {"Capacity",function() return Players.MaxPlayers.." max" end, 95,18},
    {"FPS",     function() return fps_cur.." fps" end, 0,52},
    {"Ping",    function() return GetPing() end, 95,52},
    {"Region",  function() return "N/A" end, 0,76},
}
local svLabels={}
for _, d in ipairs(svData) do
    local tKey=Instance.new("TextLabel"); tKey.BackgroundTransparency=1
    tKey.Position=UDim2.new(0,d[4]+12,0,d[3]); tKey.Size=UDim2.new(0,80,0,14); tKey.ZIndex=5
    tKey.Font=Enum.Font.GothamSemibold; tKey.Text=d[1]; tKey.TextColor3=C.tSec; tKey.TextSize=10
    tKey.TextXAlignment=Enum.TextXAlignment.Left; tKey.Parent=SV
    local tVal=Instance.new("TextLabel"); tVal.BackgroundTransparency=1
    tVal.Position=UDim2.new(0,d[4]+12,0,d[3]+15); tVal.Size=UDim2.new(0,80,0,14); tVal.ZIndex=5
    tVal.Font=Enum.Font.Gotham; tVal.Text=d[2](); tVal.TextColor3=C.tPri; tVal.TextSize=11
    tVal.TextXAlignment=Enum.TextXAlignment.Left; tVal.Parent=SV
    table.insert(svLabels,{val=tVal,fn=d[2]})
end
task.spawn(function()
    while Gui.Parent do task.wait(2)
        pcall(function() for _,s in ipairs(svLabels) do s.val.Text=s.fn() end end)
    end
end)

-- Executor card
local EX=DashCard(Row2,170,C.card,2); stroke(EX,C.border,1)
local EXT=Instance.new("TextLabel"); EXT.BackgroundTransparency=1
EXT.Position=UDim2.new(0,12,0,10); EXT.Size=UDim2.new(1,-14,0,18); EXT.ZIndex=5
EXT.Font=Enum.Font.GothamBold; EXT.Text="⚡ Velocity / Executor"; EXT.TextColor3=C.tPri; EXT.TextSize=12
EXT.TextXAlignment=Enum.TextXAlignment.Left; EXT.Parent=EX
local EXV=Instance.new("TextLabel"); EXV.BackgroundTransparency=1
EXV.Position=UDim2.new(0,12,0,34); EXV.Size=UDim2.new(1,-14,0,14); EXV.ZIndex=5
EXV.Font=Enum.Font.GothamSemibold; EXV.Text=DrawOK and "✓ Drawing API Supported" or "✗ No Drawing API"
EXV.TextColor3=DrawOK and C.ok or C.err; EXV.TextSize=11
EXV.TextXAlignment=Enum.TextXAlignment.Left; EXV.Parent=EX
local EXS=Instance.new("TextLabel"); EXS.BackgroundTransparency=1
EXS.Position=UDim2.new(0,12,0,52); EXS.Size=UDim2.new(1,-14,0,46); EXS.ZIndex=5
EXS.Font=Enum.Font.Gotham
EXS.Text="Synapse X, KRNL,\nFluxus, Evon\nsupported."
EXS.TextColor3=C.tDim; EXS.TextSize=10; EXS.TextXAlignment=Enum.TextXAlignment.Left; EXS.TextWrapped=true; EXS.Parent=EX

-- ══════════════════════════════════════════════════════════════
--   PLAYERS PAGE
-- ══════════════════════════════════════════════════════════════
pad(PlayPage,0,8,0,0)

SecHeader(PlayPage,"God Mode",1)
TogRow(PlayPage,"God Mode (Infinite Health)",2,function(s)
    state.godOn=s
    if s then local h=GetHum(LP); if h then h.MaxHealth=math.huge; h.Health=math.huge end end
    Notify(s and "God Mode ON 🛡️" or "God Mode OFF", s and C.ok or C.err)
end)

SecHeader(PlayPage,"Speed & Jump",10)
local spdLbl=InfoLbl(PlayPage,"WalkSpeed: 16",C.tSec,11)
local jmpLbl=InfoLbl(PlayPage,"JumpPower:  50",C.tSec,12)

local function SpeedRow(parent, lbl, order, delta, isJump)
    local F=Instance.new("Frame"); F.BackgroundTransparency=1; F.BorderSizePixel=0
    F.Size=UDim2.new(1,0,0,40); F.LayoutOrder=order; F.Parent=parent
    pad(F,4,4,18,18)
    listL(F,Enum.FillDirection.Horizontal,6)

    local function Mk(txt,col,fn)
        local B=Instance.new("TextButton"); B.BackgroundColor3=col; B.BorderSizePixel=0
        B.Size=UDim2.new(0.3,0,1,0); B.ZIndex=5; B.Font=Enum.Font.GothamSemibold
        B.Text=txt; B.TextColor3=C.tPri; B.TextSize=11; B.Parent=F; corner(B,7)
        B.MouseButton1Click:Connect(fn)
    end
    Mk("+"..(isJump and "25" or "10"), Color3.fromRGB(38,85,170), function()
        if isJump then state.jmpVal=state.jmpVal+25; local h=GetHum(LP); if h then h.JumpPower=state.jmpVal end; jmpLbl.Text="JumpPower:  "..state.jmpVal
        else state.spdVal=state.spdVal+10; local h=GetHum(LP); if h then h.WalkSpeed=state.spdVal end; spdLbl.Text="WalkSpeed: "..state.spdVal end
    end)
    Mk("-"..(isJump and "25" or "10"), Color3.fromRGB(55,45,80), function()
        if isJump then state.jmpVal=math.max(0,state.jmpVal-25); local h=GetHum(LP); if h then h.JumpPower=state.jmpVal end; jmpLbl.Text="JumpPower:  "..state.jmpVal
        else state.spdVal=math.max(2,state.spdVal-10); local h=GetHum(LP); if h then h.WalkSpeed=state.spdVal end; spdLbl.Text="WalkSpeed: "..state.spdVal end
    end)
    Mk("Reset", Color3.fromRGB(40,38,52), function()
        if isJump then state.jmpVal=50; local h=GetHum(LP); if h then h.JumpPower=50 end; jmpLbl.Text="JumpPower:  50"
        else state.spdVal=16; local h=GetHum(LP); if h then h.WalkSpeed=16 end; spdLbl.Text="WalkSpeed: 16" end
    end)
end
SpeedRow(PlayPage,"Speed",13,10,false)
SpeedRow(PlayPage,"Jump",14,25,true)

SecHeader(PlayPage,"Fling",20)
local fInput=InputRow(PlayPage,"🔍  Type player name...",21)
ActBtn(PlayPage,"🌀  Fling Selected",Color3.fromRGB(195,85,30),22,function()
    local t=FindPlayer(fInput.Text); if not t then Notify("Player not found.",C.warn); return end
    task.spawn(FlingOne,t); Notify("Flinging "..t.Name.." 🌀",C.orange)
end)
ActBtn(PlayPage,"💥  Fling ALL",Color3.fromRGB(175,45,45),23,function()
    task.spawn(FlingAll); Notify("Flinging all players! 💥",C.err)
end)

SecHeader(PlayPage,"Player List",30)
local plrListLbl=InfoLbl(PlayPage,"Tap Refresh to load list.",C.tDim,31)
plrListLbl.TextWrapped=true; plrListLbl.AutomaticSize=Enum.AutomaticSize.Y
ActBtn(PlayPage,"🔄  Refresh List",Color3.fromRGB(35,35,42),32,function()
    local t={}; for _,p in ipairs(Players:GetPlayers()) do
        local tag=p==LP and "★ " or "• "
        table.insert(t,tag..p.Name..(p.DisplayName~=p.Name and " ("..p.DisplayName..")" or ""))
    end; plrListLbl.Text=table.concat(t,"\n")
end)

-- ══════════════════════════════════════════════════════════════
--   VISUALS PAGE
-- ══════════════════════════════════════════════════════════════
pad(VisuPage,0,8,0,0)
if not DrawOK then
    local wF=Instance.new("Frame"); wF.BackgroundColor3=Color3.fromRGB(60,30,30); wF.BorderSizePixel=0
    wF.Size=UDim2.new(1,0,0,36); wF.LayoutOrder=0; wF.Parent=VisuPage; corner(wF,8); pad(wF,0,0,14,14)
    local wL=Instance.new("TextLabel"); wL.BackgroundTransparency=1; wL.Size=UDim2.new(1,0,1,0); wL.ZIndex=5
    wL.Font=Enum.Font.GothamSemibold; wL.Text="⚠  No Drawing API — use a trusted executor for ESP/Tracers"
    wL.TextColor3=C.err; wL.TextSize=11; wL.TextWrapped=true; wL.TextXAlignment=Enum.TextXAlignment.Left; wL.Parent=wF
end

SecHeader(VisuPage,"ESP  (Drawing API)",1)
TogRow(VisuPage,"ESP Boxes + Names",2,function(s)
    state.espOn=s
    if s then for _,p in ipairs(Players:GetPlayers()) do InitESP(p) end; Notify("ESP ON 🔷",C.ok)
    else Notify("ESP OFF",C.err) end
end)
TogRow(VisuPage,"Show HP Bar",3,function(s) state.showHP=s end)
TogRow(VisuPage,"Show Distance",4,function(s) state.showDist=s end)

SecHeader(VisuPage,"Tracers",10)
TogRow(VisuPage,"Tracers to All Players",11,function(s)
    state.tracerOn=s
    if s then for _,p in ipairs(Players:GetPlayers()) do InitESP(p) end; Notify("Tracers ON 🔶",C.ok)
    else Notify("Tracers OFF",C.err) end
end)

SecHeader(VisuPage,"Chams",20)
TogRow(VisuPage,"Player Chams (SelectionBox)",21,function(s)
    state.chamOn=s
    if s then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character and not ChamData[p] then
                local sel=Instance.new("SelectionBox"); sel.Adornee=p.Character
                sel.Color3=ESPCol(p); sel.LineThickness=0.05; sel.SurfaceTransparency=0.72
                sel.SurfaceColor3=ESPCol(p); sel.Parent=CoreGui; ChamData[p]=sel
            end
        end
        Notify("Chams ON ✨",C.ok)
    else KillAllChams(); Notify("Chams OFF",C.err) end
end)

SecHeader(VisuPage,"Environment",30)
TogRow(VisuPage,"Fullbright",31,function(s)
    state.fullbrite=s; Lighting.Brightness=s and 6 or 1; if s then Lighting.ClockTime=14 end
    Notify(s and "Fullbright ON ☀️" or "Fullbright OFF 🌙", s and C.gold or C.tSec)
end)
TogRow(VisuPage,"Custom Crosshair",32,function(s)
    state.xhairOn=s
    -- Crosshair created below
end)

-- FOV Circle
local FOVCirc=Instance.new("Frame"); FOVCirc.BackgroundTransparency=1; FOVCirc.AnchorPoint=Vector2.new(0.5,0.5)
FOVCirc.Position=UDim2.new(0.5,0,0.5,0); FOVCirc.Size=UDim2.new(0,180,0,180)
FOVCirc.ZIndex=50; FOVCirc.Visible=false; FOVCirc.Parent=Gui
corner(FOVCirc,999); stroke(FOVCirc,C.togOn,1.5)
TogRow(VisuPage,"FOV Circle",33,function(s) FOVCirc.Visible=s end)

-- Crosshair
local CrH=Instance.new("Frame"); CrH.BackgroundColor3=Color3.fromRGB(210,55,55); CrH.BorderSizePixel=0
CrH.AnchorPoint=Vector2.new(0.5,0.5); CrH.Position=UDim2.new(0.5,0,0.5,0); CrH.Size=UDim2.new(0,20,0,2); CrH.ZIndex=55; CrH.Visible=false; CrH.Parent=Gui; corner(CrH,99)
local CrV=Instance.new("Frame"); CrV.BackgroundColor3=Color3.fromRGB(210,55,55); CrV.BorderSizePixel=0
CrV.AnchorPoint=Vector2.new(0.5,0.5); CrV.Position=UDim2.new(0.5,0,0.5,0); CrV.Size=UDim2.new(0,2,0,20); CrV.ZIndex=55; CrV.Visible=false; CrV.Parent=Gui; corner(CrV,99)
RunSvc.RenderStepped:Connect(function() CrH.Visible=state.xhairOn; CrV.Visible=state.xhairOn end)

-- ══════════════════════════════════════════════════════════════
--   NDS PAGE  (only if in Natural Disaster Survival)
-- ══════════════════════════════════════════════════════════════
if IS_NDS and NDSPage then
    pad(NDSPage,0,8,0,0)

    SecHeader(NDSPage,"Current Disaster",1)
    local disasterDisplay=InfoLbl(NDSPage,"Disaster: Detecting...",C.warn,2)
    disasterDisplay.Font=Enum.Font.GothamSemibold; disasterDisplay.TextSize=13

    -- Auto-refresh disaster label every 2s
    task.spawn(function()
        while Gui.Parent do
            task.wait(2)
            pcall(function()
                local d=GetDisaster()
                local col= d=="None / Waiting" and C.tDim or C.warn
                disasterDisplay.Text="Disaster: "..d
                disasterDisplay.TextColor3=col
            end)
        end
    end)

    ActBtn(NDSPage,"🔍  Detect Disaster Now",Color3.fromRGB(38,85,155),3,function()
        local d=GetDisaster(); disasterDisplay.Text="Disaster: "..d
        disasterDisplay.TextColor3= d=="None / Waiting" and C.tDim or C.warn
        Notify("Detected: "..d,C.warn)
    end)

    SecHeader(NDSPage,"Auto Survive",10)
    TogRow(NDSPage,"Auto Safe  (stay above Y = 280)",11,function(s)
        state.ndsAuto=s; Notify(s and "Auto Survive ON ☁️" or "Auto Survive OFF",s and C.ok or C.err)
    end)

    SecHeader(NDSPage,"Teleport Tools",20)
    ActBtn(NDSPage,"☁️  Teleport to Sky  (Y = 320)",Color3.fromRGB(60,110,200),21,function()
        local r=GetRoot(LP); if r then pcall(function() r.CFrame=CFrame.new(r.Position.X,320,r.Position.Z) end); Notify("Sky teleport! ☁️",C.sky) end
    end)
    ActBtn(NDSPage,"🏠  Map Center  (0, 320, 0)",Color3.fromRGB(48,88,160),22,function()
        local r=GetRoot(LP); if r then pcall(function() r.CFrame=CFrame.new(0,320,0) end); Notify("Map center! 🏠",C.sky) end
    end)
    ActBtn(NDSPage,"🏔  Go to Highest Platform",Color3.fromRGB(150,115,30),23,function()
        local r=GetRoot(LP); if not r then return end
        local best=80
        pcall(function()
            for _,p in ipairs(workspace:GetDescendants()) do
                if p:IsA("BasePart") and p.Size.X>4 and p.Size.Z>4
                    and not(LP.Character and p:IsDescendantOf(LP.Character)) then
                    if p.Position.Y>best then best=p.Position.Y end
                end
            end
        end)
        pcall(function() r.CFrame=CFrame.new(r.Position.X,best+6,r.Position.Z) end)
        Notify("Highest platform ≈ Y"..math.floor(best),C.gold)
    end)
    ActBtn(NDSPage,"⬆  Jump Above Disaster (+100)",Color3.fromRGB(195,120,30),24,function()
        local r=GetRoot(LP); if r then pcall(function() r.CFrame=CFrame.new(r.Position+Vector3.new(0,100,0)) end); Notify("+100 studs! ⬆",C.orange) end
    end)

    SecHeader(NDSPage,"One-Click Pack",30)
    ActBtn(NDSPage,"🌟  SURVIVAL PACK  (God + Fly + Noclip)",Color3.fromRGB(160,130,20),31,function()
        state.godOn=true; state.noclipOn=true; state.flyOn=true; state.ndsAuto=true
        local h=GetHum(LP); if h then h.MaxHealth=math.huge; h.Health=math.huge; h.WalkSpeed=50 end
        Notify("Survival Pack ON! 🌟 God+Fly+Noclip+AutoSafe",C.gold)
    end)
    ActBtn(NDSPage,"❌  Reset All NDS",Color3.fromRGB(45,38,65),32,function()
        state.godOn=false; state.flyOn=false; state.noclipOn=false; state.ndsAuto=false
        local h=GetHum(LP); if h then h.MaxHealth=100; h.Health=100; h.WalkSpeed=16 end
        state.spdVal=16; spdLbl.Text="WalkSpeed: 16"
        Notify("NDS reset.",C.tSec)
    end)
end

-- ══════════════════════════════════════════════════════════════
--   MISC PAGE
-- ══════════════════════════════════════════════════════════════
pad(MiscPage,0,8,0,0)

SecHeader(MiscPage,"Movement",1)
TogRow(MiscPage,"👻  Noclip",2,function(s) state.noclipOn=s; Notify(s and "Noclip ON 👻" or "Noclip OFF",s and C.ok or C.err) end)
TogRow(MiscPage,"🚀  Flight  (WASD + Space / Ctrl)",3,function(s) state.flyOn=s; Notify(s and "Flight ON 🚀" or "Flight OFF",s and C.ok or C.err) end)
TogRow(MiscPage,"🦘  Infinite Jump",4,function(s) state.infJump=s; Notify(s and "Infinite Jump ON 🦘" or "Infinite Jump OFF",s and C.ok or C.err) end)

SecHeader(MiscPage,"Fling Yourself",10)
TogRow(MiscPage,"🌀  Self Spin Fling (like Infinite Yield)",11,function(s) state.selfSpin=s; Notify(s and "Spin Fling ON 🌀" or "Spin OFF",s and C.ok or C.err) end)

SecHeader(MiscPage,"Appearance",20)
TogRow(MiscPage,"🫥  Invisible (Local only)",21,function(s)
    state.invisOn=s
    if LP.Character then
        for _,p in ipairs(LP.Character:GetDescendants()) do
            if p:IsA("BasePart") or p:IsA("Decal") then p.LocalTransparencyModifier=s and 1 or 0 end
        end
    end
    Notify(s and "Invisible 🫥" or "Visible again",s and C.ok or C.err)
end)
ActBtn(MiscPage,"🔄  Respawn Self",Color3.fromRGB(38,85,155),22,function() LP:LoadCharacter(); Notify("Respawning...",C.togOn) end)

SecHeader(MiscPage,"Time of Day",30)
local timeRow=Instance.new("Frame"); timeRow.BackgroundTransparency=1; timeRow.BorderSizePixel=0
timeRow.Size=UDim2.new(1,0,0,42); timeRow.LayoutOrder=31; timeRow.Parent=MiscPage
pad(timeRow,5,5,18,18); listL(timeRow,Enum.FillDirection.Horizontal,6)
local function TBtn(lbl,col,hr)
    local B=Instance.new("TextButton"); B.BackgroundColor3=col; B.BorderSizePixel=0
    B.Size=UDim2.new(0.3,0,1,0); B.ZIndex=5; B.Font=Enum.Font.GothamSemibold
    B.Text=lbl; B.TextColor3=C.tPri; B.TextSize=11; B.Parent=timeRow; corner(B,7)
    B.MouseButton1Click:Connect(function() Lighting.ClockTime=hr; Notify("Time → "..hr..":00",C.gold) end)
end
TBtn("☀️ Day",Color3.fromRGB(180,130,25),12)
TBtn("🌅 Sunset",Color3.fromRGB(170,80,25),18)
TBtn("🌙 Night",Color3.fromRGB(28,28,60),0)

-- ══════════════════════════════════════════════════════════════
--   ACTIVATE DASHBOARD BY DEFAULT
-- ══════════════════════════════════════════════════════════════
Pages["Dashboard"].Page.Visible=true; ActivePage="Dashboard"
tw(Pages["Dashboard"].Btn,0,{BackgroundTransparency=0, BackgroundColor3=C.navAct})
Pages["Dashboard"].Ic.TextColor3=C.tPri; Pages["Dashboard"].Lbl.TextColor3=C.tPri

-- ══════════════════════════════════════════════════════════════
--   MINIMIZE / CIRCLE BUTTON
-- ══════════════════════════════════════════════════════════════
local MinBtn=Instance.new("TextButton")
MinBtn.AnchorPoint=Vector2.new(0,1); MinBtn.BackgroundColor3=Color3.fromRGB(30,30,35)
MinBtn.BorderSizePixel=0; MinBtn.Position=UDim2.new(0,16,1,-16)
MinBtn.Size=UDim2.new(0,52,0,52); MinBtn.ZIndex=60; MinBtn.Font=Enum.Font.GothamBold
MinBtn.Text="🌸"; MinBtn.TextSize=22; MinBtn.Visible=false; MinBtn.Parent=Gui
corner(MinBtn,999); local minSK=stroke(MinBtn,Color3.fromRGB(80,120,230),2)

local MinTip=Instance.new("TextLabel"); MinTip.BackgroundColor3=C.card; MinTip.BorderSizePixel=0
MinTip.AnchorPoint=Vector2.new(0,0.5); MinTip.Size=UDim2.new(0,100,0,24); MinTip.ZIndex=61
MinTip.Font=Enum.Font.GothamSemibold; MinTip.Text="Open Luna"; MinTip.TextColor3=C.tPri; MinTip.TextSize=11
MinTip.Visible=false; MinTip.Parent=Gui; corner(MinTip,6); stroke(MinTip,C.border,1)
MinBtn.MouseEnter:Connect(function()
    if MinBtn.Visible then
        MinTip.Position=UDim2.new(0,MinBtn.Position.X.Offset+60,0,MinBtn.Position.Y.Offset-26)
        MinTip.Visible=true
    end
end)
MinBtn.MouseLeave:Connect(function() MinTip.Visible=false end)
task.spawn(function()
    while Gui.Parent do
        task.wait(0.3)
        if MinBtn.Visible then
            TwnSvc:Create(minSK,TweenInfo.new(0.9,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Transparency=0.65}):Play(); break
        end
    end
end)

-- Open / Close panel
local function OpenPanel()
    MinBtn.Visible=false; MinTip.Visible=false; Win.Visible=true
    Win.Size=UDim2.new(0,0,0,0)
    TwnSvc:Create(Win,TweenInfo.new(0.42,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,720,0,488)}):Play()
end
local function ClosePanel()
    MinTip.Visible=false
    TwnSvc:Create(Win,TweenInfo.new(0.28,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0)}):Play()
    task.wait(0.3); Win.Visible=false; MinBtn.Visible=true
end

-- Close button (top-right dot cluster → red dot click)
-- The red dot in top-right closes the window
-- We'll also add a dedicated close X in the top-left of topbar area
local CloseX=Instance.new("TextButton"); CloseX.BackgroundTransparency=1; CloseX.BorderSizePixel=0
CloseX.AnchorPoint=Vector2.new(0,0.5); CloseX.Position=UDim2.new(0,200,0,19)
CloseX.Size=UDim2.new(0,28,0,28); CloseX.ZIndex=10; CloseX.Font=Enum.Font.GothamBold
CloseX.Text=""; CloseX.TextColor3=C.tDim; CloseX.TextSize=14; CloseX.Parent=Win
-- Actually make the red dot (first in iconRow) the close trigger
-- Let's repurpose the top-right area: clicking the red dot closes
-- We need to grab the red dot from iconRow. Let's add a standalone close button overlaid on Win title area
local function AddCloseAndMin()
    -- Invisible close trigger over the leftmost visible area of topbar
    -- We'll use the sidebar drag + a right-click or small X on sidebar logo
    local XBtn=Instance.new("TextButton"); XBtn.BackgroundColor3=Color3.fromRGB(200,60,60)
    XBtn.BorderSizePixel=0; XBtn.AnchorPoint=Vector2.new(1,0.5)
    XBtn.Position=UDim2.new(1,-10,0,19); XBtn.Size=UDim2.new(0,22,0,22); XBtn.ZIndex=10
    XBtn.Font=Enum.Font.GothamBold; XBtn.Text="✕"; XBtn.TextColor3=Color3.new(1,1,1); XBtn.TextSize=11
    XBtn.Parent=TopBar; corner(XBtn,99)
    XBtn.MouseButton1Click:Connect(function() task.spawn(ClosePanel) end)
    XBtn.MouseEnter:Connect(function() tw(XBtn,0.1,{BackgroundColor3=Color3.fromRGB(230,75,75)}) end)
    XBtn.MouseLeave:Connect(function() tw(XBtn,0.1,{BackgroundColor3=Color3.fromRGB(200,60,60)}) end)
end
AddCloseAndMin()
MinBtn.MouseButton1Click:Connect(function() if not minDragMoved then OpenPanel() end end)

-- ══════════════════════════════════════════════════════════════
--   DRAG — Window + MinBtn
-- ══════════════════════════════════════════════════════════════
local winDrag,winStart,winStartPos=false,nil,nil
local minDrag,minDragStart,minBtnStartPos=false,nil,nil
local minDragMoved=false
local MIN_THRESH=8

TopBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        winDrag=true; winStart=i.Position; winStartPos=Win.Position
    end
end)
MinBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        minDrag=true; minDragMoved=false; minDragStart=i.Position; minBtnStartPos=MinBtn.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
    if winDrag then
        local d=i.Position-winStart
        Win.Position=UDim2.new(winStartPos.X.Scale,winStartPos.X.Offset+d.X,winStartPos.Y.Scale,winStartPos.Y.Offset+d.Y)
    end
    if minDrag then
        local d=i.Position-minDragStart
        if d.Magnitude>MIN_THRESH then
            minDragMoved=true; MinTip.Visible=false
            MinBtn.Position=UDim2.new(minBtnStartPos.X.Scale,minBtnStartPos.X.Offset+d.X,minBtnStartPos.Y.Scale,minBtnStartPos.Y.Offset+d.Y)
        end
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        winDrag=false; minDrag=false
    end
end)

-- ══════════════════════════════════════════════════════════════
--   PLAYER JOIN/LEAVE ESP
-- ══════════════════════════════════════════════════════════════
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.6)
        if state.espOn or state.tracerOn then InitESP(p) end
        if state.chamOn and p.Character then
            if not ChamData[p] then
                local sel=Instance.new("SelectionBox"); sel.Adornee=p.Character; sel.Color3=ESPCol(p)
                sel.LineThickness=0.05; sel.SurfaceTransparency=0.72; sel.SurfaceColor3=ESPCol(p); sel.Parent=CoreGui; ChamData[p]=sel
            end
        end
    end)
end)

-- ══════════════════════════════════════════════════════════════
--   LOADING SEQUENCE → REVEAL MAIN UI
-- ══════════════════════════════════════════════════════════════
task.spawn(function()
    task.wait(2.6)
    -- Fade out loading card
    TwnSvc:Create(LoadCard,TweenInfo.new(0.3,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
        BackgroundTransparency=1, Size=UDim2.new(0,260,0,0)
    }):Play()
    TwnSvc:Create(LoadBG,TweenInfo.new(0.45,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
        BackgroundTransparency=1
    }):Play()
    task.wait(0.5)
    pcall(function() LoadGui:Destroy() end)

    -- Show main UI with open anim
    Gui.Enabled=true
    Win.Size=UDim2.new(0,0,0,0)
    TwnSvc:Create(Win,TweenInfo.new(0.5,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,720,0,488)
    }):Play()
    task.wait(0.55)
    Notify("🌸 Luna Admin V3 loaded!  Hey, "..LP.Name, C.togOn)
    if not DrawOK then task.wait(0.9); Notify("⚠️  No Drawing API — ESP requires trusted executor",C.err) end
    if IS_NDS then task.wait(0.5); Notify("🌋 NDS game detected! NDS tab available.",C.gold) end
end)

print("[LunaAdmin V3 Reimagined] Loaded for: "..LP.Name)
