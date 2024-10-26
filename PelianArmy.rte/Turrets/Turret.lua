function Create(self)
	self.control = self:GetController()
	self.sightRange = self.Sharpness
	self.canFire = 0
	self.fireDelay = Timer()
	self.stopDelay = Timer()
	local checkRange = 50
	for i = 0, 3 do
		local angle = (math.pi / 2) * i
		self.endPos = Vector(0, 0)
		local wallCheck = SceneMan:CastStrengthRay(
			self.Pos,
			Vector(checkRange, 0):RadRotate(angle),
			1,
			self.endPos,
			0,
			128,
			true
		)
		local dist = SceneMan:ShortestDistance(self.endPos, self.Pos, true).Magnitude
		if dist ~= nil then
			if self.oldDist == nil then
				self.closest = i
				self.oldDist = dist
				self.lastPos = self.endPos
			else
				if self.oldDist > dist then
					self.closest = i
					self.oldDist = dist
					self.lastPos = self.endPos
				end
			end
		end
	end
	if self.closest ~= nil and self.oldDist < 50 then
		self.Frame = self.closest + 1
		self.Pos = self.lastPos + Vector(self.SpriteOffset.X, 0):RadRotate((math.pi / 2) * self.closest)
		self:MoveOutOfTerrain(1)
		self.lastPos = self.Pos
	end
	self.PinStrength = 999
end

function UpdateAI(self)
	self.AIMode = 0
end

function Update(self)
	self.cont = self:GetController()
	self.AIMode = 0
	if self.lastPos ~= nil and self.oldDist < 50 then
		self.Frame = self.closest + 1
		self.Pos = self.lastPos
	end
	self.HFlipped = false
	self.MovementState = 0
	if self:IsPlayerControlled() == false then
		for actor in MovableMan.Actors do
			if actor.Team ~= self.Team then
				local between = SceneMan:ShortestDistance(
					self.Pos,
					(actor.Pos + Vector(0, -2):RadRotate(actor.RotAngle)),
					true
				)
				if self.PresetName == "PAHT Coilgun" or self.PresetName == "PALT Coilgun" then
					between = SceneMan:ShortestDistance(
						self.Pos,
						(actor.Pos + Vector(0, -16):RadRotate(actor.RotAngle)),
						true
					)
				end
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
		if self.fireDelay:IsPastSimMS(1000) then
			self.cont:SetState(14, true)
		else
			self.cont:SetState(14, false)
		end
	end
	self.cont:SetState(4, false)
	self.cont:SetState(27, false)
	self.cont:SetState(33, false)
end
