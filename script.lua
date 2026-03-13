local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

------------------------------------------------
-- Character
------------------------------------------------

local function getChar()
	local c = player.Character or player.CharacterAdded:Wait()
	local hum = c:WaitForChild("Humanoid")
	local root = c:WaitForChild("HumanoidRootPart")
	return c, hum, root
end

local char, hum, root = getChar()

player.CharacterAdded:Connect(function()
	char, hum, root = getChar()
end)

------------------------------------------------
-- Window
------------------------------------------------

local Window = Rayfield:CreateWindow({
	Name="Universal Fly Hub",
	LoadingTitle="Universal Hub",
	LoadingSubtitle="Loading",
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
-- FLY
------------------------------------------------

local flying=false
local speed=60
local bv,bg
local ctrl={f=0,b=0,l=0,r=0,u=0,d=0}

Main:CreateInput({
	Name="Fly Speed",
	PlaceholderText="Enter Fly Speed",
	Callback=function(v)
		local n=tonumber(v)
		if n then speed=n end
	end
})

Main:CreateToggle({
	Name="Fly",
	CurrentValue=false,
	Callback=function(v)

		flying=v

		if flying then
			bv=Instance.new("BodyVelocity",root)
			bv.MaxForce=Vector3.new(1e9,1e9,1e9)

			bg=Instance.new("BodyGyro",root)
			bg.MaxTorque=Vector3.new(1e9,1e9,1e9)
		else
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
		end

	end
})

UIS.InputBegan:Connect(function(k,g)
	if g then return end
	if k.KeyCode==Enum.KeyCode.W then ctrl.f=1 end
	if k.KeyCode==Enum.KeyCode.S then ctrl.b=-1 end
	if k.KeyCode==Enum.KeyCode.A then ctrl.l=-1 end
	if k.KeyCode==Enum.KeyCode.D then ctrl.r=1 end
	if k.KeyCode==Enum.KeyCode.Space then ctrl.u=1 end
	if k.KeyCode==Enum.KeyCode.LeftControl then ctrl.d=-1 end
end)

UIS.InputEnded:Connect(function(k)
	if k.KeyCode==Enum.KeyCode.W then ctrl.f=0 end
	if k.KeyCode==Enum.KeyCode.S then ctrl.b=0 end
	if k.KeyCode==Enum.KeyCode.A then ctrl.l=0 end
	if k.KeyCode==Enum.KeyCode.D then ctrl.r=0 end
	if k.KeyCode==Enum.KeyCode.Space then ctrl.u=0 end
	if k.KeyCode==Enum.KeyCode.LeftControl then ctrl.d=0 end
end)

RunService.RenderStepped:Connect(function()

	if flying and bv then
		local dir =
		(cam.CFrame.LookVector*(ctrl.f+ctrl.b)) +
		(cam.CFrame.RightVector*(ctrl.r+ctrl.l)) +
		(cam.CFrame.UpVector*(ctrl.u+ctrl.d))

		bv.Velocity=dir*speed
		bg.CFrame=cam.CFrame
	end

end)

------------------------------------------------
-- SEEKER FINDER
------------------------------------------------

local function getSeeker()
	for _,p in pairs(Players:GetPlayers()) do
		if p.Team and p.Team.Name:lower():find("seeker") then
			return p
		end
	end
end

------------------------------------------------
-- SEEKER TRACKER
------------------------------------------------

local seekerESP

HSE:CreateToggle({
	Name="Seeker Tracker",
	CurrentValue=false,
	Callback=function(v)

		if seekerESP then
			seekerESP:Destroy()
			seekerESP=nil
		end

		if v then
			local s=getSeeker()

			if s and s.Character then
				seekerESP=Instance.new("Highlight")
				seekerESP.FillColor=Color3.fromRGB(255,0,0)
				seekerESP.Parent=s.Character
			end
		end

	end
})

------------------------------------------------
-- SAFE SPOT
------------------------------------------------

HSE:CreateButton({
	Name="Teleport Safe Spot",
	Callback=function()
		root.CFrame=CFrame.new(0,350,0)
	end
})

------------------------------------------------
-- AUTO COIN FARM (WORKING)
------------------------------------------------

local farming = false

local function getCoins()

	local coins = {}

	for _,v in pairs(workspace:GetDescendants()) do

		if v:IsA("BasePart") then

			if v.Name:lower():find("coin") 
			or v.Name:lower():find("gold") 
			or v.Name:lower():find("token") then

				table.insert(coins,v)

			end

		end

	end

	return coins

end


HSE:CreateToggle({
	Name="Auto Coin Farm",
	CurrentValue=false,
	Callback=function(v)

		farming=v

		while farming do

			local coins = getCoins()

			for _,coin in pairs(coins) do

				if coin and coin.Parent then

					root.CFrame = coin.CFrame + Vector3.new(0,3,0)
					task.wait(0.15)

				end

			end

			task.wait(1)

		end

	end
})
------------------------------------------------
-- SMOOTH FLING (Infinite Yield style)
------------------------------------------------

local function fling(target)

	if not target or not target.Character then return end

	local thrp = target.Character:FindFirstChild("HumanoidRootPart")
	if not thrp then return end

	local old = root.CFrame

	root.CFrame = thrp.CFrame * CFrame.new(0,0,2)

	local bav = Instance.new("BodyAngularVelocity")
	bav.AngularVelocity = Vector3.new(0,999999,0)
	bav.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bav.P = 100000
	bav.Parent = root

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = Vector3.new(0,0,0)
	bv.MaxForce = Vector3.new(9e9,9e9,9e9)
	bv.Parent = root

	task.wait(0.4)

	bav:Destroy()
	bv:Destroy()

	root.CFrame = old

end
