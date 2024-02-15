local Booths_Broadcast = game:GetService("ReplicatedStorage").Network:WaitForChild("Booths_Broadcast")

local function potatographics()
    local lighting = game.Lighting
    local terrain = game.Workspace.Terrain
    terrain.WaterWaveSize = 0
    terrain.WaterWaveSpeed = 0
    terrain.WaterReflectance = 0
    terrain.WaterTransparency = 0
    lighting.GlobalShadows = false
    lighting.FogStart = 0
    lighting.FogEnd = 0
    lighting.Brightness = 0
    settings().Rendering.QualityLevel = "Level01"

    for i, v in pairs(game:GetDescendants()) do
        if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        elseif v:IsA("Explosion") then
            v.BlastPressure = 1
            v.BlastRadius = 1
        elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v.Enabled = false
        elseif v:IsA("MeshPart") then
            v.Material = "Plastic"
            v.Reflectance = 0
        end
    end

    for i, e in pairs(lighting:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
            e.Enabled = false
        end
    end

    task.wait(2)
    return true
end

repeat
    task.wait()
until potatographics()

-- Booths_Broadcast.OnClientEvent:Connect(function(username, message)
--     if type(message) == "table" then
--         for v, value in pairs(message["Listings"] or {}) do
--             if type(value) == "table" and value["ItemData"] and value["ItemData"]["data"] then
--                 local buytimestamp = value["ReadyTimestamp"]
--                 local data = value["ItemData"]["data"]
--                 local gems = tonumber(value["DiamondCost"])
--                 local uid = v
--                 local item = data["id"]
--                 local amount = tonumber(data["_am"]) or 1
--                 local playerid = message['PlayerID']
--                 local unitGems = gems / amount

--                 if uid then
--                     print("uid: " .. tostring(uid))
--                 end
--                 if playerid then
--                     print("PlayerID: " .. tostring(playerid))
--                 end
--                 if unitGems then
--                     print("unitGems: " .. tostring(unitGems))
--                 end
--                 if item then
--                     print("item: " .. tostring(item))
--                 end
--             end
--         end
--     end
-- end)

Booths_Broadcast.OnClientEvent:Connect(function(username, message)
    if type(message) == "table" then
        local highestTimestamp = -math.huge -- Initialize with the smallest possible number
        local key = nil
        local listing = nil
        for v, value in pairs(message["Listings"] or {}) do
            if type(value) == "table" and value["ItemData"] and value["ItemData"]["data"] then
                local timestamp = value["Timestamp"]
                if timestamp > highestTimestamp then
                    highestTimestamp = timestamp
                    key = v
                    listing = value
                end
            end
        end
        if listing then
            local buytimestamp = listing["ReadyTimestamp"]
            local data = listing["ItemData"]["data"]
            local gems = tonumber(listing["DiamondCost"])
            local uid = key
            local item = data["id"]
            local amount = tonumber(data["_am"]) or 1
            local playerid = message['PlayerID']
            local unitGems = gems / amount

            if uid then
                print("UID: " .. tostring(uid))
            end
            if playerid then
                print("Player ID: " .. tostring(playerid))
            end
        end
    end
end)
