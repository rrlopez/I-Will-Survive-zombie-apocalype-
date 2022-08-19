extends TileMap

export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D
var houseScene = [
	preload("res://scene/entities/houses/House.tscn"),
	preload("res://scene/entities/houses/House2.tscn"),
	preload("res://scene/entities/houses/House3.tscn")
]


var density = 5
var snap = 20
var pointSnap = 3

func _ready():
	drawGrass(collider.shape.extents)
	
	generateRoad(collider.shape.extents, 6)
	generateRoad(collider.shape.extents, 4)
	generateRoad(collider.shape.extents, 2)


func drawGrass(size):
	size = size/64
	for x in size.x*2:
		for y in size.y*2:
			set_cell(x-size.x, y-size.y, 12)

func generateRoad(size, width):
	size = size/(64*3)
	var intersections = generatePoints(size, width)
	generateIntersections(intersections, width)

func generatePoints(size, width):
	var intersections = []
	var point1 = Vector2(Constants.rand.randi_range(-size.x/snap, size.x/snap), Constants.rand.randi_range(-size.y/snap, size.y/snap))*snap
	if density < 1: return intersections
	for i in (size.x*size.y)/(width*width*density):
		Constants.rand.randomize()
		var point2 = point1 + (Vector2(Constants.rand.randi_range(-1, 1), Constants.rand.randi_range(-1, 1))*(width*snap)/2)
		if !(point2.x < size.x && point2.x > -size.x): point2.x = point1.x
		if !(point2.y < size.y &&  point2.y > -size.y): point2.y = point1.y
		var path = connectPoints(point1*pointSnap, point2*pointSnap)
		for point in path.intersections: intersections.append(point)
		for point in generatePath(path.points, width): intersections.append(point)
		point1 = point2
	return intersections


func connectPoints(point1, point2):
	var points = []
	var intersections = []
	var isIntersected = false
	if get_cell(point1.x, point1.y)==12: points.append(point1)
	var point = Vector2(point1.x, point1.y)
	
	while point.x > point2.x:
		point = Vector2(point.x-pointSnap, point.y)
		if get_cell(point.x, point.y)==12:
			isIntersected = false
			points.append(point)
		elif !isIntersected:
			isIntersected = true
			intersections.append(point)
	while point.x < point2.x: 
		point = Vector2(point.x+pointSnap, point.y)
		if get_cell(point.x, point.y)==12:
			isIntersected = false
			points.append(point)
		elif !isIntersected:
			isIntersected = true
			intersections.append(point)
	
	while point.y > point2.y: 
		point = Vector2(point.x, point.y-pointSnap)
		if get_cell(point.x, point.y)==12:
			isIntersected = false
			points.append(point)
		elif !isIntersected:
			isIntersected = true
			intersections.append(point)
	while point.y < point2.y: 
		point = Vector2(point.x, point.y+pointSnap)
		if get_cell(point.x, point.y)==12:
			isIntersected = false
			points.append(point)
		elif !isIntersected:
			isIntersected = true
			intersections.append(point)
	
	if get_cell(point2.x, point2.y)==12: points.append(point2)
	
	return {"intersections": intersections, "points": points}



func generatePath(path, width):
	var intersections = []
	var lastDir=1
	var curDir=1
	for i in path.size():
		var offset = Vector2.ZERO
		var rotated = 0
		var direction = path[i].direction_to(path[min(i+1, path.size()-1)])
		if abs(direction.x) < abs(direction.y): 
			curDir=1
			offset = Vector2(width, 0)
			rotated = 90
			drawVerticalLine(path[i], width)
		else: 
			curDir=0
			offset = Vector2(0, width)
			rotated = 180
			drawHorizontalLine(path[i], width)
		if lastDir!=curDir: intersections.append(path[i])
		lastDir=curDir
		
		placeHouse(path[i], offset+(offset.normalized()*8), rotated)
	return intersections
	
	
func drawVerticalLine(point, width):
	#point = point*3
	drawVerticalRoad(point.x, point.y-1, 4, width)
	drawVerticalRoad(point.x, point.y, 3, width)
	drawVerticalRoad(point.x, point.y+1, 4, width)

func drawVerticalRoad(x, y, id, width):
	set_cell(x, y, id)
	for i in width:
		set_cell(x-1-i, y, 4)
		set_cell(x+1+i, y, 4)
	
	for i in 2:
		drawPavement(x-width-i, y)
		drawPavement(x+width+i, y)
		
		
		
func drawHorizontalLine(point, size):
	#point = point*3
	drawHorizontalRoad(point.x-1, point.y, 4, size)
	drawHorizontalRoad(point.x, point.y, 11, size)
	drawHorizontalRoad(point.x+1, point.y, 4, size)

func drawHorizontalRoad(x, y, id, size):
	set_cell(x, y, id)
	for i in size:
		set_cell(x, y-1-i, 4)
		set_cell(x, y+1+i, 4)
	
	for i in 2:
		drawPavement(x, y-size-i)
		drawPavement(x, y+size+i)


func generateIntersections(intersections, width):
	for point in intersections:
		#point = point*3
		var size = 3+(width*2)
				
		for x in size:
			for y in size:
				set_cell(point.x+x-(size/2), point.y+y-(size/2), 4)
				
		
		for x in size:
			for y in 2:
				drawPavement(point.x+x-(size/2), point.y-(size/2)+y)
				drawPavement(point.x+x-(size/2), point.y+(size/2)-y)
				
				drawPavement(point.x-(size/2)+y, point.y+x-(size/2))
				drawPavement(point.x+(size/2)-y, point.y+x-(size/2))
		

func drawPavement(x, y):
	var cell = get_cell(x, y)
	if cell > 0 and cell != 12: return
	set_cell(x, y, 0)
	
	
var lastHousePosition = Vector2(0, 0)
func placeHouse(point, offset, rotated):
	if lastHousePosition.distance_to(point)>20:
		lastHousePosition = point
		var position = point+offset
		if get_cell(position.x, position.y) == 12:
			Constants.rand.randomize()
			var house = houseScene[0].instance()
			house.global_position = position*64
			house.global_rotation_degrees = rotated
			Globals.mapManager.add_child(house)
		
		position = point-offset
		if get_cell(position.x, position.y) == 12:
			Constants.rand.randomize()
			var house2 = houseScene[0].instance()
			house2.global_position = position*64
			house2.global_rotation_degrees = -rotated
			Globals.mapManager.add_child(house2)
