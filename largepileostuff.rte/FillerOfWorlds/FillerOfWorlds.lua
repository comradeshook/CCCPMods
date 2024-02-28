function Create(self)
	local absoluteMax = math.max(SceneMan.SceneHeight, SceneMan.SceneWidth) / 1.9
	self.maxRadius = math.min(absoluteMax, self.PinStrength)
	self.boulderSize = 16
	self.rockingRadius = self.boulderSize
	self.radiusIncrement = self.rockingRadius * 1.5
	self.startPos = Vector(self.Pos.X, self.Pos.Y)
	self.Pos = Vector(0, -10)

	function addBoulder(position)
		local boulder = CreateMOSRotating("Rok")
		boulder.Pos = position
		boulder.Frame = math.random(1, 10)
		boulder.RotAngle = math.random() * math.rad(360)
		boulder.spriteOffset = Vector(
			ToMOSprite(boulder):GetSpriteWidth() / 2,
			ToMOSprite(boulder):GetSpriteHeight() / 2
		)
		MovableMan:AddMO(boulder)
		boulder.ToSettle = true
	end
	addBoulder(self.startPos)
end

function Update(self)
	local angleIncrement = (self.boulderSize / self.rockingRadius) * 1.5
	local step = 0

	if self.rockingRadius < self.maxRadius then
		while step * angleIncrement < math.rad(360) do
			step = step + 1
			local rockVector = self.startPos + Vector(self.rockingRadius, 0):RadRotate(step * angleIncrement)
			if rockVector.Y > 100 and rockVector.Y < SceneMan.SceneHeight then
				addBoulder(rockVector)
			end
		end
		self.rockingRadius = self.rockingRadius + self.radiusIncrement
	else
		self.Lifetime = 1
	end
end
