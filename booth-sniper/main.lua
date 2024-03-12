local settings = {
    {
        item = "Mini Pinata",
        maxPrice = 51000,
        class = "Misc"
    }
}

local tpToBooth = false
local discordwebhook =
"https://discord.com/api/webhooks/1215003357761114143/KADsp0Ad5hdCMaHll_9SViyWusTXTA4idz6_SrKCAI9oURxFBiTv1LgbjiF0-zwwBTDF"

local function formatPrice(price)
    if price >= 1000 then
        local suffixes = { "", "k", "m", "b", "t" } -- Add more suffixes as needed
        local suffixIndex = 1

        while price >= 1000 do
            price = price / 1000
            suffixIndex = suffixIndex + 1
        end

        return string.format("%.0f%s", price, suffixes[suffixIndex])
    else
        return tostring(price)
    end
end
local function webhook(type, amt, price, seller, left)
    url = discordwebhook
    local data = {
        ["content"] = "",
        ["username"] = "snipe webhook",
        ["embeds"] = {
            {
                ["type"] = "rich",
                ["color"] = 16711680,
                ["author"] = {
                    ["name"] = "Gems left: " .. formatPrice(left),
                },
                ["fields"] = {
                    {
                        ["name"] = "Seller",
                        ["value"] = seller,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Item",
                        ["value"] = type,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Quantity",
                        ["value"] = amt,
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Price",
                        ["value"] = formatPrice(price) .. " Diamonds (" .. formatPrice((amt * price)) .. ")",
                        ["inline"] = false
                    }
                }

            }
        }
    }
    local newdata = game:GetService("HttpService"):JSONEncode(data)

    local headers = {
        ["content-type"] = "application/json"
    }

    request = http_request or request or HttpPost or syn.request
    local a = { Url = url, Body = newdata, Method = "POST", Headers = headers }

    request(a)
end

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.PlaceId ~= nil
repeat task.wait() until not game.Players.LocalPlayer.PlayerGui:FindFirstChild("__INTRO")
repeat task.wait() until game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
if game.PlaceId == 8737899170 or game.PlaceId == 16498369169 then
    local map = game:GetService("Workspace"):FindFirstChild('Map') or game:GetService("Workspace"):FindFirstChild('Map2')
    repeat task.wait() until #map:GetChildren() >= 25
    game:GetService("TeleportService"):Teleport(15502339080, game.Players.LocalPlayer)
elseif game.PlaceId == 15502339080 then
    repeat task.wait() until game:GetService("Workspace").__THINGS and game:GetService("Workspace").__DEBRIS
else
    print("wtf r u doing? what game r u even on dumb fuck")
end

repeat
    task.wait()
until game:GetService("Players").LocalPlayer:FindFirstChild("PlayerScripts")
    :FindFirstChild("Scripts")
    :FindFirstChild("Game")
    :FindFirstChild("Trading Plaza")
    :FindFirstChild("Booths Frontend")

print("loaded")

e = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts.Scripts.Game["Trading Plaza"]["Booths Frontend"])
local save = require(game:GetService("ReplicatedStorage").Library.Client.Save)

if not isfolder("butterTerminalFinder") then
    makefolder("butterTerminalFinder")
    task.wait(0.1)
    writefile("butterTerminalFinder/hasHopped.txt", "false")
end

local function getUserFromId(id)
    for i, v in pairs(game.Players:GetPlayers()) do
        if v.UserId == id then
            return v.DisplayName
        end
    end
    return nil
end

local inv
repeat
    task.wait()
    pcall(function() inv = save.Get()['Inventory'] end)
until inv ~= nil

local money = 0
for i, v in pairs(save.Get().Inventory.Currency) do
    if v.id == 'Diamonds' then
        money = v._am
    end
end

