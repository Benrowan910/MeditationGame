extends CanvasLayer
class_name HUD

var main = Main

func _open_journal() -> void:
	main.journal_hud.visible = true
	main.hud.visible = false

func _open_inventory() -> void:
	main.inventory_hud.visible = true
	main.hud.visible = false
