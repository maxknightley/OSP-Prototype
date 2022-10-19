extends PlayerCharacter

var charName = "Baqi"
# Character class, if you end up with any place to put it

# Set up ability lists and populate them with early-game abilities
var attackList = [CombatAbility.new("Quick Slash", "A swift strike of the sword aimed at a nearby enemy.", 
				"Melee", "One Tile", false, true, 20, -1.5),
				CombatAbility.new("Knight's Lunge", "Thrust your blade at a near-ish enemy. Deals piercing damage.",
				"Knight", "One Tile", false, true, 35, -2.0),
				CombatAbility.new("Vent Steam", "Blast all nearby enemies with a wave of heat.",
				"Self", "Small Donut", false, true, 15, -1.0)]
var supportList = [CombatAbility.new("Deep Breathing", "Heal yourself and up your defense at the cost of attack power.",
				"Self", "One Tile", true, false, 30, 1.0)]

func _init():
	# Set stats
	maxHP = 220
	
	bleedResist = 150
	paralResist = 120
	blindResist = 75
	sealResist = 40

	baseAttack = 7
	baseDefense = 3
	baseSpeed = 8
	# Separate magic stats?

func _ready():
	pass
	
#func _process(delta):
#	pass
