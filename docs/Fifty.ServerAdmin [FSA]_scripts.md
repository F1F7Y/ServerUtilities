# Fifty.ServerAdmin [FSA] - Scripts
[Go back](./docs_index.md)


## fsa_core.nut

#### `void function FSA_Init()`

Gets called after the map is loaded

#### `array< entity > function FSA_GetLoggedInAdmins()`

Returns loggedin admins

#### `ClServer_MessageStruct function FSA_CheckMessageForPrivilegedUser( ClServer_MessageStruct message )`

Gets called when a player sends a chat message
##### Argumets:
- `message` The message struct containing information about the chat message

#### `void function FSA_SendMessageWithPrefix( entity from, string message, bool isTeamMessage, array< string > prefix )`

Sends a message with a prefix
##### Argumets:
- `from` The player who originally sent the message
- `message` The message string
- `isTeamMessage` Whether it was sent in team or grobal chat
- `prefix` The prefix to add

#### `bool function FSA_IsOwner( entity player )`

Returns true if player is an owner
@ param player The player to check

#### `bool function FSA_IsAdmin( entity player )`

Returns true if player is an admin
@ param player The player to check

#### `entity function FSA_GetPlayerEntityByName(string name)`
/*
Returns the entity of a player name returns null if no player was found
@ param name The name of the player you want the entity of

#### `void function FSCC_CommandCallback_Playerlist( entity player, array< string > args )`

Gets called when a player runs !playerlist
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSCC_CommandCallback_Script(entity player, array<string> args)`

Gets called when a player runs !script
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSCC_CommandCallback_ServerCommand(entity player, array<string> args)`

Gets called when a player runs !serverCommand
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSCC_CommandCallback_Reload(entity player, array<string> args)`

Gets called when a player runs !reload
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSU_C_Reload_thread(float time)`

#### `void function FSCC_CommandCallback_Ban(entity player, array<string> args)`

Gets called when a player runs !ban
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSCC_CommandCallback_Kick(entity player, array<string> args)`

Gets called when a player runs !kick
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSCC_CommandCallback_CommandFor(entity player, array<string> args)`

Gets called when a player runs !commandFor
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player


## fsa_command_callbacks.nut

#### `void function FSA_CommandCallback_NPC( entity player, array< string > args )`

Gets called when a player runs !npc
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSA_CommandCallback_Titan( entity player, array< string > args )`

Gets called when a player runs !titan
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSA_CommandCallback_Login( entity player, array< string > args )`

Gets called when a player runs !login
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSA_CommandCallback_Logout( entity player, array< string > args )`

Gets called when a player runs !logout
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

