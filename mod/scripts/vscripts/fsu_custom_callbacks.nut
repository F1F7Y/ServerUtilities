globalize_all_functions

//-----------------------------------------------------------------------------
// This file holds general custom callbacks
//-----------------------------------------------------------------------------


struct {
	array<void functionref()> matchEndCallbacksReliable
	array<void functionref()> matchEndCallbacksUnReliable
	array<bool functionref( ClServer_MessageStruct )> chatCallbacks
} file


//-----------------------------------------------------------------------------
// Purpose: Custom callbacks init callback
//-----------------------------------------------------------------------------
string function FSU_RegisterCustomCallbacksModule() {
	AddCallback_GameStateEnter( eGameState.Postmatch, FSU_EndOfMatchCallback_Threaded )

	return "CustomCallbacksModule"
}

//-----------------------------------------------------------------------------
// Purpose: Gets called right before the map is changed
//-----------------------------------------------------------------------------
void function FSU_EndOfMatchCallback_Threaded() {
	// FIXME [Fifty]: Is this, good?
	wait GAME_POSTMATCH_LENGTH - 1

	// Run first callbacks
	foreach( void functionref() callback in file.matchEndCallbacksFirst )
		callback()

	// Run second callbacks
	foreach( void functionref() callback in file.matchEndCallbacksSecond )
		callback()

	FSU_Debug( "FSU_EndOfMatchCallback_Threaded" )
}

//-----------------------------------------------------------------------------
// Purpose: Allows mods to register a match end callback
//          This version gets called first and shouldn't stop processing by
//           for example changing the map
// Input  : callback - The callback to be added
//-----------------------------------------------------------------------------
void function FSU_AddCallback_OnEndOfMatchReliable( void functionref() callback ) {
	file.matchEndCallbacksReliable.append( callback )
}

//-----------------------------------------------------------------------------
// Purpose: Allows mods to register a match end callback
//          This version gets called second and can stop processing by
//          for example changing the map
// Input  : callback - The callback to be added
//-----------------------------------------------------------------------------
void function FSU_AddCallback_OnEndOfMatchUnReliable( void functionref() callback ) {
	file.matchEndCallbacksUnReliable.append( callback )
}

//-----------------------------------------------------------------------------
// Purpose: Runs all registered chat callbacks
// Input  : message - The message struct
//-----------------------------------------------------------------------------
bool function FSU_RunOnReceivedSayTextMessageCallbacks( ClServer_MessageStruct message ) {
	bool bShouldBlock = false

	foreach( bool functionref( ClServer_MessageStruct ) callback in file.chatCallbacks )
		bShouldBlock = bShouldBlock || callback( message )

	return bShouldBlock
}

///-----------------------------------------------------------------------------
// Purpose: Allows other mods to register a chat message callback
// Input  : callback - The callback func which takes in the message struct
//-----------------------------------------------------------------------------
void function FSU_AddCallback_OnReceivedSayTextMessage( bool functionref( ClServer_MessageStruct ) callback ) {
	file.chatCallbacks.append( callback )
}