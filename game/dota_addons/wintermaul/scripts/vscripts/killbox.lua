require("wintermaul_game_round")
function OnStartTouch(key)
    killEntity(key.activator)
end

function killEntity(key)
    -- "Unit '" .. unitName .. "' has entered the killbox"
    unitName = key:GetUnitName() -- Retrieves the name that the unit has, such as listed in "npc_units_custom.txt"

    if (key:IsOwnedByAnyPlayer() ) then
        -- Is player owned - Ignore

    else
        -- Is not owned by player - Terminate
        if key then
            --TODO: add a particle
            GameRules.CWintermaulGameMode:GetCurrentRound():OnEntityRemoved(key)
            EmitGlobalSound("DOTA_Item.Armlet.DeActivate")
            UTIL_Remove(key)
            GameRules.CWintermaulGameMode:LifeLost()
        end
    end
end