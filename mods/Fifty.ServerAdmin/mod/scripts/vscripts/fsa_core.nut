global function FSA_Init
#if FSCC_ENABLED && FSU_ENABLED
global function FSA_IsAdmin

struct {
	array< entity > loggedin
} admins

/**
 * Gets called after the map is loaded
*/
void function FSA_Init() {
	if( GetConVarBool( "FSA_PREFIX_ADMINS_IN_CHAT" ) )
 		AddCallback_OnReceivedSayTextMessage( FSA_CheckForAdminMessage )

	FSCC_CommandStruct command
	command.m_UsageUser = "npc <npc> <team>"
	command.m_UsageAdmin = ""
	command.m_Description = "Spawns an npc at your crosshair."
	command.m_Group = "ADMIN"
	command.m_Abbreviations = []
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSCC_CommandCallback_NPC
	FSCC_RegisterCommand( "npc", command )

	if( GetConVarBool( "FSA_ADMINS_REQUIRE_LOGIN" ) ) {
		command.m_UsageUser = "login <password>"
		command.m_UsageAdmin = ""
		command.m_Description = "Logs you in if you are registered on the server as an admin."
		command.m_Group = "ADMIN"
		command.m_Abbreviations = []
		command.PlayerCanUse = null
		command.Callback = FSCC_CommandCallback_Login
		FSCC_RegisterCommand( "login", command )

		command.m_UsageUser = "logout"
		command.m_UsageAdmin = ""
		command.m_Description = "Logs you out if you are logged in as an admin"
		command.m_Group = "ADMIN"
		command.m_Abbreviations = []
		command.PlayerCanUse = FSA_IsAdmin
		command.Callback = FSCC_CommandCallback_Logout
		FSCC_RegisterCommand( "logout", command )
	}
}

/**
 * Gets called when a player runs !grunt
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_NPC( entity player, array< string > args ) {
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
void function FSCC_CommandCallback_Login( entity player, array< string > args ) {
	if( admins.loggedin.find( player ) != -1 ) {
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
		admins.loggedin.append( player )
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
void function FSCC_CommandCallback_Logout( entity player, array< string > args ) {
	int adminIndex = admins.loggedin.find( player )
	if( adminIndex == -1 ) {
		FSU_PrivateChatMessage( player, "Not logged in!" )
		return
	}

	admins.loggedin.remove( adminIndex )
	FSU_PrivateChatMessage( player, "Logged out!" )
}

/**
 * Gets called when a player sends a chat message
 * @param message The message struct containing information about the chat message
*/
ClServer_MessageStruct function FSA_CheckForAdminMessage( ClServer_MessageStruct message ) {
	if( message.message.find( GetConVarString( "FSCC_PREFIX" ) ) == 0 || message.message.len() == 0 || message.shouldBlock ) {
		message.shouldBlock = true
		return message
	}

	if( FSA_IsAdmin( message.player ) ) {
		Chat_Impersonate( message.player, FSU_FmtAdmin() + "[ADMIN]: " + FSU_FmtEnd() + message.message, false )
		message.shouldBlock = true
	}

	return message
}

/**
 * Returns true if player is an admin
 * @ param player The player to check
*/
bool function FSA_IsAdmin( entity player ) {
	array< string > adminUIDs = split( GetConVarString( "FSA_ADMIN_UIDS" ), "," )

	if( adminUIDs.find( player.GetUID() ) != -1 ) {
		if( !GetConVarBool( "FSA_ADMINS_REQUIRE_LOGIN" ) || GetConVarBool( "FSA_ADMINS_REQUIRE_LOGIN" ) && admins.loggedin.find( player ) != -1 )
			return true
	}

	return false
}

#else
void function FSA_Init() {
	print( "[FSA][ERRR] FSU and FSCC Need to be enabled for FSA to work!!!" )
}
#endif
