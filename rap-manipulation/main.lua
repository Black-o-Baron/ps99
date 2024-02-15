loadstring(game:HttpGet("https://raw.githubusercontent.com/Black-o-Baron/luautils/main/printTable.lua"))()

game.Players.LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild('Library'))
local Booths_Broadcast = require(ReplicatedStorage.Network:WaitForChild("Booths_Broadcast"))
local PlayerData = ""
local HugeData = {}
local signal

local function listHuge(hname)
    print("listHuge(): hname: " .. tostring(hname))
    if hname then
        local listingStatus = ReplicatedStorage.Network.Booths_CreateListing:InvokeServer(HugeData[hname][1], HugeData[hname][2], 1)
        print("listHuge(): listingStatus: " .. tostring(listingStatus))
    else
        print("listHuge(): listingStatus: false -> improper args")
    end
end

local function tryPurchase(uid, playerid, buytimestamp, hname)
    print("tryPurchase(): uid: " .. tostring(uid) .. " | playerid: " .. tostring(playerid) .. " | buytimestamp: " .. tostring(buytimestamp) .. " | hname: " .. tostring(hname))
    if uid and playerid and buytimestamp and hname then
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
            listHuge(hname)
        end
    else
        print("tryPurchase(): purchaseStatus: false -> improper args")
        if not config["misc"]["stopOnPurchaseFail"] then
            listHuge(hname)
        end
    end
end

local function init()
    local Pet = Library.Save.Get().Inventory.Pet

    -- Initialize start in config
    print("init(): Initialize start in config...")
    config["start"] = {
        ["player"] = config["players"][1],
        ["huge"] = config["huges"][1]["name"]
    }
    print("init(): start.player: " .. config["start"]["player"] .. " | start.huge: " .. config["start"]["huge"])

    -- Initialize PlayerData
    print("init(): Initialize PlayerData...")
    for i = 1, #config["players"], 1 do
        PlayerData = PlayerData .. tostring(Players[config["players"][i]].UserId) .. "_"
    end
    print("init(): PlayerData: " .. PlayerData)

    -- Initialize HugeData
    print("init(): Initialize HugeData...")
    for i = 1, #config["huges"], 1 do
        for petId, petData in pairs(Pet) do
            if string.find(petData["id"], "Huge") and string.find(petData["id"], config["huges"][i]["name"]) then
                print("init(): i: " .. tostring(i) .. " | petData[\"id\"]: " .. petData["id"] .. " | config: " .. tostring(config["huges"][i]["pt"]) .. ", " .. tostring(config["huges"][i]["sh"]) .. " | petData: " .. tostring(petData["pt"]) .. ", " .. tostring(petData["sh"]))
                if ((not config["huges"][i]["pt"] and not petData["pt"]) or (config["huges"][i]["pt"] and petData["pt"] and config["huges"][i]["pt"] == petData["pt"])) and ((not config["huges"][i]["sh"] and not petData["sh"]) or (config["huges"][i]["sh"] and petData["sh"] and config["huges"][i]["sh"] == petData["sh"])) then
                    HugeData[config["huges"][i]["name"]] = {petId, config["huges"][i]["price"], config["huges"][(i%3)+1]["name"]}
                end
            end
        end
    end
    print("init(): HugeData:")
    printTable(HugeData, "HugeData")

    -- Check for starting player, if true, add the first huge
    print("init(): Initialize add first huge...")
    if game.Players.LocalPlayer.Name == config["start"]["player"] then
        print("init(): start player detected. adding first huge...")
        listHuge(config["start"]["huge"])
    end

    task.wait(2)

    print("init(): Initialize completed...")
    return true
end

repeat task.wait() until init()

print("--> BOOTH SNIPER READY <--")

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

            print("Booths_Broadcast: listing: " .. tostring(item) .. " | " .. tostring(playerid) .. " | " .. tostring(uid))

            for hname, hvalues in pairs(HugeData) do
                if string.find(PlayerData, tostring(playerid)) and string.find(item, hname) and unitGems == hvalues[2] then
                    print("Booths_Broadcast: match found. calling tryPurchase...")
                    coroutine.wrap(tryPurchase)(uid, playerid, buytimestamp, hvalues[3])
                end
            end
        end
    end
end)
