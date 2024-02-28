function Create(self)
	if IsMOSRotating(self) then
		self.activationDelay = self:GetNumberValue("IncinerationStartDelay");
		self.burnInterval = self:GetNumberValue("IncinerationInterval");
		self.burnRadius = self:GetNumberValue("IncinerationRadius");
	else
		self.activationDelay = 0
		self.burnInterval = -self.RestThreshold;
		self.burnRadius = self.AirThreshold;
	end
	self.burnTimer = Timer()
	self.startTimer = Timer()
	self.BurntID = nil
	self.materialPenetration = 4;
end

function Update(self)
	if self.startTimer:IsPastSimMS(self.activationDelay) then
		if IsAEmitter(self) and self:IsEmitting() == false then
			self:EnableEmission(true)
		end
		if self.burnTimer:IsPastSimMS(self.burnInterval) then
			self.burnTimer:Reset()
			for MO in MovableMan:GetMOsInRadius(self.Pos, self.burnRadius, -1, true) do
				if IsActor(MO) and MO.PresetName ~= "Burnt Skeleton" and MO.PresetName ~= "Reflective Robot MK-II" then
					local actor = ToActor(MO);
					local distVec = SceneMan:ShortestDistance(self.Pos, actor.Pos, true)
					if not SceneMan:CastStrengthRay(self.Pos, distVec, 6, Vector(0, 0), 3, 0, true) then
						local dist = distVec.Magnitude
						if dist < (self.burnRadius/2) then
							actor.Health = actor.Health - (8 + math.random(1, 8)) * 2
						else
							actor.Health = actor.Health - (4 + math.random(1, 8)) * 2
							local BurnEmitter = CreateAEmitter("Burning")
							BurnEmitter.Pos = actor.Pos
							MovableMan:AddParticle(BurnEmitter)
						end
						if actor.Health <= 0 then
							if IsAHuman(actor) and actor:IsOrganic() then
								actor.ToDelete = true
								local PoofSkeletonEmitter = CreateAEmitter("Poof Skeleton")
								PoofSkeletonEmitter.Pos = actor.Pos
								PoofSkeletonEmitter.Vel = actor.Vel
								MovableMan:AddParticle(PoofSkeletonEmitter)
							else
								actor:GibThis()
								local PoofEmitter = CreateAEmitter("Poof")
								PoofEmitter.Pos = actor.Pos
								PoofEmitter.Vel = actor.Vel
								MovableMan:AddParticle(PoofEmitter)
							end
						end
					end
				end
			end
		end
	end
end
