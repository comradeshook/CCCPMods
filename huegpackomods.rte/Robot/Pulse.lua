function Create(self)
	for MO in MovableMan:GetMOsInRadius(self.Pos, 50, -1, true) do
		if MO.PresetName == "Reflective Robot MK-II" then
			self:SetWhichMOToNotHit(MO, -1)
		end
	end
	self.HitsMOs = true
end
