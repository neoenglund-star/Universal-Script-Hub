return function(WindUI, PlayerMovement)
    local FlyTab = PlayerMovement:Tab({
        Title = "Fly",
        Icon = "plane"
    })

    local flying = false
    local speed = 50  -- Default speed (IY uses multipliers like 1, but we'll adapt)

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    local lp = Players.LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    lp.CharacterAdded:Connect(function(c)
        char = c
        hrp = char:WaitForChild("HumanoidRootPart")
        humanoid = char:FindFirstChildOfClass("Humanoid")
    end)

    -- IY-style variables
    local FLYING = false
    local flyKeyDown, flyKeyUp
    local iyflyspeed = 1  -- Multiplier (IY default)

    local function sFLY(vfly)
        FLYING = true
        local plr = Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            repeat task.wait() until char:FindFirstChildOfClass("Humanoid")
            humanoid = char:FindFirstChildOfClass("Humanoid")
        end

        if flyKeyDown or flyKeyUp then
            flyKeyDown:Disconnect()
            flyKeyUp:Disconnect()
        end

        local T = hrp  -- HumanoidRootPart
        local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
        local SPEED = 0

        local function FLY()
            FLYING = true
            local BG = Instance.new('BodyGyro')
            local BV = Instance.new('BodyVelocity')
            BG.P = 9e4
            BG.Parent = T
            BV.Parent = T
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = T.CFrame
            BV.Velocity = Vector3.new(0, 0, 0)
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

            task.spawn(function()
                repeat task.wait()
                    local camera = workspace.CurrentCamera
                    if not vfly and humanoid then
                        humanoid.PlatformStand = true
                    end

                    if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                        SPEED = speed  -- Use your custom speed
                    elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                        SPEED = 0
                    end

                    if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                        BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                        lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                    elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                        BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                    else
                        BV.Velocity = Vector3.new(0, 0, 0)
                    end
                    BG.CFrame = camera.CFrame
                until not FLYING

                CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
                SPEED = 0
                BG:Destroy()
                BV:Destroy()

                if humanoid then humanoid.PlatformStand = false end
            end)
        end

        flyKeyDown = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            local mult = (vfly and 1 or iyflyspeed) * speed / 50  -- Scale to your speed var
            if input.KeyCode == Enum.KeyCode.W then
                CONTROL.F = mult
            elseif input.KeyCode == Enum.KeyCode.S then
                CONTROL.B = -mult
            elseif input.KeyCode == Enum.KeyCode.A then
                CONTROL.L = -mult
            elseif input.KeyCode == Enum.KeyCode.D then
                CONTROL.R = mult
            elseif input.KeyCode == Enum.KeyCode.E then
                CONTROL.Q = mult * 2
            elseif input.KeyCode == Enum.KeyCode.Q then
                CONTROL.E = -mult * 2
            end
        end)

        flyKeyUp = UserInputService.InputEnded:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.W then
                CONTROL.F = 0
            elseif input.KeyCode == Enum.KeyCode.S then
                CONTROL.B = 0
            elseif input.KeyCode == Enum.KeyCode.A then
                CONTROL.L = 0
            elseif input.KeyCode == Enum.KeyCode.D then
                CONTROL.R = 0
            elseif input.KeyCode == Enum.KeyCode.E then
                CONTROL.Q = 0
            elseif input.KeyCode == Enum.KeyCode.Q then
                CONTROL.E = 0
            end
        end)

        FLY()
    end

    local function NOFLY()
        FLYING = false
        if flyKeyDown or flyKeyUp then 
            flyKeyDown:Disconnect() 
            flyKeyUp:Disconnect() 
        end
        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    FlyTab:Toggle({
        Title = "Fly",
        Callback = function(v)
            if v then
                NOFLY()  -- Clean previous
                task.wait()
                sFLY()   -- Use IY logic (normal fly)
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
                iyflyspeed = n / 50  -- Keep multiplier in sync
            end
        end
    })
end
