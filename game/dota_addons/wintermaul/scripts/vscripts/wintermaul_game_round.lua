--[[
	CWintermaulGameRound - A single round of Wintermaul
]]

if CWintermaulGameRound == nil then
	CWintermaulGameRound = class({})
end

function CWintermaulGameRound:ReadConfiguration( kv, gameMode, roundNumber )
	
	self._gameMode = gameMode
	self._nRoundNumber = roundNumber
	self._szRoundQuestTitle = "#DOTA_Quest_Wintermaul_Round_Subtext"
	self._szRoundTitle = kv.round_title or string.format( "Round%d", roundNumber )
	self._szRoundElement = kv.round_special
    
    local spawnerNames = {}
    for i = 1,#self._gameMode._vSpawnsList do
        spawnerNames[self._gameMode._vSpawnsList[i].szSpawnerName] = true
    end
    self._vSpawnAt = kv.SpawnAt or spawnerNames
    
	self._vSpawners = {}
	self._bGroupSpawners = kv.GroupSpawners
    
	for k, v in pairs( kv ) do
		if type( v ) == "table" and v.NPCName then
            local totalUnitsForWave = v.TotalUnitsToSpawn
            local totalUnitsSpawned = 0
            local idealNumberOfUnitsToSpawn = math.ceil(v.TotalUnitsToSpawn/#self._gameMode._vSpawnsList)
            for spawnerName, bSpawn in pairs(self._vSpawnAt) do
                if self._vSpawnAt[spawnerName] then
                    v.TotalUnitsToSpawn = math.min(idealNumberOfUnitsToSpawn, totalUnitsForWave - totalUnitsSpawned)
                    v.SpawnerName = spawnerName
                    local spawner = CWintermaulGameSpawner()
                    spawner:ReadConfiguration( k, v, self )
                    self._vSpawners[spawnerName] = spawner
                    totalUnitsSpawned = totalUnitsSpawned + v.TotalUnitsToSpawn
                end
            end
		end
	end

	for _, spawner in pairs( self._vSpawners ) do
		spawner:PostLoad( self._vSpawners )
	end

end


function CWintermaulGameRound:Precache()
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Precache()
	end
end

function CWintermaulGameRound:BeginSpecial()
	-- load this one instead of Begin() to do cool things
	print("using custom rules for this round!")
end

function CWintermaulGameRound:Begin()

	local event_data --hellyeah
	local nextRoundNumber = self._nRoundNumber+1
	local nextRound = self._gameMode._vRounds[self._nRoundNumber+1]

	--[[Difficulty block bois
	if next(self._gameMode._diff) == nil then
		print("Difficulty not selected, defaulting to normal.")  -- TODO this is a repeat of code, need a seperate file that stores the configuration of difficulties
		self._gameMode._diff["hp"] = 1
		self._gameMode._diff["lives"] = 40
		CustomGameEventManager:Send_ServerToAllClients("diff_default", {})
		self._gameMode._nLivesLeft = self._gameMode._diff["lives"]
		CustomNetTables:SetTableValue("game_state", "lives_remaining", {value = string.format("%d", self._gameMode._nLivesLeft)})
	end
	]]

	if nextRoundNumber <= #self._gameMode._vRounds then
		event_data =
		{	
			roundData = self._nRoundNumber,
		    currentTitle = self._szRoundTitle,
		    nextTitle = nextRound._szRoundTitle,
		    currentSpecial = self._szRoundElement,
		    nextSpecial = nextRound._szRoundElement,
		}
	else
		event_data =
		{
			roundData = nextRoundNumber,
		    currentTitle = self._szRoundTitle,
		    nextTitle = "",
		    currentSpecial = self._szRoundElement,
		    nextSpecial = "",
		}
	end
    CustomNetTables:SetTableValue("game_state", "round_wave_data", event_data)

	self._vEnemiesRemaining = {}
	self._vEventHandles = {
		ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CWintermaulGameRound, "OnNPCSpawned" ), self ),
		ListenToGameEvent( "entity_killed", Dynamic_Wrap( CWintermaulGameRound, "OnEntityKilled" ), self ),
		ListenToGameEvent( "player_reconnected", Dynamic_Wrap(CWintermaulGameRound, "OnPlayerReconnect"), self)

	}


	self._vPlayerStats = {}
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		-- Put player stats here
		self._vPlayerStats[ nPlayerID ] = {
			nCreepsKilled = 0,
		}
	end

	self._nCoreUnitsTotal = 0
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Begin()
		self._nCoreUnitsTotal = self._nCoreUnitsTotal + spawner:GetTotalUnitsToSpawn()
	end
    self._nCoreUnitsRemaining = self._nCoreUnitsTotal
	self._nCoreUnitsKilled = 0

	--DEPRECATED PROBABLY?
	self._entQuest = SpawnEntityFromTableSynchronous( "quest", {
		name = self._szRoundTitle,
		title =  self._szRoundQuestTitle
	})
	self._entQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_ROUND, self._nRoundNumber )
	self._entQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, self._nCoreUnitsTotal )

	self._entKillCountSubquest = SpawnEntityFromTableSynchronous( "subquest_base", {
		show_progress_bar = true,
		progress_bar_hue_shift = -119
	} )
	self._entQuest:AddSubquest( self._entKillCountSubquest )
	self._entKillCountSubquest:SetTextReplaceValue( SUBQUEST_TEXT_REPLACE_VALUE_TARGET_VALUE, self._nCoreUnitsTotal )

	CustomNetTables:SetTableValue("game_state", "round_creep_data", {enemiesremaining = self._nCoreUnitsTotal, totalenemies = self._nCoreUnitsTotal})

