return function(WindUI, PlayerMovement)
    local NoclipTab = PlayerMovement:Tab({
        Title = "Noclip",
        Icon = "ban"  -- Using ban icon as requested
    })

    local noclipping = false
    local NoclippingConnection = nil
    local Clip = true  -- true = collision on, false = noclip

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local lp = Players.LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    lp.CharacterAdded:Connect(function(c)
        char = c
        humanoid = c:FindFirstChildOfClass("Humanoid")
    end)

    local function getRoot(character)
        return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    end

    local function StartNoclip()
        if NoclippingConnection then
            NoclippingConnection:Disconnect()
        end

        Clip = false
        noclipping = true

        local function NoclipLoop()
            if Clip == false and char and char.Parent then
                for _, child in pairs(char:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide == true then
                        child.CanCollide = false
                    end
                end
            end
        end

        NoclippingConnection = RunService.Stepped:Connect(NoclipLoop)
    end

    local function StopNoclip()
        Clip = true
        noclipping = false
        if NoclippingConnection then
            NoclippingConnection:Disconnect()
            NoclippingConnection = nil
        end

        -- Restore collision
        if char and char.Parent then
            for _, child in pairs(char:GetDescendants()) do
                if child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
                    child.CanCollide = true
                end
            end
        end
    end

    NoclipTab:Toggle({
        Title = "Noclip",
        Callback = function(v)
            if v then
                StartNoclip()
            else
                StopNoclip()
            end
        end
    })

    -- Optional: Add a toggle for vehicle noclip if you want later
end
