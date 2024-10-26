function Create(self)
	self.control = self:GetController()
	self.sightRange = 500
	self.canFire = 0
	self.fireDelay = Timer()
	self.stopDelay = Timer()
end

function UpdateAI(self)
	self.AIMode = 0
end

function Update(self)
	self.cont = self:GetController()
	self.AIMode = 0
	self.HFlipped = false
	if self:IsPlayerControlled() == false then
		for actor in MovableMan.Actors do
			if actor.Team ~= self.Team then
				local between = SceneMan:ShortestDistance(
					self.Pos,
					(actor.Pos + Vector(0, -2):RadRotate(actor.RotAngle)),
					true
				)
				local obsCheck = SceneMan:CastMORay(self.Pos, between, self.RootID, self.Team, 128, false, 1)
				if obsCheck ~= nil then
					local hit = MovableMan:GetMOFromID(obsCheck)
					if hit ~= nil then
						local target = MovableMan:GetMOFromID(hit.RootID)
						if between.Magnitude < self.sightRange and target.Team == actor.Team then
							self.stopDelay:Reset()
							self.canFire = 1
							self:SetAimAngle(between.AbsRadAngle)
						end
					end
				end
			end
		end
		if self.stopDelay:IsPastSimMS(100) then
			self.canFire = 0
		end
		if self.canFire == 0 then
			self.fireDelay:Reset()
		end
		if self.fireDelay:IsPastSimMS(300) then
			self.cont:SetState(14, true)
		else
			self.cont:SetState(14, false)
		end
	end
	self.cont:SetState(4, false)
	self.cont:SetState(27, false)
	self.cont:SetState(33, false)
end
