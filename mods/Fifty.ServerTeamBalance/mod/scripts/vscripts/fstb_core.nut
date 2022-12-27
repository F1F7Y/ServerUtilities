global function FSTB_Init

#if FSU_ENABLED && FSCC_ENABLED
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
	command.Callback = FSTM_CommandCallback_Switch
	FSCC_RegisterCommand( "switch", command )

	if( GetConVarBool( "FSTB_TEAM_BALANCE_ENABLED" ) && !IsFFAGame() )
		AddCallback_GameStateEnter( eGameState.Postmatch, FSTM_EndOfMatchMatch_Threaded )
}

/**
 * Gets called when a player runs !switch
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSTM_CommandCallback_Switch( entity player, array< string > args ) {
	if( GetGameState() != eGameState.Playing ) {
		FSU_PrivateChatMessage( player, "Can't switch teams currently." )
		return
	}

	entity target = player

	if( FSA_IsAdmin( player ) && args.len() != 0 ) {
		bool foundTarget = false
		foreach( entity player in GetPlayerArray() ) {
			if( player.GetPlayerName().tolower().find( args[0].tolower() ) != -1 ) {
				target = player
				foundTarget = true
				break
			}
		}

		if( !foundTarget ) {
			FSU_PrivateChatMessage( player, FSU_Highlight( "\"" + args[0] + "\"" ) + " couldn't be found!" )
			return
		}
	}

	SetTeam( target, GetOtherTeam( target.GetTeam() ) )
	target.Die()
	FSU_PrivateChatMessage( player, "Your team has been switched!" )
}

/**
 * Balances the teams right before map change
*/
void function FSTM_EndOfMatchMatch_Threaded() {
	wait GAME_POSTMATCH_LENGTH - 2

	if( IsFFAGame() )
		return

	array< entity > players = clone GetPlayerArray()

	players.sort( int function( entity p0, entity p1 ) {
		if( FSTM_CalculatePlayerSkill( p0 ) < FSTM_CalculatePlayerSkill( p1 ) )
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
float function FSTM_CalculatePlayerSkill( entity player ) {
	float kills = float( player.GetPlayerGameStat( PGS_KILLS ) )
	float deaths = float( player.GetPlayerGameStat( PGS_DEATHS ) )

	float score = kills / deaths
	return score
}
#else
void function FSTB_Init() {
	print( "[FSTB][ERRR] FSU and FSCC Need to be enabled for FSTB to work!!!" )
}
#endif
