globalize_all_functions

string function FSU_GetCommandPrefix() {
    if( !FSU_DoesSettingExist( "CommandPrefix" ) ) {
        FSU_Error( "\"CommandPrefix\" not found in settings table!" )
        return "!"
    }

    return FSU_GetSettingValue( "CommandPrefix" )
}