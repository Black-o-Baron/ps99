--[[
    --> INVENTORY KEYS <--
    Enchant
    Misc
    Hoverboard
    Box
    Currency
    Potion
    Seed
    Fruit
    Pet
    Booth

    [Pet][<pet_id>][id] = Name of the pet
    [Pet][<pet_id>][pt] = Type of the pet -> 1 for gold, 2 for rainbow, Key doesn't exist for normal
    [Pet][<pet_id>][sh] = Shiny -> true for shiny, Key doesn't exist for non-shiny
    [Pet][<pet_id>][_am] = Amount of pet -> 2 to any_count if exist, Key doesn't exist for 1
]]

local Library = require(game.ReplicatedStorage:WaitForChild('Library'))
local Inventory = Library.Save.Get().Inventory
local Pet = Inventory.Pet

local function printTable(n, t)
    for k,v in pairs(t) do
        if n == "[Pet]" then
            print("================================================")
        end
        if type(v) == "table" then
            printTable(n .. "[" .. k .. "]", v)
        else
            print(tostring(n .. "[" .. k .. "]") .. ": " .. tostring(v))
        end
    end
end

printTable("[Inventory]", Inventory)

printTable("[Pet]", Pet)
