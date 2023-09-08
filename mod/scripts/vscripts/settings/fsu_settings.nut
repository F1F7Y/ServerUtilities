untyped
global function FSU_GetSettings

global function FSU_LoadSettings
global function FSU_SettingsAreLoaded

global function FSU_ReloadSettings


//-----------------------------------------------------------------------------
// Global settings
//-----------------------------------------------------------------------------


const string FSU_SETTINGS_FILE_NAME = "fsu_settings.json"


struct
{
	FSUSettings_t Settings
	bool bLoaded = false
} file

//-----------------------------------------------------------------------------
// Purpose: Returns the global settings struct
//-----------------------------------------------------------------------------
FSUSettings_t function FSU_GetSettings()
{
	return file.Settings
}

//-----------------------------------------------------------------------------
// Purpose: Returns whether settings are loaded, is false only before map load calback
//          and when loading settings
//-----------------------------------------------------------------------------
bool function FSU_SettingsAreLoaded() {
	return file.bLoaded
}

//-----------------------------------------------------------------------------
// Purpose: Tries to load settings schema from disk
//-----------------------------------------------------------------------------
void function FSU_LoadSettings() {
	file.bLoaded = false

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
	FSU_LoadSettings()
}

//-----------------------------------------------------------------------------
// Purpose: Gets called after we succesfully loaded the settings schema
// Input  : json - The loaded Json file represented as a table
//-----------------------------------------------------------------------------
void function FSU_LoadSettingsSuccess_Callback( table json ) {
	FSU_ParseSettingsJSON(json)
	file.bLoaded = true
}

//-----------------------------------------------------------------------------
// Purpose: Loads the placeholder schema
//-----------------------------------------------------------------------------
void function FSU_LoadSettingsFailure_Callback() {
	table json = DecodeJSON( g_strPlaceholderSchema )
	FSU_ParseSettingsJSON(json)
	file.bLoaded = true
}

//-----------------------------------------------------------------------------
// Purpose: Parse json
// Input  : json -
//-----------------------------------------------------------------------------
void function FSU_ParseSettingsJSON( table json ) {
	FSU_Debug("Parsing JSON!")

	if( "Version" in json && typeof(json["Version"]) == "int" )
		file.Settings.iVersion = expect int( json["Version"] )

	if( "ChatSystemPrefix" in json && typeof(json["ChatSystemPrefix"]) == "string" )
		file.Settings.svChatPrefix = expect string( json["ChatSystemPrefix"] )

	if( "CommandPrefix" in json && typeof(json["CommandPrefix"]) == "string" )
		file.Settings.svCommandPrefix = expect string( json["CommandPrefix"] )

	if( "Themes" in json && typeof(json["Themes"]) == "array" ) {
		foreach(var vTheme in expect array(json["Themes"])) {
			if(typeof(vTheme) != "table"){
				FSU_Error("Skipping malformed theme: vTheme isnt a table")
				continue
			}

			string svType
			if("Type" in vTheme && typeof(vTheme["Type"]) == "string") {
				svType = expect string( vTheme["Type"] )
			}else{
				FSU_Error("Skipping malformed theme: vTheme missing 'Type' or 'Type' isnt string")
				continue
			}

			FSUTheme_t Theme

			if( "Red" in vTheme && typeof(vTheme["Red"]) == "int" )
				Theme.iRed = expect int( vTheme["Red"] )

			if( "Green" in vTheme && typeof(vTheme["Green"]) == "int" )
				Theme.iGreen = expect int( vTheme["Green"] )

			if( "Blue" in vTheme && typeof(vTheme["Blue"]) == "int" )
				Theme.iBlue = expect int( vTheme["Blue"] )

			file.Settings.tbThemes[svType] <- Theme
		}
	}

	if( "Players" in json && typeof(json["Players"]) == "array") {
		foreach( var vPlayer in expect array(json["Players"])) {
			if(typeof(vPlayer) != "table"){
				FSU_Error("Skipping malformed player: vPlayer isnt a table")
				continue
			}

			string svUID
			if("UID" in vPlayer && typeof(vPlayer["UID"]) == "string") {
				svUID = expect string( vPlayer["UID"] )
			}else{
				FSU_Error("Skipping malformed player: vPlayer missing 'UID' or 'UID' isnt string")
				continue
			}

			FSUPlayer_t Player

			if("AccessLevel" in vPlayer && typeof(vPlayer["AccessLevel"]) == "int")
				Player.iAccessLevel = expect int( vPlayer["AccessLevel"] )

			array<FSUPlayerTag_t> arTags
			if( "Tags" in vPlayer && typeof(vPlayer["Tags"]) == "array") {
				foreach(var vTag in vPlayer["Tags"]){
					FSUPlayerTag_t Tag

					if("Name" in vTag && typeof(vTag["Name"]) == "string") {
						Tag.svName = expect string( vTag["Name"] )
					}else{
						FSU_Error("Skipping malformed player tag: vTag missing 'Name' or 'Name' isnt string")
						continue
					}

					if( "Red" in vTag && typeof(vTag["Red"]) == "int" )
						Tag.iRed = expect int( vTag["Red"] )

					if( "Green" in vTag && typeof(vTag["Green"]) == "int" )
						Tag.iGreen = expect int( vTag["Green"] )

					if( "Blue" in vTag && typeof(vTag["Blue"]) == "int" )
						Tag.iBlue = expect int( vTag["Blue"] )

					Player.arTags.append(Tag)
				}
			}

			file.Settings.tbPlayers[svUID] <- Player
		}
	}
}