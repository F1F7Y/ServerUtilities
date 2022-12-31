globalize_all_functions

string header      = "\x1b[38:5:214m"
string highlight   = "\x1b[36m"
string text        = "\x1b[38:5:152m"
string adminHeader = "\x1b[94m"

const FSU_LIST_ROWS = 5

/**
 * Gets called after the map is loaded
*/
void function FSU_Init() {
	AddCallback_GameStateEnter( eGameState.Prematch, FSU_PrintPrematchMessage )
}

/**
 * Prints a message to global chat to inform players which features they can use
 * based on which FSU modules are enabled. Also prints which modules are enabled
 * to console
*/
void function FSU_PrintPrematchMessage() {
	FSU_Print( "Checking enabled modules!" )
	FSU_ChatBroadcast( "Fifty.ServerUtilities is active!" )

#if FSCC_ENABLED
	FSU_Print( "FSCC is enabled!")
	FSU_ChatBroadcast( "Do you want to know which mods are installed on this server? Do you want to contact the owner? Use %H%Phelp%T to list avalible commands!" )
#endif
#if FSA_ENABLED
	FSU_Print( "FSA is enabled!")
#endif
#if FSM_ENABLED
	FSU_Print( "FSM is enabled!")
#endif
#if FSTB_ENABLED
	FSU_Print( "FSTB is enabled!")
#endif
#if FSV_ENABLED
	FSU_Print( "FSV is enabled!")
#endif

	FSU_Print( "Finished! Thanks for using FSU :)" )
}

/**
 * Sets the ANSI codes used for formatting
 * @param headerCode The ANSI code to be used for the message header ( "[FSU]" )
 * @param highlightCode The ANSI code to be used for highlighted text
 * @param textCode The ANSI code to be used for normal text
 * @param adminHeaderCode The ANSI code to be used for the admin header ( "[ADMIN]" )
*/
void function FSU_SetTheme( string headerCode, string highlightCode, string textCode, string adminHeaderCode ) {
	header = headerCode
	highlight = highlightCode
	text = textCode
	adminHeader = adminHeaderCode
}

/**
 * Prints a message to the console and prepends "[FSU][ERRR]" to it
 * @param mesage The message to be printed to console
*/
void function FSU_Error( string message ) {
	print( "[FSU][ERRR]" + message + "\n" )
}

/**
 * Prints a message to the console and prepends "[FSU][WARN]" to it
 * @param mesage The message to be printed to console
*/
void function FSU_Warning( string message ) {
	print( "[FSU][WARN]" + message + "\n" )
}

/**
 * Prints a message to the console and prepends "[FSU][INFO]" to it
 * @param mesage The message to be printed to console
*/
void function FSU_Print( string message ) {
	print( "[FSU][INFO]" + message + "\n" )
}

/**
 * Sends a colored message to global chat and prepends it with [FSU]
 * @param mesage The message to be sent to global chat
 * @param usePopUp Whether we should use serverside rui instead of chat
*/
void function FSU_ChatBroadcast( string message, bool usePopUp = false ) {
	if( usePopUp ) {
		foreach( entity player in GetPlayerArray() )
			NSSendPopUpMessageToPlayer( player, message )
	} else {
		Chat_ServerBroadcast( FSU_FormatString( "%F[FSU]%T " + message ), false )
	}
}

/**
 * Sends a colored message to player in chat and prepends it with [FSU]
 * @param player The player to send the message to
 * @param mesage The message to be sent to player
*/
void function FSU_PrivateChatMessage( entity player, string message ) {
	Chat_ServerPrivateMessage( player, FSU_FormatString( "%F[FSU]%T " + message ), false, false )
}

/**
 * Returns the maximum number of pages for FSU_PrintFormattedList
 * @param list The list to be printed
 * @param columns The nubre of columns per row
*/
int function FSU_GetListPages( array< string > list, int columns = 1 ) {
	return int( ceil( list.len() / ( columns * 5.0 ) ) )
}

/**
 * Prints a part of an array in pages
 * @param player The player to send the list to
 * @param list The list to be printed
 * @param page The page to display
 * @param columns The nubre of columns per row
 * @param separator The list item separator
*/
void function FSU_PrintFormattedList( entity player, array< string > list, int page, int columns = 1, string separator = ", " ) {
	for( int r = ( page - 1 ) * FSU_LIST_ROWS * columns; r < page * FSU_LIST_ROWS * columns; r += columns ) {
		string row = "  "
		for( int c = 0; c < columns; c++ ) {
			if( r + c >= list.len() )
				break

			row += FSU_Highlight( list[r + c] )

			if( r + c < list.len() - 1 )
				row += separator
		}
		if( row != "  ")
			FSU_PrivateChatMessage( player, row )

	}
}

/**
 * Returns a formatted string convar
 * @param str The string to format
*/
string function FSU_FormatString( string str ) {
	string formatted = str

	int begin, end
	var index
	bool skipNext = false
	while( true ) {
		index = formatted.find( "%" )
		if( index == null )
			break

		int _index = expect int( index )

		string code = formatted.slice( _index, _index + 2 )
		switch( code ) {
			case "%H":
				code = highlight
				break
			case "%F":
				code = header
				break
			case "%T":
				code = text
				break
			case "%A":
				code = adminHeader
				break
			case "%0":
				code = "\x1b[0m"
				break
#if FSCC_ENABLED
			case "%P":
				code = GetConVarString( "FSCC_PREFIX" )
				break
#endif
		}

		formatted = formatted.slice( 0, _index ) + code + formatted.slice( _index + 2, formatted.len() )
	}

	return formatted
}

/**
 * Returns a formatted string convar
 * @param convar The convar to format
*/
string function FSU_GetFormattedConVar( string convar ) {
	string formatted = FSU_FormatString( GetConVarString( convar ) )
	return formatted
}

/**
 * Highlights a string using ANSI code and returns the highlited string
 * @param mesage The string to be highlited
*/
string function FSU_Highlight( string message ) {
	return highlight + message + text
}

/**
 * Returns an ANSI code resetting formatting
*/
string function FSU_FmtEnd() {
	return "\x1b[0m"
}

/**
 * Returns an ANSI code coloring the text
*/
string function FSU_FmtBegin() {
	return text
}

/**
 * Returns an ANSI code coloring the adminHeader
*/
string function FSU_FmtAdmin() {
	return adminHeader
}
