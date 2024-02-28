package.path = package.path .. string.format(";GAYER.rte/?.lua")
require("MegaGib")

function Create(self)
	self.invulTimer = Timer()
	self.skipCheck = 0
	self.frameTimer = 3
	local correctedAngle = self.RotAngle + math.rad(180) * math.min(0, self.FlipFactor)
	if correctedAngle > (math.pi / 2) or correctedAngle < -(math.pi / 2) then
		self.fireAngle = (math.pi / 2) + 0.4
	else
		self.fireAngle = (math.pi / 2) - 0.4
	end
	self.whackVel = Vector(40, 0):RadRotate(self.fireAngle)
	self.whackDamage = 60
	self.endPos = Vector(0, 0)
	self.ownerVector = Vector(-20, 0):RadRotate(correctedAngle)
	self.posCorrection = Vector(0, 0):RadRotate(correctedAngle)
	self.range = Vector(28, 0):RadRotate(correctedAngle) + self.posCorrection
	self.owner = MovableMan:GetMOFromID(SceneMan:CastMORay(self.Pos, self.ownerVector, self.ID, -2, 0, true, 0))
	if self.owner == nil then
		self.skipCheck = 1
	end
	if self.skipCheck == 0 then
		for actor in MovableMan.Actors do
			if actor.ID == self.owner.RootID and actor:HasObject("Shoryuken") == false then
				self.skipCheck = 1
			end
		end
	end
	self.swing = CreateMOSParticle("Fist Of Doom")
	if correctedAngle > ((math.pi / 2) + 0.01) or correctedAngle < -((math.pi / 2) + 0.01) then
		self.swing = CreateMOSParticle("Fist Of Doom 2")
		self.swing.Pos = self.swing.Pos - Vector(2, 0):RadRotate(correctedAngle)
	end
	self.swing.Pos = self.Pos
	self.swing.Vel = self.Vel + self.whackVel / 4
	self.swing.HFlipped = self.HFlipped
	if self.owner ~= nil then
		self.ownerRoot = MovableMan:GetMOFromID(self.owner.RootID)
		self.ownerRoot.Vel = self.ownerRoot.Vel + (self.whackVel / 4)
	end
	MovableMan:AddMO(self.swing)
end

function Update(self)
	if self.frameTimer == 3 then
		if self.skipCheck == 1 then
			for i = 1, 12 do
				local angleAdjust = 0.6
				self.target = MovableMan:GetMOFromID(
					SceneMan:CastMORay(
						self.Pos - self.posCorrection,
						self.range:RadRotate(angleAdjust),
						self.ID,
						self.Team,
						0,
						false,
						0
					)
				)
				if self.target ~= nil then
					self.targetRoot = MovableMan:GetMOFromID(self.target.RootID)
					break
				end
				angleAdjust = angleAdjust - 0.1
			end
			if self.targetRoot ~= nil then
				if self.targetRoot.ClassName ~= "ACRocket" and self.targetRoot.ClassName ~= "ACDropShip" then
					self.targetRoot.Vel = self.targetRoot.Vel + self.whackVel
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
				local impact = CreateAEmitter("Shoryuken Impact")
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
							absolutelyFuckingGib(actor, self.whackVel)
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
				local impact = CreateAEmitter("Shoryuken Impact")
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
							absolutelyFuckingGib(actor, self.whackVel)
						end
						actor.Health = actor.Health - self.whackDamage
					end
				end
			end
		end
		self.Lifetime = 150
		self.frameTimer = 4
	end
end
