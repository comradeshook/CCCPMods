function Update(self)
	if self:GetController():IsState(Controller.MOVE_UP) then
		if self.Vel.Y > -15 then
			self.Vel.Y = self.Vel.Y - 1
		end
	elseif self:GetController():IsState(Controller.MOVE_DOWN) then
		if self.Vel.Y < 15 then
			self.Vel.Y = self.Vel.Y + 1
		end
	elseif self.Vel.Y > 0 then
		self.Vel.Y = self.Vel.Y - 0.5
	elseif self.Vel.Y < 0 then
		self.Vel.Y = self.Vel.Y + 0.5
	end
	if self:GetController():IsState(Controller.MOVE_LEFT) then
		if self.Vel.X > -15 then
			self.Vel.X = self.Vel.X - 1
		end
	elseif self:GetController():IsState(Controller.MOVE_RIGHT) then
		if self.Vel.X < 15 then
			self.Vel.X = self.Vel.X + 1
		end
	elseif self.Vel.X > 0 then
		self.Vel.X = self.Vel.X - 0.5
	elseif self.Vel.X < 0 then
		self.Vel.X = self.Vel.X + 0.5
	end
	if self:GetController():IsState(Controller.PRIMARY_ACTION) then
		self:GibThis()
	end
	if self.HFlipped == false then
		self.AngularVel = -3
	else
		self.AngularVel = 3
	end
	for MO in MovableMan:GetMOsInRadius(self.Pos, 30, self.Team, true) do
		if IsActor(MO:GetRootParent()) == true then
			self:GibThis()
		end
	end
end
