function Create(self)
	self.initialMass = self.IndividualMass;
end

function Update(self)
	local adjustedMass = self.initialMass*2 - self.Mass;
	self.Mass = adjustedMass;
end