require("wintermaul_game_round")
function OnStartTouch(key)
    if not (key.activator:GetUnitName() == "npc_dota_defender_fort") then
        killEntity(key.activator)
    end
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

            --Boss logic for loosing more lives when leaking
            if unitName == "npc_dota_wintermaul_corrupt_chieftain" then
                GameRules.CWintermaulGameMode:LifeLost(10)
            elseif unitName == "npc_dota_wintermaul_duke_wintermaul" then
                GameRules.CWintermaulGameMode:LifeLost(100)
            else
                GameRules.CWintermaulGameMode:LifeLost(1)
            end
        end
    end
end