class_name Item extends TextureRect

export(String) var id
export(String) var item_name
var label_quantity

var staticData = {}
var data = {}

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
	return self
	
func serialize():
	return data

func deserialize(savedData):
	data.quantity = savedData.quantity
