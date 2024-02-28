function Create(self)
	self.gibTime = self.Lifetime
	self.Age = self.Age - 50
	self.boomTimer = Timer()
end

function Update(self)
	if self.boomTimer:IsPastSimMS(self.gibTime) then
		self:GibThis()
	end
end
