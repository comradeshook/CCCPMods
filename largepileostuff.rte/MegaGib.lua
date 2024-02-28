function absolutelyFuckingGib(target, velocity)
	for mo in ToMOSRotating(target).Attachables do
		for mo2 in ToMOSRotating(mo).Attachables do
			mo2.Vel = mo2.Vel + velocity
			ToMOSRotating(mo2):GibThis()
		end
		mo.Vel = mo.Vel + velocity
		ToMOSRotating(mo):GibThis()
	end
	--target.Vel = target.Vel + velocity; -- commented out because i can't be arsed to change other code
	ToMOSRotating(target):GibThis()
end
