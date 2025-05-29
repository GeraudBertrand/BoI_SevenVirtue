local stats = include("../../scripts.constants.stats")

local greedModule = {}

greedModule.greedType = Isaac.GetPlayerTypeByName("Greed", true)
greedModule.greedItem = Isaac.GetItemIdByName("Greed Hand")

greedModule.baseDebuf = { 
    GREED_HAND_DAMAGE_PENALTY = 0.3,
    GREED_HAND_SPEED_PENALTY = 0.1,
    GREED_HAND_FIRERATE_PENALTY = 0.15,
    GREED_HAND_LUCK_PENALTY = 1
}

---@param player EntityPlayer
function greedModule:OnPlayerInit(player)
    if player:GetPlayerType() == greedModule.greedType then
        if not player:HasCollectible(greedModule.greedItem) then
            player:AddCollectible(greedModule.greedItem, 5, true)
        end
    end
end

---Adjust stat for the flag
---@param player EntityPlayer
---@param cacheFlags CacheFlag
function greedModule:PowerPrice(player, cacheFlags)
    local itemCount = player:GetCollectibleNum(greedModule.greedItem)
    local playerData = player:GetData()

    if itemCount == 0 then return end

    if cacheFlags == CacheFlag.CACHE_DAMAGE then
        local damageToRemove = greedModule.baseDebuf.GREED_HAND_DAMAGE_PENALTY * (itemCount + (playerData.GreedDamagePenalty or 0))
        player.Damage = player.Damage - damageToRemove
    elseif cacheFlags == CacheFlag.CACHE_SPEED then
        local speedToRemove = greedModule.baseDebuf.GREED_HAND_SPEED_PENALTY * (itemCount + (playerData.GreedSpeedPenalty or 0))
        player.MoveSpeed = player.MoveSpeed - speedToRemove
    elseif cacheFlags == CacheFlag.CACHE_LUCK then
        local luckToRemove = greedModule.baseDebuf.GREED_HAND_LUCK_PENALTY * (itemCount + (playerData.GreedFireRatePenalty or 0))
        player.Luck = player.Luck - luckToRemove
    elseif cacheFlags == CacheFlag.CACHE_FIREDELAY then
        local tearsPerSecond = stats.toTearsPerSecond(player.MaxFireDelay)
        local tearToRemove = greedModule.baseDebuf.GREED_HAND_FIRERATE_PENALTY * (itemCount + (playerData.GreedLuckPenalty or 0))
        tearsPerSecond = tearsPerSecond + (itemCount * tearToRemove)
        player.MaxFireDelay = stats.toMaxFireDelay(tearsPerSecond)
    end
end

---comment
---@param item CollectibleType
---@param rng RNG
---@param player EntityPlayer
---@param flags UseFlag
---@param slot ActiveSlot
---@param CustomVarData integer
---@return table
function greedModule:GreedHandUse(item, rng, player, flags, slot, CustomVarData)
    local roomEntities = Isaac.GetRoomEntities()
    local room = Game():GetRoom()


    for _, entity in ipairs(roomEntities) do
        local pickup = entity:ToPickup()
        if pickup and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and Isaac.GetItemConfig():GetCollectible(pickup.SubType).Type ~= ItemType.ITEM_ACTIVE then
            if room:GetType() == RoomType.ROOM_DEVIL then
                greedModule:DevilPrice(player)
            elseif room:GetType() == RoomType.ROOM_ANGEL then
                greedModule:AngelPrice(player)
            end
            player:AddCollectible(pickup.SubType)
            pickup:Remove()
        end
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = false
    }
end

---Make player Damage or Speed decrease
---@param player EntityPlayer
function greedModule:DevilPrice(player)
    local playerData = player:GetData()
    local rng = RNG()
    rng:SetSeed(Random(), 35)
    local roll = rng:RandomInt(10)
    if roll < 5 then
        playerData.GreedDamagePenalty = (playerData.GreedDamagePenalty or 0) + 1
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    else
        playerData.GreedSpeedPenalty = (playerData.GreedSpeedPenalty or 0) + 1
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
    end
    player:EvaluateItems()
end

---Make player Tear Rate or Luck decrease
---@param player EntityPlayer
function greedModule:AngelPrice(player)
    local playerData = player:GetData()
    local rng = RNG()
    rng:SetSeed(Random(), 1)
    local roll = rng:RandomInt(10)
    if roll < 5 then
        playerData.GreedFireRatePenalty = (playerData.GreedFireRatePenalty or 0) + 1
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    else
        playerData.GreedLuckPenalty = (playerData.GreedLuckPenalty or 0) + 1
        player:AddCacheFlags(CacheFlag.CACHE_LUCK)
    end
    player:EvaluateItems()
end


---Initialize all callback for Greed
---@param mod ModReference
function greedModule:init(mod)
    mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, greedModule.OnPlayerInit)
    mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, greedModule.PowerPrice)
    mod:AddCallback(ModCallbacks.MC_USE_ITEM, greedModule.GreedHandUse, greedModule.greedItem)
end

return greedModule