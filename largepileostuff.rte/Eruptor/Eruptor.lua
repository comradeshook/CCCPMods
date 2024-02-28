function Create(self)
	self.owner = MovableMan:GetMOFromID(
		SceneMan:CastMORay(
			self.Pos - (self.Vel * (GetPPM() * TimerMan.DeltaTimeSecs)),
			Vector(-10, 0):RadRotate(self.RotAngle + math.rad(180) * math.min(0, self.FlipFactor)),
			self.ID,
			-2,
			0,
			true,
			0
		)
	)
	self.fireMode = 0
	self.playerUsed = 0
	self.beamTimer = Timer()
	self.flightBeamRange = 70
	self.impactBeamRange = 200
	self.checkRange = 200
	if self.owner ~= nil then
		self.ownerRoot = self.owner:GetRootParent();
		if self.ownerRoot:IsActor() then
			self.playerUsed = 1
		end
	end
	if self.playerUsed == 1 then
		local actor = ToActor(self.ownerRoot)
		if actor:IsPlayerControlled() then
			if actor:GetController():IsState(Controller.BODY_CROUCH) then
				self.fireMode = 2
			elseif actor:GetController():IsState(Controller.AIM_SHARP) and actor.Vel.Magnitude < 2 then
				self.fireMode = 1
			end
		end
	end
	self.virtualAngle = self.RotAngle
	self.gravity = 5 * (SceneMan.GlobalAcc.Y * TimerMan.DeltaTimeSecs)
	if self.fireMode == 0 then
		self.Vel.Y = self.Vel.Y + self.gravity
	elseif self.fireMode == 2 then
		self.Vel = self.Vel - self.Vel.Normalized * 40
	end
end

function Update(self)
	self.gravity = 5 * (SceneMan.GlobalAcc.Y * TimerMan.DeltaTimeSecs)
	if self.fireMode ~= 2 then
		self.virtualAngle = self.RotAngle
	end
	if self.fireMode == 0 then
		self.Vel.Y = self.Vel.Y + self.gravity
	elseif self.fireMode == 2 then
		if self.Vel.X >= 0 then
			self.virtualAngle = self.virtualAngle - (4 * math.pi * TimerMan.DeltaTimeSecs)
		elseif self.Vel.X < 0 then
			self.virtualAngle = self.virtualAngle + (4 * math.pi * TimerMan.DeltaTimeSecs)
		end
	end
	self.length = SceneMan:CastObstacleRay(self.Pos, self.Vel / -3, Vector(0, 0), Vector(0, 0), self.ID, -2, 0, 1)
	local velCorrection = self.Vel * (GetPPM() * TimerMan.DeltaTimeSecs)
	local trueLength = self.length + velCorrection.Magnitude
	local iters = (math.ceil(trueLength) / 4)
	local initPos = self.Pos - velCorrection
	local increment = (trueLength / iters)
	for i = 0, iters, 1 do
		local trail1 = CreateMOPixel("Eruptor Trail 1")
		trail1.Pos = initPos + (self.Vel.Normalized * (i * increment))
		trail1.Vel = Vector(0, 0)
		MovableMan:AddMO(trail1)
		local trail2 = CreateMOPixel("Eruptor Trail 2")
		trail2.Pos = initPos + (self.Vel.Normalized * (i * increment))
		trail2.Vel = Vector(10, 0):RadRotate(self.virtualAngle + math.pi * 0.5)
		MovableMan:AddMO(trail2)
		local trail3 = CreateMOPixel("Eruptor Trail 2")
		trail3.Pos = initPos + (self.Vel.Normalized * (i * increment))
		trail3.Vel = Vector(10, 0):RadRotate(self.virtualAngle - math.pi * 0.5)
		MovableMan:AddMO(trail3)
		local trail4 = CreateMOPixel("Eruptor Trail 3")
		trail4.Pos = initPos + (self.Vel.Normalized * (i * increment))
		trail4.Vel = Vector(math.random(30, 40), 0):RadRotate(math.random(0, 200 * math.pi) / 100)
		MovableMan:AddMO(trail4)
		local trail5 = CreateMOPixel("Eruptor Trail 4")
		trail5.Pos = initPos + (self.Vel.Normalized * (i * increment))
		trail5.Vel = Vector(0, 0)
		MovableMan:AddMO(trail5)
	end
	self.pointed = MovableMan:GetMOFromID(
		SceneMan:CastMORay(self.Pos, (self.Vel * (1 / 3)), self.ID, self.IgnoresWhichTeam, 0, true, 0)
	)
	if self.pointed ~= nil then
		self:GibThis()
	end
	if self.fireMode == 2 then
		for MO in MovableMan:GetMOsInRadius(self.Pos, self.checkRange, self.Team, true) do
			if MovableMan:IsActor(MO) then
				local actor = ToActor(MO);
				if self.ToDelete == true then
					local targetPos = actor.Pos + (actor.Vel / 3)
					local selfPos = self.Pos + (self.Vel / 3)
					local yDiff = targetPos.Y - selfPos.Y
					local xDiff = targetPos.X - selfPos.X
					local angle = math.atan2(-yDiff, xDiff)
					self.beam = MovableMan:GetMOFromID(
						SceneMan:CastMORay(
							self.Pos,
							Vector(self.impactBeamRange, 0):RadRotate(angle),
							self.ID,
							-2,
							0,
							false,
							0
						)
					)
				else
					local targetPos = actor.Pos + (actor.Vel / 3)
					local selfPos = self.Pos + (self.Vel / 3)
					local yDiff = targetPos.Y - selfPos.Y
					local xDiff = targetPos.X - selfPos.X
					local angle = math.atan2(-yDiff, xDiff)
					self.beam = MovableMan:GetMOFromID(
						SceneMan:CastMORay(
							self.Pos,
							Vector(self.flightBeamRange, 0):RadRotate(angle),
							self.ID,
							self.IgnoresWhichTeam,
							0,
							false,
							0
						)
					)
				end
				if self.beam ~= nil then
					if self.ToDelete == true or self.beamTimer:IsPastSimMS(200) then
						if self.beam.RootID == actor.ID and actor.ID ~= self.ownerRoot.ID then
							self.beamTimer:Reset()
							self.dontExplode = 0
							self.traceVector = SceneMan:ShortestDistance(self.Pos, actor.Pos, true)
							self.endPos = Vector(0, 0)
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
						end
					end
				end
			end
		end
	end
end
