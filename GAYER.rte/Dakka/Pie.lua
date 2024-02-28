function MoreDakka(actor)
	actor.userGun = nil
	for i = 1, MovableMan:GetMOIDCount() - 1 do
		actor.userGun = MovableMan:GetMOFromID(i)
		if
			actor.userGun.RootID == actor.ID
			and actor.userGun.ClassName == "HDFirearm"
			and actor.userGun.PresetName == "Dakkagun"
		then
			actor.userGun.Sharpness = actor.userGun.Sharpness + 120
			break
		end
	end
	actor.userGun = nil
end

function LessDakka(actor)
	actor.userGun = nil
	for i = 1, MovableMan:GetMOIDCount() - 1 do
		actor.userGun = MovableMan:GetMOFromID(i)
		if
			actor.userGun.RootID == actor.ID
			and actor.userGun.ClassName == "HDFirearm"
			and actor.userGun.PresetName == "Dakkagun"
		then
			if actor.userGun.Sharpness > 120 then
				actor.userGun.Sharpness = actor.userGun.Sharpness - 120
				break
			else
				actor.userGun.Sharpness = 0
				break
			end
		end
	end
	actor.userGun = nil
end
