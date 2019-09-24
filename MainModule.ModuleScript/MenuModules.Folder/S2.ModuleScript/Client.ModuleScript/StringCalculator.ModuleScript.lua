script.Name = "StringCalculator"

local LuaMathFuncs = {
	
	round = function ( Num, DecimalsPoints )
	
		local Mult = 10 ^ ( DecimalsPoints or 0 )
		
		return math.floor( Num * Mult + 0.5 ) / Mult
	
	end,
	
	truncate = function ( Num, DecimalsPoints )
	
		local Mult = 10 ^ ( DecimalsPoints or 0 )
		
		local FloorOrCeil = Num < 0 and math.ceil or math.floor
	
		return FloorOrCeil( Num * Mult ) / Mult
	
	end,

	approach = function ( Num, Target, Inc )
	
		Inc = math.abs( Inc )
	
		if ( Num < Target ) then
	
			return math.min( Num + Inc, Target )
	
		elseif ( Num > Target ) then
	
			return math.max( Num - Inc, Target )
	
		end
	
		return Target
	
	end
	
}

function MapArgs( Nums, Args )
	
	for _, Num in ipairs( Nums) do
		
		if type( Num ) == "table" then
			
			Num = MapArgs( Num, Args )
			
		elseif Args[ Num ] then
			
			Num = Args[ Num ]
			
		end
		
	end
	
	return Nums
	
end

