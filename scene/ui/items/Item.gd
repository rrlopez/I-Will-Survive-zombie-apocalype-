class_name Item extends TextureRect

export(String) var id
export(String) var item_name
var label_quantity

var data = {}

func init(itemData):
	data = itemData
	if(data.has("base_stats")): data["base_stats"] = Base_stat.new(data["base_stats"], randf())

func _ready():
	texture = data.static.texture
	label_quantity = Label.new()
	label_quantity.set("custom_fonts/font", Constants.fonts[16])
	label_quantity.set("custom_colors/font_color", Color.black)
	add_child(label_quantity)
	set_quantity(data.quantity)

func set_quantity(value):
	data.quantity = value
	if(label_quantity):
		label_quantity.text = str(value)
		label_quantity.visible = data.static.stock_size > 1


func add_item_quantity(value):
	var remainder = max((data.quantity+value)-data.static.stock_size, 0)
	set_quantity(min(data.quantity+value, data.static.stock_size))
	return remainder

func use():
	return self
