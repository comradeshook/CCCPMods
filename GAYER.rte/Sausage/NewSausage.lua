function Create(self)
	self.maxCharge = 5;
	self.chargeLevel = 0;
	self.chargeRate = 500; -- milliseconds per charge level
	self.strikeRecovery = 50;
	self.chargeTimer = Timer();
	self.baseRange = 18;
	self.whackSound = CreateSoundContainer("Sausage Whack", "GAYER.rte");
	self.baseStance = self.StanceOffset;
	self.baseAngle = self.InheritedRotAngleOffset;
	self.baseArmMoveSpeed = 0;
	self.arm = nil;
	self.bgArmIdleStance = nil;
	self.strikeTimer = Timer();
	
	self.chargeStance = {
		Vector(2, 0), 
		Vector(-3, -2), 
		Vector(-8, -1), 
		Vector(-10, -1), 
		Vector(-14, -1)
	};
	
	self.chargeSpinOffset = {0, 0, 1, 2, 4};
	
	self.strikeStance = Vector(18, 0);
	self.strikeAngle = -1;
	
	self.chargeSpinRate = {0, 0, -0.2, -0.5, -1}; -- radians per frame
	self.chargeAngle = {0.5, 2.5, 2.5, 2.5, 2.5};
end

function Update(self)
	if self:IsActivated() then
		if self.chargeLevel == 0 or self.chargeTimer:IsPastSimMS(self.chargeRate) then
			self.chargeTimer:Reset();
			if self.chargeLevel < self.maxCharge then
				self.chargeLevel = self.chargeLevel + 1;
			end
		end
		
		if self.InheritedRotAngleOffset < self.chargeAngle[self.chargeLevel] and self.chargeSpinRate[self.chargeLevel] == 0 then
			self.InheritedRotAngleOffset = self.InheritedRotAngleOffset + math.min(0.15, self.chargeAngle[self.chargeLevel] - self.InheritedRotAngleOffset);
		end
		
		self.InheritedRotAngleOffset = self.InheritedRotAngleOffset + self.chargeSpinRate[self.chargeLevel];
		
		local handSpinOffset = Vector(self.chargeSpinOffset[self.chargeLevel], 0):GetRadRotatedCopy(self.InheritedRotAngleOffset - 2);
		
		local parent = self:GetRootParent();
		if IsAHuman(parent) then
			parent = ToAHuman(parent);
			if parent.BGArm then
				if self.bgArmIdleStance == nil then
					self.bgArmIdleStance = parent.BGArm.HandIdleOffset;
				end
				
				if self.chargeLevel > 1 then
					parent.BGArm.HandIdleOffset = self.chargeStance[self.chargeLevel]:GetRadRotatedCopy(math.pi + parent:GetAimAngle(false));
				end
			end
		end
		
		self.StanceOffset = self.chargeStance[self.chargeLevel] + handSpinOffset;
		self.SharpStanceOffset = self.chargeStance[self.chargeLevel] + handSpinOffset;
	else
		if self.chargeLevel > 0 then
			local aimAngle = self.RotAngle;
			local origin = self.Pos + Vector(self.JointOffset.X, self.JointOffset.Y):GetXFlipped(self.HFlipped):GetRadRotatedCopy(aimAngle);
			local parent = self:GetRootParent();
			local attachedTo = self:GetParent();
			if IsAHuman(parent) and IsArm(attachedTo) then
				parent = ToAHuman(parent);
				aimAngle = attachedTo.RotAngle;
				self.arm = ToArm(self:GetParent());
				origin = self.arm.Pos + Vector(self.arm.JointOffset.X, self.arm.JointOffset.Y):GetXFlipped(self.HFlipped):GetRadRotatedCopy(aimAngle);
				self.baseArmMoveSpeed = self.arm.MoveSpeed;
				
				if parent.BGArm then
					parent.BGArm.HandIdleOffset = self.bgArmIdleStance;
					self.bgArmIdleStance = nil;
				end
			elseif attachedTo.UniqueID ~= self.UniqueID then
				aimAngle = attachedTo.RotAngle;
			end
			
			local rangeVector = Vector(self.baseRange + (self.arm and self.arm.MaxLength or 0), 0);
			rangeVector = rangeVector:GetXFlipped(self.HFlipped):GetRadRotatedCopy(aimAngle);
			local rayTarget = SceneMan:CastMORay(origin, rangeVector, self.RootID, self.Team, 0, false, 1);
			--PrimitiveMan:DrawLinePrimitive(origin, origin + rangeVector, 13);
			if rayTarget and rayTarget ~= 255 then
				local target = ToMOSRotating(MovableMan:GetMOFromID(rayTarget));
				local force = (self.chargeLevel * 700);
				local woundCount = self.chargeLevel * self.chargeLevel + 1;
				
				target:GetRootParent():AddAbsImpulseForce(rangeVector:SetMagnitude(force), SceneMan:GetLastRayHitPos());
				
				local targetWoundName = target:GetEntryWoundPresetName();
				if targetWoundName ~= "" then
					local woundTemplate = CreateAEmitter(targetWoundName);
					
					for i = 1, woundCount, 1 do
						local bonkWound = CreateAEmitter("Sausage Bonk Wound", "GAYER.rte");
						bonkWound.Pos = target.Pos;
						bonkWound.BurstDamage = woundTemplate.BurstDamage;
						target:AddWound(bonkWound, Vector(0, 0), true);
					end
				end
				
				self.whackSound.Pos = self.Pos;
				self.whackSound:Play();
			end
			
			self.FireSound:Play();
			self.chargeLevel = 0;
			if self.arm then
				self.arm.MoveSpeed = 1;
			end
			self.InheritedRotAngleOffset = self.strikeAngle;
			self.StanceOffset = self.strikeStance;
			self.SharpStanceOffset = self.strikeStance;
			self.strikeTimer:Reset();
		elseif self.strikeTimer:IsPastSimMS(self.strikeRecovery) then
			if self.arm and self.arm.MoveSpeed ~= self.baseArmMoveSpeed then
				self.arm.MoveSpeed = self.baseArmMoveSpeed;
			end
			
			if self.InheritedRotAngleOffset < 0 then
				self.InheritedRotAngleOffset = self.InheritedRotAngleOffset + 0.05;
			end
			
			self.StanceOffset = self.baseStance;
			self.SharpStanceOffset = self.baseStance;
		end
	end
	
	if self.InheritedRotAngleOffset > math.pi * 2 then
		self.InheritedRotAngleOffset = self.InheritedRotAngleOffset - math.pi * 2;
	end
	
	if self.InheritedRotAngleOffset < -math.pi * 2 then
		self.InheritedRotAngleOffset = self.InheritedRotAngleOffset + math.pi * 2;
	end
	--self.StanceOffset = self.chargeStance[self.chargeLevel];
end

function OnDetach(self, oldParent)
	if self.arm then
		self.arm.MoveSpeed = self.baseArmMoveSpeed;
	end
	
	if IsAHuman(oldParent) and self.bgArmIdleStance then
		ToAHuman(oldParent).BGArm.HandIdleOffset = self.bgArmIdleStance;
	end
end