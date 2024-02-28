function Create(self)
	self.skipCheck = 0
	self.whackVel = Vector(40, 0):RadRotate(self.RotAngle)
	self.whackDamage = 40
	self.endPos = Vector(0, 0)
	self.range = Vector(25, 0):RadRotate(self.RotAngle)
	self.ownerVector = Vector(-20, 0):RadRotate(self.RotAngle)
	self.velCorrection = Vector(10, 0):RadRotate(self.RotAngle)
	self.owner = MovableMan:GetMOFromID(
		SceneMan:CastMORay(self.Pos - 2 * self.velCorrection, self.ownerVector, self.ID, 0, false, 1)
	)
	if self.owner == nil then
		self.skipCheck = 1
	end
	if self.skipCheck == 0 then
		for actor in MovableMan.Actors do
			if actor.ID ~= self.owner.ID and actor:HasObject("Sausage") == false then
				self.skipCheck = 1
			end
		end
	end
	self.target = MovableMan:GetMOFromID(
		SceneMan:CastMORay(self.Pos - self.velCorrection, self.range, self.ID, 0, false, 0)
	)
	if self.target ~= nil then
		self.targetRoot = MovableMan:GetMOFromID(self.target.RootID)
	end
	if self.skipCheck == 1 then
		if self.targetRoot ~= nil and self.targetRoot.ID then
			self.targetRoot.Vel = self.targetRoot.Vel + self.whackVel
			self.length = SceneMan:CastObstacleRay(
				self.Pos - self.velCorrection,
				self.range,
				Vector(0, 0),
				self.endPos,
				self.ID,
				0,
				0
			)
			local impact = CreateAEmitter("Impact")
			impact.Pos = self.endPos
			impact.Vel = Vector(0, 0)
			MovableMan:AddMO(impact)
			if self.Vel.X > 0 then
				self.targetRoot.AngularVel = self.targetRoot.AngularVel - 5
			else
				self.targetRoot.AngularVel = self.targetRoot.AngularVel + 5
			end
			for actor in MovableMan.Actors do
				if actor.ID == self.targetRoot.ID then
					if actor.Health - self.whackDamage <= 0 then
						for i = 1, MovableMan:GetMOIDCount() - 1 do
							local mo = MovableMan:GetMOFromID(i)
							if
								mo.ID == self.target.ID
								and mo.ClassName ~= "MOPixel"
								and mo.ClassName ~= "MOSParticle"
							then
								ToMOSRotating(mo):GibThis()
							end
						end
					end
					actor.Health = actor.Health - self.whackDamage
				end
			end
		end
	elseif self.skipCheck == 0 then
		if self.targetRoot ~= nil and self.targetRoot.ID ~= self.owner.RootID then
			self.targetRoot.Vel = self.targetRoot.Vel + self.whackVel
			self.length = SceneMan:CastObstacleRay(
				self.Pos - self.velCorrection,
				self.range,
				Vector(0, 0),
				self.endPos,
				self.owner.RootID,
				0,
				0
			)
			local impact = CreateAEmitter("Impact")
			impact.Pos = self.endPos
			impact.Vel = Vector(0, 0)
			MovableMan:AddMO(impact)
			if self.Vel.X > 0 then
				self.targetRoot.AngularVel = self.targetRoot.AngularVel - 5
			else
				self.targetRoot.AngularVel = self.targetRoot.AngularVel + 5
			end
			for actor in MovableMan.Actors do
				if actor.ID == self.targetRoot.ID then
					if actor.Health - self.whackDamage <= 0 then
						for i = 1, MovableMan:GetMOIDCount() - 1 do
							local mo = MovableMan:GetMOFromID(i)
							if
								mo.ID == self.target.ID
								and mo.ClassName ~= "MOPixel"
								and mo.ClassName ~= "MOSParticle"
							then
								ToMOSRotating(mo):GibThis()
							end
						end
					end
					actor.Health = actor.Health - self.whackDamage
				end
			end
		end
	end
end
