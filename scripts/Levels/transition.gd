extends CanvasLayer
@onready var anim = $Wipe

func play_wipe_in(callback: Callable):
	visible = true
	anim.play("wipe_in")
	
	# Call scene change.
	callback.call()
	
	anim.animation_finished.connect(func(name):
		if name == "wipe_in":
			visible = false
	, CONNECT_ONE_SHOT)
