-- 1 is blue
-- 2 is green

function Create(self)
	self.flyNameTable = {"Blue Fly", "Green Fly"};
	self.flyCap = 
		{ToMOSRotating(self):GetNumberValue("DonkBlueFlyCap"),
		ToMOSRotating(self):GetNumberValue("DonkGreenFlyCap")};
	self.flySpawnInterval = 
		{ToMOSRotating(self):GetNumberValue("DonkBlueFlySpawnInterval"),
		ToMOSRotating(self):GetNumberValue("DonkGreenFlyHealInterval")};
	self.flySpawnTimer = {Timer(), Timer()};
	self.flyTable = {{}, {}};
	self.flyObstructionLimit = {math.floor(60/self.flyCap[1]), math.floor(60/self.flyCap[2])};
	
	self.blueFlyDetectionRange = ToMOSRotating(self):GetNumberValue("DonkBlueFlyRange");
	self.blueFlyAttackInterval = ToMOSRotating(self):GetNumberValue("DonkBlueFlyAttackInterval");
	self.blueFlyAttackTimer = Timer();
	
	self.healColour = 133;
	
	self.flyAcc = 1;
	self.swarmPos = Vector(-10, -5);
	self.swarmRadius = 10;
	self.sightCheckIndex = {1, 1};
	self.fliesTransferred = false;
end

local function addFly(self, fly)
	if (fly) then
		if (fly.PresetName == "Blue Fly") then
			table.insert(self.flyTable[1], fly);
		elseif (fly.PresetName == "Green Fly") then
			table.insert(self.flyTable[2], fly);
		end
		fly.owner = self.UniqueID;
		fly.swarmOffset = Vector(math.random(-self.swarmRadius, self.swarmRadius), math.random(-self.swarmRadius, self.swarmRadius));
		fly.obstructionCount = 0;
	end
end

local function removeFly(self, flyType, i)
	table.remove(self.flyTable[flyType], i);
end

local function spawnFly(self, flyType, spawnPos)
	local fly = CreateMOSRotating(self.flyNameTable[flyType], "Donks.rte");
	MovableMan:AddMO(fly);
	table.insert(self.flyTable[flyType], fly);
	fly.Pos = spawnPos;
	fly.Team = self.Team;
	fly.owner = self.UniqueID;
	fly.swarmOffset = Vector(math.random(-self.swarmRadius, self.swarmRadius), math.random(-self.swarmRadius, self.swarmRadius));
	fly.obstructionCount = 0;
end

local function fireBoolet(self, pos, angle)
	local boolet = CreateAEmitter("Spark Bullet Emitter", "Donks.rte");
	boolet.Pos = pos;
	boolet.Team = self.Team;
	boolet.RotAngle = angle;
	MovableMan:AddMO(boolet);
end

local function nameCheck(fly, self)
	for i = 1, #self.flyNameTable, 1 do
		if (fly.PresetName == self.flyNameTable[i]) then
			return true;
		end
	end
	
	return false;
end

