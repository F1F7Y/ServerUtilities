globalize_all_functions

/**
 * Gets called when a player runs !nextmap
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSV_CommandCallback_NextMap( entity player, array< string > args ) {
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
		FSU_PrivateChatMessage( player, "Map %H\"" + args[0] + "\"%T isn't in the voting pool!" )
		return
	}

	if( FSA_IsAdmin( player ) && args.len() >= 2 ) {
		if( args[1].tolower() == "force" ) {
			GameRules_ChangeMap( FSV_UnLocalize( maps[index] ), GAMETYPE )
			return
		} else {
			FSU_PrivateChatMessage( player, "Use %H%Pnextmap <map> force%T  to forcefully change the map.")
			return
		}
	}

	array< entity > playerBlacklist = FSV_GetPlayerArrayReference_NextMap()

	foreach( entity ent in playerBlacklist ) {
		if( player == ent ) {
			FSU_PrivateChatMessage( player, "You have already voted!" )
			return
		}
	}


	FSU_ChatBroadcast( "%H" + player.GetPlayerName() + "%T voted %H" + maps[index] + "%T as the next map." )
	FSV_VoteForNextMap( player, maps[index] )
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
			FSU_PrivateChatMessage( player, "Use %H%Pskip force%T to forcefully skip the map.")
			return
		}
	}

	array< entity > playerBlacklist = FSV_GetPlayerArrayReference_Skip()

	foreach( entity ent in playerBlacklist ) {
		if( player == ent ) {
			FSU_PrivateChatMessage( player, "You have already voted!" )
			return
		}
	}

	playerBlacklist.append( player )
	FSU_ChatBroadcast( "%H" + player.GetPlayerName() + "%T voted to skip this map. %H[" + playerBlacklist.len() + "/" + ceil( GetPlayerArray().len() / 2.0 ) + "]" )


	if ( ceil( GetPlayerArray().len() / 2.0 ) > playerBlacklist.len() )
		return

	FSU_ChatBroadcast( "Skipping current map." )

	FSV_SkipMatch()
}

/**
 * Gets called when a player runs !maps
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSV_CommandCallback_Maps( entity player, array< string > args ) {
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
		FSU_PrivateChatMessage( player, "Maximum number of pages is: %H" + string( pages ) )
		return
	}

	if( page < 1 )
		page = 1

	FSU_PrivateChatMessage( player, "List of avalible maps:" )
	FSU_PrintFormattedList( player, maps, page, 2 )
	FSU_PrivateChatMessage( player, "Page: %H[" + page + "/" + pages + "]" )
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

	array< entity > playerBlacklist = FSV_GetPlayerArrayReference_Extend()

	foreach( entity ent in playerBlacklist ) {
		if( player == ent ) {
			FSU_PrivateChatMessage( player, "%EYou have already voted!" )
			return
		}
	}

	playerBlacklist.append( player )
	FSU_ChatBroadcast( "%H" + player.GetPlayerName() + "%T voted to extend this match. %H[" + playerBlacklist.len() + "/" + ceil( GetPlayerArray().len() / 2.0 ) + "]" )


	if ( ceil( GetPlayerArray().len() / 2.0 ) > playerBlacklist.len() )
		return

	FSU_ChatBroadcast( "%NMap time has been extended!" )

	FSV_ExtendMatch( 20.0 )

	playerBlacklist.clear()
}

// void function FSV_ExtendHUDThread(){
//     foreach (entity player in GetPlayerArray()) {
//         NSSendAnnouncementMessageToPlayer( player, "VOTE TO EXTEND MAP TIME STARTED", "Use '"+GetConVarString( "FSCC_PREFIX" )+"extend' in chat to add your vote", <1,0,0>, 0, 1 )
//     }
//     wait 1
//     foreach (entity player in GetPlayerArray()) {
//         NSCreateStatusMessageOnPlayer( player, "",  extendVoters.len() + "/" + extendThreshold + "have voted to extend map time", "extend" )
//     }
//
//     int timer = GetConVarInt("FSV_MAP_EXTENDING_DURATION")
//
//     while(timer > 0 && extendVoters.len() < extendThreshold){
//         int minutes = int(floor(timer / 60))
//         string seconds = string(timer - (minutes * 60))
//         if (timer - (minutes * 60) < 10){
//             seconds = "0"+seconds
//         }
//
//         foreach (entity player in GetPlayerArray()) {
//             NSEditStatusMessageOnPlayer( player, minutes + ":" + seconds, extendVoters.len() + "/" + extendThreshold + " have voted to extend map time", "extend" )
//         }
//         timer -= 1
//         wait 1
//     }
//
//     if(extendVoters.len() >= extendThreshold){
//         foreach ( entity player in GetPlayerArray() ){
//             NSSendAnnouncementMessageToPlayer( player, "Map time has been extended", "", <1,0,0>, 0, 1 )
//         }
//         wait 1
//         foreach (entity player in GetPlayerArray()) {
//             NSEditStatusMessageOnPlayer( player, "PASS", "Map time has been extended!", "extend" )
//         }
//     }
//     else{
//         foreach (entity player in GetPlayerArray()) {
//             NSEditStatusMessageOnPlayer( player, "FAIL", "Not enough votes to extend map!", "extend" )
//         }
//     }
//
//     wait 10
//     foreach ( entity player in GetPlayerArray() ){
//         NSDeleteStatusMessageOnPlayer( player, "extend" )
//     }
//     file.extendVoters.clear()
// }

/**
 * Gets called when a player runs !kick
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
struct KickInfo {
    array<string> voters
    int threshold
}
table <string, KickInfo> kickTable = {}
array <string> playersWithActiveVotes
float kickPercentage = 0.3
array <string> kickedPlayers

void function FSV_CommandCallback_Kick( entity player, array<string> args) {

    if (args.len() == 0){
        FSU_PrivateChatMessage(player, "%ENo argument. %TWho is it you want to kick?")
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
        FSU_PrivateChatMessage(player, "%AYou are admin, you can force kick: %H"+GetConVarString( "FSCC_PREFIX" )+"kick " + args[0] + " force")
    }

	int kickMinPlayers = GetConVarInt("FSV_KICK_MIN_PLAYERS")
    if (GetPlayerArray().len() < kickMinPlayers) {
        // TODO: store into kicktable anyway?
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
        if(GetConVarBool("FSV_ENABLE_RUI"))
			thread FSV_KickHUDThread(targetName, targetUid)
    }
    FSU_PrivateChatMessage(player, "%SYou voted to kick %H" + targetName + "%S!" )
    FSU_ChatBroadcast( "%H"+ kickTable[targetUid].voters.len() + "/" + kickTable[targetUid].threshold + "%N have voted to kick %H" + targetName + "%T, %H" + GetConVarString( "FSCC_PREFIX" )+"kick  " + targetName + "%N to vote." )

	kickedPlayers = FSU_GetSelectedArrayFromConVar("FSV_KICK_BLOCK", 0)
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
		FSU_ChatBroadcast("%H"+player.GetPlayerName() + " %Nhas been kicked!")
        playersWithActiveVotes.remove( playersWithActiveVotes.find( kickInfo.voters[0] ) )
    }

    return
}

/**
 * RUI HUD Thread for kick votes
*/
void function FSV_KickHUDThread(string targetName, string targetUid){

    foreach (entity player in GetPlayerArray()) {
        if( player.GetUID() != targetUid){
            NSSendAnnouncementMessageToPlayer( player, "VOTE TO KICK "+targetName+" STARTED", "Use '"+GetConVarString( "FSCC_PREFIX" )+"kick "+targetName+"' in chat to contribute your vote.", <1,0,0>, 0, 1 )
        }
    }
    wait 1
    foreach (entity player in GetPlayerArray()) {
        if( player.GetUID() != targetUid){
            NSCreateStatusMessageOnPlayer( player, "",  kickTable[targetUid].voters.len() + "/" + kickTable[targetUid].threshold + " have voted to kick " + targetName, "kick" + targetName )
        }
    }

    int timer = GetConVarInt("FSV_KICK_DURATION")

    while(timer > 0 && kickTable[targetUid].voters.len() < kickTable[targetUid].threshold){
        int minutes = int(floor(timer / 60))
        string seconds = string(timer - (minutes * 60))
        if (timer - (minutes * 60) < 10){
            seconds = "0"+seconds
        }

        foreach (entity player in GetPlayerArray()) {
            if( player.GetUID() != targetUid ){
                NSEditStatusMessageOnPlayer( player, minutes + ":" + seconds, kickTable[targetUid].voters.len() + "/" + kickTable[targetUid].threshold + " have voted to kick " + targetName, "kick" + targetName )
            }
        }
        timer -= 1
        wait 1
    }

	KickInfo kickInfo = kickTable[targetUid]
    if (kickInfo.voters.len() >= kickInfo.threshold){
        foreach ( entity player in GetPlayerArray() ){
            NSSendAnnouncementMessageToPlayer( player, player.GetPlayerName() + " has been kicked", "", <1,0,0>, 0, 1 )
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

    wait 10

    foreach ( entity player in GetPlayerArray() ){
        NSDeleteStatusMessageOnPlayer( player, "kick" + targetName )
    }
    if (targetUid in kickTable) {
        delete kickTable[targetUid]
    }
}

/**
 * Updates the kicked player re-join block list
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
 * Runs on player connected, preventing any previusly kicked players from re-joining
*/
void function FSV_JoiningPlayerKickCheck(entity player) {
    if (kickedPlayers.contains(player.GetUID())) {
        FSU_Print("previously kicked " + player.GetPlayerName() + " tried to rejoin")
        ServerCommand("kick " + player.GetPlayerName())
    }
}
