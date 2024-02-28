local function drawThiccLineTaper(startPos, endPos, thiccnessStart, thiccnessEnd, color)
	local dirVector = SceneMan:ShortestDistance(startPos, endPos, true):Perpendicularize()
	local pos1 = startPos + dirVector:SetMagnitude((thiccnessStart - 1)/2)
	local pos2 = startPos - dirVector:SetMagnitude((thiccnessStart - 1)/2)
	local pos3 = endPos + dirVector:SetMagnitude((thiccnessEnd - 1)/2)
	local pos4 = endPos - dirVector:SetMagnitude((thiccnessEnd - 1)/2)

	PrimitiveMan:DrawTriangleFillPrimitive(pos1, pos2, pos3, color)
	PrimitiveMan:DrawTriangleFillPrimitive(pos3, pos4, pos2, color)
end

local function drawTrianglePoint(startPos, endPos, thiccnessStart, color)
	local dirVector = SceneMan:ShortestDistance(startPos, endPos, true):Perpendicularize()
	local pos1 = startPos + dirVector:SetMagnitude((thiccnessStart - 1)/2)
	local pos2 = startPos - dirVector:SetMagnitude((thiccnessStart - 1)/2)
	local pos3 = endPos

	PrimitiveMan:DrawTriangleFillPrimitive(pos1, pos2, pos3, color)
end

local Random = math.random;

local stepLength = 20; --pixels
local maxJitter = 40;
local flashColour = 166;
local lingerColour = 198;
local darkColour = 194;
local branchChance = 0.5;
local chainDelay = 50; --ms

function Create(self)
	self.endPos = Vector(self.Pos.X, self.Pos.Y);
	self.boltTable = {
		{self.Pos, nil, 1} -- Pos, branchTable, scale
	};
	self.chainTable = nil;
	self.lastChainHitPos = nil;
	self.tableGenerated = false;
	self.hitSomething = false;
	self.flashFactor = 3;
	
	self.canChain = true;
end

