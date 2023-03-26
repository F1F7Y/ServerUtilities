untyped
global function FSU_RegisterSettingsModule
global function FSU_SettingsAreLoaded

global function FSU_ReloadSettings

global function FSU_DoesSettingExistInTable
global function FSU_DoesSettingExist
global function FSU_GetSettingValue
global function FSU_GetSettingArray

global function FSU_GetSettingsTable

const string FSU_SETTINGS_FILE_NAME = "fsu_settings.json"

struct {
    bool bInitilazed = false
    bool bIsPlaceholder = false

    table tabSettings
} file

/**
 * Settings handler init callback
 */
string function FSU_RegisterSettingsModule() {
    FSU_Print( "Loading settings schema!" )
    FSU_LoadSettingsJSON()

    return "SettingsModule"
}

/**
 * Tries to load settings schema from disk
 */
void function FSU_LoadSettingsJSON() {
    file.bInitilazed = false

    if( NSDoesFileExist( FSU_SETTINGS_FILE_NAME ) ) {
        NSLoadJSONFile( FSU_SETTINGS_FILE_NAME, FSU_LoadSettingsSuccess_Callback, FSU_LoadSettingsFailure_Callback )
    } else {
        FSU_LoadSettingsFailure_Callback()
    }
}

/**
 *
 */
void function FSU_ReloadSettings( array<string> strArgs ) {
    // TODO: Check for a password here as anyone can call this
    FSU_Print( "Reloading settings schema" )
    FSU_LoadSettingsJSON()
}

/**
 * Gets called after we succesfully loaded the settings schema
 */
void function FSU_LoadSettingsSuccess_Callback( table json ) {
    file.tabSettings = json
    file.bIsPlaceholder = false
    file.bInitilazed = true
}

/**
 * Loads the placeholder schema
 */
void function FSU_LoadSettingsFailure_Callback() {
    file.tabSettings = DecodeJSON( g_strPlaceholderSchema )

    if( !("Version" in file.tabSettings) )
        FSU_Error( "Failed parsing JSON file!" )

    file.bIsPlaceholder = true
    file.bInitilazed = true
}

/**
 * Returns whether settings are loaded, is false only before map load calback
 * and when loading settings
 */
bool function FSU_SettingsAreLoaded() {
    return file.bInitilazed
}

bool function FSU_DoesSettingExistInTable( table tabTable, string strKey ) {
    return strKey in tabTable
}

bool function FSU_DoesSettingExist( string strKey ) {
    return strKey in file.tabSettings
}

string function FSU_GetSettingValue( string strKey ) {
    return string( file.tabSettings[strKey] )
}

array function FSU_GetSettingArray( string strKey ) {
    return expect array( file.tabSettings[strKey] )
}

table function FSU_GetSettingsTable() {
    return file.tabSettings
}