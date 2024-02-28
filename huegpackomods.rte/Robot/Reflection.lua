function Create(self)
	self.reflectTimer = Timer(); -- in case you wanna use it down in Update
	self.plinkSound = CreateSoundContainer("Plink", "huegpackomods.rte");
end

local function reflectMO(self, target, plinkPos)
	--self:AddForce((target.Vel - self.Vel) * math.min(target.Mass, self.Mass) * 60, Vector(0, 0));
	--target.Vel = Vector(-target.Vel.X, -target.Vel.Y) + self.Vel;
	local distVec = SceneMan:ShortestDistance(target.Pos, self.Pos, true);
	local forceScalar = math.cos(math.abs(target.Vel.AbsRadAngle - distVec.AbsRadAngle));
	local force = (target.Vel - self.Vel):AbsRotateTo(distVec) * math.min(target.Mass, self.Mass) * 2 * forceScalar;
	target:AddForce(force * -60, Vector(0, 0));
	self:AddForce(force * 60, Vector(0, 0));
	local emitter = CreateAEmitter("Plink");
	emitter.Pos = plinkPos;
	emitter.RotAngle = distVec.AbsRadAngle;
	MovableMan:AddParticle(emitter);
	if IsActor(target) == false then
		target.Team = self.Team;
	end
	
	self.plinkSound.Pos = plinkPos;
	self.plinkSound:Stop(); -- to stop the sound from playing over itself
	self.plinkSound:Play();
	
	self.reflectTimer:Reset()
end

local function checkMOSRCollisionCircle(this, target, checkRadius)
	local collisionFound = false;
	local totalVel = target.Vel - this.Vel;
	if (this.Pos - target.Pos):Dot(totalVel) >= 0 then
		local checkDist = checkRadius + target.IndividualRadius;
		local iters = math.max(math.ceil((totalVel.Magnitude/3)/(math.min(target.IndividualRadius, checkRadius)/2)), 1);
		for i = 1, iters, 1 do
			local pos1 = this.Pos + ((this.Vel/3)/iters)*i;
			local pos2 = target.Pos + ((target.Vel/3)/iters)*i;
			collisionFound = SceneMan:ShortestDistance(pos1, pos2, true).Magnitude <= checkDist;
		
			if collisionFound == true and this.UniqueID == this:GetRootParent().UniqueID then
				collisionFound = SceneMan:ShortestDistance(pos1, pos2, true).Magnitude <= ToMOSRotating(this).IndividualRadius;
				for attachable in this.Attachables do
					if collisionFound == false then
						collisionFound = checkMOSRCollisionCircle(attachable, target, ToMOSRotating(attachable).IndividualRadius);
					end
				end
			end
		end
	end
	return collisionFound;
end

-- Not really used but eh, keeping for posterity
local function checkMOSRCollisionRays(self, target)
	local totalVel = target.Vel - self.Vel;
	local rayCaster = target;
	local rayTarget = self;
	if self.Radius < target.Radius then
		rayCaster = self;
		rayTarget = target;
		totalVel = self.Vel - target.Vel;
	end
	local collisionFound = SceneMan:CastFindMORay(rayCaster.Pos, totalVel/3, rayTarget.ID, Vector(0, 0), 0, true, 1)
	for i = -0.5, 0.5, 1 do
		for q = -0.5, 0.5, 1 do
			if collisionFound == false then
				local offsetVector = Vector(rayCaster.Radius*i, rayCaster.Radius*q);
				collisionFound = SceneMan:CastFindMORay(rayCaster.Pos + offsetVector, totalVel/3, rayTarget.ID, Vector(0, 0), 0, true, 1)
			end
		end
	end
end

function Update(self)
	self.collisionRadius = self.Radius;
	--PrimitiveMan:DrawCirclePrimitive(self.Pos, self.collisionRadius, 83);
	--for attachable in self.Attachables do
	--	PrimitiveMan:DrawCirclePrimitive(attachable.Pos, ToMOSRotating(attachable).IndividualRadius, 83);
	--end
	--if self.reflectTimer:IsPastSimMS(50) then
		for MO in MovableMan:GetMOsInRadius(self.Pos, math.ceil(500/3) + self.Vel.Magnitude/3, self.Team, false) do
			if MO.HitsMOs == true and MovableMan:ValidMO(MO) and IsADoor(MO:GetRootParent()) == false and MO.PinStrength <= 0 and (MO.Vel.Magnitude > 3 or (MO.Vel - self.Vel).Magnitude > 20) then
				if IsMOSRotating(MO) == true then
					if checkMOSRCollisionCircle(self, ToMOSRotating(MO), self.collisionRadius) == true then
						reflectMO(self, MO:GetRootParent(), MO.Pos + MO.Vel/3);
					end
				else
					local hitPos = Vector(MO.Pos.X, MO.Pos.Y);
					local rayCheck = SceneMan:CastFindMORay(MO.Pos, MO.Vel/3, self.ID, hitPos, 0, true, 1);
					if rayCheck == true then
						reflectMO(self, MO, hitPos);
						MO.Pos = hitPos;
					end
				end
			end
		end
	--end
end