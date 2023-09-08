untyped
globalize_all_functions


//-----------------------------------------------------------------------------
// This file contains chat utility functions.
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Purpose: Sends a message as a player effectively impersonating them. Unlike
//          the northstar implementation this also adds tags before their name
// Input  : entPlayer - The player to impersonate
//          strMessage - The message to send
//          bIsTeam - Wheter to use team chat
//-----------------------------------------------------------------------------
void function FSU_SendMessageAsPlayer( entity entPlayer, string strMessage, bool bIsTeam ) {
	array<string> arrTags

	foreach( string svUID, FSUPlayer_t Player in FSU_GetSettings().tbPlayers ) {

		if( svUID != entPlayer.GetUID() )
			continue

		foreach( FSUPlayerTag_t Tag in Player.arTags ) {
			arrTags.append( format( "%s[%s]", FSU_GetANSICodeFromRGB( Tag.iRed, Tag.iGreen, Tag.iBlue ), Tag.svName ) )
		}
	}

	foreach( entity player in GetPlayerArray() ) {
		if( bIsTeam && entPlayer.GetTeam() != player.GetTeam() )
			continue

		string message

		foreach( string strTag in arrTags )
			message += strTag

		message += ( entPlayer.GetTeam() == player.GetTeam() ? "%F" : "%E" ) + entPlayer.GetPlayerName() + ( bIsTeam ? "(Team)" : "" ) + "%0: "
		message = FSU_FormatString( message )
		message += strMessage

		NSBroadcastMessage( -1, player.GetPlayerIndex(), message , true, false, 1 )
	}
}

//-----------------------------------------------------------------------------
// Purpose: Sends a system message to a player.
// Input  : entPlayer - The player to send the message to
//          strMessage - The message to send them
//-----------------------------------------------------------------------------
void function FSU_SendSystemMessageToPlayer( entity entPlayer, string strMessage ) {
	string color

	foreach( string svTheme, FSUTheme_t Theme  in FSU_GetSettings().tbThemes ) {
		if( svTheme == "ChatSystemPrefix" ) {
			color = FSU_GetANSICodeFromRGB( Theme.iRed, Theme.iGreen, Theme.iBlue )
			break
		}
	}

	string prefix = FSU_GetSettings().svChatPrefix

	string message = FSU_FormatString( color + prefix + "%0 " ) + strMessage
	NSBroadcastMessage( -1, entPlayer.GetPlayerIndex(), message , true, false, 1 )
}

//-----------------------------------------------------------------------------
// Purpose: Broadcasts a message to all players
// Input  : strMessage - The mesage to broadcast
//-----------------------------------------------------------------------------
void function FSU_BroadcastSystemMessage( string strMessage ) {
	foreach( entity player in GetPlayerArray() )
		FSU_SendSystemMessageToPlayer( player, strMessage )
}

//-----------------------------------------------------------------------------
// Purpose: Returns the command prefix
//-----------------------------------------------------------------------------
string function FSU_GetCommandPrefix() {
	return FSU_GetSettings().svCommandPrefix
}