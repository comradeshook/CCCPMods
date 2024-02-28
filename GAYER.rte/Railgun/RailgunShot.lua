function drawThiccLine(startPos, endPos, thiccness, color)
	local dirVector = SceneMan:ShortestDistance(startPos, endPos, true):Perpendicularize()
	local pos1 = startPos + dirVector:SetMagnitude((thiccness - 1) / 2)
	local pos2 = startPos - dirVector:SetMagnitude((thiccness - 1) / 2)
	local pos3 = endPos + dirVector:SetMagnitude((thiccness - 1) / 2)
	local pos4 = endPos - dirVector:SetMagnitude((thiccness - 1) / 2)

	PrimitiveMan:DrawTriangleFillPrimitive(pos1, pos2, pos3, color)
	PrimitiveMan:DrawTriangleFillPrimitive(pos3, pos4, pos2, color)
end

-- this isn't actually used yet but maybe at some point will i make the shot
-- consider terrain more for its range
function complexRay(self)
	local shatterThreshold = 350
	local maxMaterialPenetration = 48000 --cumulative StructuralIntegrity
	local toExplode = false
	while self.barrierFound do
		local distanceVector = SceneMan:ShortestDistance(self.Pos, self.hitVector, true)
		local materialStrength = SceneMan:CastMaxStrengthRay(self.hitVector, self.hitVector, 0)
		local rayStop = self.hitVector
		if materialStrength > 0 then
			if materialStrength >= shatterThreshold then
				toExplode = true
			else
				local materialLengthWeak = SceneMan:CastWeaknessRay(
					self.hitVector,
					self.rangeVector - distanceVector,
					materialStrength,
					rayStop,
					1,
					true
				)
				local materialLengthStrong = SceneMan:CastWeaknessRay(
					self.hitVector,
					self.rangeVector - distanceVector,
					materialStrength,
					rayStop,
					1,
					true
				)
				maxMaterialPenetration = maxMaterialPenetration - materialLength.Magnitude * materialStrength * 2 -- multiplied to account for skipped pixels
			end
		end

		if maxMaterialPenetration <= 0 then
			self.barrierFound = false
		else
			self.barrierFound = SceneMan:CastStrengthRay(
				rayStop,
				self.rangeVector - distanceVector,
				10,
				self.hitVector,
				1,
				128,
				true
			)
		end
	end
end

