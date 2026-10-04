extends Node
## Utils — stateless helper functions for file I/O, arrays, and node traversal.

# ── JSON / File I/O ───────────────────────────────────────────────────────────

## Load and parse a JSON file, returning the parsed value (Array or Dictionary).
## Returns null on failure and prints an error.
func import_data(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Utils.import_data: cannot open '%s' (error %d)" % [path, FileAccess.get_open_error()])
		return null
	var text := file.get_as_text()
	file.close()
	var result = JSON.parse_string(text)
	if result == null:
		push_error("Utils.import_data: JSON parse failed for '%s'" % path)
	return result


## Returns true if the file at `path` exists.
func file_exists(path: String) -> bool:
	return FileAccess.file_exists(path)


## Recursively list filenames (no .import files) inside a directory.
func get_files(path: String) -> Array:
	var files: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		push_error("Utils.get_files: cannot open directory '%s'" % path)
		return files
	dir.list_dir_begin()
	var filename := dir.get_next()
	while filename != "":
		if not filename.ends_with(".import"):
			files.append(filename)
		filename = dir.get_next()
	dir.list_dir_end()
	return files

# ── Array helpers ─────────────────────────────────────────────────────────────

## Return a new array with all elements whose `.key` property equals `key` removed.
func filter_by_key(list: Array, key: String) -> Array:
	var filtered: Array = []
	for element in list:
		if element.key != key:
			filtered.append(element)
	return filtered


## Walk `node` recursively and return all descendants that belong to `group_name`.
func find_descendants_in_group(node: Node, group_name: String) -> Array:
	var result: Array = []
	for child in node.get_children():
		if child.is_in_group(group_name):
			result.append(child)
		result += find_descendants_in_group(child, group_name)
	return result


## Traverse a dot-separated property path on `object`.
## e.g. get_prop(entity, "data.stats.health") → entity.data.stats.health
func get_prop(object: Object, path: String) -> Variant:
	var current = object
	for key in path.split(".", false):
		current = current.get(key)
	return current
