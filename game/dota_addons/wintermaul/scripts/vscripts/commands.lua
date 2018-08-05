--[[
	File for Custom Wintermaul Commands
]]

Convars:RegisterCommand( "wintermaul_set_round", function(...) return self:_SetRound( ... ) end, "Start playing a specific Wintermaul round", FCVAR_CHEAT )
Convars:RegisterCommand( "wintermaul_set_lives_remaining", function(...) return self:_SetLivesRemaining( ... ) end, "Set the lives remaining for Wintermaul.", FCVAR_CHEAT )

function CWintermaulCommands:_SetRound( cmdName, roundNumber, delay )
	local nRoundToTest = tonumber( roundNumber )
	print (string.format( "Testing round %d", nRoundToTest ) )
	if nRoundToTest <= 0 or nRoundToTest > #self._vRounds then
		Msg( string.format( "Cannot test invalid round %d", nRoundToTest ) )
		return
	end

	if self._currentRound ~= nil then
		self._currentRound:End()
		self._currentRound = nil
	end

	self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
	self._nRoundNumber = nRoundToTest
	if delay ~= nil then
		self._flPrepTimeEnd = GameRules:GetGameTime() + tonumber( delay )
	end
end

function CWintermaulCommands:_SetLivesRemaining( cmdName, livesNumber)
	local nLivesToGet = tonumber( livesNumber )
	print (string.format( "Testing %d lives", nLivesToGet ) )
	if nLivesToGet <= 0 then
		Msg( string.format( "Cannot test invalid lives %d", nLivesToGet ) )
		return
	end
	self._nLivesLeft = nLivesToGet

	CustomGameEventManager:Send_ServerToAllClients("game_state", {lives_remaining = string.format("%d", self._nLivesLeft)})
end
