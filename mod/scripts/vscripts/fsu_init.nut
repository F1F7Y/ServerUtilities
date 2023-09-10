//-----------------------------------------------------------------------------
// FSU Init script
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Player level used for command permissions
global enum eFSUPlayerLevel {
	DEFAULT = 0,
	VIP = 1,
	MODERATOR = 2,
	ADMIN = 3,
	OWNER = 4,
	LENGTH = 5
}

//-----------------------------------------------------------------------------
// Commands
global struct FSUCommand_t {
	// Minimum level for a user to be able to use / see the command
	int iUserLevel = eFSUPlayerLevel.DEFAULT
	// Command descripiton
	// Each array index corresponds to a eFSUPlayerLevel
	// If a description is empty for a level we use the next one under us
	string[eFSUPlayerLevel.LENGTH] arDescriptions
	// Command abbreviations
	array<string> arAbbreviations
	// Callback function
	string functionref( entity, array<string> ) fnCallback
}

//-----------------------------------------------------------------------------
// Settings
global struct FSUTheme_t
{
	int iRed   = 255
	int iGreen = 255
	int iBlue  = 255
}

global struct FSUPlayerTag_t
{
	string svName = "UNITILIASED"
	int iRed   = 255
	int iGreen = 255
	int iBlue  = 255
}

global struct FSUPlayer_t
{
	int iAccessLevel = eFSUPlayerLevel.DEFAULT
	array<FSUPlayerTag_t> arTags
}

global struct FSUSettings_t
{
	int    iVersion
	string svChatPrefix
	string svCommandPrefix

	// < Name, Theme >
	table<string,FSUTheme_t> tbThemes

	// < UID, Player >
	table<string,FSUPlayer_t> tbPlayers
}