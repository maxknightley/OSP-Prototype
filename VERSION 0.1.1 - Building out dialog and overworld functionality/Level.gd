extends Node2D

# Declare member variables here. Examples:
var isReading = false
var activeText = false
var lineIndex = 0
# var charIndex = 0 - This, or something like it, could eventually be used to make dialog show up a letter at a time.

# We'll use this to call actions at the end of a dialog or cutscene sequence.
var dialogAction = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$DialogDisplay/DialogBox.hide()
	$DialogDisplay/SpeakerNameBox.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# If the player is currently reading, and they press the "accept" button, advance the dialog one line &
	# refresh what's being shown.
	if activeText && Input.is_action_just_pressed("ui_accept"):
		lineIndex += 1
		dialogHandler()

# This signal is received when the player successfully interacts with our test NPC.
# Along with all other NPC signals, it should initialize and display dialog.
func _on_Sign_sendTextToDisplay(sourceText, actionOnComplete):
	initDialog(sourceText, actionOnComplete)

# All actions that initiate dialog in the overworld should go HERE.
# It initializes DialogDisplay's text, shows it, and prevents the player from moving.
func initDialog(sourceText, actionOnComplete):
	# If activeText is already set OR if we've just finished reading a dialog sequence, ignore this signal.
	if activeText || isReading: return
	
	# Otherwise...
	# Prevent "double-reading," moving during dialog, etc.
	isReading = true
	$OW_Leader.canMove = false
	
	# Initialize the text so we can read it properly.
	activeText = sourceText
	lineIndex = 0
	# charIndex = 0
	# Display the dialog box.
	$DialogDisplay/DialogBox.show()
	
	# If an actionOnComplete has been defined, we'll call it at the end of the dialog.
	dialogAction = actionOnComplete
	
	# Start actually processing/displaying the dialog.
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
		$DialogDisplay/SpeakerNameBox.hide()
		$DialogDisplay/SpeakerNameBox/RichTextLabel.text = ""
		$DialogDisplay/TalkspritesFG/AnimationPlayer/TalkspriteRightF.hide()
		$DialogDisplay/TalkspritesFG/AnimationPlayer/TalkspriteLeftF.hide()
		
		$OW_Leader.canMove = true
		$DialogCooldown.start()
		
		# If a dialogAction has been set, run it now.
		if dialogAction: runDialogAction()
		
		return
	# If we HAVEN'T passed the final line, load up the next line of dialog!
	else:
		# Lines of dialog are set up as arrays containing:
		# 1. Text for the dialog box, 2. a talksprite (optional), and 3. a position for the talksprite if one exists.
		# First, let's update the text...
		if activeText[lineIndex][0]:
			$DialogDisplay/SpeakerNameBox/RichTextLabel.text = activeText[lineIndex][0]
			$DialogDisplay/SpeakerNameBox.show()
		else: $DialogDisplay/SpeakerNameBox.hide()
		$DialogDisplay/DialogBox/RichTextLabel.text = activeText[lineIndex][1]
		
		# And next, if there's a talksprite, let's update that!
		match activeText[lineIndex][3]:
			"RF":
				var tsprite = $DialogDisplay/TalkspritesFG/AnimationPlayer/TalkspriteRightF
				
				match activeText[lineIndex][4]:
					"fade in hop":
						tsprite.texture = load(activeText[lineIndex][2])
						tsprite.modulate.a = 0.0
						tsprite.show()
						$DialogDisplay/TalkspritesFG/AnimationPlayer.play("fade in hop RF")
						return
					"fade in":
						tsprite.texture = load(activeText[lineIndex][2])
						tsprite.modulate.a = 0.0
						tsprite.show()
						$DialogDisplay/TalkspritesFG/AnimationPlayer.play("slow fade in RF")
						return
					"hop":
						tsprite.texture = load(activeText[lineIndex][2])
						$DialogDisplay/TalkspritesFG/AnimationPlayer.play("hop RF")
						return
				
				# If no other animation was called, just make sure we're displaying the talksprite.
				tsprite.texture = load(activeText[lineIndex][2])
				tsprite.modulate.a = 1.0
				tsprite.show()
			"LF":
				var tsprite = $DialogDisplay/TalkspritesFG/AnimationPlayer/TalkspriteLeftF
				
				match activeText[lineIndex][4]:
					"fade in hop":
						tsprite.texture = load(activeText[lineIndex][2])
						tsprite.modulate.a = 0.0
						tsprite.show()
						$DialogDisplay/TalkspritesFG/AnimationPlayer.play("fade in hop LF")
						return
					"fade in":
						tsprite.texture = load(activeText[lineIndex][2])
						tsprite.modulate.a = 0.0
						tsprite.show()
						$DialogDisplay/TalkspritesFG/AnimationPlayer.play("slow fade in LF")
						return
					"hop":
						tsprite.texture = load(activeText[lineIndex][2])
						tsprite.show()
						$DialogDisplay/TalkspritesFG/AnimationPlayer.play("hop LF")
						return
				
				# If no other animation was called, just make sure we're displaying the talksprite.
				tsprite.texture = load(activeText[lineIndex][2])
				tsprite.modulate.a = 1.0
				tsprite.show()

func _on_DialogCooldown_timeout():
	isReading = false

# When called, runs a particular function based on the value of dialogAction.
# We'll want to override this w/ different function calls in any "real" level. This is a generic one.
func runDialogAction():
	if dialogAction == "test battle":
		initiateBattle(load("res://ExampleBattle.tscn").instance(), $CombatThemePlayer,
			[["Baqi", "Alright. Combat has been TESTED. And yet...", "res://Assets/baqi_placeholder_talksprite.png", "LF", "false"],
			["Baqi", "My sword still hungers...", false, false, "hop"]])

# When called, hide + deactivate everything in the overworld and begin the selected battle.
func initiateBattle(battleScene, bAudioStream, battleCompletionText):
	$Sign.active = false
	
	$FadeOutSuperFG/AnimationPlayer.play("FadeToWhite")
	yield($FadeOutSuperFG/AnimationPlayer, "animation_finished")
	$FadeOutSuperFG/AnimationPlayer.play_backwards("FadeToWhite")
	
	$Sign.hide()
	$Sign/AnimatedSprite.play("default")
	$OW_Leader.hide()
	$OW_Leader.canMove = false
	$TestFloor.hide()
	$CombatThemePlayer.volume_db = 0
	
	get_tree().get_root().add_child(battleScene)
	bAudioStream.play()
	yield(battleScene.get_node("Battlefield"), "victory")
	
	# On victory, fade out the battle music, unload the scene, and show all the level assets again.
	audio_video_fadeout(bAudioStream)
	yield($FadeOutSuperFG/AnimationPlayer, "animation_finished")
	get_tree().get_root().remove_child(battleScene)
	$Sign.show()
	$OW_Leader.show()
	$TestFloor.show()
	$FadeOutSuperFG/AnimationPlayer.play_backwards("FadeToBlack")

	# Finally, display battleCompletionText - if it exists - to move the story forward.
	if battleCompletionText: _on_Sign_sendTextToDisplay(battleCompletionText, "do nothing")

# Fades audio and visuals out when a smooth transition is desired, e.g., after the end of combat
# TBD - add "start/fade in other audio" feature?
func audio_video_fadeout(streamPlayer):
	$FadeOutSuperFG/AnimationPlayer.play("FadeToBlack")
	
	var aud_tween = Tween.new()
	aud_tween.interpolate_property(streamPlayer, "volume_db", 0, -80,
		3.75, 1, Tween.EASE_IN, 0)
	add_child(aud_tween)
	aud_tween.start()
