global function FSU_RegisterUnitTestsGameModule


//-----------------------------------------------------------------------------
// This file contains the Core commands module. This module
// implements all core commands.
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Purpose: Core commands init callback
//-----------------------------------------------------------------------------
string function FSU_RegisterUnitTestsGameModule() {
	if( GetConVarBool("FSU_DEBUG") ) {
		FSU_AddCallback_ChatCommandRegister( FSU_OnRegisteringCommands )
	}
	return "UnitTestsgameModule"
}

//-----------------------------------------------------------------------------
// Purpose: Gets called when we're registering commands. Registers all
//          core commands.
//-----------------------------------------------------------------------------
void function FSU_OnRegisteringCommands() {
	FSUCommand_t Test
	Test.iUserLevel = eFSUPlayerLevel.DEFAULT
	Test.arDescriptions[eFSUPlayerLevel.DEFAULT] = "Test desc"
	Test.arAbbreviations = [ "te", "TA" ]
	Test.fnCallback = FSU_CommandCallback_Test
	//cmd.args = 1
	//cmd.argsUsage = "<test arg>"
	FSU_RegisterCommand( "test", Test )

	FSUCommand_t Dump
	Test.iUserLevel = eFSUPlayerLevel.DEFAULT
	Dump.arDescriptions[eFSUPlayerLevel.DEFAULT] = "Dumps all registered commands"
	Dump.arAbbreviations = []
	Dump.fnCallback = FSU_CommandCallback_Dump
	FSU_RegisterCommand( "dump", Dump )
}

//-----------------------------------------------------------------------------
// Purpose: Test command callback
// Input  : entPlayer - The player calling this command
//          Args - An array of arguments the player passed
//-----------------------------------------------------------------------------
string function FSU_CommandCallback_Test( entity entPlayer, array<string> Args ) {
	FSU_SendSystemMessageToPlayer( entPlayer, format("%s ran test command using: '%s'", entPlayer.GetPlayerName(), Args[0]) )
	return ""
}

//-----------------------------------------------------------------------------
// Purpose: Test command callback
// Input  : entPlayer - The player calling this command
//          Args - An array of arguments the player passed
//-----------------------------------------------------------------------------
string function FSU_CommandCallback_Dump( entity entPlayer, array<string> Args ) {
	FSU_DumpRegisteredCommands_Debug()
	return ""
}