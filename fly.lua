return function(WindUI, PlayerMovement)
    local FlyTab = PlayerMovement:Tab({
        Title = "Fly",
        Icon = "plane"
    })

    local flying = false
    local speed = 50  -- This will control iyflyspeed multiplier

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")

    local lp = Players.LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    lp.CharacterAdded:Connect(function(c)
        char = c
        hrp = c:WaitForChild("HumanoidRootPart")
        humanoid = c:FindFirstChildOfClass("Humanoid")
    end)

    -- IY Variables
    local FLYING = false
    local QEfly = true
    local iyflyspeed = 1
    local flyKeyDown, flyKeyUp

    local function getRoot(char)
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    end

    local function sFLY(vfly)
        if flyKeyDown or flyKeyUp then
            pcall(function() flyKeyDown:Disconnect() end)
            pcall(function() flyKeyUp:Disconnect() end)
        end

        local plr = Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local T = getRoot(char)

        if not T then return end

        local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        local SPEED = 0

        local function FLY()
            FLYING = true
            local BG = Instance.new("BodyGyro")
            local BV = Instance.new("BodyVelocity")
            BG.P = 9e4
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = T.CFrame
            BG.Parent = T
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BV.Parent = T

            task.spawn(function()
                repeat task.wait()
                    local camera = workspace.CurrentCamera
                    if not vfly and humanoid then
                        humanoid.PlatformStand = true
                    end

                    if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                        SPEED = speed
                    elseif SPEED ~= 0 then
                        SPEED = 0
                    end

                    if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                        BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + 
                                      (camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).Position - camera.CFrame.Position)) * SPEED
                        lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                    elseif SPEED ~= 0 then
                        BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + 
                                      (camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).Position - camera.CFrame.Position)) * SPEED
                    else
                        BV.Velocity = Vector3.zero
                    end

                    BG.CFrame = camera.CFrame
                until not FLYING

                BG:Destroy()
                BV:Destroy()
                if humanoid then humanoid.PlatformStand = false end
            end)
        end

        flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            local mult = vfly and 1 or iyflyspeed
            if input.KeyCode == Enum.KeyCode.W then
                CONTROL.F = mult
            elseif input.KeyCode == Enum.KeyCode.S then
                CONTROL.B = -mult
            elseif input.KeyCode == Enum.KeyCode.A then
                CONTROL.L = -mult
            elseif input.KeyCode == Enum.KeyCode.D then
                CONTROL.R = mult
            elseif input.KeyCode == Enum.KeyCode.E and QEfly then
                CONTROL.Q = mult * 2
            elseif input.KeyCode == Enum.KeyCode.Q and QEfly then
                CONTROL.E = -mult * 2
            end
        end)

        flyKeyUp = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then CONTROL.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then CONTROL.B = 0
            elseif input.KeyCode == Enum.KeyCode.A then CONTROL.L = 0
            elseif input.KeyCode == Enum.KeyCode.D then CONTROL.R = 0
            elseif input.KeyCode == Enum.KeyCode.E then CONTROL.Q = 0
            elseif input.KeyCode == Enum.KeyCode.Q then CONTROL.E = 0
            end
        end)

        FLY()
    end

    local function NOFLY()
        FLYING = false
        if flyKeyDown then flyKeyDown:Disconnect() end
        if flyKeyUp then flyKeyUp:Disconnect() end
        flyKeyDown = nil
        flyKeyUp = nil

        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    FlyTab:Toggle({
        Title = "Fly",
        Callback = function(v)
            flying = v
            if v then
                NOFLY()
                task.wait()
                sFLY(false)  -- normal fly
            else
                NOFLY()
            end
        end
    })

    FlyTab:Input({
        Title = "Speed",
        Callback = function(v)
            local n = tonumber(v)
            if n then
                speed = n
                iyflyspeed = n / 50  -- IY internal scaling
            end
        end
    })
end
