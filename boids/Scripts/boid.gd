extends CharacterBody2D

var maxVelocity = 250

var attractionAttenuation = 100
var repulsionAttenuation = 5
var followAttenuation = 40
var obstacleRepulsionAttenuation = 5

var obstaclesInSight : Array

"Return the distance from another boid"
func distance(boid):
	var distX = self.global_position.x - boid.global_position.x
	var distY = self.global_position.y - boid.global_position.y 
	return sqrt(distX * distX + distY * distY)

"Move closer to a set of boids"
func moveCloser(boids):
	if len(boids) < 1: return
		
	# calculate the average distances from the other boids
	var avgX = 0
	var avgY = 0
	for boid in boids:
		if boid.global_position.x == self.global_position.x and boid.global_position.y == self.global_position.y:
			continue
			
		avgX += (self.global_position.x - boid.global_position.x)
		avgY += (self.global_position.y - boid.global_position.y)

	avgX /= len(boids)
	avgY /= len(boids)

	# set our velocity towards the others
   
	velocity.x -= (avgX / attractionAttenuation) 
	velocity.y -= (avgY / attractionAttenuation) 
	
"Move with a set of boids"
func moveWith(boids):
	if len(boids) < 1: return
	# calculate the average velocities of the other boids
	var avgX = 0
	var avgY = 0
			
	for boid in boids:
		avgX += boid.velocity.x
		avgY += boid.velocity.y

	avgX /= len(boids)
	avgY /= len(boids)

	# set our velocity towards the others
	velocity.x += (avgX / followAttenuation)
	velocity.y += (avgY / followAttenuation)

"Move away from a set of boids. This avoids crowding"
func moveAway(boids, minDistance):
	if len(boids) < 1: return
	
	var distanceX = 0
	var distanceY = 0
	var numClose = 0

	for boid in boids:
		var distance = self.distance(boid)
		if  distance < minDistance:
			numClose += 1
			var xdiff = (self.global_position.x - boid.global_position.x) 
			var ydiff = (self.global_position.y - boid.global_position.y) 
			
			if xdiff >= 0: xdiff = sqrt(minDistance) - xdiff
			elif xdiff < 0: xdiff = -sqrt(minDistance) - xdiff
			
			if ydiff >= 0: ydiff = sqrt(minDistance) - ydiff
			elif ydiff < 0: ydiff = -sqrt(minDistance) - ydiff

			distanceX += xdiff 
			distanceY += ydiff 
	
	if numClose == 0:
		return
		
	self.velocity.x -= distanceX / repulsionAttenuation
	self.velocity.y -= distanceY / repulsionAttenuation
	

func moveAwayFromObstacle(minDistance):
	if len(obstaclesInSight) < 1: return
	
	var distanceX = 0
	var distanceY = 0
	
	for obstacle in obstaclesInSight:
		var xdiff = (self.global_position.x - obstacle.global_position.x) 
		var ydiff = (self.global_position.y - obstacle.global_position.y) 
		
		if xdiff >= 0: xdiff = sqrt(minDistance) - xdiff
		elif xdiff < 0: xdiff = -sqrt(minDistance) - xdiff
		
		if ydiff >= 0: ydiff = sqrt(minDistance) - ydiff
		elif ydiff < 0: ydiff = -sqrt(minDistance) - ydiff
		
		
		distanceX += xdiff 
		distanceY += ydiff 
	
	self.velocity.x -= distanceX / repulsionAttenuation
	self.velocity.y -= distanceY / repulsionAttenuation

"Perform actual movement based on our velocity"

func move():
	if abs(self.velocity.x) > maxVelocity or abs(self.velocity.y) > maxVelocity:
		var scaleFactor = maxVelocity / max(abs(self.velocity.x), abs(self.velocity.y))
		self.velocity.x *= scaleFactor
		self.velocity.y *= scaleFactor
	
	#Ensure we don't go out of the window
	var borderRight = 1920
	var borderBottom = 1080
	
	if self.global_position.x >= borderRight:
		self.global_position.x = 400
	elif self.global_position.x < 400:
		self.global_position.x = borderRight - 5
	
	if self.global_position.y >= borderBottom:
		self.global_position.y = 0
	elif self.global_position.y < 0:
		self.global_position.y = borderBottom - 5

	move_and_slide()
	
	#self.global_position.x += self.velocity.x
	#self.global_position.y += self.velocity.y

func _init() -> void:
	velocity.x = randi_range(1, 10) / 10.0
	velocity.y = randi_range(1, 10) / 10.0

func _ready() -> void:
	var velocitySlider = get_tree().get_nodes_in_group("velocitySlider")
	velocitySlider.front().connect("value_changed", func(value): maxVelocity = value)
	
	var attractionSlider = get_tree().get_nodes_in_group("attractionSlider")
	attractionSlider.front().connect("value_changed", func(value): attractionAttenuation = value)
	
	var repulsionSlider = get_tree().get_nodes_in_group("repulsionSlider")
	repulsionSlider.front().connect("value_changed", func(value): repulsionAttenuation = value)
	
	var followSlider = get_tree().get_nodes_in_group("followSlider")
	followSlider.front().connect("value_changed", func(value): followAttenuation = value)
	
	var obsRepulsionSlider = get_tree().get_nodes_in_group("obstacleRepulsionSlider")
	obsRepulsionSlider.front().connect("value_changed", func(value): obstacleRepulsionAttenuation = value)
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	var closeBoids = []

	for otherBoid in get_tree().get_nodes_in_group("boidGroup"):
		if otherBoid == self: continue
		var distance = self.distance(otherBoid)
		if distance < 200:
			closeBoids.append(otherBoid)
	
	self.moveCloser(closeBoids)
	self.moveWith(closeBoids)  
	self.moveAway(closeBoids, 20) 
	self.moveAwayFromObstacle(10)
	
	velocity *= 10000
	
	self.move()
	pass


# ---- Signals ---


# Obstacle detection
func _on_detection_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("obstacles"):
		obstaclesInSight.append(area.get_parent())
	pass # Replace with function body.


func _on_detection_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("obstacles"):
		obstaclesInSight.erase(area.get_parent())
	pass # Replace with function body.
