function Create(self)
	local maxRange = 600 --Max range in pixels
	local boltVariance = 0.6 --Max variance in angle between individual bolt sections, in radians
	local sectionDistance = 3 --Distance between individual bolt sections in pixels
	local accurate = true --Whether or not the start- and end points of the bolt should be parallel to a line projected from the guns muzzle

	local q = 1
	if accurate then
		q = 2
	end
	local iters = math.ceil(maxRange / sectionDistance) / q
	local yTotal = 0
	local velCorrection = self.Vel * (GetPPM() * TimerMan.DeltaTimeSecs)
	local initPos = self.Pos
	local oldPos = initPos
	local newPos = Vector(0, 0)
	local angleTable = {}
	for i = 1, iters do
		local angleOffset = math.random(-(boltVariance * 100), (boltVariance * 100)) / 100
		if accurate then
			--angleTable[1+iters-i] = -angleOffset;
			angleTable[i] = -angleOffset
		end
		local glow = CreateMOPixel("Glow Particle Necron")
		local glow2 = CreateMOPixel("Glow Particle Necron Big")
		posVector = Vector(sectionDistance, 0):RadRotate(self.RotAngle + angleOffset)
		newPos = newPos + posVector
		glow.Pos = initPos + newPos
		glow2.Pos = initPos + newPos
		glow.Vel = Vector(0, 0)
		glow2.Vel = Vector(0, 0)
		local endPos = Vector(0, 0)
		if i > 2 then
			local randomRay = SceneMan:CastMORay(oldPos, posVector, glow.ID, -2, 0, false, 0)
			endPos = SceneMan:GetLastRayHitPos()
			local trueLength = SceneMan:ShortestDistance(oldPos, endPos, true).Magnitude
			if trueLength < posVector.Magnitude then
				local impact = CreateAEmitter("Necron Strike")
				impact.Pos = endPos
				impact.RotAngle = self.RotAngle
				MovableMan:AddMO(impact)
				break
			end
		end
		MovableMan:AddMO(glow)
		MovableMan:AddMO(glow2)
		oldPos = glow.Pos
	end
	if accurate then
		for i = 1, iters do
			local angleOffset = angleTable[i]
			local glow = CreateMOPixel("Glow Particle Necron")
			local glow2 = CreateMOPixel("Glow Particle Necron Big")
			posVector = Vector(sectionDistance, 0):RadRotate(self.RotAngle + angleOffset)
			newPos = newPos + posVector
			glow.Pos = initPos + newPos
			glow2.Pos = initPos + newPos
			glow.Vel = Vector(0, 0)
			glow2.Vel = Vector(0, 0)
			local endPos = Vector(0, 0)
			if i > 2 then
				local randomRay = SceneMan:CastMORay(oldPos, posVector, glow.ID, -2, 0, false, 0)
				endPos = SceneMan:GetLastRayHitPos()
				local trueLength = SceneMan:ShortestDistance(oldPos, endPos, true).Magnitude
				if trueLength < posVector.Magnitude then
					local impact = CreateMOPixel("NECRON ZAP")
					impact.Pos = endPos
					impact.Vel = Vector(60, 0):RadRotate(self.RotAngle)
					MovableMan:AddMO(impact)
					break
				end
			end
			MovableMan:AddMO(glow)
			MovableMan:AddMO(glow2)
			oldPos = glow.Pos
		end
	end
	self.ToDelete = true
end
