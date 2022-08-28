extends RigidBody2D

export(NodePath) onready var sprite  = get_node(sprite) as TextureRect
export(NodePath) onready var collider  = get_node(collider) as CollisionShape2D

var data = null
var life = 20

func _ready():
	sprite.texture = Factory.items.itemTexture[data.id]
	Constants.rand.randomize()
	linear_velocity.x = Constants.rand.randf_range(-1, 1)
	Constants.rand.randomize()
	linear_velocity.y = Constants.rand.randf_range(-1, 1)
	linear_velocity*=350
	Constants.rand.randomize()
	angular_velocity = Constants.rand.randi_range(-7, 7)
	
func init(name, position):
	global_position = position
	data = Factory.items.staticData[name]
	data.quantity = 0

func _process(delta):
	life-=delta
	if(life<0): queue_free()

func add_item_quantity(value):
	var remainder = (data.quantity+value)-data.stock_size
	data.quantity = min(data.quantity+value, data.stock_size)
	return remainder


func pick_item():
	var quantity = data.quantity
	var remainder = pick_it_up()
	if remainder == 0: queue_free()
	Globals.HUD.notifs.addNotif(data.name+" x"+String(quantity-remainder))

func pick_it_up(lastQuantity=0):
	if data.quantity == lastQuantity: return data.quantity
	lastQuantity = data.quantity
	
	var item = Factory.items.create(data.id, data.quantity)
	var remainder = Globals.player.inventory.put_item(item)
	if remainder>0 :
		data.quantity=remainder
		return pick_it_up(lastQuantity)
	return remainder
	
