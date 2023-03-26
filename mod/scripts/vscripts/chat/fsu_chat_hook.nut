global function FSU_RegisterChatHookModule


/**
 * This file contains the Chat hook module. We block all messages
 * by players and resend them checking for commands and adding
 * custom formatting. This may break other mods, but due to FSU
 * being the largest server utilities mod and there being no other
 * way of adding tags before the players name I think this is a 
 * trade-off we can make.
 */


/**
 * Chat hook init callback
 */
string function FSU_RegisterChatHookModule() {
	AddCallback_OnReceivedSayTextMessage( FSU_ChatHook )

	return "ChatHookModule"
}

/**
 * Chat hook callback
 * @param message The message for this callback
 */
ClServer_MessageStruct function FSU_ChatHook( ClServer_MessageStruct message ) {

	bool bBlock = !FSU_CheckMessageForCommand( message.player, message.message )

	if( !bBlock )
		FSU_SendMessageAsPlayer( message.player, message.message, message.isTeam )

	// Block the message
	message.shouldBlock = true
	message.message = ""

	return message
}