local randTable
local function infoHanlder()
    randTable = settings[math.random(1, #settings)]
    local ohString2
    if not randTable.tier then
        ohString2 = "{\"id\":\"" .. randTable.item .. "\"}"
    else
        ohString2 = string.format("{\"id\":\"" .. randTable.item .. "\",\"tn\":%d}", randTable.tier)
    end
    print('looking for item: ' .. randTable.item)

    local ohNil3 = nil
    local ohBoolean4 = true
    local info
    pcall(function()
        info = game:GetService("ReplicatedStorage").Network.TradingTerminal_Search:InvokeServer(
            randTable.class, ohString2,
            ohNil3,
            ohBoolean4)
    end)
    if info == nil then
        local info
        repeat
            pcall(function()
                info = game:GetService("ReplicatedStorage").Network.TradingTerminal_Search:InvokeServer(
                    randTable.class, ohString2,
                    ohNil3,
                    ohBoolean4)
                task.wait(1)
                randTable = settings[math.random(1, #settings)]
                if not randTable.tier then
                    ohString2 = "{\"id\":\"" .. randTable.item .. "\"}"
                else
                    ohString2 = string.format("{\"id\":\"" .. randTable.item .. "\",\"tn\":%d}", randTable.tier)
                end
            end)
        until info ~= nil

        task.wait(3)
        game:GetService("TeleportService"):TeleportToPlaceInstance(info.place_id, info.job_id, game.Players.LocalPlayer)
        writefile("butterTerminalFinder/hasHopped.txt", 'true')
    else
        game:GetService("TeleportService"):TeleportToPlaceInstance(info.place_id, info.job_id, game.Players.LocalPlayer)
        writefile("butterTerminalFinder/hasHopped.txt", 'true')
    end
end

if readfile("butterTerminalFinder/hasHopped.txt") == "false" then
    infoHanlder()
else
    print("looking for booth")

    for i, k in pairs(game.Players:GetPlayers()) do
        suc, _ = pcall(function()
            local f = e.getByOwnerId(k.UserId).Listings
        end)
        if suc then
            if tpToBooth then
                for a, s in pairs(workspace.__THINGS.Booths:GetChildren()) do
                    if s.Info.BoothBottom.Frame.Top.Text:find(k.DisplayName) then
                        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = s.Table.CFrame * CFrame.new(5, 0, 0)
                    end
                end
            end

            for i, v in pairs(e.getByOwnerId(k.UserId).Listings) do
                if not v['Item'] then continue end
                for n, l in pairs(settings) do
                    local cost = v.DiamondCost
                    local itemType = v.Item._data.id
                    local amt = v.Item._data._am
                    if amt ~= nil and cost ~= nil and money >= amt * cost then
                        if cost <= l.maxPrice and itemType == l.item then
                            if v.Item._data['tn'] then
                                if tonumber(v.Item._data['tn']) ~= l.tier then
                                    continue
                                end
                            end

                            print('xd?')

                            print(i)
                            if not i then
                                writefile("butterTerminalFinder/hasHopped.txt", "false")
                                infoHanlder()
                            else
                                local ohTable2 = {
                                    [i] = amt
                                }

                                game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(
                                    k.UserId,
                                    ohTable2)
                                webhook(itemType, amt, cost, k.DisplayName, (money - (cost * amt)))
                                task.wait(2)
                            end
                        end
                    else
                        if amt ~= nil and cost ~= nil then
                            local newAmt = math.floor(money / cost)
                            if cost <= l.maxPrice and itemType == l.item then
                                print(i)
                                print('xd?')
                                if not i then
                                    writefile("butterTerminalFinder/hasHopped.txt", "false")
                                    infoHanlder()
                                else
                                    local ohTable2 = {
                                        [i] = newAmt
                                    }

                                    game:GetService("ReplicatedStorage").Network.Booths_RequestPurchase:InvokeServer(
                                        k.UserId,
                                        ohTable2)

                                    webhook(itemType, amt, cost, k.DisplayName, (money - (cost * amt)))
                                    task.wait(2)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    task.wait(0.3)
    print("looking thru files")
    task.wait(2)
    writefile("butterTerminalFinder/hasHopped.txt", "false")
    while true do
        infoHanlder()
        task.wait(1)
    end
end
