globalize_all_functions

/**
 * Prints a message into console
 * @param ... A list of variables to be printed
 */
void function FSU_Print( ... ) {
	if ( vargc <= 0 )
		return

	var msg = "[FSU][INFO]"
	for ( int i = 0; i < vargc; i++ )
		msg += " " + vargv[i]

	print( msg )
}

/**
 * Prints a warning into console
 * @param ... A list of variables to be printed
 */
void function FSU_Warning( ... ) {
	if ( vargc <= 0 )
		return

	var msg = "[FSU][WARN]"
	for ( int i = 0; i < vargc; i++ )
		msg += " " + vargv[i]

	CodeWarning( string( msg ) )
}

/**
 * Prints an error into console, if FSU_FATAL_ERRORS is set it
 * throws an error instead
 * @param ... A list of variables to be printed
 */
void function FSU_Error( ... ) {
	if ( vargc <= 0 )
		return

	var msg = "[FSU][ERRR]"
	for ( int i = 0; i < vargc; i++ )
		msg += " " + vargv[i]

	if( GetConVarBool( "FSU_FATAL_ERRORS" ) )
		throw msg
	else
		print( msg )
}