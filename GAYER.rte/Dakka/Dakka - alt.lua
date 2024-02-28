function Create(self)
	self.Sharpness = 600
end

function Update(self)
	if self.Sharpness == nil then
		self.Sharpness = 600
	end
	self.RateOfFire = self.Sharpness
end
