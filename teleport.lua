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
            WindUI:Notify({ Title = "Teleport", Content = "Player has no character!", Color = "Red" })
            return
        end
        
        local targetRoot = getRoot(targetPlayer.Character)
        if targetRoot and hrp then
            hrp.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)  -- Safe offset above
            WindUI:Notify({ Title = "Teleported", Content = "To " .. targetPlayer.Name })
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

    -- Main dynamic dropdown
    local playerDropdown = TpTab:Dropdown({
        Title = "Teleport to Player",
        Values = GetPlayerList(),   -- Initial list
        Callback = function(selectedName)
            local target = Players:FindFirstChild(selectedName)
            if target then
                TeleportTo(target)
            end
        end
    })

    -- Refresh button (this fixes your issue)
    TpTab:Button({
        Title = "🔄 Refresh Player List",
        Callback = function()
            local newList = GetPlayerList()
            playerDropdown:Refresh(newList)   -- WindUI supports :Refresh()
            
            WindUI:Notify({
                Title = "Player List",
                Content = "Refreshed! (" .. #newList .. " players)",
            })
        end
    })

    -- Fallback: Quick input teleport
    TpTab:Input({
        Title = "Teleport by Username",
        Placeholder = "Exact username",
        Callback = function(name)
            if name and name ~= "" then
                local target = Players:FindFirstChild(name)
                if target then
                    TeleportTo(target)
                else
                    WindUI:Notify({ Title = "Error", Content = "Player not found", Color = "Red" })
                end
            end
        end
    })
end
