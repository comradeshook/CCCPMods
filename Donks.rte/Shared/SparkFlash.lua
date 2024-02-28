function Create(self)
	self.flashRadius = 3;
	self.flashColour = 166;
	self.secondaryColour = 5;
	self.flash = true;
end

function Update(self)
	if self.flash then
		PrimitiveMan:DrawCircleFillPrimitive(self.Pos, self.flashRadius*2, self.flashColour);
		self.flash = false;
	else
		PrimitiveMan:DrawCircleFillPrimitive(self.Pos, self.flashRadius, self.secondaryColour);
		self.ToDelete = true;
	end
end