function Create(self)
	function doShit()
		for emitter in self.Attachables do
			ToAEmitter(emitter):EnableEmission(true)
		end
		self.AngularVel = 25 * self.FlipFactor
	end

	if not self:GetParent() then
		doShit()
	end
end

function OnDetach(self, exParent)
	doShit()
end
