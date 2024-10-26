function Create(self)
	local random = math.random(100, 200) / 100
	self.Lifetime = self.Lifetime / random
end
