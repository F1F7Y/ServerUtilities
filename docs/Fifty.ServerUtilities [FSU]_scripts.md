# Fifty.ServerUtilities [FSU] - Scripts
[Go back](./docs_index.md)


## fsu_core.nut

#### `void function FSU_Init()`

Gets called after the map is loaded

#### `void function FSU_PrintPrematchMessage()`

Prints a message to global chat to inform players which features they can use
based on which FSU modules are enabled. Also prints which modules are enabled
to console

#### `void function FSU_Error( string message )`

Prints a message to the console and prepends "[FSU][ERRR]" to it
##### Argumets:
- `mesage` The message to be printed to console

#### `void function FSU_Warning( string message )`

Prints a message to the console and prepends "[FSU][WARN]" to it
##### Argumets:
- `mesage` The message to be printed to console

#### `void function FSU_Print( string message )`

Prints a message to global chat to inform players which features they can use
based on which FSU modules are enabled. Also prints which modules are enabled
to console

#### `void function FSU_ChatBroadcast( string message, bool usePopUp = false )`

Sends a colored message to global chat and prepends it with [FSU]
##### Argumets:
- `mesage` The message to be sent to global chat
- `usePopUp` Whether we should use serverside rui instead of chat

#### `void function FSU_PrivateChatMessage( entity player, string message )`

Sends a colored message to player in chat and prepends it with [FSU]
##### Argumets:
- `player` The player to send the message to
- `mesage` The message to be sent to player

#### `int function FSU_GetListPages( array< string > list, int rows = 5, string separator = "%T, " )`

Returns the maximum number of pages for FSU_PrintFormattedList
##### Argumets:
- `list` The list to be printed
- `columns` The nubre of columns per row
- `separator` The list item separator, inconsquential as long as charachter count is the same

#### `void function FSU_PrintFormattedList( entity player, array< string > list, int page, string separator = "%T, ", int rows = 5, string color = "%H" )`

Prints a part of an array in pages
##### Argumets:
- `player` The player to send the list to
- `list` The list to be printed
- `page` The page to display
- `separator` The list item separator
- `rows` The number of rows to print per page
- `color` The color of list items

#### `void function FSU_PrintFormattedListWithoutPagination( entity player, array< string > list, string separator = "%T, ", string color = "%H" )`

Prints a full list without pagination, as densely as possible
##### Argumets:
- `player` The player to send the list to
- `list` The list to be printed
- `separator` The list item separator
- `color` The color of list items

#### `string function FSU_ArrayToString( array< string > args, string separator = " " )`

Returns the given array as a sting
##### Argumets:
- `args` Array of stings that will be
- `separator` optional argument of string that will separate all words

#### `string function FSU_FormatString( string str )`

Returns a formatted string convar
##### Argumets:
- `str` The string to format

#### `int function FSU_GetIntegerFromHexString( string hex )`

Returns integer from hex string
##### Argumets:
- `hex` The hex string to convert

#### `string function FSU_GetFormattedConVar( string convar )`

Returns a formatted string convar
##### Argumets:
- `convar` The convar to format

#### `string function FSU_Highlight( string message )`

Highlights a string using ANSI code and returns the highlited string
##### Argumets:
- `mesage` The string to be highlited

#### `string function FSU_FmtEnd()`

Returns an ANSI code resetting formatting

#### `string function FSU_FmtBegin()`

Returns an ANSI code coloring the text

#### `string function FSU_FmtAdmin()`

Returns an ANSI code coloring the adminHeader

#### `void function FSU_SaveArrayToConVar(string convar, array <string> input)`

Saves a string array into a convar, as "," is used as the divider it should NEVER be present in the items of the array
##### Argumets:
- `convar` Which convar
- `input` The array that is to be saved

#### `void function FSU_SaveArrayArrayToConVar(string convar, array <array <string> > input)`

Saves an array of string arrays into a convar, as "," and "-" are used as the dividers, they should NEVER be present in the items of the array
##### Argumets:
- `convar` Which convar
- `input` An array of the arrays to be saved

#### `int function FSU_GetSettingIntFromConVar(string convar)`

Returns just the setting value of a convar if it is also used to store data
##### Argumets:
- `convar` Which convar

#### `array <string> function FSU_GetArrayFromConVar(string convar)`

Returns an array that has been stored in a convar using FSU_SaveArrayToConVar
##### Argumets:
- `convar` Which convar

#### `array <string> function FSU_GetSelectedArrayFromConVar(string convar, int whichArray)`

Returns the selected array from a convar that is storing more than one
##### Argumets:
- `convar` Which convar
- `whichArray` Which array to pull, provide an index number


## fsu_deprecated.nut

#### `void function FSU_RegisterCommand ( string name, string usage, string group, void functionref( entity, array < string > ) callbackFunc, array < string > abbreviations = [], bool functionref( entity ) visibilityFunc = null )`

A deprecated FSU < v2 function used to register commands

#### `bool function FSU_CanCreatePoll ()`

A deprecated FSU < v2 function used to check if a poll can be created

#### `void function FSU_CreatePoll ( array < string > options, string before, float duration, bool show_result )`

A deprecated FSU < v2 function used to create a poll

#### `int function FSU_GetPollResultIndex ()`

A deprecated FSU < v2 function used to get a poll result

