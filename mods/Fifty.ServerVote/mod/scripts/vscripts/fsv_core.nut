globalize_all_functions

#if FSCC_ENABLED && FSU_ENABLED

table <entity, string> mapVoteTable = {}

/**
 * Gets called after the map is loaded
*/
void function FSV_Init() {
	if (FSU_GetSettingIntFromConVar("FSV_MAP_REPLAY_LIMIT") > 0)
		FSV_UpdatePlayedMaps()

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
// 	command.m_Description = "Test MentalEdge's style of votes."
// 	command.m_Group = "VOTE"
// 	command.m_Abbreviations = ["tv"]
// 	command.Callback = FSV_CommandCallback_TestVote
// 	FSCC_RegisterCommand( "testvote", command)

	command.m_UsageUser = "kick <partial/full-name>"
	command.m_UsageAdmin = "kick <partial/full-name> force"
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
 * Updates last played (vote blocked) maps
*/
void function FSV_UpdatePlayedMaps(){
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
 * Convert seconds to minutes and seconds
*/
string function FSV_TimerToMinutesAndSeconds(int timer){
	int minutes = int(floor(timer / 60))
	string seconds = string(timer - (minutes * 60))
	if (timer - (minutes * 60) < 10){
		seconds = "0"+seconds
	}
	return minutes + ":" + seconds
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
 * Adds a vote to a map
 * @param player The player who voted
 * @param map The map to vote for
*/
void function FSV_VoteForNextMap( entity player, string map ) {
	mapVoteTable[player] <- map;
}

/**
 * Grab a reference to the mvt
*/
table <entity, string> function FSV_GetMapVoteTable() {
	return mapVoteTable
}

/**
 * Get current next map chances
*/
string function FSV_GetNextMapChances() {
	table <string, float> mapChances
	foreach(entity player, string map in mapVoteTable){
		if((map in mapChances))
			mapChances[map] += 100.0 / mapVoteTable.len()
		else
			mapChances[map] <- 100.0 / mapVoteTable.len()
	}
	string message = ""
	foreach(string map, float chance in mapChances){
		if (message == "")
			message += FSV_Localize(map) + " %T" + floor(chance) + "%"
		else
			message += ", %H" + FSV_Localize(map) + " %T" + floor(chance) + "%"
	}
	return message
}

/**
 * Gets the map to be played next
*/
string function FSV_GetNextMap() {
	table< string, int > mapVotes

	// If there have been votes, choose a random one from the vote-pool
	if( mapVoteTable.len() > 0 ) {
		foreach( entity player, string map in mapVoteTable ) {
			if( map in mapVotes )
				mapVotes[map]++
			else
				mapVotes[map] <- 1
		}

		string bestMap;
		int    mostVotes;
		foreach( string map, int votes in mapVotes ) {
			if( votes > mostVotes ) {
				bestMap = map
				mostVotes = votes
			}
		}

		return bestMap
	}

	// Create array of valid next maps
	array<string> maps = FSV_GetMapArrayFromConVar( "FSV_MAP_ROTATION" )
	foreach( string blockedMap in FSU_GetArrayFromConVar( "FSV_MAP_REPLAY_LIMIT" ) ) {
		int index = maps.find(blockedMap)
		if( index != -1 ){
			maps.remove( index )
		}
	}

	// Return a random map if set
	if( GetConVarInt( "FSV_RANDOM_MAP_ROTATION" ) ) {
		return maps[RandomInt(maps.len()-1)]
	}

	// Need to get the array again because we remove current map above
	maps = FSV_GetMapArrayFromConVar( "FSV_MAP_ROTATION" )
	// Return the next map
	int index = maps.find( GetMapName() )
	if( index != -1 ) {
		int nextMap = index + 1
		if( nextMap >= maps.len() )
			nextMap = 0

		return maps[nextMap]
	}

	FSU_Error( "Couldn't get the next map!" );

	// If there is no valid next map, pick a random one
	return maps[RandomInt(maps.len()-1)]
}

/**
 * Gets called when the game enters Postmatch
*/
void function FSV_EndOfMatchMatch_Threaded() {
	wait GAME_POSTMATCH_LENGTH - 1

	GameRules_ChangeMap( FSV_GetNextMap(), GAMETYPE )
}


/**
 * Skips the current map
*/
void function FSV_SkipMatch() {
	SetServerVar( "gameEndTime", Time()+4 )
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
