extends ColorRect

export(NodePath) onready var sprite = get_node(sprite) as TextureRect
export(NodePath) onready var label = get_node(label) as Label
export(NodePath) onready var cooldown = get_node(cooldown) as ColorRect

var items = []

func addItem(item):
	items.push_front(item)
	sprite.texture = Factory.items.itemTexture[items[0].data.id]
	cooldown.show()
	show()

func delItem(item = items[0]):
	items.erase(item)
	if items.size()<1: hide()
	else: 
		sprite.texture = Factory.items.itemTexture[items[0].data.id]
		updateText()

func setCooldown(percent, item):
	if(items[0] == item):
		percent = min(percent, 100)
		cooldown.rect_position = Vector2(60-(percent/2),92)
		cooldown.rect_scale = Vector2(percent,1)

func updateText(item = items[0]):
	if items.empty(): return
	if(items[0] == item):
		label.text = item.getInfoPanelText()
