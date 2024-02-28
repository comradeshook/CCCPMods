function Create(self)
	self.length = SceneMan:CastObstacleRay(
		self.Pos,
		self.Vel / -3,
		Vector(0, 0),
		Vector(0, 0),
		self.ID,
		self.Team,
		0,
		1
	)
	local velCorrection = self.Vel * (GetPPM() * TimerMan.DeltaTimeSecs)
	local trueLength = self.length + velCorrection.Magnitude
	local iters = (math.ceil(trueLength) / 4)
	local initPos = self.Pos - velCorrection
	local increment = (trueLength / iters)
	for i = 0, iters, 1 do
		local trail = CreateMOSParticle("Side Thruster Blast Ball 1 Glow")
		trail.Pos = initPos + (self.Vel.Normalized * (i * increment))
		trail.Vel = Vector(0, 0)
		trail.Lifetime = trail.Lifetime * (1 + (math.random(1, 20) / 100))
		MovableMan:AddMO(trail)
	end
	self.pointed = MovableMan:GetMOFromID(
		SceneMan:CastMORay(self.Pos, (self.Vel * (2 / 3)), self.ID, self.Team, 0, true, 1)
	)
	if self.pointed ~= nil then
		self.pointedRoot = MovableMan:GetMOFromID(self.pointed.RootID)
		if self.pointedRoot.PresetName ~= "Reflective Robot MK-II" then
			self:GibThis()
		else
			self.pointedRoot.Vel = self.Vel * (self.Mass / self.pointedRoot.Mass)
			self.Pos = self.Pos + (self.Vel / 3)
			self.Vel = self.Vel * -1
			self.blergemitter = CreateAEmitter("Plink")
			self.blergemitter.Pos.X = self.pointedRoot.Pos.X
			self.blergemitter.Pos.Y = self.Pos.Y + (self.Vel.Y / 3)
			if self.Vel.X > 0 then
				self.blergemitter.RotAngle = math.atan(self.Vel.Y / self.Vel.X)
			else
				self.blergemitter.RotAngle = math.atan(self.Vel.Y / self.Vel.X) + math.pi
			end
			MovableMan:AddParticle(self.blergemitter)
		end
	end
end

function Update(self)
	self.length = SceneMan:CastObstacleRay(
		self.Pos,
		self.Vel / -3,
		Vector(0, 0),
		Vector(0, 0),
		self.ID,
		self.Team,
		0,
		1
	)
	local velCorrection = self.Vel * (GetPPM() * TimerMan.DeltaTimeSecs)
	local trueLength = self.length + velCorrection.Magnitude
	local iters = (math.ceil(trueLength) / 4)
	local initPos = self.Pos - velCorrection
	local increment = (trueLength / iters)
	for i = 0, iters, 1 do
		local trail = CreateMOSParticle("Side Thruster Blast Ball 1 Glow")
		trail.Pos = initPos + (self.Vel.Normalized * (i * increment))
		trail.Vel = Vector(0, 0)
		trail.Lifetime = trail.Lifetime * (1 + (math.random(1, 20) / 100))
		MovableMan:AddMO(trail)
	end
	self.pointed = MovableMan:GetMOFromID(
		SceneMan:CastMORay(self.Pos, (self.Vel * (2 / 3)), self.ID, self.Team, 0, true, 1)
	)
	if self.pointed ~= nil then
		self.pointedRoot = MovableMan:GetMOFromID(self.pointed.RootID)
		if self.pointedRoot.PresetName ~= "Reflective Robot MK-II" then
			self:GibThis()
		else
			self.pointedRoot.Vel = self.Vel * (self.Mass / self.pointedRoot.Mass)
			self.Pos = self.Pos + (self.Vel / 3)
			self.Vel = self.Vel * -1
			self.blergemitter = CreateAEmitter("Plink")
			self.blergemitter.Pos.X = self.pointedRoot.Pos.X
			self.blergemitter.Pos.Y = self.Pos.Y + (self.Vel.Y / 3)
			if self.Vel.X > 0 then
				self.blergemitter.RotAngle = math.atan(self.Vel.Y / self.Vel.X)
			else
				self.blergemitter.RotAngle = math.atan(self.Vel.Y / self.Vel.X) + math.pi
			end
			MovableMan:AddParticle(self.blergemitter)
		end
	end
end
