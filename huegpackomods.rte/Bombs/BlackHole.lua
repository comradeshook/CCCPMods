dofile("huegpackomods.rte/Fx/TableVectorLibrary.lua");

local Rad = math.rad;
local Max = math.max;
local Min = math.min;
local Cos = math.cos;
local Sin = math.sin;
local Sqrt = math.sqrt;
local Ceil = math.ceil;
local Random = math.random;
local Atan2 = math.atan2;
local Pi = math.pi;

local tableA = VecNew(1, 2);
local tableB = VecNew(3, 4);

local test2 = VecShortestDistance(tableB, tableA, true);

local test3 = tableA + tableB;
local test4 = tableA - tableB;
local test5 = tableA * 2;
local test6 = tableA / 2;

local DislodgeRing = SceneMan.DislodgePixelRing;
local DislodgeCircle = SceneMan.DislodgePixelCircle;
local TableInsert = table.insert;

-- lol, lmao
local randomTable = {};
local randomTableIterator = 0;

for i = 1, 500 do
	TableInsert(randomTable, Random());
end

local function GetRandom()
	randomTableIterator = randomTableIterator + 1;
	if randomTableIterator > #randomTable then
		randomTableIterator = randomTableIterator - #randomTable;
	end
	
	return randomTable[randomTableIterator];
end

local accAtEventHorizon = 200 -- Pixels per frame
local twistAtEventHorizon = -32;
local baseRadius = 25;

