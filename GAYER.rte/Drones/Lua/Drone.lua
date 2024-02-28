function Create(self)
	self.acceleration = 0.5
	self.speedLimit = 20
	self.tiltSpeed = 1
	self.tiltLimit = 0.5
	self.isMovingX = 0
	self.isMovingY = 0
	self.overloaded = 0
	self.overloadFactor = 1
	if not string.find(self.PresetName, "Heavy") then
		self.liftLimit = SceneMan.GlobalAcc * 10.5
	else
		self.liftLimit = SceneMan.GlobalAcc * 30
	end
	self.lift = Vector(0, 0)
end

function Update(self)
	self.isMovingX = 0
	self.isMovingY = 0
	self.lift = SceneMan.GlobalAcc * self.Mass
	if self.lift.Magnitude > self.liftLimit.Magnitude then
		self.lift = self.lift - (self.lift - self.liftLimit)
		self.overloaded = 1
		self.overloadFactor = (self.lift.Magnitude / self.liftLimit.Magnitude) * 2
	end
	if self.Health > 0 then
		self:AddAbsForce(self.lift * -1, self.Pos)
	end
	if self:GetController():IsState(Controller.MOVE_UP) then
		self.isMovingY = 1
		if self.Vel.Y > -self.speedLimit / 2 then
			self.Vel.Y = self.Vel.Y - (self.acceleration / self.overloadFactor)
		end
	elseif self:GetController():IsState(Controller.MOVE_DOWN) then
		self.isMovingY = 1
		if self.Vel.Y < self.speedLimit / 2 then
			self.Vel.Y = self.Vel.Y + self.acceleration
		end
	end
	if self:GetController():IsState(Controller.MOVE_LEFT) then
		self.isMovingX = 1
		self.HFlipped = true
		self.AngularVel = self.tiltSpeed
		if self.Vel.X > -self.speedLimit then
			self.Vel.X = self.Vel.X - (self.acceleration / self.overloadFactor)
		end
	elseif self:GetController():IsState(Controller.MOVE_RIGHT) then
		self.isMovingX = 1
		self.HFlipped = false
		self.AngularVel = -self.tiltSpeed
		if self.Vel.X < self.speedLimit then
			self.Vel.X = self.Vel.X + (self.acceleration / self.overloadFactor)
		end
	end
	if self.isMovingY == 0 and self.overloaded == 0 then
		self.Vel.Y = self.Vel.Y * 0.95
	elseif self.isMovingY == 0 and self.overloaded == 1 then
		if self.Vel.Y < 0 then
			self.Vel.Y = self.Vel.Y * 0.95
		end
	end
	if self.isMovingX == 0 then
		if self.RotAngle > 0 then
			if self.RotAngle > self.tiltLimit * 2 then
				self.RotAngle = (self.tiltLimit * 2)
				self.AngularVel = 0
			else
				self.AngularVel = -(self.tiltLimit * 2)
			end
		elseif self.RotAngle < 0 then
			if self.RotAngle < -(self.tiltLimit * 2) then
				self.RotAngle = -(self.tiltLimit * 2)
				self.AngularVel = 0
			else
				self.AngularVel = (self.tiltLimit * 2)
			end
		end
	else
		if self.RotAngle > self.tiltLimit then
			self.RotAngle = self.tiltLimit
			self.AngularVel = 0
		elseif self.RotAngle < -self.tiltLimit then
			self.RotAngle = -self.tiltLimit
			self.AngularVel = 0
		end
	end
end
