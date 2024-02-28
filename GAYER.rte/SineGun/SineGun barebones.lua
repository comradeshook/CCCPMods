function Create(self)
	self.terrain = 0
	self.endPos = Vector(0, 0)
	self.actualVel = self.Vel
	self.angle = math.atan2(-self.Vel.Y, self.Vel.X)
	self.posCorrection = Vector(0, 4):RadRotate(self.angle)
	self.virtualDistance = math.pi / 8 --I think this should probably be half the value seen in self.virtualDistance, not wholly sure.
	self.sineVector = Vector(20 * math.cos(self.virtualDistance), 0):RadRotate(self.angle + math.pi / 2) --The 20 here is sort of the amplitude of the wave
	self.Vel = self.actualVel + self.sineVector
	self.Pos = self.Pos + self.posCorrection
end

function Update(self)
	self.virtualDistance = self.virtualDistance + (math.pi / 4) --This determines the frequency of the wave. Should be a multiple of 2.
	self.sineVector = Vector(20 * math.cos(self.virtualDistance), 0):RadRotate(self.angle + math.pi / 2)
	self.Vel = self.actualVel + self.sineVector
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
