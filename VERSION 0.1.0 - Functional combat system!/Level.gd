extends Node2D

# Declare member variables here. Examples:
var isReading = false
var activeText = false
var lineIndex = 0
# var charIndex = 0 - This, or something like it, could eventually be used to make dialog show up a letter at a time.

#####
var dialogAction = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$DialogDisplay/DialogBox.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If the player is currently reading, and they press the "accept" button, advance the dialog one line &
	# refresh what's being shown.
	if activeText && Input.is_action_just_pressed("ui_accept"):
		lineIndex += 1
		dialogHandler()

# This signal is received when the player successfully interacts with an NPC or noteworthy object.
# It initializes DialogDisplay's text, shows it, and prevents the player from moving.
func _on_Sign_sendTextToDisplay(sourceText, actionOnComplete):
	# If activeText is already set OR if we've just finished reading a dialog sequence, ignore this signal.
	if activeText || isReading: return
	
	#####
	isReading = true
	$OW_Leader.canMove = false
	
	#####
	activeText = sourceText
	lineIndex = 0
	# charIndex = 0
	$DialogDisplay/DialogBox.show()
	
	#####
	dialogAction = actionOnComplete
	
	#####
	dialogHandler()

# Once DialogDisplay has been populated, this function allows the player to read through the text it's received.
# Once they've finished reading, they regain control and the DialogDisplay is hidden.
func dialogHandler():
	# If we've passed the final line, the exchange is over.
	# Reset our text-handling variables, hide DialogDisplay, allow the player to move again, and start a brief
	# timer until they can read anything else (to avoid getting stuck in a loop).
	if lineIndex >= activeText.size():
		lineIndex = 0
		# charIndex = 0
		activeText = false
		
		$DialogDisplay/DialogBox.hide()
		$DialogDisplay/DialogBox/RichTextLabel.text = ""
		$DialogDisplay/TalkspritesFG/TalkspriteRightF.hide()
		$DialogDisplay/TalkspritesFG/TalkspriteLeftF.hide()
		
		$OW_Leader.canMove = true
		$DialogCooldown.start()
		
		#####
		if dialogAction == "test battle": 
			initiateBattle(load("res://ExampleBattle.tscn").instance(), $CombatThemePlayer,
				[["Alright. Combat has been TESTED. And yet...", "res://Assets/baqi_placeholder_talksprite.png", "LF"],
				["My sword still hungers...", false, false]])
		
		return
	# If we HAVEN'T passed the final line, load up the next line of dialog!
	else:
		# Lines of dialog are set up as arrays containing:
		# 1. Text for the dialog box, 2. a talksprite (optional), and 3. a position for the talksprite if one exists.
		# First, let's update the text...
		$DialogDisplay/DialogBox/RichTextLabel.text = activeText[lineIndex][0]
		
		# And next, if there's a talksprite, let's update that!
		match activeText[lineIndex][2]:
			"RF":
				$DialogDisplay/TalkspritesFG/TalkspriteRightF.texture = load(activeText[lineIndex][1])
				$DialogDisplay/TalkspritesFG/TalkspriteRightF.show()
			"LF":
				$DialogDisplay/TalkspritesFG/TalkspriteLeftF.texture = load(activeText[lineIndex][1])
				$DialogDisplay/TalkspritesFG/TalkspriteLeftF.show()

func _on_DialogCooldown_timeout():
	isReading = false

# When called, hide + deactivate everything in the overworld and begin the selected battle.
# TBD - PROPER SCENE TRANSITION, AUDIO FADEOUT
func initiateBattle(battleScene, bAudioStream, battleCompletionText):
	$Sign.hide()
	$Sign.active = false
	$OW_Leader.hide()
	$OW_Leader.canMove = false
	$TestFloor.hide()
	
	get_tree().get_root().add_child(battleScene)
	bAudioStream.play()
	yield(battleScene.get_node("Battlefield"), "victory")
	
	# On victory, stop the battle music, unload the scene, and show all the level assets again.
	bAudioStream.stop()
	get_tree().get_root().remove_child(battleScene)
	$Sign.show()
	$OW_Leader.show()
	$TestFloor.show()

	# Finally, display battleCompletionText - if it exists - to move the story forward.
	if battleCompletionText: _on_Sign_sendTextToDisplay(battleCompletionText, "do nothing")
