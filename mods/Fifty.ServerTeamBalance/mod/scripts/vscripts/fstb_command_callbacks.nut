globalize_all_functions


/**
 * Gets called when a player runs !switch
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSTM_CommandCallback_Switch( entity player, array< string > args ) {
	if( GetGameState() != eGameState.Playing ) {
		FSU_PrivateChatMessage( player, "%ECan't switch teams currently." )
		return
	}

	entity target
	if( FSA_IsAdmin( player ) && args.len() != 0 ) {
		foreach( entity p in GetPlayerArray() ){
			if( p.GetPlayerName() == args[0] ) // Maybe this should have .tolower()?? TF displays names in all-caps in many cases
				target = p
		}
		if(target == null){
			foreach( entity p in GetPlayerArray() ) {
				if( p.GetPlayerName().tolower().find( args[0].tolower() ) != null ) {
					if( target != null ) ){
						FSU_PrivateChatMessage(player, "%EMore than one matching player! %TWrite a bit more of their name.")
						return
					}
					target = p
				}
			}
		}
		if(target == null){
			FSU_PrivateChatMessage( player, "%H\"" + args[0] + "\"%E couldn't be found!" )
			return
		}
		else{
			FSU_PrivateChatMessage( player, "%SThe team of %H" + target.GetPlayerName() + "%S has been switched!" )
		}
	}
	else{
		target = player
	}

	if( !IsValid( target ) ) {
		FSU_PrivateChatMessage( player, "%EThat player entity isn't valid!" )
		return
	}

	if( IsAlive(target) )
		target.Die()

	SetTeam( target, GetOtherTeam( target.GetTeam() ) )
	FSU_PrivateChatMessage( target, "%SYour team has been switched!" )
}
