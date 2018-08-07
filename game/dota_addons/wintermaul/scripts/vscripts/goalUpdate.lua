function OnStartTouch(key)
    riverEntity(key.activator)
end

function riverEntity(key)
    unitName = key:GetUnitName() -- Retrieves the name that the unit has, such as listed in "npc_units_custom.txt"
    if (key:IsOwnedByAnyPlayer() or key:HasFlyMovementCapability()) then
        -- Is player owned - Ignore
    else
        -- Is not owned by player - Terminate
        if key then
            local waypoint = Entities:FindByName(nil, "path_end")
            key:SetInitialGoalEntity( waypoint )
            key:MoveToPositionAggressive( waypoint:GetOrigin())
        end
    end

end