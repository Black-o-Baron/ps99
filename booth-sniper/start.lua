--[[
    {
        item = "The Cocktail",
        maxPrice = 145000,
        class = "Potion",
        tier = 1
    }
    {
        item = "Amethyst Dragon", -- idk if this works with part of the name...
        maxPrice = 2000000,
        class = "Pet",
        tier = 1, -- nil for normal, 1 for gold, 2 for rainbow
        shiny = true -- nil for non-shiny, true for shiny
    }
    {
        item = "Secret Key Upper Half",
        maxPrice = 52000,
        class = "Misc"
    }
]]
getgenv().settings = {
    {
        item = "Secret Key Lower Half",
        maxPrice = 3000,
        class = "Misc"
    }
}
repeat task.wait() until game:IsLoaded()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Black-o-Baron/ps99/master/booth-sniper/main.lua"))()
