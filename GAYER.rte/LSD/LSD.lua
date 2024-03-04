local rechargeSpeed = 2 -- seconds
local rechargeRate = (100/60)/rechargeSpeed;

function Create(self)
	local var = {};
	var.chargeLevel = 100;
	var.Magazine = self.Magazine;
	var.Magazine.RoundCount = var.chargeLevel;
	self.var = var;
end

function Update(self)
	local var = self.var;
	if (var.chargeLevel < 100) then
		var.chargeLevel = var.chargeLevel + math.min(100 - var.chargeLevel, rechargeRate);
		var.Magazine.RoundCount = var.chargeLevel;
		
		if (var.chargeLevel == 100 and self:IsActivated() == false) then
			self.ReloadEndSound.Pos = self.Pos;
			self.ReloadEndSound:Play();
		end
		
		if (self:IsActivated()) then
			self:Deactivate();
		end
	end
	
	if (self.FiredFrame) then
		var.Magazine.RoundCount = 0;
		var.chargeLevel = 0;
	end
end