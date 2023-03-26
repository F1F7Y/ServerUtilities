global function FSU_RegisterChatHookModule


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