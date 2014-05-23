
actorIndices = {}    -- new array

ledgeRigidBody = nil
numberOfRigidBodies = 13
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
	info("Level4 started")

	-- Set up the scene
	background(0.0)
	setGrayscaleColor(1.0, 1.0, 1.0, 0.0)
	backgroundSprite1 = addSprite("SomethingBlueBackground", 0.0, 3.0, -2.0, 30.0, 25.0, 0.0, shadowTypeRectangle) -- add 2 tileable background sprites
	backgroundSprite2 = addSprite("SomethingBlueBackground", 30.0, 3.0, -2.0, 30.0, 25.0, 0.0, shadowTypeRectangle)
	portalX = 9.5
	portalY = -2.5
	portalSprite = addSprite("Portal", portalX, portalY, -0.1, 1.2, 1.4, 0.0, shadowTypeNone) -- portal

	restitutionC = 0.3
	frictionC = 0.7
	-- spriteName, isMovable, restitutionC, frictionC, mass, sizeX, sizeY, posX, posY, orientation
	rigidBody[1] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 10.0, 0.5, 0.0, 0.0, 0.0)
	rigidBody[2] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 1.7, -6.0, 0.6, 0.0)
	rigidBody[3] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 1.8, 0.8, -4.2, 0.0, 0.0)
	rigidBody[4] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.3, 0.8, -5.9, -0.5, 0.0)
	rigidBody[5] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 0.5, 3.0, 4.75, -1.3, 0.0)
	rigidBody[6] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 7.7, 2.5, 0.25, -4.6, 0.0) -- 
	rigidBody[7] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 1.0, 0.5, -6.5, -6.0, 0.0) -- steps
	rigidBody[8] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 1.0, 0.5, -4.0, -4.75, 0.0)
	rigidBody[9] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 30.0, 30.0, -22.0, 0.0, 0.0) -- left wall
	rigidBody[10] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 30.0, 5.0, 20.8, 0.6, 0.0) -- right wall upper part
	rigidBody[11] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 30.0, 15.0, 21.6, -10.6, 0.0) -- right wall lower part
	rigidBody[12] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 30.0, 8.0, 25.0, 0.0, 0.0) -- right wall middle part
	rigidBody[13] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 30.0, 30.0, 0.0, -22.0, 0.0)

	ledgeRigidBody = addRectangleRigidBody("DarkerGray", true, restitutionC, 0.1, 1.0, 5.0, 0.5, 1.5, -3.1, 0.0)

	updateAmbientLight(0.6, 0.6, 0.6)
	updateLightSource(0, 3.0, 1.0, 1.0, directionalLight, -0.1, 0.1, 0.1)
	updateLightSource(1, -4.0, -0.7, 3.0, pointLight, -0.9, 0.9, 0.9)
	setPhysicsFlowOfTime(1.0)

	-- Call in the player character
	currentActor = 0
	startScript("playerCharacters", "level4", -6.0, 2.3, portalX, portalY, 1)
end

-- Called before every frame is rendered.
function Update(dt)

	currentTime, flowOfTime = getPhysicsTimeValues()
	if ((not isLevelCompleted) and (not isLevelFailed)) then
		-- Apply gravity
		if (flowOfTime > 0.0) then
			addForceOnRigidBody(ledgeRigidBody, 0.0, -9.0*2.0)
			for i=1, currentActor do addForceOnRigidBody(actorIndices[i], 0.0, -9.0) end
		end

		for i=1, currentActor do
			x, y, orientation = getRigidBodyPositionAndOrientation(actorIndices[i])
			-- Is level complete?
			if ((math.abs(x - portalX) < 0.5) and (math.abs(y - portalY) < 0.5)) then
				isLevelCompleted = true
				info("Level4 completed.")
				stopScript("playerCharacters")
				break
			end
		end
	else
		levelOverTimer = levelOverTimer + dt
		setGrayscaleColor(0.0, 0.0, 0.0, levelOverTimer/levelOverWaitTime)
		if (levelOverTimer >= levelOverWaitTime) then
			if (isLevelFailed) then -- go to next level
				stopScript("level4")
				startScript("level4")
			elseif (isLevelCompleted) then
				stopScript("level4")
				lastLevel, volume = loadSettings()
				if (lastLevel < 5) then saveSettings(5, volume) info("Level5 saved as last level.") end
				startScript("mainMenu")
			end
		end
	end
end

-- Called after the script has ended.
function Stop()
	for i=1, numberOfRigidBodies do
		removeRigidBody(rigidBody[i])
	end
	removeRigidBody(ledgeRigidBody)

	removeSprite(portalSprite)
	removeSprite(backgroundSprite1)
	removeSprite(backgroundSprite2)
end

-- Called when other scrpit is trying to send data via sendToScript(..)
function ReceiveMessage(callerScript, charIndex)
	if (tonumber(charIndex) > 0) then
		currentActor = currentActor + 1
		actorIndices[currentActor] = charIndex
	else
		isLevelFailed = true
		info("Level4 failed.")
		stopScript("playerCharacters")
	end
end