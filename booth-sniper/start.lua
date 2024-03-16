getgenv().settings = {
    {
        item = "The Cocktail",
        maxPrice = 145000,
        class = "Potion",
        tier = 1
    }
}
repeat task.wait() until game:IsLoaded()
loadstring(game:HttpGet("https://raw.githubusercontent.com/Black-o-Baron/ps99/master/booth-sniper/main.lua"))()
