function Create(self)
	self.turnSpeed = 0
	self.maxTurnSpeed = 12
	self.turnSpeedAcc = 0.4
	self.decel = 0.6

	self.spinDir = 1
	if self.Vel.X < 0 then
		self.spinDir = -1
	end
end

function Update(self)
	if self.Vel.Magnitude > 2 then
		self.Vel = Vector(self.Vel.X, self.Vel.Y)
			:RadRotate(math.rad(self.turnSpeed * self.spinDir))
			:SetMagnitude(self.Vel.Magnitude - self.decel)
	else
		ToMOSRotating(self):GibThis()
	end

	if self.turnSpeed < self.maxTurnSpeed then
		self.turnSpeed = self.turnSpeed + self.turnSpeedAcc
	end
end
