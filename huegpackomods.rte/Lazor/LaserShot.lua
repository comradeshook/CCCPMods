local function drawThiccLine(startPos, endPos, thiccness, color)
	local dirVector = SceneMan:ShortestDistance(startPos, endPos, true):Perpendicularize()
	local pos1 = startPos + dirVector:SetMagnitude((thiccness - 1) / 2)
	local pos2 = startPos - dirVector:SetMagnitude((thiccness - 1) / 2)
	local pos3 = endPos + dirVector:SetMagnitude((thiccness - 1) / 2)
	local pos4 = endPos - dirVector:SetMagnitude((thiccness - 1) / 2)

	PrimitiveMan:DrawTriangleFillPrimitive(pos1, pos2, pos3, color)
	PrimitiveMan:DrawTriangleFillPrimitive(pos3, pos4, pos2, color)
end

local brightColourIndex = 177
local darkColourIndex = 198 -- colours of the laser, look at the palette for index numbers

function Create(self)
	local NumberValueExists = self.NumberValueExists;
	local GetNumberValue = self.GetNumberValue;
	
	local selfPos = self.Pos;
	local maxRange = self.Vel.Magnitude * 5
	local maxSpread = math.rad(NumberValueExists(self, "LaserSpread") and GetNumberValue(self, "LaserSpread") or 0)
	local rayAngle = self.Vel.AbsRadAngle - (maxSpread / 2) + math.random() * maxSpread
	local rangeVector = Vector(maxRange, 0):RadRotate(rayAngle)
	
	local var = {};
	var.woundCount = NumberValueExists(self, "LaserWoundCount") and GetNumberValue(self, "LaserWoundCount") or 1
	var.thickness = NumberValueExists(self, "LaserThickness") and GetNumberValue(self, "LaserThickness") or 3
	var.drawFlash = true -- set to false if you hate that the lasers flash in the first frame
	var.persistentRayHitPos = selfPos + rangeVector
	
	--penetration power is solely defined by Sharpness; StructuralIntegrity > Sharpness = no wound
	--look in Ammo.ini for examples of how to use the number values

	local terrainCheck = SceneMan:CastTerrainPenetrationRay(selfPos, rangeVector, var.persistentRayHitPos, self.Sharpness, 0);
	rangeVector = SceneMan:ShortestDistance(selfPos, var.persistentRayHitPos, true);
	rangeVector = rangeVector - rangeVector.Normalized;
	local targetMOID = SceneMan:CastMORay(selfPos, rangeVector, self.ID, self.Team, 0, false, 1)
	if targetMOID ~= 255 then
		var.hitObstacle = true
		local rayHitPos = SceneMan:GetLastRayHitPos()
		rangeVector = SceneMan:ShortestDistance(selfPos, rayHitPos, true);
		var.persistentRayHitPos = selfPos + rangeVector
		local MO = ToMOSRotating(MovableMan:GetMOFromID(targetMOID))
		local woundName = MO:GetEntryWoundPresetName()
		if woundName ~= "" then
			local function createWound(woundToAdd, counts)
				local woundOffset = var.persistentRayHitPos - MO.Pos;
				local woundPos = woundOffset:GetRadRotatedCopy(-MO.RotAngle):GetXFlipped(MO.HFlipped);
				local inboundAngle = rangeVector:GetXFlipped(MO.HFlipped).AbsRadAngle;
				local woundAngle = inboundAngle - (MO.RotAngle * MO.FlipFactor) + math.pi;
				woundToAdd.InheritedRotAngleOffset = woundAngle;
				MO:AddWound(woundToAdd, woundPos, counts)
			end
			
			if MO.Material.StructuralIntegrity <= self.Sharpness then
				for i = 1, var.woundCount, 1 do
					createWound(CreateAEmitter(woundName), true);
				end
			else
				local woundTemplate = CreateAEmitter(woundName)
				for i = 1, var.woundCount, 1 do
					createWound(CreateAEmitter("Laser Scorch Wound"), false);
				end
			end
		end
	else
		var.hitObstacle = terrainCheck;
		--var.persistentRayHitPos = selfPos + SceneMan:ShortestDistance(selfPos, var.persistentRayHitPos, true)
	end
	
	for pixel in SceneMan:DislodgePixelLine(selfPos, rangeVector, 0, false) do
		if pixel.Material.StructuralIntegrity <= self.Sharpness then
			pixel.ToDelete = true;
			local slag = CreateMOPixel("Slag Particle", "huegpackomods.rte");
			slag.Pos = pixel.Pos;
			MovableMan:AddParticle(slag);
		else
			pixel.ToSettle = true;
		end
	end
	
	self.var = var;
end

function Update(self)
	local selfPos = self.Pos;
	local var = self.var;
	local drawThickness = math.ceil(var.thickness * math.max(0, 1 - (self.Age / self.Lifetime)))
	if var.drawFlash then
		var.drawFlash = false
		drawThiccLine(selfPos, var.persistentRayHitPos, drawThickness * 2, brightColourIndex)
		PrimitiveMan:DrawCircleFillPrimitive(selfPos, drawThickness * 1.5, brightColourIndex)
		if var.hitObstacle then
			PrimitiveMan:DrawCircleFillPrimitive(var.persistentRayHitPos, drawThickness * 2, brightColourIndex)
		else
			PrimitiveMan:DrawCircleFillPrimitive(var.persistentRayHitPos, drawThickness, brightColourIndex)
		end
	else
		drawThiccLine(selfPos, var.persistentRayHitPos, drawThickness, darkColourIndex)
		if var.hitObstacle then
			PrimitiveMan:DrawCircleFillPrimitive(var.persistentRayHitPos, drawThickness, brightColourIndex)
		else
			PrimitiveMan:DrawCircleFillPrimitive(var.persistentRayHitPos, drawThickness / 2, darkColourIndex)
		end
	end
end
