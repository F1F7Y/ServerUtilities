# Fifty.ServerChatCommands [FSCC] - Scripts
[Go back](./docs_index.md)


## fscc_core.nut

#### `void function FSCC_Init()`

Gets called after the map is loaded

#### `void function FSCC_RegisterCommand( string name, FSCC_CommandStruct command )`

Registers a chat command
##### Argumets:
- `mesage` The message to be printed to console

#### `array< string > function FSCC_GetCommands( entity player )`

Return a string array of registered commands
##### Argumets:
- `player` The player to check for command rights

#### `FSCC_CommandStruct function FSCC_GetCommandAttributes( string command )`

Returns the command struct containing information about the command
##### Argumets:
- `command` The command to get the info for

#### `table <string, FSCC_CommandStruct > function FSCC_GetCommandList()`

Retuns the commandList table


## fscc_command_callbacks.nut

#### `void function FSCC_CommandCallback_Help( entity player, array< string > args )`

Gets called when a player runs !help
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSCC_CommandCallback_Mods( entity player, array< string > args )`

Gets called when a player runs !mods
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSCC_CommandCallback_Name( entity player, array< string > args )`

Gets called when a player runs !name
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSCC_CommandCallback_Owner( entity player, array< string > args )`

Gets called when a player runs !owner
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSCC_CommandCallback_Rules( entity player, array< string > args )`

Gets called when a player runs !rules
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSCC_CommandCallback_Discord( entity player, array< string > args )`

Gets called when a player runs !discord
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

