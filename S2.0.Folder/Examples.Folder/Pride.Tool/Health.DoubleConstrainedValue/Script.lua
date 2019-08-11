local Stage = 0

local Hit = 0

script.Parent.Changed:Connect( function ( )
	
	if Stage == 4 then return end
	
	if script.Parent.Value <= 0 then
		
		Stage = 4
		
		local Shields = script.Parent.Parent:GetChildren( )
		
		for _, Obj in ipairs( Shields ) do
			
			if Obj.Name == "InnerShield" then
				
				Obj.ParticleEmitter.Enabled = false
				
			end
			
		end
		
		for a = 1, 10 do
			
			if Stage ~= 4 then return end
			
			for _, Obj in ipairs( Shields ) do
				
				if Obj.Name == "InnerShield" then
					
					Obj.Transparency = Obj.Transparency + ( a == 3 and -0.05 or a == 5 and -0.05 or 0.05 )
					
				end
				
			end
			
			wait( )
			
		end
		
		if Stage ~= 4 then return end
		
		for _, Obj in ipairs( Shields ) do
			
			if Obj.Name == "InnerShield" then
				
				Obj.Transparency = 1
				
			end
			
		end
		
		script.Parent.Name = "DisabledHealth"
		
		while wait( 1 )and script.Parent.Value < script.Parent.MaxValue do
			
			script.Parent.Value = script.Parent.Value + ( script.Parent.MaxValue / 180 )
			
		end
		
		script.Parent.Name = "Health"
		
		for a = 1, 8 do
			
			if Stage ~= 4 then return end
			
			for _, Obj in ipairs( Shields ) do
				
				if Obj.Name:find( "Shield" ) then
					
					Obj.Transparency = Obj.Transparency + -0.05
					
				end
				
			end
			
			wait( )
			
		end
		
		if Stage ~= 4 then return end
		
		for _, Obj in ipairs( Shields ) do
			
			if Obj.Name:find( "Shield" ) then
				
				Obj.Transparency = 0.6
				
				Obj.ParticleEmitter.Enabled = true
				
			end
			
		end
		
		Stage = 0
		
	elseif script.Parent.Value <= script.Parent.MaxValue / 4 then
		
		Stage = 3
		
		local Shields = script.Parent.Parent:GetChildren( )
		
		for _, Obj in ipairs( Shields ) do
			
			if Obj.Name == "Shield" then
				
				Obj.ParticleEmitter.Enabled = false
				
			end
			
		end
		
		for a = 1, 8 do
			
			for _, Obj in ipairs( Shields ) do
				
				if Stage ~= 3 then return end
				
				if Obj.Name == "Shield" then
					
					Obj.Transparency = Obj.Transparency + 0.05
					
				end
				
			end
			
			wait( )
			
		end
		
		if Stage ~= 3 then return end
		
		for _, Obj in ipairs( Shields ) do
			
			if Obj.Name == "Shield" then
				
				Obj.Transparency = 1
				
			end
			
		end
		
	elseif script.Parent.Value <= script.Parent.MaxValue / 4 * 2 then
		
		Stage = 2
		
		local Shields = script.Parent.Parent:GetChildren( )
		
		for _, Obj in ipairs( Shields ) do
			
			if Obj.Name == "MiddleShield" then
				
				Obj.ParticleEmitter.Enabled = false
				
			end
			
		end
		
		for a = 1, 8 do
			
			for _, Obj in ipairs( Shields ) do
				
				if Stage ~= 2 then return end
				
				if Obj.Name == "MiddleShield" then
					
					Obj.Transparency = Obj.Transparency + 0.05
					
				end
				
			end
			
			wait( )
			
		end
		
		if Stage ~= 2 then return end
		
		for _, Obj in ipairs( Shields ) do
			
			if Obj.Name == "MiddleShield" then
				
				Obj.Transparency = 1
				
			end
			
		end
		
	elseif script.Parent.Value <= script.Parent.MaxValue / 4 * 3 then
		
		Stage = 1
		
		local Shields = script.Parent.Parent:GetChildren( )
		
		for _, Obj in ipairs( Shields ) do
			
			if Obj.Name == "OuterShield" then
				
				Obj.ParticleEmitter.Enabled = false
				
			end
			
		end
		
		for a = 1, 8 do
			
			for _, Obj in ipairs( Shields ) do
				
				if Stage ~= 1 then return end
				
				if Obj.Name == "OuterShield" then
					
					Obj.Transparency = Obj.Transparency + 0.05
					
				end
				
			end
			
			wait( )
			
		end
		
		if Stage ~= 1 then return end
		
		for _, Obj in ipairs( Shields ) do
			
			if Obj.Name == "OuterShield" then
				
				Obj.Transparency = 1
				
			end
			
		end
		
	end
	
	local MyHit = Hit + 1
	
	Hit = MyHit
	
	local Shields = script.Parent.Parent:GetChildren( )
	
	for _, Obj in ipairs( Shields ) do
		
		if Obj.Name:find( "Shield" ) and Obj.Transparency < 1 then
			
			Obj.Transparency = 0.4
			
		end
		
	end
	
	for _ = 1, 4 do
		
		wait( )
		
		if Hit ~= MyHit then return end
		
		for _, Obj in ipairs( Shields ) do
			
			if Obj.Name:find( "Shield" ) and Obj.Transparency < 1 then
				
				Obj.Transparency = Obj.Transparency + 0.05
				
			end
			
		end
	
	end
	
end )