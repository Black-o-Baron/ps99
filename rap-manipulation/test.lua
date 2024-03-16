local args = {
    [1] = "Potion",
    [2] = "{\"id\":\"The Cocktail\",\"tn\":1}",
    [4] = false
}

game:GetService("ReplicatedStorage").Network.TradingTerminal_Search:InvokeServer(unpack(args))
