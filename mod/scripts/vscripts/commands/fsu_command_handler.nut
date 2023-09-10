global function FSU_AddCallback_ChatCommandRegister
global function FSU_ReloadRegisteredCommands
global function FSU_RegisterCommand

global function FSU_CheckMessageForCommand

global function FSU_DumpRegisteredCommands_Debug

//-----------------------------------------------------------------------------
// This file handles the registering, storage and
// calling of chat commands
//-----------------------------------------------------------------------------


struct {
	bool bCanRegisterCommands = false

	// Command register callbacks
	array<void functionref()> arCallbacks

	// Chat command callbacks
	table<string, FSUCommand_t> tbCommands
	table<string, FSUCommand_t> tbAbbreviations
} file


//-----------------------------------------------------------------------------
// Purpose: Adds a callback function for registering commands.
// Input  : callback  - The function to add to our command registering callback array
//-----------------------------------------------------------------------------
void function FSU_AddCallback_ChatCommandRegister( void functionref() callback ) {
	file.arCallbacks.append( callback )
}

//-----------------------------------------------------------------------------
// Purpose: Calls command register callbacks.
//-----------------------------------------------------------------------------
void function FSU_ReloadRegisteredCommands() {
	file.bCanRegisterCommands = true

	foreach( void functionref() callback in file.arCallbacks )
		callback()

	file.bCanRegisterCommands = false
}

//-----------------------------------------------------------------------------
// Purpose: Registers a command. Can only be called inside the command
//          registering callback.
// Input  : name - The command name
//          cmd - The command struct ascosiated(?) with the command name
//-----------------------------------------------------------------------------
void function FSU_RegisterCommand( string name, FSUCommand_t cmd ) {
	if( !file.bCanRegisterCommands ) {
		FSU_Error( "Tried to register command outside of command register callback!" )
		return
	}

	string svCmd = name.tolower()

	if( svCmd in file.tbCommands )
		FSU_Warning( "Overwriting command: \"" + svCmd + "\"" )

	file.tbCommands[svCmd] <- cmd

	foreach( string abr in cmd.arAbbreviations ) {
		if( abr in file.tbAbbreviations )
			FSU_Warning( "Overwriting abbreviation: \"" + abr + "\"" )

		file.tbAbbreviations[abr.tolower()] <- cmd
	}
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
	array<string> arArgs = split( strMessage, " " )
	arArgs[0] = arArgs[0].slice( FSU_GetCommandPrefix().len() )

	string svCmd = arArgs[0].tolower()

	FSU_Debug( "Player:", entPlayer.GetPlayerName(), "tried to run command:", svCmd )

	// Try to find the command
	FSUCommand_t command

	if( svCmd in file.tbCommands )
		command = file.tbCommands[svCmd]
	if( svCmd in file.tbAbbreviations)
		command = file.tbAbbreviations[svCmd]

	if( command.fnCallback != null ) {
		string svResponse = command.fnCallback( entPlayer, arArgs )

		if(svResponse.len())
			FSU_SendSystemMessageToPlayer( entPlayer, svResponse )
	} else {
		FSU_SendSystemMessageToPlayer( entPlayer, format( "Command: \"%s\" not found!", svCmd ) )
	}

	return bIsCommand
}

//-----------------------------------------------------------------------------
// Purpose: dumps all registered commands
//-----------------------------------------------------------------------------
void function FSU_DumpRegisteredCommands_Debug() {
	if(!GetConVarBool("FSU_DEBUG"))
		return

	foreach( string svCmd, FSUCommand_t cmd in file.tbCommands)
		FSU_Debug("- ", svCmd, "(Command)")

	foreach( string svAbr, FSUCommand_t cmd in file.tbAbbreviations)
		FSU_Debug("- ", svAbr, "(Abbreviation)")
}