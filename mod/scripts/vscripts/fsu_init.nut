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
// Settings structs
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