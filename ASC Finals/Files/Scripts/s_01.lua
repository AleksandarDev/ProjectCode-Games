
goToNextScreen = false
exiting = false
nextScreenTransitionTime = 0.0
transitionTimeTotal = nil
transitionOffsetTotal = nil
transitionSpeed = nil

spritePosX = 0.0
spritePosY = 0.0
spritePtr = nil
spriteSize = 6.5
nextSpritePtr = nil

currSprite = nil
spritesSize = 14
spriteNames = {	"spritePicture_start", "spritePicture_team", "spritePicture_bojan", "spritePicture_aleks",
				"spritePicture_idea01", "spritePicture_idea02", "spritePicture_idea03",
				"spritePicture_IDE01", "spritePicture_IDE02", "spritePicture_IDE03", "spritePicture_IDE04", "spritePicture_IDE05",
				"spritePicture_Ava01", "spritePicture_Ava02"}
spriteTransitionDirection = {{0, 1}, {-1, 0}, {-1, 0},
							{0, 1}, {-1, 0}, {-1, 0},
							{0, 1}, {-1, 0},
							{0, 1},	{-1, 0}, {-1, 0}, {-1, 0},
							{0, 1}, {0, 1}}

-- Called after the script has started.
function Start(transitionTime, transitionOffset, transitionSpeedArg)
	
	info("started")
	currSprite = 1
	transitionTimeTotal = tonumber(transitionTime)
	transitionOffsetTotal = tonumber(transitionOffset)
	transitionSpeed = tonumber(transitionSpeedArg)
	spritePtr = addSprite(spriteNames[currSprite], spritePosX, spritePosY, 0.0, spriteSize*1.333, spriteSize*1, 0, shadowTypeNone)
end

-- Called before every frame is rendered.
function Update(dt)
	
	if (goToNextScreen) then -- animate transition
		nextScreenTransitionTime = nextScreenTransitionTime + dt
		spritePosX = spritePosX + transitionSpeed*math.abs(math.abs(transitionOffsetTotal) - math.abs(spritePosX))*dt*spriteTransitionDirection[currSprite][1]
		spritePosY = spritePosY + transitionSpeed*math.abs(math.abs(transitionOffsetTotal) - math.abs(spritePosY))*dt*spriteTransitionDirection[currSprite][2]
		sprite.update(spritePtr, spritePosX, spritePosY, spriteSize*1.333, spriteSize*1, 0)
		if (not exiting) then sprite.update(nextSpritePtr,
			spritePosX - transitionOffsetTotal*spriteTransitionDirection[currSprite][1],
			spritePosY - transitionOffsetTotal*spriteTransitionDirection[currSprite][2],
			spriteSize*1.333, spriteSize*1, 0) end
	end
	
	if ((goToNextScreen) and (nextScreenTransitionTime >= transitionTimeTotal)) then
		
		-- set next screen as current
		goToNextScreen = false
		removeSprite(spritePtr)
		info("sprite removed")
		spritePtr = nextSpritePtr
		currSprite = currSprite + 1
		if (exiting) then
			script.stop("s_01")
		end
		nextScreenTransitionTime = 0.0
		spritePosX = 0.0
		spritePosY = 0.0
	end

end

-- Called after the script has ended.
function Stop()
	info("stopped")
end

-- Called when user touches the screen.
function OnInput(type, coordX, coordY)
	x, y = transformFromScreenSpaceToWorld(coordX, coordY)
	
	if ((type == inputTypeUp) and (not goToNextScreen)) then
	
		if (currSprite < spritesSize) then
		
			info("transition has begun")
			goToNextScreen = true
			nextSpritePtr = addSprite(spriteNames[currSprite + 1],
			spritePosX - transitionOffsetTotal*spriteTransitionDirection[currSprite][1],
			spritePosY - transitionOffsetTotal*spriteTransitionDirection[currSprite][2],
			0.0, spriteSize*1.333, spriteSize*1, 0, shadowTypeNone)
		
		else
			exiting = true
			goToNextScreen = true
			script.start("s_02", transitionTimeTotal, transitionOffsetTotal, transitionSpeed)
		end
	end
	
end
