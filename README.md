# Fifty.ServerUtils
A framework for chat command based server mods. Doesn't spam the chat, doesn't cover your HUD with unnecessarily large messages, doesn't have a dogwater auto-balance.

The mod is separated into modules all of which have extensive settings and apart from the core (FSU) and chat commands (FSCC) can be entirely disabled or even deleted.

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
