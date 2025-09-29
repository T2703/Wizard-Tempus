extends Control

# Spell selection
@export var starting_spells: Array[Spell]
var selected_spell: Spell = null

# Menu nodes.
@onready var stats_label: Label = $Stats
@onready var confirm_button: Button = $Confirmation
@onready var spell_list: VBoxContainer = $SpellList

func _ready():
	for spell in starting_spells:
		var btn := Button.new()
		btn.text = spell.name
		btn.pressed.connect(func():
			_on_spell_selected(spell)
		)
		spell_list.add_child(btn)
	
	confirm_button.disabled = true

func _on_spell_selected(spell: Spell):
	selected_spell = spell
	stats_label.text = """
		Damage: %d
		Mana Cost: %d
		Cooldown: %.2f
		Speed: %.1f
		Crit Chance: %.0f%%
		Crit Multiplier: x%.1f
	""" % [
		spell.damage,
		spell.mana_cost,
		spell.cool_down_rate,
		spell.speed,
		spell.crit_chance_var * 100.0,
		spell.crit_multipier
	]
	confirm_button.disabled = false


func _on_confirm_pressed() -> void:
	GameState.starting_spell = selected_spell
	get_tree().change_scene_to_file("res://scenes/Levels/starting_room.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/menu.tscn")
