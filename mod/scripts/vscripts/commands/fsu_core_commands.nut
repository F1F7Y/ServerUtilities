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
	cmd.iUserLevel = 0
	cmd.strDefaultDescription = "Test"
	cmd.arrAbbreviations = []
	cmd.Callback = FSU_CommandCallback_Test
	FSU_RegisterCommand( "test", cmd )
}

/**
 * Test command callback
 * @param entity entPlayer The player calling this command
 * @param array<string> arrArgs An array of arguments the player passed
 */
void function FSU_CommandCallback_Test( entity entPlayer, array<string> arrArgs ) {
	FSU_SendSystemMessageToPlayer( entPlayer, "Test" )

	//FSU_Print(FSU_GetSettingValue("Version"))
}