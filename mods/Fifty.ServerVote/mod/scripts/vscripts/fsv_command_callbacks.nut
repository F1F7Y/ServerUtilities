globalize_all_functions

array <entity> extendVoters
int extendThreshold

array<entity> skipVoters
int skipThreshold

struct KickInfo {
	array<string> voters
	int threshold
}
table <string, KickInfo> kickTable = {}
array <string> playersWithActiveVotes


/**
 * Gets called when a player runs !nextmap
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSV_CommandCallback_NextMap( entity player, array< string > args ) {
	array <string> mapsInRotation = FSV_LocalizeArray( split( GetConVarString( "FSV_MAP_ROTATION" ), "," ))
	array <string> voteOnlyMaps = FSV_LocalizeArray( split( GetConVarString( "FSV_MAP_VOTE_ONLY" ), "," ))
	array <string> blockedMaps = FSV_LocalizeArray( FSU_GetArrayFromConVar( "FSV_MAP_REPLAY_LIMIT" ))

	array <string> maps
	maps.extend( mapsInRotation )
	maps.extend( voteOnlyMaps )

	if (args.len() == 0){
		FSU_PrivateChatMessage(player, "Maps in rotation:")
		FSU_PrintFormattedListWithoutPagination( player, mapsInRotation, "%T, ", "%S")

		if (voteOnlyMaps.len() > 0) {
			FSU_PrivateChatMessage(player, "Maps by vote only:")
			FSU_PrintFormattedListWithoutPagination( player, voteOnlyMaps, "%T, ", "%H")
		}
		if (blockedMaps.len() > 0) {
			FSU_PrivateChatMessage(player, "Recently played maps (not vote-able):")
			FSU_PrintFormattedListWithoutPagination( player, blockedMaps, "%T, ", "%E")
		}
		FSU_PrivateChatMessage(player, "Use %H%Pnextmap <map> %Tto vote for a certain map to be next.")
		return
	}

	int index = 0
	foreach( string map in maps ) {
		if( map.tolower().find( args[0].tolower() ) != null )
			break

		index++
	}

	if( index == maps.len() ) {
		FSU_PrivateChatMessage( player, "%EMap %H\"" + args[0] + "\"%E isn't in the voting pool!" )
		FSV_CommandCallback_NextMap(player, [])
		return
	}

	string mapVoteName = maps[index]
	string mapArg = FSV_UnLocalize(maps[index])

	if( FSA_IsAdmin( player ) && args.len() >= 2 ) {
		if( args[1].tolower() == "force" ) {
			GameRules_ChangeMap( mapArg, GAMETYPE )
			return
		} else {
			FSU_PrivateChatMessage( player, "Use %H%Pnextmap <map> force%T to forcefully change the map.")
			return
		}
	}

	if ( mapArg == GetMapName() && FSU_GetSettingIntFromConVar("FSV_MAP_REPLAY_LIMIT") > 0 ) {
		FSU_PrivateChatMessage(player, "%EYou can't vote for the current map!")
		return
	}

	foreach(string playedMap in FSU_GetArrayFromConVar("FSV_MAP_REPLAY_LIMIT")){
		if (mapArg == playedMap){
			FSU_PrivateChatMessage(player, "%EYou can't vote for a recently played map!")
			FSU_PrivateChatMessage(player, "Recently played maps (not vote-able):")
			FSU_PrintFormattedListWithoutPagination( player, blockedMaps, ", ", "%E")
			return
		}
	}

	if (player in FSV_GetMapVoteTable()) {
		if( mapArg == FSV_GetMapVoteTable()[player] ){
			FSU_PrivateChatMessage(player, "%EYou've already voted for %H" + mapVoteName + "%E!")
			return
		}
		else{
			FSU_PrivateChatMessage(player, "%SYour vote has been changed to: %H" + mapVoteName)
		}
	}
	else{
		FSU_PrivateChatMessage(player, "%SYou voted for: %H" + mapVoteName)
	}

	FSU_ChatBroadcast( "A player has voted for %H" + mapVoteName + "%N to be the next map, %H" + GetConVarString("FSCC_PREFIX")+"nm <map>" + "%N." )
	FSV_VoteForNextMap( player, mapArg )
	FSV_PrintNextMapChances()
}

/**
 * Gets called when a player runs !skip
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSV_CommandCallback_Skip( entity player, array< string > args ) {
	if( FSA_IsAdmin( player ) && args.len() >= 1 ) {
		if( args[0].tolower() == "force" ) {
			FSV_SkipMatch()
		} else {
			FSU_PrivateChatMessage( player, "You are admin. You can force skip: %H%Pskip force")
			return
		}
	}

	if (skipVoters.len() == 0) {
		skipThreshold = int(ceil(GetPlayerArray().len() * GetConVarFloat("FSV_MAP_SKIP_PERCENTAGE")))
		thread FSV_SkipThread()
	}

	if (!skipVoters.contains(player)) {
		skipVoters.append(player)
		FSU_PrivateChatMessage( player, "%SYou voted to skip this map!" )
	}
	else {
		FSU_PrivateChatMessage( player, "%EYou have already voted to skip this map!" )
		return
	}

	if ( skipThreshold > skipVoters.len() )
		return

	FSV_SkipMatch()
}

/**
 * Thread for skip votes
*/
void function FSV_SkipThread(){
	int timer = GetConVarInt("FSV_MAP_SKIP_DURATION")
	int nextUpdate = timer
	int lastVotes = skipVoters.len()

	// Announce the starting of a vote
	if(GetConVarBool("FSV_ENABLE_RUI")){
		foreach ( entity player in GetPlayerArray() ){
			NSSendAnnouncementMessageToPlayer( player, "VOTE TO SKIP MAP STARTED", "Use '!skip' in chat to add your vote", <1,0,0>, 0, 1 )
		}
		wait 1
		foreach ( entity player in GetPlayerArray() ){
			NSCreateStatusMessageOnPlayer( player, FSV_TimerToMinutesAndSeconds(timer), skipVoters.len() + "/" + skipThreshold + " have voted to skip", "skip"  )
		}
	}
	if(GetConVarBool("FSV_ENABLE_CHATUI")){
		FSU_ChatBroadcast( "%F[%T"+FSV_TimerToMinutesAndSeconds(timer)+" %FREMAINING]%H " + "A vote to skip this map has been started! Use %H%Pskip %Nto vote. %T" + skipThreshold + " votes will be needed." )
	}

	wait 5

	// Timer and UI update loop
	while(timer > 0 && skipVoters.len() < skipThreshold){
		if(timer == nextUpdate){
			if(GetConVarBool("FSV_ENABLE_RUI")){
				foreach (entity player in GetPlayerArray()) {
					NSEditStatusMessageOnPlayer( player, FSV_TimerToMinutesAndSeconds(timer), skipVoters.len() + "/" + skipThreshold + " have voted to skip", "skip" )
				}
			}
			if(GetConVarBool("FSV_ENABLE_CHATUI") && skipVoters.len() != lastVotes){
				FSU_ChatBroadcast( "%F[%T"+FSV_TimerToMinutesAndSeconds(timer)+" %FREMAINING]%H "+ skipVoters.len() + "/" + skipThreshold + "%N have voted to skip this map. %TUse %H%Pskip %Tto vote." )
				lastVotes = skipVoters.len()
			}
			nextUpdate -= 5
		}
		timer -= 1
		wait 1
	}

	// Announce results of vote
	if(GetConVarBool("FSV_ENABLE_RUI")){
		if(skipVoters.len() >= skipThreshold){
			foreach ( entity player in GetPlayerArray() ){
				NSSendAnnouncementMessageToPlayer( player, "MAP WILL BE SKIPPED", "Next map loading in 5 seconds", <1,0,0>, 0, 1 )
			}
			wait 1
			foreach ( entity player in GetPlayerArray() ){
				NSEditStatusMessageOnPlayer( player, "PASS", "Map will be skipped!", "skip" )
			}
		}
		else{
			foreach (entity player in GetPlayerArray()) {
				NSEditStatusMessageOnPlayer( player, "FAIL", "Not enough votes to skip!", "skip" )
			}
		}
	}
	if (GetConVarBool("FSV_ENABLE_CHATUI") ){
		if(skipVoters.len() >= skipThreshold){
			FSU_ChatBroadcast("Final vote received! %SMap will be skipped!")
		}
		else{
			FSU_ChatBroadcast("%EThe vote to skip this map has failed! %NNot enough votes.")
		}
	}

	// Reset everything
	skipVoters.clear()
	wait 10
	if(GetConVarBool("FSV_ENABLE_RUI")){
		foreach ( entity player in GetPlayerArray() ){
			NSDeleteStatusMessageOnPlayer( player, "skip" )
		}
	}
}


