if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(15)

if not settings then os.exit() end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Library = require(ReplicatedStorage:WaitForChild('Library'))
local Booths_Broadcast = ReplicatedStorage.Network:WaitForChild("Booths_Broadcast")

local osclock = os.clock()
local LocalPlayer = Players.LocalPlayer
local prices, isPrimary = {}, false
local signal

local internalSettings = {
    ["PlaceId"] = 15502339080,
    ["target"] = settings["players"][1] ~= LocalPlayer.Name and settings["players"][1] or settings["players"][2],
    ["init"] = {
        ["addFirstHugeDelay"] = 30
    }
}

print(internalSettings["PlaceId"])
print(internalSettings["target"])
print(internalSettings["init"]["addFirstHugeDelay"])

LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false

local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:connect(function()
   VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
   task.wait(1)
   VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)

local function serverHop(PlaceId, joinLowPlayerServer)
    print("serverHop(): PlaceId: " .. tostring(PlaceId) .. " | joinLowPlayerServer: " .. tostring(joinLowPlayerServer))
    local retries = 0
    local config = {
        ["url"] = {
            ["sortOrder"] = joinLowPlayerServer and "Asc" or "Desc",
            ["resultsLimit"] = 100
        },
        ["servers"] = {
            ["ping"] = 100,
            ["playing"] = 2
        },
        ["retries"] = {
            ["limit"] = 3,
            ["delay"] = 2
        },
        ["delay"] = 5
    }
    if retries < config["retries"]["limit"] then
        local sfUrl = "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=%s&excludeFullGames=true"
        local req = request({ Url = string.format(sfUrl, PlaceId, config["url"]["sortOrder"], config["url"]["resultsLimit"]) })
        local body = game:GetService("HttpService"):JSONDecode(req.Body)
        if body and body.data then
            local servers, playing = {}, 1
            repeat
                for i, v in next, body.data do
                    if type(v) == "table" then
                        if v.playing > playing then break end
                        if v.id ~= game.JobId and v.playing == playing and v.ping < config["servers"]["ping"] then
                            table.insert(servers, 1, v.id)
                        end
                    end
                end
                playing = playing + 1
            until #servers > 0 or playing > config["servers"]["playing"]
            if #servers == 0 then
                retries = retries + 1
                print("serverHop(): No servers available with " .. config["servers"]["playing"] " playing. Retrying " .. tostring(retries) .. "/3.")
                task.wait(config["retries"]["delay"])
                serverHop(PlaceId, joinLowPlayerServer)
            else
                print("serverHop(): Server hopping in " .. tostring(config["delay"]) .. " seconds...")
                task.wait(config["delay"])
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            end
        else
            retries = retries + 1
            print("serverHop(): Error in response. Retrying " .. tostring(retries) .. "/3.")
            task.wait(config["retries"]["delay"])
            serverHop(PlaceId, joinLowPlayerServer)
        end
    else
        print("[FAIL] serverHop(): Error while trying to join.")
    end
end

local function joinFriend(UserName)
    print("joinFriend(): UserName: " .. tostring(UserName))
    local PlaceId, GameId

    local retries = 0
    local config = {
        ["retries"] = {
            ["limit"] = 3,
            ["delay"] = 2
        },
        ["delay"] = 5
        
    }
    if retries < config["retries"]["limit"] then
        local success, result = pcall(LocalPlayer.GetFriendsOnline, LocalPlayer)
        print("joinFriend(): success: " .. tostring(success))
        if success then
            for _, friend in pairs(result) do
                if friend.UserName == UserName then
                    PlaceId = friend.PlaceId
                    GameId = friend.GameId
                    break
                end
            end
            print("joinFriend(): GameId: " .. tostring(GameId))
            if GameId then
                print("joinFriend(): Joining friend in " .. tostring(config["delay"]) .. " seconds...")
                task.wait(config["delay"])
                game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceId, GameId, LocalPlayer)
            else
                retries = retries + 1
                print("joinFriend(): " .. UserName .. " is either OFFLINE or NOT ADDED AS FRIEND. Retrying " .. tostring(retries) .. "/3.")
                task.wait(config["retries"]["delay"])
                joinFriend(UserName)
            end
        else
            retries = retries + 1
            print("joinFriend(): Failed to get online players: " .. tostring(result) .. ". Retrying " .. tostring(retries) .. "/3.")
            task.wait(config["retries"]["delay"])
            joinFriend(UserName)
        end
    else
        print("[FAIL] joinFriend(): Error while trying to join friend. Try checking Privacy Settings")
    end
end

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
    if claimStatus then
        return true
    else
        -- TODO: Add retries...
        print("[FAIL] claimBooth(): Error while trying to claim booth.")
        return false
    end
end

