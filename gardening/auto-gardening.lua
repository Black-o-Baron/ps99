repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.PlaceId ~= nil
repeat task.wait() until not game.Players.LocalPlayer.PlayerGui:FindFirstChild("__INTRO")
repeat task.wait() until game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
local map = game:GetService("Workspace"):FindFirstChild('Map') or game:GetService("Workspace"):FindFirstChild('Map2')
if game.PlaceId == 8737899170 or game.PlaceId == 16498369169 then
    repeat task.wait() until #map:GetChildren() >= 25
elseif game.PlaceId == 15502339080 then
    repeat task.wait() until game:GetService("Workspace").__THINGS and game:GetService("Workspace").__DEBRIS
end
local Remote = game.ReplicatedStorage.Network.Instancing_InvokeCustomFromClient
local save = require(game:GetService("ReplicatedStorage").Library.Client.Save)

game:GetService("Players").LocalPlayer.Idled:connect(function()
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "B", false, game)
    wait()
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "B", false, game)
end)


local newprt = Instance.new("Part", workspace)
newprt.Name = "standpart"
newprt.Anchored = true
newprt.CFrame = CFrame.new(-451, 85, -1400)
newprt.Size = Vector3.new(100, 1, 100)

local seedsBought = 0
local seedsUsed = 0
local oldGemAmt

local prt = Instance.new("Part", workspace)
prt.Anchored = true
prt.CFrame = CFrame.new(259, 15, 2059)
prt.Name = 'gardenPart'
local info = {}
function getUpdatedInfo()
    info = {}
    table.insert(info, save.Get().UnlockedZones)
    table.insert(info, save.Get().Rebirths)
    return info
end

function getFolderFromName(name)
    local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("Map2")
    for i, v in pairs(map:GetChildren()) do
        local areaNUM = v.Name:split(" ")[1]
        if v.Name:gsub(areaNUM .. " | ", "") == name then
            return v
        end
    end
    return false
end

local infoCuh = {}
function getZoneInfo()
    infoCuh = {}
    for i, v in pairs(getUpdatedInfo()[1]) do
        if getFolderFromName(i) then
            local areaNum = getFolderFromName(i).Name:split(" ")[1]

            infoCuh[getFolderFromName(i)] = { i, tonumber(areaNum) }
        end
    end
    return infoCuh
end

function getNextArea()
    local small = 0
    local ownedAreasAndNums = getZoneInfo()

    for i, v in pairs(ownedAreasAndNums) do
        if v[2] > small then
            small = v[2]
        end
    end

    return small == 99 and nil or small + 1
end

local foundFolder
local foundNum
function getMaxArea()
    foundFolder = nil
    foundNum = nil
    local nextArea = getNextArea()
    for i, v in pairs(getZoneInfo()) do
        if v[2] == nextArea - 1 then
            foundFolder = i
            foundNum = nextArea - 1
        end
    end
    return { foundFolder, foundNum }
end

task.spawn(function()
    while task.wait() do
        game:GetService("ReplicatedStorage").Network["Mailbox: Claim All"]:InvokeServer()
        task.wait(30)
    end
end)


workspace.__THINGS.Lootbags.ChildAdded:Connect(function(v)
    task.wait(0.5)
    pcall(function()
        if v:IsA("Model") and v.PrimaryPart then
            wait()
            v.PrimaryPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            wait()
            game:GetService("ReplicatedStorage").Network.Lootbags_Claim:FireServer({ v.Name })
            wait()
            v.Parent = nil
        end
    end)
end)

workspace.__THINGS.Orbs.ChildAdded:Connect(function(v)
    task.wait(0.5)
    game:GetService("ReplicatedStorage").Network["Orbs: Collect"]:FireServer({ tonumber(v.Name) })
    wait()
    v.Parent = nil
end)

HttpService = game:GetService("HttpService")
TeleportService = game:GetService("TeleportService")
httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
function hop2()
    local servers = {}
    local req = httprequest({ Url = string.format(
    "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true", game.PlaceId) })
    local body = HttpService:JSONDecode(req.Body)
    if body and body.data then
        for i, v in next, body.data do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], game.Players
        .LocalPlayer)
    end
end

