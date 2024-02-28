function Create(self)
	self.newHelmet = CreateAttachable(self.PresetName);
	self.newHelmet.ParentOffset = self.ParentOffset;
	self.parent = self:GetParent();
end

function Destroy(self)
	if (MovableMan:IsOfActor(self.parent.ID)) then
		self.parent:AddAttachable(self.newHelmet, self.newHelmet.ParentOffset);
	end
end