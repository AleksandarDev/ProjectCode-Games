
actorIndices = {}    -- new array

gateRigidBody = nil
panelRigidBody = nil
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
	info("Level3 started")

	-- Set up the scene
	background(0.0)
	setGrayscaleColor(1.0, 1.0, 1.0, 0.0)
	backgroundSprite1 = addSprite("SomethingBlueBackground", 0.0, 3.0, -2.0, 30.0, 25.0, 0.0, shadowTypeRectangle) -- add 2 tileable background sprites
	backgroundSprite2 = addSprite("SomethingBlueBackground", 30.0, 3.0, -2.0, 30.0, 25.0, 0.0, shadowTypeRectangle)
	portalX = -2.1
	portalY = -0.7
	portalSprite = addSprite("Portal", portalX, portalY, -0.1, 1.2, 1.4, 0.0, shadowTypeNone) -- portal

	restitutionC = 0.3
	frictionC = 0.7
	-- spriteName, isMovable, restitutionC, frictionC, mass, sizeX, sizeY, posX, posY, orientation
	rigidBody[1] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 15.0, 48.0, -6.0, -25.5, 0.0)
	rigidBody[2] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 20.0, 30.0, -1.0, 20.0, 0.0)
	rigidBody[3] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 20.0, 50.0, -15.0, 0.0, 0.0)
	rigidBody[4] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 50.0, 30.0, 0.0, -20.0, 0.0)
	rigidBody[5] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 1.0, 48.0, 2.6, -25.5, 0.0)
	rigidBody[6] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 5.0, 1.0, 5.4, -2.0, 0.0)
	rigidBody[7] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.5, 0.5, 7.0, -4.8, 0.0)
	rigidBody[8] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 4.0, 0.5, 11.0, -3.8, 0.0)
	rigidBody[9] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 1.0, 11.0, -3.2, 0.0)
	rigidBody[10] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 0.5, 3.0, 11.0, -2.0, 0.0)
	rigidBody[11] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 6.0, 1.0, 17.0, -2.0, 0.0)
	rigidBody[12] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.5, 0.5, 15.0, -4.8, 0.0)
	rigidBody[13] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 20.0, 50.0, 28.0, -23.0, 0.0)
	rigidBody[14] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 1.5, 0.5, 9.5, 6.0, 0.0)
	rigidBody[15] = addRectangleRigidBody("LighterGray", false, restitutionC, frictionC, 1.0, 2.0, 0.4, -2.1, -1.4, 0.0)

	panelRigidBody = addRectangleRigidBody("DarkerGray", false, restitutionC, frictionC, 2.0, 1.5, 0.3, 4.0, -4.85, 0.0)
	gateRigidBody = addRectangleRigidBody("DarkerGray", true, restitutionC, frictionC, 2.0, 0.5, 3.4, 1.8, -1.25, 0.0)
	enableRotationRigidBody(gateRigidBody, false)
	panelTimer = 0.0
	panelPressed = false

	updateAmbientLight(0.6, 0.6, 0.6)
	updateLightSource(0, 3.0, 1.0, 1.0, directionalLight, -0.2, 0.2, 0.2)
	setPhysicsFlowOfTime(1.0)

	-- Call in the player character
	currentActor = 0
	startScript("playerCharacters", "level3", 9.5, 7.0, portalX, portalY, 1)

	-- Set text
	textSprite = addSprite("Text03", 11.0, -5.8, 0.01, 6.0, 1.5, 0.0, shadowTypeNone)
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
		
		currentTime, timeFlow = getPhysicsTimeValues()
		movementType = getRigidBodyMovementType(gateRigidBody)
		if (movementType == rigidBodyIsSimulating) then
			if (panelPressed) then
				panelTimer = panelTimer + dt/2.0*timeFlow
				if (panelTimer > math.pi/2.0) then panelTimer = math.pi/2.0 end
			else
				panelTimer = panelTimer - dt/2.0*timeFlow
				if (panelTimer < 0.0) then panelTimer = 0.0 end
			end

			-- Gate
			updateRigidBodyPositionAndOrientation(gateRigidBody, 1.8, -1.25 + -2.0*math.sin(panelTimer), 0.0)
			if ((panelTimer == 1.0) or (panelTimer == 0.0)) then updateRigidBodyVelocity(gateRigidBody, 0.0, 0.0, 0.0)
			else updateRigidBodyVelocity(gateRigidBody, 0.0, -2.0*math.cos(panelTimer), 0.0) end
		else
			x, y, orientation = getRigidBodyPositionAndOrientation(gateRigidBody)
			local val = (y + 1.25)/(-2.0)
			if (val < 0.0) then val = 0.0 end
			if (val > 1.0) then val = 1.0 end
			panelTimer = math.asin(val)
		end

		panelPressed = false
		for i=1, currentActor do
			x, y, orientation = getRigidBodyPositionAndOrientation(actorIndices[i])
			-- Is level complete?
			if ((math.abs(x - portalX) < 0.5) and (math.abs(y - portalY) < 0.5)) then
				isLevelCompleted = true
				info("Level3 completed.")
				stopScript("playerCharacters")
				break
			end
			-- Is panel pressed?
			index, distanceFromPanel = lineIntersection(x, y, 0.0, -1.0, actorIndices[i])
			if ((distanceFromPanel < 0.8) and (index == panelRigidBody)) then
				panelPressed = true
			end
		end
	else
		levelOverTimer = levelOverTimer + dt
		setGrayscaleColor(0.0, 0.0, 0.0, levelOverTimer/levelOverWaitTime)
		if (levelOverTimer >= levelOverWaitTime) then
			if (isLevelFailed) then -- go to next level
				stopScript("level3")
				startScript("level3")
			elseif (isLevelCompleted) then
				stopScript("level3")
				lastLevel, volume = loadSettings()
				if (lastLevel < 4) then saveSettings(4, volume) info("Level4 saved as last level.") end
				startScript("level4")
			end
		end
	end
end

-- Called after the script has ended.
function Stop()
	for i=1, numberOfRigidBodies do
		removeRigidBody(rigidBody[i])
	end
	removeRigidBody(gateRigidBody)
	removeRigidBody(panelRigidBody)
	removeSprite(portalSprite)
	removeSprite(textSprite)
	removeSprite(backgroundSprite1)
	removeSprite(backgroundSprite2)
end

-- Called when other scrpit is trying to send data via sendToScript(..)
function ReceiveMessage(callerScript, charIndex)
	local index = charIndex
	if (tonumber(index) > 0) then
		currentActor = currentActor + 1
		actorIndices[currentActor] = charIndex
	else
		isLevelFailed = true
		info("Level3 failed.")
		stopScript("playerCharacters")
	end
end