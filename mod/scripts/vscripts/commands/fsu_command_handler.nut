global function FSU_AddCallback_ChatCommandRegister
global function FSU_ReloadRegisteredCommands
global function FSU_RegisterCommand

global function FSU_CheckMessageForCommand


global struct FSU_CommandStruct {
	// Minimum level for a user to be able to use / see the command
	// 0 - Default
	// x - Admin
	int iUserLevel
	//
	string strDefaultDescription
	//
	string strAdminDescription
	//
	array<string> arrAbbreviations
	//
	void functionref( entity, array <string> ) Callback
}



struct {
	bool bCanRegisterCommands = false

	array<void functionref()> arrCallbacks
	table<string, FSU_CommandStruct> tabCommands
} file

/**
 * Adds a callback function for registering commands
 */
void function FSU_AddCallback_ChatCommandRegister( void functionref() callback ) {
	file.arrCallbacks.append( callback )
}

/**
 * Calls command register callbacks
 */
void function FSU_ReloadRegisteredCommands() {
	file.bCanRegisterCommands = true

	foreach( void functionref() callback in file.arrCallbacks )
		callback()

	file.bCanRegisterCommands = false
}

void function FSU_RegisterCommand( string name, FSU_CommandStruct cmd ) {
	if( !file.bCanRegisterCommands ) {
		FSU_Error( "Tried to register command outside of command register callback!" )
		return
	}

	if( name in file.tabCommands ) {
		file.tabCommands[name] = cmd
		FSU_Print( "Overwriting command: \"" + name + "\"" )
	} else {
		file.tabCommands[name] <- cmd
	}
}

bool function FSU_CheckMessageForCommand( entity entPlayer, string strMessage ) {
	bool bIsCommand = strMessage.find( FSU_GetCommandPrefix() ) != 0

	array<string> arrArgs = split( strMessage, " " )
	string strCommand = arrArgs[0].tolower().slice( FSU_GetCommandPrefix().len(), arrArgs[0].len() )
	arrArgs.remove(0)

	FSU_CommandStruct command
	foreach( string name, FSU_CommandStruct cmd in file.tabCommands ) {
		if( name == strCommand ) {
			command = cmd
			break
		}
	}

	if(command.Callback != null)
		command.Callback(entPlayer, arrArgs)

	return bIsCommand
}