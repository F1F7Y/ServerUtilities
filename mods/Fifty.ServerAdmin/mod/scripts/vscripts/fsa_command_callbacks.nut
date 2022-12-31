globalize_all_functions


/**
 * Gets called when a player runs !npc
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSA_CommandCallback_NPC( entity player, array< string > args ) {
	if( args.len() == 0 ) {
		FSU_PrivateChatMessage( player, "Run %H%Pnpc <grunt/spectre/stalker/reaper/marvin> <imc/militia>%T to spawn an npc." )
		return
	}

	int team = TEAM_UNASSIGNED
	string npc = ""
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

	if( npc.len() == 0 ) {
		FSU_PrivateChatMessage( player, "Couldn't find entity: " + args[0] )
		return
	}

	thread DEV_SpawnNPCWithWeaponAtCrosshair( npc, npc, team )
	FSU_PrivateChatMessage( player, "Spawned a " + args[0] + "!" )
}

/**
 * Gets called when a player runs !titan
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSA_CommandCallback_Titan( entity player, array< string > args ) {
	if( args.len() == 0 ) {
		FSU_PrivateChatMessage( player, "Run %H%Ptitan <ion/scorch/northstar/ronin/tone/legion/monarch> <imc/militia>%T to spawn a titan." )
		return
	}

	int team = TEAM_UNASSIGNED
	string titan = ""
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
			case "ion":
				titan = "npc_titan_auto_atlas_ion_prime"
				break
			case "scorch":
				titan = "npc_titan_ogre_meteor"
				break
			case "northstar":
				titan = "npc_titan_auto_stryder_sniper"
				break
			case "ronin":
				titan = "npc_titan_auto_stryder_leadwall"
				break
			case "tone":
				titan = "npc_titan_atlas_tracker"
				break
			case "legion":
				titan = "npc_titan_auto_ogre_minigun"
				break
			case "monarch":
				titan = "npc_titan_auto_atlas_vanguard"
				break
		}
	}

	if( titan.len() == 0 ) {
		FSU_PrivateChatMessage( player, "Couldn't find entity: " + args[0] )
		return
	}

	thread DEV_SpawnNPCWithWeaponAtCrosshair( "npc_titan", titan, team )
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
	if( adminUIDs.len() != passwords.len() ) {
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
