function Create(self)
	self.burnTimer = Timer()
	self.burnStrength = 1 + math.random(0, 3)
	self.target = nil
	self.stickpositionX = 0
	self.stickpositionY = 0
	self.stickrotation = 0
	self.stickdirection = 0
	for MO in MovableMan:GetMOsInRadius(self.Pos, 80, -1, true) do
		if MovableMan:ValidMO(MO) then
			local posDiff = MO.Pos - self.Pos
			self.RotAngle = math.atan2(-posDiff.Y, posDiff.X)
			self.stickObject = SceneMan:CastMORay(
				self.Pos,
				Vector(10, 0):RadRotate(self.RotAngle),
				255,
				-2,
				0,
				false,
				0
			)
			if self.stickObject ~= 255 and self.stickObject ~= nil then
				self.target = MovableMan:GetMOFromID(self.stickObject)
				self.targetRoot = MovableMan:GetMOFromID(self.target.RootID)
				self.targetclass = self.target.ClassName
				self.stickpositionX = self.Pos.X - self.target.Pos.X
				self.stickpositionY = self.Pos.Y - self.target.Pos.Y
				self.stickrotation = self.target.RotAngle
				self.stickdirection = self.RotAngle
			end
		end
	end
end

function Update(self)
	self.burnStrength = 1 + math.random(0, 3)
	local altitude = self:GetAltitude(100, 2)
	if self.target ~= nil and self.target.ID ~= 255 then
		self.ToSettle = false
		self.Pos = self.target.Pos
			+ Vector(self.stickpositionX, self.stickpositionY):RadRotate(
				self.target.RotAngle - self.stickrotation
			)
			+ (self.target.Vel / 3)
		self.RotAngle = self.stickdirection + (self.target.RotAngle - self.stickrotation)
		self.Vel = Vector(0, 0)
		self.PinStrength = 1000
	end
	if self.burnTimer:IsPastSimMS(200) then
		for MO in MovableMan:GetMOsInRadius(self.Pos, 80, -1, true) do
			if (MovableMan:IsActor(MO)) then
				local actor = ToActor(MO);
				local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, true).Magnitude
				if self.targetRoot ~= nil and actor.GetsHitByMOs == true and actor.ID ~= 255 then
					if actor.ID == self.targetRoot.ID then
						if actor:HasObjectInGroup("Craft") then
							actor.Health = actor.Health - (self.burnStrength / 3)
						else
							actor.Health = actor.Health - self.burnStrength
						end
					elseif dist < 40 and actor.ID ~= self.targetRoot.ID then
						if actor:HasObjectInGroup("Craft") then
							actor.Health = actor.Health - (self.burnStrength / 3)
						else
							actor.Health = actor.Health - self.burnStrength
						end
					end
				elseif targetRoot == nil and dist < 40 and actor.GetsHitByMOs == true and actor.ID ~= 255 then
					actor.Health = actor.Health - self.burnStrength
				end
			end
		end
		self.burnTimer:Reset()
	end
	if altitude >= 8 and self.targetRoot == nil then
		self.PinStrength = 0
	elseif altitude < 8 then
		self.PinStrength = 1000
	end
end
