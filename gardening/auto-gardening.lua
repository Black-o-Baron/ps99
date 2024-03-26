getgenv().autoGarden = true
getgenv().InstaPlant = false
getgenv().Water = true

task.wait(10)

local Player = game:GetService("Players").LocalPlayer
local RepStor = game.ReplicatedStorage
local Library = require(RepStor.Library)
local HRP = Player.Character.HumanoidRootPart
local saveMod = require(RepStor.Library.Client.Save)

local args

function getDiamonds() return Player.leaderstats["💎 Diamonds"].Value end

function getInfo(name) return saveMod.Get()[name] end

if not game:IsLoaded() then
    game.Loaded:Wait()
end

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

-- AUTO ORB
local autoOrbConnection = nil
local autoLootBagConnection = nil
for i, v in workspace.__THINGS.Orbs:GetChildren() do
    Library.Network.Fire("Orbs: Collect", { tonumber(v.Name) })
    Library.Network.Fire("Orbs_ClaimMultiple", { [1] = { [1] = v.Name } })
    task.wait()
    v:Destroy()
end
for i, v in workspace.__THINGS.Lootbags:GetChildren() do
    Library.Network.Fire("Lootbags_Claim", { v.Name })
    task.wait()
    v:Destroy()
end
autoOrbConnection = workspace.__THINGS.Orbs.ChildAdded:Connect(function(v)
    Library.Network.Fire("Orbs: Collect", { tonumber(v.Name) })
    Library.Network.Fire("Orbs_ClaimMultiple", { [1] = { [1] = v.Name } })
    task.wait()
    v:Destroy()
end)
autoLootBagConnection = workspace.__THINGS.Lootbags.ChildAdded:Connect(function(v)
    Library.Network.Fire("Lootbags_Claim", { v.Name })
    task.wait()
    v:Destroy()
end)

print("AUTO GARDENING START...")

while getgenv().autoGarden do

    print("LOOP START...")

    print("Teleporting to the Garden Merchant area...")
    HRP.CFrame = CFrame.new(260, 16, 2145) -- TP to Garden Merchant area center point
    task.wait(10)                          -- Added delay here just incase of unexpected lag during teleport

    print("Teleporting to Garden entry door...")
    HRP.CFrame = CFrame.new(184, 23, 1989)    -- TP to gardening entry door
    task.wait(30)                             -- Added delay here just incase of unexpected lag during teleport

    print("Teleporting to to center pot...")
    HRP.CFrame = CFrame.new(-449, 110, -1399) -- TP to center pot

    task.wait(10)
    for i = 1, 10, 1 do
        Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "PlantSeed", i, "Diamond")
        task.wait(5)
        Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "WaterSeed", i)
        task.wait(5)
        Library.Network.Invoke("Instancing_InvokeCustomFromClient", "FlowerGarden", "ClaimPlant", i)
        task.wait(5)
    end
    task.wait(10)

    print("Teleporting to Garden exit door...")
    HRP.CFrame = CFrame.new(-533, 108, -1401) -- TP to gardening exit door
    task.wait(30)                             -- Added delay here just incase of unexpected lag during teleport

    for i = 1, 10, 1 do

        print("Teleporting to Advanced Merchant area...")
        HRP.CFrame = CFrame.new(819, 16, 1493) -- TP to Advanced Merchant area center point
        task.wait(30)

        for i = 1, 6 do
            args = {
                [1] = "AdvancedMerchant",
                [2] = i
            }
            for i = 1, 5 do
                task.wait(1)
                game:GetService("ReplicatedStorage").Network.Merchant_RequestPurchase:InvokeServer(unpack(args))
            end
            task.wait(1)
        end

        task.wait(30)

        print("Teleporting to Garden Merchant Area...")
        HRP.CFrame = CFrame.new(260, 16, 2145) -- TP to Garden Merchant area center point
        task.wait(30)

        for i = 1, 6 do
            args = {
                [1] = "GardenMerchant",
                [2] = i
            }
            for i = 1, 5 do
                task.wait(1)
                game:GetService("ReplicatedStorage").Network.Merchant_RequestPurchase:InvokeServer(unpack(args))
            end
            task.wait(1)
        end

        task.wait(30)

    end

    print("LOOP DONE...")

    task.wait(1)

end
