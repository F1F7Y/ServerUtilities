#if FSU_ENABLED && FSCC_ENABLED
global function FSM_UpdateKillstreakInformation


table< entity, int > killstreak

array< int > killstreakAchivements = [ 100, 50, 40, 30, 20, 15, 10 ]

/**
 * Updates the player killstreak information
 * @param victim The player killed who was killed
 * @param attacker The player who killed the victim
*/
void function FSM_UpdateKillstreakInformation( entity victim, entity attacker ) {
	if( attacker in killstreak ) {
		killstreak[attacker]++

		foreach( achivement in killstreakAchivements ) {
			if( killstreak[attacker] == achivement ) {
				bool usePopUp = GetConVarBool( "FSM_USE_RUI_POPUP_FOR_KILLSTREAK" )
				string message
				if( usePopUp )
					message = attacker.GetPlayerName() + " is on a " + string( achivement ) + " kill streak!"
				else
					message = FSU_Highlight( attacker.GetPlayerName() ) + " is on a " + FSU_Highlight( string( achivement ) ) + " kill streak!"
				
				FSU_ChatBroadcast( message, usePopUp )
				break
			}
		}
	} else {
		killstreak[attacker] <- 1
	}

	if( victim in killstreak ) {
		if( killstreak[victim] > 10 ) {
			bool usePopUp = GetConVarBool( "FSM_USE_RUI_POPUP_FOR_KILLSTREAK" )
			string message
			if( usePopUp )
				message = attacker.GetPlayerName() + " ended " + victim.GetPlayerName() + "s " + string( killstreak[victim] ) + " kill streak!"
			else
				message = FSU_Highlight( attacker.GetPlayerName() ) + " ended " + FSU_Highlight( victim.GetPlayerName() ) + "s " + FSU_Highlight( string( killstreak[victim] ) ) + " kill streak!"
			
			FSU_ChatBroadcast( message, usePopUp )
		}
		killstreak[victim] = 0
	}
}
#endif
