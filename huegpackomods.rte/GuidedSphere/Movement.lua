function Update(self)
	if self:GetController():IsState(Controller.MOVE_UP) then
		if self.Vel.Y > -100 then
			self.Vel.Y = self.Vel.Y - 1
		end
	elseif self:GetController():IsState(Controller.MOVE_DOWN) then
		if self.Vel.Y < 100 then
			self.Vel.Y = self.Vel.Y + 1
		end
	end
	if self:GetController():IsState(Controller.MOVE_LEFT) then
		if self.Vel.X > -100 then
			self.Vel.X = self.Vel.X - 1
		end
	elseif self:GetController():IsState(Controller.MOVE_RIGHT) then
		if self.Vel.X < 100 then
			self.Vel.X = self.Vel.X + 1
		end
	end
	if self:GetController():IsState(Controller.PRIMARY_ACTION) then
		self:GibThis()
	end
	if self:GetController():IsState(Controller.AIM_SHARP) then
		if self.HFlipped == false then
			if self.AngularVel > -60 then
				self.AngularVel = self.AngularVel - 2
			end
		else
			if self.AngularVel < 60 then
				self.AngularVel = self.AngularVel + 2
			end
		end
	end
end
