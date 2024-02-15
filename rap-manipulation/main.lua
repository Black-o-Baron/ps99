game.Players.LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Booths_Broadcast = ReplicatedStorage.Network:WaitForChild("Booths_Broadcast")
local PlayerData = ""
local HugeData = {}
local signal

--[[ ~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~ ]]

--[[
    [<full-huge-name>] = {
        ["pt"] = 1 for golden | 2 for rainbow | <REMOVE KEY FOR NORMAL>,
        ["sh"] = true for shiny | <REMOVE KEY FOR NON-SHINY>
        ["price"] = Target Purchase value
        ["next"] = <full-huge-name> of next huge added in the list -> for 3 huges, 1st has 2nd, 2nd has 3rd and 3rd has 1st huge's full name
    }
]]

local config = {
    ["start"] = {
        ["player"] = "LoneByte_Alt1", -- Username of the starting player, case-sensitive
        ["huge"] = "Huge Painted Cat" -- Exact name of the Huge, case-sensitive
    },
    ["players"] = {"LoneByte_Alt1", "LoneByte_Alt2"}, -- Usernames of target players, case-sensitive
    ["huges"] = {
        ["Huge Painted Cat"] = {
            ["price"] = 79867890,
            ["next"] = "Huge Colorful Slime"
        },
        ["Huge Colorful Slime"] = {
            ["price"] = 80560432,
            ["next"] = "Huge Hell Rock"
        },
        ["Huge Hell Rock"] = {
            ["price"] = 81780654,
            ["next"] = "Huge Painted Cat"
        }
    }
}

--[[ ~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~.~ ]]

local function listHuge(hname)
    local args = {
        [1] = HugeData[hname][1],
        [2] = HugeData[hname][2],
        [3] = 1
    }
    ReplicatedStorage.Network.Booths_CreateListing:InvokeServer(unpack(args))
end

local function tryPurchase(uid, playerid, buytimestamp, hname)
    signal = game:GetService("RunService").Heartbeat:Connect(function()
        if buytimestamp < workspace:GetServerTimeNow() then
            signal:Disconnect()
            signal = nil
        end
    end)
    repeat task.wait() until signal == nil
    local purchaseStatus, purchaseMessage = ReplicatedStorage.Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
    if purchaseStatus then
        listHuge(hname)
    end
end

local function init()
    -- Initialize PlayerData
    for i = 1, #config["players"], 1 do
        PlayerData = PlayerData .. tostring(Players[config["players"][i]].UserId) .. "_"
    end

    task.wait(2)

    -- Initialize HugeData
    local Pet = Library.Save.Get().Inventory.Pet
    for hkey, hvalues in pairs(config["huges"]) do
        for petId, petData in pairs(Pet) do
            if string.find(petData["id"], hkey) and ((not hvalues["pt"] and not petData["pt"]) or (hvalues["pt"] and petData["pt"] and hvalues["pt"] == petData["pt"])) and ((not hvalues["sh"] and not petData["sh"]) or (hvalues["sh"] and petData["sh"] and hvalues["sh"] == petData["sh"])) then
                HugeData[hkey] = {petId, hvalues["price"], hvalues["next"]}
            end
        end
    end

    task.wait(2)

    -- Check for starting player, if true, add the first huge
    if game.Players.LocalPlayer.Name == config["start"]["player"] then
        listHuge(config["start"]["huge"])
    end

    task.wait(2)
    return true
end

repeat
    task.wait()
until init()

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

            print("ITEM NAME: " .. item)

            for hname, hvalues in pairs(HugeData) do
                if string.find(PlayerData, tostring(playerid)) and string.find(item, hname) and unitGems == hvalues[2] then
                    coroutine.wrap(tryPurchase)(uid, playerid, buytimestamp, hvalues[3])
                end
            end
        end
    end
end)
