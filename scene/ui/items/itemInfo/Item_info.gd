extends PanelContainer

export(NodePath) onready var item_name  = get_node(item_name) as Label
export(NodePath) onready var button  = get_node(button) as Button
export(NodePath) onready var sprite  = get_node(sprite) as TextureRect
export(NodePath) onready var description  = get_node(description) as RichTextLabel
export(NodePath) onready var sections  = get_node(sections) as VBoxContainer


var slot = null
var curItemId = null

func display(_slot:Slot = slot):
	slot = _slot
	var info = _slot.get_item_info()
	item_name.text = info.staticData.name
	curItemId = info.staticData.id
	sprite.texture = Factory.items.itemTexture[curItemId]
	description.text = info.staticData.description
	
	for section in sections.get_children(): section.queue_free()
	for section in info.sections:
		var infoSection = Constants.infoSectionScene.instance()
		infoSection.info = section
		sections.add_child(infoSection)
		
	
	if(info.has("btnText")):
		button.text = info.btnText
		button.show()
	else: button.hide()
	
	sections.rect_size.y = min(sections.rect_size.y, 100)
	print(sections.rect_size)
	show()
	


func _on_Button_button_up():
	if slot.use_item():
		if curItemId != slot.item.data.id: hide()
	else: hide()
