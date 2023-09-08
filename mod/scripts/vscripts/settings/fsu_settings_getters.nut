untyped
globalize_all_functions


//-----------------------------------------------------------------------------
// This file contains setting getter wrappers designed
// to return a predifined value when the desired entry
// couldnt be found.
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Purpose: Gets the command prefix.
//          Defaults to "!".
//-----------------------------------------------------------------------------
string function FSU_GetCommandPrefix() {
	if( !FSU_DoesSettingExist( "CommandPrefix" ) ) {
		FSU_Error( "\"CommandPrefix\" not found in settings table!" )
		return "!"
	}

	return FSU_GetSettingString( "CommandPrefix" )
}

//-----------------------------------------------------------------------------
// Purpose: Gets the player array.
//          Defaults to an empty array.
//-----------------------------------------------------------------------------
array function FSU_GetPlayerArray() {
	if( !FSU_DoesSettingExist( "Players" ) ) {
		FSU_Error( "\"Players\" not found in settings table!" )
		array empty
		return empty
	}

	return FSU_GetSettingArray( "Players" )
}

//-----------------------------------------------------------------------------
// Purpose: Gets the player tags array.
//          Defaults to an empty array.
//-----------------------------------------------------------------------------
array function FSU_GetPlayerTags( table tabPlayer ) {
	if( !FSU_DoesSettingExistInTable( tabPlayer, "Tags" ) ) {
		FSU_Error( "\"Tags\" not found in settings table!" )
		array empty
		return empty
	}

	return expect array( tabPlayer["Tags"] )
}