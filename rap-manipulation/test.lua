loadstring(game:HttpGet("https://raw.githubusercontent.com/Black-o-Baron/luautils/main/printTable.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Booths_Broadcast = ReplicatedStorage.Network:WaitForChild("Booths_Broadcast")

print("TESTING STARTED")

Booths_Broadcast.OnClientEvent:Connect(function(username, message)
    if username == "MythicalDealer" and type(message) == "table" then
        print("Stage-1 OK.")
        printTable(message)
    end
end)