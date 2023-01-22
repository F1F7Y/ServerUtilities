untyped
globalize_all_functions

#if FSCC_ENABLED && FSU_ENABLED

struct {
	array< entity > loggedin
} admins

/**
 * Gets called after the map is loaded
*/
void function FSA_Init() {
	AddCallback_OnReceivedSayTextMessage( FSA_CheckMessageForPrivilegedUser )

	FSCC_CommandStruct command
	command.m_UsageUser = "npc <npc> <team>"
	command.m_UsageAdmin = ""
	command.m_Description = "Spawns an npc at your crosshair."
	command.m_Group = "ADMIN"
	command.m_Abbreviations = []
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSA_CommandCallback_NPC
	FSCC_RegisterCommand( "npc", command )

	command.m_UsageUser = "titan <type> <team>"
	command.m_Description = "Spawns a titan at your crosshair."
	command.m_Group = "ADMIN"
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSA_CommandCallback_Titan
	FSCC_RegisterCommand( "titan", command )

	command.m_UsageUser = "playerlist"
	command.m_UsageAdmin = ""
	command.m_Description = "Shows the playerlist for the index of each player"
	command.m_Group = "ADMIN"
	command.m_Abbreviations = ["pl"]
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSCC_CommandCallback_Playerlist
	FSCC_RegisterCommand( "playerlist", command )

	command.m_UsageUser = "script <code>"
	command.m_UsageAdmin = ""
	command.m_Description = "Executes code on the server"
	command.m_Group = "ADMIN"
	command.m_Abbreviations = []
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSCC_CommandCallback_Script
	FSCC_RegisterCommand( "script", command )

	command.m_UsageUser = "ServerCommand <command>"
	command.m_UsageAdmin = ""
	command.m_Description = "Executes a command on the server"
	command.m_Group = "ADMIN"
	command.m_Abbreviations = ["sc"]
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSCC_CommandCallback_ServerCommand
	FSCC_RegisterCommand( "serverCommand", command )

	command.m_UsageUser = "reload <time=5>"
	command.m_UsageAdmin = ""
	command.m_Description = "Reloads the server"
	command.m_Group = "ADMIN"
	command.m_Abbreviations = []
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSCC_CommandCallback_Reload
	FSCC_RegisterCommand( "reload", command )

	command.m_UsageUser = "ban <player name>"
	command.m_UsageAdmin = ""
	command.m_Description = "Bans the given player"
	command.m_Group = "ADMIN"
	command.m_Abbreviations = []
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSCC_CommandCallback_Ban
	FSCC_RegisterCommand( "ban", command )

	command.m_UsageUser = "commandFor <player name> <command>"
	command.m_UsageAdmin = ""
	command.m_Description = "Executes a command for a player"
	command.m_Group = "ADMIN"
	command.m_Abbreviations = []
	command.PlayerCanUse = FSA_IsAdmin
	command.Callback = FSCC_CommandCallback_CommandFor
	FSCC_RegisterCommand( "commandFor", command )

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
ClServer_MessageStruct function FSA_CheckMessageForPrivilegedUser( ClServer_MessageStruct message ) {
	if( message.message.find( GetConVarString( "FSCC_PREFIX" ) ) == 0 || message.message.len() == 0 || message.shouldBlock ) {
		message.shouldBlock = true
		return message
	}

	array< string > tagsList = split( GetConVarString( "FSA_USER_TAGS" ), "," )
	array< string > uidList = split( GetConVarString( "FSA_USER_TAG_UIDS" ), "," )
	array< string > colorList = split( GetConVarString( "FSA_USER_TAG_COLORS" ), "," )

	array< string > tags
	if( tagsList.len() == uidList.len() && uidList.len() == colorList.len() ) {
		for( int i = 0; i < tagsList.len(); i++ ) {
			if( message.player.GetUID() == uidList[i] )
				tags.append( colorList[i] + "[" + tagsList[i] + "]" )
		}
	} else {
		FSU_Error( "FSA_TAG convar length mismatch!" )
	}


	if( FSA_IsOwner( message.player ) && GetConVarBool( "FSA_PREFIX_OWNERS_IN_CHAT" ) ) {
		message.shouldBlock = true
		tags.append( "%O[OWNER]")
		FSA_SendMessageWithPrefix( message.player, message.message, message.isTeam,  tags )
		return message
	}

	if( FSA_IsAdmin( message.player ) && GetConVarBool( "FSA_PREFIX_ADMINS_IN_CHAT" ) ) {
		message.shouldBlock = true
		tags.append( "%A[ADMIN]" )
		FSA_SendMessageWithPrefix(message.player, message.message, message.isTeam, tags )
		return message
	}

	return message
}

/**
 * Sends a message with a prefix
 * @param from The player who originally sent the message
 * @param message The message string
 * @param isTeamMessage Whether it was sent in team or grobal chat
 * @param prefix The prefix to add
*/
void function FSA_SendMessageWithPrefix( entity from, string message, bool isTeamMessage, array< string > prefix ){
	foreach( entity p in GetPlayerArray() ) {
		if( isTeamMessage && p.GetTeam() != from.GetTeam())
			continue

		string tags
		foreach( string tag in prefix )
			tags += tag

		Chat_ServerPrivateMessage( p, FSU_FormatString( tags + ((p.GetTeam() == from.GetTeam()) ? "\x1b[111m " : "\x1b[112m " ) + from.GetPlayerName() + ( isTeamMessage ? "(Team)" : "") + "%0: " )  + message, false, false )
	}
}

/**
 * Returns true if player is an owner
 * @ param player The player to check
*/
bool function FSA_IsOwner( entity player ) {
	array< string > ownerUIDs = split( GetConVarString( "FSA_OWNERS" ), "," )

	if( ownerUIDs.find( player.GetUID() ) != -1 ) {
		return true
	}

	return false
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
/*
 * Returns the entity of a player name returns null if no player was found
 * @ param name The name of the player you want the entity of
*/
entity function FSA_GetPlayerEntityByName(string name){

	if(name == "")
    	return null


  foreach(entity p in GetPlayerArray())
    if(p.GetPlayerName().tolower() == name.tolower())
      return p


  if(name.len() <= 2){
    int PlayerIndex = name.tointeger()
    if(GetPlayerArray().len()-1>= PlayerIndex && PlayerIndex > -1) // check if the index exits
      return GetPlayerArray()[PlayerIndex]
  }

  return null
}

/**
 * Gets called when a player runs !playerlist
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Playerlist( entity player, array< string > args ){
	array< string > printList
	foreach( index, entity p in GetPlayerArray() ) {
		printList.append( p.GetPlayerName() )
		printList.append( index.tostring() )
	}
	int pages = FSU_GetListPages(printList) +1
	for( int page = 1; page< pages; page++ )
		FSU_PrintFormattedList(player, printList, page)
}

/**
 * Gets called when a player runs !script
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Script(entity player, array<string> args){
  if(args.len() == 0){
    FSU_PrivateChatMessage(player, "%EMissing arguments: !script <code here>")
    return
  }
  try{
    compilestring( FSU_ArrayToString(args) )()
    FSU_PrivateChatMessage(player, "%SYour code seems to have compiled")
    return
  }
  catch ( ex ){
    printt(ex)
    FSU_PrivateChatMessage(player, "%EThe code has caused an exception, the error can be found in the server log")
    return
  }
}

/**
 * Gets called when a player runs !serverCommand
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_ServerCommand(entity player, array<string> args){
  if(args.len()==0)
  {
    FSU_PrivateChatMessage(player, "%EMissing arguments")
    return
  }
  try{
    ServerCommand(FSU_ArrayToString(args))
  }
  catch(ex){
    FSU_PrivateChatMessage(player,"%EThe command has caused an exception")
  }
  FSU_PrivateChatMessage(player, "%SCommand executed")

}

/**
 * Gets called when a player runs !reload
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Reload(entity player, array<string> args){

  if(args.len() <= 0)
    thread FSU_C_Reload_thread(5.0)
  else
    thread FSU_C_Reload_thread(args[0].tofloat())
}

void function FSU_C_Reload_thread(float time){
  while(time > 0){
    FSU_ChatBroadcast("The server will reload in "+ time)
    wait 1.0
    time = time - 1.0
  }
  ServerCommand("reload")
}

/**
 * Gets called when a player runs !ban
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Ban(entity player, array<string> args){
	if(args.len() < 1){
		FSU_PrivateChatMessage(player, "%EWrong format, !ban <player name>")
		return
	}

	entity toBan = FSA_GetPlayerEntityByName(args[0])

	if(toBan == null){
		FSU_PrivateChatMessage(player, "%EPlayer not found")
		return
	}

	if( FSA_IsOwner(toBan)|| FSA_IsAdmin(toBan) ){
		FSU_PrivateChatMessage(player, "%ECannot ban admins")
		return
	}

	ServerCommand("ban " + toBan.GetUID())
  	FSU_PrivateChatMessage(player, "%SSucessfully banned")
	return
}

/**
 * Gets called when a player runs !kick
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Kick(entity player, array<string> args){
	if( args.len()==0 ){
		FSU_PrivateChatMessage(player, "%EMissing argument")
		return
	}

	string toBan = ""
	foreach( entity p in GetPlayerArray() )
		if( p.GetPlayerName() == args[0] )
			toBan = p.GetPlayerName()

	if( toBan == "" ){
		//check for numbers in playerlist
		if( args[0] == "0" || ( args[0].tointeger() > 0 && args[0].tointeger() < GetPlayerArray().len()-1 ) ){
			entity p = FSA_GetPlayerEntityByName(args[0])
			if( p != null ){
				toBan = p.GetPlayerName()

			}
		}
		//2nd check if its still not found
		if(toBan == ""){
			FSU_PrivateChatMessage (player, "%EPlayer not found" )
			return
		}
	}

	ServerCommand( "kick " + toBan )
  	FSU_PrivateChatMessage( player, "%SSucessfully kicked" )
	return
}

/**
 * Gets called when a player runs !commandFor
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_CommandFor(entity player, array<string> args){
	if( args.len()<2 ){
		FSU_PrivateChatMessage(player, "%EMissing arguments !cmdFor <player name> <command> <command arguments>")
		return
	}

	//finds the player to execute the command on
	entity foundPlayer = FSA_GetPlayerEntityByName( args[0] )

	if( foundPlayer == null ){
		FSU_PrivateChatMessage( player, "%EPlayer not found" )
		return
	}
	//copied from the REAL code
	string command = args[1].tolower()
	args.remove(1)


	FSCC_CommandStruct commandInfo
	bool foundCommand = false
	table <string, FSCC_CommandStruct > commandsList = FSCC_GetCommandList()
	// Find command
	foreach( string c, FSCC_CommandStruct cm in commandsList ) {
		// Check command
		if( c == command ) {
			commandInfo = cm
			foundCommand = true
		}

		// Check abbreviations
		foreach( string a in cm.m_Abbreviations ) {
			if( ( GetConVarString( "FSCC_PREFIX" ) + a ) == command ) {
				commandInfo = cm
				foundCommand = true
			}
		}

		if( foundCommand )
			break
	}

	// Didnt find command
	if( !foundCommand ) {
		FSU_PrivateChatMessage( player, "%H\"" + command + "\"%E wasn't found!" )
	}
	// Did find command
	else {
		if( commandInfo.PlayerCanUse != null && !commandInfo.PlayerCanUse( foundPlayer ) ){
			FSU_PrivateChatMessage( player, "%H\"" + command + "\"%E wasn't found!" )
		} else {
			thread commandInfo.Callback( foundPlayer, args )
		}
	}

}



#else
void function FSA_Init() {
	print( "[FSA][ERRR] FSU and FSCC Need to be enabled for FSA to work!!!" )
}
#endif
