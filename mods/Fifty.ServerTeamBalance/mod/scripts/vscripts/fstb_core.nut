global function FSTB_Init


/**
 * Gets called after the map is loaded
*/
void function FSTB_Init() {
	FSCC_CommandStruct command
	command.m_UsageUser = "switch"
	command.m_UsageAdmin = "switch <player>"
	command.m_Description = "Switches your teams."
	command.m_Group = "BALANCE"
	command.m_Abbreviations = [ "sw" ]
	command.Callback = FSTB_CommandCallback_Switch
	if( !IsFFAGame() )
		FSCC_RegisterCommand( "switch", command )

	if( GetConVarBool( "FSTB_TEAM_BALANCE_ENABLED" ) && !IsFFAGame() )
		AddCallback_GameStateEnter( eGameState.Postmatch, FSTB_EndOfMatchMatch_Threaded )
}

/**
 * Balances the teams right before map change
*/
void function FSTB_EndOfMatchMatch_Threaded() {
	wait GAME_POSTMATCH_LENGTH - 2

	if( IsFFAGame() )
		return

	array< entity > players = clone GetPlayerArray()

	players.sort( int function( entity p0, entity p1 ) {
		if( FSTB_CalculatePlayerSkill( p0 ) < FSTB_CalculatePlayerSkill( p1 ) )
			return 1

		return -1
	})

	for( int i = 0; i < players.len(); i++ ) {
		entity player = players[i]
		if( i % 2 == 0 )
			SetTeam( player, TEAM_IMC )
		else
			SetTeam( player, TEAM_MILITIA )
	}

	FSU_ChatBroadcast( "Teams have been balanced!" )
}

/**
 * Calculates the skill of a player based on kd
 * @param player The player to calculate the skill of
*/
float function FSTB_CalculatePlayerSkill( entity player ) {
	float kills = float( player.GetPlayerGameStat( PGS_KILLS ) )
	float deaths = float( player.GetPlayerGameStat( PGS_DEATHS ) )

	float score = kills / deaths
	return score
}

