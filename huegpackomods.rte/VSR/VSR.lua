function Update(self)
	if not self:IsEmitting() and self.Age >= 1000 then
		self:EnableEmission(true)
		self.Vel = Vector(0, 10)
		self.GlobalAccScalar = 5
	end

	if self.Age > 4000 then
		self:GibThis()
	end
end
