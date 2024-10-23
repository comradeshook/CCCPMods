local baseCorrosion = 100;
local bottomChance = 0.6;
local sideChance = 1;
local topChance = 0.2;
local smonkChance = 0.1;
local corrodeInterval = 108; -- frames/updates, 60 UPS; default 108

local GetTerrMatter = SceneMan.GetTerrMatter;
local DislodgePixel = SceneMan.DislodgePixel;
local GetMaterialFromID = SceneMan.GetMaterialFromID;

local AddParticle = MovableMan.AddParticle;

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

function Create(self)
	local var = {};
	var.firstSide = GetRandom(0, 1)*2 - 1;
	var.corrosion = 0;
	var.Pos = self.Pos;
	var.Vel = self.Vel;
	var.corrodeCounter = 0;
	var.corrodeTimerOffset = GetRandom() * corrodeInterval;
	var.pinCounter = 0;
	var.pinDuration = (corrodeInterval/2) + var.corrodeTimerOffset;
	var.fluidRange = 2;
	var.flow = false;
	var.checkTable = {
		{0, 1, bottomChance},
		{var.firstSide, 0, sideChance},
		{-var.firstSide, 0, sideChance},
		{0, -1, topChance}
	};
	var.blockageTable = {};
	self.var = var;
	
	if (GetRandom() < 0.5) then
		self.PostEffectEnabled = false;
	end
end

function OnCollideWithTerrain(self, nah)
	local var = self.var;
	var.flow = true;
end

function ThreadedUpdate(self)
	local var = self.var;
	if (var.pinCounter ~= nil) then
		local PINNY = self.PinStrength;
		var.pinCounter = var.pinCounter + 1;
		if ((var.pinCounter > var.pinDuration and PINNY > 0) or PINNY == 0) then
			self.PinStrength = 0;
			var.pinCounter = nil;
		end
	end
	
	if (var.flow == true and var.pinCounter == nil) then
		local eggs = var.Pos.X;
		local why = var.Pos.Y;
		local fluidDirection = 0;
		var.blockageTable[0] = GetTerrMatter(SceneMan, eggs + var.checkTable[1][1], why + var.checkTable[1][2]);
		
		if (var.blockageTable[0] ~= 0) then
			var.blockageTable[var.firstSide] = GetTerrMatter(SceneMan, eggs + var.checkTable[2][1], why);
			var.blockageTable[-var.firstSide] = GetTerrMatter(SceneMan, eggs + var.checkTable[3][1], why);
			for q = -var.firstSide, var.firstSide, 2*var.firstSide do
				if (var.blockageTable[q] == 0) then
					local skip = false;
					for i = 1, var.fluidRange do
						if (skip == false) then
							local n = i * q;
							local trueEggs = eggs + n;
							local matt = GetTerrMatter(SceneMan, trueEggs, why + 1);
							if (matt == 0) then
								fluidDirection = fluidDirection + 1/n;
								skip = true;
							end
						end
					end
				end
			end
			
			fluidDirection = fluidDirection / (var.fluidRange*2 + 1);
			
			if (fluidDirection == 0) then
				fluidDirection = GetRandom() - 0.5;
			end
			
			var.Vel.X = var.Vel.X + fluidDirection;
		end
		var.flow = false;
	end
	
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
				if (var.blockageTable[0] and i == 1) then
					terrainID = var.blockageTable[0];
					var.blockageTable[0] = nil;
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
				local smonk = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
				smonk.Pos = pos;
				AddParticle(MovableMan, smonk);
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