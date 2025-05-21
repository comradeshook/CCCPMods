local useAltCorrosion = false;

local baseCorrosion = 100;
local bottomChance = 0.6;
local sideChance = 1;
local topChance = 0.2;
local pinChance = 0.2;
local smonkChance = 0.1;
local MOSmonkChance = 0.1;
local corrodeInterval = 108; -- frames/updates, 60 UPS; default 108

if (useAltCorrosion == true) then
	bottomChance = 1;
	sideChance = 0.6;
	topChance = 0.2;
	pinChance = 1;
end

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

local fluidTable = {};
local fluidCheckOrder = {
	{0, -1},
	{-1, 0},
	{1, 0},
	{0, 1},
	{-1, -1},
	{1, -1},
	{-1, 1},
	{1, 1}
}

local randomTable = {};
local randomTableIterator = 0;
local randomTableSize = 500;

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
	return (minimum + (maximum - minimum)*GetRandom());
end

local function spawnSmonk(var)
	local smonk = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
	smonk.Pos = var.Pos;
	smonk.Vel = Vector(GetRandomRange(-2, 2), GetRandomRange(-2, 2));
	smonk.HitsMOs = false;
	AddParticle(MovableMan, smonk);
	smonk = nil;
end

-- function OnCollideWithMO(self, hitMO, hitMORootParent)
-- 	local var = self.var;
-- 	if (var.corrosion > 0) then
-- 		local MOCorrosion = GetNumberValue(hitMO, "GAYER_MOCorrosion");
-- 		local corrosionFactor = (var.corrosion - MOCorrosion) / var.corrosion;

-- 		if (MOCorrosion == 0 or GetRandom() < var.corrosion / MOCorrosion) then
-- 			local corrosionToAdd = math.ceil(math.max((var.corrosion - MOCorrosion)*corrosionFactor*0.1, var.corrosion/100));
-- 			local finalCorrosion = MOCorrosion + corrosionToAdd;
-- 			SetNumberValue(hitMO, "GAYER_MOCorrosion", finalCorrosion);
-- 			var.corrosion = var.corrosion - corrosionToAdd;

-- 			if (GetRandom() < MOSmonkChance) then
-- 				spawnSmonk(var);
-- 			end

-- 			local MOMat = hitMO.Material;
-- 			local matSI = MOMat.StructuralIntegrity;
-- 			local pixelCount = math.ceil(hitMO.IndividualMass / MOMat.DensityKGPerPixel);
	
-- 			if (finalCorrosion >= matSI * pixelCount) then
-- 				pixelCount = math.min(pixelCount, ToMOSprite(hitMO):GetSpriteWidth() * ToMOSprite(hitMO):GetSpriteHeight() * 0.5);
-- 				if (IsMOSRotating(hitMO)) then
-- 					hitMOSR = ToMOSRotating(hitMO);
-- 					if (hitMO.UniqueID ~= hitMORootParent.UniqueID) then
-- 						ToAttachable(hitMO):RemoveFromParent(false, false);
-- 					end
-- 					-- hitMOSR:GibThis();
-- 					for attachable in hitMOSR.Attachables do
-- 						attachable:RemoveFromParent(true, false);
-- 					end
-- 					hitMO.ToDelete = true;
-- 				end

-- 				local spawnPos = hitMO.Pos;

-- 				for i = 0, pixelCount do
-- 					local acidThiccsel = CreateMOPixel("Funny Acid", "GAYER.rte");
-- 					acidThiccsel.Pos = spawnPos;
-- 					acidThiccsel.Vel = hitMO.Vel + Vector(GetRandomRange(-2, 2), GetRandomRange(-2, 2));
-- 					AddParticle(MovableMan, acidThiccsel);
-- 					SetNumberValue(acidThiccsel, "GAYER_Corrosion", matSI / pixelCount)
-- 				end
-- 				hitMO.ToDelete = true;
-- 			end
-- 		end
-- 	end
-- end

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

local function InitialiseFluidEntry(posX, posY)
	if (fluidTable[posX] == nil) then
		fluidTable[posX] = {};
	end
	
	if (fluidTable[posX][posY] == nil) then
		fluidTable[posX][posY] = 0;
	end
end

local function ChangeFluidTable(posX, posY, value)
	InitialiseFluidEntry(posX, posY);
		
	fluidTable[posX][posY] = fluidTable[posX][posY] + value;
end

local function ReadFluidTable(posX, posY)
	InitialiseFluidEntry(posX, posY)

	return fluidTable[posX][posY];
end

