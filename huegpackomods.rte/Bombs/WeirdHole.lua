function Create(self)
	self.Vel = Vector(0, 0)
	self.baseMass = 100000
	self.massStored = self.Mass * (9 / 10);
	self:SetNumberValue("BlackHoleMassStored", self.massStored)
	self.Mass = self.Mass * (1 / 10)
	self.massCap = self.baseMass * 30
	self.baseRadius = 25
	self.accAtEventHorizon = 200 -- Pixels per frame
	self.flatEvaporationSpeed = (1 / 60) * (self.baseMass / 10) -- 10 seconds to lose base mass, flat rate
	self.minimumAccThreshold = 0.2;
	self.twistAtEventHorizon = math.rad(10);

	self.humSound = CreateSoundContainer("Black Hole Hum", "huegpackomods.rte")
	self.humSound.Volume = 0.5
	self.humSound.Pos = self.Pos
	self.humSound:Play()
	-- print("bif")

	self.massFactor = self.Mass / self.baseMass
	self.eventHorizonRadius = math.ceil(self.massFactor * self.baseRadius)
	
	--self:RequestSyncedUpdate();
end

local function accAtDist(self, distance)
	local divisor = math.max(1, distance / self.eventHorizonRadius);
	local acc = self.accAtEventHorizon / (divisor * divisor);
	return acc
end

function SyncedUpdate(self)
	if self.massStored > self.massCap then
		self.massStored = self.massCap
	end
	
	if self.massStored > 0 then
		self.Mass = self.Mass + math.min(2000, self.massStored)
		self.massStored = self.massStored - math.min(2000, self.massStored)
	end

	self.massFactor = self.Mass / self.baseMass
	self.eventHorizonRadius = math.ceil(self.massFactor * self.baseRadius)
	local eventHorizonRadius = self.eventHorizonRadius;

	self.humSound.Volume = math.min(1, self.massFactor * 2)
	self.humSound.AttenuationStartDistance = eventHorizonRadius * 1.5 + 100
	self.humSound.Pos = self.Pos
	if not self.humSound:IsBeingPlayed() then
		self.humSound:Play()
	end

	-- Mass evaporation
	local scalingEvaporationSpeed = self.flatEvaporationSpeed * (self.Mass / self.baseMass)
	self.Mass = self.Mass - (self.flatEvaporationSpeed + scalingEvaporationSpeed)
	if self.Mass < 0 then
		self:GibThis()
		--self.ToDelete = true;
	end
	
	local distance = math.sqrt(self.accAtEventHorizon/self.minimumAccThreshold)*eventHorizonRadius*0.5;
	
	-- dunno how much this helps lmao
	local selfPOS = self.Pos;
	local selfMass = self.Mass;
	
	for MO in MovableMan:GetMOsInRadius(selfPOS, distance) do
		if not (MO.UniqueID == self.UniqueID or MO.ToDelete) then
			if MO.AirThreshold ~= 13371 then -- gotta detect those effect particles somehow lol
				-- grab things into locals for slight GAINZ
				local moPOS = MO.Pos;
				local moVEL = MO.Vel;
				local distVec = SceneMan:ShortestDistance(moPOS, selfPOS, true)
				local dist = distVec.Magnitude;
				local scalar = eventHorizonRadius/math.max(eventHorizonRadius, dist);
				local newPos = selfPOS + distVec:GetRadRotatedCopy(self.twistAtEventHorizon * scalar);
			
				local moRadius = MO.Radius;
				local moMass = MO.Mass;
				
				local acc = accAtDist(self, dist)
				local tidalForce = (accAtDist(self, dist - moRadius) - accAtDist(self, dist + moRadius)) * moMass
				
				if dist < eventHorizonRadius + moVEL.Magnitude / 6 then
					if MO.PresetName ~= "New Black Hole" then
						MO.ToDelete = true
						self.massStored = self.massStored + moMass
					else
						if moMass < selfMass or (moMass == selfMass and MO.UniqueID < self.UniqueID) then
							MO.ToDelete = true
							self.massStored = self.massStored + moMass + ToMOSRotating(MO):GetNumberValue("BlackHoleMassStored")
							self.Vel = Vector(0, 0)
							MO.Vel = Vector(0, 0)
						end
					end
				end
				
				MO.Pos = newPos;

				if MO.PresetName ~= "New Black Hole" then
					MO:AddForce(distVec:SetMagnitude((acc * moMass) * 60 - tidalForce), Vector(0, 0))
					MO:AddImpulseForce(distVec:SetMagnitude(tidalForce), Vector(0, 0))
				else
					if MO.ToDelete == false then
						MO:AddForce(distVec:SetMagnitude(math.min(acc, 30) * moMass * 60 * math.min(selfMass / moMass, 1) * 0.5), Vector(0, 0))
					end
				end
			end
		end
	end
		

	self:SetNumberValue("BlackHoleMassStored", self.massStored)
	
	--local testDist = distance;
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, testDist, 86)
	--print(testDist);
end

function ThreadedUpdate(self)
	self.Vel = self.Vel * 0.9

	-- Draw the black hole
	local drawRadius = self.eventHorizonRadius + math.random(0, self.eventHorizonRadius / 20)
	PrimitiveMan:DrawCircleFillPrimitive(self.Pos, drawRadius + math.ceil(drawRadius / 10), 86)
	PrimitiveMan:DrawCircleFillPrimitive(self.Pos, drawRadius + math.ceil(drawRadius / 40), 222)
	PrimitiveMan:DrawCircleFillPrimitive(self.Pos, drawRadius, 245)

	-- Spawn fancy effects
	local suckyParticle = CreateMOPixel("Black Hole Sucky Particle", "huegpackomods.rte")
	local suckyAngle = math.random() * math.rad(360)
	suckyParticle.Pos = self.Pos
		+ Vector(math.min(self.eventHorizonRadius + 200, self.eventHorizonRadius * 3), 0):RadRotate(suckyAngle)
	suckyParticle.Vel = Vector(0, 0):RadRotate(suckyAngle)
	MovableMan:AddMO(suckyParticle)

	local spinnyFire = CreateMOSRotating("Scalable Fire Sprite", "huegpackomods.rte")
	local fireAngle = math.random() * math.rad(360)
	spinnyFire.Pos = self.Pos + Vector(drawRadius + math.random()*5, 0):RadRotate(fireAngle)
	spinnyFire.Vel = Vector(-self.massFactor, 0):RadRotate(fireAngle)
	spinnyFire.Scale = self.massFactor;
	spinnyFire.AirThreshold = 13371;
	spinnyFire.GlobalAccScalar = 0;
	MovableMan:AddMO(spinnyFire)

	-- Scale terrain chew
	local chewVel = math.min(490, 200 * self.massFactor)
	for emission in self.Emissions do
		emission.MinVelocity = chewVel
		emission.MaxVelocity = chewVel
	end
	
	self:RequestSyncedUpdate();
end

function Destroy(self)
	self.humSound:Stop()
end
