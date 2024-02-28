function Create(self)
	local iters = 250
	lightning(250, self.RotAngle + math.rad(180) * math.min(0, self.FlipFactor), self.Pos, 100)
	self.ToDelete = true
end

function lightning(iters, angle, pos, branchChance)
	local initPos = pos
	local oldPos = initPos
	local newPos = Vector(0, 0)
	for i = 1, iters do
		local angleOffset = math.random(-120, 120) / 100
		local branch = math.random(1, branchChance)
		local glow = CreateMOPixel("Glow Particle Lightning")
		local glow2 = CreateMOPixel("Glow Particle Lightning Big")
		local glow3 = CreateMOPixel("Random Particle")
		local posVector = Vector(3, 0):RadRotate(angle + angleOffset)
		newPos = newPos + posVector
		glow.Pos = initPos + newPos
		glow2.Pos = initPos + newPos
		glow3.Pos = initPos + newPos
		glow.Vel = Vector(0, 0)
		glow2.Vel = Vector(0, 0)
		glow3.Vel = Vector(3, 0):RadRotate(math.random(0, math.pi * 2000) / 1000)
		local endPos = Vector(0, 0)
		if i > 2 then
			local randomRay = SceneMan:CastMORay(oldPos, posVector, glow.ID, -2, 0, false, 0)
			endPos = SceneMan:GetLastRayHitPos()
			local trueLength = SceneMan:ShortestDistance(oldPos, endPos, true).Magnitude
			if trueLength < posVector.Magnitude then
				local impact = CreateAEmitter("Lightning Strike")
				impact.Pos = endPos
				impact.Vel = Vector(0, 0)
				MovableMan:AddMO(impact)
				break
			end
			if branch == branchChance then
				lightning((iters - i) / 2, angle + angleOffset, glow.Pos, branchChance * 1.5)
			end
		end
		MovableMan:AddMO(glow)
		MovableMan:AddMO(glow2)
		MovableMan:AddMO(glow3)
		oldPos = glow.Pos
	end
end
