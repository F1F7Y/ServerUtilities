globalize_all_functions

#if FSCC_ENABLED && FSU_ENABLED

struct {
	// List of player who already voted
	array< entity > playerBlacklist
	table< string, int > votes
} mapVote

struct {
	// List of players who already voted
	array< entity > playerBlacklist
} skipVote

struct {
	// List of players who already voted
	array< entity > playerBlacklist
} extendVote


/**
 * Gets called after the map is loaded
*/
void function FSV_Init() {
	if( GetConVarBool( "FSV_CUSTOM_MAP_ROTATION" ) )
		AddCallback_GameStateEnter( eGameState.Postmatch, FSV_EndOfMatchMatch_Threaded )

	FSCC_CommandStruct command
	command.m_UsageUser = "nextmap <map>"
	command.m_UsageAdmin = "nextmap <map> <force>"
	command.m_Description = "Allows you to vote for the next map"
	command.m_Group = "VOTE"
	command.m_Abbreviations = [ "nm" ]
	command.Callback = FSV_CommandCallback_NextMap
	FSCC_RegisterCommand( "nextmap", command )
	command.m_UsageUser = "skip"
	command.m_UsageAdmin = "skip <force>"
	command.m_Description = "Allows you to vote to skip the current map"
	command.m_Group = "VOTE"
	command.m_Abbreviations = []
	command.Callback = FSV_CommandCallback_Skip
	FSCC_RegisterCommand( "skip", command )
	command.m_UsageUser = "extend"
	command.m_UsageAdmin = "extend <minutes>"
	command.m_Description = "Allows you to vote to extend the current match"
	command.m_Group = "VOTE"
	command.m_Abbreviations = [ "ex" ]
	command.Callback = FSV_CommandCallback_Extend
	FSCC_RegisterCommand( "extend", command )
	command.m_UsageUser = "maps <page>"
	command.m_UsageAdmin = ""
	command.m_Description = "Lists maps in the voting pool."
	command.m_Group = "VOTE"
	command.m_Abbreviations = []
	command.Callback = FSV_CommandCallback_Maps
	FSCC_RegisterCommand( "maps", command )
}

/**
 * Returns a reference to an array of players who have voted to extend the match
*/
array< entity > function FSV_GetPlayerArrayReference_Extend() {
	return extendVote.playerBlacklist
}

/**
 * Returns a reference to an array of players who have voted to skip the map
*/
array< entity > function FSV_GetPlayerArrayReference_Skip() {
	return skipVote.playerBlacklist
}

/**
 * Returns a reference to an array of players who have voted for the next map
*/
array< entity > function FSV_GetPlayerArrayReference_NextMap() {
	return mapVote.playerBlacklist
}

/**
 * Adds a vote to a map
 * @param player The player who voted
 * @param map The map to vote for
*/
void function FSV_VoteForNextMap( entity player, string map ) {
	mapVote.playerBlacklist.append( player )

	if( map in mapVote.votes ) {
		mapVote.votes[map]++
	} else {
		mapVote.votes[map] <- 1
	}
}

/**
 * Gets called when the game enters Postmatch
*/
void function FSV_EndOfMatchMatch_Threaded() {
	wait GAME_POSTMATCH_LENGTH - 1

	string map = ""
	int votes = 0
	foreach( string m, int v in mapVote.votes ) {
		if( v > votes ) {
			votes = v
			map = FSV_UnLocalize( m )
		}
	}

	array< string > maps = split( GetConVarString( "FSV_MAP_ROTATION" ), "," )

	// Noone voted, get the map next in line
	if( map == "" ) {
		int index = 1
		foreach( string m in maps ) {
			if( GetMapName() == m )
				break

			index++
		}

		if( index >= maps.len() )
			index = 0

		map = maps[index]
	}

	// Change map
	GameRules_ChangeMap( map, GAMETYPE )
}


/**
 * Skips the current map
*/
void function FSV_SkipMatch() {
	string map = ""
	int votes = 0

	array< string > maps = split( GetConVarString( "FSV_MAP_ROTATION" ), "," )

	int index = 1
	foreach( string m in maps ) {
		if( GetMapName() == m )
			break

		index++
	}

	if( index >= maps.len() )
		index = 0

	map = maps[index]

	SetServerVar( "gameEndTime", Time() )
}

/**
 * Extends the match
 * @param minutes The amount by which to extend the match
*/
void function FSV_ExtendMatch( float minutes ) {
	// Creadit:
	// https://github.com/CTalvio/MentalEdge.FSU-fvnk/blob/main/mod/scripts/vscripts/fm.nut#L386-L394
	float currentEndTime = expect float( GetServerVar( "gameEndTime" ) )
	float newEndTime = currentEndTime + ( 60 * minutes )
	SetServerVar( "gameEndTime", newEndTime )
}
#else
void function FSV_Init() {
	print( "[FSV][ERRR] FSU and FSCC Need to be enabled for FSV to work!!!" )
}
#endif