local function instanceControl(inst1, inst, ctrl)
    local oldTick = tick()
    repeat
        if ctrl then
            if not workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild(inst) then break end
        else
            if workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild(inst) then
                break
            end
        end

        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = inst1.CFrame
        firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, inst1, 0)
        wait()
        firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, inst1, 1)
        task.wait(3)
        if tick() - oldTick >= 120 then
            hop2()
        end
    until ctrl and not workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild(inst) or workspace.__THINGS.__INSTANCE_CONTAINER.Active:FindFirstChild(inst)
end


local manee = {}
for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.MainLeft.Left.Currency:GetDescendants()) do
    pcall(function()
        if v.Visible then
            table.insert(manee, v)
        end
    end)
end

local doingGarden = false
function main()
    if not doingGarden then
        doingGarden = true
        for i = 1, 10 do
            wait()
            Remote:InvokeServer("FlowerGarden", "ClaimPlant", i)
            Remote:InvokeServer("FlowerGarden", "PurchaseSlot", i)
            task.wait(1)
        end

        for i = 1, 10 do
            task.wait(0.5)
            Remote:InvokeServer("FlowerGarden", "PlantSeed", i, "Diamond")
            task.wait(1)
            Remote:InvokeServer("FlowerGarden", "WaterSeed", i)
            task.wait(1)
        end

        task.wait(1)

        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-451, 95, -1400)
        doingGarden = false
        if not isfile("lastPlant.txt") then
            writefile("lastPlant.txt", tostring(tick()))
        end
    end
end

local images = {
    "rbxassetid://15554896030",
    "rbxassetid://15554896174",
    "rbxassetid://15554896248",
}

local function ClickButton(btn)
    local events = { "MouseButton1Up", "MouseButton1Down", "MouseButton1Click", "Activated" }
    for _, event in pairs(events) do
        for _, evnt in pairs(getconnections(btn[event])) do
            evnt:Fire()
        end
    end
end

function claimMapGifts()
    pcall(function()
        for i, v in pairs(getupvalues(getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game.Misc["Hidden Presents"]).GetActive)) do
            for j, k in pairs(v) do
                game:GetService("ReplicatedStorage").Network["Hidden Presents: Found"]:InvokeServer(j)
            end
        end
    end)
end

local function buyGardenMerchant()
    task.spawn(function()
        while task.wait() do
            if doingGarden then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-451, 95, -1400)
                return
            end
            task.wait(1)
        end
    end)
    local oldPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
    pcall(function()
        claimMapGifts()
    end)

    local merchantXP = save.Get().MerchantExperience['GardenMerchant']

    for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui._MACHINES.Merchant.Frame.ItemsFrame.Items:GetChildren()) do
        if not v.Name:find("Slot") then continue end
        if merchantXP == 80000 then
            local cost = v.Buy.Cost.Amount.Text
            cost = cost:gsub(",", "")
            cost = tonumber(cost)

            local moneymouth = 0
            for i, v in pairs(save.Get().Inventory.Currency) do
                if v.id == 'Diamonds' then
                    moneymouth = v._am
                end
            end
            if table.find(images, v.ITEM.ItemSlot.Icon.Image) and not v.Locked.Visible and not v.Buy:FindFirstChild("GreyGradient") and moneymouth >= cost then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(259, 17, 2059)
                wait(1)

                local num = v.Name:gsub("Slot", "")

                num = tonumber(num)


                repeat
                    if doingGarden then break end
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(259, 17, 2059)
                    game:GetService("ReplicatedStorage").Network.Merchant_RequestPurchase:InvokeServer(
                        "GardenMerchant",
                        num)
                    if v.ITEM.ItemSlot.Icon.Image == "rbxassetid://15554896030" then
                        seedsBought = seedsBought + 1
                    end
                    task.wait(1)
                    for i, v in pairs(save.Get().Inventory.Currency) do
                        if v.id == 'Diamonds' then
                            moneymouth = v._am
                        end
                    end
                until v.Locked.Visible or v.Buy:FindFirstChild("GreyGradient") or moneymouth < cost
            end
        else
            local moneymouth = 0
            for i, v in pairs(save.Get().Inventory.Currency) do
                if v.id == 'Diamonds' then
                    moneymouth = v._am
                end
            end
            local cost = v.Buy.Cost.Amount.Text
            cost = cost:gsub(",", "")

            cost = tonumber(cost)

            if not v.Locked.Visible and not v.Buy:FindFirstChild("GreyGradient") and moneymouth >= cost then
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(259, 17, 2059)
                wait(1)
                local num = v.Name:gsub("Slot", "")

                num = tonumber(num)


                repeat
                    if doingGarden then break end
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(259, 17, 2059)

                    game:GetService("ReplicatedStorage").Network.Merchant_RequestPurchase:InvokeServer(
                        "GardenMerchant",
                        num)
                    if v.ITEM.ItemSlot.Icon.Image == "rbxassetid://15554896030" then
                        seedsBought = seedsBought + 1
                    end
                    task.wait(1)
                    for i, v in pairs(save.Get().Inventory.Currency) do
                        if v.id == 'Diamonds' then
                            moneymouth = v._am
                        end
                    end
                until v.Locked.Visible or v.Buy:FindFirstChild("GreyGradient") or moneymouth < cost
            end
        end
    end

    pcall(function()
        ClickButton(game:GetService("Players").LocalPlayer.PlayerGui._MACHINES.Merchant.Frame.Close)
    end)

    buyingGarden = false

    task.wait(1)

    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = oldPos
