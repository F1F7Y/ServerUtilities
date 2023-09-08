global function FSU_RegisterCoreCommandsModule


/**
 * This file contains the Core commands module. This module
 * implements all core commands.
 */


/**
 * Core commands init callback
 */
string function FSU_RegisterCoreCommandsModule() {
	FSU_AddCallback_ChatCommandRegister( FSU_OnRegisteringCommands )
	return "CoreCommandsModule"
}

/**
 * Gets called when we're registering commands. Registers all
 * core commands.
 */
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

/**
 * Test command callback
 * @param entity entPlayer The player calling this command
 * @param array<string> arrArgs An array of arguments the player passed
 */
string function FSU_CommandCallback_Test( entity entPlayer, array<string> arrArgs ) {
	FSU_SendSystemMessageToPlayer( entPlayer, arrArgs[0] )
	return "test"

	//FSU_Print(FSU_GetSettingString("Version"))
}