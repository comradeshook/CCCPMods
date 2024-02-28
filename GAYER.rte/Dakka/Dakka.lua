function Create(self)
	self.baseROF = 600
	self.modROF = 0
end

function Update(self)
	if self:IsActivated() then
		if self.modROF < 1200 then
			self.modROF = self.modROF + 6
		end
	else
		self.modROF = 0
	end
	self.RateOfFire = (self.baseROF + self.modROF)
end
