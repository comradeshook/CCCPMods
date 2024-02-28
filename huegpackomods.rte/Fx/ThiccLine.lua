function drawThiccLine(startPos, endPos, thiccness, color)
	local dirVector = SceneMan
		:ShortestDistance(startPos, endPos, true)
		:SetMagnitude((thiccness - 1) / 2)
		:Perpendicularize()
	local pos1 = startPos + dirVector
	local pos2 = startPos - dirVector
	local pos3 = endPos + dirVector
	local pos4 = endPos - dirVector

	PrimitiveMan:DrawTriangleFillPrimitive(pos1, pos2, pos3, color)
	PrimitiveMan:DrawTriangleFillPrimitive(pos3, pos4, pos2, color)
end

--Bungled together by (Comrade)Shook lol
