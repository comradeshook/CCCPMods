function OnCollideWithTerrain(self)
	if not self:IsActivated() then
		self:Activate()
	end
end
