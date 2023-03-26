global function FSU_RegisterCoreCommandsModule

/**
 * Core commands init callback
 */
string function FSU_RegisterCoreCommandsModule() {
    FSU_AddCallback_ChatCommandRegister( FSU_OnRegisteringCommands )
    return "CoreCommandsModule"
}

/**
 *
 */
void function FSU_OnRegisteringCommands() {
    FSU_CommandStruct cmd
    cmd.iUserLevel = 0
    cmd.strDefaultDescription = "Test"
    cmd.arrAbbreviations = []
    cmd.Callback = FSU_CommandCallback_Test
    FSU_RegisterCommand( "test", cmd )
}

void function FSU_CommandCallback_Test( entity entPlayer, array<string> arrArgs ) {
    FSU_SendSystemMessageToPlayer( entPlayer, "Test" )

    //FSU_Print(FSU_GetSettingValue("Version"))
}