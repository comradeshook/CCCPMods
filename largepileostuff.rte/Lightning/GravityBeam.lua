function Create(self)
	local yTotal = 0
	local velCorrection = self.Vel * (GetPPM() * TimerMan.DeltaTimeSecs)
	local initPos = self.Pos
	local oldPos = initPos
	local newPos = Vector(0, 0)
	for i = 1, 250 do
		local angleOffset = math.random(-12, 12) / 10
		local branch = math.random(1, 100)
		local glow = CreateMOPixel("Glow Particle Lightning")
		local glow2 = CreateMOPixel("Glow Particle Lightning Big")
		local glow3 = CreateMOPixel("Random Particle")
		posVector = Vector(3, 0):RadRotate(self.RotAngle) + (SceneMan.GlobalAcc * TimerMan.DeltaTimeSecs * i) / 4
		newPos = newPos + posVector
		glow.Pos = initPos + newPos
		glow2.Pos = initPos + newPos
		glow3.Pos = initPos + newPos
		glow.Vel = Vector(0, 0)
		glow2.Vel = Vector(0, 0)
		glow3.Vel = Vector(3, 0):RadRotate(math.random(0, math.pi * 2000) / 1000)
		local endPos = Vector(0, 0)
		if i > 2 then
			local randomRay = SceneMan:CastMORay(oldPos, posVector, glow.ID, 0, false, 0)
			endPos = SceneMan:GetLastRayHitPos()
			local trueLength = SceneMan:ShortestDistance(oldPos, endPos, true).Magnitude
			if trueLength < posVector.Magnitude then
				local impact = CreateAEmitter("Lightning Strike")
				impact.Pos = endPos
				impact.Vel = Vector(0, 0)
				MovableMan:AddMO(impact)
				break
			end
		end
		MovableMan:AddMO(glow)
		MovableMan:AddMO(glow2)
		MovableMan:AddMO(glow3)
		oldPos = glow.Pos
	end
	self.ToDelete = true
end
