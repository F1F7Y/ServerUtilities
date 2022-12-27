global function FSV_Localization_Init

global function FSV_Localize
global function FSV_UnLocalize
global function FSV_LocalizeArray


table< string, string > localizationStrings


/**
 * Gets called after the map is loaded
*/
void function FSV_Localization_Init() {
	localizationStrings["mp_angel_city"]               <- "Angel City"
	localizationStrings["mp_black_water_canal"]        <- "Black Water Canal"
	localizationStrings["mp_grave"]                    <- "Boomtown"
	localizationStrings["mp_colony02"]                 <- "Colony"
	localizationStrings["mp_complex3"]                 <- "Complex"
	localizationStrings["mp_crashsite3"]               <- "Crashsite"
	localizationStrings["mp_drydock"]                  <- "DryDock"
	localizationStrings["mp_eden"]                     <- "Eden"
	localizationStrings["mp_thaw"]                     <- "Exoplanet"
	localizationStrings["mp_forwardbase_kodai"]        <- "Forward Base Kodai"
	localizationStrings["mp_glitch"]                   <- "Glitch"
	localizationStrings["mp_homestead"]                <- "Homestead"
	localizationStrings["mp_relic02"]                  <- "Relic"
	localizationStrings["mp_rise"]                     <- "Rise"
	localizationStrings["mp_wargames"]                 <- "Wargames"
	localizationStrings["mp_lobby"]                    <- "Lobby"
	localizationStrings["mp_lf_deck"]                  <- "Deck"
	localizationStrings["mp_lf_meadow"]                <- "Meadow"
	localizationStrings["mp_lf_stacks"]                <- "Stacks"
	localizationStrings["mp_lf_township"]              <- "Township"
	localizationStrings["mp_lf_traffic"]               <- "Traffic"
	localizationStrings["mp_lf_uma"]                   <- "UMA"
	localizationStrings["mp_coliseum"]                 <- "The Coliseum"
	localizationStrings["mp_coliseum_column"]          <- "Pillars"
	localizationStrings["mp_box"]                      <- "Box"
	localizationStrings["mp_frostbite"]                <- "Frostbite"
}

/**
 * Localizes the map name
 * @param str The string to localize
*/
string function FSV_Localize( string str ) {
	if( str in localizationStrings )
		return localizationStrings[str]

	return str
}

/**
 * UnLocalizes the map name
 * @param str The string to unlocalize
*/
string function FSV_UnLocalize( string str ) {
	string unLocalizedString
	foreach( string key, string value in localizationStrings ) {
		if( value == str )
			unLocalizedString = key
	}

	return unLocalizedString
}

/**
 * Localizes an array of map names
 * @param list The string array to localize
*/
array< string > function FSV_LocalizeArray( array< string > list ) {
	array< string > localizedStrings
	foreach( string str in list )
		localizedStrings.append( FSV_Localize( str ) )

	return localizedStrings
}
