untyped
globalize_all_functions

table <string, string> colorTable
string header
string highlight
string text
string adminHeader
string ownerHeader
string error
string success
string announce

/**
 * Gets called after the map is loaded
*/
void function FSU_Init() {
	colorTable["header"]    <- "\x1b[38:5:214m"
	colorTable["highlight"] <- "\x1b[36m"
	colorTable["text"]      <- "\x1b[38:5:152m"
	colorTable["admin"]     <- "\x1b[94m"
	colorTable["owner"]     <- "\x1b[92m"
	colorTable["error"]     <- "\x1b[38;5;203m"
	colorTable["success"]   <- "\x1b[38;5;192m"
	colorTable["announce"]  <- "\x1b[38;5;183m"

	foreach(string item in split(GetConVarString( "FSU_COLOR_THEME" ), "," )){
		colorTable[split(item, "=")[0]] = split(item, "=")[1]
	}

	header      = colorTable["header"]
	highlight   = colorTable["highlight"]
	text        = colorTable["text"]
	adminHeader = colorTable["admin"]
	ownerHeader = colorTable["owner"]
	error       = colorTable["error"]
	success     = colorTable["success"]
	announce    = colorTable["announce"]

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
 * @param separator The list item separator, inconsquential as long as charachter count is the same
*/
int function FSU_GetListPages( array< string > list, int rows = 5, string separator = "%T, " ) {
	string row = ""
	array <string> rowList
	foreach(string item in list){
		if( row == ""){
			row = "    " + "  " + item
		}
		else if( (row+separator+"  "+item).len() > 85 || FSU_FormatString(row+separator+"  "+item).len() > 200 ){
			rowList.append(row)
			row = "    " + "  " + item
		}
		else{
			row += separator + "  " + item
		}
	}
	if( row != "")
		rowList.append(row)

	return int( ceil( rowList.len() / float( rows ) ) )
}

/**
 * Prints a part of an array in pages
 * @param player The player to send the list to
 * @param list The list to be printed
 * @param page The page to display
 * @param separator The list item separator
 * @param rows The number of rows to print per page
 * @param color The color of list items
*/
void function FSU_PrintFormattedList( entity player, array< string > list, int page, string separator = "%T, ", int rows = 5, string color = "%H" ) {
	string row = ""
	array <string> rowList
	foreach(string item in list){
		if( row == ""){
			row = "    " + color + item
		}
		else if( (row+separator+color+item).len() > 85 || FSU_FormatString(row+separator+color+item).len() > 200 ){
			rowList.append(row)
			row = "    " + color + item
		}
		else{
			row += separator + color + item
		}
	}
	if( row != "")
		rowList.append(row)

	for(int rowToPrint = (page * rows) - rows ; rowToPrint < page * rows; rowToPrint++ )
		if(rowToPrint < rowList.len() )
			FSU_PrivateChatMessage( player, rowList[rowToPrint] )
}

/**
 * Prints a full list without pagination, as densely as possible
 * @param player The player to send the list to
 * @param list The list to be printed
 * @param separator The list item separator
 * @param color The color of list items
*/
void function FSU_PrintFormattedListWithoutPagination( entity player, array< string > list, string separator = "%T, ", string color = "%H" ) {
	string row = ""
	foreach(string item in list){
		if( row == ""){
			row = "    " + color + item
		}
		else if( (row+separator+color+item).len() > 85 || FSU_FormatString(row+separator+color+item).len() > 200 ){
			FSU_PrivateChatMessage( player, row )
			row = "    " + color + item
		}
		else{
			row += separator + color + item
		}
	}
	if( row != "")
		FSU_PrivateChatMessage( player, row )
}

/**
 * Returns the given array as a sting
 * @param args Array of stings that will be
 * @param separator optional argument of string that will separate all words
*/
string function FSU_ArrayToString( array< string > args, string separator = " " ) {
	string result = ""
	foreach( string s in args )
		if ( result == "" )
			result = s
		else
			result += ( separator + s )
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
	var hexColorCode = regexp("#[0-9A-Fa-f]{6}").search( formatted )
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

		hexColorCode = regexp("#[0-9A-Fa-f]{6}").search( formatted )
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
		string char = hex.toupper().slice( i, i + 1 )
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
