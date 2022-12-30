globalize_all_functions

#if FSCC_ENABLED && FSU_ENABLED

struct {
	array< entity > loggedin
} admins

/**
 * Gets called after the map is loaded
*/
void function FSA_Init() {
	if( GetConVarBool( "FSA_PREFIX_ADMINS_IN_CHAT" ) )
 		AddCallback_OnReceivedSayTextMessage( FSA_CheckForAdminMessage )

	if( GetConVarBool("FSA_HIGHLIGHT_OWNERS_IN_CHAT") )
	AddCallback_OnReceivedSayTextMessage( FAS_AddOwnerTag )

	FSCC_CommandStruct command
	command.m_UsageUser = "npc <npc> <team>"
	command.m_UsageAdmin = ""
	command.m_Description = "Spawns an npc at your crosshair."
	command.m_Group = "ADMIN"
	command.m_Abbreviations = []
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSA_CommandCallback_NPC
	FSCC_RegisterCommand( "npc", command )

	if( GetConVarBool( "FSA_ADMINS_REQUIRE_LOGIN" ) ) {
		command.m_UsageUser = "login <password>"
		command.m_UsageAdmin = ""
		command.m_Description = "Logs you in if you are registered on the server as an admin."
		command.m_Group = "ADMIN"
		command.m_Abbreviations = []
		command.PlayerCanUse = null
		command.Callback = FSA_CommandCallback_Login
		FSCC_RegisterCommand( "login", command )

		command.m_UsageUser = "logout"
		command.m_UsageAdmin = ""
		command.m_Description = "Logs you out if you are logged in as an admin"
		command.m_Group = "ADMIN"
		command.m_Abbreviations = []
		command.PlayerCanUse = FSA_IsAdmin
		command.Callback = FSA_CommandCallback_Logout
		FSCC_RegisterCommand( "logout", command )
	}
}

/**
 * Returns loggedin admins
*/
array< entity > function FSA_GetLoggedInAdmins() {
	return admins.loggedin
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

	if( FSA_IsAdmin( message.player ) && split(GetConVarString( "FSA_OWNERS" ),",").find(message.player.GetUID()) == -1  ){
		message.shouldBlock = true
		FSA_sendMessageWithPrefix(message.player, message.message, message.isTeam, "ADMIN")
	}

	return message
}
ClServer_MessageStruct function FAS_AddOwnerTag( ClServer_MessageStruct message ){
	
	message.shouldBlock = true
	FSA_sendMessageWithPrefix(message.player, message.message, message.isTeam, "OWNER")
	return message
}

void function FSA_sendMessageWithPrefix(entity from, string message, bool isTeamMessage, string prefix){
	foreach( entity p in GetPlayerArray() ){
			if( isTeamMessage && p.GetTeam() != from.GetTeam())
				continue
			Chat_ServerPrivateMessage( p, FSU_FmtAdmin() + "["+ prefix +"] " + FSU_FmtEnd() + ((p.GetTeam() == from.GetTeam()) ? "\x1b[111m" : "\x1b[112m" )+ from.GetPlayerName() + FSU_FmtEnd()+ ": "+ message, isTeamMessage, false)
		}
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
