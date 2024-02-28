function Create(self)
	self.helmetCount = ToMOSRotating(self):GetNumberValue("ExtraHelmetCount");
	self.baseAngle = -0.14;
end

function MakeHelmet(self, angle)
	local helmet = CreateAttachable(self.PresetName);
	helmet:SetNumberValue("ExtraHelmetCount", self.helmetCount - 1);
	helmet.InheritedRotAngleOffset = angle;
	self:AddAttachable(helmet, self.ParentOffset);
	PrimitiveMan:DrawCircleFillPrimitive(self.Pos, self.IndividualRadius + math.random(2), 254);
end

function Update(self)
	if (self.helmetCount > 0) then
		local angle = self.InheritedRotAngleOffset;
		if (angle == 0) then
			angle = self.baseAngle;
		end
		MakeHelmet(self, angle);
		if (math.random() < (1/20)) then
			MakeHelmet(self, -angle);
		end
		self.helmetCount = 0;
	end
end