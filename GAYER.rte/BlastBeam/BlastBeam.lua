function Create(self)
	self.endPos = Vector(0, 0)
	self.traceVector = Vector(1200, 0):RadRotate(self.RotAngle + math.rad(180) * math.min(0, self.FlipFactor))
	self.ownerVector = Vector(-20, 0):RadRotate(self.RotAngle + math.rad(180) * math.min(0, self.FlipFactor))
	self.owner = MovableMan:GetMOFromID(SceneMan:CastMORay(self.Pos, self.ownerVector, self.ID, -2, 0, false, 1))
	if self.owner ~= nil then
		self.ownerRoot = MovableMan:GetMOFromID(self.owner.RootID)
		if self.ownerRoot:HasObject("Blast Beam") == false then
			self.ownerRoot = self
		end
	end
	self.dontExplode = 0
	if self.ownerRoot ~= nil then
		self.length = SceneMan:CastObstacleRay(
			self.Pos,
			self.traceVector,
			Vector(0, 0),
			self.endPos,
			self.ownerRoot.ID,
			self.IgnoresWhichTeam,
			0,
			0
		)
	else
		self.length = SceneMan:CastObstacleRay(
			self.Pos,
			self.traceVector,
			Vector(0, 0),
			self.endPos,
			self.ID,
			self.IgnoresWhichTeam,
			0,
			0
		)
	end
	if self.length < 0 then
		self.length = self.traceVector.Magnitude
		self.dontExplode = 1
	end
	if self.length > self.traceVector.Magnitude then
		self.length = SceneMan:ShortestDistance(self.Pos, self.endPos, true).Magnitude
	end
	local velCorrection = self.Vel * (GetPPM() * TimerMan.DeltaTimeSecs)
	local trueLength = self.length + velCorrection.Magnitude
	local iters = (math.ceil(trueLength) / 4)
	local initPos = self.Pos - velCorrection
	local increment = (trueLength / iters)
	for i = 0, iters, 1 do
		local glow = CreateMOPixel("Glow Particle Blast Beam")
		glow.Pos = initPos + (self.traceVector.Normalized * (i * increment))
		glow.Vel = Vector(0, 0)
		MovableMan:AddMO(glow)
		local smoke = CreateAEmitter("Smoke Puff")
		smoke.Pos = initPos + (self.traceVector.Normalized * (i * increment))
		smoke.Vel = Vector(0, 0)
		MovableMan:AddMO(smoke)
	end
	if self.dontExplode == 0 then
		local impact = CreateMOPixel("Glow Particle Blast Beam Impact")
		impact.Pos = initPos + (self.traceVector.Normalized * trueLength)
		impact.Vel = Vector(0, 0)
		MovableMan:AddMO(impact)
		local emitter = CreateAEmitter("Beam Explosion")
		emitter.Pos = initPos + (self.traceVector.Normalized * trueLength)
		emitter.Vel = Vector(0, 0)
		MovableMan:AddMO(emitter)
	end
	self.ToDelete = true
end
