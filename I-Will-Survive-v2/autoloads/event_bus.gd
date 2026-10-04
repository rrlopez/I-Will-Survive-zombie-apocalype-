extends Node
## EventBus — pure signal hub. Zero logic, zero state.
## Every cross-cutting signal lives here so systems stay decoupled.
## Phase 0: declare all signals; implementations connect in their own phases.

# ── Player / Health ───────────────────────────────────────────────────────────
signal player_health_changed(old_val: float, new_val: float, max_val: float)
signal player_hunger_changed(old_val: float, new_val: float, max_val: float)
signal player_died
signal player_revived

# ── Levelling ─────────────────────────────────────────────────────────────────
signal player_levelled_up(new_level: int)
signal player_xp_changed(current_xp: float, threshold: float)

# ── Status effects ────────────────────────────────────────────────────────────
signal status_effect_added(effect)    # StatusEffect resource
signal status_effect_removed(effect)  # StatusEffect resource

# ── Day / Night ───────────────────────────────────────────────────────────────
signal day_started(day_number: int)
signal night_started(day_number: int)
signal wave_spawned(wave_number: int)

# ── World / chunks ────────────────────────────────────────────────────────────
signal chunk_loaded(chunk_key: String)
signal chunk_unloaded(chunk_key: String)
signal region_entered(region_name: String)

# ── Inventory / Items ─────────────────────────────────────────────────────────
signal item_picked_up(item_data: Dictionary)
signal item_dropped(item_data: Dictionary)
signal hotbar_slot_changed(slot_index: int)

# ── Notifications ─────────────────────────────────────────────────────────────
signal notification_requested(text: String)

# ── Save / Load ───────────────────────────────────────────────────────────────
signal game_saved
signal game_loaded
