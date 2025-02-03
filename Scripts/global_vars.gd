extends Node

enum {PLAYER_ONE, PLAYER_TWO}
enum GameState {START, PLAYER_TURN, AI_TURN, ENDING, DONE}

var cube_size: int = 4
var ai_toggle: bool = false
