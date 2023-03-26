untyped
globalize_all_functions

string function FSU_GetCommandPrefix() {
    if( !FSU_DoesSettingExist( "CommandPrefix" ) ) {
        FSU_Error( "\"CommandPrefix\" not found in settings table!" )
        return "!"
    }

    return FSU_GetSettingValue( "CommandPrefix" )
}

array function FSU_GetPlayersArray() {
    if( !FSU_DoesSettingExist( "Players" ) ) {
        FSU_Error( "\"Players\" not found in settings table!" )
        array empty
        return empty
    }

    return FSU_GetSettingArray( "Players" )
}

array function FSU_GetPlayerTags( table tabPlayer ) {
    if( !FSU_DoesSettingExistInTable( tabPlayer, "Tags" ) ) {
        FSU_Error( "\"Tags\" not found in settings table!" )
        array empty
        return empty
    }

    return expect array( tabPlayer["Tags"] )
}