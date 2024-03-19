--[[
getgenv().MoneyPrinter = {
    toolName = "Slingshot",
    autoBalloons = true,
    autoPresents = true,

    serverHopper = true,
    avoidCooldown = false,
    minServerTime = 10,

    sendWeb = true,
    webURL = "https://discord.com/api/webhooks/1219484976781721723/8dNBZ8UsnmA7G1E3iMS-nUDy3qYMKQ_A1m1DnNHsHWVTNIvh56mqwWjEZq3X5koejyGY",

    maybeCPUReducer = true,
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/Black-o-Baron/ps99/master/miscellaneous/kittywareAutoBalloon.lua"))()
]]

getgenv().MoneyPrinter = {
    toolName = "Slingshot",
    autoBalloons = true,
    autoPresents = true,

    serverHopper = true,
    avoidCooldown = false,
    minServerTime = 10,

    sendWeb = true,
    webURL = "https://discord.com/api/webhooks/1219484976781721723/8dNBZ8UsnmA7G1E3iMS-nUDy3qYMKQ_A1m1DnNHsHWVTNIvh56mqwWjEZq3X5koejyGY",

    maybeCPUReducer = true,
}

if game:IsLoaded() and getgenv().MoneyPrinter.maybeCPUReducer then
	pcall(function()
		for _, v in pairs(game:GetService("Workspace"):FindFirstChild("__THINGS"):GetChildren()) do
			if table.find({"ShinyRelics", "Ornaments", "Instances", "Ski Chairs"}, v.Name) then
				v:Destroy()
			end
		end

		for _, v in pairs(game:GetService("Workspace"):FindFirstChild("__THINGS").__INSTANCE_CONTAINER.Active.AdvancedFishing:GetChildren()) do
			if string.find(v.Name, "Model") or string.find(v.Name, "Water") or string.find(v.Name, "Debris") or string.find(v.Name, "Interactable") then
				v:Destroy()
			end

			if v.Name == "Map" then
				for _, v in pairs(v:GetChildren()) do
					if v.Name ~= "Union" then
						v:Destroy()
					end
				end
			end
		end

		game:GetService("Workspace"):WaitForChild("ALWAYS_RENDERING"):Destroy()
	end)

	local Workspace = game:GetService("Workspace")
	local Terrain = Workspace:WaitForChild("Terrain")
	Terrain.WaterReflectance = 0
	Terrain.WaterTransparency = 1
	Terrain.WaterWaveSize = 0
	Terrain.WaterWaveSpeed = 0

	local Lighting = game:GetService("Lighting")
	Lighting.Brightness = 0
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 9e100
	Lighting.FogStart = 0

	sethiddenproperty(Lighting, "Technology", 2)
	sethiddenproperty(Terrain, "Decoration", false)

	local function clearTextures(v)
		if v:IsA("BasePart") and not v:IsA("MeshPart") then
			v.Material = "Plastic"
			v.Reflectance = 0
			v.Transparency = 1
		elseif (v:IsA("Decal") or v:IsA("Texture")) then
			v.Transparency = 1
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
			v.TextureID = 10385902758728957
		elseif v:IsA("SpecialMesh")  then
			v.TextureId = 0
		elseif v:IsA("ShirtGraphic") then
			v.Graphic = 1
		elseif (v:IsA("Shirt") or v:IsA("Pants")) then
			v[v.ClassName .. "Template"] = 1
		elseif v.Name == "Foilage" and v:IsA("Folder") then
			v:Destroy()
		elseif string.find(v.Name, "Tree") or string.find(v.Name, "Water") or string.find(v.Name, "Bush") or string.find(v.Name, "grass") then
			task.wait()
			v:Destroy()
		end
	end

	game:GetService("Lighting"):ClearAllChildren()

	for _, v in pairs(Workspace:GetDescendants()) do
		clearTextures(v)
	end

	Workspace.DescendantAdded:Connect(function(v)
		clearTextures(v)
	end)

	for _, v in pairs(game.Players:GetChildren()) do
		for _, v2 in pairs(v.Character:GetDescendants()) do
			if v2:IsA("BasePart") or v2:IsA("Decal") then
				v2.Transparency = 1
			end
		end
	end

	game.Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			for _, v in pairs(character:GetDescendants()) do
				if v:IsA("BasePart") or v:IsA("Decal") then
					v.Transparency = 1
				end
			end
		end)
	end)

	for i,v in pairs(game.Players.LocalPlayer.PlayerGui:GetChildren()) do
		if v:IsA("ScreenGui") then
			v.Enabled = false
		end
	end

	for i, v in pairs(game:GetService("StarterGui"):GetChildren()) do
		if v:IsA("ScreenGui") then
			v.Enabled = false
		end
	end

	for i, v in pairs(game:GetService("CoreGui"):GetChildren()) do
		if v:IsA("ScreenGui") then
			v.Enabled = false
		end
	end
	setfpscap(8)
end

