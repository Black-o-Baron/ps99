local getSmallBalloons = false
local doing = false

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.PlaceId ~= nil
repeat task.wait() until not game.Players.LocalPlayer.PlayerGui:FindFirstChild("__INTRO")
repeat task.wait() until game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
if game.PlaceId == 8737899170 or game.PlaceId == 16498369169 then
    local map = game:GetService("Workspace"):FindFirstChild('Map') or game:GetService("Workspace"):FindFirstChild('Map2')
    repeat task.wait() until #map:GetChildren() >= 25
elseif game.PlaceId == 15502339080 then
    repeat task.wait() until game:GetService("Workspace").__THINGS and game:GetService("Workspace").__DEBRIS
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
getgenv().autoBalloon = true



hookfunction(setfpscap, function(v)
    pcall(function()
        setfflag("TaskSchedulerTargetFps", v)
    end)
end)

local cancer = false
task.spawn(function()
    while task.wait() do
        pcall(function()
            if game.CoreGui.RobloxPromptGui.promptOverlay.ErrorPrompt.Parent then
                cancer = true
            end
        end)
    end
end)


task.spawn(function()
    while task.wait() do
        if cancer then
            game:Shutdown()
        end
    end
end)

--setfpscap(10)

local areasWithShit = {}

function positonToNearestBalloon(pos)
    local closest = 9999
    local current
    for i, v in pairs(workspace.__THINGS.BalloonGifts:GetChildren()) do
        repeat task.wait() until v:FindFirstChild("Giftbox")
        if (pos - v.Giftbox.CFrame.Position).Magnitude < closest then
            current = v
        end
    end
    print(current)
    return current
end

function raycastBalloonForArea(pos)
    local originPosition = pos
    local direction = -Vector3.yAxis

    local distance = 1000

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = { workspace.__THINGS.Breakables, workspace.__THINGS.BalloonGifts,
        workspace.__THINGS.__FAKE_GROUND }


    local raycastResult = Workspace:Raycast(originPosition, direction * distance, raycastParams)

    if raycastResult ~= nil then
        local theParent = raycastResult.Instance
        if not theParent.Parent.Name:find(" | ") then
            pcall(function()
                repeat
                    theParent = theParent.Parent
                until theParent.Parent.Name:find(" | ")
            end)
        end
        if theParent.Parent ~= nil then
            areasWithShit[theParent.Parent] = true
        end
        return theParent.Parent
    end
end

local function rayCastBalloons()
    -- The origin point of the ray
    for i, v in pairs(workspace.__THINGS.BalloonGifts:GetChildren()) do
        if v:FindFirstChild("Balloon") and (not (getSmallBalloons and v.Balloon.BrickColor ~= BrickColor.new("Persimmmon"))) then
            local originPosition = v.Giftbox.Position

            local direction = -Vector3.yAxis

            local distance = 1000

            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastParams.FilterDescendantsInstances = { workspace.__THINGS.Breakables, workspace.__THINGS.BalloonGifts,
                workspace.__THINGS.__FAKE_GROUND }



            local raycastResult = Workspace:Raycast(originPosition, direction * distance, raycastParams)
            if raycastResult ~= nil then
                local theParent = raycastResult.Instance
                if not theParent.Parent.Name:find(" | ") then
                    repeat
                        theParent = theParent.Parent
                    until theParent.Parent.Name:find(" | ")
                end

                areasWithShit[theParent.Parent] = true
            end
        end
    end
end


function clickCoin(stringID)
    game:GetService("ReplicatedStorage").Network.Breakables_PlayerDealDamage:FireServer(stringID)
end

local ClientModule = require(game:GetService("ReplicatedStorage").Library.Client)
function getMyPetsEquipped()
    tbl = {}
    for i, v in pairs(ClientModule.PlayerPet.GetAll()) do
        if v.owner == game.Players.LocalPlayer and not table.find(tbl, v) then
            table.insert(tbl, v)
        end
    end
    return tbl
end

