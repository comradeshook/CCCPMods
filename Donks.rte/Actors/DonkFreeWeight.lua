function Create(self)
	self.freeWeight = ToMOSRotating(self):GetNumberValue("DonkFreeWeight")
	self.baseMass = self.IndividualMass
end

function Update(self)
	local heldMass = 0
	if self.EquippedItem then
		heldMass = self.EquippedItem.Mass
	end

	self.Mass = self.baseMass - math.min(self.InventoryMass + heldMass, self.freeWeight)
end
