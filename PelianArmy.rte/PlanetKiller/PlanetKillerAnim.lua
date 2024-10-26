local animRadius = 100;
local orbitalVector1 = Vector(200, 0);
local orbitalVector2 = Vector(150, 0);
local orbitalCount1 = 3;
local orbitalCount2 = 4;
local animDuration = math.ceil(0.4 * 60);
local colour = 166;

function Create(self)
	self.animCounter = 0;
end

function Update(self)
	local animFactor = (self.animCounter/animDuration)*math.pi*0.95 + math.pi*0.05;
	PrimitiveMan:DrawCircleFillPrimitive(-1, self.Pos, math.sin(animFactor)*animRadius, colour);
	
	for i = 1, orbitalCount1 do
		PrimitiveMan:DrawCircleFillPrimitive(-1, self.Pos + orbitalVector1:GetRadRotatedCopy(math.pi*(2/orbitalCount1)*i+animFactor*2)*math.sin(animFactor), math.sin(animFactor)*animRadius*0.5, colour);
	end
	
	for i = 1, orbitalCount2 do
		PrimitiveMan:DrawCircleFillPrimitive(-1, self.Pos + orbitalVector2:GetRadRotatedCopy(math.pi*(2/orbitalCount2)*i-animFactor)*math.sin(animFactor), math.sin(animFactor)*animRadius*0.25, colour);
	end
	
	if self.animCounter > animDuration then
		self.ToDelete = true;
	end
	self.animCounter = self.animCounter + 1;
end