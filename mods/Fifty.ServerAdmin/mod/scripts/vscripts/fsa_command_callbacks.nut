globalize_all_functions


/**
 * Gets called when a player runs !grunt
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSA_CommandCallback_NPC( entity player, array< string > args ) {
	if( args.len() == 0 ) {
		FSU_PrivateChatMessage( player, "Run " + FSU_Highlight( GetConVarString( "FSCC_PREFIX" ) + "npc <grunt/spectre/stalker/reaper/marvin> <imc/militia> to spawn a grunt." ) )
		return
	}

	int team = TEAM_UNASSIGNED
	string npc = "npc_soldier"
	if( args.len() >= 1 ) {
		if( args.len() >= 2 ) {
			switch( args[1].tolower() ) {
				case "imc":
					team = TEAM_IMC
					break
				case "militia":
					team = TEAM_MILITIA
					break
			}
		}

		switch( args[0].tolower() ) {
			case "grunt":
				npc = "npc_soldier"
				break
			case "spectre":
				npc = "npc_spectre"
				break
			case "stalker":
				npc = "npc_stalker"
				break
			case "marvin":
				npc = "npc_marvin"
				break
		}
	}


	thread DEV_SpawnNPCWithWeaponAtCrosshair( npc, npc, team )
	FSU_PrivateChatMessage( player, "Spawned a " + args[0] + "!" )
}

/**
 * Gets called when a player runs !login
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSA_CommandCallback_Login( entity player, array< string > args ) {
	if( FSA_GetLoggedInAdmins().find( player ) != -1 ) {
		FSU_PrivateChatMessage( player, "Already logged in!" )
		return
	}

	array< string > adminUIDs = split( GetConVarString( "FSA_ADMIN_UIDS" ), "," )
	int adminIndex
	adminIndex = adminUIDs.find( player.GetUID() )

	if( adminIndex == -1 ) {
		FSU_PrivateChatMessage( player, "You are not registered on this server. Only server owners can register admins." )
		return
	}

	if( args.len() == 0 ) {
		FSU_PrivateChatMessage( player, "Need to pass a password to login!" )
		return
	}

	array< string > passwords = split( GetConVarString( "FSA_ADMIN_PASSWORDS" ), "," )
	if( adminUIDs.len() == passwords.len() ) {
		FSU_Error( "FSA_ADMIN_UIDS length doesnt equal FSA_ADMIN_PASSWORDS length" )
		FSU_PrivateChatMessage( player, "FSA_ADMIN_UIDS && FSA_ADMIN_PASSWORDS length mismatch. Please check and correct the number of entries for both of thes ConVars!" )
		return
	}

	if( passwords[adminIndex] == args[0] ) {
		FSA_GetLoggedInAdmins().append( player )
		FSU_PrivateChatMessage( player, "Logged in!" )
		return
	}

	FSU_PrivateChatMessage( player, "Incorrect password!" )
}

/**
 * Gets called when a player runs !logout
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSA_CommandCallback_Logout( entity player, array< string > args ) {
	int adminIndex = FSA_GetLoggedInAdmins().find( player )
	if( adminIndex == -1 ) {
		FSU_PrivateChatMessage( player, "Not logged in!" )
		return
	}

	FSA_GetLoggedInAdmins().remove( adminIndex )
	FSU_PrivateChatMessage( player, "Logged out!" )
}