local function listHuge(pos)
    print("listHuge(): pos: " .. tostring(pos))

    if not pos then pos = 1 end

    local config = {
        ["delay"] = {
            ["min"] = 2,
            ["max"] = 3
        }
    }
    local Pet = Library.Save.Get().Inventory.Pet
    local hcount, listingStatus = #settings["huges"], false
    local hpos, petName, petToFindName
    for i = pos, hcount+pos-1, 1 do
        hpos = (i%hcount)+1
        for petId, petData in pairs(Pet) do
            petName, petToFindName = string.lower(petData["id"]), string.lower(settings["huges"][hpos]["name"])
            if string.find(petName, "huge") then
                print("listHuge(): config: " .. petToFindName .. " | petData: " .. petName)
                if string.find(petName, petToFindName) then
                    print("listHuge(): config: " .. tostring(settings["huges"][hpos]["pt"]) .. ", " .. tostring(settings["huges"][hpos]["sh"]) .. " | petData: " .. tostring(petData["pt"]) .. ", " .. tostring(petData["sh"]))
                    if petData["pt"] == settings["huges"][hpos]["pt"] and petData["sh"] == settings["huges"][hpos]["sh"] then
                        local targetDiamonds, n = Players[internalSettings["target"]].leaderstats["💎 Diamonds"].Value, #prices
                        if targetDiamonds < settings["price"]["max"] then
                            n = ((targetDiamonds - settings["price"]["init"]) // settings["price"]["step"]) + 1
                        end
                        task.wait(math.random(config["delay"]["min"], config["delay"]["max"])) -- Delay before listing
                        listingStatus = ReplicatedStorage.Network.Booths_CreateListing:InvokeServer(petId, prices[math.random(1, n)], 1)
                        print("listHuge(): listingStatus: " .. tostring(listingStatus))
                        if not listingStatus then
                            listingStatus = true -- To avoid adding multiple huges in loop, booth sniper fails to buy the huges.
                            print("[FAIL] listHuge(): Error while trying to list huge.")
                        end
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
        local config = {
            ["delay"] = {
                ["min"] = 2,
                ["max"] = 3
            },
            ["serverHop"] = {
                ["min"] = 840,
                ["max"] = 900
            }
        }
        signal = game:GetService("RunService").Heartbeat:Connect(function()
            if buytimestamp < workspace:GetServerTimeNow() then
                signal:Disconnect()
                signal = nil
            end
        end)
        repeat task.wait() until signal == nil
        task.wait(math.random(config["delay"]["min"], config["delay"]["max"])) -- Delay before purchase
        local purchaseStatus, purchaseMessage = ReplicatedStorage.Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
        print("tryPurchase(): purchaseStatus: " .. tostring(purchaseStatus) .. " | purchaseMessage: " .. tostring(purchaseMessage))
        if purchaseStatus then
            if isPrimary and math.floor(os.clock() - osclock) >= math.random(config["serverHop"]["min"], config["serverHop"]["max"]) then
                serverHop(internalSettings["PlaceId"], true)
            else
                listHuge(pos)
            end
        else
            print("[FAIL] tryPurchase(): Error while trying to purchase.")
        end
    else
        print("[FAIL] tryPurchase(): purchaseStatus: false -> improper args")
    end
end

local function init()
    -- Initialize prices
    print("init(): Initialize prices...")
    for i=settings["price"]["init"], settings["price"]["max"], settings["price"]["step"] do
        table.insert(prices, i)
    end

    -- Initialize auto claim booth
    print("init(): Initialize auto claim booth...")
    repeat task.wait() until claimBooth()

    -- Check for starting player, if true, add the first huge
    print("init(): Initialize primary player check...")
    isPrimary = LocalPlayer.leaderstats["💎 Diamonds"].Value < settings["price"]["init"]
    print("init(): isPrimary: " .. tostring(isPrimary))
    if isPrimary then
        local targetFound = false
        for _, player in Players:GetPlayers() do
            if player.Name == internalSettings["target"] then
                targetFound = true
                break
            end
        end
        print("init(): targetFound: " .. tostring(targetFound))
        if not targetFound then
            signal = Players.PlayerAdded:Connect(function(player)
                if player.Name == internalSettings["target"] then
                    print("init(): target found")
                    signal:Disconnect()
                    signal = nil
                end
            end)
            repeat task.wait() until signal == nil
            task.wait(internalSettings["init"]["addFirstHugeDelay"])
        end
        listHuge()
    else
        Players.PlayerRemoving:Connect(function(player)
            if player.Name == internalSettings["target"] then
                task.wait(2)
                joinFriend(player.Name)
            end
        end)
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

            print("Booths_Broadcast: username: " .. tostring(username) .. " | playerid: " .. tostring(playerid) .. " | uid: " .. tostring(uid) .. " | item: " .. tostring(item) .. " | unitGems: " .. tostring(unitGems))

            for i = 1, #settings["huges"], 1 do
                if username == internalSettings["target"] and string.find(item, string.lower(settings["huges"][i]["name"])) then
                    print("Booths_Broadcast: match found. calling tryPurchase...")
                    coroutine.wrap(tryPurchase)(uid, playerid, buytimestamp, i)
                end
            end
        end
    end
end)
