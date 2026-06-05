return function(WindUI, PlayerMovement)
    local SitTab = PlayerMovement:Tab({
        Title = "Sit",
        Icon = "bed"
    })

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local lp = Players.LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    local sitting = false
    local sitConnection = nil

    lp.CharacterAdded:Connect(function(c)
        char = c
        humanoid = c:FindFirstChildOfClass("Humanoid")
        if sitting then
            task.wait(0.3)
            ApplySit()
        end
    end)

    local function getHumanoid()
        if char and char.Parent then
            return char:FindFirstChildOfClass("Humanoid")
        end
        return nil
    end

    local function ApplySit()
        local hum = getHumanoid()
        if hum then
            hum.Sit = sitting
        end
    end

    local function StartSitLoop()
        if sitConnection then return end
        
        sitting = true
        ApplySit()

        -- Keep forcing sit state (matches IY behavior)
        sitConnection = RunService.Stepped:Connect(function()
            local hum = getHumanoid()
            if hum and hum.Sit ~= sitting then
                hum.Sit = sitting
            end
        end)
    end

    local function StopSit()
        sitting = false
        if sitConnection then
            sitConnection:Disconnect()
            sitConnection = nil
        end

        local hum = getHumanoid()
        if hum then
            hum.Sit = false
        end
    end

    SitTab:Toggle({
        Title = "Sit",
        Callback = function(v)
            if v then
                StartSitLoop()
            else
                StopSit()
            end
        end
    })

    -- Extra button for one-time sit (IY style)
    SitTab:Button({
        Title = "Sit Once",
        Callback = function()
            local hum = getHumanoid()
            if hum then
                hum.Sit = true
            end
        end
    })

    SitTab:Button({
        Title = "Stand Up",
        Callback = function()
            StopSit()
        end
    })
end
