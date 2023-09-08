untyped
global function FSU_RegisterAdminCommandsModule

string function FSU_RegisterAdminCommandsModule() {
	FSU_AddCallback_ChatCommandRegister( FSU_OnRegisteringCommands )
	return "AdminCommandsModule"
}

void function FSU_OnRegisteringCommands() {
	FSU_CommandStruct cmd
	cmd.iUserLevel = eFSUPlayerLevel.ADMIN

	cmd.arrDescriptions[eFSUPlayerLevel.ADMIN] = "execute the given script"
	cmd.arrAbbreviations = [ ]
	cmd.Callback = FSU_CommandCallback_Script
	//cmd.args = 1
	//cmd.argsUsage = "<script code>"
	FSU_RegisterCommand( "script", cmd )

	
	cmd.arrDescriptions[eFSUPlayerLevel.ADMIN] = "execute the given server command"
	cmd.arrAbbreviations = [ "sc" ]
	cmd.Callback = FSU_CommandCallback_ServerCommand
	//cmd.args = 1
	//cmd.argsUsage = "<server command>"
	FSU_RegisterCommand( "servercommand", cmd )

    
	cmd.arrDescriptions[eFSUPlayerLevel.ADMIN] = "reloads the server"
	cmd.arrAbbreviations = [  ]
	cmd.Callback = FSU_CommandCallback_Reload
	//cmd.args = 0
	//cmd.argsUsage = "<time = 5>"
	FSU_RegisterCommand( "reload", cmd )

    
	cmd.arrDescriptions[eFSUPlayerLevel.ADMIN] = "bans the given player"
	cmd.arrAbbreviations = [  ]
	cmd.Callback = FSU_CommandCallback_Ban
	//cmd.args = 1
	//cmd.argsUsage = "<player name>"
	FSU_RegisterCommand( "ban", cmd )

    
	cmd.arrDescriptions[eFSUPlayerLevel.ADMIN] = "kicks the given player"
	cmd.arrAbbreviations = [  ]
	cmd.Callback = FSU_CommandCallback_Kick
	//cmd.args = 1
	//cmd.argsUsage = "<player name>"
	FSU_RegisterCommand( "kick", cmd )

    // 
	// cmd.arrDescriptions[eFSUPlayerLevel.ADMIN] = "executes a command for a given player"
	// cmd.arrAbbreviations = [ "cf", "cmdfor" ]
	// cmd.Callback = FSU_CommandCallback_CommandFor
	// FSU_RegisterCommand( "commandfor", cmd )

    
	cmd.arrDescriptions[eFSUPlayerLevel.ADMIN] = "Spawns an npc at your crosshair"
	cmd.arrAbbreviations = [ ]
	cmd.Callback = FSU_CommandCallback_NPC
	//cmd.args = 1
	//cmd.argsUsage = "<grunt/spectre/stalker/reaper/marvin> <imc/militia>"
	FSU_RegisterCommand( "npc", cmd )    
}

string function FSU_CommandCallback_Script( entity entPlayer, array<string> arrArgs ) {
    try{
        compilestring( FSU_ArrayToString(arrArgs) )()
        return "%SYour code seems to have compiled"
    }
    catch ( ex ){
        printt( ex )
        return "%EThe code has caused an exception, the error can be found in the server log"
    }
}

string function FSU_CommandCallback_ServerCommand( entity entPlayer, array<string> arrArgs ) {
	try{
		ServerCommand(FSU_ArrayToString(arrArgs))
	}
	catch(ex){
		return "%EThe command has caused an exception"
	}
	return "%SCommand executed"
}

string function FSU_CommandCallback_Reload( entity player, array<string> arrArgs ){
    thread FSU_C_Reload_thread( (arrArgs.len() <= 0) ? 5.0 : arrArgs[0].tofloat() )
    return "Reloading now"
}

void function FSU_C_Reload_thread(float time){
	while(time > 0){
		FSU_BroadcastSystemMessage("The server will reload in "+ time)
		wait 1.0
		time = time - 1.0
	}
	ServerCommand("reload")
}

string function FSU_CommandCallback_Ban(entity player, array<string> arrArgs) {
	entity toBan = FSU_GetPlayerEntityByName(arrArgs[0])

	if(toBan == null){
		return "%EPlayer not found"}

	// if( FSA_IsOwner(toBan)|| FSA_IsAdmin(toBan) )
	// 	return "%ECannot ban admins"

	ServerCommand("ban " + toBan.GetUID())
  	return "%SSucessfully banned"
}

string function FSU_CommandCallback_Kick(entity player, array<string> arrArgs) {
	entity toBan = FSU_GetPlayerEntityByName(arrArgs[0])

	if(toBan == null){
		return "%EPlayer not found"}

	// if( FSA_IsOwner(toBan)|| FSA_IsAdmin(toBan) )
	// 	return "%ECannot ban admins"

	ServerCommand( "kick " + toBan.GetUID() )
  	return "%SSucessfully kicked"
}

string function FSU_CommandCallback_NPC( entity player, array< string > arrArgs ) {
	int team = TEAM_UNASSIGNED
	string npc = ""
	if( arrArgs.len() >= 1 ) {
		if( arrArgs.len() >= 2 ) {
			switch( arrArgs[1].tolower() ) {
				case "imc":
					team = TEAM_IMC
					break
				case "militia":
					team = TEAM_MILITIA
					break
			}
		}

		switch( arrArgs[0].tolower() ) {
			case "grunt":
				npc = "npc_soldier"
				break
			case "spectre":
				npc = "npc_spectre"
				break
			case "stalker":
				npc = "npc_stalker"
				break
			case "marvin":
				npc = "npc_marvin"
				break
		}
	}

	if( npc.len() == 0 ) 
		return "%ECouldn't find entity: " + arrArgs[0]

	thread DEV_SpawnNPCWithWeaponAtCrosshair( npc, npc, team )
	return "%SSpawned a " + arrArgs[0] + "!" 
}

string function FSA_CommandCallback_Titan( entity player, array< string > arrArgs ) {
	int team = TEAM_UNASSIGNED
	string titan = ""
	if( arrArgs.len() >= 1 ) {
		if( arrArgs.len() >= 2 ) {
			switch( arrArgs[1].tolower() ) {
				case "imc":
					team = TEAM_IMC
					break
				case "militia":
					team = TEAM_MILITIA
					break
			}
		}

		switch( arrArgs[0].tolower() ) {
			case "ion":
				titan = "npc_titan_auto_atlas_ion_prime"
				break
			case "scorch":
				titan = "npc_titan_ogre_meteor"
				break
			case "northstar":
				titan = "npc_titan_auto_stryder_sniper"
				break
			case "ronin":
				titan = "npc_titan_auto_stryder_leadwall"
				break
			case "tone":
				titan = "npc_titan_atlas_tracker"
				break
			case "legion":
				titan = "npc_titan_auto_ogre_minigun"
				break
			case "monarch":
				titan = "npc_titan_auto_atlas_vanguard"
				break
		}
	}

	if( titan.len() == 0 ) 
		return "%ECouldn't find entity: " + arrArgs[0] 

	thread DEV_SpawnNPCWithWeaponAtCrosshair( "npc_titan", titan, team )
	return "%SSpawned a " + arrArgs[0] + "!" 
}
