# Fifty.ServerMessages [FSM] - ConVars
[Go back](./docs_index.md)

#### `FSM_WELCOME_USE_RUI`
**DefaultValue:** `"1"`
  Whether to use a large message on the HUD or chat messages.

#### `FSM_WELCOME_MESSAGE_TITLE`
**DefaultValue:** `"Welcome to SERVER"`
  When using the rui message this is the title, otherwise this is the first message. Can use formatting ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_WELCOME_MESSAGE_TEXT`
**DefaultValue:** `"Hope you have fun"`
  When using the rui message this is the description, otherwise this is the second message. Can use formatting ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_WELCOME_MESSAGE_IMAGE`
**DefaultValue:** `"rui/callsigns/callsign_75_col"`
  The image used by the rui message. ( https://discord.com/channels/920776187884732556/1001559004889223258 )

#### `FSM_MARVIN_DEATH_NOTIFICATION`
**DefaultValue:** `"1"`
  Whether to shame players who kill marvins in chat.

#### `FSM_PLAYER_FALL_DEATH_NOTIFICATION`
**DefaultValue:** `"1"`
  Whether to shame players who fell into the pits on glitch and wargames or fell off the cliff on relic.

#### `FSM_PLAYER_KILLSTREAK`
**DefaultValue:** `"1"`
  Whether to announce player killstreaks.

#### `FSM_USE_RUI_POPUP_FOR_KILLSTREAK`
**DefaultValue:** `"1"`
  Whether to use a popup message or chat for killstream messages.

#### `FSM_BROADCAST_ENABLE`
**DefaultValue:** `"1"`
  Whether to broadcast messages each 150 seconds.

#### `FSM_BROADCAST_RANDOM`
**DefaultValue:** `"1"`
  Whether to randomise the broadcast message order.

#### `FSM_BROADCAST_0`
**DefaultValue:** `"You can use the %H%Pnextmap <map>%T command to vote for the next map!"`
  The first broadcast message. Can use formatting ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_BROADCAST_1`
**DefaultValue:** `"You can use the %H%Pskip%T command to vote to skip the map!"`
  The second broadcast message. Can use formatting ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_BROADCAST_2`
**DefaultValue:** `"Run %H%Pextend%T to vote to extend the match."`
  The third broadcast message. Can use formatting ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_BROADCAST_3`
**DefaultValue:** `"Run %H%Phelp <command>%T to get a detailed description of what it does."`
  The fourth broadcast message. Can use formatting ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_BROADCAST_4`
**DefaultValue:** `"Run %H%Pmaps <page>%T to get a list of maps in the voting pool."`
  The fifth broadcast message. Can use formatting ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_LIST_PRINT_ON_MATCH_START`
**DefaultValue:** `"1"`
  Whether to print a list when the match starts. ( Rules, How to play, etc... )

#### `FSM_LIST_0`
**DefaultValue:** `"First %Hlist"`
  First list value. Won't be printed if left empty. ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_LIST_1`
**DefaultValue:** `"%HSecond%T list"`
  Second list value. Won't be printed if left empty. ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_LIST_2`
**DefaultValue:** `"Third %Hlist"`
  Third list value. Won't be printed if left empty. ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_LIST_3`
**DefaultValue:** `"%HFourth%T list"`
  Fourth list value. Won't be printed if left empty. ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

#### `FSM_LIST_4`
**DefaultValue:** `"Fifth %Hlist"`
  Fifth list value. Won't be printed if left empty. ( '%P' - prefix, '%H' - highlight, '%T' - normal text, '%0' - reset formatting )

