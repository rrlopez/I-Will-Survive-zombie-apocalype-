extends Inventory


export(NodePath) onready var hand  = get_node(hand) as Slot
export(NodePath) onready var armor  = get_node(armor) as Slot
export(NodePath) onready var weapon  = get_node(weapon) as Slot

func _ready():
	slots.append(hand)
	slots.append(armor)
	slots.append(weapon)
	Globals.inventoryManager.emit_signal("inventory_ready", self)
	
func set_inventory_size(value):
	size = value


func set_column():
	pass


func _on_Hand_item_changed(handItem):
	Globals.player.setHandItem(handItem)


func _on_Armor_item_changed():
	pass # Replace with function body.


func _on_Weapon_item_changed(_weapon):
	Globals.player.setWeapon(_weapon)
