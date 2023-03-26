extends KinematicBody2D


var wheel_base = 70 # Distance from front to rear wheel
var steering_angle = 15 # Amount that front wheel turns, in degrees
var engine_power = 800 # Forward acceleration force.
var braking_power = -450 # Braking force.
var max_speed_reverse = 250 # Maximum speed when reversing.
var slip_speed = 400 # Speed where traction is reduced
var traction_fast = 0.1 # High-speed traction
var traction_slow = 0.7 # Low-speed traction
var friction = -0.9 # Coefficient of friction.
var drag = -0.0015 # Coefficient of air resistance.

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var steer_angle = 0

func _physics_process(delta):
	get_input()
	calculate_steering(delta)
	update_velocity(delta)
	move_and_slide(velocity)

func get_input():
	var turn = 0
	if Input.is_action_pressed("steer_right"):
		turn += 1
	if Input.is_action_pressed("steer_left"):
		turn -= 1
	steer_angle = turn * deg2rad(steering_angle)
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking_power

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = new_heading.dot(velocity.normalized())
	if d > 0:
		velocity = velocity.linear_interpolate(new_heading * velocity.length(), traction)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	rotation = new_heading.angle()

func update_velocity(delta):
	acceleration += calculate_friction_and_drag()
	velocity += acceleration * delta
	acceleration = Vector2.ZERO
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	rotation = velocity.angle()

func calculate_friction_and_drag():
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	if velocity.length() < 100:
		friction_force *= 3
	return drag_force + friction_force
