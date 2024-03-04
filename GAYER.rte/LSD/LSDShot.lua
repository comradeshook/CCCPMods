dofile("GAYER.rte/Fx/TableVectorLibrary.lua");

local range = 2000;
local iceColours = {166, 175, 176, 186, 198};
local rainbowColours = {13, 47, 87, 162, 194, 216};
local glowColours = {"RedTiny.png", "FireGlowTiny.png", "YellowTiny.png", "YellowTiny.png", "LightBlueTiny.png", "BlueTiny.png"};
local colourChangeSpeed = 0.25;
local waveSpeed = 1;
local terrainRadius = 20;
local beamSegmentLength = 20;

local GetTerrMatter = SceneMan.GetTerrMatter;
local DislodgePixel = SceneMan.DislodgePixel;

local function SettleAll(MO, var)
	for attachable in MO.Attachables do
		SettleAll(attachable, var);
	end
	
	if (MO.Material.ID ~= 0 and MO.Material.SettleMaterial ~= 0) then
		var.freezeTable[#var.freezeTable+1] = {VecGetFloored(VecToTable(MO.Pos)), math.ceil(MO.IndividualRadius), MO.Material.SettleMaterial};
		MO.ToSettle = true;
	else
		MO.ToDelete = true;
	end
end

local function FreezeTableEntry(pos, distVec)
	local entry = {};
	entry.frozen = false;
	entry.X = pos.X;
	entry.Y = pos.Y;
	entry.distVec = distVec;
	return entry;
end

local function GetColour(var)
	var.colourIndex = var.colourIndex + colourChangeSpeed;
	if (var.colourIndex > #rainbowColours) then
		var.colourIndex = 1;
	end
	return var.colourIndex;
end

local function MakeBeamSegment(startPos, endPos, var)
	local colour = rainbowColours[var.beamColour];
	var.beamColour = var.beamColour - 1;
	if var.beamColour < 1 then
		var.beamColour = #rainbowColours;
	end
	local entry = {};
	entry.startPos = startPos;
	entry.endPos = endPos;
	entry.colour = colour;
	
	if (var.hitColour == 0) then
		var.hitColour = colour;
	end
	
	return entry;
end

function Create(self)
	local var = {};
	var.rangeVector = Vector(range, 0):GetRadRotatedCopy(self.Vel.AbsRadAngle);
	var.Pos = self.Pos;
	var.freezeTable = {};
	var.pixelsToCheck = {};
	var.pixelTable = {};
	var.delayed = true;
	var.hitPos = var.Pos + var.rangeVector;
	var.colourIndex = math.random(#rainbowColours);
	var.beamColour = var.colourIndex;
	var.hitColour = 0;
	var.startColour = 0;
	var.beamThiccness = 8;
	var.beamAccel = 1;
	var.beamSegTable = {};
	var.flash = true;
	var.loopSound = CreateSoundContainer("LSD Loop", "GAYER.rte");
	self.var = var;
	
	local terrain = SceneMan:CastStrengthRay(var.Pos, var.rangeVector, 0.01, var.hitPos, 0, 181, true);
	var.rangeVector = SceneMan:ShortestDistance(var.Pos, var.hitPos, true);
	local rayTarget = SceneMan:CastMORay(var.Pos, var.rangeVector, self.RootID, self.Team, 0, true, 0);
	if (rayTarget ~= 255) then
		local lastRayHit = SceneMan:GetLastRayHitPos();
		var.hitPos = Vector(lastRayHit.X, lastRayHit.Y);
		var.rangeVector = SceneMan:ShortestDistance(var.Pos, var.hitPos, true);
		local MO = ToMOSRotating(MovableMan:GetMOFromID(rayTarget):GetRootParent());
		if IsActor(MO) then
			ToActor(MO).Status = 4;
		end
		
		-- i have to do this horseshit to make fully open/closed doors disintegrate properly :D
		if IsADoor(MO) then
			local door = ToADoor(MO);
			local state = door:GetDoorState();
			if (state == 0) then
				door:OpenDoor();
			end
			
			if (state == 2) then
				door:CloseDoor();
			end
		end
		SettleAll(MO, var);
	end
	var.hitPos = var.hitPos + var.rangeVector.Normalized*2;
	var.hitPosTVector = VecGetFloored(VecToTable(var.hitPos));
	var.loopSoundPos = VecCopy(var.hitPosTVector);
	
	var.freezeTable[#var.freezeTable+1] = {var.hitPosTVector, terrainRadius, -1};
end

local function SpawnAsh(pos, colourIndex, var)
	local ash = CreateMOPixel("Ash Particle", "GAYER.rte");
	local index = math.floor(colourIndex % #rainbowColours) + 1;
	local colour = rainbowColours[index];
	ash.Pos = pos;
	ash.Lifetime = math.random()*ash.Lifetime + 1;
	ash:SetColorIndex(colour);
	local scatterVel = 1;
	ash.Vel = Vector(math.random()*scatterVel*2 - scatterVel, math.random()*scatterVel*2 - scatterVel);
	if (math.random() > 0.5) then
		ash:SetScreenEffectPath("Base.rte/Effects/Glows/" .. glowColours[index]);
	end
	MovableMan:AddParticle(ash);
end

function Update(self)
	local var = self.var;
	if (var.delayed) then
		var.delayed = false;
	else
		if (var.freezeTable and #var.freezeTable > 0) then
			var.pixelTable = {};
			local closest = nil;
			for i = 1, #var.freezeTable do
				local entry = var.freezeTable[i];
				local centre = entry[1];
				local radius = entry[2];
				local targetMatt = entry[3];
				local origin = VecNew(centre.X - radius, centre.Y - radius);
				--VecPrint(origin)
				--local nigiro = VecNew(centre.X + radius, centre.Y + radius);
				--PrimitiveMan:DrawBoxPrimitive(VecTableToVector(origin), VecTableToVector(nigiro), 13)
				for x = 0, radius*2 do
					local relativeX = (origin.X + x);
					if (var.pixelTable[relativeX] == nil) then
						var.pixelTable[relativeX] = {};
					end
					for y = 0, radius*2 do
						local relativeY = (origin.Y + y);
						local checkPos = VecGetFloored(VecNew(relativeX, relativeY));
						if (var.pixelTable[checkPos.X][checkPos.Y] == nil) then
							local distVec = VecShortestDistance(centre, checkPos, true);
							if (VecGetMagnitude(distVec) <= radius) then
								local matt = GetTerrMatter(SceneMan, checkPos.X, checkPos.Y);
								if (matt ~= 0 and (matt == targetMatt or targetMatt == -1)) then
									var.pixelTable[checkPos.X][checkPos.Y] = FreezeTableEntry(checkPos, VecShortestDistance(var.hitPos, checkPos, true));
								end
							elseif (y > radius) then
								break;
							end
						end
					end
				end
			end
			
			local start = var.hitPosTVector;
			
			if (var.pixelTable[start.X] and var.pixelTable[start.X][start.Y]) then
				var.pixelTable[start.X][start.Y].frozen = true;
				var.pixelsToCheck[1] = start;
			end
		end
		
		var.freezeTable = nil;
		local pixelColour = GetColour(var);
		var.loopSoundPos = var.hitPosTVector;
		for n = 1, waveSpeed do
			if (var.pixelTable) then
				local newPixelsToCheck = {};
				for i = 1, #var.pixelsToCheck do
					local point = var.pixelsToCheck[i];
					if (point and var.pixelTable[point.X] and var.pixelTable[point.X][point.Y]) then
						local x = point.X;
						local y = point.Y;
						local entry = var.pixelTable[x][y];
						if (entry) then
							if (entry.frozen) then
								local pixel = DislodgePixel(SceneMan, entry.X, entry.Y, true);
								if (pixel) then
									local distFactor = VecGetMagnitude(entry.distVec) / 10;
									local colourOffset = math.abs(math.sin(VecGetAbsRadAngle(entry.distVec) + distFactor)) * 4;
									SpawnAsh(pixel.Pos, pixelColour + colourOffset, var);
									
									var.loopSoundPos = var.loopSoundPos + VecNew(entry.X, entry.Y);
								end
								
								local jump = math.random(2);
								
								--  s u f f e r
								local neighborTable = {
									var.pixelTable[x+jump] and var.pixelTable[x+jump][y],
									var.pixelTable[x-jump] and var.pixelTable[x-jump][y],
									var.pixelTable[x] and var.pixelTable[x][y+jump],
									var.pixelTable[x] and var.pixelTable[x][y-jump]
								};
								
								local pixelFound = false;
								
								if (#neighborTable > 0) then
									for i = 1, #neighborTable do
										local neighbor = neighborTable[i];
										if (neighbor and neighbor.frozen == false) then
											pixelFound = true;
											neighbor.frozen = true;
											newPixelsToCheck[#newPixelsToCheck+1] = VecNew(neighbor.X, neighbor.Y);
										end
									end
								end
								
								-- check diagonals if no cardinals are found
								if (pixelFound == false) then
									neighborTable = {
										var.pixelTable[x-1] and var.pixelTable[x-1][y-1],
										var.pixelTable[x-1] and var.pixelTable[x-1][y+1],
										var.pixelTable[x+1] and var.pixelTable[x+1][y-1],
										var.pixelTable[x+1] and var.pixelTable[x+1][y+1]
									};
									
									if (#neighborTable > 0) then
										for i = 1, #neighborTable do
											local neighbor = neighborTable[i];
											if (neighbor and neighbor.frozen == false) then
												neighbor.frozen = true;
												newPixelsToCheck[#newPixelsToCheck+1] = VecNew(neighbor.X, neighbor.Y);
											end
										end
									end
								end
								--var.pixelTable[x][y] = nil;
							end
						end
					end
				end
				
				if (#newPixelsToCheck > 0) then
					var.loopSoundPos = var.loopSoundPos / #var.pixelsToCheck;
					var.pixelsToCheck = newPixelsToCheck;
					if (var.loopSound:IsBeingPlayed() == false) then
						var.loopSound:Play();
					end
					
					var.loopSound.Pos = VecTableToVector(var.loopSoundPos);
				else
					for k,v in pairs(var.pixelTable) do
						for q,p in pairs(v) do
							if (p.frozen == false) then
								local pixel = DislodgePixel(SceneMan, p.X, p.Y, true);
								if (pixel and math.random() > 0.5) then
									local dist = VecGetMagnitude(p.distVec);
									local distFactor = dist / 10;
									local colourOffset = math.abs(math.sin(VecGetAbsRadAngle(p.distVec) + distFactor)) * 4;
									SpawnAsh(pixel.Pos, (dist/4) + colourOffset, var);
								end
							end
						end
					end
					var.pixelTable = nil;
					var.loopSound:Stop();
				end
			end
		end
	end
	
	if (#var.beamSegTable == 0) then
		local iters = math.ceil(var.rangeVector.Magnitude/beamSegmentLength);
		local realSegLength = (var.rangeVector/iters) * -1;
		for i = 1, iters do
			var.beamSegTable[i] = MakeBeamSegment(var.hitPos + realSegLength*(i-1), var.hitPos + realSegLength*i + realSegLength.Normalized, var);
			if (i == iters) then
				var.startColour = var.beamSegTable[i].colour;
			end
		end
	end
	
	if (var.beamThiccness > 0) then
		if (#var.beamSegTable > 0) then
			PrimitiveMan:DrawCircleFillPrimitive(var.Pos, var.beamThiccness*1.5, var.startColour);
			PrimitiveMan:DrawCircleFillPrimitive(var.hitPos, var.beamThiccness, var.hitColour);
			for i = 1, #var.beamSegTable do
				local entry = var.beamSegTable[i];
				PrimitiveMan:DrawLinePrimitive(entry.startPos, entry.endPos, entry.colour, var.beamThiccness);
			end
			PrimitiveMan:DrawLinePrimitive(var.Pos, var.Pos + var.rangeVector, 177, var.beamThiccness - 4);
			PrimitiveMan:DrawCircleFillPrimitive(var.Pos, var.beamThiccness, 166);
			PrimitiveMan:DrawCircleFillPrimitive(var.hitPos, var.beamThiccness*0.75, 166);
		end
		
		if (var.flash) then
			var.flash = false;
			PrimitiveMan:DrawCircleFillPrimitive(var.hitPos, var.beamThiccness*3, 166);
			PrimitiveMan:DrawCircleFillPrimitive(var.Pos, var.beamThiccness*3, 166);
			PrimitiveMan:DrawLinePrimitive(var.Pos, var.Pos + var.rangeVector, 166, var.beamThiccness*2);
		end
	end
	
	if (var.pixelTable == nil and var.beamThiccness <= 0) then
		self.ToDelete = true;
	else
		var.beamThiccness = var.beamThiccness + var.beamAccel;
		var.beamAccel = var.beamAccel - 0.25;
	end
end