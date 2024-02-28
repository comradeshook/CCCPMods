function Create(self)
	self.hasSwappedAmmo = false
	self.optionTable = {
		"Magazine HHCannon",
		"Magazine PRLauncher",
		"Magazine RLauncher",
		"Magazine Pyro Cannon",
		"Magazine Pyro Carpet",
		"Magazine Pyro Glob",
		"Magazine Pyro Sniper",
		"Magazine Force Cannon",
		"Magazine Plasma Cannon",
		"Magazine Hailstorm Cannon",
		"Magazine CSCannon",
		"Magazine Split Cannon",
		"Magazine VSR Launcher",
		"That Magazine",
		"Magazine Tuna Cannon",
		"Magazine Orange Shard Cannon",
		"Magazine Bomb Cannon",
	}
	function changeAmmo()
		self:SetNextMagazineName(self.optionTable[math.random(18)]) -- Remember to set the number here to equal the number of items in the above list
	end
	changeAmmo()
end

function Update(self)
	if self.hasSwappedAmmo == false and self:IsReloading() then
		changeAmmo()
		self.hasSwappedAmmo = true
	end

	if self:DoneReloading() then
		self.hasSwappedAmmo = false
	end
end
