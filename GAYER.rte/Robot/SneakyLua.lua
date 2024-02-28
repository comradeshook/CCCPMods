function Create(self)
	self.knockbackTimer = Timer()
	self.resetTimer = Timer()
	self.cancelTimer = Timer()
	self.Pulse1 = 0
	self.Pulse2 = 0
	self.Pulse3 = 0
	self.leftPressed = 0
	self.rightPressed = 0
end

function Update(self)
	if self.knockbackTimer:IsPastSimMS(1000) then
		if self:GetController():IsState(Controller.MOVE_LEFT) then
			self.resetTimer:Reset()
			self.leftPressed = 1
		elseif self:GetController():IsState(Controller.MOVE_RIGHT) then
			self.resetTimer:Reset()
			self.rightPressed = 1
		end
		if
			self.leftPressed == 1
			and self:GetController():IsState(Controller.MOVE_LEFT) == false
			and self.resetTimer:IsPastSimMS(200) == false
		then
			self.Pulse1 = self.Pulse1 + 1
			if self.Pulse2 < 2 then
				self.Pulse2 = 0
			end
			self.leftPressed = 0
			self.cancelTimer:Reset()
		elseif
			self.rightPressed == 1
			and self:GetController():IsState(Controller.MOVE_RIGHT) == false
			and self.resetTimer:IsPastSimMS(200) == false
		then
			self.Pulse2 = self.Pulse2 + 1
			if self.Pulse1 < 2 then
				self.Pulse1 = 0
			end
			self.rightPressed = 0
			self.cancelTimer:Reset()
		end
		if self.resetTimer:IsPastSimMS(200) or self.cancelTimer:IsPastSimMS(200) then
			self.Pulse1 = 0
			self.Pulse2 = 0
		end
		if self.Pulse1 >= 4 then
			self.emitter = CreateAEmitter("Pulse")
			self.emitter.Team = self.Team
			self.emitter.Pos.X = self.Pos.X
			self.emitter.Pos.Y = self.Pos.Y
			self.emitter.RotAngle = self.RotAngle
			MovableMan:AddParticle(self.emitter)
			self.knockbackTimer:Reset()
			self.Pulse1 = 0
			self.Pulse2 = 0
		elseif self.Pulse2 >= 4 then
			self.emitter = CreateAEmitter("Piercing Pulse")
			self.emitter.Team = self.Team
			self.emitter.Pos.X = self.Pos.X
			self.emitter.Pos.Y = self.Pos.Y
			self.emitter.RotAngle = self.RotAngle
			MovableMan:AddParticle(self.emitter)
			self.knockbackTimer:Reset()
			self.Pulse1 = 0
			self.Pulse2 = 0
		elseif self.Pulse1 == 2 and self.Pulse2 == 2 then
			self.emitter = CreateAEmitter("Deadly Pulse")
			self.emitter.Team = self.Team
			self.emitter.Pos.X = self.Pos.X
			self.emitter.Pos.Y = self.Pos.Y
			self.emitter.RotAngle = self.RotAngle
			MovableMan:AddParticle(self.emitter)
			self.knockbackTimer:Reset()
			self.Pulse1 = 0
			self.Pulse2 = 0
		elseif self.Pulse1 == 3 and self.Pulse2 == 3 then
			self.emitter = CreateAEmitter("Instagib Pulse")
			self.emitter.Team = self.Team
			self.emitter.Pos.X = self.Pos.X
			self.emitter.Pos.Y = self.Pos.Y
			self.emitter.RotAngle = self.RotAngle
			MovableMan:AddParticle(self.emitter)
			self.knockbackTimer:Reset()
			self.Pulse1 = 0
			self.Pulse2 = 0
		end
	end
	self.Health = 100
end
