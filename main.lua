---@type ModReference
local VirtueMod = RegisterMod("7Virtues", 1)


local charityCharacter = require("scripts.characters.charity")
local greedCharacter = require("scripts.characters.tainted.greed")


charityCharacter:init(VirtueMod)
greedCharacter:init(VirtueMod)


function PrintPlayerType()
    local player = Isaac.GetPlayer(0)
    local playerType = player:GetPlayerType()
    Isaac.ConsoleOutput(">>> Current player type: " .. tostring(playerType) .. "\n")
    Isaac.ConsoleOutput(">>> CharityType ID: " .. tostring(charityCharacter.charityType) .. "\n")
    Isaac.ConsoleOutput(">>> GreedType ID: " .. tostring(greedCharacter.greedType) .. "\n")
end



VirtueMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PrintPlayerType)