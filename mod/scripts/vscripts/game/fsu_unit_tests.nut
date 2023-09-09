global function FSU_RegisterUnitTestsGameModule


//-----------------------------------------------------------------------------
// This file contains the Core commands module. This module
// implements all core commands.
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Purpose: Core commands init callback
//-----------------------------------------------------------------------------
string function FSU_RegisterUnitTestsGameModule() {
	FSU_AddCallback_ChatCommandRegister( FSU_OnRegisteringCommands )
	return "UnitTestsgameModule"
}

//-----------------------------------------------------------------------------
// Purpose: Gets called when we're registering commands. Registers all
//          core commands.
//-----------------------------------------------------------------------------
void function FSU_OnRegisteringCommands() {
	FSU_CommandStruct cmd
	cmd.iUserLevel = eFSUPlayerLevel.DEFAULT
	cmd.arrDescriptions[eFSUPlayerLevel.DEFAULT] = "Test desc"
	cmd.arrAbbreviations = [ "te", "TA" ]
	cmd.Callback = FSU_CommandCallback_Test
	//cmd.args = 1
	//cmd.argsUsage = "<test arg>"
	FSU_RegisterCommand( "test", cmd )
}

//-----------------------------------------------------------------------------
// Purpose: Test command callback
// Input  : entPlayer - The player calling this command
//          arrArgs - An array of arguments the player passed
//-----------------------------------------------------------------------------
string function FSU_CommandCallback_Test( entity entPlayer, array<string> arrArgs ) {
	FSU_SendSystemMessageToPlayer( entPlayer, "Test" )
	return "test"
}