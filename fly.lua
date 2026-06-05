return function(WindUI, PlayerMovement)

	local FlyTab = PlayerMovement:Tab({
		Title = "Fly",
		Icon = "plane"
	})

	local flying = false
	local speed = 50

	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")

	local lp = Players.LocalPlayer
	local char = lp.Character or lp.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")

	lp.CharacterAdded:Connect(function(c)
		char = c
		hrp = char:WaitForChild("HumanoidRootPart")
	end)

	local function startFly()
		flying = true

		local bg = Instance.new("BodyGyro")
		local bv = Instance.new("BodyVelocity")

		bg.P = 9e4
		bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
		bg.CFrame = hrp.CFrame
		bg.Parent = hrp

		bv.MaxForce = Vector3.new(9e9,9e9,9e9)
		bv.Parent = hrp

		RunService.RenderStepped:Connect(function()
			if not flying then return end

			local cam = workspace.CurrentCamera
			local dir = Vector3.zero

			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

			if dir.Magnitude > 0 then
				bv.Velocity = dir.Unit * speed
			else
				bv.Velocity = Vector3.zero
			end

			bg.CFrame = cam.CFrame
		end)
	end

	local function stopFly()
		flying = false
	end

	FlyTab:Toggle({
		Title = "Fly",
		Callback = function(v)
			if v then startFly() else stopFly() end
		end
	})

	FlyTab:Input({
		Title = "Speed",
		Callback = function(v)
			local n = tonumber(v)
			if n then speed = n end
		end
	})

end