/**
 * Gets called when a player runs !extend
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSV_CommandCallback_Extend( entity player, array< string > args ) {

	if( FSA_IsAdmin( player ) && args.len() >= 1 ) {
		FSV_ExtendMatch( float( args[0].tointeger() ) )
		FSU_PrivateChatMessage( player, "%SExtended match." )
		return
	}

	foreach( entity ent in extendVoters ) {
		if( player == ent ) {
			FSU_PrivateChatMessage( player, "%EYou have already voted!" )
			return
		}
	}

	if (extendVoters.len() == 0) {
		extendThreshold = int(ceil(GetPlayerArray().len() * GetConVarFloat("FSV_MAP_EXTENDING_PERCENTAGE")))
		thread FSV_ExtendThread()
	}

	if (!extendVoters.contains(player)) {
		extendVoters.append(player)
		FSU_PrivateChatMessage(player, "%SYou voted to extend map time!" )
	}

	if (extendVoters.len() >= extendThreshold) {
		FSV_ExtendMatch( 20.0 )
	}
}

/**
 * Thread for extend votes
*/
void function FSV_ExtendThread(){
	int timer = GetConVarInt("FSV_MAP_EXTENDING_DURATION")
	int nextUpdate = timer
	int lastVotes = extendVoters.len()

	// Announce the starting of a vote
	if(GetConVarBool("FSV_ENABLE_RUI")){
		foreach (entity player in GetPlayerArray()) {
			NSSendAnnouncementMessageToPlayer( player, "VOTE TO EXTEND MAP TIME STARTED", "Use '"+GetConVarString( "FSCC_PREFIX" )+"extend' in chat to add your vote", <1,0,0>, 0, 1 )
		}
		wait 1
		foreach (entity player in GetPlayerArray()) {
			NSCreateStatusMessageOnPlayer( player, FSV_TimerToMinutesAndSeconds(timer),  extendVoters.len() + "/" + extendThreshold + "have voted to extend map time", "extend" )
		}
	}
	if(GetConVarBool("FSV_ENABLE_CHATUI")){
		FSU_ChatBroadcast( "%F[%T"+FSV_TimerToMinutesAndSeconds(timer)+" %FREMAINING]%H " + "A vote to extend map time has been started! Use %H%Pextend %Nto vote. %T" + extendThreshold + " votes will be needed." )
	}

	wait 5

	// Timer and UI update loop
	while(timer > 0 && extendVoters.len() < extendThreshold){
		if(timer == nextUpdate){
			if(GetConVarBool("FSV_ENABLE_RUI")){
				foreach (entity player in GetPlayerArray()) {
					NSEditStatusMessageOnPlayer( player, FSV_TimerToMinutesAndSeconds(timer), extendVoters.len() + "/" + extendThreshold + " have voted to extend map time", "extend" )
				}
			}
			if(GetConVarBool("FSV_ENABLE_CHATUI") && extendVoters.len() != lastVotes){
				FSU_ChatBroadcast( "%F[%T"+FSV_TimerToMinutesAndSeconds(timer)+" %FREMAINING]%H "+ extendVoters.len() + "/" + extendThreshold + "%N have voted to extend map time. %TUse %H%Pextend %Tto vote." )
				lastVotes = extendVoters.len()
			}
			nextUpdate -= 5
		}
		timer -= 1
		wait 1
	}

	// Announce results of vote
	if(GetConVarBool("FSV_ENABLE_RUI")){
		if(extendVoters.len() >= extendThreshold){
			foreach ( entity player in GetPlayerArray() ){
				NSSendAnnouncementMessageToPlayer( player, "Map time has been extended", "", <1,0,0>, 0, 1 )
			}
			wait 1
			foreach (entity player in GetPlayerArray()) {
				NSEditStatusMessageOnPlayer( player, "PASS", "Map time has been extended!", "extend" )
			}
		}
		else{
			foreach (entity player in GetPlayerArray()) {
				NSEditStatusMessageOnPlayer( player, "FAIL", "Not enough votes to extend map!", "extend" )
			}
		}
	}

	if (GetConVarBool("FSV_ENABLE_CHATUI") ){
		if(extendVoters.len() >= extendThreshold){
			FSU_ChatBroadcast("Final vote received! %SMap time has been extended!")
		}
		else{
			FSU_ChatBroadcast("%EThe vote to exend map time has failed! %NNot enough votes.")
		}
	}

	// Reset everything
	extendVoters.clear()
	wait 10
	if(GetConVarBool("FSV_ENABLE_RUI")){
		foreach ( entity player in GetPlayerArray() ){
			NSDeleteStatusMessageOnPlayer( player, "extend" )
		}
	}
}

