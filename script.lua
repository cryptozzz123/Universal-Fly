-- Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

------------------------------------------------
-- GAME CHECK
------------------------------------------------

local GAME_ID = 205224386 -- Hide and Seek Extreme

if game.PlaceId ~= GAME_ID then
	Rayfield:Notify({
		Title="Wrong Game",
		Content="This hub only works in Hide and Seek Extreme",
		Duration=6
	})
	return
end

------------------------------------------------
-- CHARACTER
------------------------------------------------

local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(c)
	char=c
	hum=c:WaitForChild("Humanoid")
	root=c:WaitForChild("HumanoidRootPart")
end)

------------------------------------------------
-- WINDOW
------------------------------------------------

local Window = Rayfield:CreateWindow({
	Name="Universal Fly | FAHFAHFAHFAH50",
	LoadingTitle="Universal Hub",
	LoadingSubtitle="Loading...",
	ConfigurationSaving={Enabled=false}
})

local Main = Window:CreateTab("Main",4483362458)
local HSE = Window:CreateTab("Hide and Seek Extreme",4483362458)

------------------------------------------------
-- WALKSPEED
------------------------------------------------

Main:CreateInput({
	Name="WalkSpeed",
	PlaceholderText="Enter Speed",
	Callback=function(v)
		local n=tonumber(v)
		if n then hum.WalkSpeed=n end
	end
})

------------------------------------------------
-- JUMP POWER
------------------------------------------------

Main:CreateInput({
	Name="JumpPower",
	PlaceholderText="Enter JumpPower",
	Callback=function(v)
		local n=tonumber(v)
		if n then hum.JumpPower=n end
	end
})

------------------------------------------------
-- TRACERS
------------------------------------------------

local tracer=false
local lines={}

Main:CreateToggle({
	Name="Tracers",
	CurrentValue=false,
	Callback=function(v)
		tracer=v
	end
})

RunService.RenderStepped:Connect(function()

	for _,p in pairs(Players:GetPlayers()) do

		if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then

			if not lines[p] then

				lines[p]={
					line=Drawing.new("Line"),
					text=Drawing.new("Text")
				}

				lines[p].line.Color=Color3.fromRGB(0,255,0)
				lines[p].line.Thickness=1

				lines[p].text.Size=13
				lines[p].text.Color=Color3.fromRGB(0,255,0)

			end

			local pos,vis=cam:WorldToViewportPoint(
				p.Character.HumanoidRootPart.Position
			)

			local dist=(root.Position-p.Character.HumanoidRootPart.Position).Magnitude

			if tracer and vis then

				lines[p].line.From=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y)
				lines[p].line.To=Vector2.new(pos.X,pos.Y)
				lines[p].line.Visible=true

				lines[p].text.Text=math.floor(dist).." studs"
				lines[p].text.Position=Vector2.new(pos.X,pos.Y)
				lines[p].text.Visible=true

			else

				lines[p].line.Visible=false
				lines[p].text.Visible=false

			end

		end

	end

end)

------------------------------------------------
-- FIND IT PLAYER
------------------------------------------------

local function getIT()

	for _,p in pairs(Players:GetPlayers()) do
		if p.Character and p.Character:FindFirstChild("IsSeeker") then
			return p
		end
	end

end

------------------------------------------------
-- ESP FUNCTIONS
------------------------------------------------

local function clearESP()

	for _,p in pairs(Players:GetPlayers()) do
		if p.Character then
			for _,v in pairs(p.Character:GetChildren()) do
				if v:IsA("Highlight") then
					v:Destroy()
				end
			end
		end
	end

end

------------------------------------------------
-- ESP PLAYERS
------------------------------------------------

HSE:CreateButton({
	Name="ESP Players",
	Callback=function()

		clearESP()

		local it=getIT()

		for _,p in pairs(Players:GetPlayers()) do

			if p~=it and p~=player and p.Character then

				local h=Instance.new("Highlight",p.Character)
				h.FillColor=Color3.fromRGB(0,255,0)

			end

		end

	end
})

------------------------------------------------
-- ESP IT
------------------------------------------------

HSE:CreateButton({
	Name="ESP IT",
	Callback=function()

		clearESP()

		local it=getIT()

		if it and it.Character then

			local h=Instance.new("Highlight",it.Character)
			h.FillColor=Color3.fromRGB(255,0,0)

		end

	end
})

------------------------------------------------
-- ESP ALL
------------------------------------------------

HSE:CreateButton({
	Name="ESP ALL",
	Callback=function()

		clearESP()

		for _,p in pairs(Players:GetPlayers()) do

			if p~=player and p.Character then

				local h=Instance.new("Highlight",p.Character)
				h.FillColor=Color3.fromRGB(0,255,0)

			end

		end

	end
})

------------------------------------------------
-- COLLECT COINS
------------------------------------------------

HSE:CreateButton({
	Name="Collect ALL Coins",
	Callback=function()

		local old=root.CFrame

		for _,v in pairs(workspace:GetDescendants()) do

			if v.Name=="Coin" and v:IsA("BasePart") then

				local tween=TweenService:Create(
					root,
					TweenInfo.new(0.3),
					{CFrame=v.CFrame}
				)

				tween:Play()
				tween.Completed:Wait()

			end

		end

		root.CFrame=old

	end
})

------------------------------------------------
-- FLING SYSTEM
------------------------------------------------

local function fling(target)

	if not target or not target.Character then return end

	local hrp=target.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local vel=Instance.new("BodyAngularVelocity")
	vel.AngularVelocity=Vector3.new(99999,99999,99999)
	vel.MaxTorque=Vector3.new(99999,99999,99999)
	vel.Parent=hrp

	task.wait(0.3)
	vel:Destroy()

end

------------------------------------------------
-- FLING IT
------------------------------------------------

HSE:CreateButton({
	Name="Fling IT",
	Callback=function()

		local it=getIT()
		if it then fling(it) end

	end
})

------------------------------------------------
-- FLING PLAYERS
------------------------------------------------

HSE:CreateButton({
	Name="Fling Players",
	Callback=function()

		local it=getIT()

		for _,p in pairs(Players:GetPlayers()) do
			if p~=player and p~=it then
				fling(p)
			end
		end

	end
})

------------------------------------------------
-- FLING ALL
------------------------------------------------

HSE:CreateButton({
	Name="Fling All",
	Callback=function()

		for _,p in pairs(Players:GetPlayers()) do
			if p~=player then
				fling(p)
			end
		end

	end
})

------------------------------------------------
-- FLING SNIPER
------------------------------------------------

HSE:CreateInput({
	Name="Fling Sniper (Username)",
	PlaceholderText="Enter Username",
	Callback=function(name)

		local target=Players:FindFirstChild(name)
		if target then
			fling(target)
		end

	end
})
