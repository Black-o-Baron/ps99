if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(5)
game.Players.LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlantSeed, InstaGrowSeed, ClaimPlant

----------------------------------------
local HowManyInstaCapsulesYouHave = 100
----------------------------------------

for x = 1, HowManyInstaCapsulesYouHave, 1 do
    task.wait(1)
    PlantSeed = {
        [1] = "FlowerGarden",
        [2] = "PlantSeed",
        [3] = 1, -- 1 to 10
        [4] = "Diamond"
    }
    ReplicatedStorage.Network.Instancing_InvokeCustomFromClient:InvokeServer(unpack(PlantSeed))
    InstaGrowSeed = {
        [1] = "FlowerGarden",
        [2] = "InstaGrowSeed",
        [3] = 1 -- 1 to 10
    }
    ReplicatedStorage.Network.Instancing_InvokeCustomFromClient:InvokeServer(unpack(InstaGrowSeed))
    ClaimPlant = {
        [1] = "FlowerGarden",
        [2] = "ClaimPlant",
        [3] = 1 -- 1 to 10
    }
    ReplicatedStorage.Network.Instancing_FireCustomFromClient:FireServer(unpack(ClaimPlant))
end
