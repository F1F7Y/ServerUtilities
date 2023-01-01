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

#### `void function FSV_CommandCallback_Maps( entity player, array< string > args )`

Gets called when a player runs !maps
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player

#### `void function FSV_CommandCallback_Extend( entity player, array< string > args )`

Gets called when a player runs !extend
##### Argumets:
- `player` The player who caled the command
- `args` The arguments passed by the player


## fsv_core.nut

#### `void function FSV_Init()`

Gets called after the map is loaded

#### `array< entity > function FSV_GetPlayerArrayReference_Extend()`

Returns a reference to an array of players who have voted to extend the match

#### `array< entity > function FSV_GetPlayerArrayReference_Skip()`

Returns a reference to an array of players who have voted to skip the map

#### `array< entity > function FSV_GetPlayerArrayReference_NextMap()`

Returns a reference to an array of players who have voted for the next map

#### `void function FSV_VoteForNextMap( entity player, string map )`

Adds a vote to a map
##### Argumets:
- `player` The player who voted
- `map` The map to vote for

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

