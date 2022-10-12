extends PlayerCharacter

var charName = "Senn"
# Character class, if you end up with any place to put it

# Set up ability lists and populate them with early-game abilities
var attackList = [CombatAbility.new("Splintering Blow", "A strike supremely suited for shredding armor and machines.",
				"Melee", "One Tile"),
				CombatAbility.new("Wide Hook", "Smash up to three nearby enemies with one nasty blow.", 
				"Melee Horizontal", "3 Column")]
var supportList = [CombatAbility.new("Flex", "Pump yourself up to increase attack and defense.",
				"Self", "One Tile")]

func _init():
	# Set stats
	maxHP = 240
	
	bleedResist = 60
	paralResist = 120
	blindResist = 80
	sealResist = 150

	baseAttack = 9
	baseDefense = 9
	baseSpeed = 5
	# Separate magic stats?

func _ready():
	pass
	
#func _process(delta):
#	pass
