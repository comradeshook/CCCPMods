function Destroy(self)
	self.blastForce = 1000
	for i = 1, MovableMan:GetMOIDCount() - 1, 1 do
		self.target = MovableMan:GetMOFromID(i)
		local dist = SceneMan:ShortestDistance(self.Pos, self.target.Pos, true)
		if self.ID ~= i and dist.Magnitude < 30 then
			self.pointed = MovableMan:GetMOFromID(SceneMan:CastMORay(self.Pos, dist, self.ID, -2, 0, false, 5))
			if self.pointed ~= nil then
				if self.pointed.RootID == self.target.RootID then
					self.target:AddAbsImpulseForce(
						dist.Normalized:SetMagnitude(self.blastForce / dist.Magnitude),
						self.target.Pos
					)
				end
			end
		end
	end
end
