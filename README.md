# Fifty.ServerUtils
A framework for chat command based server mods. Doesn't spam the chat, doesn't cover your HUD with unnecessarily large messages, doesn't have a dogwater auto-balance.

The mod is separated into modules all of which have extensive settings and apart from the core (FSU) and chat commands (FSCC) can be entirely disabled or even deleted.

### [Documentation](https://github.com/F1F7Y/ServerUtilities/blob/main/docs/docs_index.md)

All commands are case insensitive ( e.g. `commandFor` and `comandfor` are the same command ).

## Commands
*`!help <page/command>`* - Lists commands avalible to the player. If a `command` is passed it lists its usage and detailed description.

*`!name`* - Returns the name of the server ( `ns_server_name` ).

*`!owner`* - Returns the owner.

*`!mods <page>`* - Lists installed mods.

*`!rules <page>`* - Lists rules.

*`!login <password>`* - Allows admins to login to gain access to admin only commands.

*`!maps`* - list all maps in the voting pool.

*`!nextmap <map>`* - Allows you to vote for the next map. Admins can force change maps when logged in.

*`!discord`* - Returns the discord message.

*`!skip`* - Allows players to vote to skip the current map.

*`!switch`* - Allows a player to switch teams. Admins can force change the team of any player.

*`!extend`* - Allows players to vote to extend the match. Admins can force extend.

## Admin commands
*`!logout`* - Logout

*`!npc <npc> <team>`* - Allows admins to spawn an npc.

*`!titan <titan> <team>`* - Allows admins to spawn a titan.

*`!playerlist`* - Prints a list of each player and their index in chat.

*`!script <code>`* - Executes code on the server.

*`!servercommand <command>`* - Executes a command on the server.

*`!reload <time=5>`* - Reloads the server.

*`!ban <player>`* - Bans the given player

*`!kick <player>`* - Kicks the given player.

*`!commandfor <player> <command>`* - Executes a command for a player

## Other features
*`Killstreaks`* - Display a message or RUI pop up when someone is on a Killstreak.

*`Tomfoolery`* - Shame players in chat for killing MRVNs or falling off the map.

*`Map playlist`* - Set a custom map playlist, and have in rotate in order, or randomly.

*`Balance teams`* - Balance teams between rounds.

*`User tags`* - Give owners, admins, or anyone else, a player tag. (appears before their name in chat)

*`Custom colors`* - Use hex color codes to set your own colors for the chat command UI