local function flyMotion(flyType, self)
	if (#self.flyTable[flyType] > 0) then
		for i = 1, #self.flyTable[flyType], 1 do
			local fly = self.flyTable[flyType][i];
			if (fly) then
				if (fly.owner == self.UniqueID and fly.ToDelete == false and nameCheck(fly, self)) then
					local accVector = SceneMan:ShortestDistance(fly.Pos, self.Pos + self.swarmPos:GetXFlipped(self.HFlipped) + fly.swarmOffset, true);
					fly.Vel = fly.Vel + accVector:SetMagnitude(self.flyAcc);
				else
					removeFly(self, flyType, i);
					i = i - 1;
				end
			end
		end
	end
end

local function flySightCheck(self, fly)
	local dist = SceneMan:ShortestDistance(fly.Pos, self.Pos + self.swarmPos:GetXFlipped(self.HFlipped), true);
	local obstructed = SceneMan:CastStrengthRay(fly.Pos, dist, 0, Vector(0, 0), 1, 0, true);
	return obstructed;
end

local function getAllWounds(self, woundTable)
	for wound in self.Wounds do
		table.insert(woundTable, wound);
	end
	
	for limb in self.Attachables do
		getAllWounds(limb, woundTable);
	end
end

local function getEarTable(head)
	if (head) then
		local earTable = {};
		for ear in head.Attachables do
			table.insert(earTable, ear);
		end
		
		return earTable;
	else
		return {};
	end
end

function Update(self)
	if (self:IsDead() == false) then
		for flyType = 1, #self.flyTable, 1 do
			flyMotion(flyType, self);
		end
		
		for i = 1, #self.sightCheckIndex, 1 do
			self.sightCheckIndex[i] = self.sightCheckIndex[i] + 1;
			if (self.sightCheckIndex[i] > #self.flyTable[i]) then
				self.sightCheckIndex[i] = 1;
			end
			
			local fly = self.flyTable[i][self.sightCheckIndex[i]];
			
			if (fly) then
				if (flySightCheck(self, fly)) then
					if (fly.obstructionCount < self.flyObstructionLimit[i]) then
						fly.obstructionCount = fly.obstructionCount + 1;
					else
						removeFly(self, i, self.sightCheckIndex[i]);
						self.sightCheckIndex[i] = self.sightCheckIndex[i] - 1;
						ToMOSRotating(fly):GibThis();
					end
				elseif (fly.obstructionCount > 0) then
					fly.obstructionCount = fly.obstructionCount - 1;
				end
			end
		end
		
		-- BLUE FLIES
		if (self.blueFlyAttackTimer:IsPastSimMS(self.blueFlyAttackInterval)) then
			self.blueFlyAttackTimer:Reset();
			if (#self.flyTable[1] > 0) then
				local flyNumber = math.random(#self.flyTable[1]);
				local fly = self.flyTable[1][flyNumber];
				if (fly) then
					local vectorTable = {};
					for actor in MovableMan.Actors do
						if (actor.Team ~= self.Team and actor.ClassName ~= "ADoor") then
							local distVec = SceneMan:ShortestDistance(fly.Pos, actor.Pos, true);
							if (distVec.Magnitude <= self.blueFlyDetectionRange) then
								local validTarget = SceneMan:CastFindMORay(fly.Pos, distVec, actor.ID, Vector(0, 0), 128, false, 1);
								if (validTarget) then
									table.insert(vectorTable, distVec);
								end
							end
						end
					end
					
					if (#vectorTable > 0) then
						local randomTarget = math.random(#vectorTable);
						
						fireBoolet(self, fly.Pos, vectorTable[randomTarget].AbsRadAngle);
						removeFly(self, 1, flyNumber);
						ToMOSRotating(fly):GibThis();
					end
				end
			end
		end
		
		if (self.flySpawnTimer[1]:IsPastSimMS(self.flySpawnInterval[1])) then
			self.flySpawnTimer[1]:Reset();
			if (#self.flyTable[1] < self.flyCap[1]) then
				spawnFly(self, 1, self.Pos);
			end
		end
		
		-- GREEN FLIES
		if (self.flySpawnTimer[2]:IsPastSimMS(self.flySpawnInterval[2])) then
			self.flySpawnTimer[2]:Reset();
			local woundTable = {};
			getAllWounds(self, woundTable);
			local earTable = getEarTable(self.Head);
			if (#woundTable > 0 and #self.flyTable[2] > 0) then
				local flyNumber = math.random(#self.flyTable[2]);
				local fly = self.flyTable[2][flyNumber];
				if (fly) then
					local wound = woundTable[math.random(#woundTable)];
					self.Health = self.Health + wound.BurstDamage;
					PrimitiveMan:DrawLinePrimitive(fly.Pos, wound.Pos, self.healColour);
					PrimitiveMan:DrawCircleFillPrimitive(fly.Pos, 3, self.healColour);
					PrimitiveMan:DrawCircleFillPrimitive(wound.Pos, 3, self.healColour);
					wound.ToDelete = true;
					fly.ToDelete = true;
					removeFly(self, 2, flyNumber);
				end
			elseif (#earTable < 2 and #self.flyTable[2] >= 2) then
				local missingEars = {};
				if (#earTable == 1) then
					if (earTable[1].PresetName == self.PresetName .. " Ear Right") then
						missingEars[1] = self.PresetName .. " Ear Left";
					else
						missingEars[1] = self.PresetName .. " Ear Right";
					end
				else
					missingEars = {self.PresetName .. " Ear Left", self.PresetName .. " Ear Right"};
				end
				
				local ear = CreateAttachable(missingEars[math.random(#missingEars)], "Donks.rte");
				self.Head:AddAttachable(ear, ear.ParentOffset);
				
				PrimitiveMan:DrawCircleFillPrimitive(ear.Pos, 3, self.healColour);
				for i = 1, 2, 1 do
					local flyNumber = math.random(#self.flyTable[2]);
					local fly = self.flyTable[2][flyNumber];
					PrimitiveMan:DrawLinePrimitive(fly.Pos, ear.Pos, self.healColour);
					PrimitiveMan:DrawCircleFillPrimitive(fly.Pos, 3, self.healColour);
					removeFly(self, 2, flyNumber);
					fly.ToDelete = true;
				end
			elseif (#self.flyTable[2] < self.flyCap[2]) then
				spawnFly(self, 2, self.Pos);
			end
		end
	elseif ((self.ToDelete or self:IsDead()) and self.fliesTransferred == false) then
		self.fliesTransferred = true;
		local actorTable = {};
		for actor in MovableMan.Actors do
			if (actor.Team == self.Team and actor.PresetName == "Donk" and actor:IsDead() == false) then
				local distVec = SceneMan:ShortestDistance(self.Pos, actor.Pos, true);
				if (distVec.Magnitude <= self.blueFlyDetectionRange*2) then
					local validTarget = SceneMan:CastFindMORay(self.Pos, distVec, actor.ID, Vector(0, 0), 128, false, 1);
					if (validTarget) then
						table.insert(actorTable, actor);
					end
				end
			end
		end
		
		if (#actorTable > 0) then
			local target = actorTable[math.random(#actorTable)];
			
			local fliesToSend = {};
			
			for flyType = 1, #self.flyTable, 1 do
				while #self.flyTable[flyType] > 0 do
					local fly = self.flyTable[flyType][1]
					if (fly) then
						table.insert(fliesToSend, fly.UniqueID);
						removeFly(self, flyType, 1);
					end
				end
			end
			
			if #fliesToSend > 0 then
				target:SendMessage("ReceiveFlies", fliesToSend);
			end
			
			self.flyTable = {{},{}};
		end
	end
end

function Destroy(self)
	for flyType = 1, #self.flyTable, 1 do
		for flyIndex = 1, #self.flyTable[flyType], 1 do
			local fly = self.flyTable[flyType][flyIndex];
			ToMOSRotating(fly):GibThis();
		end
	end
end

function OnMessage(self, message, context)
	if message == "ReceiveFlies" then
		while #context > 0 do
			addFly(self, MovableMan:FindObjectByUniqueID(context[1]));
			table.remove(context, 1);
		end
	end
end