end


if getMaxArea()[2] >= 54 then
    buyingGarden = true

    local oldTick = tick()
    local timesUp = false
    repeat
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(259, 17, 2059)
        task.wait(3)
        if tick() - oldTick >= 6 then
            timesUp = true
            break
        end
    until game:GetService("Players").LocalPlayer.PlayerGui._MACHINES.Merchant.Enabled


    
    if timesUp then
        repeat
            local TweenService = game:GetService("TweenService")

            local character = game.Players.LocalPlayer.Character
            local hrp = character:WaitForChild("HumanoidRootPart")


            hrp.CFrame = CFrame.new(269, 17, 2058)
            task.wait(2)
            local info = TweenInfo.new(2)

            local tween = TweenService:Create(hrp, info, { CFrame = CFrame.new(250, 17, 2057) })
            tween:Play()
            tween.Completed:Wait()
            task.wait(3)
        until game:GetService("Players").LocalPlayer.PlayerGui._MACHINES.Merchant.Enabled or tick() - oldTick >= 100
    end

    buyingGarden = false

    buyGardenMerchant()



    task.spawn(function()
        while task.wait(20) do
            task.spawn(buyGardenMerchant)
        end
    end)

    instanceControl(workspace.__THINGS.Instances.FlowerGarden.Teleports.Enter, "FlowerGarden", false)

    task.wait(1)



    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-451, 95, -1400)
    task.wait(1)
    main()

    workspace.__THINGS.__INSTANCE_CONTAINER.Active.FlowerGarden.Plants.DescendantAdded:Connect(function(v)
        wait(0.1)
        pcall(function()
            if v:IsA("TextLabel") and v.Text == "Ready!" then
                seedsUsed = seedsUsed + 1
                if not doingGarden then
                    main()
                end
            end
        end)
    end)


    task.spawn(function()
        while task.wait(10) do
            for i, v in pairs(workspace.__THINGS.__INSTANCE_CONTAINER.Active.FlowerGarden.Plants:GetDescendants()) do
                pcall(function()
                    if v:IsA("TextLabel") and v.Text == "Ready!" and not doingGarden then
                        main()
                    end
                end)
            end
        end
    end)


    task.spawn(function()
        while task.wait(300) do
            main()
        end
    end)
end

local RunService = game:GetService("RunService")

for i, v in pairs(game:GetDescendants()) do
    if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("MeshPart") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
        v.Material = "Plastic"
        v.Reflectance = 0
    elseif v:IsA("Decal") then
        v.Transparency = 1
    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
        v.Lifetime = NumberRange.new(0)
    elseif v:IsA("Explosion") then
        v.BlastPressure = 1
        v.BlastRadius = 1
    end
end
task.spawn(function()
    workspace.DescendantAdded:Connect(function(child)
        task.spawn(function()
            if child:IsA('ForceField') then
                RunService.Heartbeat:Wait()
                child:Destroy()
            elseif child:IsA('Sparkles') then
                RunService.Heartbeat:Wait()
                child:Destroy()
            elseif child:IsA('Smoke') or child:IsA('Fire') then
                RunService.Heartbeat:Wait()
                child:Destroy()
            end
        end)
    end)
end)
