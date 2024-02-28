function Create(self)
	local startPos = self.Pos
	local endPos = Vector(0, 0)
	for i = 1, 100 do
		local waveAngle = math.cos((i - 1) * (math.pi / 25) * 5)
		local rayVector = Vector(5, 0):RadRotate(self.RotAngle + waveAngle)
		local castRay = SceneMan:CastMORay(startPos, rayVector, self.RootID, self.IgnoresWhichTeam, 0, false, 0)
		endPos = SceneMan:GetLastRayHitPos()
		local rayLength = SceneMan:ShortestDistance(startPos, endPos, true).Magnitude
		print(rayLength)
		print(rayVector.Magnitude)
		if rayLength < rayVector.Magnitude then
			local hit = CreateMOPixel("Glow Particle Yellow Big")
			hit.Pos = endPos
			MovableMan:AddMO(hit)
			break
		else
			local trail = CreateMOPixel("Glow Particle Yellow Small")
			trail.Pos = endPos
			MovableMan:AddMO(trail)
		end
		startPos = endPos
	end
end