function KillRay(self)
	local MOCount = 0
	local MOList = {}
	local struckMO = SceneMan:CastMORay(self.Pos, self.MOVector, self.ID, self.Team, 0, true, 1)
	while struckMO ~= 255 do
		local MO = MovableMan:GetMOFromID(struckMO)
		local MORoot = MO:GetRootParent()
		MOList[MOCount] = MO
		MOCount = MOCount + 1

		local ignoreID = struckMO
		local lastHit = SceneMan:GetLastRayHitPos()
		local newVec = Vector(self.MOVector.X, self.MOVector.Y):SetMagnitude(
			self.MOVector.Magnitude - SceneMan:ShortestDistance(self.Pos, lastHit, true).Magnitude
		)

		if self.spawnEffects and MORoot.UniqueID ~= self.lastRootID then
			self.lastRootID = MORoot.UniqueID
			local puff = CreateAEmitter("Railgun MO Hit Effect", "GAYER.rte")
			puff.Pos = lastHit
			puff.RotAngle = self.RotAngle
			puff.HFlipped = self.HFlipped
			MovableMan:AddMO(puff)
		end

		MO.Vel = Vector(self.MOVector.X, self.MOVector.Y):SetMagnitude(30)

		local forceVector = Vector(60000 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		local forceOffset = SceneMan:ShortestDistance(MORoot.Pos, lastHit, true)
		forceOffset = forceOffset:SetMagnitude(forceOffset.Magnitude / 20)
		MORoot:AddForce(forceVector, forceOffset)

		struckMO = SceneMan:CastMORay(lastHit, newVec, ignoreID, self.Team, 0, true, 1)
	end

	for i = 0, MOCount - 1, 1 do
		ToMOSRotating(MOList[i]):GibThis()
	end
end

local DislodgeLine = SceneMan.DislodgePixelLine;

function Create(self)
	self.spawnEffects = true
	self.lastRootID = -1
	self.killRayCount = 3
	self.maxRange = 1000

	self.rangeVector = Vector(self.maxRange * self.FlipFactor, 0):RadRotate(self.RotAngle)
	self.hitVector = self.Pos + self.rangeVector
	local terrainPenetration = SceneMan:CastTerrainPenetrationRay(self.Pos, self.rangeVector, self.hitVector, 48000, 0);
	self.MOVector = SceneMan:ShortestDistance(self.Pos, self.hitVector, true)
	self.barrierFound = SceneMan:CastStrengthRay(self.Pos, self.MOVector, 350, self.hitVector, 1, 128, true)
	
	if self.barrierFound then
		self.MOVector = SceneMan:ShortestDistance(self.Pos, self.hitVector, true)
	end

	local terrainHitPos = Vector(0, 0)
	local failsafe = 100
	local softTerrainCheck = SceneMan:CastStrengthRay(self.Pos, self.MOVector, 5, terrainHitPos, 1, 128, true)
	while softTerrainCheck do
		failsafe = failsafe - 1
		local entryBoom = CreateAEmitter("Railgun Terrain Entry Blast", "GAYER.rte")
		entryBoom.Pos = terrainHitPos
		entryBoom.RotAngle = self.RotAngle
		entryBoom.HFlipped = self.HFlipped
		MovableMan:AddMO(entryBoom)

		local newVec = Vector(self.MOVector.X, self.MOVector.Y):SetMagnitude(
			self.MOVector.Magnitude - SceneMan:ShortestDistance(self.Pos, terrainHitPos, true).Magnitude
		)
		local airHitPos = Vector(0, 0)
		local terrainExitCheck = SceneMan:CastWeaknessRay(terrainHitPos, newVec, 5, airHitPos, 1, true)

		if terrainExitCheck and failsafe > 0 then
			local exitBoom = CreateAEmitter("Railgun Terrain Exit Blast", "GAYER.rte")
			exitBoom.Pos = airHitPos
			exitBoom.RotAngle = self.RotAngle
			exitBoom.HFlipped = self.HFlipped
			MovableMan:AddMO(exitBoom)

			newVec = Vector(self.MOVector.X, self.MOVector.Y):SetMagnitude(
				self.MOVector.Magnitude - SceneMan:ShortestDistance(self.Pos, airHitPos, true).Magnitude
			)
			softTerrainCheck = SceneMan:CastStrengthRay(airHitPos, newVec, 5, terrainHitPos, 1, 128, true)
		else
			if failsafe == 0 then
				-- print("Angry Railgun infinite while-loop failsafe triggered, please tell Shook how this happened")
			end
			softTerrainCheck = false
		end
	end

	for i = 5, self.MOVector.Magnitude, 15 do
		local pos = self.Pos + self.MOVector:SetMagnitude(i)
		local effect = CreateAEmitter("Railgun Trail Effect", "GAYER.rte")
		effect.Pos = pos
		effect.RotAngle = self.RotAngle
		effect.HFlipped = self.HFlipped
		MovableMan:AddMO(effect)
	end
	
	for i = 0, 2.5, 0.5 do
		local offset = Vector(1, 0):AbsRotateTo(self.rangeVector):Perpendicularize();
		local melt = i >= 2;
		for q = -1, 1, 2 do
			if melt == false then
				DislodgeLine(SceneMan, self.Pos + offset*i*q, self.MOVector, 0, true);
			else
				for pixel in DislodgeLine(SceneMan, self.Pos + offset*i*q, self.MOVector, 0, true) do
					local px = CreateMOPixel("Slag Particle Pinned", "GAYER.rte");
					px.Pos = pixel.Pos;
					MovableMan:AddParticle(px);
				end
			end
		end
	end

	if self.barrierFound then
		local blast = CreateAEmitter("Railgun Shatter Blast", "GAYER.rte")
		blast.Pos = self.hitVector
		blast.RotAngle = self.RotAngle
		blast.HFlipped = self.HFlipped
		MovableMan:AddMO(blast)

		local lineDelete = CreateMOSRotating("Terrain Delete Line", "GAYER.rte")
		lineDelete.Pos = self.hitVector
		lineDelete.RotAngle = self.RotAngle
		lineDelete.HFlipped = self.HFlipped
		MovableMan:AddMO(lineDelete)

		local circleDelete = CreateMOSRotating("Terrain Delete Circle", "GAYER.rte")
		circleDelete.Pos = self.hitVector
		circleDelete.RotAngle = self.RotAngle
		circleDelete.HFlipped = self.HFlipped
		MovableMan:AddMO(circleDelete)
	end

	drawThiccLine(self.Pos, self.Pos + self.MOVector, 40, 99)
	PrimitiveMan:DrawCircleFillPrimitive(self.Pos, 30, 99)
	PrimitiveMan:DrawCircleFillPrimitive(self.Pos + self.MOVector, 40, 99)
end

function Update(self)
	if self.killRayCount > 0 then
		KillRay(self)
		self.killRayCount = self.killRayCount - 1

		if self.spawnEffects then
			self.spawnEffects = false
		end
	else
		self.ToDelete = true
	end
end
