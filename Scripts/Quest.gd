extends Node

signal progress_updated(current_progress: Dictionary, current_goal: Dictionary)

var current_quest: Dictionary = {
	"ghost": 2,
	"banshee": 1
}

var progress: Dictionary = {}

func _ready():
	print("Quest.gd ready: initializing progress tracking.")
	reset_progress()

func update_progress(ghost_type_counts: Dictionary) -> void:
	if ghost_type_counts == null:
		push_warning("[Quest] update_progress called with null ghost_type_counts.")
		return

	print("[Quest] update_progress called with:", ghost_type_counts)

	var changed := false
	for gtype in ghost_type_counts.keys():
		if current_quest.has(gtype):
			var old_val = progress.get(gtype, 0)
			var new_val = old_val + ghost_type_counts[gtype]
			new_val = min(new_val, current_quest[gtype])
			if new_val != old_val:
				print("[Quest] Updating progress for %s: %d -> %d" % [gtype, old_val, new_val])
				progress[gtype] = new_val
				changed = true
		else:
			print("[Quest] Ignored ghost type (not in quest):", gtype)

	if changed:
		emit_signal("progress_updated", progress, current_quest)

func get_progress_string() -> String:
	var parts = []
	for gtype in current_quest.keys():
		var goal = current_quest[gtype]
		var current = progress.get(gtype, 0)
		parts.append("%s: %d/%d" % [gtype.capitalize(), current, goal])
	return "Quest - " + ", ".join(parts)

func is_quest_complete() -> bool:
	for gtype in current_quest.keys():
		if progress.get(gtype, 0) < current_quest[gtype]:
			return false
	return true

func reset_progress() -> void:
	progress.clear()
	for key in current_quest.keys():
		progress[key] = 0
	emit_signal("progress_updated", progress, current_quest)
