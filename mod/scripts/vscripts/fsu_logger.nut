globalize_all_functions

//-----------------------------------------------------------------------------
// Purpose: Prints a message into console
// Input  : ... - A list of variables to be printed
//-----------------------------------------------------------------------------
void function FSU_Print( ... ) {
	if ( vargc <= 0 )
		return

	var msg = "[FSU][INFO]"
	for ( int i = 0; i < vargc; i++ )
		msg += " " + vargv[i]

	print( msg )
}

//-----------------------------------------------------------------------------
// Purpose: Prints a warning into console
// Input  : ... - A list of variables to be printed
//-----------------------------------------------------------------------------
void function FSU_Warning( ... ) {
	// FIXME [Fifty]: CodeWarning calls the engine warning func, dont think ns
	//                hooks it
	if ( vargc <= 0 )
		return

	var msg = "[FSU][WARN]"
	for ( int i = 0; i < vargc; i++ )
		msg += " " + vargv[i]

	CodeWarning( string( msg ) )
}

//-----------------------------------------------------------------------------
// Purpose: Prints an error into console, if FSU_FATAL_ERRORS is set it
//          throws an error instead
// Input  : ... - A list of variables to be printed
//-----------------------------------------------------------------------------
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

//-----------------------------------------------------------------------------
// Purpose: Prints a debug message into the chat and the console only when
//          FSU_DEBUG_PRINT is set
// Input  : ... - A list of variables to be printed
//-----------------------------------------------------------------------------
void function FSU_Debug( ... ) {
	if( !GetConVarBool( "FSU_DEBUG_PRINT" ) )
		return

	if ( vargc <= 0 )
		return

	string msg = "[FSU][DEBG]"
	for ( int i = 0; i < vargc; i++ )
		msg += " " + vargv[i]

	NSBroadcastMessage( -1, -1, msg , true, false, 1 )
}