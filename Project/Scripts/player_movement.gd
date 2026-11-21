extends CharacterBody3D

@export var animation : AnimationPlayer
@export var movement_speed = 5.0

# Get the gravity from the project settings to be synced with RigidBody nodes.

func _physics_process(delta):
	var input_dir = Input.get_vector("Left", "Right", "Up", "Down").rotated(deg_to_rad(45))
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		animation.play("anim_walk")
		velocity.x = direction.x * movement_speed
		velocity.z = direction.z * movement_speed
	else:
		animation.play("anim_idle")
		velocity.x = move_toward(velocity.x, 0, movement_speed)
		velocity.z = move_toward(velocity.z, 0, movement_speed)

	move_and_slide()
