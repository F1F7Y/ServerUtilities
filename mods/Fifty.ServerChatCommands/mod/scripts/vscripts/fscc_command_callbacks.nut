globalize_all_functions

#if FSU_ENABLED
/**
 * Gets called when a player runs !help
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Help( entity player, array< string > args ) {
	array< string > commands = FSCC_GetCommands( player )

	// Print the usage of a command
	if( args.len() != 0 ) {
		int index = 0
		foreach( string cmd in commands ) {
			if ( cmd.find( args[0].tolower() ) )
				break

			index++
		}
		if( index != commands.len() ) {
			FSCC_CommandStruct cmdInfo = FSCC_GetCommandAttributes( commands[index] )
			if( cmdInfo.m_UsageAdmin != "" && FSA_IsAdmin( player ) )
				FSU_PrivateChatMessage( player, "%H%P" + cmdInfo.m_UsageAdmin )
			else
				FSU_PrivateChatMessage( player, "%H%P" + cmdInfo.m_UsageUser )

			FSU_PrivateChatMessage( player, "%T" + cmdInfo.m_Description )

			string abbreviations
			foreach( _index, string abv in cmdInfo.m_Abbreviations ) {
				abbreviations += abv
				if( _index != cmdInfo.m_Abbreviations.len() - 1 )
					abbreviations += ", "
			}
			if( cmdInfo.m_Abbreviations.len() != 0 )
				FSU_PrivateChatMessage( player, "%HAbbreviations:%T " + abbreviations )

			return
		}
	}

	if (args.len() != 0 && args[0] == "all"){
		FSU_PrivateChatMessage( player, "List of ALL available commands:" )
		FSU_PrintFormattedListWithoutPagination(player, commands)
		FSU_PrivateChatMessage( player, "To find out more about a command, use %H!help <command>%T." )
		return
	}

	// Print a page of commands
	int pages = FSU_GetListPages( commands )

	int page
	if( args.len() == 0 ) {
		page = 1
	} else {
		page = args[0].tointeger()
	}

	if( page > pages ) {
		FSU_PrivateChatMessage( player, "%EMaximum number of pages is: %H" + string( pages ) )
		return
	}

	if( page < 1 )
		page = 1

	FSU_PrivateChatMessage( player, "List of available commands:" )
	FSU_PrintFormattedList( player, commands, page)
	if(pages > 1)
		FSU_PrivateChatMessage( player, "Page: %H[" + page + "/" + pages + "]" )
	FSU_PrivateChatMessage( player, "To find out more about a command, use %H!help <command>%T." )
}

/**
 * Gets called when a player runs !mods
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Mods( entity player, array< string > args ) {
	array< string > mods = NSGetModNames()

	if (args.len() != 0 && args[0] == "all"){
		FSU_PrivateChatMessage( player, "List of ALL mods installed on this server:" )
		FSU_PrintFormattedListWithoutPagination(player, mods)
		return
	}

	int pages = FSU_GetListPages( mods )

	int page
	if( args.len() == 0 ) {
		page = 1
	} else {
		page = args[0].tointeger()
	}

	if( page < 1 )
		page = 1

	if( page > pages ) {
		FSU_PrivateChatMessage( player, "%EMaximum number of pages is: %H" + string( pages ) )
		return
	}

	FSU_PrivateChatMessage( player, "List of mods installed on this server:" )
	FSU_PrintFormattedList( player, mods, page)
	if(pages > 1)
		FSU_PrivateChatMessage( player, "Page: %H[" + page + "/" + pages + "]" )
}

/**
 * Gets called when a player runs !name
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Name( entity player, array< string > args ) {
	FSU_PrivateChatMessage( player, "Name: %H\"" + GetConVarString( "ns_server_name" ) + "\"")
}

/**
 * Gets called when a player runs !owner
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Owner( entity player, array< string > args ) {
	FSU_PrivateChatMessage( player,  "Owner: %H\"" + GetConVarString( "FSCC_OWNER" ) + "\"")
}

/**
 * Gets called when a player runs !rules
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Rules( entity player, array< string > args ) {
	array< string > rules = split( GetConVarString( "FSCC_RULES" ), "," )

	if (args.len() != 0 && args[0] == "all"){
		FSU_PrivateChatMessage( player, "List of ALL rules:" )
		FSU_PrintFormattedListWithoutPagination(player, rules)
		return
	}

	int pages = FSU_GetListPages( rules )

	int page
	if( args.len() == 0 ) {
		page = 1
	} else {
		page = args[0].tointeger()
	}

	if( page < 1 )
		page = 1

	if( page > pages ) {
		FSU_PrivateChatMessage( player, "%EMaximum number of pages is: %H" + string( pages ) )
		return
	}

	FSU_PrivateChatMessage( player, "List of rules:" )
	FSU_PrintFormattedList( player, rules, page )
	if(pages > 1)
		FSU_PrivateChatMessage( player, "Page: %H[" + page + "/" + pages + "]" )
}

/**
 * Gets called when a player runs !discord
 * @param player The player who caled the command
 * @param args The arguments passed by the player
*/
void function FSCC_CommandCallback_Discord( entity player, array< string > args ) {
	FSU_PrivateChatMessage( player, "Discord: %H\"" + GetConVarString( "FSCC_DISCORD" ) + "\"")
}
#endif
