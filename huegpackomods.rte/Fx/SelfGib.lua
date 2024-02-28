function Create(self)
	if not self:GetParent() then
		self:GibThis()
	end
	self.gonnaGIB = false
end

function Update(self)
	if self.gonnaGIB == true then
		self:GibThis()
		self.gonnaGIB = false
	end
end

function OnDetach(self, exParent)
	self.gonnaGIB = true
end
