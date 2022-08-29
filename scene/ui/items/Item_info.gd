class_name ItemInfoWindow extends Control


export(NodePath) onready var item_name  = get_node(item_name) as Label
export(NodePath) onready var button  = get_node(button) as Button
export(NodePath) onready var sprite  = get_node(sprite) as TextureRect
export(NodePath) onready var description  = get_node(description) as RichTextLabel

var slot = null
var curItemId = null

func display(_slot:Slot = slot):
	slot = _slot
	var info = _slot.get_item_info()
	item_name.text = info.staticData.name
	curItemId = info.staticData.id
	sprite.texture = Factory.items.itemTexture[curItemId]
	description.text = info.staticData.description
	
	if(info.has("btnText")):
		button.text = info.btnText
		button.show()
	else: button.hide()
	show()
	


func _on_Button_button_up():
	if slot.use_item():
		if curItemId != slot.item.data.id: hide()
	else: hide()
