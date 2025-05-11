local baseCorrosion = 100;
local bottomChance = 1;
local sideChance = 0.6;
local topChance = 0.2;
local smonkChance = 0.1;
local MOSmonkChance = 0.1;
local corrodeInterval = 108; -- frames/updates, 60 UPS; default 108

local Floor = math.floor;
local Abs = math.abs;
local Sqrt = math.sqrt;
local Cos = math.cos;
local Sin = math.sin;
local Atan2 = math.atan2;

local GetTerrMatter = SceneMan.GetTerrMatter;
local DislodgePixel = SceneMan.DislodgePixel;
local GetMaterialFromID = SceneMan.GetMaterialFromID;

local AddParticle = MovableMan.AddParticle;
local GetMOsInRadius = MovableMan.GetMOsInRadius;

local dummyTimer = Timer();
local IsPastSimMS = dummyTimer.IsPastSimMS;
local Reset = dummyTimer.Reset;
dummyTimer = nil;

local dummyParticle = CreateMOPixel("Drop Blood", "Base.rte");
local GetNumberValue = dummyParticle.GetNumberValue;
local SetNumberValue = dummyParticle.SetNumberValue;
local NumberValueExists = dummyParticle.NumberValueExists;
local RequestSyncedUpdate = dummyParticle.RequestSyncedUpdate;
dummyParticle = nil;

local randomTable = {};
local randomTableIterator = 0;
local randomTableSize = 500;

local sqrt2 = math.sqrt(2);

local fluidTable = {};

for i = 1, randomTableSize do
	table.insert(randomTable, math.random());
end

local function GetRandom()
	randomTableIterator = randomTableIterator + 1;
	if randomTableIterator > randomTableSize then
		randomTableIterator = 1;
	end

	return randomTable[randomTableIterator];
end

local function GetRandomRange(minimum, maximum)
	local diff = maximum - minimum;
	return (minimum + diff*GetRandom());
end

local function spawnSmonk(var)
	local smonk = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
	smonk.Pos = var.Pos;
	smonk.Vel = Vector(GetRandomRange(-2, 2), GetRandomRange(-2, 2));
	smonk.HitsMOs = false;
	AddParticle(MovableMan, smonk);
end

function OnCollideWithMO(self, hitMO, hitMORootParent)
	local var = self.var;
	if (var.corrosion > 0) then
		local MOCorrosion = GetNumberValue(hitMO, "GAYER_MOCorrosion");
		local corrosionFactor = (var.corrosion - MOCorrosion) / var.corrosion;

		if (MOCorrosion == 0 or GetRandom() < var.corrosion / MOCorrosion) then
			local corrosionToAdd = math.ceil(math.max((var.corrosion - MOCorrosion)*corrosionFactor*0.1, var.corrosion/100));
			local finalCorrosion = MOCorrosion + corrosionToAdd;
			SetNumberValue(hitMO, "GAYER_MOCorrosion", finalCorrosion);
			var.corrosion = var.corrosion - corrosionToAdd;

			if (GetRandom() < MOSmonkChance) then
				spawnSmonk(var);
			end

			local MOMat = hitMO.Material;
			local matSI = MOMat.StructuralIntegrity;
			local pixelCount = math.ceil(hitMO.IndividualMass / MOMat.DensityKGPerPixel);
	
			if (finalCorrosion >= matSI * pixelCount) then
				pixelCount = math.min(pixelCount, ToMOSprite(hitMO):GetSpriteWidth() * ToMOSprite(hitMO):GetSpriteHeight() * 0.5);
				if (IsMOSRotating(hitMO)) then
					hitMOSR = ToMOSRotating(hitMO);
					if (hitMO.UniqueID ~= hitMORootParent.UniqueID) then
						ToAttachable(hitMO):RemoveFromParent(false, false);
					end
					-- hitMOSR:GibThis();
					for attachable in hitMOSR.Attachables do
						attachable:RemoveFromParent(true, false);
					end
					hitMO.ToDelete = true;
				end

				local spawnPos = hitMO.Pos;

				for i = 0, pixelCount do
					local acidThiccsel = CreateMOPixel("Funny Acid", "GAYER.rte");
					acidThiccsel.Pos = spawnPos;
					acidThiccsel.Vel = hitMO.Vel + Vector(GetRandomRange(-2, 2), GetRandomRange(-2, 2));
					AddParticle(MovableMan, acidThiccsel);
					SetNumberValue(acidThiccsel, "GAYER_Corrosion", matSI / pixelCount)
				end
				hitMO.ToDelete = true;
			end
		end
	end
