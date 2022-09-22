extends PlayerCharacter

var charName = "Senn"
# Character class, if you end up with any place to put it

# Set up ability lists and populate them with early-game abilities
var attackList = [CombatAbility.new("Splintering Blow", "A strike supremely suited for shredding armor and machines."),
				CombatAbility.new("Wide Hook", "Smash up to three nearby enemies with one nasty blow.",
				1, 1, true, true, false)]
var supportList = [CombatAbility.new("Flex", "Pump yourself up to increase attack and defense.",
				0, 0)]

func _ready():
	pass
	
#func _process(delta):
#	pass