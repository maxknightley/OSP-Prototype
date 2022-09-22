extends PlayerCharacter

var charName = "Ra'Kit"
# Character class, if you end up with any place to put it

# Set up ability lists and populate them with early-game abilities
var attackList = [CombatAbility.new("Shrill Trill", "Does a little damage to all nearby enemies and lowers their defense."),
				CombatAbility.new("Throw Dirt", "Deals minimal damage to an enemy at range. Can inflict Blind.", 
				"Long Range")]
var supportList = [CombatAbility.new("Look Over There!", "The target will step away, but won't take any damage."),
				CombatAbility.new(),
				CombatAbility.new()]

func _ready():
	pass
	
#func _process(delta):
#	pass
