return function(WindUI, PlayerMovement)
    local TpTab = PlayerMovement:Tab({
        Title = "Teleport",
        Icon = "map-pin"
    })

    local Players = game:GetService("Players")

    local lp = Players.LocalPlayer
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    lp.CharacterAdded:Connect(function(c)
        char = c
        hrp = c:WaitForChild("HumanoidRootPart")
    end)

    local function getRoot(character)
        return character:FindFirstChild("HumanoidRootPart") 
            or character:FindFirstChild("Torso") 
            or character:FindFirstChild("UpperTorso")
    end

    local function TeleportTo(targetPlayer)
        if not targetPlayer or not targetPlayer.Character then
            WindUI:Notify({Title = "Teleport", Content = "Player has no character!", Color = "Red"})
            return
        end
        local targetRoot = getRoot(targetPlayer.Character)
        if targetRoot and hrp then
            hrp.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
            WindUI:Notify({Title = "Teleported", Content = "To " .. targetPlayer.Name})
        end
    end

    local function GetPlayerList()
        local list = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                table.insert(list, plr.Name)
            end
        end
        table.sort(list)
        return list
    end

    -- Create dropdown with empty list first, then refresh immediately
    local playerDropdown = TpTab:Dropdown({
        Title = "Teleport to Player",
        Values = {},  -- Start empty
        Callback = function(selectedName)
            local target = Players:FindFirstChild(selectedName)
            if target then
                TeleportTo(target)
            end
        end
    })

    -- Initial population
    task.spawn(function()
        task.wait(0.5)  -- Give time for UI to initialize
        playerDropdown:Refresh(GetPlayerList())
    end)

    -- Auto refresh on player join/leave
    Players.PlayerAdded:Connect(function()
        task.wait(0.5)
        playerDropdown:Refresh(GetPlayerList())
    end)

    Players.PlayerRemoving:Connect(function()
        task.wait(0.3)
        playerDropdown:Refresh(GetPlayerList())
    end)

    -- Manual Refresh Button
    TpTab:Button({
        Title = "🔄 Refresh Player List",
        Callback = function()
            local list = GetPlayerList()
            playerDropdown:Refresh(list)
            WindUI:Notify({
                Title = "Player List",
                Content = "Refreshed (" .. #list .. " players)"
            })
        end
    })

    -- Fallback Input (always works)
    TpTab:Input({
        Title = "Teleport by Username",
        Placeholder = "Type exact username",
        Callback = function(name)
            if name and name ~= "" then
                local target = Players:FindFirstChild(name)
                if target then
                    TeleportTo(target)
                else
                    WindUI:Notify({Title = "Error", Content = "Player not found", Color = "Red"})
                end
            end
        end
    })
end
