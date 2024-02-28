function Create(self)
	local absoluteMax = math.max(SceneMan.SceneHeight, SceneMan.SceneWidth) / 1.9
	self.maxRadius = math.min(absoluteMax, self.PinStrength)
	self.boulderSize = 14
	self.rockingRadius = self.boulderSize
	self.radiusIncrement = self.rockingRadius * 1
	self.startPos = Vector(self.Pos.X, self.Pos.Y)
	self.Pos = Vector(0, -10)

	function addBoulder(position)
		local boulder = CreateAHuman("Bandit", "Ronin.rte")
		boulder.GibImpulseLimit = 100;
		boulder.Pos = position
		boulder.RotAngle = math.random() * math.rad(360)
		boulder.IgnoresTeamHits = false
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
	local angleIncrement = (self.boulderSize / self.rockingRadius) * 1
	local step = 0

	if self.rockingRadius < self.maxRadius then
		while step * angleIncrement < math.rad(360) do
			step = step + 1
			local rockVector = self.startPos + Vector(self.rockingRadius, 0):RadRotate(step * angleIncrement)
			if rockVector.Y < SceneMan.SceneHeight and SceneMan:GetTerrMatter(rockVector.X, rockVector.Y) == 0 then
				addBoulder(rockVector)
			end
		end
		self.rockingRadius = self.rockingRadius + self.radiusIncrement
	else
		self.Lifetime = 1
	end
end
