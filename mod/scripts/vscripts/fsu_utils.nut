untyped
globalize_all_functions

//-----------------------------------------------------------------------------
// Purpose: Formats a string. Currently supports hex color codes ( #RRGGBB ) and
//          custom presets ( %x )
// Input  : strUnformatted - The string to format
//-----------------------------------------------------------------------------
string function FSU_FormatString( string strUnformatted ) {
	string strFormatted = strUnformatted

	strFormatted = StringReplace( strFormatted, "%E", "\x1b[112m", true, false ) // Enemy
	strFormatted = StringReplace( strFormatted, "%F", "\x1b[111m", true, false ) // Friend
	strFormatted = StringReplace( strFormatted, "%0", "\x1b[0m", true, false )   // Reset

	// Hex code
	var hexColorCode = regexp("#[0-9A-Fa-f]{6}").search( strFormatted )
	while( hexColorCode != null ) {
		// "rrggbb" in 0-9 A-F
		string strColor = strFormatted.slice( hexColorCode.begin + 1, hexColorCode.end )
		int red = FSU_GetIntegerFromHexString( strColor.slice(0, 2) )
		int green = FSU_GetIntegerFromHexString( strColor.slice(2, 4) )
		int blue = FSU_GetIntegerFromHexString( strColor.slice(4, 6) )

		strFormatted = strFormatted.slice( 0, hexColorCode.begin ) + FSU_GetANSICodeFromRGB( red, green, blue )  + strFormatted.slice( hexColorCode.end, strFormatted.len() )

		hexColorCode = regexp("#[0-9A-Fa-f]{6}").search( strFormatted )
	}

	return strFormatted
}

//-----------------------------------------------------------------------------
// Purpose: Converts a base-16 string to an integer.
// Input  : strHex - The Hexadecimal number to be converted
//-----------------------------------------------------------------------------
int function FSU_GetIntegerFromHexString( string strHex ) {
	int iNumber

	for( int i = 0; i < strHex.len(); i++ ) {
		string char = strHex.toupper().slice( i, i + 1 )
		int weight = int( pow( 16, strHex.len() - i - 1 ) )

		if( char == "F" || char == "f" )
			iNumber += weight * 15
		else if( char == "E" || char == "e" )
			iNumber += weight * 14
		else if( char == "D" || char == "d" )
			iNumber += weight * 13
		else if( char == "C" || char == "c" )
			iNumber += weight * 12
		else if( char == "B" || char == "b" )
			iNumber += weight * 11
		else if( char == "A" || char == "a" )
			iNumber += weight * 10
		else
			iNumber += weight * char.tointeger()

	}

	return iNumber
}

//-----------------------------------------------------------------------------
// Purpose: Creates an ansi escape code using the passed colors.
// Input  : iRed - Red element ( 0 - 255 )
//          iGreen - Green element ( 0 - 255 )
//          iBlue - Blue element ( 0 - 255 )
//-----------------------------------------------------------------------------
string function FSU_GetANSICodeFromRGB( int iRed, int iGreen, int iBlue ) {
	// If a value is 255 its just white so we cap at 254
	int red = int( min( 245, iRed ) )
	int green = int( min( 245, iGreen ) )
	int blue = int( min( 245, iBlue ) )

	return format( "\x1b[38;2;%i;%i;%im", red, green, blue )
}

//-----------------------------------------------------------------------------
// Purpose: Gets an array of players based on whether they have a wildcard in
//          their name
// Input  : svWildCard -
//-----------------------------------------------------------------------------
array<entity> function FSU_GetPlayersByWildCard(string svWildCard) {
	array<entity> ret
	foreach(entity p in GetPlayerArray())
		if(p.GetPlayerName().tolower().find(svWildCard.tolower()) != null)
			ret.append(p)

	return ret
}

//-----------------------------------------------------------------------------
// Purpose: Gets the player entity by its name
// Input  : name - The name of the player we want
//-----------------------------------------------------------------------------
entity function FSU_GetPlayerEntityByName(string name){
	if(name == "")
		return null

	foreach(entity p in GetPlayerArray())
		if(p.GetPlayerName().tolower() == name.tolower())
			return p

	return null
}

//-----------------------------------------------------------------------------
// Purpose: Gets the player entity by its index
// Input  : iIdx - The index of the player we want
//-----------------------------------------------------------------------------
entity function FSU_GetPlayerEntityByIndex(int iIdx){
	array<entity> arPlayers = GetPlayerArray()

	if(iIdx < 0 || iIdx > GetPlayerArray().len() - 1)
		return null

	return arPlayers[iIdx]
}

//-----------------------------------------------------------------------------
// Purpose: Converts an array of strings to a string
// Input  : args -
//          separator -
//-----------------------------------------------------------------------------
string function FSU_ArrayToString( array< string > args, string separator = " " ) {
	string result = ""

	foreach( string s in args )
		if ( result == "" )
			result = s
		else
			result += ( separator + s )

	return result
}