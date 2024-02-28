function Update(self)
	if self.Frame < 3 then
		self.Frame = self.Frame + 1
	else
		self.ToDelete = true
	end
end
