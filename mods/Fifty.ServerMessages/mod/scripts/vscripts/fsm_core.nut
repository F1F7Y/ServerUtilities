global function FSM_Init

#if FSU_ENABLED && FSCC_ENABLED
/**
 * Gets called after the map is loaded
*/
void function FSM_Init() {
	// Welcome message
	AddCallback_GameStateEnter( eGameState.Playing, FSM_PrintWelcomeMessage_All )
	AddCallback_GameStateEnter( eGameState.Prematch, FSM_PrintPrematchMessage )

	AddCallback_OnClientConnected ( FSM_OnClientConnected )

	FSCC_CommandStruct command
	command.m_UsageUser = "info"
	command.m_Description = "Display server information page."
	command.m_Group = "MESSAGE"
	command.Callback = FSV_CommandCallback_Info
	if( GetConVarBool( "FSM_ENABLE_INFO_COMMAND" ) )
		FSCC_RegisterCommand( "info", command )

	// Reaptedly broadcast messages
	if( GetConVarBool( "FSM_BROADCAST_ENABLE" ) )
		thread FSM_BroadcastMessages_Threaded()
	// Killers >:(
	AddCallback_OnNPCKilled( FSM_OnNPCKilled )
	AddCallback_OnPlayerKilled( FSM_OnPlayerKilled )
}

/**
 * Prints a message to global chat
*/
void function FSM_PrintPrematchMessage() {
	// Wait so the FSU message is sent first
	WaitFrame()

	thread FSM_PrintPrematchMessage_Threaded()
}

/**
 * Prints a message to global chat
*/
void function FSM_PrintPrematchMessage_Threaded() {
	wait 1
	if( GetConVarBool( "FSM_INFO_PRINT_ON_MATCH_START" ) ) {
		for( int i = 0; i < 5; i++ ) {
			string message = GetConVarString( "FSM_INFO_" + i )
			if( message.len() > 1 )
				foreach(string row in split(message, "\n"))
					FSU_ChatBroadcast( row )
		}
	}
}
void function FSV_CommandCallback_Info(entity player, array <string> args ) {
	for( int i = 0; i < 5; i++ ) {
		string message = GetConVarString( "FSM_INFO_" + i )
		if( message.len() > 1 )
			foreach(string row in split(message, "\n"))
				FSU_PrivateChatMessage(player, row )
	}
}

/**
 * Gets called when an npc is killed
*/
void function FSM_OnNPCKilled( entity npc, entity attacker, var damageInfo ) {
	if( GetConVarBool( "FSM_MARVIN_DEATH_NOTIFICATION" ) )
		if( attacker.IsPlayer() && npc.IsNPC() && npc.GetAIClass() == AIC_MARVIN )
			FSU_ChatBroadcast( "%H" + attacker.GetPlayerName() + "%N killed a marvin." )
}

/**
 * Gets called when a player is killed
*/
void function FSM_OnPlayerKilled( entity victim, entity attacker, var damageInfo ) {
	if( GetConVarBool( "FSM_PLAYER_FALL_DEATH_NOTIFICATION" ) ) {
		if( victim.IsPlayer() && DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.fall ) {
			if( GetMapName() == "mp_relic02" ) {
				FSU_ChatBroadcast( "%H" + victim.GetPlayerName() + "%N fell off the cliff." )
			} else if( GetMapName() == "mp_complex3" ) {
				FSU_ChatBroadcast( "%H" + victim.GetPlayerName() + "%N fell into the pit." )
			} else if( GetMapName() == "mp_crashsite3" ) {
				FSU_ChatBroadcast( "%H" + victim.GetPlayerName() + "%N disappeared in the cave." )
			} else {
				FSU_ChatBroadcast( "%H" + victim.GetPlayerName() + "%N fell into the pit." )
			}
		}

		if( victim.IsPlayer() && DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.outOfBounds ) {
			FSU_ChatBroadcast( "%H" + victim.GetPlayerName() + "%N tried to flee from battle." )
		}
	}

	if( GetConVarBool( "FSM_PLAYER_KILLSTREAK" ) ) {
		if( victim.IsPlayer() && attacker.IsPlayer() ) {
			FSM_UpdateKillstreakInformation( victim, attacker )
		}
	}
}

/**
 * Broadcasts messages every 150 seconds
*/
void function FSM_BroadcastMessages_Threaded() {
	array< string > messages

	for( int i = 0; i < 5; i++ ) {
		messages.append( GetConVarString( "FSM_BROADCAST_" + i ) )
	}


	int index = 0
	while(1) {
		wait 150
		if( GetConVarBool( "FSM_BROADCAST_RANDOM" ) )
			index = RandomInt(5)

		FSU_ChatBroadcast( messages[index] )

		index++
		if( index > 4 )
			index = 0
	}
}

/**
 * Gets called when a player joins
 * @param player the player who joined
*/
void function FSM_OnClientConnected( entity player ) {
	if( GetGameState() != eGameState.Playing )
		return

	FSM_PrintWelcomeMessage( player )
}

/**
 * Sends the welcome message to all players
*/
void function FSM_PrintWelcomeMessage_All() {
	foreach( entity player in GetPlayerArray() ) {
		FSM_PrintWelcomeMessage( player )
	}
}

/**
 * Creates the welcome message
 * @param player The player to send the message to
*/
void function FSM_PrintWelcomeMessage( entity player ) {
	if( GetConVarBool( "FSM_WELCOME_USE_RUI" ) ) {
		NSSendLargeMessageToPlayer( player, GetConVarString( "FSM_WELCOME_MESSAGE_TITLE" ), GetConVarString( "FSM_WELCOME_MESSAGE_TEXT" ), 20, GetConVarString( "FSM_WELCOME_MESSAGE_IMAGE" ) )
	} else {
		FSU_PrivateChatMessage( player, "%N" + GetConVarString( "FSM_WELCOME_MESSAGE_TITLE" ) )
		FSU_PrivateChatMessage( player, "%N" + GetConVarString( "FSM_WELCOME_MESSAGE_TEXT" ) )
	}
}
#else
void function FSM_Init() {
	print( "[FSM][ERRR] FSU and FSCC Need to be enabled for FSM to work!!!" )
}
#endif
