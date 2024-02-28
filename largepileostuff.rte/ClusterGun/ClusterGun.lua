function Create(self)
	self.extraGunCount = 30;
	self.gunTable = {};
	self.fireIterator = 0;
	self.baseFrameDelay = (60/(self.RateOfFire/60))/(self.extraGunCount+1);
	self.frameDelay = self.baseFrameDelay + math.random(-2, 2);
	self.gunSpread = 7;
	self.triggerGuns = false;
	self.spawnGuns = true;
	self.emitterSound = self.FireSound;
	self.gunRemainder = 0;
end

function Update(self)
	if self.spawnGuns then
		for i = 1, self.extraGunCount, 1 do
			local gun = CreateAEmitter("Wee Gun", "largepileostuff.rte");
			gun.InheritedRotAngleOffset = math.rad(math.random(-10, 10));
			
			if i % 4 == 0 then
				for emission in gun.Emissions do
					if emission.MinVelocity > 10 then
						if emission.BurstSize == 0 then
							emission.BurstSize = 1;
						else
							emission.BurstSize = 0;
						end
					end
				end
			end
			
			self:AddEmitter(gun, Vector(math.random(-self.gunSpread, self.gunSpread), math.random(-self.gunSpread, self.gunSpread)));
			self.gunTable[i] = gun;
		end
		
		self.spawnGuns = false;
	end
	
	if self.triggerGuns then
		if self.frameDelay <= 0 then
			while self.frameDelay <= 0 and self.triggerGuns == true do
				self.fireIterator = self.fireIterator + 1;
				if self.fireIterator <= #self.gunTable then
					local gun = self.gunTable[self.fireIterator];
					if gun then
						gun:TriggerBurst();
						self.emitterSound:Stop();
						self.emitterSound.Pos = gun.Pos;
						self.emitterSound:Play();
					else
						table.remove(self.gunTable, self.fireIterator)
						self.fireIterator = self.fireIterator - 1;
					end
				else
					self.fireIterator = 0;
					self.triggerGuns = false;
				end
				
				self.baseFrameDelay = (60/(self.RateOfFire/60))/(#self.gunTable + 1);
				self.frameDelay = self.frameDelay + self.baseFrameDelay;
			end
			
			self.frameDelay = self.baseFrameDelay + math.random(-2, 2);
		end
		
		self.frameDelay = self.frameDelay - 1;
	end
end

function OnFire(self)
	self.triggerGuns = true;
	self.fireIterator = 0;
end