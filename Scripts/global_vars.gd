extends Node

enum {PLAYER_ONE, PLAYER_TWO}
enum GameState {START, PLAYER_TURN, AI_TURN, ENDING, DONE}

var cube_size: int = 4

var player_one_color: Color = Color(1,0,0)
var player_two_color: Color = Color(0,0,1)

var ai_toggle: bool = false
