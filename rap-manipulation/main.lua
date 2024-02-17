game.Players.LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false

if not config then
    os.exit()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild('Library'))
local Booths_Broadcast = ReplicatedStorage.Network:WaitForChild("Booths_Broadcast")
local PlayerData = ""
local signal

local function claimBooth()
    print("claimBooth(): Started...")
    local claimStatus
    for i = 1, 25, 1 do
        claimStatus = ReplicatedStorage.Network.Booths_ClaimBooth:InvokeServer(tostring(i))
        print("claimBooth(): i: " .. tostring(i) .. " | claimStatus: " .. tostring(claimStatus))
        if claimStatus then
            print("claimBooth(): Booth claimed!")
            break
        end
    end
    return true
end

local function listHuge(pos)
    print("listHuge(): pos: " .. tostring(pos))
    if not pos then pos = 1 end
    local Pet = Library.Save.Get().Inventory.Pet
    local hcount, listingStatus = #config["huges"], false
    local hpos
    for i = pos, hcount+pos-1, 1 do
        hpos = (i%hcount)+1
        for petId, petData in pairs(Pet) do
            local petName = string.lower(petData["id"])
            local petToFindName = string.lower(config["huges"][hpos]["name"])
            if string.find(petName, "huge") then
                print("listHuge(): config: " .. petToFindName .. " | petData: " .. petName)
                if string.find(petName, petToFindName) then
                    print("listHuge(): config: " .. tostring(config["huges"][hpos]["pt"]) .. ", " .. tostring(config["huges"][hpos]["sh"]) .. " | petData: " .. tostring(petData["pt"]) .. ", " .. tostring(petData["sh"]))
                    if ((not config["huges"][hpos]["pt"] and not petData["pt"]) or (config["huges"][hpos]["pt"] and petData["pt"] and config["huges"][hpos]["pt"] == petData["pt"])) and ((not config["huges"][hpos]["sh"] and not petData["sh"]) or (config["huges"][hpos]["sh"] and petData["sh"] and config["huges"][hpos]["sh"] == petData["sh"])) then
                        listingStatus = ReplicatedStorage.Network.Booths_CreateListing:InvokeServer(petId, config["huges"][hpos]["price"], 1)
                        print("listHuge(): listingStatus: " .. tostring(listingStatus))
                        listingStatus = true
                        break
                    end
                end
            end
        end
        if listingStatus then break end
    end
end

local function tryPurchase(uid, playerid, buytimestamp, pos)
    print("tryPurchase(): uid: " .. tostring(uid) .. " | playerid: " .. tostring(playerid) .. " | buytimestamp: " .. tostring(buytimestamp) .. " | pos: " .. tostring(pos))
    if uid and playerid and buytimestamp and pos then
        signal = game:GetService("RunService").Heartbeat:Connect(function()
            if buytimestamp < workspace:GetServerTimeNow() then
                signal:Disconnect()
                signal = nil
            end
        end)
        repeat task.wait() until signal == nil

        task.wait(math.random(3, 6)) -- Delay before purchase

        local purchaseStatus, purchaseMessage = ReplicatedStorage.Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print("tryPurchase(): purchaseStatus: " .. tostring(purchaseStatus) .. " | purchaseMessage: " .. tostring(purchaseMessage))
        if purchaseStatus then listHuge(pos) end
    else
        print("tryPurchase(): purchaseStatus: false -> improper args")
    end
end

local function init()
    -- Initialize PlayerData
    print("init(): Initialize PlayerData...")
    for i = 1, #config["players"], 1 do
        PlayerData = PlayerData .. tostring(Players[config["players"][i]].UserId) .. "_"
    end
    print("init(): PlayerData: " .. PlayerData)

    -- Initialize auto claim booth
    print("init(): Initialize auto claim booth...")
    repeat task.wait() until claimBooth()

    -- Check for starting player, if true, add the first huge
    print("init(): Initialize add first huge...")
    if game.Players.LocalPlayer.Name == config["players"][1] then
        print("init(): start player detected. adding first huge...")
        listHuge()
    end

    print("init(): Initialize completed...")
    return true
end

repeat task.wait() until init()

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
            local item = string.lower(data["id"])
            local amount = tonumber(data["_am"]) or 1
            local playerid = message['PlayerID']
            local unitGems = gems / amount

            print("Booths_Broadcast: listing: " .. tostring(playerid) .. " | " .. tostring(uid) .. " | " .. tostring(item) .. " | " .. tostring(unitGems))

            for i = 1, #config["huges"], 1 do
                if tostring(playerid) ~= tostring(Players.LocalPlayer.UserId) and string.find(PlayerData, tostring(playerid)) and string.find(item, string.lower(config["huges"][i]["name"])) and unitGems == config["huges"][i]["price"] then
                    print("Booths_Broadcast: match found. calling tryPurchase...")
                    coroutine.wrap(tryPurchase)(uid, playerid, buytimestamp, i)
                end
            end
        end
    end
end)
