function Spawn( entityKeyValues )
	print("Spawned a big mean boss!")
	ABILITY_stun = thisEntity:FindAbilityByName( "chieftain_stomp" )
	math.randomseed(1234)
	thisEntity:SetContextThink( "ChieftainThink", ChieftainThink, 14 )
end

function ChieftainThink()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	t = math.random(14, 20)
	local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetAbsOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for k,v in pairs(targets) do print(k,v) end
	if #targets > 0 then
		thisEntity:CastAbilityNoTarget(ABILITY_stun, -1)
		print("Stomping")
		return t
	end
	return t 
end
