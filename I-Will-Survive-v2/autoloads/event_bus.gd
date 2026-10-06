extends Node
## EventBus — pure signal hub. Zero logic, zero state.
## All signals declared here; each phase connects/emits in its own files.
## @warning_ignore("unused_signal") suppresses false positives — signals are
## emitted and connected across other files, not in this one.

@warning_ignore("unused_signal") signal player_health_changed(old_val: float, new_val: float, max_val: float)
@warning_ignore("unused_signal") signal player_hunger_changed(old_val: float, new_val: float, max_val: float)
@warning_ignore("unused_signal") signal player_died
@warning_ignore("unused_signal") signal player_revived
@warning_ignore("unused_signal") signal player_levelled_up(new_level: int)
@warning_ignore("unused_signal") signal player_xp_changed(current_xp: float, threshold: float)

@warning_ignore("unused_signal") signal status_effect_added(effect: Resource)
@warning_ignore("unused_signal") signal status_effect_removed(effect: Resource)

@warning_ignore("unused_signal") signal day_started(day_number: int)
@warning_ignore("unused_signal") signal night_started(day_number: int)
@warning_ignore("unused_signal") signal wave_spawned(wave_number: int)

@warning_ignore("unused_signal") signal chunk_loaded(chunk_key: String)
@warning_ignore("unused_signal") signal chunk_unloaded(chunk_key: String)
@warning_ignore("unused_signal") signal region_entered(region_name: String)

@warning_ignore("unused_signal") signal item_picked_up(item_data: Dictionary)
@warning_ignore("unused_signal") signal item_dropped(item_data: Dictionary)
@warning_ignore("unused_signal") signal hotbar_slot_changed(slot_index: int)

@warning_ignore("unused_signal") signal notification_requested(text: String)

@warning_ignore("unused_signal") signal game_saved
@warning_ignore("unused_signal") signal game_loaded

@warning_ignore("unused_signal") signal chunk_activated(coord: Vector2i)
@warning_ignore("unused_signal") signal chunk_deactivated(coord: Vector2i)
@warning_ignore("unused_signal") signal poi_discovered(poi_id: String, coord: Vector2i)

@warning_ignore("unused_signal") signal enemy_aggroed(position: Vector2, target: Node)
@warning_ignore("unused_signal") signal enemy_died(enemy: Node, position: Vector2)
