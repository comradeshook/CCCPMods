function drawThiccLine(startPos, endPos, thiccness, color)
	local dirVector = SceneMan:ShortestDistance(startPos, endPos, true):Perpendicularize()
	local pos1 = startPos + dirVector:SetMagnitude((thiccness - 1) / 2 + math.random(-1, 1))
	local pos2 = startPos - dirVector:SetMagnitude((thiccness - 1) / 2 + math.random(-1, 1))
	local pos3 = endPos + dirVector:SetMagnitude((thiccness - 1) / 2 + math.random(-1, 1))
	local pos4 = endPos - dirVector:SetMagnitude((thiccness - 1) / 2 + math.random(-1, 1))

	PrimitiveMan:DrawTriangleFillPrimitive(pos1, pos2, pos3, color)
	PrimitiveMan:DrawTriangleFillPrimitive(pos3, pos4, pos2, color)
end

function Create(self)
	local range = 800
	local burstSize = 50
	local beamWidth = 5
	local blastVelFactor = 1
	local beamColourCenter = 166
	local beamColourEdge = 198

	if string.find(self.PresetName, "Pistol") then
		range = 500
		blastVelFactor = 0.5
		beamWidth = 3
	end

	if string.find(self.PresetName, "Killer") then
		beamColourCenter = 4
		beamColourEdge = 13
	elseif string.find(self.PresetName, "Shredder") then
		beamColourCenter = 99
		beamColourEdge = 87
	end

	local startPos = Vector(self.Pos.X, self.Pos.Y)
	local rangeVector = Vector(range, 0):RadRotate(self.RotAngle + math.rad(180) * math.min(0, self.FlipFactor))
	local lastPos = Vector(0, 0)

	if string.find(self.PresetName, "Digger") then
		SceneMan:CastStrengthRay(startPos, rangeVector, 1, lastPos, 1, 0, true)
	else
		SceneMan:CastObstacleRay(startPos, rangeVector, Vector(0, 0), lastPos, self.ID, self.IgnoresWhichTeam, 0, 2)
		--SceneMan:CastMORay(startPos, rangeVector, self.ID, self.IgnoresWhichTeam, 0, false, 2);
		--lastPos = SceneMan:GetLastRayHitPos();
	end

	if lastPos == Vector(0, 0) then
		lastPos = startPos
	end

	local rayVec = SceneMan:ShortestDistance(startPos, lastPos, true)

	PrimitiveMan:DrawCircleFillPrimitive(
		startPos,
		math.random((beamWidth / 2) + 2, (beamWidth / 2) + 3),
		beamColourEdge
	)
	drawThiccLine(startPos, startPos + rayVec, beamWidth, beamColourEdge)
	PrimitiveMan:DrawCircleFillPrimitive(lastPos, math.random(beamWidth, beamWidth + 2), beamColourEdge)
	PrimitiveMan:DrawCircleFillPrimitive(startPos, 2, beamColourCenter)
	PrimitiveMan:DrawLinePrimitive(startPos, startPos + rayVec, beamColourCenter)
	PrimitiveMan:DrawCircleFillPrimitive(lastPos, math.random(beamWidth / 2, (beamWidth / 2) + 1), beamColourCenter)

	local effectName = string.gsub(self.PresetName, " Pistol", "") .. " Effect"

	if rayVec.Magnitude < rangeVector.Magnitude then
		for i = 0, burstSize, 1 do
			local pew = CreateMOPixel(effectName)
			pew.Pos = lastPos
			pew.Vel = Vector(math.random(30, 60) * blastVelFactor, 0):RadRotate(math.random() * math.pi * 2)
			MovableMan:AddMO(pew)
		end
	end
end
