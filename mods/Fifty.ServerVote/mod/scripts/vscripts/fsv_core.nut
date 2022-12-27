global function FSV_Init

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
	command.Callback = FSCC_CommandCallback_NextMap
	FSCC_RegisterCommand( "nextmap", command )
	command.m_UsageUser = "skip"
	command.m_UsageAdmin = "skip <force>"
	command.m_Description = "Allows you to vote to skip the current map"
	command.m_Group = "VOTE"
	command.m_Abbreviations = []
	command.Callback = FSCC_CommandCallback_Skip
	FSCC_RegisterCommand( "skip", command )
	command.m_UsageUser = "extend"
	command.m_UsageAdmin = "extend <minutes>"
	command.m_Description = "Allows you to vote to extend the current match"
	command.m_Group = "VOTE"
	command.m_Abbreviations = [ "ex" ]
	command.Callback = FSCC_CommandCallback_Extend
	FSCC_RegisterCommand( "extend", command )
	command.m_UsageUser = "maps <page>"
	command.m_UsageAdmin = ""
	command.m_Description = "Lists maps in the voting pool."
	command.m_Group = "VOTE"
	command.m_Abbreviations = []
	command.Callback = FSCC_CommandCallback_Maps
	FSCC_RegisterCommand( "maps", command )
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
 * Gets called when a player runs !nextmap
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_NextMap( entity player, array< string > args ) {
	if( args.len() == 0 ) {
		FSU_PrivateChatMessage( player, "This commands requires you to pass a map" )
		return
	}

	array< string > maps
	maps.extend( FSV_LocalizeArray( split( GetConVarString( "FSV_MAP_ROTATION" ), "," ) ) )
	maps.extend( FSV_LocalizeArray( split( GetConVarString( "FSV_MAP_VOTE_ONLY" ), "," ) ) )

	int index = 0
	foreach( string map in maps ) {
		if( map.tolower().find( args[0].tolower() ) != null )
			break

		index++
	}

	if( index == maps.len() ) {
		FSU_PrivateChatMessage( player, "Map " + FSU_Highlight( "\"" + args[0] + "\"" ) + " isn't in the voting pool!" )
		return
	}

	if( FSA_IsAdmin( player ) && args.len() >= 2 ) {
		if( args[1].tolower() == "force" ) {
			GameRules_ChangeMap( FSV_UnLocalize( maps[index] ), GAMETYPE )
			return
		} else {
			FSU_PrivateChatMessage( player, "Use " + FSU_Highlight( GetConVarString( "FSCC_PREFIX" ) + "nextmap <map> force" ) + " to forcefully change the map.")
			return
		}
	}

	foreach( entity ent in mapVote.playerBlacklist ) {
		if( player == ent ) {
			FSU_PrivateChatMessage( player, "You have already voted!" )
			return
		}
	}


	FSU_ChatBroadcast( FSU_Highlight( player.GetPlayerName() ) + " voted " + FSU_Highlight( maps[index] ) + " as the next map." )
	mapVote.playerBlacklist.append( player )

	if( maps[index] in mapVote.votes ) {
		mapVote.votes[maps[index]]++
	} else {
		mapVote.votes[maps[index]] <- 1
	}
}

/**
 * Gets called when a player runs !skip
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Skip( entity player, array< string > args ) {
	if( FSA_IsAdmin( player ) && args.len() >= 1 ) {
		if( args[0].tolower() == "force" ) {
			FSV_SkipMatch()
		} else {
			FSU_PrivateChatMessage( player, "Use " + FSU_Highlight( GetConVarString( "FSCC_PREFIX" ) + "skip force" ) + " to forcefully skip the map.")
			return
		}
	}


	foreach( entity ent in skipVote.playerBlacklist ) {
		if( player == ent ) {
			FSU_PrivateChatMessage( player, "You have already voted!" )
			return
		}
	}

	skipVote.playerBlacklist.append( player )
	FSU_ChatBroadcast( FSU_Highlight( player.GetPlayerName() ) + " voted to skip this map. " + FSU_Highlight( "[" + string( skipVote.playerBlacklist.len() ) + "/" + string( ceil( GetPlayerArray().len() / 2.0 ) ) + "]"  ) )


	if ( ceil( GetPlayerArray().len() / 2.0 ) < skipVote.playerBlacklist.len() )
		return

	FSU_ChatBroadcast( "Skipping current map." )

	FSV_SkipMatch()
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

	wait 1
	FSU_ChatBroadcast( "3" )
	wait 1
	FSU_ChatBroadcast( "2" )
	wait 1
	FSU_ChatBroadcast( "1" )
	wait 1

	// Change map
	GameRules_ChangeMap( map, GAMETYPE )
}

/**
 * Gets called when a player runs !maps
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Maps( entity player, array< string > args ) {
	array< string > maps
	maps.extend( FSV_LocalizeArray( split( GetConVarString( "FSV_MAP_ROTATION" ), "," ) ) )
	maps.extend( FSV_LocalizeArray( split( GetConVarString( "FSV_MAP_VOTE_ONLY" ), "," ) ) )

	// Print a page of maps
	int pages = FSU_GetListPages( maps, 2 )

	int page
	if( args.len() == 0 ) {
		page = 1
	} else {
		page = args[0].tointeger()
	}

	if( page > pages ) {
		FSU_PrivateChatMessage( player, "Maximum number of pages is: " + FSU_Highlight( string( pages ) ) )
		return
	}

	if( page < 1 )
		page = 1

	FSU_PrivateChatMessage( player, "List of avalible maps:" )
	FSU_PrintFormattedList( player, maps, page, 2 )
	FSU_PrivateChatMessage( player, "Page: " + FSU_Highlight( "[" + page + "/" + pages + "]" ) )
}

/**
 * Gets called when a player runs !extend
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Extend( entity player, array< string > args ) {
	if( FSA_IsAdmin( player ) && args.len() >= 1 ) {
		FSV_ExtendMatch( float( args[0].tointeger() ) )
		FSU_PrivateChatMessage( player, "Extended match." )
		return
	}

	foreach( entity ent in extendVote.playerBlacklist ) {
		if( player == ent ) {
			FSU_PrivateChatMessage( player, "You have already voted!" )
			return
		}
	}

	extendVote.playerBlacklist.append( player )
	FSU_ChatBroadcast( FSU_Highlight( player.GetPlayerName() ) + " voted to extend this match. " + FSU_Highlight( "[" + string( extendVote.playerBlacklist.len() ) + "/" + string( ceil( GetPlayerArray().len() / 2.0 ) ) + "]"  ) )


	if ( ceil( GetPlayerArray().len() / 2.0 ) < extendVote.playerBlacklist.len() )
		return

	FSU_ChatBroadcast( "Extending current match." )

	FSV_ExtendMatch( 20.0 )

	extendVote.playerBlacklist.clear()
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
