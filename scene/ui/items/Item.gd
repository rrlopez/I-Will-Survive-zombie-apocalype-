class_name Item extends TextureRect

export(String) var id
export(String) var item_name
var label_quantity

var staticData = {}
var data = {}

var cooldownTimer = 0
var sweep

func init(itemData, _staticData):
	data = itemData
	staticData = _staticData


func _ready():
	texture = Factory.items.itemTexture[data.id]
	label_quantity = Label.new()
	label_quantity.set("custom_fonts/font", Constants.fonts[16])
	label_quantity.set("custom_colors/font_color", Color.black)
	add_child(label_quantity)
	set_quantity(data.quantity)
	add_child(Constants.itemArea.instance())
	
	
	sweep = TextureProgress.new()
	sweep.fill_mode = 5
	sweep.value = 0
	sweep.nine_patch_stretch = true
	sweep.texture_progress = Constants.itemCooldownTexture
	sweep.rect_size =  get_parent().rect_size
	sweep.modulate = Color(0, 0, 0, 0.3)
	sweep.rect_position = Vector2.ZERO
	add_child(sweep)
	
	set_process(false)
	

func _process(delta):
	cooldownTimer+=delta
	
	if cooldownTimer>staticData.cooldown:
		sweep.value=0
		set_process(false)
		return
		
	sweep.value = int((cooldownTimer/staticData.cooldown)*100)

func set_quantity(value):
	data.quantity = value
	if(label_quantity):
		label_quantity.text = str(value)
		label_quantity.visible = staticData.stock_size > 1


func add_item_quantity(value):
	var remainder = max((data.quantity+value)-staticData.stock_size, 0)
	set_quantity(min(data.quantity+value, staticData.stock_size))
	return remainder

func use():
	if sweep.value > 0: return true
	set_process(true)
	cooldownTimer = 0
	return false
	
func getInfo():
	return {
		"staticData": staticData,
		"sections": []
	}
	
func serialize():
	return data

func deserialize(savedData):
	data.quantity = savedData.quantity

