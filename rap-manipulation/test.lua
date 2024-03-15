loadstring(game:HttpGet("https://raw.githubusercontent.com/Black-o-Baron/luautils/main/printTable.lua"))()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Booths_Broadcast = ReplicatedStorage.Network:WaitForChild("Booths_Broadcast")

print("TESTING STARTED")

Booths_Broadcast.OnClientEvent:Connect(function(username, message)
    print("Booths_Broadcast called!")
    print(tostring(username) .. " ==>> " .. tostring(type(message)))
    if username == "MythicalDealer" and type(message) == "table" then
        printTable(message)
    end
end)