function hop()
    local function alternateServersRequest()
        local response = request({
            Url = 'https://games.roblox.com/v1/games/' ..
                tostring(game.PlaceId) .. '/servers/Public?sortOrder=Asc&limit=100',
            Method = "GET",
            Headers = { ["Content-Type"] = "application/json" },
        })

        if response.Success then
            return response.Body
        else
            return nil
        end
    end

    local function getServer()
        local servers

        local success, _ = pcall(function()
            servers = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' ..
                tostring(game.PlaceId) .. '/servers/Public?sortOrder=Asc&limit=100')).data
        end)

        if not success then
            print("Error getting servers, using backup method")
            servers = game.HttpService:JSONDecode(alternateServersRequest()).data
        end

        local server = servers[Random.new():NextInteger(5, 100)]
        if server then
            return server
        else
            return getServer()
        end
    end

    pcall(function()
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, getServer().id, game.Players
            .LocalPlayer)
    end)

    task.wait(5)
    while true do
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
        task.wait()
    end
end

getgenv().autoBalloonConfig = {
    START_DELAY = 1,      -- delay before starting
    SERVER_HOP = true,    -- server hop after popping balloons
    SERVER_HOP_DELAY = 1, -- delay before server hopping
    GET_BALLOON_DELAY = 1 -- delay before getting balloons again if none are detected
}

task.wait(getgenv().autoBalloonConfig.START_DELAY)

local WAITING = false

local function serverhop(player)
    local timeToWait = Random.new():NextInteger(300, 600)
    print("[ANTI-STAFF] BIG Games staff (" ..
        player.Name .. ") is in server! Waiting for " .. tostring(timeToWait) .. " seconds before server hopping...")
    task.wait(timeToWait)

    local success, _ = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/serverhop.lua"))()
    end)

    if not success then
        game.Players.LocalPlayer:Kick("[ANTI-STAFF] A BIG Games staff member joined and script was unable to server hop")
    end
end

for _, player in pairs(game.Players:GetPlayers()) do
    local success, _ = pcall(function()
        if player:IsInGroup(5060810) then
            WAITING = true
            serverhop(player)
        end
    end)
    if not success then
        print("[ANTI-STAFF] Error while checking player: " .. player.Name)
    end
end

print("[ANTI-STAFF] No staff member detected")

game.Players.PlayerAdded:Connect(function(player)
    if player:IsInGroup(5060810) and not WAITING then
        getgenv().autoBalloon = false
        getgenv().autoChest = false
        getgenv().autoFishing = false

        getgenv().STAFF_DETECTED = true

        print("[ANTI-STAFF] Staff member joined, stopping all scripts")
        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false

        local world
        local mapPath
        if game.PlaceId == 8737899170 then
            mapPath = game:GetService("Workspace").Map
            world = "World 1"
        elseif game.PlaceId == 16498369169 then
            mapPath = game:GetService("Workspace").Map2
            world = "World 1"
        end


        local _, zoneData

        if world == "World 1" then
            _, zoneData = require(game:GetService("ReplicatedStorage").Library.Util.ZonesUtil).GetZoneFromNumber(Random
                .new():NextInteger(40, 90))
        else
            _, zoneData = require(game:GetService("ReplicatedStorage").Library.Util.ZonesUtil).GetZoneFromNumber(Random
                .new():NextInteger(5, 20))
        end

        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = mapPath[tostring(zoneData["_script"])].PERSISTENT
            .Teleport.CFrame

        serverhop(player)
    end
end)

workspace.__THINGS.Lootbags.ChildAdded:Connect(function()
    if getgenv().autoBalloon then
        pcall(function()
            for i, v in pairs(workspace.__THINGS.Lootbags:GetChildren()) do
                if not v:IsA("Model") or not v.PrimaryPart then continue end
                wait()
                v.PrimaryPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                wait()
                game:GetService("ReplicatedStorage").Network.Lootbags_Claim:FireServer({ v.Name })
                wait()
                v.Parent = nil
            end
        end)
    end
end)

game:GetService("ReplicatedStorage").Network["Mailbox: Claim All"]:InvokeServer()


