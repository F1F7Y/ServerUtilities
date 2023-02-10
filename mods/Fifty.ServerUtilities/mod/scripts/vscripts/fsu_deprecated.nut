globalize_all_functions


/**
 * A deprecated FSU < v2 function used to register commands
*/
void function FSU_RegisterCommand ( string name, string usage, string group, void functionref( entity, array < string > ) callbackFunc, array < string > abbreviations = [], bool functionref( entity ) visibilityFunc = null ) {
	FSU_Warning( "A mod is using deprecated function!" )

	FSCC_CommandStruct command
	command.m_Description = usage
	command.m_Group = group
	command.Callback = callbackFunc
	command.m_Abbreviations = abbreviations
	command.PlayerCanUse = visibilityFunc

	FSCC_RegisterCommand( name, command )
}

/**
 * A deprecated FSU < v2 function used to check if a poll can be created
*/
bool function FSU_CanCreatePoll () {
	FSU_Warning( "A mod is using deprecated function!" )
	return false
}

/**
 * A deprecated FSU < v2 function used to create a poll
*/
void function FSU_CreatePoll ( array < string > options, string before, float duration, bool show_result ) {
	FSU_Warning( "A mod is using deprecated function!" )
}

/**
 * A deprecated FSU < v2 function used to get a poll result
*/
int function FSU_GetPollResultIndex () {
	FSU_Warning( "A mod is using deprecated function!" )
	return -1
}

