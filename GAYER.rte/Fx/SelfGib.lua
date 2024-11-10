function Create(self)
	if not self:GetParent() then
		self:GibThis()
	end
	self.gonnaGIB = false
end

function Update(self)
	if self:GetRootParent().UniqueID == self.UniqueID then
		self.gonnaGIB = true;
	end
	
	if self.gonnaGIB == true then
		self:GibThis()
		self.gonnaGIB = false
	end
end