function OnFire(self)
	if self:IsEmpty() then
		self:Reload();
	end
end