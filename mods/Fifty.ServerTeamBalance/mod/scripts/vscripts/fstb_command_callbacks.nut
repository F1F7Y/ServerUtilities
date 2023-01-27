globalize_all_functions


/**
 * Gets called when a player runs !switch
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSTM_CommandCallback_Switch( entity player, array< string > args ) {
	if( GetGameState() != eGameState.Playing ) {
		FSU_PrivateChatMessage( player, "Can't switch teams currently." )
		return
	}

	entity target = player

	if( FSA_IsAdmin( player ) && args.len() != 0 ) {
		bool foundTarget = false
		foreach( entity p in GetPlayerArray() ) {
			if( p.GetPlayerName().tolower().find( args[0].tolower() ) != -1 ) {
				target = p
				foundTarget = true
				break
			}
		}

		if( !foundTarget ) {
			FSU_PrivateChatMessage( player, "%H\"" + args[0] + "\"%T couldn't be found!" )
			return
		}
	}

	if( !IsValid( target ) ) {
		FSU_PrivateChatMessage( player, "Player entity isn't valid!" )
		return
	}

	if( IsAlive( player ) )
		player.Die()

	SetTeam( target, GetOtherTeam( target.GetTeam() ) )
	FSU_PrivateChatMessage( player, "Your team has been switched!" )
}
