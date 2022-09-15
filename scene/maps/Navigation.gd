extends Navigation2D
onready var current_navpoly_id = 1

var blocks = []
export(NodePath) onready var navPolygon  = get_node(navPolygon) as NavigationPolygonInstance

func _ready():
	var polygon = navPolygon.navpoly
	polygon.clear_polygons()
	polygon.clear_outlines()
	
	createNavigationBound(polygon)
	
	polygon.make_polygons_from_outlines()
	navPolygon.navpoly = polygon
	
	
func generateNavigationPolygon(block):
	blocks.append(block)
	Globals.loadingBlocksCount-=1
	if Globals.loadingBlocksCount>0: return
	Globals.stateManager.removeOverlayState("loadingState")
	Globals.currentMap.emit_signal("onReady")
	Serialize.loadMap()
	
	var polygon = navPolygon.navpoly
	createNavigationCuts(polygon)
		
	polygon.make_polygons_from_outlines()
	navPolygon.navpoly = polygon

func createNavigationBound(polygon):
	var bounds = get_parent().get_child(0).shape.extents
	var newPolygon = PoolVector2Array()
	newPolygon.append(Vector2(-bounds.x, -bounds.y))
	newPolygon.append(Vector2(bounds.x, -bounds.y))
	newPolygon.append(Vector2(bounds.x, bounds.y))
	newPolygon.append(Vector2(-bounds.x, bounds.y))
	polygon.add_outline(newPolygon)


func createNavigationCuts(polygon):
	for block in blocks:
		var obstacles = Utils.findNodeDescendantsInGroup(block, 'obstacle')
		for obstacle in obstacles:
			var newPolygon = PoolVector2Array()
			var polygon_transform = obstacle.get_global_transform()
			var polygon_bp = obstacle.get_polygon()
			for vertex in polygon_bp: newPolygon.append(polygon_transform.xform(vertex))
			polygon.add_outline(newPolygon)
	blocks = []
