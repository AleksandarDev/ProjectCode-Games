
actorIndices = {}    -- new array

rigidBodyElevator = nil
numberOfRigidBodies = 15
rigidBody = {}    -- new array
for i=1, numberOfRigidBodies do
	rigidBody[i] = nil
end

-- Called after the script has started.
function Start()

	isLevelCompleted = false
	isLevelFailed = false
	levelOverTimer = 0.0
	levelOverWaitTime = 1.0
	info("Level1 started")

	-- Set up the scene
	background(0.0)
	setGrayscaleColor(1.0, 1.0, 1.0, 0.0)
	backgroundSprite = addSprite("IcyBackground", 9.0, 0.0, -2.0, 30.0, 30.0, 0.0, shadowTypeRectangle) -- background
	portalX = 16.0
	portalY = 5.2
	portalSprite = addSprite("Portal", portalX, portalY, -0.1, 1.2, 1.4, 0.0, shadowTypeNone) -- portal
	--updateLightSource(1, 16.0, 4.2, 1.0, pointLight, 0.0, 0.0, 0.5) -- portal light
	updateAmbientLight(0.6, 0.6, 0.6)
	updateLightSource(0, 6.0, 9.0, 3.0, pointLight, 1.0, 1.0, 1.0)

	restitutionC = 0.3
	frictionC = 0.7
	-- spriteName, isMovable, restitutionC, frictionC, mass, sizeX, sizeY, posX, posY, orientation
	rigidBody[1] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 0.4, 2.0, 1.0, 0.0) -- few platforms
	rigidBody[2] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 0.4, 4.0, 1.5, 0.0)
	rigidBody[3] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 0.4, 6.0, 2.0, 0.0)
	rigidBody[4] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 0.4, 8.0, 2.5, 0.0)
	rigidBody[5] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 0.4, 10.0, 3.0, 0.0)
	rigidBody[6] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 0.4, 12.0, 3.5, 0.0)
	rigidBody[7] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 0.4, 14.0, 4.0, 0.0)
	rigidBody[8] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 0.4, 16.0, 4.5, 0.0)

	rigidBody[9] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 30.0, 30.0, -18.0, 10.0, 0.0)-- walls 
	rigidBody[10] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 50.0, 50.0, 0.0, -27.0, 0.0)

	rigidBody[11] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 4.0, 4.0, 19.0, -2.0, 0.0)
	rigidBody[12] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 30.0, 30.0, 35.0, 0.0, 0.0)
	rigidBody[13] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 1.5, 1.0, 16.5, -1.5, 0.0)
	rigidBody[14] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 5.0, 1.0, 9.0, -2.0, 0.0)
	rigidBody[15] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 1.0, 9.0, -1.6, 0.0)

	rigidBodyElevator = addRectangleRigidBody("LighterGray", true, restitutionC, frictionC, 1.2, 1.2, 0.3, -2.3, 2.0, 0.0)
	enableRotationRigidBody(rigidBodyElevator, false)
	setPhysicsFlowOfTime(1.0)

	-- Call in the player character
	currentActor = 0
	startScript("playerCharacters", "level1", 18.61, 0.5, portalX, portalY, 0)

	-- Set text
	textSprite = addSprite("Text01", 20.0, -0.5, 0.01, 6.0, 1.5, 0.0, shadowTypeNone)
end

-- Called before every frame is rendered.
function Update(dt) 

	currentTime, flowOfTime = getPhysicsTimeValues()
	if ((not isLevelCompleted) and (not isLevelFailed)) then
		-- Apply gravity.
		if (flowOfTime > 0.0) then
			addForceOnRigidBody(ledgeRigidBody, 0.0, -9.0*2.0)
			for i=1, currentActor do addForceOnRigidBody(actorIndices[i], 0.0, -9.0) end
		end

		-- Elevator
		currentTime, timeFlow = getPhysicsTimeValues()
		updateRigidBodyPositionAndOrientation(rigidBodyElevator, -2.3, 1.0 + 2.0*math.sin(currentTime), 0.0)
		updateRigidBodyVelocity(rigidBodyElevator, 0.0, 2.0*math.cos(currentTime), 0.0)

		-- Is level complete?
		for i=1, currentActor do
			x, y, orientation = getRigidBodyPositionAndOrientation(actorIndices[i])
			if ((math.abs(x - portalX) < 0.5) and (math.abs(y - portalY) < 0.5)) then
				isLevelCompleted = true
				info("Level1 completed.")
				stopScript("playerCharacters")
				break
			end
		end
	else
		levelOverTimer = levelOverTimer + dt
		setGrayscaleColor(0.0, 0.0, 0.0, levelOverTimer/levelOverWaitTime)
		if (levelOverTimer >= levelOverWaitTime) then
			if (isLevelFailed) then -- go to next level
				stopScript("level1")
				startScript("level1")
			elseif (isLevelCompleted) then
				stopScript("level1")
				lastLevel, volume = loadSettings()
				if (lastLevel < 2) then saveSettings(2, volume) info("Level2 saved as last level.") end
				startScript("level2")
			end
		end
	end
end

-- Called after the script has ended.
function Stop()
	for i=1, numberOfRigidBodies do
		removeRigidBody(rigidBody[i])
	end
	removeRigidBody(rigidBodyElevator)
	removeSprite(portalSprite)
	removeSprite(textSprite)
	removeSprite(backgroundSprite)
end

-- Called when other scrpit is trying to send data via sendToScript(..)
function ReceiveMessage(callerScript, charIndex)
	if (tonumber(charIndex) > 0) then
		currentActor = currentActor + 1
		actorIndices[currentActor] = charIndex
	else
		isLevelFailed = true
		info("Level1 failed.")
		stopScript("playerCharacters")
	end
end