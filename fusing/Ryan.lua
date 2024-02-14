_G.autoFuse = true

local PET_TO_FUSE = "Pastel Griffin" -- name of the pet you want to fuse
local FUSE_AMOUNT = 3 -- 3 in the minimum and 10 is the max


local Library = require(game.ReplicatedStorage:WaitForChild('Library'))
local pets = Library.Save.Get().Inventory.Pet

local petId
for id, petData in pairs(pets) do
    if petData["id"] == PET_TO_FUSE and not petData["pt"] and not petData["sh"] then
        petId = id
        print(petId)
    end
end

while _G.autoFuse do
    local args = {
        [1] = {
            [petId] = FUSE_AMOUNT
        }
    }

    game:GetService("ReplicatedStorage").Network.FuseMachine_Activate:InvokeServer(unpack(args))
    task.wait(0.5)
end
