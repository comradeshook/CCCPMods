dofile("GAYER.rte/TableVectorLibrary.lua");

local range = 2000;
local iceColours = {166, 175, 176, 186, 198};

local GetTerrMatter = SceneMan.GetTerrMatter;
local DislodgePixel = SceneMan.DislodgePixel;

local function SettleAll(MO, var)
	for attachable in MO.Attachables do
		SettleAll(attachable, var);
	end
	
	if (MO.Material.SettleMaterial ~= 0) then
		var.freezeTable[#var.freezeTable+1] = {VecToTable(MO.Pos), MO.IndividualRadius, MO.Material.SettleMaterial};
		MO.ToSettle = true;
	else
		MO.ToDelete = true;
	end
end

function Create(self)
	local var = {};
	var.rangeVector = Vector(range, 0):GetRadRotatedCopy(self.Vel.AbsRadAngle);
	var.Pos = self.Pos;
	var.freezeTable = {};
	var.delayed = true;
	self.var = var;
	
	local rayTarget = SceneMan:CastMORay(var.Pos, var.rangeVector, self.RootID, self.Team, 0, false, 1);
	local rayHitPos = SceneMan:GetLastRayHitPos();
	var.freezeTable[#var.freezeTable+1] = {VecToTable(rayHitPos), 10, -1};
	if (rayTarget ~= 255) then
		local MO = ToMOSRotating(MovableMan:GetMOFromID(rayTarget):GetRootParent());
		if IsActor(MO) then
			ToActor(MO).Status = 4;
		end
		SettleAll(MO, var);
	end
	
	PrimitiveMan:DrawLinePrimitive(var.Pos, rayHitPos, 166);
end

function Update(self)
	local var = self.var;
	if (var.delayed) then
		var.delayed = false;
	else
		if (#var.freezeTable > 0) then
			for i = 1, #var.freezeTable do
				local entry = var.freezeTable[i];
				local centre = entry[1];
				local radius = entry[2];
				local targetMatt = entry[3];
				local origin = VecNew(centre.X - radius, centre.Y - radius);
				for y = 0, radius*2 do
					for x = 0, radius*2 do
						local checkPos = origin + VecNew(x, y);
						local distVec = VecShortestDistance(centre, checkPos, true);
						if (VecGetMagnitude(distVec) <= radius) then
							local matt = GetTerrMatter(SceneMan, checkPos.X, checkPos.Y);
							if (matt == targetMatt or targetMatt == -1) then
								local pixel = DislodgePixel(SceneMan, checkPos.X, checkPos.Y);
								if (pixel) then
									pixel:SetColorIndex(iceColours[math.random(#iceColours)]);
									pixel.ToSettle = true;
								end
							end
						elseif (x > radius) then
							break;
						end
					end
				end
			end
		end
		
		var.freezeTable = nil;
		self.ToDelete = true;
	end
end