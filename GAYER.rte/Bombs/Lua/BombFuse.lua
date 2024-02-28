local function lightFuse(self)
	if not self:IsActivated() and not self:GetParent() then
		self:Activate()
	end
end

function Create(self)
	self.lightFuse = lightFuse

	self.active = false
	self.fuse = CreateAEmitter(self.PresetName .. " Fuse")
	self.fuse.Pos = self.Pos
	self:AddEmitter(self.fuse)

	self:lightFuse()
end

function Update(self)
	self:lightFuse()

	if not self.active and self:IsActivated() then
		if not self.fuse:IsEmitting() then
			self.fuse:EnableEmission(true)
		end
		self.active = true
	end
end
