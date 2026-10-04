extends PanelContainer

onready var infoContainerScene = preload("res://scene/ui/items/itemInfo/info_container.tscn")

export(NodePath) onready var item_name  = get_node(item_name) as Label
export(NodePath) onready var button  = get_node(button) as Button
export(NodePath) onready var sprite  = get_node(sprite) as TextureRect
export(NodePath) onready var description  = get_node(description) as RichTextLabel
export(NodePath) onready var sections  = get_node(sections) as VBoxContainer
export(NodePath) onready var scrollContainer  = get_node(scrollContainer) as ScrollContainer


var slot = null
var curItemId = null

func setSlot(_slot:Slot = slot):
	slot = _slot
	scrollContainer.rect_size.y = 0
	scrollContainer.rect_min_size.y = 0

func show():
	var info = slot.get_item_info()
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
	.show()
	yield(get_tree(),"idle_frame")
	scrollContainer.rect_min_size.y = clamp(scrollContainer.get_child(0).rect_size.y, 55, 350)


func _on_Button_button_up():
	if slot.use_item():
		if curItemId != slot.item.data.id: hide()
	else: hide()