local function getAllValidLimbs(target, targetTable)
	if (target.GetsHitByMOs and ToMOSRotating(target):GetEntryWoundPresetName() ~= "") then
		targetTable[#targetTable+1] = target;
	end
	
	for limb in target.Attachables do
		getAllValidLimbs(limb, targetTable);
	end
end

local function woundTarget(self, target)
	local realTarget = ToMOSRotating(target);
	local rootMO = realTarget:GetRootParent();
	local targetTable = {};
	getAllValidLimbs(ToMOSRotating(rootMO), targetTable);
	
	if MovableMan:IsActor(rootMO) then
		local actor = ToActor(rootMO);
		if actor.PainSound then
			actor.PainSound:Play(actor.Pos);
		end
		
		if (IsAHuman(actor) or IsACrab(actor)) and actor:IsStatus(0) then
			actor.Status = 1;
			actor.Vel.Y = actor.Vel.Y - Random(6,12);
			actor.AngularVel = actor.AngularVel + Random(-9, -15);
		end
	end
	
	for i = 1, (self.scatterWounds + self.directWounds), 1 do
		if (i > self.scatterWounds) then
			local woundName = realTarget:GetEntryWoundPresetName();
			if (woundName ~= "") then
				local woundTemplate = CreateAEmitter(woundName);
				local wound = CreateAEmitter("Shock Wound");
				wound.BurstDamage = woundTemplate.BurstDamage;
				local targetRadius = realTarget.IndividualRadius/2;
				local woundOffset = Vector(Random(-targetRadius, targetRadius), Random(-targetRadius, targetRadius));
				realTarget:AddWound(wound, woundOffset, true);
			end
		else
			local woundTarget = targetTable[Random(#targetTable)];
			local woundName = woundTarget:GetEntryWoundPresetName();
			if (woundName ~= "") then
				local woundTemplate = CreateAEmitter(woundName);
				local wound = CreateAEmitter("Shock Wound");
				wound.BurstDamage = woundTemplate.BurstDamage;
				local targetRadius = woundTarget.IndividualRadius/2;
				local woundOffset = Vector(Random(-targetRadius, targetRadius), Random(-targetRadius, targetRadius));
				woundTarget:AddWound(wound, woundOffset, true);
			end
		end
	end
end

-- initialise tables with the first index set to start position!
local function fillLightningTable(self, startPos, endPos, boltTable, mainBolt)
	local drawVector = SceneMan:ShortestDistance(startPos, endPos, true);
	local iters = math.ceil(drawVector.Magnitude/stepLength);
	local curveOffset = 2*Random() - 1;
	local stepVector = drawVector:SetMagnitude(stepLength);
	local currentPos = startPos;
	local startScale = boltTable[1][3] or 1;
	
	for i = 2, iters, 1 do
		local jitter = Vector(0, Random(-maxJitter, maxJitter)*(math.min(i, iters-i)/iters));
		local targetPos = currentPos + stepVector;
		local scale = (1-(i/iters))*startScale;
		
		boltTable[i] = {targetPos + jitter:RadRotate(self.RotAngle), nil, (mainBolt and 1) or scale};
		
		if (SceneMan:IsWithinBounds(currentPos.X, currentPos.Y, 0) == false) then
			break;
		end
		
		if (Random() < branchChance) then
			local branchVector = SceneMan:ShortestDistance(currentPos, boltTable[i][1], true) * math.min(Random(2, 5), math.max(0, iters - i - 1));
			local branchEnd = boltTable[i][1] + branchVector;
			
			SceneMan:CastStrengthRay(boltTable[i][1], branchVector, 0, branchEnd, 1, 0, true);
			boltTable[i][2] = {{boltTable[i][1], nil, (mainBolt and startScale) or scale}};
			fillLightningTable(self, boltTable[i][1], branchEnd, boltTable[i][2], false);
		end
		
		currentPos = targetPos;
	end
end

local function drawLightning(self, boltTable, startScale, drawLastBit)
	local thiccnessStep = self.thiccness/(math.max(#boltTable-1, 1));
	local drawColour = lingerColour;
	if (self.flashFactor > 1) then
		drawColour = flashColour;
	end
	local drawThiccness = self.thiccness * self.flashFactor;
	
	local startThiccness = drawThiccness;
	local endThiccness = startThiccness;
	
	function drawLightningStep(startStep, endStep, thiccnessOffset, colour)
		local startPos = startStep[1];
		local endPos = endStep[1];
		startThiccness = drawThiccness * (startStep[3] or startScale) + thiccnessOffset;
		if (drawLastBit == false) then
			endThiccness = drawThiccness * (endStep[3] or startScale) + thiccnessOffset;
		else
			endThiccness = startThiccness;
		end
		
		if (startThiccness > 0) then
			if (startThiccness > 1) then
				if (endThiccness > 1) then
					drawThiccLineTaper(startPos, endPos, startThiccness, endThiccness, colour);
				else
					drawTrianglePoint(startPos, endPos, startThiccness, colour);
				end
				PrimitiveMan:DrawCircleFillPrimitive(startPos, startThiccness/2, colour);
			else
				local darkerColour = darkColour + math.floor(startThiccness * (lingerColour - darkColour));
				if (startThiccness > 0.5) then
					PrimitiveMan:DrawLinePrimitive(startPos, endPos, colour);
				else
					PrimitiveMan:DrawLinePrimitive(startPos, endPos, darkColour);
				end
			end
		end
	end
	
	if (#boltTable > 0) then
		for i = 1, #boltTable-1, 1 do
			drawLightningStep(boltTable[i], boltTable[i+1], 0, drawColour);
			
			if (boltTable[i][2]) then
				drawLightning(self, boltTable[i][2], boltTable[i][3], false);
			end
		end
	end
	
	local lastBit = SceneMan:ShortestDistance(boltTable[#boltTable][1], self.endPos, true);
	
	if (drawLastBit) then
		PrimitiveMan:DrawCircleFillPrimitive(boltTable[#boltTable][1], drawThiccness/2, drawColour);
		drawLightningStep(boltTable[#boltTable], {boltTable[#boltTable][1] + lastBit, nil, boltTable[#boltTable][3]}, 0, drawColour);
	end
	
	if (#boltTable > 0) then
		for i = 1, #boltTable-1, 1 do
			drawLightningStep(boltTable[i], boltTable[i+1], -5, flashColour);
		end
	end
	
	if (drawLastBit) then
		PrimitiveMan:DrawCircleFillPrimitive(boltTable[#boltTable][1], math.max(drawThiccness-5, 0)/2, drawColour);
		local lastBit = SceneMan:ShortestDistance(boltTable[#boltTable][1], self.endPos, true);
		drawLightningStep(boltTable[#boltTable], {boltTable[#boltTable][1] + lastBit, nil, boltTable[#boltTable][3]}, -5, flashColour);
		PrimitiveMan:DrawCircleFillPrimitive(self.endPos, drawThiccness, flashColour);
	end
end

function Update(self)
	local selfPos = self.Pos;
	if (self.tableGenerated == false) then
		self.tableGenerated = true;
		self.chainTimer = Timer();
		
		local range = Vector(self:GetNumberValue("DonkLightningRange"), 0);
		self.thiccness = self:GetNumberValue("DonkLightningThickness");
		self.scatterWounds = self:GetNumberValue("DonkLightningScatterWounds");
		self.directWounds = self:GetNumberValue("DonkLightningDirectWounds");
		self.chainRangeInterval = self:GetNumberValue("DonkLightningChainRange");
		self.chainPowerMax = self:GetNumberValue("DonkLightningChainPower");
		self.directTarget = MovableMan:FindObjectByUniqueID(self:GetNumberValue("DonkLightningDirectTarget"));
		self.chainPower = self.chainPowerMax;
		
		if (self.directTarget) then
			self.endPos = Vector(self.directTarget.Pos.X, self.directTarget.Pos.Y);
			woundTarget(self, self.directTarget);
			self.hitSomething = true;
		else
			local rayVector = range:GetXFlipped(self.HFlipped):RadRotate(self.RotAngle);
			self.obstacleRay = SceneMan:CastStrengthRay(selfPos, rayVector, 0, self.endPos, 0, 0, true);
			rayVector = SceneMan:ShortestDistance(selfPos, self.endPos, true);
			local rayTarget = SceneMan:CastMORay(selfPos, rayVector, self.ID, self.Team, 0, false, 1);
			if (rayTarget ~= 255) then
				local placeholder = SceneMan:GetLastRayHitPos()
				self.endPos = Vector(placeholder.X, placeholder.Y);
				self.primaryTargetID = MovableMan:GetMOFromID(rayTarget):GetRootParent().UniqueID;
				woundTarget(self, MovableMan:GetMOFromID(rayTarget));
			end
			
			self.hitSomething = self.obstacleRay or (rayTarget ~= 255);
		end
		
		fillLightningTable(self, selfPos, self.endPos, self.boltTable, self.hitSomething);
	elseif (self.chainPower > 0 and self.chainTimer:IsPastSimMS(chainDelay)) then
		self.chainTimer:Reset();
		local startPos = self.lastChainHitPos or self.endPos;
		if (self.chainTable == nil) then
			self.chainTable = {};
			for actor in MovableMan.Actors do
				if (self.primaryTargetID == nil or self.primaryTargetID ~= actor.UniqueID) then
					self.chainTable[#self.chainTable+1] = actor;
				end
			end
		end
		
		if (#self.chainTable == 0) then
			self.chainPower = 0;
		else
			local targetIndex = nil;
			local targetVector = nil;
			
			for i = 1, #self.chainTable, 1 do
				local actor = self.chainTable[i];
				local distVec = SceneMan:ShortestDistance(startPos, actor.Pos, true);
				if (distVec.Magnitude <= self.chainRangeInterval*self.chainPower) then
					if (targetVector == nil or distVec.Magnitude < targetVector.Magnitude) then
						local blockCheck = SceneMan:CastStrengthRay(startPos, distVec, 3, Vector(0, 0), 1, 0, true);
						if (blockCheck == false) then
							targetIndex = i;
							targetVector = distVec;
						end
					end
				end
			end
			
			if (targetIndex and targetVector) then
				local target = self.chainTable[targetIndex];
				self.chainPower = self.chainPower - math.floor(targetVector.Magnitude/self.chainRangeInterval);
				
				table.remove(self.chainTable, targetIndex);
				
				local chainBolt = CreateMOSRotating("Lightning Shot", "Donks.rte");
				chainBolt:SetNumberValue("DonkLightningRange", targetVector.Magnitude);
				chainBolt:SetNumberValue("DonkLightningScatterWounds", math.ceil(self.scatterWounds * (self.chainPower/self.chainPowerMax)));
				chainBolt:SetNumberValue("DonkLightningDirectWounds", 0);
				chainBolt:SetNumberValue("DonkLightningChainRange", 0);
				chainBolt:SetNumberValue("DonkLightningChainPower", 0);
				chainBolt:SetNumberValue("DonkLightningDirectTarget", target.UniqueID);
				chainBolt.Pos = target.Pos - targetVector;
				chainBolt.RotAngle = targetVector.AbsRadAngle;
				MovableMan:AddMO(chainBolt);
				
				self.lastChainHitPos = target.Pos;
			else
				self.chainPower = 0;
			end
		end
	end
	
	if (self.thiccness > 0) then
		drawLightning(self, self.boltTable, 1, self.hitSomething);
		self.thiccness = self.thiccness - 1;
	end
	
	if (self.flashFactor > 1) then
		self.flashFactor = 1;
	end
	
	if (self.thiccness <= 0 and self.chainPower <= 0) then
		self.ToDelete = true;
	end
end