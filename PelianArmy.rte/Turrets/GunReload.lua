function Update(self)
	if self.Magazine ~= nil then
		if self.Magazine.RoundCount == 0 then
			self:Reload()
		end
	end
end
