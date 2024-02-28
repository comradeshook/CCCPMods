function Update(self)
	if self:GetController():IsState(Controller.PRIMARY_ACTION) then
		self:GibThis()
	end
end
