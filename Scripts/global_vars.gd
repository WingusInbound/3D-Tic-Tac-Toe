extends Node

enum {PLAYER_ONE, PLAYER_TWO}
enum GameState {START, # Used while the game is launching, before reaching main menu
				MAIN_MENU, # Used while the player is navigating the main menu or options
				SETUP, # Used after the player has started the game, before the game is ready to accept input
				PLAYER_TURN, # Used during the turn of any human player
				AI_TURN, # Used during the turn of the AI player, if it is enabled
				ENDING, # Used after a win is detected, to allow time for animation
				DONE, # Used after the final animation has completed
				}


# Player Configurations
# Set in-game in Options Menu
var cube_size: int = 4
var player_one_color: Color = Color(1,0,0)
var player_two_color: Color = Color(0,0,1)
var ai_toggle: bool = false


# Game Settings
# Set by game functions
var game_state: int = GlobalVars.GameState.START
