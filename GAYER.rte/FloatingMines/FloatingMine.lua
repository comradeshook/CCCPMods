function Create(self)
	self.atMove = 0
	self.activated = 0
	self.beepBeepTimer = Timer()
	self.detTimer = Timer()
	self.ignoreTeam = self.Team
end

function Update(self)
	if not self:GetParent() then
		if self.activated == 0 then
			if self.Vel.X ~= 0 then
				self.Vel.X = self.Vel.X / 1.05
			end
			if self.Vel.Y ~= 0 then
				self.Vel.Y = self.Vel.Y / 1.05
			end
			if self.HFlipped == false then
				self.AngularVel = -3
			else
				self.AngularVel = 3
			end
		end
		for MO in MovableMan:GetMOsInRadius(self.Pos, 100, self.Team, true) do
			if IsActor(MO:GetRootParent()) == true then
				if self.activated == 0 then
					local angle = dist.AbsRadAngle
					self.RotAngle = angle
					self.AngularVel = 0
					self.foom = dist
					self.activated = 1
					self.beepEmitter = CreateAEmitter("Beeping")
					self.beepEmitter.Pos = self.Pos
					MovableMan:AddParticle(self.beepEmitter)
					self.beepBeepTimer:Reset()
				end
			end
		end
		if self.activated == 1 and self.beepBeepTimer:IsPastSimMS(200) and self.atMove == 0 then
			self.Vel = self.foom
			self.atMove = 1
			self.detTimer:Reset()
			self.initiated = 1
		end
		if self.atMove == 1 and self.detTimer:IsPastSimMS(200) then
			self:GibThis()
		end
	end
end
