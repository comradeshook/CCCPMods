function Create(self)
	if self.ToSettle == true then
		self.ToSettle = false
	end
	self.oldAngle = self.RotAngle
	self.lockOnVector = Vector(800, 0):RadRotate(self.RotAngle)
	self.chaseVel = Vector(50, 0):RadRotate(self.RotAngle)
	self.ownerVector = Vector(-10, 0):RadRotate(self.RotAngle)
	self.owner = MovableMan:GetMOFromID(SceneMan:CastMORay(self.Pos, self.ownerVector, self.ID, -2, 0, false, 1))
	if self.owner ~= nil then
		self.ownerRoot = MovableMan:GetMOFromID(self.owner.RootID)
	else
		self.ownerRoot = MovableMan:GetMOFromID(self.ID)
	end
	if self.pointed == nil then
		self.pointed = MovableMan:GetMOFromID(
			SceneMan:CastMORay(self.Pos, self.lockOnVector, self.ID, self.IgnoresWhichTeam, 0, false, 1)
		)
		if self.pointed == nil then
			for MO in MovableMan:GetMOsInRadius(self.Pos, 300, self.Team, true) do
				if MovableMan:IsActor(MO) then
					local actor = MO;
					self.pointed = MovableMan:GetMOFromID(
						SceneMan:CastMORay(
							self.Pos,
							(actor.Pos - self.Pos),
							self.ID,
							self.IgnoresWhichTeam,
							0,
							false,
							1
						)
					)
				end
			end
		end
	elseif self.pointed ~= nil then
		self.pointedRoot = MovableMan:GetMOFromID(self.pointed.RootID)
	end
	if
		self.pointedRoot ~= nil
		and self.pointedRoot.ID ~= self.ID
		and MovableMan:IsActor(self.pointedRoot)
		and self.pointedRoot.ID ~= self.ownerRoot.ID
		and self.pointedRoot.Team ~= self.ownerRoot.Team
	then
		self:EnableEmission(true)
		local targetPos = self.pointedRoot.Pos + (self.pointedRoot.Vel / 3)
		local selfPos = self.Pos + (self.Vel / 3)
		local yDiff = targetPos.Y - selfPos.Y
		local xDiff = targetPos.X - selfPos.X
		if SceneMan.SceneWrapsX == true then
			if xDiff > (SceneMan.SceneDim.X / 2) or xDiff < (SceneMan.SceneDim.X / -2) then
				self.RotAngle = self.oldAngle
				self.Vel = self.chaseVel
			else
				self.RotAngle = math.atan2(-yDiff, xDiff)
				self.Vel = self.chaseVel
			end
		else
			self.RotAngle = math.atan2(-yDiff, xDiff)
			self.Vel = self.chaseVel
		end
	else
		self.pointed = MovableMan:GetMOFromID(
			SceneMan:CastMORay(self.Pos, self.lockOnVector, self.ID, self.IgnoresWhichTeam, 0, false, 1)
		)
		if self.pointed == nil then
			for MO in MovableMan:GetMOsInRadius(self.Pos, 300, self.Team, true) do
				if MovableMan:IsActor(MO) then
					local actor = MO;
					self.pointed = MovableMan:GetMOFromID(
						SceneMan:CastMORay(
							self.Pos,
							(actor.Pos - self.Pos),
							self.ID,
							self.IgnoresWhichTeam,
							0,
							false,
							1
						)
					)
				end
			end
		end
	end
end

function Update(self)
	if self.ToSettle == true then
		self.ToSettle = false
	end
	self.oldAngle = self.RotAngle
	self.lockOnVector = Vector(800, 0):RadRotate(self.RotAngle)
	self.chaseVel = Vector(50, 0):RadRotate(self.RotAngle)
	if self.pointed == nil then
		self.pointed = MovableMan:GetMOFromID(
			SceneMan:CastMORay(self.Pos, self.lockOnVector, self.ID, self.IgnoresWhichTeam, 0, false, 1)
		)
		if self.pointed == nil then
			for MO in MovableMan:GetMOsInRadius(self.Pos, 300, self.Team, true) do
				if MovableMan:IsActor(MO) then
					local actor = MO;
					self.pointed = MovableMan:GetMOFromID(
						SceneMan:CastMORay(
							self.Pos,
							(actor.Pos - self.Pos),
							self.ID,
							self.IgnoresWhichTeam,
							0,
							false,
							1
						)
					)
				end
			end
		end
	elseif self.pointed ~= nil then
		self.pointedRoot = MovableMan:GetMOFromID(self.pointed.RootID)
	end
	if
		self.pointedRoot ~= nil
		and self.pointedRoot.ID ~= self.ID
		and MovableMan:IsActor(self.pointedRoot)
		and self.pointedRoot.ID ~= self.ownerRoot.ID
		and self.pointedRoot.Team ~= self.ownerRoot.Team
	then
		self:EnableEmission(true)
		local targetPos = self.pointedRoot.Pos + (self.pointedRoot.Vel / 3)
		local selfPos = self.Pos + (self.Vel / 3)
		local yDiff = targetPos.Y - selfPos.Y
		local xDiff = targetPos.X - selfPos.X
		if SceneMan.SceneWrapsX == true then
			if xDiff > (SceneMan.SceneDim.X / 2) or xDiff < (SceneMan.SceneDim.X / -2) then
				self.RotAngle = self.oldAngle
				self.Vel = self.chaseVel
			else
				self.RotAngle = math.atan2(-yDiff, xDiff)
				self.Vel = self.chaseVel
			end
		else
			self.RotAngle = math.atan2(-yDiff, xDiff)
			self.Vel = self.chaseVel
		end
	else
		self.pointed = MovableMan:GetMOFromID(
			SceneMan:CastMORay(self.Pos, self.lockOnVector, self.ID, self.IgnoresWhichTeam, 0, false, 1)
		)
		if self.pointed == nil then
			for MO in MovableMan:GetMOsInRadius(self.Pos, 300, self.Team, true) do
				if MovableMan:IsActor(MO) then
					local actor = MO;
					self.pointed = MovableMan:GetMOFromID(
						SceneMan:CastMORay(
							self.Pos,
							(actor.Pos - self.Pos),
							self.ID,
							self.IgnoresWhichTeam,
							0,
							false,
							1
						)
					)
				end
			end
		end
	end
end
