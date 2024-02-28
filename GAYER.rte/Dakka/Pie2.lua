function MoreDakka(actor)
	self.RateOfFire = self.RateOfFire + 120
end

function LessDakka(actor)
	if self:GetRateOfFire() > 120 then
		self.RateOfFire = self.RateOfFire - 120
	else
		self.RateOfFire = 0
	end
end
