local SERVER_HOP = true -- server hop after breaking all chests
local SERVER_HOP_DELAY = 2 -- delay in seconds before server hopping (set to 0 for no delay)
local CHEST_BREAK_DELAY = 1 -- delay in seconds before breaking next chest (set to 0 for no delay)

local BigChests = {
    [1] = "Beach",
    [2] = "Underworld",
    [3] = "No Path Forest",
    [4] = "Heaven Gates"
}

repeat
    task.wait()
until game:IsLoaded()

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = ReplicatedStorage:WaitForChild("Library")
local Client = Library:WaitForChild("Client")
local LocalPlayer = game:GetService("Players").LocalPlayer

local zonePath

local function trim(string)
    if not string then
        return false
    end
    return string:match("^%s*(.-)%s*$")
end

local function split(input, separator)
    if separator == nil then
        separator = "%s"
    end
    local parts = {}
    for str in string.gmatch(input, "([^" .. separator .. "]+)") do
        table.insert(parts, str)
    end
    return parts
end

local function potatographics()
    task.wait(1)

    -- local lighting = game.Lighting
    -- local terrain = game.Workspace.Terrain
    -- terrain.WaterWaveSize = 0
    -- terrain.WaterWaveSpeed = 0
    -- terrain.WaterReflectance = 0
    -- terrain.WaterTransparency = 0
    -- lighting.GlobalShadows = false
    -- lighting.FogStart = 0
    -- lighting.FogEnd = 0
    -- lighting.Brightness = 0
    -- settings().Rendering.QualityLevel = "Level01"

    -- for i, v in pairs(game:GetDescendants()) do
    --     if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
    --         v.Material = "Plastic"
    --         v.Reflectance = 0
    --     elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
    --         v.Lifetime = NumberRange.new(0)
    --     elseif v:IsA("Explosion") then
    --         v.BlastPressure = 1
    --         v.BlastRadius = 1
    --     elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
    --         v.Enabled = false
    --     elseif v:IsA("MeshPart") then
    --         v.Material = "Plastic"
    --         v.Reflectance = 0
    --     end
    -- end

    -- for i, e in pairs(lighting:GetChildren()) do
    --     if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
    --         e.Enabled = false
    --     end
    -- end

    game:GetService("RunService"):Set3dRenderingEnabled(false)

    task.wait(1)
    return true
end

local function teleportToZone(selectedZone)
    local teleported = false

    while not teleported do
        for _, v in pairs(Workspace.Map:GetChildren()) do
            local zoneName = trim(split(v.Name, "|")[2])
            if zoneName and zoneName == selectedZone then
                LocalPlayer.Character.HumanoidRootPart.CFrame = game:GetService("Workspace").Map[v.Name].PERSISTENT.Teleport.CFrame
                teleported = true
                break
            end
        end
        task.wait()
    end
end

local function waitForLoad(zone)
    for _, v in pairs(Workspace.Map:GetChildren()) do
        local zoneName = trim(split(v.Name, "|")[2])
        if zoneName and zoneName == zone then
            zonePath = game:GetService("Workspace").Map[v.Name]
            break
        end
    end

    if not zonePath:FindFirstChild("INTERACT") then
        local loaded = false
        local detectLoad = zonePath.ChildAdded:Connect(function(child)
            if child.Name == "INTERACT" then
                loaded = true
            end
        end)

        repeat
            task.wait()
        until loaded

        detectLoad:Disconnect()
    end

    local function getBreakZonesAmount()
        local counter = 0
        for _ in pairs(zonePath.INTERACT.BREAK_ZONES:GetChildren()) do
            counter = counter + 1
        end
        return counter
    end

    if getBreakZonesAmount() < 2 then
        local loaded = false
        local detectLoad = zonePath.INTERACT.BREAK_ZONES.ChildAdded:Connect(function(child)
            if getBreakZonesAmount() == 2 then
                loaded = true
            end
        end)
        repeat
            task.wait()
        until loaded
        detectLoad:Disconnect()
    end
end

local function breakChest(zone)

    local chest
    while not chest do
        for v in require(Client.BreakableCmds).AllByZoneAndClass(zone, "Chest") do
            chest = v
            break
        end
        task.wait()
    end

    local args = {
        [1] = {

        }
    }

    for petId, _ in pairs(require(Client.Save).Get(LocalPlayer).EquippedPets) do
        args[1][petId] = {
            ["targetValue"] = chest,
            ["targetType"] = "Player"
        }
    end

    game:GetService("ReplicatedStorage").Network.Pets_SetTargetBulk:FireServer(unpack(args))

    local brokeChest = false
    local breakableRemovedService = Workspace:WaitForChild("__THINGS").Breakables.ChildRemoved:Connect(function(breakable)
        if breakable.Name == chest then
            brokeChest = true
            print("Broke chest")
        end
    end)

    LocalPlayer.Character.HumanoidRootPart.CFrame = zonePath.INTERACT.BREAKABLE_SPAWNS.Boss.CFrame

    repeat
        task.wait()
    until brokeChest

    breakableRemovedService:Disconnect()
end

require(Library.Client.PlayerPet).CalculateSpeedMultiplier = function()
    return 200
end

local sortedKeys = {}
for key in pairs(BigChests) do
    table.insert(sortedKeys, key)
end
table.sort(sortedKeys)

repeat
    task.wait()
until potatographics()

for _, key in ipairs(sortedKeys) do
    local zoneName = BigChests[key]

    print("Starting " .. zoneName)

    teleportToZone(zoneName)
    waitForLoad(zoneName)
    task.wait()

    task.wait(2)
    for _, v in pairs(game:GetService("Workspace").__DEBRIS:GetChildren()) do

        if v.Name == "host" then
            local timer

            pcall(function()
                timer = v.ChestTimer.Timer.Text
            end)

            if timer ~= nil then
                if timer == "00:00" then
                    print(zoneName .. " chest is available")
                    breakChest(zoneName)
                else
                    print(zoneName .. " chest is not available " .. timer)
                end
                v:Destroy()
                break
            end
        end
    end
    warn("Finished " .. zoneName)
    task.wait(CHEST_BREAK_DELAY)
end

if SERVER_HOP then
    print("Server hopping in " .. SERVER_HOP_DELAY .. " seconds")
    task.wait(SERVER_HOP_DELAY)

    local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true"
    local req = request({ Url = string.format(sfUrl, 8737899170, "Asc", 25) })
    local body = game:GetService("HttpService"):JSONDecode(req.Body)
    local deep = math.random(1, 9)
    if deep > 1 then
        for i = 1, deep, 1 do
            if body.nextPageCursor then
                req = request({ Url = string.format(sfUrl .. "&cursor=" .. body.nextPageCursor, 8737899170, "Asc", 25) })
                body = game:GetService("HttpService"):JSONDecode(req.Body)
                task.wait(0.1)
            else
                break
            end
        end
    end
    local servers = {}
    if body and body.data then
        for i, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId and v.ping < 100 then
                table.insert(servers, 1, v.id)
            end
        end
    end
    local randomCount = #servers
    if not randomCount then
        randomCount = 2
    end
    while true do
        game:GetService("TeleportService"):TeleportToPlaceInstance(8737899170, servers[math.random(1, randomCount)], LocalPlayer)
        task.wait(0.5)
        game:GetService("TeleportService"):Teleport(8737899170, LocalPlayer)
    end
end