local LargeRAP = 11000; local SmallRAP = 2800
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Player = game:GetService("Players").LocalPlayer
local RepStor = game:GetService("ReplicatedStorage")
local Library = require(RepStor.Library)
local HRP = Player.Character.HumanoidRootPart
local saveMod = require(RepStor.Library.Client.Save)
local BreakMod = require(RepStor.Library.Client.BreakableCmds)
local Slingshot = getsenv(Player.PlayerScripts.Scripts.Game.Misc.Slingshot)
local RAPValues = getupvalues(require(RepStor.Library).DevRAPCmds.Get)[1]
hookfunction(require(game.ReplicatedStorage.Library.Client.PlayerPet).CalculateSpeedMultiplier, function() return 250 end)
function getInfo(name) return saveMod.Get()[name] end 
function getTool() return Player.Character:FindFirstChild("WEAPON_"..Player.Name, true) end
function equipTool(toolName) return Library.Network.Invoke(toolName.."_Toggle") end
function getCurrentZone() return Library["MapCmds"].GetCurrentZone() end
function sendNotif(msg)
	local message = {content = msg}
	local jsonMessage = HttpService:JSONEncode(message)
	local success, webMessage = pcall(function() 
		HttpService:PostAsync(getgenv().MoneyPrinter.webURL, jsonMessage) 
	end)
	if not success then 
		local response = request({Url = getgenv().MoneyPrinter.webURL,Method = "POST",Headers = {["Content-Type"] = "application/json"},Body = jsonMessage})
	end
end
function getBalloonUID(zoneName) 
	for i,v in pairs(BreakMod.AllByZoneAndClass(zoneName, "Chest")) do
		if v:GetAttribute("OwnerUsername") == Player.Name and string.find(v:GetAttribute("BreakableID"), "Balloon Gift") then
			return v:GetAttribute("BreakableUID")
		elseif v:GetAttribute("OwnerUserName") ~= Player.Name and string.find(v:GetAttribute("BreakableID"), "Balloon Gift") then
			return "Skip"
		end
	end
end
function getServer()
	local servers = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. tostring(game.PlaceId) .. '/servers/Public?sortOrder=Asc&limit=100')).data
	local server = servers[Random.new():NextInteger(1, 100)]
	if server then return server else return getServer() end
end
function getPresents() for i,v in pairs(Library.Save.Get().HiddenPresents) do 
		if not v.Found and v.ID then 
			local success,reason = Library.Network.Invoke("Hidden Presents: Found", v.ID) 
		end 
	end 
end
function getTotalRAP(num)
	local suffixes = {"", "k", "m", "b"}
	local suffixInd = 1
	while num >= 1000 and suffixInd < #suffixes do
		num = num / 1000
		suffixInd = suffixInd + 1
	end
	local formattedNum
	if num % 1 == 0 then
		formattedNum = string.format("%d", num)
	else
		formattedNum = string.format("%.1f", num):gsub("%.?0+$", "")
	end
	return formattedNum .. suffixes[suffixInd]
end
-- AUTO ORB
local autoOrbConnection = nil
local autoLootBagConnection = nil
for i, v in workspace.__THINGS.Orbs:GetChildren() do
	Library.Network.Fire("Orbs: Collect",{tonumber(v.Name)})
	Library.Network.Fire("Orbs_ClaimMultiple",{[1]={[1]=v.Name}})
	task.wait()
	v:Destroy()
end
for i, v in workspace.__THINGS.Lootbags:GetChildren() do
	Library.Network.Fire("Lootbags_Claim",{v.Name})
	task.wait()
	v:Destroy()
end
autoOrbConnection = workspace.__THINGS.Orbs.ChildAdded:Connect(function(v)
	Library.Network.Fire("Orbs: Collect",{tonumber(v.Name)})
	Library.Network.Fire("Orbs_ClaimMultiple",{[1]={[1]=v.Name}})
	task.wait()
	v:Destroy()
end)
autoLootBagConnection = workspace.__THINGS.Lootbags.ChildAdded:Connect(function(v)
	Library.Network.Fire("Lootbags_Claim",{v.Name})
	task.wait()
	v:Destroy()
end)
local startBalloons = #workspace.__THINGS.BalloonGifts:GetChildren()
if #workspace.__THINGS.BalloonGifts:GetChildren() <= 1 then
	repeat game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, getServer().id, Player) task.wait(3) until not game.PlaceId
end
local startGifts = 0
local startLarge = 0
for i,v in pairs(getInfo("Inventory").Misc) do
	if startGifts ~= 0 and startLarge ~= 0 then break end
	if v.id == "Gift Bag" then
		startGifts = (v._am or 1)
	elseif v.id == "Large Gift Bag" then
		startLarge = (v._am or 1)
	end
end
local startTime = os.time()



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

    local endGifts = 0
    local endLarge = 0 
    for i,v in pairs(getInfo("Inventory").Misc) do
        if endGifts ~= 0 and endLarge ~= 0 then break end
        if v.id == "Gift Bag" then
            endGifts = (v._am or 1)
        elseif v.id == "Large Gift Bag" then
            endLarge = (v._am or 1)
        end
    end
    if getgenv().MoneyPrinter.sendWeb then
        sendNotif("```asciidoc\n[ "..Player.Name.." Earned ]\n‐ "..tostring(endGifts - startGifts).." Small :: "..tostring(getTotalRAP((endGifts - startGifts) * SmallRAP)).." \n‐ "..tostring(endLarge - startLarge).." Large :: "..tostring(getTotalRAP((endLarge - startLarge) * LargeRAP)).." \n\n[ Total / Server ]\n‐ "..tostring(endGifts).." Small :: "..tostring(getTotalRAP(endGifts * SmallRAP)).." \n‐ "..tostring(endLarge).." Large :: "..tostring(getTotalRAP(endLarge * LargeRAP)).." \n- took "..tostring(currentTime - startTime).." seconds \n- had "..tostring(startBalloons).." balloons\n```")
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
