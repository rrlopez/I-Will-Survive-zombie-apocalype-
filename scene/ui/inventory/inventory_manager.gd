extends Node

signal inventory_opened
signal inventory_ready

export(NodePath) onready var item_in_hand_node  = get_node(item_in_hand_node) as Control
export(NodePath) onready var item_info  = get_node(item_info) as Control

var panels: Array = []
var inventories: Array = []
var clickPosition = null
var cur_inventory = null
var cur_slot = null
var prev_slot = null
var item_in_hand = null
var item_offset = Vector2.ZERO
var lastTap = 0

var panelPressed = null

func _init(): 
	Globals.inventoryManager = self

func _ready():
	connect("inventory_ready", self, "_on_inventory_ready")
	
	
func _on_inventory_ready(inventory):
	inventories.append(inventory)
	if inventory.slot_type == 'hotbar':
		for slot in inventory.slots:
			slot.connect("gui_input", self, "_on_gui_input_slot", [slot])
	else:
		for slot in inventory.slots:
			slot.connect("mouse_entered", self, "_on_mouse_entered_slot", [slot])
			slot.connect("mouse_exited", self, "_on_mouse_exited_slot")
			slot.connect("gui_input", self, "_on_gui_input_slot", [slot])
		

func _input(event:InputEvent):
	if(item_in_hand):
		if event is InputEventScreenDrag and panelPressed == event.index: item_in_hand.rect_position = event.position
				
		if event is InputEventScreenTouch and panelPressed == event.index and !event.is_pressed():
			item_in_hand_node.mouse_filter = item_in_hand_node.MOUSE_FILTER_IGNORE
			if(cur_slot): 
				if item_in_hand.staticData.has("equipment_type") and (cur_slot.type or item_in_hand.staticData.equipment_type == "craft") and item_in_hand.staticData.equipment_type != cur_slot.type: 
					item_in_hand_node.remove_child(item_in_hand)
					prev_slot.put_item(item_in_hand)
					item_in_hand = null
				else: updateSlot(event, cur_slot)
			elif prev_slot:
				item_in_hand_node.remove_child(item_in_hand)
				prev_slot.put_item(item_in_hand)
				item_in_hand = null
			prev_slot.emitItemChanged()
			prev_slot = null
	elif clickPosition and event is InputEventScreenDrag and event.position.distance_to(clickPosition)>10: 
		item_in_hand_node.mouse_filter = item_in_hand_node.MOUSE_FILTER_STOP
		clickPosition = null
		updateSlot(event, prev_slot)
	elif event is InputEventScreenTouch:
		if event.is_pressed(): 
			if (OS.get_ticks_msec()-lastTap)<300 and prev_slot:
				prev_slot.use_item()
				yield(get_tree(), "idle_frame")
				prev_slot = null
			lastTap = OS.get_ticks_msec()
			
		else: clickPosition = null
	

#if(prev_slot.item.data.static.equipment_type != "craft"): 
func _on_mouse_entered_slot(slot):
	if(slot.item):
		item_info.display(slot)

func _on_mouse_exited_slot():
	item_info.hide()
	

func _on_gui_input_slot(event: InputEvent, slot: Slot):
	if event is InputEventScreenTouch and event.is_pressed() and slot.item:
		panelPressed = event.index
		clickPosition = slot.get_global_mouse_position()
		prev_slot = slot


func updateSlot(event, slot):
	if item_in_hand:
		item_in_hand_node.remove_child(item_in_hand)
	
		if slot.item:
			if(slot.item.data.id == item_in_hand.data.id) and slot.item.data.quantity < slot.item.staticData.stock_size:
				var remainder = slot.item.add_item_quantity(item_in_hand.data.quantity)
				if remainder > 0:
					item_in_hand.set_quantity(remainder)
					prev_slot.put_item(item_in_hand)
				item_in_hand=null
			else:
				var temp_item = slot.item
				slot.pick_item()
				temp_item.rect_global_position = event.position
				slot.put_item(item_in_hand)
				prev_slot.put_item(temp_item)
				item_in_hand=null
		else:
			slot.put_item(item_in_hand)
			item_in_hand = null
		
	elif slot.item:
		item_in_hand = slot.item
		slot.pick_item()
		item_in_hand.rect_global_position = slot.rect_global_position + event.position
		item_in_hand_node.add_child(item_in_hand)


func show():
	for panel in panels:
		panel.show()

func hide():
	item_info.hide()
	for panel in panels:
		panel.close()
