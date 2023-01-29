# Fifty.ServerVote [FSV] - Scripts
[Go back](./docs_index.md)


## fsv_command_callbacks.nut

#### `void function FSV_CommandCallback_NextMap( entity player, array< string > args )`

Gets called when a player runs !nextmap
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSV_CommandCallback_Skip( entity player, array< string > args )`

Gets called when a player runs !skip
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSV_SkipThread()`

Thread for skip votes

#### `void function FSV_CommandCallback_Extend( entity player, array< string > args )`

Gets called when a player runs !extend
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSV_ExtendThread()`

Thread for extend votes

#### `void function FSV_CommandCallback_Kick( entity player, array<string> args)`

Gets called when a player runs !kick
##### Argumets:
- `player` The player who called the command
- `args` The arguments passed by the player

#### `void function FSV_KickThread(string targetName, string targetUid)`

Thread for kick votes

#### `// void function TestVoteHUD()`

#### `// void function FSV_CommandCallback_TestVote(entity player, array<string> args)`


## fsv_core.nut

#### `void function FSV_Init()`

Gets called after the map is loaded

#### `void function FSV_UpdatePlayedMaps()`

Updates last played (vote blocked) maps

#### `string function FSV_TimerToMinutesAndSeconds(int timer)`

Convert seconds to minutes and seconds

#### `void function FSV_JoiningPlayerKickCheck(entity player)`

Runs on player connected, preventing any previously kicked players from re-joining

#### `void function FSV_UpdateKicked()`

Updates the kicked player re-join block list, removing any expired blocks and incrementing existing ones

#### `void function FSV_VoteForNextMap( entity player, string map )`

Adds a vote to a map
##### Argumets:
- `player` The player who voted
- `map` The map to vote for

#### `table <entity, string> function FSV_GetMapVoteTable()`

Grab a reference to the mvt

#### `string function FSV_GetNextMapChances()`

Get current next map chances

#### `string function FSV_GetNextMap()`

Get current next map chances

#### `void function FSV_EndOfMatchMatch_Threaded()`

Gets called when the game enters Postmatch

#### `void function FSV_SkipMatch()`

Skips the current map

#### `void function FSV_ExtendMatch( float minutes )`

Extends the match
##### Argumets:
- `minutes` The amount by which to extend the match


## fsv_localization.nut

#### `void function FSV_Localization_Init()`

Gets called after the map is loaded

#### `string function FSV_Localize( string str )`

Localizes the map name
##### Argumets:
- `str` The string to localize

#### `string function FSV_UnLocalize( string str )`

UnLocalizes the map name
##### Argumets:
- `str` The string to unlocalize

#### `array< string > function FSV_LocalizeArray( array< string > list )`

Localizes an array of map names
##### Argumets:
- `list` The string array to localize

#### `array <string> function FSV_GetMapArrayFromConVar( string convar )`

Get a valid array from one of the map ConVars, discarding any invalid items and matching any partial entries to proper IDs

