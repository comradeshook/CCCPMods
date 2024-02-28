function Create(self)
	self.Mass = 300
end

function Update(self)
	if self.Vel.X > 0 then
		self.AngularVel = -25
	else
		self.AngularVel = 25
	end
end
