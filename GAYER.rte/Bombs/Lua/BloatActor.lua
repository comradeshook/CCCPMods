package.path = package.path .. string.format(";GAYER.rte/?.lua")
require("MegaGib")

function Create(self)
	self.bloatFrames = 300
	self.bloatFactor = 1.5
	self.bloatIncrement = self.bloatFactor / self.bloatFrames
end

function Update(self)
	if self.Scale < self.bloatFactor then
		for mo in self.Attachables do
			mo.ParentOffset = Vector(mo.ParentOffset.X, mo.ParentOffset.Y):SetMagnitude(
				(mo.ParentOffset.Magnitude / mo.Scale) * (mo.Scale + self.bloatIncrement)
			)
			mo.Scale = mo.Scale + self.bloatIncrement
		end
		self.Scale = self.Scale + self.bloatIncrement
	elseif self.Scale >= self.bloatFactor then
		self.deathPuff = CreateAEmitter("Bloating Gas Puff")
		self.deathPuff.Pos = self.Pos
		MovableMan:AddParticle(self.deathPuff)
		absolutelyFuckingGib(self, Vector(0, 0))
	end
end