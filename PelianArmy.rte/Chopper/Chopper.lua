function Create(self)
	self.dismember = 0
	self.skipCheck = 0
	self.frameTimer = 0
	self.whackVel = Vector(3, 0):RadRotate(self.RotAngle)
	self.whackDamage = 30
	self.endPos = Vector(0, 0)
	self.ownerVector = Vector(-20, 0):RadRotate(self.RotAngle)
	self.posCorrection = Vector(0, 0):RadRotate(self.RotAngle)
	self.range = Vector(28, 0):RadRotate(self.RotAngle) + self.posCorrection
	self.owner = MovableMan:GetMOFromID(SceneMan:CastMORay(self.Pos, self.ownerVector, self.ID, self.Team, 0, true, 0))
	if self.owner == nil then
		self.skipCheck = 1
	end
	if self.skipCheck == 0 then
		for actor in MovableMan.Actors do
			if actor.ID == self.owner.RootID and actor:HasObject("PACQ-23 Plasma Axe") == false then
				self.skipCheck = 1
			end
		end
	end
	self.swing = CreateMOSRotating("Axe Swing GFX")
	self.swing.Pos = self.Pos
	self.swing.Vel = self.Vel
	self.swing.RotAngle = self.RotAngle
	if self.RotAngle > (math.pi / 2) or self.RotAngle < -(math.pi / 2) then
		self.swing.HFlipped = true
		self.swing.RotAngle = self.RotAngle - math.pi
		self.swing.Pos = self.swing.Pos - Vector(2, 0):RadRotate(self.RotAngle)
	end
	MovableMan:AddMO(self.swing)
end

function Update(self)
	if self.frameTimer < 3 then
		self.frameTimer = self.frameTimer + 1
	end
	if self.skipCheck == 0 then
		for actor in MovableMan.Actors do
			if actor.ID == self.owner.RootID then
				self.RotAngle = actor:GetAimAngle(false)
				self.HFlipped = actor.HFlipped
			end
		end
	end
	if self.frameTimer == 3 then
		if self.skipCheck == 1 then
			self.target = MovableMan:GetMOFromID(
				SceneMan:CastMORay(self.Pos - self.posCorrection, self.range, self.ID, self.Team, 0, false, 0)
			)
			if self.target ~= nil then
				self.targetRoot = MovableMan:GetMOFromID(self.target.RootID)
			end
			if self.targetRoot ~= nil then
				if self.targetRoot.ClassName ~= "ACRocket" and self.targetRoot.ClassName ~= "ACDropShip" then
					self.targetRoot.Vel = self.targetRoot.Vel + self.whackVel
					self.dismember = 1
				end
				self.length = SceneMan:CastObstacleRay(
					self.Pos - self.posCorrection,
					self.range,
					Vector(0, 0),
					self.endPos,
					self.ID,
					self.Team,
					0,
					0
				)
				local impact = CreateAEmitter("Axe Impact")
				impact.Pos = self.endPos
				impact.Vel = Vector(0, 0)
				MovableMan:AddMO(impact)
				local impactGFX = CreateMOSRotating("Axe Impact GFX")
				impactGFX.Pos = self.endPos
				impactGFX.Vel = Vector(0, 0)
				impactGFX.RotAngle = self.RotAngle
				MovableMan:AddMO(impactGFX)
				if self.Vel.X > 0 then
					self.targetRoot.AngularVel = self.targetRoot.AngularVel - 5
				else
					self.targetRoot.AngularVel = self.targetRoot.AngularVel + 5
				end
				for actor in MovableMan.Actors do
					if actor.ID == self.targetRoot.ID then
						for i = 1, MovableMan:GetMOIDCount() - 1 do
							local mo = MovableMan:GetMOFromID(i)
							if
								mo.ID == self.target.ID
								and mo.ClassName ~= "MOPixel"
								and mo.ClassName ~= "MOSParticle"
							then
								if mo.ID ~= mo.RootID then
									ToMOSRotating(mo):GibThis()
								else
									actor.Health = actor.Health - self.whackDamage
								end
							end
						end
						actor.Health = actor.Health - self.whackDamage
					end
				end
			end
		elseif self.skipCheck == 0 then
			self.target = MovableMan:GetMOFromID(
				SceneMan:CastMORay(self.Pos - self.posCorrection, self.range, self.owner.RootID, self.Team, 0, false, 0)
			)
			if self.target ~= nil then
				self.targetRoot = MovableMan:GetMOFromID(self.target.RootID)
			end
			if self.targetRoot ~= nil and self.targetRoot.ID ~= self.owner.RootID then
				if self.targetRoot.ClassName ~= "ACRocket" and self.targetRoot.ClassName ~= "ACDropShip" then
					self.targetRoot.Vel = self.targetRoot.Vel + self.whackVel
				end
				self.length = SceneMan:CastObstacleRay(
					self.Pos - self.posCorrection,
					self.range,
					Vector(0, 0),
					self.endPos,
					self.owner.RootID,
					self.Team,
					0,
					0
				)
				local impact = CreateAEmitter("Axe Impact")
				impact.Pos = self.endPos
				impact.Vel = Vector(0, 0)
				MovableMan:AddMO(impact)
				local impactGFX = CreateMOSRotating("Axe Impact GFX")
				impactGFX.Pos = self.endPos
				impactGFX.Vel = Vector(0, 0)
				impactGFX.RotAngle = self.RotAngle
				MovableMan:AddMO(impactGFX)
				if self.Vel.X > 0 then
					self.targetRoot.AngularVel = self.targetRoot.AngularVel - 5
				else
					self.targetRoot.AngularVel = self.targetRoot.AngularVel + 5
				end
				for actor in MovableMan.Actors do
					if actor.ID == self.targetRoot.ID then
						for i = 1, MovableMan:GetMOIDCount() - 1 do
							local mo = MovableMan:GetMOFromID(i)
							if
								mo.ID == self.target.ID
								and mo.ClassName ~= "MOPixel"
								and mo.ClassName ~= "MOSParticle"
							then
								if mo.ID ~= mo.RootID then
									ToMOSRotating(mo):GibThis()
								else
									actor.Health = actor.Health - self.whackDamage
								end
							end
						end
						actor.Health = actor.Health - self.whackDamage
					end
				end
			end
		end
		self.Lifetime = 10
		self.frameTimer = 4
	end
end
