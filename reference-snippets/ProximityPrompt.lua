-- Reference to the ProximityPrompt
local proximityPrompt = game.Workspace.ProximityPrompt -- Replace "Workspace.ProximityPrompt" with the path to your ProximityPrompt object

-- Function to trigger the prompt
local function triggerPrompt()
    proximityPrompt:PromptAction() -- This function triggers the ProximityPrompt
end

-- Function to detect when a player enters the proximity of the ProximityPrompt
local function onPlayerEnteredProximity(other)
    if other:IsA("Player") then
        triggerPrompt()
    end
end

-- Connect the function to the ProximityPrompt's "Triggered" event
proximityPrompt.Triggered:Connect(onPlayerEnteredProximity)
