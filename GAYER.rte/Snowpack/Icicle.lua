function Update(self)
	if self.Vel.Magnitude < 90 then
		self.ApplyWoundBurstDamageOnCollision = false;
	else
		self.ApplyWoundBurstDamageOnCollision = true;
	end
end