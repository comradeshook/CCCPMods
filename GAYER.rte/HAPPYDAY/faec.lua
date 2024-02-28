function Create(self)
	self.timerthing = Timer()
	self.halfdiameter = 99
end

function Update(self)
	self.Health = 100
	if self:GetController():IsState(Controller.MOVE_LEFT) then
		if self.Vel.X > -30 then
			self.Vel.X = self.Vel.X - 2
			self.AngularVel = -((self.Vel.X / 3) / self.halfdiameter) * 60
		end
	elseif self:GetController():IsState(Controller.MOVE_RIGHT) then
		if self.Vel.X < 30 then
			self.Vel.X = self.Vel.X + 2
			self.AngularVel = -((self.Vel.X / 3) / self.halfdiameter) * 60
		end
	end
	if self:GetController():IsState(Controller.PRIMARY_ACTION) == false then
		self.timerthing:Reset()
	end
	if self.timerthing:IsPastSimMS(1000) then
		self.ToDelete = true
	end
	if self.Pos.Y < -200 then
		self.Vel.Y = -self.Vel.Y
	end
end
