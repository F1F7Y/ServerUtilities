untyped
globalize_all_functions


void function FSU_SendMessageAsPlayer( entity entPlayer, string strMessage, bool bIsTeam ) {
	array<string> arrTags

	foreach( var varPlayer in FSU_GetPlayersArray() ) {
		table tabPlayer = expect table( varPlayer )

		if( tabPlayer["UID"] != entPlayer.GetUID() )
			continue

		foreach( var varTag in FSU_GetPlayerTags( tabPlayer ) ) {
			table tabTag = expect table( varTag )

			if( !FSU_DoesSettingExistInTable( tabTag, "Name" ) ) {
				FSU_Error( "Invalid tag entry for player", entPlayer.GetUID(), "!!!" )
				continue
			}

			arrTags.append( string( tabTag["Name"] ) )
		}
	}

	foreach( entity player in GetPlayerArray() ) {
		if( bIsTeam && entPlayer.GetTeam() != player.GetTeam() )
			continue

		string message

		foreach( string strTag in arrTags )
			message += format( "[%s]", strTag )

		message += ( entPlayer.GetTeam() == player.GetTeam() ? "%F" : "%E" ) + entPlayer.GetPlayerName() + ( bIsTeam ? "(Team)" : "" ) + "%0: "
		message += strMessage
		message = FSU_FormatString( message )

		NSBroadcastMessage( -1, player.GetPlayerIndex(), message , true, false, 1 )
	}
}

void function FSU_SendSystemMessageToPlayer( entity entPlayer, string strMessage ) {
	string message
	message += "[FSU] "
	message += strMessage
	NSBroadcastMessage( -1, entPlayer.GetPlayerIndex(), message , true, false, 1 )
}