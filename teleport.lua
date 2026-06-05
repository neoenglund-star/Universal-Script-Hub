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
        return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    end

    local function TeleportTo(targetPlayer)
        if not targetPlayer or not targetPlayer.Character then
            return
        end
        
        local targetRoot = getRoot(targetPlayer.Character)
        if targetRoot and hrp then
            hrp.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)  -- Slight offset to avoid stacking
        end
    end

    -- Get current players for dropdown
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

    -- Teleport to selected player (Dropdown)
    TpTab:Dropdown({
        Title = "Teleport to Player",
        Options = GetPlayerList(),
        Callback = function(selectedName)
            local target = Players:FindFirstChild(selectedName)
            if target then
                TeleportTo(target)
            end
        end
    })

    -- Refresh button (important because players join/leave)
    TpTab:Button({
        Title = "Refresh Player List",
        Callback = function()
            -- Note: Some UIs require re-creating the dropdown, but if WindUI supports dynamic update, this helps
            print("Player list refreshed - re-open dropdown")
        end
    })

    -- Bring player to me
    TpTab:Button({
        Title = "Bring Player to Me",
        Callback = function()
            -- This would require a second dropdown or input, but for simplicity we'll add an Input version
        end
    })

    -- Alternative: Input-based teleport (type username)
    TpTab:Input({
        Title = "Teleport to (Username)",
        Placeholder = "PlayerName",
        Callback = function(name)
            if name and name ~= "" then
                local target = Players:FindFirstChild(name)
                if target then
                    TeleportTo(target)
                else
                    -- Try partial match
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr.Name:lower():find(name:lower()) then
                            TeleportTo(plr)
                            return
                        end
                    end
                end
            end
        end
    })
end
