return function(WindUI, PlayerMovement)
    local JumpTab = PlayerMovement:Tab({
        Title = "JumpPower",
        Icon = "gauge"  -- or "arrow-up" if your UI supports it
    })

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local lp = Players.LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    local defaultJumpPower = 50
    local currentJumpPower = defaultJumpPower
    local loopJumpEnabled = false
    local jpConnection = nil

    lp.CharacterAdded:Connect(function(c)
        char = c
        humanoid = c:FindFirstChildOfClass("Humanoid")
        if loopJumpEnabled then
            task.wait(0.3)
            ApplyJumpPower()
        end
    end)

    local function getHumanoid()
        if char and char.Parent then
            return char:FindFirstChildOfClass("Humanoid")
        end
        return nil
    end

    local function ApplyJumpPower()
        local hum = getHumanoid()
        if hum then
            hum.JumpPower = currentJumpPower
            -- Some games use JumpHeight instead
            pcall(function() hum.JumpHeight = currentJumpPower end)
        end
    end

    local function StartLoopJump()
        if loopJumpEnabled then return end
        loopJumpEnabled = true
        ApplyJumpPower()

        jpConnection = RunService.Stepped:Connect(function()
            local hum = getHumanoid()
            if hum and hum.JumpPower ~= currentJumpPower then
                hum.JumpPower = currentJumpPower
            end
        end)
    end

    local function StopLoopJump()
        loopJumpEnabled = false
        if jpConnection then
            jpConnection:Disconnect()
            jpConnection = nil
        end
        local hum = getHumanoid()
        if hum then
            hum.JumpPower = defaultJumpPower
            pcall(function() hum.JumpHeight = defaultJumpPower end)
        end
    end

    JumpTab:Toggle({
        Title = "Loop JumpPower",
        Callback = function(v)
            if v then
                StartLoopJump()
            else
                StopLoopJump()
            end
        end
    })

    JumpTab:Input({
        Title = "JumpPower",
        Placeholder = "50 (default)",
        Callback = function(v)
            local num = tonumber(v)
            if num and num >= 0 then
                currentJumpPower = num
                ApplyJumpPower()
            end
        end
    })

    JumpTab:Button({
        Title = "Reset to Default",
        Callback = function()
            currentJumpPower = defaultJumpPower
            ApplyJumpPower()
            if not loopJumpEnabled then
                StopLoopJump()
            end
        end
    })
end
