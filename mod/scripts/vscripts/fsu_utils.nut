untyped
globalize_all_functions

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

		// If a value is 255 its just white so we cap at 254
		red = int( min( 245, red ) )
		green = int( min( 245, green ) )
		blue = int( min( 245, blue ) )


		strFormatted = strFormatted.slice( 0, hexColorCode.begin ) + format( "\x1b[38;2;%i;%i;%im", red, green, blue )  + strFormatted.slice( hexColorCode.end, strFormatted.len() )

		hexColorCode = regexp("#[0-9A-Fa-f]{6}").search( strFormatted )
	}

	return strFormatted
}

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