function ThreadedUpdate(self)
	local var = self.var;
	if (var.blockageTable == nil) then
		var.blockageTable = {};
	else
		for x = -1, 1 do
			if (var.blockageTable[x] ~= nil) then
				for y = -1, 1 do
					if (var.blockageTable[x][y] ~= nil) then
						var.blockageTable[x][y] = nil;
					end
				end
			end
		end
	end
		
	var.outwardPressure = 0;
	var.eggs = var.Pos.X;
	var.why = var.Pos.Y;

	-- tracy.ZoneBeginN("acid pin check")
	if (var.pinCounter ~= nil) then
		var.PINNY = self.PinStrength;
		var.pinCounter = var.pinCounter + 1;
		if ((var.pinCounter > var.pinDuration and var.PINNY > 0) or var.PINNY == 0) then
			self.PinStrength = 0;
			var.pinCounter = nil;
		end
	end
	-- tracy.ZoneEnd();
	
	if (var.pinCounter == nil) then
		-- tracy.ZoneBeginN("acid motion init")
		var.fleggs = Floor(var.eggs);
		var.fly = Floor(var.why);
		var.extraVelX = 0;
		var.extraVelY = 0;
		-- tracy.ZoneEnd();

		-- tracy.ZoneBeginN("acid update table")
		if (var.oldPosX ~= nil and var.oldPosY ~= nil) then
			ChangeFluidTable(var.oldPosX, var.oldPosY, -1);
		end
		var.oldPosX = var.fleggs;
		var.oldPosY = var.fly;
		ChangeFluidTable(var.fleggs, var.fly, 1);
		-- tracy.ZoneEnd();

		-- Pressure mechanics
		var.pressureX = 0;
		var.pressureY = 0;
		var.outwardPressure = ReadFluidTable(var.fleggs, var.fly) - 1;
		var.particleCount = var.outwardPressure;
		var.minAround = -1;
		var.directions = 8;
		var.airborne = true;

		for i = 1, #fluidCheckOrder do
			var.x = fluidCheckOrder[i][1];
			var.y = fluidCheckOrder[i][2];
			var.particles = ReadFluidTable(var.fleggs + var.x, var.fly + var.y);
			if (var.minAround == -1 or var.particles < var.minAround) then
				var.minAround = var.particles;
			end
			if (var.particles == 0) then
				var.toCheck = false;
				if (i <= 4) then
					var.toCheck = true;
				else
					for toCheckX = -1, 1 do
						for toCheckY = -1, 1 do
							if ((var.x == toCheckX or var.y == toCheckY) == false and (toCheckX + toCheckY) % 2 ~= 0) then
								if (var.blockageTable[toCheckX + var.x] ~= nil and var.blockageTable[toCheckX + var.x][toCheckY + var.y] ~= nil) then
									var.toCheck = true;
									goto outOfLoop;
								end
							end
						end
					end
				end
				::outOfLoop::

				if (var.toCheck == true) then
					var.terrain = GetTerrMatter(SceneMan, var.fleggs + var.x, var.fly + var.y);
				else
					var.terrain = 0;
				end

				if (var.terrain ~= 0) then
					if (var.blockageTable[var.x] == nil) then
						var.blockageTable[var.x] = {};
					end

					var.blockageTable[var.x][var.y] = var.terrain;
					var.directions = var.directions - 1;
					goto continue;
				end
			end
			if (var.particles ~= var.outwardPressure) then
				var.particleCount = var.particleCount + var.particles;
				var.factor = 1/(Abs(var.x) + Abs(var.y))
				var.particleDifference = var.particles - var.outwardPressure;
				var.pressureX = var.pressureX - (var.particleDifference*var.x) * var.factor;
				var.pressureY = var.pressureY - (var.particleDifference*var.y) * var.factor;
			end
			::continue::
		end

		if (var.particleCount > 0 and var.minAround < var.outwardPressure) then
			var.extraVelX = var.pressureX/8;
			var.extraVelY = var.pressureY/8;
		end

		var.scatter = (var.outwardPressure - var.minAround);
		var.pressureDir = Atan2(var.pressureY, var.pressureX);
		var.arc = (3.1415/8)*var.directions;
		if (var.scatter > 0) then
			var.scatterDir = GetRandomRange(-var.arc/2, var.arc/2) + var.pressureDir;
			var.mag = GetRandomRange(0, var.scatter/var.directions);

			var.extraVelX = var.extraVelX + var.mag*Cos(var.scatterDir);
			var.extraVelY = var.extraVelY + var.mag*Sin(var.scatterDir);
		end

		-- Flow mechanics
		var.fluidDirection = 0;
		
		-- tracy.ZoneBeginN("acid flow mechanics")
		if (var.blockageTable[0] ~= nil and var.blockageTable[0][1] ~= nil) then
			for q = -var.firstSide, var.firstSide, 2*var.firstSide do
				if (var.blockageTable[q] == nil or var.blockageTable[q][0] == nil) then
					var.skip = false;
					var.storedDir = 0;
					for i = var.fluidRange, 1, -1 do
						if (var.skip == false) then
							var.n = i * q;
							var.trueEggs = var.eggs + var.n;
							if (var.blockageTable[var.n] == nil or var.blockageTable[var.n][1] == nil) then
								var.matt = GetTerrMatter(SceneMan, var.trueEggs, var.why + 1);
								if (var.matt ~= 0) then
									var.skip = true;
								else
									var.storedDir = 1/var.n;
								end
							else
								var.skip = true;
							end
						end
					end
					var.fluidDirection = var.fluidDirection + var.storedDir;
				end
			end
			
			var.fluidDirection = var.fluidDirection / (var.fluidRange*2 + 1);
			
			if (var.fluidDirection == 0) then
				var.fluidDirection = GetRandom() - 0.5;
			end
			
			var.extraVelX = var.extraVelX + var.fluidDirection;
		end
		-- tracy.ZoneEnd();

		-- tracy.ZoneBeginN("acid velocity update")
		if (var.extraVelX ~= 0) then
			var.Vel.X = var.Vel.X + var.extraVelX;
		end
	
		if (var.extraVelY ~= 0) then
			var.Vel.Y = var.Vel.Y + var.extraVelY;
		end
		-- tracy.ZoneEnd();
	end
	
	-- Corrosion mechanics
	-- tracy.ZoneBeginN("acid corrosion")
	var.corrodeCounter = var.corrodeCounter + 1;
	if (var.corrodeCounter > (corrodeInterval/2) + var.corrodeTimerOffset) then
		var.corrodeCounter = 0;
		var.corrodeTimerOffset = (corrodeInterval/2);
		
		if (var.acidTable == nil) then
			var.acidTable = {};
		end
		if (NumberValueExists(self, "GAYER_Corrosion") == false) then
			var.corrosion = baseCorrosion;
		else
			var.corrosion = GetNumberValue(self, "GAYER_Corrosion");
		end
		
		for i = 1, #var.checkTable do
			var.chanceRoll = GetRandom();
			var.chance = var.checkTable[i][3];
			if (var.chanceRoll < var.chance and (i ~= 1 or var.chanceRoll < var.chance / (var.outwardPressure + 1))) then
				var.trueEggs = var.eggs + var.checkTable[i][1];
				var.trueWhy = var.why + var.checkTable[i][2];
				var.terrainID = nil;
				if (var.blockageTable[0] ~= nil and var.blockageTable[0][1] ~= nil and i == 1) then
					var.terrainID = var.blockageTable[0][1];
					var.blockageTable[0][1] = nil;
				else
					var.terrainID = GetTerrMatter(SceneMan, var.trueEggs, var.trueWhy);
				end
				if (var.terrainID ~= 0) then
					var.matt = GetMaterialFromID(SceneMan, var.terrainID);
					var.SI = var.matt.StructuralIntegrity;
					if (var.SI <= var.corrosion or GetRandom() <= (var.corrosion/var.SI)) then
						table.insert(var.acidTable, {var.trueEggs, var.trueWhy, var.SI});
					end
				end
			end
		end
		
		if (#var.acidTable > 0) then
			RequestSyncedUpdate(self)
			self.ToDelete = true;
		end
	end
	-- tracy.ZoneEnd();
end

function SyncedUpdate(self)
	-- tracy.ZoneBeginN("acid synced update")
	local var = self.var;
	if (var.pixels == nil) then
		var.pixels = {};
	end

	for i = 1, #var.acidTable do
		var.eggs = var.acidTable[i][1];
		var.why = var.acidTable[i][2];
		if (DislodgePixel(SceneMan, var.eggs, var.why, true)) then
			var.acidThiccsel = CreateMOPixel("Funny Acid", "GAYER.rte");
			var.pixelPos = Vector(var.eggs, var.why);
			var.acidThiccsel.Pos = var.pixelPos;
			if (GetRandom() < pinChance) then
				var.acidThiccsel.PinStrength = 10;
			end
			table.insert(var.pixels, var.acidThiccsel);
			
			if (GetRandom() <= smonkChance) then
				spawnSmonk(var);
			end
			
			var.corrosion = var.corrosion - var.acidTable[i][3];
		end
		
		if (#var.pixels > 0) then
			var.corrosion = var.corrosion / #var.pixels;
			
			local iters = #var.pixels;
			for i = 1, iters do
				local piccsel = table.remove(var.pixels);
				AddParticle(MovableMan, piccsel);
				SetNumberValue(piccsel, "GAYER_Corrosion", var.corrosion);
			end
		end
	end
	-- tracy.ZoneEnd();
end