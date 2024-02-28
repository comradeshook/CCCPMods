function absolutelyFuckingGib(target, velocity)
	for mo in ToMOSRotating(target).Attachables do
		absolutelyFuckingGib(mo, velocity);
	end
	target.Vel = target.Vel + velocity
	ToMOSRotating(target):GibThis()
end
