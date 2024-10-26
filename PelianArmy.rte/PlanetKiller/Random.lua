function Create(self)
	self.durp = math.random(1, self.FrameCount)
	self.Frame = self.durp
end

function Update(self)
	self.Frame = self.durp
end