/**
 * Gets called when a player runs !kick
 * @param player The player who called the command
 * @param args The arguments passed by the player
*/
void function FSV_CommandCallback_Kick( entity player, array<string> args) {

	if (args.len() == 0){
		FSU_PrivateChatMessage(player, "%ENo argument! %TWho is it you want to kick?")
		return
	}

	foreach(string uid in playersWithActiveVotes){
		if (uid == player.GetUID() && !(FSA_IsAdmin(player)) ){
			FSU_PrivateChatMessage(player, "%EYou can only have one kickvote active at a time! %TWait for the current one to expire or succeed before starting another.")
			return
		}
	}

	entity target
	foreach( entity p in GetPlayerArray() )
		if( p.GetPlayerName() == args[0] )
			target = p
	if( target == null ){
		//check for numbers in playerlist
		if( args[0] == "0" || ( args[0].tointeger() > 0 && args[0].tointeger() < GetPlayerArray().len()-1 ) ){
			entity p = FSA_GetPlayerEntityByName(args[0])
			if( p != null ){
				target = p
			}
		}
		//2nd check if its still not found
		if(target == null){
			FSU_PrivateChatMessage (player, "%EPlayer not found!" )
			return
		}
	}

	string targetUid = target.GetUID()
	string targetName = target.GetPlayerName()

	if (player == target) {
		FSU_PrivateChatMessage(player, "%EYou can't kick yourself!")
		return
	}

	if (FSA_IsAdmin(player) && args.len() == 2 && args[1] == "force") {
		// allow admins to force kick spoofed admins
		if (FSA_IsAdmin(target)) {
			FSU_PrivateChatMessage(player, "%EYou can't kick an authenticated admin!")
			return
		}

		FSU_Print( targetName + " kicked by admin:" + player.GetPlayerName())
		ServerCommand("kick " + target.GetPlayerName())
		FSU_ChatBroadcast("%H"+player.GetPlayerName() + " %Nwas kicked by an admin.")
		return
	}

	if (FSA_IsAdmin(target)) {
		FSU_PrivateChatMessage(player, "%EYou can't kick an admin.")
		return
	}

	// check if admin
	if (FSA_IsAdmin(player)){
		FSU_PrivateChatMessage(player, "%AYou are admin, you can force kick: %H%Pkick " + args[0] + " force")
	}

	int kickMinPlayers = GetConVarInt("FSV_KICK_MIN_PLAYERS")
	if (GetPlayerArray().len() < kickMinPlayers) {
		FSU_PrivateChatMessage(player, "%ENot enough players for vote kick! %TAt least " + kickMinPlayers + " are needed!")
		return
	}

	// ensure kicked player is in kickTable
	if (targetUid in kickTable) {
		KickInfo kickInfo = kickTable[targetUid]
		if (!kickInfo.voters.contains(player.GetUID())){
			kickInfo.voters.append(player.GetUID())
			playersWithActiveVotes.append(player.GetUID())
		}
		else{
			FSU_PrivateChatMessage( player, "%EYou have already voted to kick %H" + targetName + "%E!" )
			return
		}
	}
	else {
		KickInfo kickInfo
		kickInfo.voters = []
		kickInfo.voters.append(player.GetUID())
		kickInfo.threshold = int(ceil(GetPlayerArray().len() * GetConVarFloat("FSV_KICK_PERCENTAGE")))
		kickTable[targetUid] <- kickInfo
		thread FSV_KickThread(targetName, targetUid)
	}
	FSU_PrivateChatMessage(player, "%SYou voted to kick %H" + targetName + "%S!" )

	array <string> kickedPlayers = FSU_GetSelectedArrayFromConVar("FSV_KICK_BLOCK", 0)
	KickInfo kickInfo = kickTable[targetUid]
	if (kickInfo.voters.len() >= kickInfo.threshold) {
		FSU_Print( targetName + " was kicked by player vote!" )
		string playerUid = target.GetUID()
		if (kickedPlayers.contains(playerUid)) {
			kickedPlayers.append(playerUid)

			array <string> kicked = FSU_GetSelectedArrayFromConVar("FSV_KICK_BLOCK", 0)
			array <string> kickedfor = FSU_GetSelectedArrayFromConVar	("FSV_KICK_BLOCK", 1)
			kicked.append(targetUid)
			kickedfor.append("0")
			array <array <string> > newKickedArray = [kicked, kickedfor]
			FSU_SaveArrayArrayToConVar("FSV_KICK_BLOCK", newKickedArray)
		}

		ServerCommand("kick " + player.GetPlayerName())
		playersWithActiveVotes.remove( playersWithActiveVotes.find( kickInfo.voters[0] ) )
		if (targetUid in kickTable) {
			delete kickTable[targetUid]
		}
	}
	return
}

