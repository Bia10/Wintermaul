function OnStartTouch(key)
    print('asd')
    riverEntity(key.activator)
end

function riverEntity(key)
    unitName = key:GetUnitName() -- Retrieves the name that the unit has, such as listed in "npc_units_custom.txt"
    if (key:IsOwnedByAnyPlayer() ) then
        -- Is player owned - Ignore
    else
        -- Is not owned by player - Terminate
        if key then
            local waypoint = Entities:FindByName(nil, "path_end")
            entity:SetInitialGoalEntity( waypoint )
        end
    end

end