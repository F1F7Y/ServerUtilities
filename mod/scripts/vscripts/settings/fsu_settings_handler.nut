untyped
global function FSU_RegisterSettingsModule
global function FSU_SettingsAreLoaded

global function FSU_ReloadSettings

global function FSU_DoesSettingExistInTable
global function FSU_DoesSettingExist
global function FSU_GetSettingString
global function FSU_GetSettingArray


const string FSU_SETTINGS_FILE_NAME = "fsu_settings.json"


//-----------------------------------------------------------------------------
// This file contains the Settings module. The job of this
// module is to store the settings Json.
//-----------------------------------------------------------------------------


struct {
	bool bInitilazed = false
	bool bIsPlaceholder = false

	table tabSettings
} file


//-----------------------------------------------------------------------------
// Purpose: Settings handler init callback
//-----------------------------------------------------------------------------
string function FSU_RegisterSettingsModule() {
	FSU_Print( "Loading settings schema!" )
	FSU_LoadSettingsJSON()

	return "SettingsModule"
}

//-----------------------------------------------------------------------------
// Purpose: Tries to load settings schema from disk
//-----------------------------------------------------------------------------
void function FSU_LoadSettingsJSON() {
	file.bInitilazed = false

	if( NSDoesFileExist( FSU_SETTINGS_FILE_NAME ) ) {
		NSLoadJSONFile( FSU_SETTINGS_FILE_NAME, FSU_LoadSettingsSuccess_Callback, FSU_LoadSettingsFailure_Callback )
	} else {
		FSU_LoadSettingsFailure_Callback()
	}
}

//-----------------------------------------------------------------------------
// Purpose: Reloads settings. This is also the callback function
//          for the "fsu_reload_settings" ConCommand
// Input  : strArgs - An array of arguments
//-----------------------------------------------------------------------------
void function FSU_ReloadSettings( array<string> strArgs ) {
	// TODO [Fifty]: Check for a password here as anyone can call this
	FSU_Print( "Reloading settings schema" )
	FSU_LoadSettingsJSON()
}

//-----------------------------------------------------------------------------
// Purpose: Gets called after we succesfully loaded the settings schema
// Input  : json - The loaded Json file represented as a table
//-----------------------------------------------------------------------------
void function FSU_LoadSettingsSuccess_Callback( table json ) {
	file.tabSettings = json
	file.bIsPlaceholder = false
	file.bInitilazed = true
}

//-----------------------------------------------------------------------------
// Purpose: Loads the placeholder schema
//-----------------------------------------------------------------------------
void function FSU_LoadSettingsFailure_Callback() {
	file.tabSettings = DecodeJSON( g_strPlaceholderSchema )

	if( !("Version" in file.tabSettings) )
		FSU_Error( "Failed parsing JSON file!" )

	file.bIsPlaceholder = true
	file.bInitilazed = true
}

//-----------------------------------------------------------------------------
// Purpose: Returns whether settings are loaded, is false only before map load calback
//          and when loading settings
//-----------------------------------------------------------------------------
bool function FSU_SettingsAreLoaded() {
	return file.bInitilazed
}

//-----------------------------------------------------------------------------
// Purpose: Check whether a key exists in a table
// Input  : tabTable - The table to check against
//          strKey - The key to check for
//-----------------------------------------------------------------------------
bool function FSU_DoesSettingExistInTable( table tabTable, string strKey ) {
	return strKey in tabTable
}

//-----------------------------------------------------------------------------
// Purpose: Check whether a key exists in the root of the current loaded settings json
// Input  : strKey - The key to check for
//-----------------------------------------------------------------------------
bool function FSU_DoesSettingExist( string strKey ) {
	return strKey in file.tabSettings
}

//-----------------------------------------------------------------------------
// Purpose: Gets the string value of a key from the root of the current
//          loaded settings schema
// Input  : strKey - The key to get the value of
//-----------------------------------------------------------------------------
string function FSU_GetSettingString( string strKey ) {
	return string( file.tabSettings[strKey] )
}

//-----------------------------------------------------------------------------
// Purpose: Gets the array value of a key from the root of the current
//          loaded settings schema
// Input  : strKey - The key to get the array of
//-----------------------------------------------------------------------------
array function FSU_GetSettingArray( string strKey ) {
	return expect array( file.tabSettings[strKey] )
}