end

function Create(self)
	local var = {};
	var.firstSide = math.random(0, 1)*2 - 1;
	var.corrosion = 0;
	var.Pos = self.Pos;
	var.Vel = self.Vel;
	var.corrodeCounter = 0;
	var.corrodeTimerOffset = GetRandom() * corrodeInterval;
	var.pinCounter = 0;
	var.pinDuration = (corrodeInterval/2) + var.corrodeTimerOffset;
	var.fluidRange = 2;
	var.checkTable = {
		{0, 1, bottomChance},
		{var.firstSide, 0, sideChance},
		{-var.firstSide, 0, sideChance},
		{0, -1, topChance}
	};
	self.var = var;
	
	if (GetRandom() < 0.5) then
		self.PostEffectEnabled = false;
	end
end

function InitialiseFluidEntry(posX, posY)
	if (fluidTable[posX] == nil) then
		fluidTable[posX] = {};
	end
	
	if (fluidTable[posX][posY] == nil) then
		fluidTable[posX][posY] = 0;
	end
end

function ChangeFluidTable(posX, posY, value)
	InitialiseFluidEntry(posX, posY);

	fluidTable[posX][posY] = fluidTable[posX][posY] + value;
end

function ReadFluidTable(posX, posY)
	InitialiseFluidEntry(posX, posY);

	return fluidTable[posX][posY];
end

