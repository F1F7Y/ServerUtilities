untyped
globalize_all_functions

string header      = "\x1b[38:5:214m"
string highlight   = "\x1b[36m"
string text        = "\x1b[38:5:152m"
string adminHeader = "\x1b[94m"
string ownerHeader = "\x1b[92m"
string error       = "\x1b[38;5;203m"
string success     = "\x1b[38;5;192m"
string announce    = "\x1b[38;5;189m"

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
	//FSU_ChatBroadcast( "Fifty.ServerUtilities is active!" )

#if FSCC_ENABLED
	FSU_Print( "FSCC is enabled!")
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
 * @param ownerHeaderCode The ANSI code to be used for the owner prefix ( "[OWNER]" )
*/
void function FSU_SetTheme( string headerCode, string highlightCode, string textCode, string adminHeaderCode, string ownerHeaderCode, string errorCode, string successCode, string announceCode ) {
	header = headerCode
	highlight = highlightCode
	text = textCode
	adminHeader = adminHeaderCode
	ownerHeader = ownerHeaderCode
	error = errorCode
	success = successCode
	announce = announceCode
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
		if( GetConVarBool( "FSU_PREFIX_SYSTEM_MESSAGES" ) )
			Chat_ServerBroadcast( FSU_FormatString( "%F[FSU]%N " + message ), false )
		else
			Chat_ServerBroadcast( FSU_FormatString( "%N" + message ), false )
	}
}

/**
 * Sends a colored message to player in chat and prepends it with [FSU]
 * @param player The player to send the message to
 * @param mesage The message to be sent to player
*/
void function FSU_PrivateChatMessage( entity player, string message ) {
	if( GetConVarBool( "FSU_PREFIX_SYSTEM_MESSAGES" ) )
		Chat_ServerPrivateMessage( player, FSU_FormatString( "%F[FSU]%T " + message ), false, false )
	else
		Chat_ServerPrivateMessage( player, FSU_FormatString( "%T" + message ), false, false )
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
 * Returns the given array as a sting
 * @param args Array of stings that will be
 * @param separator optional argument of string that will separate all words
*/
string function FSU_ArrayToString( array< string > args, string separator = " " ) {
	string result = ""
	foreach( string s in args )
		result += ( s + separator )
	return result
}

/**
 * Returns a formatted string convar
 * @param str The string to format
*/
string function FSU_FormatString( string str ) {
	string formatted = str

	formatted = StringReplace( formatted, "%H", highlight, true, false )
	formatted = StringReplace( formatted, "%F", header, true, false )
	formatted = StringReplace( formatted, "%T", text, true, false )
	formatted = StringReplace( formatted, "%A", adminHeader, true, false )
	formatted = StringReplace( formatted, "%O", ownerHeader, true, false )
	formatted = StringReplace( formatted, "%E", error, true, false )
	formatted = StringReplace( formatted, "%S", success, true, false )
	formatted = StringReplace( formatted, "%N", announce, true, false )
	formatted = StringReplace( formatted, "%0", "\x1b[0m", true, false )
#if FSCC_ENABLED
	formatted = StringReplace( formatted, "%P", GetConVarString( "FSCC_PREFIX" ), true, false )
#endif

	// Hex code
	var hexColorCode = regexp("#[0-9A-F]{6}").search( formatted )
	while( hexColorCode != null ) {
		// "rrggbb" in 0-9 A-F
		string strColor = formatted.slice( hexColorCode.begin + 1, hexColorCode.end )
		int red = FSU_GetIntegerFromHexString( strColor.slice(0, 2) )
		int green = FSU_GetIntegerFromHexString( strColor.slice(2, 4) )
		int blue = FSU_GetIntegerFromHexString( strColor.slice(4, 6) )

		// If a value is 255 its just white so we cap at 254
		red = int( min( 245, red ) )
		green = int( min( 245, green ) )
		blue = int( min( 245, blue ) )


		formatted = formatted.slice( 0, hexColorCode.begin ) + format( "\x1b[38;2;%i;%i;%im", red, green, blue )  + formatted.slice( hexColorCode.end, formatted.len() )

		hexColorCode = regexp("#[0-9A-F]{6}").search( formatted )
	}

	return formatted
}

/**
 * Returns integer from hex string
 * @param hex The hex string to convert
*/
int function FSU_GetIntegerFromHexString( string hex ) {
	int number

	for( int i = 0; i < hex.len(); i++ ) {
		string char = hex.slice( i, i + 1 )
		int weight = int( pow( 16, hex.len() - i - 1 ) )

		if( char == "F" )
			number += weight * 15
		else if( char == "E" )
			number += weight * 14
		else if( char == "D" )
			number += weight * 13
		else if( char == "C" )
			number += weight * 12
		else if( char == "B" )
			number += weight * 11
		else if( char == "A" )
			number += weight * 10
		else
			number += weight * char.tointeger()

	}

	return number
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

/**
 * Saves a string array into a convar, as "," is used as the divider it should NEVER be present in the items of the array
 * @param convar Which convar
 * @param input The array that is to be saved
*/
void function FSU_SaveArrayToConVar(string convar, array <string> input){
	if(GetConVarString(convar) == "0")
		return

	string newContent = split(GetConVarString(convar), ",")[0]
	foreach(string item in input){
		newContent += "," + item
	}
	SetConVarString(convar, newContent)
}

/**
 * Saves an array of string arrays into a convar, as "," and "-" are used as the dividers, they should NEVER be present in the items of the array
 * @param convar Which convar
 * @param input An array of the arrays to be saved
*/
void function FSU_SaveArrayArrayToConVar(string convar, array <array <string> > input){
	if(GetConVarString(convar) == "0")
		return

	array <string> newArray

	for(int arrayArrayIndex = 0; arrayArrayIndex < input.len(); arrayArrayIndex++){
		string newContent = ""
		for(int arrayIndex = 0; arrayIndex < input[arrayArrayIndex].len(); arrayIndex++){
			if(newContent == ""){
				newContent = input[arrayArrayIndex][arrayIndex]
			}
			else{
				newContent += "-" + input[arrayArrayIndex][arrayIndex]
			}
		}
		newArray.append(newContent)
	}
	FSU_SaveArrayToConVar(convar, newArray)
}

/**
 * Returns just the setting value of a convar if it is also used to store data
 * @param convar Which convar
*/
int function FSU_GetSettingIntFromConVar(string convar){
	return split(GetConVarString(convar), ",")[0].tointeger()
}

/**
 * Returns an array that has been stored in a convar using FSU_SaveArrayToConVar
 * @param convar Which convar
*/
array <string> function FSU_GetArrayFromConVar(string convar){
	array <string> convarArray = split(GetConVarString(convar), ",")
	convarArray.remove(0)
	return convarArray
}

/**
 * Returns the selected array from a convar that is storing more than one
 * @param convar Which convar
 * @param whichArray Which array to pull, provide an index number
*/
array <string> function FSU_GetSelectedArrayFromConVar(string convar, int whichArray){
	if(FSU_GetArrayFromConVar(convar).len() != 0)
		return split(FSU_GetArrayFromConVar(convar)[whichArray], "-")
	return FSU_GetArrayFromConVar(convar)
}
