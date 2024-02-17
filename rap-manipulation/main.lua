game.Players.LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false

local Players = game:GetService("Players")
print("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
print("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild('Library'))
print("Library")
local Booths_Broadcast = ReplicatedStorage.Network:WaitForChild("Booths_Broadcast")
print("Booths_Broadcast")
local PlayerData = ""
local signal

local function listHuge(pos)
    print("listHuge(): pos: " .. tostring(pos))
    if not pos then pos = 1 end
    local Pet = Library.Save.Get().Inventory.Pet
    local hcount = #config["huges"]
    local hpos
    for i = pos, hcount+pos-1, 1 do
        hpos = (i%hcount)+1
        for petId, petData in pairs(Pet) do
            if string.find(petData["id"], "Huge") and string.find(petData["id"], config["huges"][hpos]["name"]) then
                print("listHuge(): hpos: " .. tostring(hpos) .. " | config: " .. tostring(config["huges"][hpos]["pt"]) .. ", " .. tostring(config["huges"][hpos]["sh"]) .. " | petData: " .. tostring(petData["pt"]) .. ", " .. tostring(petData["sh"]))
                if ((not config["huges"][hpos]["pt"] and not petData["pt"]) or (config["huges"][hpos]["pt"] and petData["pt"] and config["huges"][hpos]["pt"] == petData["pt"])) and ((not config["huges"][hpos]["sh"] and not petData["sh"]) or (config["huges"][hpos]["sh"] and petData["sh"] and config["huges"][hpos]["sh"] == petData["sh"])) then
                    local listingStatus = ReplicatedStorage.Network.Booths_CreateListing:InvokeServer(petId, config["huges"][hpos]["price"], 1)
                    print("listHuge(): listingStatus: " .. tostring(listingStatus))
                    return listingStatus
                end
            end
        end
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
        local purchaseStatus, purchaseMessage = ReplicatedStorage.Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print("tryPurchase(): purchaseStatus: " .. tostring(purchaseStatus))
        if purchaseStatus or not config["misc"]["stopOnPurchaseFail"] then
            listHuge(pos)
        end
    else
        print("tryPurchase(): purchaseStatus: false -> improper args")
        if not config["misc"]["stopOnPurchaseFail"] then
            listHuge(pos)
        end
    end
end

local function init()
    -- Initialize PlayerData
    print("init(): Initialize PlayerData...")
    for i = 1, #config["players"], 1 do
        PlayerData = PlayerData .. tostring(Players[config["players"][i]].UserId) .. "_"
    end
    print("init(): PlayerData: " .. PlayerData)

    -- Check for starting player, if true, add the first huge
    print("init(): Initialize add first huge...")
    if game.Players.LocalPlayer.Name == config["players"][1] then
        print("init(): start player detected. adding first huge...")
        listHuge()
    end

    print("init(): Initialize completed...")
    return true
end

print("SCRIPT STARTED...")

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
            local item = data["id"]
            local amount = tonumber(data["_am"]) or 1
            local playerid = message['PlayerID']
            local unitGems = gems / amount

            print("Booths_Broadcast: listing: " .. tostring(playerid) .. " | " .. tostring(uid) .. " | " .. tostring(item) .. " | " .. tostring(unitGems))

            for i = 1, #config["huges"], 1 do
                if string.find(PlayerData, tostring(playerid)) and string.find(item, config["huges"][i]["name"]) and unitGems == config["huges"][i]["price"] then
                    print("Booths_Broadcast: match found. calling tryPurchase...")
                    coroutine.wrap(tryPurchase)(uid, playerid, buytimestamp, i)
                end
            end
        end
    end
end)
