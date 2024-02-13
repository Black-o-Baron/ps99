--[[ -- No need for delay, cuz the script is executed manually after the game is loaded
if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(15)
]]

game.Players.LocalPlayer.PlayerScripts.Scripts.Core["Idle Tracking"].Enabled = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Booths_Broadcast = ReplicatedStorage.Network:WaitForChild("Booths_Broadcast")
local signal

--[[ -- Not necessary?
local Players = game:GetService('Players')
local vu = game:GetService("VirtualUser")
Players.LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)
]]

--=====================================================================================================--
-- local HUGEDATA = {
--     ["Huge Hologram Axolotl"] = {"cb8eda4d6593498e87e9901a5af48163", 79867890, "Huge Skeleton"},
--     ["Huge Skeleton"] = {"e23961d8fb554bfdb6a4419352994eea", 80560432, "Huge BIG Maskot"},
--     ["Huge BIG Maskot"] = {"ef4239db53904f0b9ff211c3dd330558", 81780654, "Huge Hologram Axolotl"}
-- }
local HUGEDATA = {
    ["545b0cda2e3a48ee9b8effa5434e27d7"] = {"Huge Neon Cat", 94567789, "e23961d8fb554bfdb6a4419352994eea"},
    ["e23961d8fb554bfdb6a4419352994eea"] = {"Huge Skeleton", 94578889, "ee42bb68f9a447b5a0c2b1b9b4a7d164"},
    ["ee42bb68f9a447b5a0c2b1b9b4a7d164"] = {"Huge Tiedye Cat", 94678789, "e2009a92586a4ae0bfdea27b00d69dac"},
    ["e2009a92586a4ae0bfdea27b00d69dac"] = {"Huge Fluffy Cat", 94568899, "545b0cda2e3a48ee9b8effa5434e27d7"}
}
--=====================================================================================================--

local function listHuge(hid)
    local args = {
        [1] = hid,
        [2] = HUGEDATA[hid][2],
        [3] = 1
    }
    ReplicatedStorage.Network.Booths_CreateListing:InvokeServer(unpack(args))
end

local function tryPurchase(uid, playerid, buytimestamp, hid)
    signal = game:GetService("RunService").Heartbeat:Connect(function()
        if buytimestamp < workspace:GetServerTimeNow() then
            signal:Disconnect()
            signal = nil
        end
    end)
    repeat task.wait() until signal == nil
    local purchaseStatus, purchaseMessage = ReplicatedStorage.Network.Booths_RequestPurchase:InvokeServer(playerid, uid)
    if purchaseStatus then
        listHuge(hid)
    end
end

print("--> BOOTH SNIPER STARTED <--")

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

            for hid, hvalues in pairs(HUGEDATA) do
                if string.find(item, hvalues[1]) and unitGems == hvalues[2] then
                    coroutine.wrap(tryPurchase)(uid, playerid, buytimestamp, hvalues[3])
                end
            end
        end
    end
end)
