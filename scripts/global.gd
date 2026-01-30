extends Node
class_name Global

var unlocked_levels := 1
var high_score := 0
var level_stars := {} # {level_id: stars}

func save_game():
	var file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var data = {
		"unlocked_levels": unlocked_levels,
		"high_score": high_score,
		"level_stars": level_stars
	}
	file.store_string(JSON.stringify(data))

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return
		
	var file = FileAccess.open("user://savegame.save", FileAccess.READ)
	var json_string = file.get_as_text()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result == OK:
		var data = json.get_data()
		unlocked_levels = data.get("unlocked_levels", 1)
		high_score = data.get("high_score", 0)
		level_stars = data.get("level_stars", {})

func complete_level(level: int, stars: int):
	level_stars[str(level)] = max(level_stars.get(str(level), 0), stars)
	if level == unlocked_levels:
		unlocked_levels += 1
	save_game()
