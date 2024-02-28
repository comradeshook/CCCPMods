function Create(self)
	self.terrain = 0
	self.endPos = Vector(0, 0)
	self.actualVel = self.Vel
	self.angle = math.atan2(-self.Vel.Y, self.Vel.X)
	self.posCorrection = Vector(0, -4):RadRotate(self.angle)
	self.virtualDistance = math.pi / 8
	self.sineVector = Vector(20 * math.cos(self.virtualDistance), 0):RadRotate(self.angle + math.pi / 2)
	self.Vel = self.actualVel - self.sineVector
	self.Pos = self.Pos + self.posCorrection
end

function Update(self)
	self.length = SceneMan:CastObstacleRay(self.Pos, self.Vel / 3, Vector(0, 0), self.endPos, self.ID, self.Team, 0, 0)
	local velCorrection = self.Vel * (GetPPM() * TimerMan.DeltaTimeSecs)
	if self.length > velCorrection.Magnitude then
		self.length = SceneMan:ShortestDistance(self.Pos, self.endPos, true).Magnitude
	end
	local trueLength = self.length + velCorrection.Magnitude
	local iters = (math.floor(trueLength) / 4)
	local initPos = self.Pos - velCorrection
	local increment = (trueLength / iters)
	if self.Age > 20 then
		for i = 0, iters, 1 do
			local trail = CreateMOPixel("Sine Trail Green")
			trail.Pos = initPos + (self.Vel.Normalized * (i * increment))
			trail.Vel = Vector(0, 0)
			MovableMan:AddMO(trail)
		end
	end
	self.virtualDistance = self.virtualDistance + (math.pi / 4)
	self.sineVector = Vector(20 * math.cos(self.virtualDistance), 0):RadRotate(self.angle + math.pi / 2)
	self.Vel = self.actualVel - self.sineVector
	if self.terrain == 0 then
		self.terrainCheck = SceneMan:CastStrengthRay(
			self.Pos,
			(self.Vel * GetPPM() * TimerMan.DeltaTimeSecs),
			1,
			Vector(0, 0),
			0,
			0,
			true
		)
		if self.terrainCheck == true then
			self.Lifetime = 20
		end
	end
end
