globalize_all_functions


void function FSU_SendMessageAsPlayer( entity entPlayer, string strMessage, bool bIsTeam ) {
    foreach( entity player in GetPlayerArray() ) {
        if( bIsTeam && entPlayer.GetTeam() != player.GetTeam() )
            continue

        string message
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