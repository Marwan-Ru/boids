extends CharacterBody2D

var direction : Vector2
@export
var maxVelocity = 250

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
   
	velocity.x -= (avgX / 100) 
	velocity.y -= (avgY / 100) 
	
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
	velocity.x += (avgX / 40)
	velocity.y += (avgY / 40)

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
		
	self.velocity.x -= distanceX / 5
	self.velocity.y -= distanceY / 5
	
"Perform actual movement based on our velocity"

func move():
	if abs(self.velocity.x) > maxVelocity or abs(self.velocity.y) > maxVelocity:
		var scaleFactor = maxVelocity / max(abs(self.velocity.x), abs(self.velocity.y))
		self.velocity.x *= scaleFactor
		self.velocity.y *= scaleFactor
	
	#Ensure we don't go out of the window
	var borderRight = 1920
	var borderBottom = 1080
	if self.global_position.x < 0 and self.velocity.x > 0:
		self.velocity.x = -self.velocity.x * randi()
	if self.global_position.x > borderRight and self.velocity.x < 0:
		self.velocity.x = -self.velocity.x * randi()
	if self.global_position.y < 0 and self.velocity.y > 0:
		self.velocity.y = -self.velocity.y * randi()
	if self.global_position.y > borderBottom and self.velocity.y < 0:
		self.velocity.y = -self.velocity.y * randi()	

	move_and_slide()
	
	#self.global_position.x += self.velocity.x
	#self.global_position.y += self.velocity.y

func _init() -> void:
	velocity.x = randi_range(1, 10) / 10.0
	velocity.y = randi_range(1, 10) / 10.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# direction = direction.rotated(0.1)
	#self.rotate(0.1)
	#self.translate(direction * delta * speed)
	
	velocity *= 10000
	
	self.move()
	pass
