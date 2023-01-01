# Fifty.ServerUtilities [FSU] - Scripts
[Go back](./docs_index.md)


## fsu_core.nut

#### `void function FSU_Init()`

Gets called after the map is loaded

#### `void function FSU_PrintPrematchMessage()`

Prints a message to global chat to inform players which features they can use
based on which FSU modules are enabled. Also prints which modules are enabled
to console

#### `void function FSU_SetTheme( string headerCode, string highlightCode, string textCode, string adminHeaderCode, string ownerHeaderCode )`

Sets the ANSI codes used for formatting
##### Argumets:
- `headerCode` The ANSI code to be used for the message header ( "[FSU]" )
- `highlightCode` The ANSI code to be used for highlighted text
- `textCode` The ANSI code to be used for normal text
- `adminHeaderCode` The ANSI code to be used for the admin header ( "[ADMIN]" )
- `ownerHeaderCode` The ANSI code to be used for the owner prefix ( "[OWNER]" )

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

#### `int function FSU_GetListPages( array< string > list, int columns = 1 )`

Returns the maximum number of pages for FSU_PrintFormattedList
##### Argumets:
- `list` The list to be printed
- `columns` The nubre of columns per row

#### `void function FSU_PrintFormattedList( entity player, array< string > list, int page, int columns = 1, string separator = ", " )`

Prints a part of an array in pages
##### Argumets:
- `player` The player to send the list to
- `list` The list to be printed
- `page` The page to display
- `columns` The nubre of columns per row
- `separator` The list item separator

#### `string function FSU_ArrayToString( array< string > args, string separator = " " )`

Returns the given array as a sting
##### Argumets:
- `args` Array of stings that will be
- `separator` optional argument of string that will separate all words

#### `string function FSU_FormatString( string str )`

Returns a formatted string convar
##### Argumets:
- `str` The string to format

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


## fsu_deprecated.nut

#### `void function FSU_RegisterCommand ( string name, string usage, string group, void functionref( entity, array < string > ) callbackFunc, array < string > abbreviations = [], bool functionref( entity ) visibilityFunc = null )`

A deprecated FSU < v2 function used to register commands

#### `bool function FSU_CanCreatePoll ()`

A deprecated FSU < v2 function used to check if a poll can be created

#### `void function FSU_CreatePoll ( array < string > options, string before, float duration, bool show_result )`

A deprecated FSU < v2 function used to create a poll

#### `int function FSU_GetPollResultIndex ()`

A deprecated FSU < v2 function used to get a poll result

