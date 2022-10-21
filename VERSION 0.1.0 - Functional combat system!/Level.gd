extends Node2D

# Declare member variables here. Examples:
var isReading = false
var activeText = false
var lineIndex = 0
# var charIndex = 0 - This, or something like it, could eventually be used to make dialog show up a letter at a time.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if activeText: dialogHandler()

# This signal is received when the player successfully interacts with an NPC or noteworthy object.
# It initializes DialogDisplay's text, shows it, and prevents the player from moving.
func _on_Sign_sendTextToDisplay(sourceText):
	# If activeText is already set OR if we've just finished reading a dialog sequence, ignore this signal.
	if activeText || isReading: return
	
	#####
	isReading = true
	$OW_Leader.canMove = false
	
	#####
	activeText = sourceText
	lineIndex = 0
	# charIndex = 0
	$DialogDisplay.show()

# Once DialogDisplay has been populated, this function allows the player to read through the text it's received.
# Once they've finished reading, they regain control and the DialogDisplay is hidden.
func dialogHandler():
	# When the player presses the "accept" button, advance the text one line.
	if Input.is_action_just_pressed("ui_accept"):
		lineIndex += 1
		
	# When we pass the final line, the exchange is over.
	# Reset our text-handling variables, hide DialogDisplay, allow the player to move again, and start a brief
	# timer until they can read anything else (to avoid getting stuck in a loop).
	if lineIndex >= activeText.size():
		lineIndex = 0
		# charIndex = 0
		activeText = false
		
		$DialogDisplay.hide()
		$DialogDisplay/RichTextLabel.text = ""
		$OW_Leader.canMove = true
		$DialogCooldown.start()
		return
	# If we HAVEN'T passed the final line, just load up the next line of dialog!
	else:
		$DialogDisplay/RichTextLabel.text = activeText[lineIndex]

func _on_DialogCooldown_timeout():
	isReading = false