while getgenv().autoBalloon do
    local balloonIds = {}

    local getActiveBalloons = ReplicatedStorage.Network.BalloonGifts_GetActiveBalloons:InvokeServer()

    local allPopped = true
    for i, v in pairs(getActiveBalloons) do
        if not v.Popped and (not getSmallBalloons and v.BalloonTypeId ~= "Small Balloon") then
            allPopped = false

            balloonIds[i] = v
        end
    end

    if allPopped then
        if getgenv().autoBalloonConfig.SERVER_HOP then
            while task.wait() do
                if not doing then
                    hop()
                    task.wait(1)
                end
            end
        end
        task.wait(getgenv().autoBalloonConfig.GET_BALLOON_DELAY)
        continue
    end

    if not getgenv().autoBalloon then
        break
    end

    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame

    LocalPlayer.Character.HumanoidRootPart.Anchored = true

    for balloonId, balloonData in pairs(balloonIds) do
        ReplicatedStorage.Network.Slingshot_Toggle:InvokeServer()

        task.wait(0.2)
        local balloonPosition = balloonData.Position


        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(balloonPosition.X, balloonPosition.Y + 30,
            balloonPosition.Z)



        local area

        task.spawn(function()
            repeat
                area = raycastBalloonForArea(balloonPosition)
                task.wait(0.1)
            until area ~= nil
            print(area)
            local balloonModel
            task.spawn(function()
                balloonModel = positonToNearestBalloon(balloonPosition)
            end)
        end)

        -- if balloonModel == nil then continue end



        local args = {
            [1] = Vector3.new(balloonPosition.X, balloonPosition.Y + 25, balloonPosition.Z),
            [2] = 0.5794160315249014,
            [3] = -0.8331117721691044,
            [4] = 200
        }

        ReplicatedStorage.Network.Slingshot_FireProjectile:InvokeServer(unpack(args))

        task.wait(0.1)

        local args = {
            [1] = balloonId
        }

        ReplicatedStorage.Network.BalloonGifts_BalloonHit:FireServer(unpack(args))

        task.wait(0.1)

        ReplicatedStorage.Network.Slingshot_Unequip:InvokeServer()
    end

    LocalPlayer.Character.HumanoidRootPart.Anchored = false



    for i, v in pairs(areasWithShit) do
        doing = true
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = i.PERSISTENT.Teleport.CFrame

        local areaName = i.name:split(" | ")[2]

        local oldTimer = tick()
        local found = false
        repeat
            for i, v in pairs(workspace.__THINGS.Breakables:GetChildren()) do
                if v:GetAttribute("ParentID") and v:GetAttribute("ParentID") == areaName and v:GetAttribute("BreakableID") and v:GetAttribute("BreakableID"):find("Balloon Gift") and (not getSmallBalloons and v:GetAttribute("BreakableID") ~= "Small Balloon Gift") and v:GetAttribute("OwnerUsername") and v:GetAttribute("OwnerUsername") == game.Players.LocalPlayer.Name then
                    found = true
                end
            end
            task.wait(0.05)
        until found or tick() - oldTimer >= 3.5


        for i = 1, 3 do
            for i, v in pairs(workspace.__THINGS.Breakables:GetChildren()) do
                if v:GetAttribute("ParentID") and v:GetAttribute("ParentID") == areaName and v:GetAttribute("BreakableID") and v:GetAttribute("BreakableID"):find("Balloon Gift") and (not getSmallBalloons and v:GetAttribute("BreakableID") ~= "Small Balloon Gift") and v:GetAttribute("OwnerUsername") and v:GetAttribute("OwnerUsername") == game.Players.LocalPlayer.Name then
                    local AvaliblePets = getMyPetsEquipped()

                    pcall(function()
                        repeat
                            pcall(function()
                                AvaliblePets = getMyPetsEquipped()


                                local pets = AvaliblePets[math.random(1, #AvaliblePets)]
                                local args = { [1] = v:GetAttribute("BreakableUID"), [2] = pets.euid }
                                game:GetService("ReplicatedStorage").Network.Breakables_JoinPet:FireServer(unpack(args))
                            end)


                            game:GetService("ReplicatedStorage").Network.Breakables_PlayerDealDamage:FireServer(id)

                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.PrimaryPart.CFrame
                            wait()
                        until v == nil or v.Parent == nil
                    end)


                    task.wait(1)
                end
            end
        end
    end
    doing = false



    if getgenv().autoBalloonConfig.SERVER_HOP then
        while task.wait() do
            hop()
            task.wait(1)
        end
    end

    LocalPlayer.Character.HumanoidRootPart.Anchored = false
    LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
end
