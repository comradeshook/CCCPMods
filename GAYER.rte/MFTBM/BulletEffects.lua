function Create(self)
	self.lifeTimer = Timer()
end

function Update(self)
	if self.ToDelete and self.Age < self.Lifetime then
		self.impactemitter = CreateAEmitter("Bullet Effects");
		self.impactemitter.Pos = self.Pos + (self.Vel / 3)
		MovableMan:AddParticle(self.impactemitter)
	end
end
