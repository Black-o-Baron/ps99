--[[
Credits: Aniqami#0001(@aniqami)
]]
local Lib = require(game.ReplicatedStorage:WaitForChild('Library'))

local function findItem(Type, Id)
    local save = Lib.Save.Get().Inventory
    if save[Type] then
        for i,v in pairs(save[Type]) do
            if v.id == Id then
                local AM = (v._am) or 1
                return i, AM
            end
        end
    end
end

local i, AM = findItem("Misc", "Bucket")

print(i)

while true do
    local args = {
        [1] = i,
        [2] = 100000,
        [3] = 10
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Booths_CreateListing"):InvokeServer(unpack(args))
    task.wait(30)
end
