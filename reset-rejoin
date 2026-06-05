return function(WindUI, PlayerMovement)
    local UtilsTab = PlayerMovement:Tab({
        Title = "Utilities",
        Icon = "rotate-ccw"
    })

    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")

    local lp = Players.LocalPlayer
    local PlaceId = game.PlaceId
    local JobId = game.JobId

    -- ==================== REJOIN ====================
    UtilsTab:Button({
        Title = "Rejoin Server",
        Callback = function()
            if #Players:GetPlayers() <= 1 then
                -- Single player server
                lp:Kick("\nRejoining...")
                task.wait()
                TeleportService:Teleport(PlaceId, lp)
            else
                -- Multiplayer server (same server)
                TeleportService:TeleportToPlaceInstance(PlaceId, JobId, lp)
            end
        end
    })

    -- ==================== RESET ====================
    UtilsTab:Button({
        Title = "Reset Character",
        Callback = function()
            local humanoid = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Dead)
            else
                if lp.Character then
                    lp.Character:BreakJoints()
                end
            end
        end
    })

    -- Optional: Respawn button (IY also has this)
    UtilsTab:Button({
        Title = "Respawn",
        Callback = function()
            local humanoid = lp.Character and lp.Character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                humanoid.Health = 0
            else
                if lp.Character then
                    lp.Character:BreakJoints()
                end
            end
        end
    })
end
