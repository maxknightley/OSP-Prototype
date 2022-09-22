# Most of the actual code is handled by the generic Battle_Archetype script.
# Use specific scripts to do encounter-specific stuff.
extends Encounter_OnFoot

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add all the relevant characters to the characterArray, and distribute them across the field.
	characterArray.append($PC_Baqi)
	characterArray[0].gridIndex = Vector2.ZERO
	characterArray.append($PC_RaKit)
	characterArray[1].gridIndex = Vector2(3,5)
	characterArray.append($PC_Senn)
	characterArray[2].gridIndex = Vector2(5,2)
	characterArray.append($NPC_ExEnemy)
	characterArray[3].gridIndex = Vector2(4,0)
	
	# Initialize timeToNextTurn for all characters, then hand over control to the fastest one.
	activeCharacter = characterArray[0]
	for character in characterArray:
		character.timeToNextTurn = 100
		character.timeToNextTurn -= character.baseSpeed
		if character.timeToNextTurn < activeCharacter.timeToNextTurn:
			activeCharacter = character
			
	populateSkillMenus()
	
	print("Prototype battle initiated!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
