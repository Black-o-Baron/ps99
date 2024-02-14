_G.Enabled = true
local lplr = game:GetService("Players").LocalPlayer; local Http = game:GetService("HttpService"); local Mouse = lplr:GetMouse()
local SaveModule = require(game:GetService("ReplicatedStorage").Library.Client.Save); local SaveFile = SaveModule.Get(lplr)
local MiscInventory = SaveFile.Inventory.Misc; local BoothFolder = workspace:WaitForChild("__THINGS"):WaitForChild("Booths")

local ItemtoList = "Magic Shard" -- name of thing to sell
local AmountToList = 10 -- amount to sell
local GemAmnt = 250000 -- amount to sell for 

local function UnList()
    for ID,value in pairs(MiscInventory) do
        if value.id == ItemtoList and value._am >= AmountToList then 
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Booths_RemoveListing"):InvokeServer(ID)
        end
    end
end

local function List()
    for ID,value in pairs(MiscInventory) do
        if value.id == ItemtoList and value._am >= AmountToList then 
            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Booths_CreateListing"):InvokeServer(ID, GemAmnt, AmountToList)
        end
    end
end

spawn(function()
    while _G.Enabled do
        List() task.wait(2) UnList() task.wait(1) List() -- funny way to avoid booths anti-afk
    end
end)
