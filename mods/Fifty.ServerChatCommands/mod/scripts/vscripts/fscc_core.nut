global function FSCC_Init

#if FSU_ENABLED
global function FSCC_RegisterCommand
global function FSCC_GetCommands
global function FSCC_GetCommandAttributes
global function FSCC_GetCommandList
// Stores information about a command
// Note: The prefix "!" is used in examples, but can be changed using the FSCC_PREFIX convar
global struct FSCC_CommandStruct {
	// Description of what the command does
	string m_Description
	string m_UsageUser  // Normal players usage
	string m_UsageAdmin // Admin usage, If this is empty m_UsageUser will be used as default
	// Group in which the command falls
	string m_Group
	// Abbreviations of the command ( e.g. the command "!help" could also be invoked with "!h" )
	array< string > m_Abbreviations
	// Callback gets called when a player runs the command
	// @param entity The player who called the command
	// @param array< string > A list of arguments passed ( e.g. running "!whisper bobthebob hi :)" would give [ "bobthebob", "hi", ":)" ] )
	void functionref( entity, array < string > ) Callback
	// Gets called when printing a list of commands using "!help" and when getting called by a player
	// to check if the player calling can use and see the command
	// @param entity The player which is checked
	bool functionref( entity ) PlayerCanUse
}

// Stores a list of registered commands
table< string, FSCC_CommandStruct > commandsList


/**
 * Gets called after the map is loaded
*/
void function FSCC_Init() {
	AddCallback_OnReceivedSayTextMessage( FSCC_CheckForCommand )

	// Register base commands
	// !help
	FSCC_CommandStruct command
	command.m_UsageUser = "help <page/command>"
	command.m_UsageAdmin = ""
	command.m_Description = "Lists available commands."
	command.m_Group = "CORE"
	command.m_Abbreviations = [ "h" ]
	command.Callback = FSCC_CommandCallback_Help
	FSCC_RegisterCommand( "help", command )

	// !mods
	command.m_UsageUser = "mods <page>"
	command.m_Description = "Lists mods installed on the server."
	command.m_Abbreviations = []
	command.Callback = FSCC_CommandCallback_Mods
	FSCC_RegisterCommand( "mods", command )

	// !name
	command.m_UsageUser = "name"
	command.m_Description = "Returns the server name."
	command.Callback = FSCC_CommandCallback_Name
	FSCC_RegisterCommand( "name", command )

	// !owner
	command.m_UsageUser = "owner"
	command.m_Description = "Returns contact information of the owner."
	command.Callback = FSCC_CommandCallback_Owner
	FSCC_RegisterCommand( "owner", command )

	// !rules
	command.m_UsageUser = "rules <page>"
	command.m_Description = "Lists server rules."
	command.Callback = FSCC_CommandCallback_Rules
	FSCC_RegisterCommand( "rules", command )

	// !discord
	command.m_UsageUser = "discord"
	command.m_Description = "Returns a discord link."
	command.Callback = FSCC_CommandCallback_Discord
	FSCC_RegisterCommand( "discord", command )
}

/**
 * Gets called when a player sends a chat message and checks it for a command
 * @param message The message struct containing information about the chat message
*/
ClServer_MessageStruct function FSCC_CheckForCommand( ClServer_MessageStruct message ) {
	if( message.message.find( GetConVarString( "FSCC_PREFIX" ) ) != 0 )
		return message

	// Split the message into arguments and get the command
	array< string > args = split( message.message, " " )
	string command = args[0].tolower()
	args.remove(0)

	FSCC_CommandStruct commandInfo
	bool foundCommand = false
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
		FSU_PrivateChatMessage( message.player, "%H\"" + command + "\"%E wasn't found!" )
	}
	// Did find command
	else {
		if( commandInfo.PlayerCanUse != null && !commandInfo.PlayerCanUse( message.player ) ){
			FSU_PrivateChatMessage( message.player, "%H\"" + command + "\"%E wasn't found!" )
		} else {
			thread commandInfo.Callback( message.player, args )
		}
	}



	if( GetConVarBool( "FSCC_MODE_HIDE_MESSAGES_GLOBAL" ) )
		message.shouldBlock = true

	if( GetConVarBool( "FSCC_MODE_SECURE") )
		message.message = ""

	return message
}


/**
 * Registers a chat command
 * @param mesage The message to be printed to console
*/
void function FSCC_RegisterCommand( string name, FSCC_CommandStruct command ) {
	commandsList[ GetConVarString( "FSCC_PREFIX" ) + name.tolower() ] <- clone command
	FSU_Print( "Registered command: " + name.tolower() )
}

/**
 * Return a string array of registered commands
 * @param player The player to check for command rights
*/
array< string > function FSCC_GetCommands( entity player ) {
	array< string > commands
	foreach( string c, FSCC_CommandStruct cm in commandsList ) {
		if( cm.PlayerCanUse == null || ( cm.PlayerCanUse != null && cm.PlayerCanUse( player ) ) ) {
			commands.append( c )
		}
	}

	return commands
}

/**
 * Returns the command struct containing information about the command
 * @param command The command to get the info for
*/
FSCC_CommandStruct function FSCC_GetCommandAttributes( string command ) {
	return commandsList[command]
}
/**
 * Retuns the commandList table
*/
table <string, FSCC_CommandStruct > function FSCC_GetCommandList() {
	return commandsList
}

#else
void function FSCC_Init() {
	print( "[FSCC][ERRR] FSU and FSCC Need to be enabled for FSCC to work!!!" )
}
#endif
