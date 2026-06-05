return function(WindUI, PlayerMovement)
    local SpeedTab = PlayerMovement:Tab({
        Title = "Speed",
        Icon = "gauge"
    })

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local lp = Players.LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    local defaultSpeed = 16
    local currentSpeed = defaultSpeed
    local loopSpeedEnabled = false
    local wsConnection = nil
    local charAddedConnection = nil

    lp.CharacterAdded:Connect(function(c)
        char = c
        humanoid = c:FindFirstChildOfClass("Humanoid")
        if loopSpeedEnabled then
            task.wait(0.5)
            ApplySpeed()
        end
    end)

    local function getHumanoid()
        if char and char.Parent then
            return char:FindFirstChildOfClass("Humanoid")
        end
        return nil
    end

    local function ApplySpeed()
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = currentSpeed
        end
    end

    local function StartLoopSpeed()
        if loopSpeedEnabled then return end
        loopSpeedEnabled = true
        ApplySpeed()

        -- Main loop to maintain speed
        wsConnection = RunService.Stepped:Connect(function()
            local hum = getHumanoid()
            if hum and hum.WalkSpeed ~= currentSpeed then
                hum.WalkSpeed = currentSpeed
            end
        end)
    end

    local function StopLoopSpeed()
        loopSpeedEnabled = false
        if wsConnection then
            wsConnection:Disconnect()
            wsConnection = nil
        end
        -- Reset to normal
        local hum = getHumanoid()
        if hum then
            hum.WalkSpeed = defaultSpeed
        end
    end

    SpeedTab:Toggle({
        Title = "Loop Speed",
        Callback = function(v)
            if v then
                StartLoopSpeed()
            else
                StopLoopSpeed()
            end
        end
    })

    SpeedTab:Input({
        Title = "WalkSpeed",
        Placeholder = "16 (default)",
        Callback = function(v)
            local num = tonumber(v)
            if num then
                currentSpeed = num
                ApplySpeed()
                -- If loop is active, it will maintain the new value automatically
            end
        end
    })

    -- Optional: Button to reset to default
    SpeedTab:Button({
        Title = "Reset to Default",
        Callback = function()
            currentSpeed = defaultSpeed
            ApplySpeed()
            if not loopSpeedEnabled then
                StopLoopSpeed() -- just in case
            end
        end
    })
end