/**
 * Thread for kick votes
*/
void function FSV_KickThread(string targetName, string targetUid){
	int timer = GetConVarInt("FSV_KICK_DURATION")
	int nextUpdate = timer
	int lastVotes = kickTable[targetUid].voters.len()

	// Announce the starting of a vote
	if(GetConVarBool("FSV_ENABLE_RUI")){
		foreach (entity player in GetPlayerArray()) {
			if( player.GetUID() != targetUid ){
				NSSendAnnouncementMessageToPlayer( player, "VOTE TO KICK "+targetName+" STARTED", "Use '"+GetConVarString( "FSCC_PREFIX" )+"kick "+targetName+"' in chat to contribute your vote.", <1,0,0>, 0, 1 )
			}
		}
		wait 1
		foreach (entity player in GetPlayerArray()) {
			if( player.GetUID() != targetUid){
				NSCreateStatusMessageOnPlayer( player, FSV_TimerToMinutesAndSeconds(timer),  kickTable[targetUid].voters.len() + "/" + kickTable[targetUid].threshold + " have voted to kick " + targetName, "kick" + targetName )
			}
		}
	}
	if(GetConVarBool("FSV_ENABLE_CHATUI")){
		FSU_ChatBroadcast( "%F[%T"+FSV_TimerToMinutesAndSeconds(timer)+" %FREMAINING]%H " + "A vote to kick %H" + targetName + "%N has been started! Use %H%Pkick " + targetName + "%N to vote. %T" + kickTable[targetUid].threshold + " votes will be needed." )
	}

	wait 5

	// Timer and UI update loop
	while(timer > 0 && kickTable[targetUid].voters.len() < kickTable[targetUid].threshold){
		if(timer == nextUpdate){
			if(GetConVarBool("FSV_ENABLE_RUI")){
				foreach (entity player in GetPlayerArray()) {
					if( player.GetUID() != targetUid ){
						NSEditStatusMessageOnPlayer( player, FSV_TimerToMinutesAndSeconds(timer), kickTable[targetUid].voters.len() + "/" + kickTable[targetUid].threshold + " have voted to kick " + targetName, "kick" + targetName )
					}
				}
			}
			if(GetConVarBool("FSV_ENABLE_CHATUI") && kickTable[targetUid].voters.len() != lastVotes){
				FSU_ChatBroadcast( "%F[%T"+FSV_TimerToMinutesAndSeconds(timer)+" %FREMAINING]%H "+ kickTable[targetUid].voters.len() + "/" + kickTable[targetUid].threshold + "%N have voted to kick %H" + targetName + "%N. %TUse %H%Pkick  " + targetName + "%T to vote." )
				lastVotes = kickTable[targetUid].voters.len()
			}

			nextUpdate -= 5
		}
		timer -= 1
		wait 1
	}

	// Announce results of vote
	KickInfo kickInfo = kickTable[targetUid]
	if(GetConVarBool("FSV_ENABLE_RUI")){
		if (kickInfo.voters.len() >= kickInfo.threshold){
			foreach ( entity player in GetPlayerArray() ){
				NSSendAnnouncementMessageToPlayer( player, targetName + " has been kicked", "", <1,0,0>, 0, 1 )
			}
			wait 1
			foreach (entity player in GetPlayerArray()) {
				NSEditStatusMessageOnPlayer( player, "PASS", targetName + " has been kicked!", "kick" + targetName )
			}
		}
		else{
			foreach (entity player in GetPlayerArray()) {
				if( player.GetUID() != targetUid ){
					NSEditStatusMessageOnPlayer( player, "FAIL", "Not enough votes to kick " + targetName + "!", "kick" + targetName )
				}
			}
		}
	}
	if (GetConVarBool("FSV_ENABLE_CHATUI") ){
		if (kickInfo.voters.len() >= kickInfo.threshold){
			FSU_ChatBroadcast("Final vote received! %H"+ targetName + " %Shas been kicked!")
		}
		else{
			FSU_ChatBroadcast("%EThe vote to kick "+ targetName +" has failed! %NNot enough votes to kick.")
		}
	}

	// Reset everything
	if (targetUid in kickTable){
		delete kickTable[targetUid]
	}
	wait 10
	if(GetConVarBool("FSV_ENABLE_RUI")){
		foreach ( entity player in GetPlayerArray() ){
			NSDeleteStatusMessageOnPlayer( player, "kick" + targetName )
		}
	}
}

