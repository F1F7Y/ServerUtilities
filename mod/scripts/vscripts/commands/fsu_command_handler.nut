global function FSU_AddCallback_ChatCommandRegister
global function FSU_ReloadRegisteredCommands
global function FSU_RegisterCommand

global function FSU_CheckMessageForCommand


//-----------------------------------------------------------------------------
// This file handles the registering, storage and
// calling of chat commands
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Stores information about the command
//-----------------------------------------------------------------------------
global struct FSU_CommandStruct {
	// Minimum level for a user to be able to use / see the command
	int iUserLevel = eFSUPlayerLevel.DEFAULT
	// Command descripiton
	// Each array index corresponds to a eFSUPlayerLevel
	// If a description is empty for a level we use the next one under us
	string[eFSUPlayerLevel.LENGTH] arrDescriptions
	// Command abbreviations
	array<string> arrAbbreviations
	// Callback function
	string functionref( entity, array <string> ) Callback
}

struct {
	bool bCanRegisterCommands = false

	array<void functionref()> arrCallbacks
	table<string, FSU_CommandStruct> tabCommands
	table<string, FSU_CommandStruct> abrCommands
} file


//-----------------------------------------------------------------------------
// Purpose: Adds a callback function for registering commands.
// Input  : callback  - The function to add to our command registering callback array
//-----------------------------------------------------------------------------
void function FSU_AddCallback_ChatCommandRegister( void functionref() callback ) {
	file.arrCallbacks.append( callback )
}

//-----------------------------------------------------------------------------
// Purpose: Calls command register callbacks.
//-----------------------------------------------------------------------------
void function FSU_ReloadRegisteredCommands() {
	file.bCanRegisterCommands = true

	foreach( void functionref() callback in file.arrCallbacks )
		callback()

	file.bCanRegisterCommands = false
}

//-----------------------------------------------------------------------------
// Purpose: Registers a command. Can only be called inside the command
//          registering callback.
// Input  : name - The command name
//          cmd - The command struct ascosiated(?) with the command name
//-----------------------------------------------------------------------------
void function FSU_RegisterCommand( string name, FSU_CommandStruct cmd ) {
	if( !file.bCanRegisterCommands ) {
		FSU_Error( "Tried to register command outside of command register callback!" )
		return
	}

	if( name in file.tabCommands )
		FSU_Print( "Overwriting command: \"" + name + "\"" )

	file.tabCommands[name] <- cmd //since the <- operator just overrides an existing key we dont need to check if it already exists

	//to avoid having a double for loop when finding a command (it looks clearner)
	foreach( string abr in cmd.arrAbbreviations )
		file.abrCommands[abr] <- cmd
}

//-----------------------------------------------------------------------------
// Purpose: Check a message for a command, returns true if it found a command.
// Input: entPlayer - The player who sent the message
//        strMessgae - The message to check
//-----------------------------------------------------------------------------
bool function FSU_CheckMessageForCommand( entity entPlayer, string strMessage ) {
	bool bIsCommand = strMessage.find( FSU_GetCommandPrefix() ) == 0

	// Early out if we're not a command
	if( !bIsCommand )
		return bIsCommand

	// Extract arguments
	array<string> arrArgs = split( strMessage, " " )
	string strCommand = arrArgs.remove(0).tolower().slice( FSU_GetCommandPrefix().len() )

	// Try to find the command
	FSU_CommandStruct command

	if( strCommand in file.tabCommands )
		command = file.tabCommands[strCommand]
	if( strCommand in file.abrCommands)
		command = file.abrCommands[strCommand]

	if( command.Callback != null )
		FSU_SendSystemMessageToPlayer( entPlayer, command.Callback( entPlayer, arrArgs ) )
	else
		FSU_SendSystemMessageToPlayer( entPlayer, format( "Command: \"%s\" not found!", strCommand ) )

	return bIsCommand
}