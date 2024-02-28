package.path = package.path .. string.format(";Donks.rte/Shared/?.lua");
require "ThiccLine";

function Create(self)
	self.range = Vector(self:GetNumberValue("DonkLightningRange"), 0);
	self.thiccness = self:GetNumberValue("DonkLightningThickness");
	self.scatterWounds = self:GetNumberValue("DonkLightningScatterWounds");
	self.directWounds = self:GetNumberValue("DonkLightningDirectWounds");
	self.stepLength = 20; --pixels
	self.maxJitter = 40;
	self.flashColour = 166;
	self.lingerColour = 198;
	self.endPos = Vector(self.Pos.X, self.Pos.Y);
	self.boltTable = {self.Pos};
	self.branchTables = {};
	self.branchScaleTable = {};
	self.tableGenerated = false;
	self.flashFactor = 3;
	self.branchChance = 1;
	
	self.canChain = true;
end

function getAllValidLimbs(target, targetTable)
	targetTable[#targetTable+1] = target;
	for limb in target.Attachables do
		if (limb.GetsHitByMOs == 1 and limb:GetEntryWoundPresetName() ~= "") then
			targetTable[#targetTable+1] = limb;
		end
		
		getAllValidLimbs(limb, targetTable);
	end
end

function woundTarget(self, target)
	local realTarget = ToMOSRotating(target);
	local rootMO = realTarget:GetRootParent();
	local targetTable = {};
	getAllValidLimbs(ToMOSRotating(rootMO), targetTable);
	
	if (ToActor(rootMO).PainSound) then
		ToActor(rootMO).PainSound:Play(rootMO.Pos);
	end
	
	for i = 1, (self.scatterWounds + self.directWounds), 1 do
		if (i > self.scatterWounds) then
			local woundName = realTarget:GetEntryWoundPresetName();
			if (woundName ~= "") then
				local woundTemplate = CreateAEmitter(woundName);
				local wound = CreateAEmitter("Shock Wound");
				wound.BurstDamage = woundTemplate.BurstDamage;
				local targetRadius = realTarget.IndividualRadius/2;
				local woundOffset = Vector(math.random(-targetRadius, targetRadius), math.random(-targetRadius, targetRadius));
				realTarget:AddWound(wound, woundOffset, true);
			end
		else
			local woundTarget = targetTable[math.random(#targetTable)];
			local woundName = woundTarget:GetEntryWoundPresetName();
			if (woundName ~= "") then
				local woundTemplate = CreateAEmitter(woundName);
				local wound = CreateAEmitter("Shock Wound");
				wound.BurstDamage = woundTemplate.BurstDamage;
				local targetRadius = woundTarget.IndividualRadius/2;
				local woundOffset = Vector(math.random(-targetRadius, targetRadius), math.random(-targetRadius, targetRadius));
				woundTarget:AddWound(wound, woundOffset, true);
			end
		end
	end
end

-- initialise tables with the first index set to start position!
function fillLightningTable(self, startPos, endPos, boltTable, mainBolt)
	local drawVector = SceneMan:ShortestDistance(startPos, endPos, true);
	local iters = math.ceil(drawVector.Magnitude/self.stepLength);
	local curveOffset = 2*math.random() - 1;
	local stepVector = drawVector:SetMagnitude(self.stepLength);
	local currentPos = startPos;
	
	for i = 2, iters, 1 do
		local jitter = Vector(0, math.random(-self.maxJitter, self.maxJitter)*(math.min(i, iters-i)/iters));
		local targetPos = currentPos + stepVector;
		
		boltTable[i] = targetPos + jitter:RadRotate(self.RotAngle);
		
		if (SceneMan:IsWithinBounds(currentPos.X, currentPos.Y, 0) == false) then
			break;
		end
		
		if (math.random() < self.branchChance) then
			local branchVector = SceneMan:ShortestDistance(currentPos, boltTable[i], true) * math.min(math.random(2, 5), math.max(0, iters - i - 1));
			local branchEnd = boltTable[i] + branchVector;
			SceneMan:CastStrengthRay(boltTable[i], branchVector, 0, branchEnd, 1, 0, true);
			local n = #self.branchTables+1;
			self.branchTables[n] = {boltTable[i]};
			self.branchScaleTable[n] = i/iters;
			fillLightningTable(self, boltTable[i], branchEnd, self.branchTables[n], false);
		end
		
		currentPos = targetPos;
	end
end

function drawLightning(self, boltTable, startScale, drawLastBit)
	local drawThiccness = self.thiccness;
	local thiccnessStep = self.thiccness/(math.max(#boltTable-1, 1));
	local drawColour = self.lingerColour;
	if (self.flashFactor > 1) then
		drawColour = self.flashColour;
	end
	
	local startThiccness = drawThiccness * self.flashFactor;
	local endThiccness = startThiccness;
	
	function drawLightningStep(startPos, endPos)
		startThiccness = drawThiccness * self.flashFactor;
		if (drawLastBit == false) then
			endThiccness = math.max((drawThiccness - thiccnessStep) * self.flashFactor, 0);
		else
			endThiccness = startThiccness;
		end
		
		drawThiccLineTaper(startPos, endPos, startThiccness, endThiccness, drawColour);
		--drawThiccLine(startPos, endPos, startThiccness, drawColour);
		PrimitiveMan:DrawCircleFillPrimitive(startPos, startThiccness/2, drawColour);
		
		if (startThiccness > 5) then
			PrimitiveMan:DrawCircleFillPrimitive(startPos, math.max(startThiccness-5, 0)/2, self.flashColour);
			drawThiccLineTaper(startPos, endPos, startThiccness - 5, math.max(endThiccness - 5, 0), self.flashColour);
			--drawThiccLine(startPos, endPos, startThiccness - 5, self.flashColour);
		end
		
		if (self.flashFactor > 1) then
			PrimitiveMan:DrawCircleFillPrimitive(startPos, startThiccness/2, drawColour);
		end
	end
		
	for i = 1, #boltTable-1, 1 do
		drawLightningStep(boltTable[i], boltTable[i+1]);
		if (drawLastBit == false) then
			drawThiccness = math.max(drawThiccness - thiccnessStep, 0);
		end
	end
	
	if (drawLastBit) then
		PrimitiveMan:DrawCircleFillPrimitive(boltTable[#boltTable], drawThiccness/2 * self.flashFactor, drawColour);
		local lastBit = SceneMan:ShortestDistance(boltTable[#boltTable], self.endPos, true);
		drawLightningStep(boltTable[#boltTable], boltTable[#boltTable] + lastBit);
		PrimitiveMan:DrawCircleFillPrimitive(self.endPos, drawThiccness * self.flashFactor, self.flashColour);
	end
end

function Update(self)
	if (self.tableGenerated == false) then
		self.tableGenerated = true;
		local rayVector = self.range:GetXFlipped(self.HFlipped):RadRotate(self.RotAngle);
		local obstacleRay = SceneMan:CastStrengthRay(self.Pos, rayVector, 0, self.endPos, 1, 0, true);
		rayVector = SceneMan:ShortestDistance(self.Pos, self.endPos, true);
		local rayTarget = SceneMan:CastMORay(self.Pos, rayVector, self.ID, self.Team, 0, false, 1);
		if (rayTarget ~= 255) then
			local placeholder = SceneMan:GetLastRayHitPos()
			self.endPos = Vector(placeholder.X, placeholder.Y);
			woundTarget(self, MovableMan:GetMOFromID(rayTarget));
		end
		
		fillLightningTable(self, self.Pos, self.endPos, self.boltTable, true);
	end
	
	if (#self.branchTables > 0) then
		for i = 1, #self.branchTables, 1 do
			drawLightning(self, self.branchTables[i], self.branchScaleTable[i], false);
		end
	end
	drawLightning(self, self.boltTable, 1, true);
	self.thiccness = self.thiccness - 1;
	
	if (self.flashFactor > 1) then
		self.flashFactor = 1;
	end
	
	if (self.thiccness <= 0) then
		self.ToDelete = true;
	end
end