extends Navigation2D
onready var current_navpoly_id = 1


export(NodePath) onready var blocks  = get_node(blocks) as Node2D

func _ready():
	var polygon = $Polygon.get_navigation_polygon()
	
	createNavigationBound(polygon)
	createNavigationCuts(polygon)
		
	polygon.make_polygons_from_outlines()
	$Polygon.set_navigation_polygon(polygon)
	$Polygon.enabled = false
	$Polygon.enabled = true

func createNavigationBound(polygon):
	var bounds = get_parent().get_child(0).shape.extents
	var newPolygon = PoolVector2Array()
	newPolygon.append(Vector2(-bounds.x, -bounds.y))
	newPolygon.append(Vector2(bounds.x, -bounds.y))
	newPolygon.append(Vector2(bounds.x, bounds.y))
	newPolygon.append(Vector2(-bounds.x, bounds.y))
	polygon.add_outline(newPolygon)


func createNavigationCuts(polygon):
	var obstacles = Utils.findNodeDescendantsInGroup(blocks, 'obstacle')
	for obstacle in obstacles:
		var newPolygon = PoolVector2Array()
		var polygon_transform = obstacle.get_global_transform()
		var polygon_bp = obstacle.get_polygon()
		for vertex in polygon_bp: newPolygon.append(polygon_transform.xform(vertex))
		polygon.add_outline(newPolygon)
		
