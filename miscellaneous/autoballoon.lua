repeat task.wait() until game:IsLoaded() and game:GetService("ReplicatedStorage") and game:GetService("ReplicatedStorage"):FindFirstChild("Network") and game:GetService("ReplicatedStorage").Network:FindFirstChild("BalloonGifts_GetActiveBalloons")
repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("Main") and game:GetService("ReplicatedStorage"):FindFirstChild("Library") and game:GetService("ReplicatedStorage").Library:FindFirstChild("Client") and game:GetService("ReplicatedStorage").Library.Client:FindFirstChild("Save")
--queueonteleport("loadstring(readfile('balloon.lua'))()")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer
local giftMeshId = "rbxassetid://15239110635"
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

function clickCoin(stringID)
    game:GetService("ReplicatedStorage").Network.Breakables_PlayerDealDamage:FireServer(stringID)
end

getgenv().autoBalloonConfig = {
    START_DELAY = 1,      -- delay before starting
    SERVER_HOP = true,    -- server hop after popping balloons
    SERVER_HOP_DELAY = 1, -- delay before server hopping
    BALLOON_DELAY = 0.3,  -- delay before popping next balloon (if there are multiple balloons in the server)
    GET_BALLOON_DELAY = 1 -- delay before getting balloons again if none are detected
}

task.wait(getgenv().autoBalloonConfig.START_DELAY)

loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/antiStaff.lua"))()

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
        if not v.Popped then
            allPopped = false
   
            balloonIds[i] = v
        end
    end

    if allPopped then
        print("No balloons detected, waiting " .. getgenv().autoBalloonConfig.GET_BALLOON_DELAY .. " seconds")
        if getgenv().autoBalloonConfig.SERVER_HOP then
            while task.wait() do
            loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/serverhop.lua"))()
            task.wait(1)
            end
        end
        task.wait(getgenv().autoBalloonConfig.GET_BALLOON_DELAY)
        continue
    end

    if not getgenv().autoBalloon then
        break
    end

    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame


    for balloonId, balloonData in pairs(balloonIds) do

        local balloonPosition = balloonData.Position

        ReplicatedStorage.Network.Slingshot_Toggle:InvokeServer()

        task.wait(0.5)

        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(balloonPosition.X, balloonPosition.Y + 30,
            balloonPosition.Z)
        task.wait(0.5)
        LocalPlayer.Character.HumanoidRootPart.Anchored = true

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

        task.wait(0.5)

        ReplicatedStorage.Network.Slingshot_Unequip:InvokeServer()
        
        LocalPlayer.Character.HumanoidRootPart.Anchored = false

        
        local foundGift = false
        local oldTick = tick()
        repeat 

        for i, v in pairs(workspace.__THINGS.Breakables:GetChildren()) do
            if v:FindFirstChildOfClass("MeshPart") and v:FindFirstChildOfClass("MeshPart").MeshId == giftMeshId then
                foundGift = true
               
                repeat
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v:FindFirstChildOfClass("MeshPart")
                    .CFrame
                    wait()
                    clickCoin(v.Name)
                until v.Parent == nil
                break
            end
        end
        task.wait(1)
    until foundGift or tick() - oldTick >= 10

        print("Popped balloon, waiting " .. tostring(getgenv().autoBalloonConfig.BALLOON_DELAY) .. " seconds")
        task.wait(getgenv().autoBalloonConfig.BALLOON_DELAY)
    end

    if getgenv().autoBalloonConfig.SERVER_HOP then
        while task.wait() do
            loadstring(game:HttpGet("https://raw.githubusercontent.com/fdvll/pet-simulator-99/main/serverhop.lua"))()
            task.wait(1)
        end
    end

    LocalPlayer.Character.HumanoidRootPart.Anchored = false
    LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
end
