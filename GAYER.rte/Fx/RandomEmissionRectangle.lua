function Create(self)
	self.emissionName = "Flash Particle Yellow Big" -- MOPixel PresetName here
	self.emissionVel = Vector(0, 3) -- X, Y
	self.emissionAngle = math.random() * math.rad(360) -- Change the 360 if you want it to not be a radial scatter
	self.emissionPosRangeX = { -50, 50 } -- Min/Max horizontal distance from center
	self.emissionPosRangeY = { -50, 50 } -- Min/Max vertical distance from center
	self.emissionOffset = Vector(0, 0) -- Just in case :V
	self.emissionInterval = 50 -- Milliseconds
	self.emissionTimer = Timer()
end

function Update(self)
	if self.emissionTimer:IsPastSimMS(self.emissionInterval) then
		local particle = CreateMOPixel(self.emissionName)
		particle.Pos = self.Pos
			+ self.emissionOffset
			+ Vector(
				math.random(self.emissionPosRangeX[1], self.emissionPosRangeX[2]),
				math.random(self.emissionPosRangeY[1], self.emissionPosRangeY[2])
			)
		particle.Vel = self.emissionVel:RadRotate(self.emissionAngle)
		MovableMan:AddMO(particle)
		self.emissionTimer:Reset()
	end
end
