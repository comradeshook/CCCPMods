function Update(self)
	self.Vel = self.Vel * 0.98
	self.RotAngle = 0
	if self.Age > 10000 then
		self.Age = 5000
	end
end
