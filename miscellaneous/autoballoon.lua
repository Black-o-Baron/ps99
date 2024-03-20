task.wait(2)
getgenv().MoneyPrinter = {
    toolName = "Slingshot",
    autoBalloons = true,
    autoPresents = true,

    serverHopper = true,
    avoidCooldown = false,
    minServerTime = 10, -- Avoid 268 if multi-accounting : Force stay in server for x time even if no Balloons

    sendWeb = true,
    webURL = "https://discord.com/api/webhooks/1219484976781721723/8dNBZ8UsnmA7G1E3iMS-nUDy3qYMKQ_A1m1DnNHsHWVTNIvh56mqwWjEZq3X5koejyGY",

    maybeCPUReducer = true,
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/Black-o-Baron/ps99/master/miscellaneous/kittywareAutoBalloon.lua"))()