// //TestVote
// int testVoters = 0
//
// void function TestVoteHUD(){
//	 int threshold = RandomIntRange( 5, 9)
//
//	 foreach (entity player in GetPlayerArray()) {
//		 NSSendAnnouncementMessageToPlayer( player, "VOTE TO TEST STARTED", "Use '"+GetConVarString( "FSCC_PREFIX" )+"test' in chat to add your vote.", <1,0,0>, 0, 1 )
//	 }
//	 wait 1
//	 foreach (entity player in GetPlayerArray()) {
//		 NSCreateStatusMessageOnPlayer( player, "", testVoters + "/" + threshold + " have voted to test", "test" )
//	 }
//	 FSU_ChatBroadcast(  "A vote to test has been started! Use %H%Ptv %Nto vote! %T" + threshold + " votes will be needed." )
//
//	 int timer = 90
//	 int nextUpdate = timer
//	 int lastVotes = testVoters
//
//	 while(timer > 0 && testVoters < threshold){
//
//		 if(timer == nextUpdate){
//			 int minutes = int(floor(timer / 60))
//			 string seconds = string(timer - (minutes * 60))
//			 if (timer - (minutes * 60) < 10){
//				 seconds = "0"+seconds
//			 }
//
//			 foreach (entity player in GetPlayerArray()) {
//				 NSEditStatusMessageOnPlayer( player, FSV_TimerToMinutesAndSeconds(timer), testVoters + "/" + threshold + " have voted to test", "test" )
//			 }
//			 if(testVoters != lastVotes){
//				 FSU_ChatBroadcast( "%F[%T"+FSV_TimerToMinutesAndSeconds(timer)+" %FREMAINING]%H "+ testVoters + "/" + threshold + "%N have voted to test. %TUse %H%Ptv %Tto vote." )
//				 lastVotes = testVoters
//			 }
//
//			 nextUpdate -= 5
//		 }
//		 timer -= 1
//		 wait 1
//	 }
//
//	 if(testVoters >= threshold)
//		 foreach (entity player in GetPlayerArray()) {
//			 NSEditStatusMessageOnPlayer( player, "PASS", "Vote to test successful!", "test" )
//			 NSSendAnnouncementMessageToPlayer( player, "VOTE TO TEST SUCCESSFUL", "The thing you voted for will now happen!", <1,0,0>, 0, 1 )
//		 }
//	 else{
//		 foreach (entity player in GetPlayerArray()) {
//			 NSEditStatusMessageOnPlayer( player, "FAIL", "Not enough votes to test!", "test" )
//		 }
//	 }
//	 if (testVoters >= threshold){
//		 FSU_ChatBroadcast("%SVote to test successful!")
//	 }
//	 else{
//		 FSU_ChatBroadcast("%ENot enough votes to test!")
//	 }
//
//	 wait 10
//
//	 foreach ( entity player in GetPlayerArray() ){
//		 NSDeleteStatusMessageOnPlayer( player, "test" )
//	 }
//
//	 testVoters = 0
// }
//
// void function FSV_CommandCallback_TestVote(entity player, array<string> args) {
//	 if( testVoters == 0 ){
//		 thread TestVoteHUD()
//	 }
//	 testVoters += 1
// }
