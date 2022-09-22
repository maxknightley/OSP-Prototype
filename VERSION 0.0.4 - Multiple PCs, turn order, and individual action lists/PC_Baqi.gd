extends PlayerCharacter

var charName = "Baqi"
# Character class, if you end up with any place to put it

# Set up ability lists and populate them with early-game abilities
var attackList = [CombatAbility.new("Quick Slash", "A swift strike of the sword aimed at a nearby enemy.", 
				"Melee"),
				CombatAbility.new("Vent Steam", "Blast all nearby enemies with an oppressive wave of heat.")]
var supportList = [CombatAbility.new("Deep Breathing", "Heal yourself and up your defense at the cost of attack power.")]

func _ready():
	pass
	
#func _process(delta):
#	pass
