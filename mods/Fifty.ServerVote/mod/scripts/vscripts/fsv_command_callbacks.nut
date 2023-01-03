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
		FSU_PrivateChatMessage( player, "Extended match." )
		return
	}

	array< entity > playerBlacklist = FSV_GetPlayerArrayReference_Extend()

	foreach( entity ent in playerBlacklist ) {
		if( player == ent ) {
			FSU_PrivateChatMessage( player, "You have already voted!" )
			return
		}
	}

	playerBlacklist.append( player )
	FSU_ChatBroadcast( "%H" + player.GetPlayerName() + "%T voted to extend this match. %H[" + playerBlacklist.len() + "/" + ceil( GetPlayerArray().len() / 2.0 ) + "]" )


	if ( ceil( GetPlayerArray().len() / 2.0 ) > playerBlacklist.len() )
		return

	FSU_ChatBroadcast( "Extending current match." )

	FSV_ExtendMatch( 20.0 )

	playerBlacklist.clear()
}

void function FSV_CommandCallback_Kick( entity player, array<string> args){
	if(args.len()==0){
		FSU_PrivateChatMessage(player, "Missing argument")
		return
	}
	if( FSA_IsAdmin( player ) ){
		string toBan = ""
	foreach(entity p in GetPlayerArray())
		if(p.GetPlayerName() == args[0] )
			toBan = p.GetPlayerName()

	if(toBan == ""){
		//check for numbers in playerlist 
		if(args[0] == "0" || ( args[0].tointeger() > 0 && args[0].tointeger() < GetPlayerArray().len()-1 ) ){
			entity p = FSA_GetPlayerEntityByName(args[0])
			if(p != null){
				toBan = p.GetPlayerName()
			}
		}
		//2nd check if its still not found 
		if(toBan == ""){
			FSU_PrivateChatMessage(player, "Player not found")
			return
		}
	}

	ServerCommand("kick " + toBan)
  	FSU_PrivateChatMessage(player, "Sucessfully kicked")
	return
	}//IS NOT ADMIN
	else{
		if( !FSV_CanPlayerStartKick( player ) ){
			FSU_PrivateChatMessage( player,"You started too many votes, to protect against spam you can no longer start votes")
			return
		}
		entity playerToBeKicked = FSA_GetPlayerEntityByName( args[0] )
		if( playerToBeKicked == null){
			FSU_PrivateChatMessage(player, "Player was not found" )
			return
		}
		FSV_increaseVoteForPlayer(player)
		thread FSV_PlayerKickVote( playerToBeKicked )
	}
		
}