function ToNumber( Nums, LocalFuncs, Attempt )
	
	local a = 1
	
	while a <= #Nums do
		
		if type( Nums[ a ] ) == "table" then
			
			local Prev = Nums[ a - 1 ]
			
			if Prev then
				
				if type( Prev ) == "number" then
					
					Nums[ a - 1 ] = Nums[ a - 1 ] * ToNumber( Nums[ a ], LocalFuncs )
					
					table.remove( Nums, a )
					
				elseif type( Prev ) == "function" or LocalFuncs[ Prev ] then
					
					local Args = { { } }
					
					for _, Arg in ipairs( Nums[ a ] ) do
						
						if Arg == "," then
							
							Args[ #Args ] = ToNumber( Args[ #Args ] )
							
							Args[ #Args + 1 ] = { }
							
						else
							
							Args[ #Args ][ #Args[ #Args ] + 1 ] = Arg
							
						end
						
					end
					
					Args[ #Args ] = ToNumber( Args[ #Args ], LocalFuncs )
					
					if type( Prev ) == "function" then
						
						Nums[ a - 1 ] = Prev( unpack( Args ) )
						
					elseif type( LocalFuncs[ Prev ] ) == "number" then
						
						Nums[ a - 1 ] = LocalFuncs[ Prev ]
						
					else
						
						local MappedArgs = { }
						
						for _, Func in ipairs( LocalFuncs[ Prev ][ 2 ] ) do
							
							MappedArgs[ Func[ a ] ] = Args[ a ]
							
						end
						
						local Func = MapArgs( LocalFuncs[ Prev ][ 1 ], MappedArgs )
						
						Nums[ a - 1 ] = ToNumber( Func, LocalFuncs, Attempt )
						
					end
					
					table.remove( Nums, a )
					
				else
					
					Nums[ a ] = ToNumber( Nums[ a ], LocalFuncs, Attempt )
					
					a = a + 1
					
				end
				
			else
				
				Nums[ a ] = ToNumber( Nums[ a ], LocalFuncs, Attempt )
				
				a = a + 1
				
			end
			
		else
			
			a = a + 1
			
		end
		
	end
	
	a = 1
	
	while a <= #Nums do
		
		if Nums[ a ] == "!" and type( Nums[ a - 1 ] ) == "number" then
			
			local x = Nums[ a - 1 ]
			
			local Total = 1
			
			while x > 0 do
				
				Total = Total * x
				
				x = x - 1
				
			end
			
			Nums[ a - 1 ] = Total
			
			table.remove( Nums, a )
			
		else
			
			a = a + 1
			
		end
		
	end
	
	a = 1
	
	while a <= #Nums do
		
		if Nums[ a ] == "^" and type( Nums[ a - 1 ] ) == "number" and type( Nums[ a + 1 ] ) == "number" then
			
			Nums[ a - 1 ] = Nums[ a - 1 ] ^ Nums[ a + 1 ]
			
			table.remove( Nums, a )
			
			table.remove( Nums, a )
			
		else
			
			a = a + 1
			
		end
		
	end
	
	a = 1
	
	while a <= #Nums do
		
		if Nums[ a ] == "%" and type( Nums[ a - 1 ] ) == "number" and type( Nums[ a + 1 ] ) == "number" then
			
			Nums[ a - 1 ] = Nums[ a - 1 ] % Nums[ a + 1 ]
			
			table.remove( Nums, a )
			
			table.remove( Nums, a )
			
		else
			
			a = a + 1
			
		end
		
	end
	
	a = 1
	
	while a <= #Nums do
		
		if Nums[ a ] == "*" and type( Nums[ a - 1 ] ) == "number" and type( Nums[ a + 1 ] ) == "number" then
			
			Nums[ a - 1 ] = Nums[ a - 1 ] * Nums[ a + 1 ]
			
			table.remove( Nums, a )
			
			table.remove( Nums, a )
			
		elseif Nums[ a ] == "/" and type( Nums[ a - 1 ] ) == "number" and type( Nums[ a + 1 ] ) == "number" then
			
			Nums[ a - 1 ] = Nums[ a - 1 ] / Nums[ a + 1 ]
			
			table.remove( Nums, a )
			
			table.remove( Nums, a )
			
		else
			
			a = a + 1
			
		end
		
	end
	
	a = 1
	
	while a <= #Nums do
		
		if Nums[ a ] == "+" and type( Nums[ a - 1 ] ) == "number" and type( Nums[ a + 1 ] ) == "number" then
			
			Nums[ a - 1 ] = Nums[ a - 1 ] + Nums[ a + 1 ]
			
			table.remove( Nums, a )
			
			table.remove( Nums, a )
			
		elseif Nums[ a ] == "-" and type( Nums[ a - 1 ] ) == "number" and type( Nums[ a + 1 ] ) == "number" then
			
			Nums[ a - 1 ] = Nums[ a - 1 ] - Nums[ a + 1 ]
			
			table.remove( Nums, a )
			
			table.remove( Nums, a )
			
		elseif a ~= 1 and type( Nums[ a ] ) == "number" and Nums[ a ] < 0 and type( Nums[ a - 1 ] ) == "number" then
			
			Nums[ a - 1 ] = Nums[ a - 1 ] + Nums[ a ]
			
			table.remove( Nums, a )
			
		else
			
			a = a + 1
			
		end
		
	end
	
	if Attempt then
		
		return #Nums == 1 and Nums[ 1 ] or Nums
		
	elseif #Nums == 1 then
		
		return Nums[ 1 ]
		
	else
		
		local Invalid = ""
		
		for _, Num in ipairs( Nums ) do
			
			if type( Num ) ~= "number" and not Num:find( "%W" ) then
				
				Invalid = Invalid .. Num .. ", "
				
			end
			
		end
		
		if Invalid ~= "" then
			
			error( "Unknown variable(s)/function(s) - " .. Invalid:sub( 1, -3 ) )
			
		end
		
		for _, Num in ipairs( Nums )do
			
			if type( Num ) == "string" and Num:find( "%W" ) then
				
				Invalid = Invalid .. Num .. ", "
				
			end
			
		end
		
		if Invalid ~= "" then
			
			error( "Invalid operator(s) - " .. Invalid:sub( 1, -3 ) )
			
		end
		
	end
	
end

function Interpret( Formula, LocalVars )
	
	local Ins = { { } }
	
	local Var
	
	for M1, M2 in string.gmatch( Formula, "(-?%d*%.?%d*)(%D?)" ) do
		
		if Var then
			
			Var = Var .. M1
			
		elseif M1 ~= "" then
			
			Ins[ #Ins ][ #Ins[ #Ins ] + 1 ] = tonumber( M1 )
			
		end
		
		if M2 == "(" then
			
			if Var then
				
				Ins[ #Ins ][ #Ins[ #Ins ] + 1 ] = LocalVars[ Var ] or math[ Var ] or LuaMathFuncs[ Var ] or Var
				
				Var = nil
				
			end
			
			local In = { }
			
			Ins[ #Ins ][ #Ins[ #Ins ] + 1 ] = In
			
			Ins[ #Ins + 1 ] = In
			
		elseif M2 == ")" then
			
			if Var then
				
				Ins[ #Ins ][ #Ins[ #Ins ] + 1 ] = LocalVars[ Var ] or math[ Var ] or LuaMathFuncs[ Var ] or Var
				
				Var = nil
				
			end
			
			Ins[ #Ins ] = nil
			
		elseif M2:find("%W") then
			
			if Var then
				
				Ins[ #Ins ][ #Ins[ #Ins ] + 1 ] = LocalVars[ Var ] or math[ Var ] or LuaMathFuncs[ Var ] or Var
				
				Var = nil
				
			end
			
			Ins[ #Ins ][ #Ins[ #Ins ] + 1 ] = M2
			
		elseif M2 ~= "" then
			
			Var = Var and ( Var .. M2 ) or M2
			
		end
		
	end
	
	if Var then
		
		Ins[ #Ins ][ #Ins[ #Ins ] + 1 ] = LocalVars[ Var ] or math[ Var ] or LuaMathFuncs[ Var ] or Var
		
	end
	
	return Ins[ 1 ]
	
end

return function ( Formula, LocalVars, LocalFuncs )
	
	if tonumber( Formula ) then return tonumber( Formula ) end
	
	local LocalVars, LocalFuncs = LocalVars or { }, LocalFuncs or { }
	
	Formula = Formula:gsub( "%s+", "" )
	
	if Formula:find("%;") then
		-- Split the string into variables/functions and the actual expression
        local LastSplit = Formula:reverse( ):find( ";" )
		
		local Locals
		
        Formula, Locals = Formula:sub( -LastSplit + 1 ), string.split( Formula:sub( 1, -LastSplit - 1 ), ";" )
		-- Iterates through the user defined variables / functions and interpret them
		for _, Local in ipairs( Locals ) do
			
			local Name, Value = Local:match( "(.+)=(.+)" )
			
			if not Name then error( "Invalid local function/variable - " .. Local ) end
			
			local FuncName, Args = Name:match( "(%w+)(%b())" )
			
			if FuncName then
				
				Args = string.split( Args:sub( 2, -2 ), "," )
				
				local Func = ToNumber( Interpret( Value, LocalVars ), LocalFuncs, true )
				
				LocalFuncs[ FuncName ] = type( Func ) == "number" and Func or { Func, Args }
				
			else
				
				local Ran, Result = pcall( ToNumber, Interpret( Value, LocalVars ), LocalFuncs )
				
				if not Ran then
					
					error( "Local variable " .. Name .. " could not be calculated\n" .. Result:sub( -Result:reverse( ):find( ":" ) + 2 ) )
					
				end
				
				LocalVars[ Name ] = Result
				
			end
			
		end
		
	end
	
	local Ran, Result = pcall( ToNumber, Interpret( Formula, LocalVars ), LocalFuncs )
	
	if not Ran then
		
		error( Result:sub( -Result:reverse( ):find( ":" ) + 2 ) )
		
	end
	
	return type( Result ) == "number" and Result or error( "Formula could not be calculated" )
	
end