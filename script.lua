local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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
-- WINDOW
------------------------------------------------

local Window = Rayfield:CreateWindow({
	Name="Universal Main Hub",
	LoadingTitle="Universal Hub",
	LoadingSubtitle="Loading...",
	ConfigurationSaving={Enabled=false}
})

local Main = Window:CreateTab("Main",4483362458)

------------------------------------------------
-- WALKSPEED
------------------------------------------------

Main:CreateInput({
	Name="Set WalkSpeed",
	PlaceholderText="Enter Speed",
	Callback=function(v)
		local n = tonumber(v)
		if n then
			hum.WalkSpeed = n
		end
	end
})

------------------------------------------------
-- JUMP POWER
------------------------------------------------

Main:CreateInput({
	Name="Set JumpPower",
	PlaceholderText="Enter JumpPower",
	Callback=function(v)
		local n = tonumber(v)
		if n then
			hum.JumpPower = n
		end
	end
})

------------------------------------------------
-- FLY
------------------------------------------------

local flying = false
local speed = 60
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
		(cam.CFrame.LookVector*(ctrl.f+ctrl.b))+
		(cam.CFrame.RightVector*(ctrl.r+ctrl.l))+
		(cam.CFrame.UpVector*(ctrl.u+ctrl.d))

		bv.Velocity=dir*speed
		bg.CFrame=cam.CFrame

	end

end)

------------------------------------------------
-- ESP
------------------------------------------------

local esp=false

Main:CreateToggle({
	Name="Player ESP",
	CurrentValue=false,
	Callback=function(v)

		esp=v

		for _,p in pairs(Players:GetPlayers()) do

			if p~=player and p.Character then

				if esp then

					local h=Instance.new("Highlight",p.Character)
					h.FillColor=Color3.fromRGB(0,255,0)

				else

					for _,v in pairs(p.Character:GetChildren()) do
						if v:IsA("Highlight") then
							v:Destroy()
						end
					end

				end

			end

		end

	end
})

------------------------------------------------
-- TRACERS
------------------------------------------------

local tracer=false
local lines={}

Main:CreateToggle({
	Name="Player Tracers",
	CurrentValue=false,
	Callback=function(v)
		tracer=v
	end
})

RunService.RenderStepped:Connect(function()

	for _,p in pairs(Players:GetPlayers()) do

		if p~=player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then

			if not lines[p] then

				lines[p]={line=Drawing.new("Line"),text=Drawing.new("Text")}

				lines[p].line.Color=Color3.fromRGB(0,255,0)
				lines[p].text.Size=13
				lines[p].text.Color=Color3.fromRGB(0,255,0)

			end

			local pos,vis=cam:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)

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
