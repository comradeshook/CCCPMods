function Update(self)
	if self.FiredFrame then
		local user = self:GetRootParent()
		local forceVector = Vector(-120000 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		local forceOffset = SceneMan:ShortestDistance(self.Pos, user.Pos, true)
		forceOffset = forceOffset:SetMagnitude(forceOffset.Magnitude / 20)
		user:AddForce(forceVector, forceOffset)
	end
end
