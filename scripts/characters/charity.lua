local charityModule = {}

charityModule.charityType = Isaac.GetPlayerTypeByName("Charity", false)
charityModule.hairCostume = Isaac.GetCostumeIdByPath("gfx/characters/charity_hair.anm2") -- Exact path, with the "resources" folder as the root
charityModule.stolesCostume = Isaac.GetCostumeIdByPath("gfx/characters/charity_stoles.anm2") -- Exact path, with the "resources" folder as the root

---comment
---@param player EntityPlayer
function charityModule:GivesCostumesOnInit(player)
    if player:GetPlayerType() ~= charityModule.charityType then
        return
    end

    player:AddNullCostume(charityModule.hairCostume)
    player:AddNullCostume(charityModule.stolesCostume)

end

---Set Charity stats on 
---@param player EntityPlayer
---@param flag CacheFlag
function charityModule:HandleStartingStats(player, flag)
    if player:GetPlayerType() ~= charityModule.charityType then
        return -- End the function early. The below code doesn't run, as long as the player isn't Gabriel.
    end

end

---comment
---@param npc EntityNPC
function charityModule:HandleBeggarInteraction(npc)
    if Isaac.GetPlayer(0):GetPlayerType() ~= charityModule.charityType then return  end

    local type = npc.Type
    if type == 6 then 
        local var = npc.Variant
        if var == 4 or var == 5 then
            Isaac.ConsoleOutput("Mendiant au state : " .. npc.State)
            if npc.State == 9 or npc.State == 10 or npc.State == 11 then
                Isaac.ConsoleOutput("Give donation")
            end
        end
    end
end

---comment
---@param npc EntityNPC
---@param pos Vector
function charityModule:HandleBeggarSpawn(npc, pos)
    if Isaac.GetPlayer(0):GetPlayerType() ~= charityModule.charityType then return  end
    if npc.Type == EntityType.ENTITY_SLOT and 
   (npc.Variant == 4 or npc.Variant == 5 or npc.Variant == 7) then 
        Isaac.ConsoleOutput("Un mendiant a spawn\n")
        local var = npc.Variant
        local type = npc.Type
        Isaac.ConsoleOutput("Type : " .. type .. "\n")
        Isaac.ConsoleOutput("Variant : " .. var .. "\n\n")
    end
end

---comment
---@param npc EntityNPC
function charityModule:HandleSpawn(npc)
    if Isaac.GetPlayer(0):GetPlayerType() ~= charityModule.charityType then return  end
    Isaac.ConsoleOutput("Un mendiant a spawn\n")
end




---Initialize all callback for Charity
---@param mod ModReference
function charityModule:init(mod)
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, charityModule.GivesCostumesOnInit)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, charityModule.HandleStartingStats)
    mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, charityModule.HandleBeggarInteraction)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER,charityModule.HandleBeggarSpawn)
    mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, charityModule.HandleSpawn)
end


return charityModule