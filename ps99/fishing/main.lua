--[[
Created by kittyware -- https://discord.gg/kittyware
]]
getgenv().config = {
    autoFish = true,
    placetoFish = "AdvancedFishing",
    autoPresents = true,
    invisWater = true,

    userToMail = "",
    autoMail = false,
    sendHuges = true,
    sendShards = true,

    sendDiamonds = true,
    minShards = 100,
    minDiamonds = 1050000,
    keepDiamonds = 50000,
}
loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/2c340ba7f63eb21c2e772c76d8d077be.lua"))()
