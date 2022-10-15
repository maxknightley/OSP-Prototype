extends EnemyEntity

var charName = "Generic Test Enemy"

func _init():
	# Set stats
	maxHP = 80
	
	bleedResist = 50
	paralResist = 50
	blindResist = 50
	sealResist = 50

	baseAttack = 3
	baseDefense = 2
	baseSpeed = 6
	# Separate magic stats?
	
	# Set up and populate ability lists
	attackList = [CombatAbility.new("Quick Slash", "A swift strike of the sword aimed at a nearby enemy.", 
				"Melee", "One Tile", false, true, 20, -1.5),
				CombatAbility.new("Super Knight's Lunge", "Thrust your blade at a near-ish enemy. Deals piercing damage.",
				"Knight", "3x3", false, true, 35, -2.0)]
	specialList = [CombatAbility.new()]

func _ready():
	pass # Replace with function body.

#func _process(delta):
#	pass

# This enemy has no support skill yet, but I want to make sure overriding the generic function works.
#func ai_specialSkillReview(charlist):
#	print("Enemy ESPECIALLY has no support skills. We checked.")
#	return false
