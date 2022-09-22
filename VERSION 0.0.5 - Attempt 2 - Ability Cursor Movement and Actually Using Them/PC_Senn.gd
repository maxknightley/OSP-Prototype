extends PlayerCharacter

var charName = "Senn"
# Character class, if you end up with any place to put it

# Set up ability lists and populate them with early-game abilities
var attackList = [CombatAbility.new("Splintering Blow", "A strike supremely suited for shredding armor and machines.",
				"Melee"),
				CombatAbility.new("Wide Hook", "Smash up to three nearby enemies with one nasty blow.", 
				"Melee Cardinal")]
var supportList = [CombatAbility.new("Flex", "Pump yourself up to increase attack and defense.")]

func _init():
	# Set stats
	maxHP = 240
	statusResist = 80

	baseAttack = 9
	baseDefense = 9
	baseSpeed = 5
	# Separate magic stats?

func _ready():
	pass
	
#func _process(delta):
#	pass
