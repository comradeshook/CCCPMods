function AcidRainScript:StartScript()
	local var = {};
	var.SceneWidth = SceneMan.SceneWidth;
	
end

function AcidRainScript:UpdateScript()
	for i = 1, 5 do
		local acid = CreateMOPixel("Funny Acid", "GAYER.rte");
		acid.Pos = Vector(math.random(0, SceneMan.SceneWidth), -1);
		acid.Vel = Vector(5, 20);
		MovableMan:AddParticle(acid);
		acid:SetNumberValue("GAYER_Corrosion", 2);
	end
end