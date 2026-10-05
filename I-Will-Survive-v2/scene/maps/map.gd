class_name MapTileMap extends TileMap
## Procedural road and building placement — full implementation in Phase 17.
## Phase 4 stub: methods exist but do nothing.


## Called by city/suburb chunk scenes to draw road tiles along a path.
## from: Vector2i — start tile coordinate. to: Vector2i — end tile coordinate.
func generate_road(_from: Vector2i, _to: Vector2i) -> void:
	pass  # Phase 17


## Called by city chunk scenes to place a house tile cluster.
## coord: Vector2i — chunk grid coordinate. house_type: String — variant name.
func place_house(_coord: Vector2i, _house_type: String) -> void:
	pass  # Phase 17
