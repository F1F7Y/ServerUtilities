globalize_all_functions

#if FSCC_ENABLED && FSU_ENABLED

struct {
	// List of player who already voted
	array< entity > playerBlacklist
	table< string, int > votes
} mapVote

/**
 * Gets called after the map is loaded
*/
void function FSV_Init() {
	if (FSU_GetSettingIntFromConVar("FSV_MAP_REPLAY_LIMIT") > 0)
		UpdatePlayedMaps()

	if( GetConVarBool( "FSV_CUSTOM_MAP_ROTATION" ) )
		AddCallback_GameStateEnter( eGameState.Postmatch, FSV_EndOfMatchMatch_Threaded )

	FSCC_CommandStruct command
	command.m_UsageUser = "nextmap <map>"
	command.m_UsageAdmin = "nextmap <map> force"
	command.m_Description = "Allows you to vote for the next map, or view map rotation information."
	command.m_Group = "VOTE"
	command.m_Abbreviations = [ "nm", "maps", "map" ]
	command.Callback = FSV_CommandCallback_NextMap
	if( !GetConVarBool( "FSV_ENABLE_MAP_VOTING" ) )
		command.PlayerCanUse = FSA_IsAdmin
	FSCC_RegisterCommand( "nextmap", command )
	command.PlayerCanUse = null

	command.m_UsageUser = "skip"
	command.m_UsageAdmin = "skip force"
	command.m_Description = "Allows you to vote to skip the current map."
	command.m_Group = "VOTE"
	command.m_Abbreviations = []
	command.Callback = FSV_CommandCallback_Skip
	if( !GetConVarBool( "FSV_ENABLE_MAP_SKIPPING" ) )
		command.PlayerCanUse = FSA_IsAdmin
	FSCC_RegisterCommand( "skip", command )
	command.PlayerCanUse = null

	command.m_UsageUser = "extend"
	command.m_UsageAdmin = "extend <minutes>"
	command.m_Description = "Allows you to vote to extend the current match."
	command.m_Group = "VOTE"
	command.m_Abbreviations = [ "ex" ]
	command.Callback = FSV_CommandCallback_Extend
	if( !GetConVarBool( "FSV_ENABLE_MAP_EXTENDING" ) )
		command.PlayerCanUse = FSA_IsAdmin
	FSCC_RegisterCommand( "extend", command )
	command.PlayerCanUse = null

// 	command.m_UsageUser = "testvote"
// 	command.m_UsageUser = "testvote <player-name>"
// 	command.m_Description = "Test MentalEdge's style of votes."
// 	command.m_Group = "VOTE"
// 	command.m_Abbreviations = ["tv"]
// 	command.Callback = FSV_CommandCallback_TestVote
// 	FSCC_RegisterCommand( "testvote", command)

	command.m_UsageUser = "kick <player-name>"
	command.m_UsageAdmin = "kick <player-name> force"
	command.m_Description = "Starts a vote to kick a player."
	command.m_Group = "VOTE"
	command.m_Abbreviations = []
	command.Callback = FSV_CommandCallback_Kick
	if( !GetConVarBool( "FSV_ENABLE_KICK_VOTING" ) )
		command.PlayerCanUse = FSA_IsAdmin
	FSCC_RegisterCommand( "kick", command)

	if( FSU_GetSettingIntFromConVar( "FSV_KICK_BLOCK" ) > 0 ){
		FSV_UpdateKicked()
		if( FSU_GetSettingIntFromConVar( "FSV_KICK_BLOCK" ) > 1 )
			AddCallback_OnClientConnected(FSV_JoiningPlayerKickCheck)
	}
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

// Updates last played (vote blocked) maps
void function UpdatePlayedMaps(){
    if(GetMapName() != "mp_lobby"){
        array <string> playedMaps = FSU_GetArrayFromConVar("FSV_MAP_REPLAY_LIMIT")
        playedMaps.append(GetMapName())
        while (playedMaps.len() > FSU_GetSettingIntFromConVar("FSV_MAP_REPLAY_LIMIT")){
            playedMaps.remove(0)
        }

        FSU_SaveArrayToConVar("FSV_MAP_REPLAY_LIMIT", playedMaps)
    }
}

/**
 * Runs on player connected, preventing any previously kicked players from re-joining
*/
void function FSV_JoiningPlayerKickCheck(entity player) {
    if (FSU_GetSelectedArrayFromConVar("FSV_KICK_BLOCK", 0).contains(player.GetUID())) {
        FSU_Print("previously kicked " + player.GetPlayerName() + " tried to rejoin")
        ServerCommand("kick " + player.GetPlayerName())
    }
}

/**
 * Updates the kicked player re-join block list, removing any expired blocks and incrementing existing ones
*/
void function FSV_UpdateKicked(){
    array <string> kicked = FSU_GetSelectedArrayFromConVar("FSV_KICK_BLOCK", 0)
    array <string> kickedfor = FSU_GetSelectedArrayFromConVar	("FSV_KICK_BLOCK", 1)
    int kickDuration = FSU_GetSettingIntFromConVar("FSV_KICK_BLOCK")

    for(int i = kickedfor.len()-1; i > -1; i--){
        kickedfor.insert(i, (kickedfor[i].tointeger()+1).tostring())
        kickedfor.remove(i+1)
        if(kickedfor[i].tointeger() > kickDuration){
            kickedfor.remove(i)
            kicked.remove(i)
        }
    }

    array <array <string> > newKickedArray = [kicked, kickedfor]
	FSU_SaveArrayArrayToConVar("FSV_KICK_BLOCK", newKickedArray)
}

/**
 * Gets the map to be played next
*/
string function FSV_GetNextMap(){
	array< string > maps = split( GetConVarString( "FSV_MAP_ROTATION" ), "," )

	// Remove any recently and the current maps so they don't immediately come up again when randomizing
    foreach (string blockedMap in FSU_GetArrayFromConVar("FSV_MAP_REPLAY_LIMIT")){
		if(maps.find(blockedMap) > -1){
			maps.remove(maps.find(blockedMap))
        }
    }

    // Get either a random next map, or the one next on the plalist
	if(GetConVarInt("FSV_RANDOM_MAP_ROTATION") == 1){
        return maps[RandomInt(maps.len()-1)]
	}

	if(maps.find(GetMapName()) > -1) {
		int nextMap = maps.find(GetMapName()) + 1
		if( nextMap >= maps.len() )
			nextMap = 0
		return maps[nextMap]
	}

	// pick a random playlist map if for example currently on a vote-only map
	return maps[RandomInt(maps.len()-1)]
}

/**
 * Gets called when the game enters Postmatch
*/
void function FSV_EndOfMatchMatch_Threaded() {
	wait GAME_POSTMATCH_LENGTH - 1

	int votes = 0
	foreach( string m, int v in mapVote.votes ) {
		if( v > votes ) {
			votes = v
			GameRules_ChangeMap( FSV_UnLocalize( m ), GAMETYPE )
			return
		}
	}

	GameRules_ChangeMap( FSV_GetNextMap(), GAMETYPE )
}


/**
 * Skips the current map
*/
void function FSV_SkipMatch() {
	SetServerVar( "gameEndTime", Time() )
}

/**
 * Extends the match
 * @param minutes The amount by which to extend the match
*/
void function FSV_ExtendMatch( float minutes ) {
	// Credit:
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
