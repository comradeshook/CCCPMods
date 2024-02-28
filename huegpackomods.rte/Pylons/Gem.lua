function Create(self)
	self.gibRandom = math.random(0, 500)
end

function Update(self)
	if self.ToSettle == true then
		self.ToSettle = false
	end
	if self.Age > (3500 + self.gibRandom) then
		self:GibThis()
	end
end
