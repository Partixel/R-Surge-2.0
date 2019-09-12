--[[
	
			       THANKS FOR USING SURGE 2.0 WEAPON SYSTEM
		
		BY INSERTING THIS MODEL INTO YOUR PLACE ANY WEAPON THAT SUPPORTS
 				     THE SURGE 2.0 WEAPON SYSTEM WILL WORK
				
				----------------------------------------------
							
						   USING THE EXAMPLE WEAPONS
						
		      THE EXAMPLE WEAPONS SHOW HOW TO SET UP A WEAPON USING
			    SURGE 2.0 AS WELL AS GIVING A BASE TO START WITH
			
				  MOVE THE GunStats FOLDER TO ReplicatedStorage
				
				----------------------------------------------
				
							  WEAPON REQUIREMENTS
							
					    1. MAKE SURE THE WEAPON HAS A HANDLE
					
	    2.  MAKE A StringValue NAMED GunStat WITH THE VALUE OF THE GUNS NAME
								
			    3. MAKE SURE ALL PARTS ARE WELDED AND UNCOLLIDEABLE
						
						

			 !!!! THE FOLLOWING IS OUT OF DATE, SOME MAY NOT WORK !!!!
				
		 		    ADD THE FOLLOWING AS NECESSARY TO THE TABLE
					  ( IF PREFIXED BY [+] IT IS REQUIRED )
			( IF PREFIXED BY [-] IT IS REQUIRED IN NON-TOOL BASED GUNS )


-- Functions --
Target( ) -- Gets where the user is currently aiming, defaults to the location a player clicked when using Weapon:PlayerToUser( script )
IgnoreFunction( Part ) -- A function that returns true when the gun should ignore Part

-- Values --

[+] FireModes -- A table of FireModes a gun has ( "Auto", "Burst", "Semi", "Safety" OR { Name = "Burst", Automatic = false, Shots = 3 } )
[+] Damage -- Damage of the gun
[+] FireRate -- How many clicks will be handled in a second
[+] MaxAmmo -- The max ammo the gun has, -1 is infinite
[+] ReloadDelay -- The time it takes to reload
[+] Range -- The max distance the bullet can travel
[+] AccurateRange -- The accuracy of the bullet ( The distance at which it will always hit a 1x1x1 block )
[+] Barrels -- A function returning a barrel part or table barrel parts
					     ( if a table the bullets will come from the next barrel in the table after each shot )
[-] User -- A table of information on the player / user, defaults to the players object when in a normal tool clientside
				   ( Weapon.User = { } Weapon.User.Name = "Model" Weapon.User.TeamColor = BrickColor.Random( ) )
[-] Ignore -- A table of parts for the gun to ignore when shooting, defaults to the players character when using Weapon:PlayerToUser( script )
FireSound -- The sound played when a bullet is fired
ReloadSound -- The sound played when the gun reloads
RightWeld -- The CFrame data for the right arm weld when the tool is selected
LeftWeld -- The CFrame data for the left arm weld when the tool is selected
UseBarrelAsOrigin -- Uses the barrel as the origin for the burrel raycast instead of the head ( Use for things like turrets )
PreventSprint -- Prevents sprinting when the gun is selected
WindupTime -- The time it takes to charge up the gun ( e.g. a minigun )
DelayBetweenShots -- How long the delay between each shot per click is
OneAmmoPerClick -- If ShotsPerClick is more then one, does each one use ammo or only the first?
ShotsPerClick -- How many bullets will be shot per click
BulletColor -- The bullets color ( Must be a Color3, e.g. Color3.new( 1, 1, 1 ) or BrickColor.new( "Bright red" ).Color ), if nil uses teamcolor
BulletTransparency -- The bullets transparency, defaults to 0.2
BulletSize -- The bullets thickness, defaults to 0.1
NoAntiWall -- Whether or not to check if the gun is shooting through a wall ( Useful if the barrel is not in
					 the players character, e.g. with turrets ), defaults to false
HitSound -- The sound to be played when hitting a humanoid, defaults to "rbxassetid://161164363"
LongReloadSound -- If true, plays the reload sound once instead of for each ammo added, defaults to false
MouseIcon -- The icon to use for the mouse, can be left as nil if using the S2 gun cursor
Knockback -- The knockback multiplier, can be left as nil
DistanceModifier -- How much the distance from the barrel will affect the damage of the bullet, can be left as nil
						
]]