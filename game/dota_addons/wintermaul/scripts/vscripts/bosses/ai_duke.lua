function Spawn( entityKeyValues )
	ABILITY_spawn = thisEntity:FindAbilityByName( "duke_spawn_minions" )
	--math.randomseed(GameRules:GetGameTime())
	EmitGlobalSound("Hero_Abaddon.BorrowedTime")

	EmitGlobalSound("abad_respawn_" + tostring(math.random(1,10)))
	thisEntity:SetContextThink( "DukeThink", DukeThink, 1 )
end

function DukeThink()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	local now = GameRules:GetGameTime()
	t = math.random(10, 20)

	if now - thisEntity:GetLastIdleChangeTime() > t then
		thisEntity:CastAbilityNoTarget(ABILITY_spawn, -1)
	end
	return 1
end
