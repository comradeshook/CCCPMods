function Create(self)
	self.terrain = 0
	self.endPos = Vector(0, 0)
	self.actualVel = self.Vel
	self.angle = self.Vel.AbsRadAngle
	self.flip = false
	if self.angle > math.pi / 2 or self.angle < -math.pi / 2 then
		self.flip = true
	end
	self.posCorrection = Vector(0, 4):RadRotate(self.angle)
	self.virtualDistance = math.pi / 16
	self.sineVector = (Vector(20 * math.cos(self.virtualDistance), 0):GetXFlipped(self.flip)):RadRotate(
		self.angle + math.pi / 2
	)
	self.Vel = self.actualVel + self.sineVector
	self.Pos = self.Pos + self.posCorrection
end

function Update(self)
	self.length = SceneMan:CastObstacleRay(self.Pos, self.Vel / 3, Vector(0, 0), self.endPos, self.ID, self.Team, 0, 0)
	local velCorrection = self.Vel * (GetPPM() * TimerMan.DeltaTimeSecs)
	if self.length > velCorrection.Magnitude then
		self.length = SceneMan:ShortestDistance(self.Pos, self.endPos, true).Magnitude
	end
	self.virtualDistance = self.virtualDistance + (math.pi / 8)
	self.sineVector = (Vector(20 * math.cos(self.virtualDistance), 0):GetXFlipped(self.flip)):RadRotate(
		self.angle + math.pi / 2
	)
	self.Vel = self.actualVel + self.sineVector

	local trail = CreateMOPixel("Glowy Trail Stationary")
	trail.Pos = self.Pos
	trail.Vel = Vector(0, 0)
	MovableMan:AddMO(trail)
end
