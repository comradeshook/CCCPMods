function Create(self)
	local totalVel = math.sqrt(self.Vel.X ^ 2 + self.Vel.Y ^ 2)
	self.speedFactor = math.floor(totalVel / 10)
end

function Update(self)
	if self.ToDelete == false then
		local totalVel = math.sqrt(self.Vel.X ^ 2 + self.Vel.Y ^ 2)
		self.speedFactor = math.floor(totalVel / 10)
		if self.speedFactor <= 7 and self.speedFactor > 0 then
			self.Frame = self.speedFactor
		elseif self.speedFactor > 7 then
			self.Frame = 7
		end
		if totalVel > 110 then
			self:GibThis()
		end
	end
end

function Destroy(self)
	if self.speedFactor <= 1 then
		local Kerblammo1 = CreateAEmitter("Kablammo 1")
		Kerblammo1.Pos.X = self.Pos.X
		Kerblammo1.Pos.Y = self.Pos.Y
		MovableMan:AddParticle(Kerblammo1)
	elseif self.speedFactor == 2 then
		local Kerblammo2 = CreateAEmitter("Kablammo 2")
		Kerblammo2.Pos.X = self.Pos.X
		Kerblammo2.Pos.Y = self.Pos.Y
		MovableMan:AddParticle(Kerblammo2)
	elseif self.speedFactor == 3 then
		local Kerblammo3 = CreateAEmitter("Kablammo 3")
		Kerblammo3.Pos.X = self.Pos.X
		Kerblammo3.Pos.Y = self.Pos.Y
		MovableMan:AddParticle(Kerblammo3)
	elseif self.speedFactor == 4 then
		local Kerblammo4 = CreateAEmitter("Kablammo 4")
		Kerblammo4.Pos.X = self.Pos.X
		Kerblammo4.Pos.Y = self.Pos.Y
		MovableMan:AddParticle(Kerblammo4)
	elseif self.speedFactor == 5 then
		local Kerblammo5 = CreateAEmitter("Kablammo 5")
		Kerblammo5.Pos.X = self.Pos.X
		Kerblammo5.Pos.Y = self.Pos.Y
		MovableMan:AddParticle(Kerblammo5)
	elseif self.speedFactor == 6 then
		local Kerblammo6 = CreateAEmitter("Kablammo 6")
		Kerblammo6.Pos.X = self.Pos.X
		Kerblammo6.Pos.Y = self.Pos.Y
		MovableMan:AddParticle(Kerblammo6)
	elseif self.speedFactor >= 7 then
		local Kerblammo7 = CreateAEmitter("Kablammo 7")
		Kerblammo7.Pos.X = self.Pos.X
		Kerblammo7.Pos.Y = self.Pos.Y
		MovableMan:AddParticle(Kerblammo7)
	end
end
