extends EnemyEntity

var charName = "Generic Test Enemy"

# Set up and populate ability lists
var attackList = [CombatAbility.new()]
var supportList = [CombatAbility.new()]

func _init():
	# Set stats
	maxHP = 80
	statusResist = 50

	baseAttack = 3
	baseDefense = 2
	baseSpeed = 6
	# Separate magic stats?

func _ready():
	pass # Replace with function body.

#func _process(delta):
#	pass