end


function CWintermaulGameRound:End()
	
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	self._vEventHandles = {}

	for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
		if not unit:IsTower() then
			UTIL_Remove( unit )
		end
	end

	for _,spawner in pairs( self._vSpawners ) do
		spawner:End()
	end

	--DEPRECATED PROBABLY
	if self._entQuest then
		UTIL_Remove( self._entQuest )
		self._entQuest = nil
		self._entKillCountSubquest = nil
	end

	local nRoundCompletionGoldReward = self._nRoundNumber*5+20
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:HasSelectedHero( nPlayerID ) then
			if nPlayerID == 0 then
				PlayerResource:ModifyGold( nPlayerID, nRoundCompletionGoldReward+50, false, DOTA_ModifyGold_Unspecified )
			else
				PlayerResource:ModifyGold( nPlayerID, nRoundCompletionGoldReward, false, DOTA_ModifyGold_Unspecified )
			end
		end
	end

	local roundEndSummary = {
		nRoundNumber = self._nRoundNumber - 1,
		nRoundDifficulty = GameRules:GetCustomGameDifficulty(),
		roundName = self._szRoundTitle
	}

	local playerSummaryCount = 0
	for i = 1, DOTA_MAX_TEAM_PLAYERS do
		local nPlayerID = i-1
		if PlayerResource:HasSelectedHero( nPlayerID ) then
			local szPlayerPrefix = string.format( "Player_%d_", playerSummaryCount)
			playerSummaryCount = playerSummaryCount + 1
			local playerStats = self._vPlayerStats[ nPlayerID ]
			roundEndSummary[ szPlayerPrefix .. "HeroName" ] = PlayerResource:GetSelectedHeroName( nPlayerID )
			roundEndSummary[ szPlayerPrefix .. "CreepKills" ] = playerStats.nCreepsKilled
			-- Have other tower stats here eg most valuable tower

		end
	end
end


function CWintermaulGameRound:Think()
    if self._bGroupSpawners then
        for _, spawner in pairs( self._vSpawners ) do
            --If any spawner has finished spawning
            if not spawner:IsSpawningFinished() or spawner:AreThereSpawnedUnitsAlive() then
                spawner:Think()
                return
            end
        end
    else
        for _, spawner in pairs( self._vSpawners ) do
            spawner:Think()
        end
    end
end

function CWintermaulGameRound:IsFinished()
	for _, spawner in pairs( self._vSpawners ) do
		if not spawner:IsFinishedSpawning() then
			return false
		end
	end
	local nEnemiesRemaining = #self._vEnemiesRemaining
	if nEnemiesRemaining == 0 then
		return true
	end

	if not self._lastEnemiesRemaining == nEnemiesRemaining then
		self._lastEnemiesRemaining = nEnemiesRemaining
		print ( string.format( "%d enemies remaining in the round...", #self._vEnemiesRemaining ) )
	end
	return false
end


function CWintermaulGameRound:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit or spawnedUnit:IsPhantom() or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:GetUnitName() == "" then
		return
	end

	if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		spawnedUnit:SetMustReachEachGoalEntity(true)
		table.insert( self._vEnemiesRemaining, spawnedUnit )
		spawnedUnit:SetDeathXP( 0 )
		spawnedUnit.unitName = spawnedUnit:GetUnitName()
		spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_phased", nil)
	end
end

--Units die in lane
function CWintermaulGameRound:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if not killedUnit then
		return
	end

	for i, unit in pairs( self._vEnemiesRemaining ) do
		if killedUnit == unit then
			table.remove( self._vEnemiesRemaining, i )
			break
		end
	end	

	local attackerUnit = EntIndexToHScript( event.entindex_attacker or -1 )
	if attackerUnit then
		-- Here we need some way of using the tower ID to update round
		local playerID = attackerUnit:GetPlayerOwnerID()
		local playerStats = self._vPlayerStats[ playerID ]
		if playerStats then
			playerStats.nCreepsKilled = playerStats.nCreepsKilled + 1
			CustomGameEventManager:Send_ServerToAllClients("new_score", { id = playerID })
		end
	end
    
    self._nCoreUnitsRemaining = self._nCoreUnitsRemaining - 1
	CustomNetTables:SetTableValue("game_state", "round_creep_data", {enemiesremaining = string.format( "%d", self._nCoreUnitsRemaining), totalenemies = self._nCoreUnitsTotal})
end

--Units reach the end
function CWintermaulGameRound:OnEntityRemoved( event )

	for i, unit in pairs( self._vEnemiesRemaining ) do
		if event == unit then
			table.remove( self._vEnemiesRemaining, i )
			break
		end
	end
    self._nCoreUnitsRemaining = self._nCoreUnitsRemaining - 1
	CustomNetTables:SetTableValue("game_state", "round_creep_data", {enemiesremaining = string.format( "%d", self._nCoreUnitsRemaining), totalenemies = self._nCoreUnitsTotal})
end

--[[
Up for deletion?
function CWintermaulGameRound:StatusReport( )
	print( string.format( "Enemies remaining: %d", #self._vEnemiesRemaining ) )
	for _,e in pairs( self._vEnemiesRemaining ) do
		if e:IsNull() then
			print( string.format( "<Unit %s Deleted from C++>", e.unitName ) )
		else
			print( e:GetUnitName() )
		end
	end
	print( string.format( "Spawners: %d", #self._vSpawners ) )
	for _,s in pairs( self._vSpawners ) do
		s:StatusReport()
	end
end

function CWintermaulGameRound:OnPlayerReconnect()
	-- Do nothing.
end
]]