local pronounTable = {"he/him", "she/her", "they/them", "it/its"};
local pronouns = pronounTable[Random(#pronounTable)];
local baseMass = 100000
local massCap = baseMass * 30
local flatEvaporationSpeed = (1 / 60) * (baseMass / 10) -- 10 seconds to lose base mass, flat rate
local minimumAccThreshold = 0.2;

local glowsEnabled = false; -- set this to true if you want the spinny fire to GLOW

local function accAtDist(distance, var)
	local divisor = Max(1, distance / var.eventHorizonRadius);
	local acc = accAtEventHorizon / (divisor * divisor);
	return acc
end

local function twistAtDistVec(distVec, var)
	local dist = VecGetMagnitude(distVec);
	local scalar = var.eventHorizonRadius/Max(var.eventHorizonRadius, (dist*dist));
	local twist = VecGetRadRotatedCopy(distVec, 3.1416 + twistAtEventHorizon * scalar);
	twist = twist + distVec;
	return twist;
end

function Create(self)
	self.Vel = Vector(0, 0)
	local massStored = self.Mass * (9 / 10);
	self:SetNumberValue("BlackHoleMassStored", massStored)
	self.Mass = self.Mass * (1 / 10)
	self.pronouns = pronounTable[Random(#pronounTable)];
	
	local massFactor = self.Mass / baseMass;
	local eventHorizonRadius = Ceil(massFactor * baseRadius);
	
	self.var = {};
	self.var.massFactor = massFactor;
	self.var.eventHorizonRadius = eventHorizonRadius;
	self.var.massStored = massStored;
	self.var.inhaleTable = {};
	self.var.otherTable = {};
	self.var.gibTable = {};
	self.var.deleteTable = {};
	self.var.humSound = CreateSoundContainer("Black Hole Hum", "huegpackomods.rte");
	
	self.var.humSound.Volume = 0.5
	self.var.humSound.Pos = self.Pos
	self.var.humSound:Play()
end

function SyncedUpdate(self)
	local var = self.var;
	--tracy.ZoneBeginN("black hole application");
	for i = 1, #var.inhaleTable do
		var.inhaleTable[i][1].X = var.inhaleTable[i][1].X + var.inhaleTable[i][2].X;
		var.inhaleTable[i][1].Y = var.inhaleTable[i][1].Y + var.inhaleTable[i][2].Y;
	end
	
	for i = 1, #var.otherTable do
		var.otherTable[i][1].X = var.otherTable[i][1].X + var.otherTable[i][2].X;
		var.otherTable[i][1].Y = var.otherTable[i][1].Y + var.otherTable[i][2].Y;
	end
	
	for i = 1, #var.gibTable do
		ToMOSRotating(var.gibTable[i]):GibThis();
	end
	
	for i = 1, #var.deleteTable do
		var.deleteTable[i].ToDelete = true;
	end
	
	var.inhaleTable = {};
	var.otherTable = {};
	var.gibTable = {};
	var.deleteTable = {};
	--tracy.ZoneEnd();
end

function ThreadedUpdate(self)
	local var = self.var;
	self.Vel = self.Vel * 0.9
	
	-- optimisation bullshit lmao
	local selfPos = self.Pos;
	local selfVel = self.Vel;
	local selfPosTable = VecToTable(selfPos);
	local selfVelTable = VecToTable(selfVel);
	local selfMass = self.Mass;
	local selfUID = self.UniqueID;
	
	if var.massStored > massCap then
		var.massStored = massCap
	end
	
	if var.massStored > 0 then
		self.Mass = self.Mass + Min(2000, var.massStored)
		var.massStored = var.massStored - Min(2000, var.massStored)
	end

	var.massFactor = self.Mass / baseMass
	var.eventHorizonRadius = Ceil(var.massFactor * baseRadius)

	var.humSound.Volume = Min(1, var.massFactor * 2)
	var.humSound.AttenuationStartDistance = var.eventHorizonRadius * 1.5 + 100
	var.humSound.Pos = self.Pos
	if not var.humSound:IsBeingPlayed() then
		var.humSound:Play()
	end

	-- Mass evaporation
	local scalingEvaporationSpeed = flatEvaporationSpeed * (self.Mass / baseMass)
	self.Mass = self.Mass - (flatEvaporationSpeed + scalingEvaporationSpeed)
	if self.Mass < 0 then
		self:GibThis()
	end
	
	local distance = Sqrt(accAtEventHorizon/minimumAccThreshold)*var.eventHorizonRadius;

	-- Draw the black hole
	local drawRadius = var.eventHorizonRadius + GetRandom()*(var.eventHorizonRadius / 20)
	PrimitiveMan:DrawCircleFillPrimitive(selfPos, drawRadius + Ceil(drawRadius / 10), 86)
	PrimitiveMan:DrawCircleFillPrimitive(selfPos, drawRadius + Ceil(drawRadius / 40), 222)
	PrimitiveMan:DrawCircleFillPrimitive(selfPos, drawRadius, 245)

	-- Spawn fancy effects
	for i = 1, 3 do
		local suckyParticle = CreateMOPixel("Black Hole Sucky Particle", "huegpackomods.rte")
		local suckyAngle = GetRandom() * Rad(360)
		suckyParticle.Pos = selfPos
			+ Vector(Min(var.eventHorizonRadius + 200, var.eventHorizonRadius * 3), 0):RadRotate(suckyAngle)
		suckyParticle.Vel = Vector(0, 0):RadRotate(suckyAngle)
		MovableMan:AddMO(suckyParticle)
	end

	for i = 1, 5 do
		local spinnyFire = CreateMOSRotating("Scalable Fire Sprite", "huegpackomods.rte")
		local fireAngle = GetRandom() * Rad(360)
		local scale = GetRandom();
		spinnyFire.Pos = selfPos + Vector(drawRadius + (1-scale)*drawRadius, 0):RadRotate(fireAngle)
		spinnyFire.Vel = Vector(-var.massFactor, 0):RadRotate(fireAngle)
		spinnyFire.Scale = var.massFactor * scale;
		spinnyFire.AirThreshold = 13371;
		spinnyFire.GlobalAccScalar = 0;
		spinnyFire.IgnoreTerrain = true;
		if (glowsEnabled) then
			spinnyFire:SetScreenEffectPath("Base.rte/Effects/Glows/FireGlow2.png");
			spinnyFire.EffectStartStrength = var.massFactor * scale;
			spinnyFire.EffectStopStrength = 0;
			spinnyFire.PostEffectEnabled = true;
		end
		MovableMan:AddMO(spinnyFire)
	end

	-- Terrain chew
	local chewVel = Vector(Min(490, 200 * var.massFactor), 0);
	for i = 1, 5 do
		local chewParticle1 = CreateMOPixel("Black Hole Particle");
		chewParticle1.Pos = selfPos;
		chewParticle1.Vel = chewVel:GetRadRotatedCopy(GetRandom()*Pi*2);
		MovableMan:AddParticle(chewParticle1);
		
		local chewParticle2 = CreateMOPixel("Black Hole Particle Sharp");
		chewParticle2.Pos = selfPos;
		chewParticle2.Vel = chewVel:GetRadRotatedCopy(GetRandom()*Pi*2);
		MovableMan:AddParticle(chewParticle2);
	end
	
	-- math.rad has been substituted with numbers for the tiniest of performance gains :V
	-- math.rad(180) = 3.1416
	-- math.rad(90) = 1.5708
	-- math.rad(-85) = -1.4835
	
	--tracy.ZoneBeginN("black hole calculations");
	for MO in MovableMan:GetMOsInRadius(selfPos, distance) do
		if not (MO.UniqueID == selfUID or MO.ToDelete) then
			-- grab things into locals for slight GAINZ
			local moPOS = MO.Pos;
			local moPOSTable = VecToTable(moPOS);
			local moVEL = MO.Vel;
			local moVELTable = VecToTable(moVEL);
			local distVec = VecShortestDistance(moPOSTable, selfPosTable, true)
			
			local dist = VecGetMagnitude(distVec);
			local scalar = var.eventHorizonRadius/Max(var.eventHorizonRadius, (dist*dist));
			local acc = accAtDist(dist, var)
			local twist = twistAtDistVec(distVec, var);
			local newPos = VecCopy(twist);
			
			local MOAT = MO.AirThreshold;
			
			if MOAT < 13371 then -- gotta detect those effect particles somehow lol
				local moRadius = MO.Radius;
				local moMass = MO.Mass;
				local moName = MO.PresetName;
				local motionSinceLastFrame = VecCopy(moVELTable);
				motionSinceLastFrame = motionSinceLastFrame / 3;
				
				if dist < var.eventHorizonRadius + VecGetMagnitude(moVELTable) / 6 then
					if moName ~= "New Black Hole" then
						var.massStored = var.massStored + moMass
						TableInsert(var.deleteTable, MO);
					else
						if moMass < selfMass or (moMass == selfMass and MO.UniqueID < selfUID) then
							var.massStored = var.massStored + moMass + ToMOSRotating(MO):GetNumberValue("BlackHoleMassStored")
							self.Vel = Vector(0, 0)
							TableInsert(var.deleteTable, MO);
						end
					end
				end
				
				local accVec = VecCopy(distVec);
				VecSetMagnitude(accVec, acc);
				VecSetMagnitude(twist, acc);
				accVec = accVec + twist;
				local nextDist = VecCopy(distVec);
				nextDist = nextDist - ((moVELTable + accVec) / 3);
				nextDist = VecGetMagnitude(nextDist);
				local normalNextDist = VecCopy(distVec);
				normalNextDist = normalNextDist - motionSinceLastFrame;
				normalNextDist = VecGetMagnitude(normalNextDist);
				if nextDist > normalNextDist then
					accVec = accVec * (normalNextDist/nextDist);
				end
				
				local tidalForce = accAtDist(dist - moRadius, var) - accAtDist(dist + moRadius, var)

				if moName ~= "New Black Hole" then
					accVec = accVec + VecSetMagnitude(distVec, acc);
					
					local gibRadius = (var.eventHorizonRadius + VecGetMagnitude(moVELTable) / 6)*1.5;
					
					local MOGIL = MO.GibImpulseLimit;
					if IsMOSRotating(MO) and (dist < gibRadius or (MOGIL and MOGIL < tidalForce*2)) then
						TableInsert(var.gibTable, MO);
					end
				else
					if MO.ToDelete == false then
						accVec = accVec + VecSetMagnitude(distVec, Min(acc, 30) * Min(selfMass / moMass, 1) * 0.5);
					end
				end
				
				TableInsert(var.inhaleTable, {moVEL, accVec});
			else
				TableInsert(var.otherTable, {moPOS, newPos});
			end
		end
	end
	--tracy.ZoneEnd();
	
	--tracy.ZoneBeginN("black hole eat terrain new");
	DislodgeRing(SceneMan, selfPos, var.eventHorizonRadius, var.eventHorizonRadius - Min(Max(5, selfVel.Magnitude/2), var.eventHorizonRadius), true);
	--tracy.ZoneEnd();
	
	-- keeping this for posterity but unfortunately it ruins performance :V
	--tracy.ZoneBeginN("black hole twist terrain");
	--local twistFactor = Random();
	--for pixel in DislodgeRing(SceneMan, selfPos, var.eventHorizonRadius, var.eventHorizonRadius + 1.5 * var.eventHorizonRadius * twistFactor) do
	--	pixel.ToSettle = true;
	--	local pixelPos = pixel.Pos;
	--	local pos = VecToTable(pixelPos);
	--	local distVec = VecShortestDistance(pos, selfPosTable, true);
	--	distVec = VecGetPerpendicular(distVec);
	--	VecSetMagnitude(distVec, 3);
	--	pixelPos.X = pixelPos.X + distVec.X;
	--	pixelPos.Y = pixelPos.Y + distVec.Y;
	--end
	--tracy.ZoneEnd();

	self:SetNumberValue("BlackHoleMassStored", var.massStored)
	
	self:RequestSyncedUpdate();
end

function Destroy(self)
	self.var.humSound:Stop()
end
