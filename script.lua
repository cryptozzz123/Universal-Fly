-- Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local cam = workspace.CurrentCamera

local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	root = c:WaitForChild("HumanoidRootPart")
end)

------------------------------------------------
-- WINDOW
------------------------------------------------

local Window = Rayfield:CreateWindow({
	Name = "Universal Fly | FAHFAHFAHFAH50",
	LoadingTitle = "Universal Hub",
	LoadingSubtitle = "Loading...",
	ConfigurationSaving = {Enabled = false}
})

local Tab = Window:CreateTab("Main",4483362458)

------------------------------------------------
-- WALKSPEED
------------------------------------------------

Tab:CreateInput({
	Name = "Set WalkSpeed",
	PlaceholderText = "Enter Speed",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local n = tonumber(text)
		if n then
			hum.WalkSpeed = n
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

Tab:CreateInput({
	Name = "Fly Speed",
	PlaceholderText = "Enter Fly Speed",
	RemoveTextAfterFocusLost = false,
	Callback = function(text)
		local n=tonumber(text)
		if n then speed=n end
	end
})

Tab:CreateToggle({
	Name="Toggle Fly",
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

		local dir=
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

Tab:CreateToggle({
	Name="ESP",
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
						if v:IsA("Highlight") then v:Destroy() end
					end

				end

			end
		end

	end
})
