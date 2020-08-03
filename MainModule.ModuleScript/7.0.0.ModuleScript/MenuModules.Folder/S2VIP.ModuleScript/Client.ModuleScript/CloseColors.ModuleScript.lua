local CloseColorsCache = {}

return function(Col)
	if CloseColorsCache[tostring(Col)] then return CloseColorsCache[tostring(Col)] end
	
	local Cols = {[tostring(Col)] = true}
	
	local h, s, v = Color3.toHSV(Col.Color)
	h, s, v = h * 100, s * 100, v * 100
	
	for a = math.max(s - 30, 0), math.min(s + 30, 100) do
		local New = BrickColor.new(Color3.fromHSV(h / 100, a / 100, v / 100))
		
		if not Cols[tostring(New)] then
			Cols[tostring(New)] = true
		end
	end
	
	local tmp = {Col}
	Cols[tostring(Col)] = nil
	for a, b in pairs(Cols) do
		if #tmp > 6 then break end
		tmp[#tmp + 1] = BrickColor.new(a)
	end
	CloseColorsCache[tostring(Col)] = tmp
	
	return tmp
end