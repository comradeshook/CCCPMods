function Create(self)
	self.Pos = self.Pos - self.Vel / 3
	self:GibThis()
end