function ThreadedUpdate(self)
	local var = self.var;
	local blockageTable = {};
	if (var.pinCounter ~= nil) then
		local PINNY = self.PinStrength;
		var.pinCounter = var.pinCounter + 1;
		if ((var.pinCounter > var.pinDuration and PINNY > 0) or PINNY == 0) then
			self.PinStrength = 0;
			var.pinCounter = nil;
		end
	end
	
	if (var.pinCounter == nil) then
		local eggs = var.Pos.X;
		local why = var.Pos.Y;
		local fleggs = Floor(eggs);
		local fly = Floor(why);
		local extraVel = {};
		extraVel.X = 0;
		extraVel.Y = 0;

		if (var.oldPos ~= nil) then
			ChangeFluidTable(var.oldPos[1], var.oldPos[2], -1);
		end
		var.oldPos = {fleggs, fly};
		ChangeFluidTable(fleggs, fly, 1);

		-- Pressure mechanics
		local pressureTable = {};
		pressureTable.X = 0;
		pressureTable.Y = 0;
		local outwardPressure = ReadFluidTable(fleggs, fly) - 1;
		local particleCount = outwardPressure;
		local minAround = -1;
		local directions = 8;

		for x = -1, 1, 1 do
			for y = -1, 1, 1 do
				if (x == 0 and y == 0) == false then
					local particles = ReadFluidTable(fleggs + x, fly + y);
					if (minAround == -1 or particles < minAround) then
						minAround = particles;
					end
					if (particles == 0) then
						local terrain = GetTerrMatter(SceneMan, fleggs + x, fly + y);
						if (terrain ~= 0) then
							if (blockageTable[x] == nil) then
								blockageTable[x] = {};
							end

							blockageTable[x][y] = terrain;
							directions = directions - 1;
							goto continue;
						end
					end
					if (particles ~= outwardPressure) then
						particleCount = particleCount + particles;
						local factor = 1/(Abs(x) + Abs(y))
						local particleDifference = particles - outwardPressure;
						pressureTable.X = pressureTable.X - (particleDifference*x) * factor;
						pressureTable.Y = pressureTable.Y - (particleDifference*y) * factor;
					end
					::continue::
				end
			end
		end

		if (particleCount > 0 and minAround < outwardPressure) then
			extraVel.X = pressureTable.X/8;
			extraVel.Y = pressureTable.Y/8;
		end

		local scatter = (outwardPressure - minAround);
		local pressureDir = Atan2(pressureTable.Y, pressureTable.X);
		local arc = (3.1415/8)*directions;
		if (scatter ~= 0) then
			local scatterDir = GetRandomRange(-arc/2, arc/2) + pressureDir;
			local mag = GetRandomRange(0, scatter/directions);

			extraVel.X = extraVel.X + mag*Cos(scatterDir);
			extraVel.Y = extraVel.Y + mag*Sin(scatterDir);
		end

		-- Flow mechanics
		local fluidDirection = 0;
		
		if (blockageTable[0] ~= nil and blockageTable[0][1] ~= nil) then
			for q = -var.firstSide, var.firstSide, 2*var.firstSide do
				if (blockageTable[q] == nil or blockageTable[q][0] == nil) then
					local skip = false;
					for i = 1, var.fluidRange do
						if (skip == false) then
							local n = i * q;
							local trueEggs = eggs + n;
							if (blockageTable[n] == nil or blockageTable[n][1] == nil) then
								local matt = GetTerrMatter(SceneMan, trueEggs, why + 1);
								if (matt == 0) then
									fluidDirection = fluidDirection + 1/n;
									skip = true;
								end
							end
						end
					end
				end
			end
			
			fluidDirection = fluidDirection / (var.fluidRange*2 + 1);
			
			if (fluidDirection == 0) then
				fluidDirection = GetRandom() - 0.5;
			end
			
			extraVel.X = extraVel.X + fluidDirection;
		end

		if (extraVel.X ~= 0) then
			var.Vel.X = var.Vel.X + extraVel.X;
		end
	
		if (extraVel.Y ~= 0) then
			var.Vel.Y = var.Vel.Y + extraVel.Y;
		end
	end
	
	-- Corrosion mechanics
	var.corrodeCounter = var.corrodeCounter + 1;
	if (var.corrodeCounter > (corrodeInterval/2) + var.corrodeTimerOffset) then
		var.corrodeCounter = 0;
		var.corrodeTimerOffset = (corrodeInterval/2);
		local eggs = var.Pos.X;
		local why = var.Pos.Y;
		
		var.acidTable = {};
		if (NumberValueExists(self, "GAYER_Corrosion") == false) then
			var.corrosion = baseCorrosion;
		else
			var.corrosion = GetNumberValue(self, "GAYER_Corrosion");
		end
		
		for i = 1, #var.checkTable do
			if (GetRandom() < var.checkTable[i][3]) then
				local trueEggs = eggs + var.checkTable[i][1];
				local trueWhy = why + var.checkTable[i][2];
				local terrainID = nil;
				if (blockageTable[0] ~= nil and blockageTable[0][1] ~= nil and i == 1) then
					terrainID = blockageTable[0][1];
					blockageTable[0][1] = nil;
				else
					terrainID = GetTerrMatter(SceneMan, trueEggs, trueWhy);
				end
				if (terrainID ~= 0) then
					local matt = GetMaterialFromID(SceneMan, terrainID);
					local SI = matt.StructuralIntegrity;
					if (SI <= var.corrosion or GetRandom() <= (var.corrosion/SI)) then
						table.insert(var.acidTable, {trueEggs, trueWhy, SI});
					end
				end
			end
		end
		
		if (#var.acidTable > 0) then
			RequestSyncedUpdate(self)
			self.ToDelete = true;
		end
	end
end

function SyncedUpdate(self)
	local var = self.var;
	for i = 1, #var.acidTable do
		local eggs = var.acidTable[i][1];
		local why = var.acidTable[i][2];
		local pixels = {};
		if (DislodgePixel(SceneMan, eggs, why, true)) then
			local acidThiccsel = CreateMOPixel("Funny Acid", "GAYER.rte");
			local pos = Vector(eggs, why);
			acidThiccsel.Pos = pos;
			acidThiccsel.PinStrength = 10;
			table.insert(pixels, acidThiccsel);
			
			if (GetRandom() <= smonkChance) then
				spawnSmonk(var);
			end
			
			var.corrosion = var.corrosion - var.acidTable[i][3];
		end
		
		if (#pixels > 0) then
			var.corrosion = var.corrosion / #pixels;
			
			for i = 1, #pixels do
				AddParticle(MovableMan, pixels[i]);
				SetNumberValue(pixels[i], "GAYER_Corrosion", var.corrosion);
			end
		end
	end
end